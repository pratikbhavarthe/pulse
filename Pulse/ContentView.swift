//
//  ContentView.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import AppKit
import Combine
import SwiftUI

// MARK: - UI Components

struct HighlightText: View {
    let text: String
    let query: String

    var body: some View {
        Group {
            if query.isEmpty {
                Text(text)
            } else if let range = text.range(of: query, options: .caseInsensitive) {
                let prefix = String(text[..<range.lowerBound])
                let match = String(text[range])
                let suffix = String(text[range.upperBound...])

                HStack(spacing: 0) {
                    Text(prefix)
                    Text(match).bold()
                    Text(suffix)
                }
            } else {
                Text(text)
            }
        }
    }
}

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var state: NSVisualEffectView.State = .active
    var cornerRadius: CGFloat = 0  // New parameter

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state

        // Critical for rounded corners on macOS
        view.wantsLayer = true
        view.layer?.cornerRadius = cornerRadius
        view.layer?.masksToBounds = cornerRadius > 0

        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state

        if nsView.layer?.cornerRadius != cornerRadius {
            nsView.layer?.cornerRadius = cornerRadius
            nsView.layer?.masksToBounds = cornerRadius > 0
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

    func makeNSView(context: Context) -> PulseNativeTextField {
        let textField = PulseNativeTextField()
        textField.delegate = context.coordinator
        textField.focusRingType = .none
        textField.isBordered = false
        textField.drawsBackground = false
        textField.font = .systemFont(ofSize: 24, weight: .light)  // Larger, thinner font
        textField.placeholderString = placeholder
        textField.textColor = .white.withAlphaComponent(0.95)  // Pure white
        // Note: Placeholder color requires attributed string if we want to change it,
        // but default gray on dark background is usually fine.
        // Let's stick to standard behavior for now to avoid complexity.
        return textField
    }

    func updateNSView(_ nsView: PulseNativeTextField, context: Context) {
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

class PulseNativeTextField: NSTextField {
    private var observer: NSObjectProtocol?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        if let existing = observer {
            NotificationCenter.default.removeObserver(existing)
        }

        if let window = window {
            observer = NotificationCenter.default.addObserver(
                forName: NSWindow.didBecomeKeyNotification, object: window, queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                if self.window?.firstResponder != self.currentEditor() {
                    self.window?.makeFirstResponder(self)
                }
            }

            // Also grab focus immediately if window is already key
            if window.isKeyWindow && window.firstResponder != self.currentEditor() {
                window.makeFirstResponder(self)
            }
        }
    }

    deinit {
        if let existing = observer {
            NotificationCenter.default.removeObserver(existing)
        }
    }
}

struct ResultRow: View {
    let result: SearchResult
    let query: String
    let isSelected: Bool
    let isHovering: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if let symbolName = result.symbolName {
                    Image(systemName: symbolName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(isSelected ? .primary : .primary.opacity(0.9))
                } else {
                    Image(nsImage: result.icon)
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
            }
            .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 1) {
                HighlightText(text: result.name, query: query)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)

                if let subtitle = result.subtitle {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(result.categoryLabel)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.secondary.opacity(0.8))  // Just text, subtle
                .padding(.horizontal, 4)  // Minimal spacing from edge
        }
        .padding(.vertical, 4)  // More breathing room
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)  // Rounder corners
                .fill(
                    isSelected
                        ? Color.white.opacity(0.15)
                        : isHovering ? Color.white.opacity(0.05) : Color.clear
                )
        )
    }
}

struct DetailPane: View {
    let result: SearchResult?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let result = result {
                if let detail = result.detailContent {
                    ScrollView {
                        Text(detail)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.primary.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 10) {
                            ZStack {
                                if let symbol = result.symbolName {
                                    Image(systemName: symbol)
                                        .font(.system(size: 26))
                                } else {
                                    Image(nsImage: result.icon)
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .frame(width: 52, height: 52)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(result.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .lineLimit(2)
                                Text(result.categoryLabel)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Divider().background(Color.white.opacity(0.08))

                        VStack(alignment: .leading, spacing: 10) {
                            DetailItem(label: "Path", value: result.path)
                            if let subtitle = result.subtitle {
                                DetailItem(label: "Type", value: subtitle)
                            }
                        }
                    }
                    .padding(20)
                }
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.2))  // Slightly darker detail pane
    }
}

struct DetailItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 12))
                .foregroundColor(.primary.opacity(0.8))
                .lineLimit(2)
        }
    }
}

