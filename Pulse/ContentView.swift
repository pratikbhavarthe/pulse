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
    @ObservedObject var orchestrator = SearchOrchestrator.shared
    @State private var query: String = ""
    @State private var selectedIndex: Int = 0

    // We listen to changes but orchestrator manages results

    var body: some View {
        ZStack {
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
                        selectedIndex = min(selectedIndex + 1, orchestrator.results.count - 1)
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

                if !orchestrator.results.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(0..<min(orchestrator.results.count, 6), id: \.self) { index in
                            let result = orchestrator.results[index]
                            HStack(spacing: 12) {
                                Image(nsImage: result.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 26, height: 26)  // Slightly larger icon

                                HighlightText(text: result.name, query: query)
                                    .font(.system(size: 18, weight: .regular))  // Larger, cleaner font
                                    .foregroundColor(selectedIndex == index ? .white : .primary)

                                Spacer()
                            }
                            .padding(.vertical, 10)  // More breathing room
                            .padding(.horizontal, 12)
                            .contentShape(Rectangle())  // Make entire row clickable
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(selectedIndex == index ? Color.accentColor : Color.clear)
                            )
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
            orchestrator.search(query: query)
            selectedIndex = 0
        }
    }

    func runSelectedCommand() {
        guard selectedIndex < orchestrator.results.count else { return }
        let result = orchestrator.results[selectedIndex]

        // Execute via Protocol extension (which handles Logging)
        result.run()

        NSApp.keyWindow?.orderOut(nil)
    }
}
