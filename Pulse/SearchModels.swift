import AppKit
import Combine
import Foundation
import JavaScriptCore
import SwiftUI

// MARK: - Global Extensions

extension Notification.Name {
    static let pulseKeyEvent = Notification.Name("pulseKeyEvent")
}

extension String {
    func fuzzyMatch(_ query: String) -> Bool {
        if query.isEmpty { return true }
        let queryString = query.lowercased()
        let selfString = self.lowercased()
        var remainder = queryString[...]
        for char in selfString {
            if let first = remainder.first, char == first {
                remainder.removeFirst()
                if remainder.isEmpty { return true }
            }
        }
        return false
    }
}

// MARK: - Core Protocols

public protocol Command: Identifiable {
    var id: UUID { get }
    var stableId: String { get }  // For persistence/ranking
    var name: String { get }
    var icon: NSImage { get }
    var score: Double { get }

    func execute()
}

extension Command {
    // Helper to run safely
    func run() {
        execute()
        // Record usage
        RankingEngine.shared.recordExecution(stableId: stableId)
    }
}

// MARK: - Search Models

public enum ResultType {
    case app
    case system
    case calculator
    case emoji
    case plugin
    case file
    case clipboard
    case snippet
    case quicklink
}

public struct SearchResult: Command, Hashable {
    public let id = UUID()
    public let stableId: String
    public let name: String
    public let path: String
    public let icon: NSImage
    public let symbolName: String?
    public let customIcon: String?  // For emoji symbols
    public let type: ResultType
    public let isFolder: Bool
    public var subtitle: String?
    public let detailContent: String?
    public let action: (() -> Void)?

    // Display Helpers
    public var categoryLabel: String {
        switch type {
        case .app: return "Application"
        case .system: return "System"
        case .calculator: return "Calculator"
        case .emoji: return "Emoji"
        case .plugin: return "Extension"
        case .file: return isFolder ? "Folder" : "File"
        case .clipboard: return "Clipboard"
        case .snippet: return "Snippet"
        case .quicklink: return "Quicklink"
        }
    }

    // Command Protocol Compliance
    public var score: Double {
        return 0.0
    }

    public func execute() {
        if let action = action {
            action()
        } else if type == .app {
            let url = URL(fileURLWithPath: path)
            NSWorkspace.shared.openApplication(
                at: url, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        } else if type == .calculator {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(path, forType: .string)  // path holds result for calc
        } else if type == .plugin {
            ExtensionManager.shared.execute(path)
        } else if type == .file {
            let url = URL(fileURLWithPath: path)
            if NSEvent.modifierFlags.contains(.command) {
                // Explicit "Reveal in Finder"
                NSWorkspace.shared.activateFileViewerSelecting([url])
            } else {
                // Try to open directly (works for files and folders)
                if !NSWorkspace.shared.open(url) {
                    if isFolder {
                        // For folders, try AppleScript as a fallback to force opening
                        let script = "tell application \"Finder\" to open POSIX file \"\(path)\""
                        if let appleScript = NSAppleScript(source: script) {
                            var error: NSDictionary?
                            appleScript.executeAndReturnError(&error)
                        }
                    } else {
                        // Fallback to revealing if direct open fails for files
                        NSWorkspace.shared.activateFileViewerSelecting([url])
                    }
                }
            }
        } else if type == .clipboard || type == .snippet {
            // Logic: Set Pasteboard
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(path, forType: .string)

            // Hide the launcher via notification to avoid scope issues
            NotificationCenter.default.post(name: NSNotification.Name("hidePulse"), object: nil)
        } else if type == .quicklink {
            if let url = URL(string: path) {
                NSWorkspace.shared.open(url)
            }
        }
    }

    public init(
        name: String, path: String, icon: NSImage, symbolName: String? = nil,
        customIcon: String? = nil,
        type: ResultType = .app,
        isFolder: Bool = false, subtitle: String? = nil, detailContent: String? = nil,
        stableId: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.name = name
        self.path = path
        self.icon = icon
        self.symbolName = symbolName
        self.customIcon = customIcon
        self.type = type
        self.isFolder = isFolder
        self.subtitle = subtitle
        self.detailContent = detailContent
        self.action = action
        // Use provided stableId, or fallback to path/name
        self.stableId = stableId ?? path
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(stableId)
    }

    public static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.stableId == rhs.stableId
    }
}

