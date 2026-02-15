//
//  EmojiActionsMenu.swift
//  Pulse
//
//  Created by Pulse on 2026-02-15.
//  Production-grade Actions Menu with Liquid Glass Design
//

import SwiftUI

// MARK: - Action Model

struct EmojiAction: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let shortcut: String?
    let modifiers: [String]
    let showAppIcon: Bool
    let action: () -> Void
    let isDestructive: Bool

    init(
        icon: String,
        title: String,
        shortcut: String? = nil,
        modifiers: [String] = [],
        showAppIcon: Bool = false,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.shortcut = shortcut
        self.modifiers = modifiers
        self.showAppIcon = showAppIcon
        self.action = action
        self.isDestructive = isDestructive
    }
}

// MARK: - Actions Menu View

struct EmojiActionsMenu: View {
    let emoji: Emoji
    let targetAppName: String
    let onCopyOnly: () -> Void
    let onPasteToApp: () -> Void
    let onDismiss: () -> Void

    @ObservedObject private var pinnedManager = PinnedEmojiManager.shared
    @State private var appIcon: NSImage?

    @State private var hoverIndex: Int?
    @State private var selectedIndex = -1  // No default selection as requested
    @State private var searchQuery = ""
    @FocusState private var isSearchFocused: Bool

    private var actions: [EmojiAction] {
        [
            // Primary action with app icon
            EmojiAction(
                icon: "arrow.up.forward.app",
                title: "Paste to \(targetAppName)",
                shortcut: "↵",
                modifiers: [],
                showAppIcon: true,
                action: {
                    onPasteToApp()
                }
            ),

            // Copy to Clipboard
            EmojiAction(
                icon: "doc.on.clipboard",
                title: "Copy to Clipboard",
                shortcut: "C",
                modifiers: ["⌘"],
                action: {
                    onCopyOnly()
                    onDismiss()
                }
            ),

            // Paste and Keep Window Open
            EmojiAction(
                icon: "arrow.up.forward.app",
                title: "Paste and Keep Window Open",
                shortcut: "↵",
                modifiers: ["⌥"],
                showAppIcon: true,
                action: {
                    pasteAndKeepOpen()
                }
            ),

            // Copy Unicode
            EmojiAction(
                icon: "textformat.abc",
                title: "Copy Unicode",
                shortcut: "U",
                modifiers: ["⇧", "⌘"],
                action: {
                    copyUnicode()
                    onDismiss()
                }
            ),

            // Copy Name removed

            // Copy All Emojis
            EmojiAction(
                icon: "doc.on.clipboard",
                title: "Copy All Emojis from Section",
                shortcut: "C",
                modifiers: ["⇧", "⌘"],
                action: {
                    // Logic to copy all emojis from the section
                    // For now, placeholder or partial implementation
                    // We need access to the section emojis, but we only have `emoji`.
                    // Just a toast or print for now.
                    print("Copy All Emojis from Section")
                    onDismiss()
                }
            ),

            // Save as Snippet
            EmojiAction(
                icon: "doc.text",
                title: "Save as Snippet",
                shortcut: "S",
                modifiers: ["⌘"],
                action: {
                    print("Save as Snippet: \(emoji.symbol)")
                    onDismiss()
                }
            ),

            // Pin Emoji
            EmojiAction(
                icon: PinnedEmojiManager.shared.isPinned(emoji) ? "pin.slash" : "pin",
                title: PinnedEmojiManager.shared.isPinned(emoji) ? "Unpin Emoji" : "Pin Emoji",
                shortcut: "P",
                modifiers: ["⇧", "⌘"],
                action: {
                    PinnedEmojiManager.shared.togglePin(emoji)
                    // Don't dismiss, just toggle
                }
            ),

            // Reset Ranking
            EmojiAction(
                icon: "arrow.counterclockwise",
                title: "Reset Ranking",
                action: {
                    RankingEngine.shared.reset()
                    onDismiss()
                }
            ),

            // Edit Custom Keywords
            EmojiAction(
                icon: "pencil",
                title: "Edit Custom Keywords",
                shortcut: "E",
                modifiers: ["⌘"],
                action: {
                    print("Edit Custom Keywords for \(emoji.name)")
                    onDismiss()
                }
            ),
        ]
    }

    private var filteredActions: [EmojiAction] {
        if searchQuery.isEmpty {
            return actions
        }
        return actions.filter { action in
            action.title.lowercased().contains(searchQuery.lowercased())
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Actions List
            // Actions List - Scrollable
            ScrollView {
                VStack(spacing: 0) {  // Zero spacing to control row height
                    ForEach(Array(filteredActions.enumerated()), id: \.element.id) {
                        index, action in
                        VStack(spacing: 0) {
                            ActionRow(
                                action: action,
                                targetAppName: targetAppName,
                                appIcon: appIcon,
                                isSelected: index == selectedIndex,
                                onTap: {
                                    action.action()
                                }
                            )

                            // Separator after "Paste and Keep Window Open" (index 2)
                            // Only if we are not filtering (showing all actions)
                            if searchQuery.isEmpty && index == 2 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 1)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 10)
                            }

                            // Separator after "Copy All Emojis" (index 4) - Save as Snippet follows
                            if searchQuery.isEmpty && index == 4 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 1)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 10)
                            }

