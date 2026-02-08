//
//  ContentView.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 08/02/26.
//

import AppKit
import Combine
import SwiftUI

struct ContentView: View {

    @ObservedObject var appSearch = AppSearch.shared
    @State private var query: String = ""
    @State private var selectedIndex: Int = 0

    var filteredResults: [SearchResult] {
        if query.isEmpty { return appSearch.apps }
        return appSearch.apps.filter { $0.name.fuzzyMatch(query) }
    }

    var body: some View {
        VStack(spacing: 12) {

            PulseTextField(
                text: $query,
                placeholder: "Search applications…",
                onUpArrow: {
                    selectedIndex = max(selectedIndex - 1, 0)
                },
                onDownArrow: {
                    selectedIndex = min(selectedIndex + 1, filteredResults.count - 1)
                },
                onEnter: {
                    runSelectedCommand()
                },
                onEscape: {
                    NSApp.keyWindow?.orderOut(nil)
                }
            )
            .frame(height: 40)
            .background(.ultraThinMaterial)
            .cornerRadius(10)

            if !filteredResults.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    // Limit to 6 results for now to fit in the window
                    ForEach(0..<min(filteredResults.count, 6), id: \.self) { index in
                        let result = filteredResults[index]
                        HStack(spacing: 12) {
                            Image(nsImage: result.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)

                            Text(result.name)
                                .font(.system(size: 16))
                                .foregroundColor(selectedIndex == index ? .white : .primary)

                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(
                            selectedIndex == index ? Color.accentColor : Color.clear
                        )
                        .cornerRadius(6)
                    }
                }
            } else if !query.isEmpty {
                Text("No results found")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(16)
        .frame(width: 700)
        .onAppear {
            // Ensure window takes focus
            NSApp.activate(ignoringOtherApps: true)
        }
        .onChange(of: query) {
            selectedIndex = 0
        }
    }

    func runSelectedCommand() {
        guard selectedIndex < filteredResults.count else { return }
        let result = filteredResults[selectedIndex]

        let url = URL(fileURLWithPath: result.path)
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
        { _, _ in
            DispatchQueue.main.async {
                NSApp.keyWindow?.orderOut(nil)
            }
        }
    }
}

struct PulseTextField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String

    var onUpArrow: () -> Void
    var onDownArrow: () -> Void
    var onEnter: () -> Void
    var onEscape: () -> Void

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.delegate = context.coordinator
        textField.focusRingType = .none
        textField.isBordered = false
        textField.drawsBackground = false
        textField.font = .systemFont(ofSize: 22)
        textField.placeholderString = placeholder
        textField.textColor = .labelColor
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: PulseTextField

        init(_ parent: PulseTextField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            parent.text = textField.stringValue
        }

        func control(
            _ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector
        ) -> Bool {
            if commandSelector == #selector(NSResponder.moveUp(_:)) {
                parent.onUpArrow()
                return true
            } else if commandSelector == #selector(NSResponder.moveDown(_:)) {
                parent.onDownArrow()
                return true
            } else if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                parent.onEnter()
                return true
            } else if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                parent.onEscape()
                return true
            }
            return false
        }
    }
}

struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let path: String
    let icon: NSImage

    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }

    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.path == rhs.path
    }
}

class AppSearch: ObservableObject {
    static let shared = AppSearch()

    @Published var apps: [SearchResult] = []
    private var isScanning = false

    private init() {
        scanApps()
    }

    func scanApps() {
        guard !isScanning else { return }
        isScanning = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var foundApps: [SearchResult] = []

            let directories = [
                "/Applications",
                "/System/Applications",
                "/System/Library/CoreServices/Applications",
                ("~" as NSString).expandingTildeInPath + "/Applications",
            ]

            let fileManager = FileManager.default
            let workspace = NSWorkspace.shared

            for dir in directories {
                guard let contents = try? fileManager.contentsOfDirectory(atPath: dir) else {
                    continue
                }

                for item in contents {
                    if item.hasSuffix(".app") {
                        let path = (dir as NSString).appendingPathComponent(item)
                        let name = (item as NSString).deletingPathExtension
                        let icon = workspace.icon(forFile: path)

                        let result = SearchResult(name: name, path: path, icon: icon)
                        foundApps.append(result)
                    }
                }
            }

            DispatchQueue.main.async {
                self?.apps = foundApps
                self?.isScanning = false
            }
        }
    }
}

extension String {
    func fuzzyMatch(_ query: String) -> Bool {
        if query.isEmpty { return true }
        var remainder = query[...]
        for char in self {
            if let first = remainder.first, char.lowercased() == String(first).lowercased() {
                remainder.removeFirst()
                if remainder.isEmpty { return true }
            }
        }
        return false
    }
}