// MARK: - Search Infrastructure

class Calculator {
    static let context = JSContext()

    static func evaluate(_ query: String) -> String? {
        // Simple logic: if it has digits and math operators, try to eval
        let mathRegex = ".*[0-9]+.*[\\+\\-\\*/].*"
        guard query.range(of: mathRegex, options: .regularExpression) != nil else { return nil }

        // 1. Sanitize query - only allow math chars
        let allowedChars = CharacterSet(charactersIn: "0123456789+-*/(). ")
        let cleaned = String(query.unicodeScalars.filter { allowedChars.contains($0) })

        if cleaned.isEmpty { return nil }

        // 2. Safety Check: Filter out dangerous chars (braces, brackets, quotes) to prevent JS injection/execution of arbitrary code
        let riskyChars = CharacterSet(charactersIn: "{}[]'\"`$;")
        if cleaned.rangeOfCharacter(from: riskyChars) != nil {
            return nil
        }

        // 4. Evaluate safely using JavaScriptCore
        let result = context?.evaluateScript(cleaned)

        if let res = result, !res.isUndefined, !res.isNull, let num = res.toNumber() {
            let doubleVal = num.doubleValue
            if doubleVal.isNaN || doubleVal.isInfinite { return nil }

            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 4
            return formatter.string(from: NSNumber(value: doubleVal))
        }

        return nil
    }
}

struct SystemCommand: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let action: () -> Void
    let iconName: String

    static func == (lhs: SystemCommand, rhs: SystemCommand) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func runShell(_ command: String) {
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]
        try? process.run()
    }

    static func runScript(_ source: String) {
        print("DEBUG: runScript called with: \(source)")
        var error: NSDictionary?
        if let script = NSAppleScript(source: source) {
            let result = script.executeAndReturnError(&error)
            if let error = error {
                print("DEBUG: AppleScript error: \(error)")
            } else {
                print("DEBUG: AppleScript executed successfully, result: \(result)")
            }
        } else {
            print("DEBUG: Failed to create NSAppleScript")
        }
    }

    static let all: [SystemCommand] = [
        SystemCommand(name: "Search Emoji & Symbols", action: {}, iconName: "face.smiling"),
        SystemCommand(name: "Sleep", action: { runShell("pmset sleepnow") }, iconName: "moon.fill"),
        SystemCommand(
            name: "Restart", action: { runScript("tell application \"Finder\" to restart") },
            iconName: "restart.circle.fill"),
        SystemCommand(
            name: "Shut Down", action: { runScript("tell application \"Finder\" to shut down") },
            iconName: "power.circle.fill"),
        SystemCommand(
            name: "Lock Screen", action: { runShell("pmset displaysleepnow") },
            iconName: "lock.fill"),
        SystemCommand(
            name: "Empty Trash",
            action: {
                print("DEBUG: Empty Trash action executing...")
                runScript("tell application \"Finder\" to empty trash")
                print("DEBUG: Empty Trash action completed")
            },
            iconName: "trash.fill"),
    ]

    var asSearchResult: SearchResult {
        var icon = NSImage(systemSymbolName: iconName, accessibilityDescription: nil) ?? NSImage()
        var shouldUseCustomIcon = false

        if name == "Search Emoji & Symbols" {
            // Try explicit file path first (for development)
            let devPath = "/Users/pratikbhavarthe/Developer/Pulse/Pulse/emoji_icon.png"
            if FileManager.default.fileExists(atPath: devPath) {
                if let img = NSImage(contentsOfFile: devPath) {
                    icon = img
                    shouldUseCustomIcon = true
                }
            } else if let bundleImage = NSImage(named: "emoji_icon") {
                // Fallback to bundle/asset catalog
                icon = bundleImage
                shouldUseCustomIcon = true
            }

            if shouldUseCustomIcon {
                // Resize to 64x64 (Retina @2x for 32pt display) to match "buttery smooth" requirement
                // This prevents aliasing artifacts from downscaling 512px -> 20px
                icon = icon.resized(to: NSSize(width: 64, height: 64)) ?? icon
                icon.size = NSSize(width: 32, height: 32)  // Logical size 32pt
            }
        }

        return SearchResult(
            name: name,
            path: "system",
            icon: icon,
            symbolName: shouldUseCustomIcon ? nil : iconName,  // Nil out symbol name to force NSImage rendering
            type: .system,
            isFolder: false,
            subtitle: "System Command",
            stableId: "system.\(name.lowercased().replacingOccurrences(of: " ", with: "."))",
            action: action
        )
    }
}

