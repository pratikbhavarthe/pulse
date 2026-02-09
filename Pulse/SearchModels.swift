//
//  SearchModels.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import AppKit
import Combine

public enum ResultType {
    case app
    case system
    case calculator
    case plugin
    case file
}

// Conforming to Command protocol
public struct SearchResult: Command, Hashable {
    public let id = UUID()
    public let stableId: String  // For persistence (Bundle ID or unique name)
    public let name: String
    public let path: String
    public let icon: NSImage
    public let type: ResultType
    public let isFolder: Bool
    public let action: (() -> Void)?

    // Command Protocol Compliance
    public var score: Double {
        // We could fetch dynamic score here if needed,
        // or let the Orchestrator/Sorter handle it externally.
        // For protocol compliance, return 0.0 or cached value.
        // Ideally, we'd store the score if calculated.
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
        }
    }

    public init(
        name: String, path: String, icon: NSImage, type: ResultType = .app,
        isFolder: Bool = false, stableId: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.name = name
        self.path = path
        self.icon = icon
        self.type = type
        self.isFolder = isFolder
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