                            // Separator after "Save as Snippet" (index 5) - Pin/Reset Ranking follow
                            if searchQuery.isEmpty && index == 5 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 1)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 10)
                            }

                            // Separator after "Reset Ranking" (index 7) - Edit Keywords follows
                            if searchQuery.isEmpty && index == 7 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 1)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 10)
                            }
                        }
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 6)
            }
            .frame(maxHeight: 230)  // Reduced height to show ~4-5 items

            // Separator
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)

            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary.opacity(0.7))

                TextField("Search for actions...", text: $searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .focused($isSearchFocused)
            }
            .padding(.horizontal, 10)  // Compact padding
            .padding(.vertical, 10)
        }
        .frame(width: 360)  // Increased width to fit text on one line
        .background(
            // Liquid Glass Background
            ZStack {
                // Base dark layer - reduced opacity for more glass effect
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.black.opacity(0.45))  // Reduced from 0.65 for more vibrancy

                // Native Material background
                Rectangle()
                    .fill(.regularMaterial)
                    .cornerRadius(12)

                // Subtle gradient overlay for depth
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),  // Slightly increased
                                Color.white.opacity(0.02),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .shadow(color: Color.black.opacity(0.5), radius: 40, x: 0, y: 16)  // Deeper shadow
            .overlay(
                // Border with subtle gradient
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.1),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1  // Increased border visibility slightly
                    )
            )
        )
        .onAppear {
            isSearchFocused = true
            fetchAppIcon()
        }
    }

    // MARK: - App Icon Fetching

    private func fetchAppIcon() {
        // Use ActiveAppDetector's bundle ID if available
        if let bundleID = ActiveAppDetector.shared.previousAppBundleID,
            let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
        {
            appIcon = NSWorkspace.shared.icon(forFile: url.path)
            return
        }

        // Fallback: Get the frontmost app from workspace
        let workspace = NSWorkspace.shared

        // Method 1: Try to find running app with matching name
        if let runningApp = workspace.runningApplications.first(where: {
            // Match name loosely to handle cases like "Xcode" vs "Xcode.app"
            $0.localizedName?.localizedCaseInsensitiveContains(targetAppName) == true
                || $0.bundleURL?.lastPathComponent.localizedCaseInsensitiveContains(targetAppName)
                    == true
        }) {
            if let bundleURL = runningApp.bundleURL {
                appIcon = workspace.icon(forFile: bundleURL.path)
                return
            }
        }

        // Method 2: Fallback to common paths
        let appPaths = [
            "/Applications/\(targetAppName).app",
            "/System/Applications/\(targetAppName).app",
            "/Applications/Utilities/\(targetAppName).app",
            "/System/Applications/Utilities/\(targetAppName).app",
        ]

        for path in appPaths {
            if FileManager.default.fileExists(atPath: path) {
                appIcon = workspace.icon(forFile: path)
                return
            }
        }
    }

    // MARK: - Action Handlers

    private func copyEmojiName() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(emoji.name, forType: .string)
    }

    private func copyUnicode() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        let unicode = emoji.symbol.unicodeScalars.map { String(format: "U+%04X", $0.value) }.joined(
            separator: " ")
        pasteboard.setString(unicode, forType: .string)
    }

    private func pasteAndKeepOpen() {
        // Copy to clipboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(emoji.symbol, forType: .string)

        // Paste but don't dismiss
        ActiveAppDetector.shared.pasteToPreviousApp()

        // Close menu but keep window open
        onDismiss()
    }
}

// MARK: - Action Row

struct ActionRow: View {
    let action: EmojiAction
    let targetAppName: String
    let appIcon: NSImage?
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isHovering: Bool = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // App Icon or System Icon
                if action.showAppIcon {
                    Group {
                        if let icon = appIcon {
                            Image(nsImage: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)  // Slightly larger
                        } else {
                            // High-quality fallback
                            Image(systemName: "app.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(width: 24, height: 24)
                } else {
                    Image(systemName: action.icon)
                        .font(.system(size: 16, weight: .regular))  // Adjusted weight
                        .foregroundColor(action.isDestructive ? .red : .primary)
                        .frame(width: 24, height: 24)
                }

                // Title
                Text(action.title)
                    .font(.system(size: 13, weight: .regular))  // Reduced size and weight
                    .foregroundColor(action.isDestructive ? .red : .primary)

                Spacer()

                // Keyboard Shortcut
                HStack(spacing: 4) {
                    ForEach(action.modifiers, id: \.self) { modifier in
                        KeyboardShortcutBadge(text: modifier, isSelected: isSelected)
                    }

                    if let shortcut = action.shortcut {
                        KeyboardShortcutBadge(text: shortcut, isSelected: isSelected)
                    }
                }
            }
            .padding(.horizontal, 14)  // Increased padding
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected || isHovering {
                        // Raycast-style selection: Brighter, slightly bluish/gray
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.white.opacity(0.12))  // More visible selection
                    }
                }
            )
            .contentShape(Rectangle())  // Ensure entire area is clickable
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// MARK: - Keyboard Shortcut Badge

struct KeyboardShortcutBadge: View {
    let text: String
    let isSelected: Bool

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .regular))
            .foregroundColor(.secondary)  // Always secondary for cleaner look
            .frame(minWidth: 20)
            .frame(height: 22)  // Fixed height
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
            )
    }
}