class AppSearch: ObservableObject {
    static let shared = AppSearch()
    @Published var apps: [SearchResult] = []
    private var isScanning = false

    private init() { scanApps() }

    func scanApps() {
        guard !isScanning else { return }
        isScanning = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var foundApps: [SearchResult] = []
            let directories = [
                "/Applications", "/Applications/Utilities", "/System/Applications",
                "/System/Applications/Utilities", "/System/Library/CoreServices",
                "/System/Library/CoreServices/Applications",
                ("~" as NSString).expandingTildeInPath + "/Applications",
            ]
            let workspace = NSWorkspace.shared
            for dir in directories {
                guard let contents = try? FileManager.default.contentsOfDirectory(atPath: dir)
                else {
                    continue
                }
                for item in contents where item.hasSuffix(".app") {
                    let path = (dir as NSString).appendingPathComponent(item)
                    let icon = workspace.icon(forFile: path)
                    let bundle = Bundle(path: path)
                    let stableId = bundle?.bundleIdentifier ?? path
                    foundApps.append(
                        SearchResult(
                            name: (item as NSString).deletingPathExtension, path: path, icon: icon,
                            stableId: stableId))
                }
            }
            DispatchQueue.main.async {
                self?.apps = foundApps
                self?.isScanning = false
            }
        }
    }
}

struct ClipboardEntry: Codable, Identifiable {
    let id: UUID
    let content: String
    let timestamp: Date
}

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()
    @Published var history: [ClipboardEntry] = []
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private let storageURL: URL

    private init() {
        self.lastChangeCount = pasteboard.changeCount
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent(
                "Pulse")
        try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        self.storageURL = appSupport.appendingPathComponent("clipboard_history.json")
        loadHistory()
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
    }

    private func checkPasteboard() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        if let newString = pasteboard.string(forType: .string), !newString.isEmpty {
            history.removeAll { $0.content == newString }
            let entry = ClipboardEntry(id: UUID(), content: newString, timestamp: Date())
            history.insert(entry, at: 0)
            if history.count > 50 { history = Array(history.prefix(50)) }
            saveHistory()
        }
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) { try? data.write(to: storageURL) }
    }

    private func loadHistory() {
        if let data = try? Data(contentsOf: storageURL),
            let decoded = try? JSONDecoder().decode([ClipboardEntry].self, from: data)
        {
            history = decoded
        }
    }
}

struct Snippet: Codable, Identifiable {
    let id: UUID
    let trigger: String
    let content: String
}

class SnippetManager: ObservableObject {
    static let shared = SnippetManager()
    @Published var snippets: [Snippet] = []
    private let storageURL: URL

    private init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent(
                "Pulse")
        try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        self.storageURL = appSupport.appendingPathComponent("snippets.json")
        loadSnippets()
    }

    func loadSnippets() {
        if let data = try? Data(contentsOf: storageURL),
            let decoded = try? JSONDecoder().decode([Snippet].self, from: data)
        {
            snippets = decoded
        }
    }
}

