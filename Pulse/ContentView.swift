//
//  ContentView.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 08/02/26.
//

import AppKit
import SwiftUI

struct ContentView: View {

    @State private var query: String = ""
    @State private var selectedIndex: Int = 0
    let commands = [
        "Open Safari",
        "Open Finder",
        "Open Notes",
        "Quit Pulse",
    ]

    var filteredCommands: [String] {
        if query.isEmpty { return commands }
        return commands.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(spacing: 12) {

            PulseTextField(
                text: $query,
                placeholder: "Type a command…",
                onUpArrow: {
                    selectedIndex = max(selectedIndex - 1, 0)
                },
                onDownArrow: {
                    selectedIndex = min(selectedIndex + 1, filteredCommands.count - 1)
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

            VStack(alignment: .leading, spacing: 6) {
                ForEach(filteredCommands.indices, id: \.self) { index in
                    Text(filteredCommands[index])
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            selectedIndex == index ? Color.white.opacity(0.15) : Color.clear
                        )
                        .cornerRadius(6)
                }
            }
        }
        .padding(16)
        .frame(width: 700)
        .onAppear {
            // Ensure window takes focus
            NSApp.activate(ignoringOtherApps: true)
        }
        .onChange(of: query) { _ in
            selectedIndex = 0
        }
    }

    func runSelectedCommand() {
        let command = filteredCommands[selectedIndex]

        switch command {
        case "Open Safari":
            NSWorkspace.shared.launchApplication("Safari")
        case "Open Finder":
            NSWorkspace.shared.launchApplication("Finder")
        case "Open Notes":
            NSWorkspace.shared.launchApplication("Notes")
        case "Quit Pulse":
            NSApp.terminate(nil)
        default:
            break
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
