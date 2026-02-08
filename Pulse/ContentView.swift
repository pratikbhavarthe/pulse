//
//  ContentView.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import AppKit
import SwiftUI

// MARK: - Visual Components

struct VisualEffectBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        // 'hudWindow' gives a dark, high-contrast, translucent "liquid glass" look
        // 'popover' or 'sidebar' can change the tint.
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
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

struct ContentView: View {
    @ObservedObject var appSearch = AppSearch.shared
    @State private var query: String = ""
    @State private var selectedIndex: Int = 0

    var filteredResults: [SearchResult] {
        var results: [SearchResult] = []

        // 1. Calculator 
        if let calcResult = Calculator.evaluate(query) {
            results.append(
                SearchResult(
                    name: "= \(calcResult)",
                    path: calcResult,
                    icon: NSImage(systemSymbolName: "function", accessibilityDescription: nil)
                        ?? NSImage(),
                    type: .calculator,
                    action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(calcResult, forType: .string)
                    }
                ))
        }

        // 2. System Commands
        if !query.isEmpty {
            let sys = SystemCommand.all.filter { $0.name.fuzzyMatch(query) }
            let sysResults = sys.map { cmd in
                SearchResult(
                    name: cmd.name,
                    path: "system",
                    icon: NSImage(systemSymbolName: cmd.iconName, accessibilityDescription: nil)
                        ?? NSImage(),
                    type: .system,
                    action: cmd.action
                )
            }
            results.append(contentsOf: sysResults)
        }

        // 3. Apps
        if query.isEmpty {
            results.append(contentsOf: appSearch.apps)
        } else {
            results.append(contentsOf: appSearch.apps.filter { $0.name.fuzzyMatch(query) })
        }

        return results
    }

    var body: some View {
        ZStack {
            // Liquid Glass Background
            VisualEffectBlur()
                .edgesIgnoringSafeArea(.all)

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
                .padding(.horizontal, 10)
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)

                if !filteredResults.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
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
                            .onTapGesture {
                                selectedIndex = index
                                runSelectedCommand()
                            }
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
        }
        .frame(width: 700)
        .cornerRadius(16)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
        }
        .onChange(of: query) {
            selectedIndex = 0
        }
    }

    func runSelectedCommand() {
        guard selectedIndex < filteredResults.count else { return }
        let result = filteredResults[selectedIndex]

        if let action = result.action {
            action()
            // Optional: Keep open or close. Standard launcher behavior is close.
            NSApp.keyWindow?.orderOut(nil)
        } else if result.type == .app {
            let url = URL(fileURLWithPath: result.path)
            NSWorkspace.shared.openApplication(
                at: url, configuration: NSWorkspace.OpenConfiguration()
            ) { _, _ in
                DispatchQueue.main.async {
                    NSApp.keyWindow?.orderOut(nil)
                }
            }
        }
    }
}