class ExtensionManager: ObservableObject {
    static let shared = ExtensionManager()
    @Published var extensions: [SearchResult] = []
    private let extensionsURL: URL? = {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first
        return appSupport?.appendingPathComponent("Pulse/Extensions")
    }()

    private init() { scanExtensions() }

    func scanExtensions() {
        guard let url = extensionsURL,
            let contents = try? FileManager.default.contentsOfDirectory(
                at: url, includingPropertiesForKeys: nil)
        else { return }
        var found: [SearchResult] = []
        for fileURL in contents {
            if let content = try? String(contentsOf: fileURL, encoding: .utf8) {
                let lines = content.components(separatedBy: .newlines)
                var title: String?
                for line in lines.prefix(10) {
                    if line.contains("@pulse.title:") {
                        title = line.components(separatedBy: ":").last?.trimmingCharacters(
                            in: .whitespaces)
                    }
                }
                if let title = title {
                    found.append(
                        SearchResult(
                            name: title, path: fileURL.path,
                            icon: NSWorkspace.shared.icon(forFile: fileURL.path), type: .plugin,
                            subtitle: "Extension", stableId: "ext_" + title))
                }
            }
        }
        DispatchQueue.main.async { self.extensions = found }
    }

    func execute(_ path: String) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", path]
        try? task.run()
    }
}

// MARK: - Quicklinks

struct Quicklink: Codable, Identifiable {
    var id: UUID
    var name: String
    var link: String
    var icon: String
    var openWith: String?
}

class QuicklinkManager: ObservableObject {
    static let shared = QuicklinkManager()
    @Published var quicklinks: [Quicklink] = []
    private let storageURL: URL

    private init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent(
                "Pulse")
        try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        self.storageURL = appSupport.appendingPathComponent("quicklinks.json")
        loadQuicklinks()

        // Add default quicklinks if empty
        if quicklinks.isEmpty {
            addDefaultQuicklinks()
        }
    }

    func loadQuicklinks() {
        if let data = try? Data(contentsOf: storageURL),
            let decoded = try? JSONDecoder().decode([Quicklink].self, from: data)
        {
            quicklinks = decoded
        }
    }

    func saveQuicklinks() {
        if let data = try? JSONEncoder().encode(quicklinks) {
            try? data.write(to: storageURL)
        }
    }

    func addQuicklink(name: String, link: String, icon: String = "link", openWith: String? = nil) {
        let newLink = Quicklink(
            id: UUID(), name: name, link: link, icon: icon, openWith: openWith)
        quicklinks.append(newLink)
        saveQuicklinks()
    }

    func deleteQuicklink(id: UUID) {
        quicklinks.removeAll { $0.id == id }
        saveQuicklinks()
    }

    private func addDefaultQuicklinks() {
        addQuicklink(
            name: "Search Google", link: "https://www.google.com/search?q={argument}",
            icon: "globe")
        addQuicklink(
            name: "Search GitHub", link: "https://github.com/search?q={argument}",
            icon: "chevron.left.forwardslash.chevron.right")
        addQuicklink(
            name: "Open Downloads", link: "file://~/Downloads", icon: "arrow.down.circle")
    }

    func resolve(link: String, query: String) -> String {
        var resolved = link

        // Replace {argument}
        let encodedQuery =
            query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            ?? query
        resolved = resolved.replacingOccurrences(of: "{argument}", with: encodedQuery)

        // Replace {clipboard}
        if resolved.contains("{clipboard}") {
            let clipboardContent = NSPasteboard.general.string(forType: .string) ?? ""
            let encodedClipboard =
                clipboardContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                ?? ""
            resolved = resolved.replacingOccurrences(
                of: "{clipboard}", with: encodedClipboard)
        }

        return resolved
    }
}