struct FooterBar: View {
    var body: some View {
        HStack {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.3))  // Translucent icon

            Spacer()

            HStack(spacing: 14) {
                // Keep existing hints
                ShortcutHint(key: "↵", label: "Open")
                ShortcutHint(key: "⌘K", label: "Actions")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.15))  // Subtle translucent background
    }
}

struct ShortcutHint: View {
    let key: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Text(key)
                .font(.system(size: 10, weight: .medium))
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(Color.white.opacity(0.1))
                .cornerRadius(3)
                .foregroundColor(.secondary)
        }
    }
}

struct ContentView: View {
    @ObservedObject var orchestrator = SearchOrchestrator.shared
    @State private var query: String = ""
    @State private var selectedIndex: Int = 0
    @State private var hoveredIndex: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Search Input Area
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.8))

                PulseTextField(
                    text: $query,
                    placeholder: "Search for apps and commands...",
                    onUpArrow: {
                        if selectedIndex > 0 {
                            withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.82))
                            {
                                selectedIndex -= 1
                            }
                        }
                    },
                    onDownArrow: {
                        if selectedIndex < orchestrator.flattenedResults.count - 1 {
                            withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.82))
                            {
                                selectedIndex += 1
                            }
                        }
                    },
                    onEnter: {
                        runSelectedCommand()
                    },
                    onEscape: {
                        NSApp.keyWindow?.orderOut(nil)
                    }
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)  // Tighter vertical padding (from 14)

            Divider().background(Color.white.opacity(0.1))

            // Results List
            ScrollViewReader { proxy in
                CustomScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        if orchestrator.flattenedResults.isEmpty && !query.isEmpty {
                            Text("No results found")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 60)
                        } else {
                            ForEach(orchestrator.sections) { section in
                                Section(
                                    header:
                                        Text(section.title.uppercased())
                                        .font(.system(size: 11, weight: .medium))  // Softer header
                                        .foregroundColor(.secondary.opacity(0.7))
                                        .padding(.horizontal, 10)
                                        .padding(.top, 6)  // Reduced header top padding (from 12)
                                        .padding(.bottom, 4)
                                ) {
                                    ForEach(section.results) { result in
                                        let flatIndex =
                                            orchestrator.flattenedResults.firstIndex(where: {
                                                $0.id == result.id
                                            }) ?? 0
                                        ResultRow(
                                            result: result,
                                            query: query,
                                            isSelected: selectedIndex == flatIndex,
                                            isHovering: hoveredIndex == flatIndex
                                        )
                                        .id(flatIndex)
                                        .onTapGesture {
                                            selectedIndex = flatIndex
                                            runSelectedCommand()
                                        }
                                        .onHover { hovering in
                                            hoveredIndex = hovering ? flatIndex : nil
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.top, 2)  // Minimal top padding (originally 6)
                    .padding(.bottom, 6)
                    .onHover { _ in NSCursor.arrow.set() }
                }
                .onChange(of: selectedIndex) { newIndex in
                    withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.82)) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
            .frame(maxHeight: .infinity)  // Dynamic height list
            .padding(.bottom, 6)

            // Footer Bar
            FooterBar()
        }
        .padding(.top, 28)  // MORE padding to un-chop search
        .padding(.bottom, 0)  // No bottom gap for footer
        .padding(.horizontal, 0)
        .background(
            ZStack {
                VisualEffectBlur(
                    material: .hudWindow, blendingMode: .behindWindow, state: .active,
                    cornerRadius: 16)
                Color.black.opacity(0.45)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))  // Tighter corner
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .frame(width: 770, height: 450)
        .shadow(color: Color.black.opacity(0.4), radius: 30, x: 0, y: 15)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
            orchestrator.search(query: "")
        }
        .onChange(of: query) { newQuery in
            orchestrator.search(query: newQuery)
            selectedIndex = 0
        }
    }

    private func runSelectedCommand() {
        guard selectedIndex < orchestrator.flattenedResults.count else { return }
        let selected = orchestrator.flattenedResults[selectedIndex]

        // Record usage for Recents
        RankingEngine.shared.recordExecution(stableId: selected.stableId)

        selected.execute()

        // Hide on execution (except calculator)
        if selected.type != .calculator {
            NotificationCenter.default.post(name: NSNotification.Name("hidePulse"), object: nil)
        }
    }
}