class FileSearchManager: NSObject, ObservableObject {
    static let shared = FileSearchManager()
    @Published var results: [SearchResult] = []
    private let query = NSMetadataQuery()

    private override init() {
        super.init()
        query.searchScopes = [NSMetadataQueryUserHomeScope]
        NotificationCenter.default.addObserver(
            self, selector: #selector(queryDidUpdate), name: .NSMetadataQueryDidFinishGathering,
            object: query)
        NotificationCenter.default.addObserver(
            self, selector: #selector(queryDidUpdate), name: .NSMetadataQueryDidUpdate,
            object: query)
    }

    func search(queryStr: String) {
        guard queryStr.count >= 2 else {
            self.results = []
            return
        }
        query.stop()
        query.predicate = NSPredicate(format: "kMDItemDisplayName CONTAINS[cd] %@", queryStr)
        query.start()
    }

    @objc private func queryDidUpdate(_ notification: Notification) {
        var found: [SearchResult] = []
        for item in query.results {
            if let metadataItem = item as? NSMetadataItem,
                let path = metadataItem.value(forAttribute: NSMetadataItemPathKey) as? String,
                let name = metadataItem.value(forAttribute: NSMetadataItemDisplayNameKey) as? String
            {
                found.append(
                    SearchResult(
                        name: name, path: path, icon: NSWorkspace.shared.icon(forFile: path),
                        type: .file, stableId: "file_" + path))
            }
        }
        DispatchQueue.main.async { self.results = Array(found.prefix(20)) }
    }
}

// MARK: - Ranking Engine

struct CommandUsage: Codable {
    let id: String
    var count: Int
    var lastUsed: Date
}

public class RankingEngine {
    public static let shared = RankingEngine()
    private var usageStats: [String: CommandUsage] = [:]
    private var statsURL: URL?

    private init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent(
                "Pulse")
        self.statsURL = appSupport.appendingPathComponent("ranking_data.json")
        load()
    }

    private func load() {
        if let url = statsURL, let data = try? Data(contentsOf: url) {
            usageStats = (try? JSONDecoder().decode([String: CommandUsage].self, from: data)) ?? [:]
        }
    }

    public func recordExecution(stableId: String) {
        var usage = usageStats[stableId] ?? CommandUsage(id: stableId, count: 0, lastUsed: Date())
        usage.count += 1
        usage.lastUsed = Date()
        usageStats[stableId] = usage
        if let url = statsURL, let data = try? JSONEncoder().encode(usageStats) {
            try? data.write(to: url)
        }
    }

    func score(candidate: SearchResult, query: String) -> Double {
        let nameLower = candidate.name.lowercased()
        let queryLower = query.lowercased()
        var s = 0.0
        if nameLower == queryLower {
            s += 100
        } else if nameLower.hasPrefix(queryLower) {
            s += 50
        } else if nameLower.contains(queryLower) {
            s += 10
        }
        if let usage = usageStats[candidate.stableId] { s += Double(usage.count) * 2.0 }
        return s
    }

    public func getRecents(limit: Int = 5) -> [String] {
        return usageStats.values
            .sorted { $0.lastUsed > $1.lastUsed }
            .prefix(limit)
            .map { $0.id }
    }

    public func reset() {
        usageStats = [:]
        if let url = statsURL {
            try? FileManager.default.removeItem(at: url)
        }
    }
}

// MARK: - Search Orchestrator

public struct SearchResultSection: Identifiable {
    public let id = UUID()
    public let title: String
    public let results: [SearchResult]
}

class SearchOrchestrator: ObservableObject {
    static let shared = SearchOrchestrator()
    @Published var sections: [SearchResultSection] = []
    @Published var flattenedResults: [SearchResult] = []

    private var cancellables = Set<AnyCancellable>()
    private var searchWorkItem: DispatchWorkItem?
    private var lastQuery: String = ""

    init() {
        AppSearch.shared.$apps.sink { [weak self] _ in self?.search(query: self?.lastQuery ?? "") }
            .store(in: &cancellables)
        ClipboardManager.shared.$history.sink { [weak self] _ in
            self?.search(query: self?.lastQuery ?? "")
        }
        .store(in: &cancellables)
        QuicklinkManager.shared.$quicklinks.sink { [weak self] _ in
            self?.search(query: self?.lastQuery ?? "")
        }
        .store(in: &cancellables)
    }

    func search(query: String) {
        lastQuery = query
        searchWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            var categorized: [String: [SearchResult]] = [
                "Recents": [],
                "Suggestions": [],
                "Applications": [],
                "System": [],
                "Emojis": [],
                "Clipboard": [],
            ]

            // 1. Calculator
            if let res = Calculator.evaluate(query) {
                categorized["Suggestions"]?.append(
                    SearchResult(
                        name: "= \(res)", path: res,
                        icon: NSImage(systemSymbolName: "function", accessibilityDescription: nil)
                            ?? NSImage(),
                        symbolName: "function", type: .calculator, subtitle: "Calculator"))
            }

            // 2. System Commands
            let sys = SystemCommand.all
            var systemMatches = query.isEmpty ? sys : sys.filter { $0.name.fuzzyMatch(query) }

            // Check for emoji matches to conditionally show "Search Emoji & Symbols"
            if !query.isEmpty {
                let emojiMatches = EmojiData.shared.search(query: query)
                if !emojiMatches.isEmpty {
                    // Find the command if not already in results
                    if !systemMatches.contains(where: { $0.name == "Search Emoji & Symbols" }) {
                        if let cmd = sys.first(where: { $0.name == "Search Emoji & Symbols" }) {
                            systemMatches.insert(cmd, at: 0)
                        }
                    } else {
                        // Ensure it's at the top if it was already matched
                        if let idx = systemMatches.firstIndex(where: {
                            $0.name == "Search Emoji & Symbols"
                        }) {
                            let cmd = systemMatches.remove(at: idx)
                            systemMatches.insert(cmd, at: 0)
                        }
                    }
                }
            }

            categorized["System"] = systemMatches.map { cmd in
                var result = cmd.asSearchResult
                // Enhance subtitle if emoji matches found
                if cmd.name == "Search Emoji & Symbols" && !query.isEmpty {
                    let count = EmojiData.shared.search(query: query).count
                    if count > 0 {
                        result.subtitle = "Found \(count) matching emojis"
                        // Boost score implicitly by order, or we could trick the ranker
                    }
                }
                return result
            }

            // 3. Emojis - REMOVED (Handled by dedicated picker command)
            // let emojiSource = EmojiSearchSource()
            // let emojiResults = emojiSource.search(query: query)
            // categorized["Emojis"] = emojiResults

            // 4. Apps
            let apps = AppSearch.shared.apps
            if !query.isEmpty {
                categorized["Applications"] = apps.filter { $0.name.fuzzyMatch(query) }
            }

            // 5. Quicklinks
            let quicklinks = QuicklinkManager.shared.quicklinks
            if !query.isEmpty {
                categorized["Quicklinks"] = quicklinks.filter { $0.name.fuzzyMatch(query) }.map {
                    ql in
                    SearchResult(
                        name: ql.name,
                        path: QuicklinkManager.shared.resolve(link: ql.link, query: query),
                        icon: NSImage(systemSymbolName: ql.icon, accessibilityDescription: nil)
                            ?? NSImage(),
                        symbolName: ql.icon,
                        type: .quicklink,
                        subtitle: ql.link,
                        stableId: "ql_\(ql.id)"
                    )
                }
            }

            // 6. Clipboard
            let history = ClipboardManager.shared.history
            if query.isEmpty {
                categorized["Clipboard"] = history.prefix(5).map {
                    SearchResult(
                        name: String(
                            $0.content.prefix(50).replacingOccurrences(of: "\n", with: " ")),
                        path: $0.content,
                        icon: NSImage(
                            systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil)
                            ?? NSImage(),
                        symbolName: "doc.on.clipboard",
                        type: .clipboard,
                        subtitle: "Recent Selection",
                        detailContent: $0.content
                    )
                }
            }

            // 6. Recents & Scoring
            let recentIds = RankingEngine.shared.getRecents(limit: 5)
            var allCandidates = Array(categorized.values.joined())

            // Re-score
            let scored = allCandidates.map {
                (r: $0, s: RankingEngine.shared.score(candidate: $0, query: query))
            }
            .sorted { $0.s > $1.s }

            allCandidates = scored.map { $0.r }

            let recentItems = allCandidates.filter { recentIds.contains($0.stableId) }.prefix(3)
            categorized["Recents"] = Array(recentItems)

            for (key, _) in categorized where key != "Recents" {
                categorized[key]?.removeAll { item in
                    recentItems.contains { $0.stableId == item.stableId }
                }
            }

            // 7. Final Sections
            let sectionOrder = [
                "Recents", "Suggestions", "Emojis", "Applications", "Quicklinks", "System",
                "Clipboard",
            ]
            var finalSections: [SearchResultSection] = []
            var finalFlattened: [SearchResult] = []

            for title in sectionOrder {
                if let items = categorized[title], !items.isEmpty {
                    let sortedItems = items.map {
                        (r: $0, s: RankingEngine.shared.score(candidate: $0, query: query))
                    }
                    .sorted { $0.s > $1.s }.map { $0.r }

                    finalSections.append(SearchResultSection(title: title, results: sortedItems))
                    finalFlattened.append(contentsOf: sortedItems)
                }
            }

            // 8. Fallback Commands
            if finalFlattened.isEmpty && !query.isEmpty {
                var fallbackResults: [SearchResult] = []

                // Google Search
                fallbackResults.append(
                    SearchResult(
                        name: "Search Google for '\(query)'",
                        path:
                            "https://www.google.com/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)",
                        icon: NSImage(systemSymbolName: "globe", accessibilityDescription: nil)
                            ?? NSImage(),
                        symbolName: "globe",
                        type: .quicklink,
                        subtitle: "Fallback Command",
                        stableId: "fallback_google"
                    ))

                // Create Quicklink
                fallbackResults.append(
                    SearchResult(
                        name: "Create Quicklink for '\(query)'",
                        path: "create_quicklink",
                        icon: NSImage(
                            systemSymbolName: "link.badge.plus", accessibilityDescription: nil)
                            ?? NSImage(),
                        symbolName: "link.badge.plus",
                        type: .system,
                        subtitle: "Create a new shortcut",
                        stableId: "fallback_create_quicklink",
                        action: {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("triggerCreateQuicklink"), object: query)
                        }
                    ))

                finalSections.append(
                    SearchResultSection(title: "Fallback Commands", results: fallbackResults))
                finalFlattened.append(contentsOf: fallbackResults)
            }

            DispatchQueue.main.async {
                self.sections = finalSections
                self.flattenedResults = finalFlattened
            }
        }

        searchWorkItem = workItem
        if query.count < 3 {
            workItem.perform()
        } else {
            DispatchQueue.global(qos: .userInitiated).async(execute: workItem)
        }
    }
}

// MARK: - NSImage Extension for High Quality Resizing
extension NSImage {
    func resized(to newSize: NSSize) -> NSImage? {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) {
            bitmapRep.size = newSize
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            NSGraphicsContext.current?.imageInterpolation = .high  // Critical for smoothness
            draw(
                in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height),
                from: NSRect(x: 0, y: 0, width: size.width, height: size.height),
                operation: .copy,
                fraction: 1.0
            )
            NSGraphicsContext.restoreGraphicsState()

            let resizedImage = NSImage(size: newSize)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }
        return nil
    }
}
