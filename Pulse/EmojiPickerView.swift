//
//  EmojiPickerView.swift
//  Pulse
//
//  Raycast-style emoji picker with grid layout, categories, and smooth animations
//

import SwiftUI

struct EmojiPickerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var activeAppDetector = ActiveAppDetector.shared

    @State private var searchQuery: String = ""
    @State private var selectedCategory: EmojiCategory? = nil
    @State private var isShowingCategoryPicker: Bool = false
    @State private var isShowingActionsMenu: Bool = false

    @State private var selectedEmoji: Emoji? = nil
    @State private var copiedEmoji: Emoji? = nil

    @State private var showCopiedToast: Bool = false
    @FocusState private var isSearchFocused: Bool

    let columns = [GridItem(.adaptive(minimum: 52, maximum: 60), spacing: 8)]

    var onDismiss: () -> Void

    // Auto-select first emoji
    private func selectFirstEmoji() {
        if searchQuery.isEmpty && selectedCategory == nil {
            if let firstFrequent = frequentlyUsed.first {
                selectedEmoji = firstFrequent
                return
            }
        }

        if let first = filteredEmojis.first {
            selectedEmoji = first
        }
    }

    var filteredEmojis: [Emoji] {
        // Handle Frequently Used specially
        if selectedCategory == .frequentlyUsed {
            let emojis = EmojiData.shared.getFrequentlyUsed()
            if !searchQuery.isEmpty {
                let query = searchQuery.lowercased()
                return emojis.filter { emoji in
                    emoji.name.lowercased().contains(query)
                        || emoji.keywords.contains { $0.lowercased().contains(query) }
                }
            }
            return emojis
        }

        var emojis = EmojiData.shared.allEmojis

        // Filter by category
        if let category = selectedCategory {
            emojis = emojis.filter { $0.category == category }
        }

        // Filter by search query
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            emojis = emojis.filter { emoji in
                emoji.name.lowercased().contains(query)
                    || emoji.keywords.contains { $0.lowercased().contains(query) }
            }
        }

        return emojis
    }

    var frequentlyUsed: [Emoji] {
        EmojiData.shared.getFrequentlyUsed()
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main Layer
            VStack(spacing: 0) {
                // Header with back button and search
                header

                Divider()
                    .background(Color.white.opacity(0.1))

                // Emoji grid or No Results
                if !searchQuery.isEmpty && filteredEmojis.isEmpty {
                    noResultsView
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Frequently Used section
                            if searchQuery.isEmpty && selectedCategory == nil
                                && !frequentlyUsed.isEmpty
                            {
                                frequentlyUsedSection
                            }

                            // All emojis or filtered results
                            if searchQuery.isEmpty && selectedCategory == nil {
                                allCategoriesGrid
                            } else {
                                filteredEmojiGrid
                            }
                        }
                        .padding(16)
                    }
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                // Footer with paste label or emoji name
                footer
            }
            .liquidGlass(material: .hudWindow, blendingMode: .behindWindow, cornerRadius: 16)

            // Overlay Layer (Dropdown)
            if isShowingCategoryPicker {
                // Transparent shim to detect clicks outside the dropdown
                Color.purple.opacity(0.001)  // Nearly transparent but interactive
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            isShowingCategoryPicker = false
                        }
                    }
                    .zIndex(99)

                CategoryDropdown(
                    selectedCategory: $selectedCategory,
                    isPresented: $isShowingCategoryPicker
                )
                .padding(.top, 74)  // Increased to clear separator
                .padding(.trailing, 14)  // Align with header padding
                .transition(
                    .asymmetric(
                        insertion: .opacity
                            .combined(with: .scale(scale: 0.95, anchor: .topTrailing))
                            .combined(with: .offset(y: -5)),
                        removal: .opacity
                            .combined(with: .scale(scale: 0.95, anchor: .topTrailing))
                    )
                )
                .zIndex(100)
            }

            // Copied toast
            if showCopiedToast {
                copiedToastView
                    .zIndex(200)
            }

            // Actions Menu
            if isShowingActionsMenu, let emoji = selectedEmoji {
                // Dimmed background
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) {
                            isShowingActionsMenu = false
                        }
                    }
                    .zIndex(300)

                // Menu positioned above Actions button
                VStack {
                    Spacer()

                    EmojiActionsMenu(
                        emoji: emoji,
                        targetAppName: activeAppDetector.previousAppName,
                        onCopyOnly: {
                            copyEmojiOnly(emoji)
                        },
                        onPasteToApp: {
                            copyEmoji(emoji)
                        },
                        onDismiss: {
                            withAnimation(.easeOut(duration: 0.15)) {
                                isShowingActionsMenu = false
                            }
                        }
                    )
                    .padding(.bottom, 55)  // Adjusted gap: not too close, not too far
                    .padding(.horizontal, 20)  // Ensure safety margin from edges
                }
                .transition(.scale(scale: 0.96, anchor: .bottom).combined(with: .opacity))
                .zIndex(400)
            }
        }
        .overlayPreferenceValue(TooltipPreferenceKey.self) { tooltipData in
            TooltipOverlay(tooltipData: tooltipData)
        }
        .onAppear {
            selectFirstEmoji()
            isSearchFocused = true
        }
        .onChange(of: searchQuery) { _, _ in
            selectFirstEmoji()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            // Back button

            Button(action: {
                onDismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))  // Slightly bolder, smaller for crispness

            }
            .buttonStyle(SmoothBackButtonStyle())

            // Search field with integrated filter
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                TextField("Search Emoji & Symbols...", text: $searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 14))
                    .focused($isSearchFocused)
                    .onSubmit {
                        if let emoji = selectedEmoji {
                            copyEmoji(emoji)
                        }
                    }

                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Divider before filter
                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 1, height: 16)
                    .padding(.horizontal, 4)

                // Integrated Category Filter
                // Integrated Category Filter Trigger
                Button(action: {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        isShowingCategoryPicker.toggle()
                    }
                }) {
                    FilterButtonLabel(
                        selectedCategory: selectedCategory, isPresented: isShowingCategoryPicker)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)  // Slightly more padding for pill shape
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())  // Pill shape requested by user
        }
        .padding(12)
    }

    // MARK: - Frequently Used Section

    private var frequentlyUsedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Frequently Used")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)

                Text("\(frequentlyUsed.count)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(frequentlyUsed) { emoji in
                    EmojiCell(
                        emoji: emoji,
                        isSelected: selectedEmoji?.id == emoji.id,
                        onSelect: {
                            selectedEmoji = emoji
                            isSearchFocused = true
                        }
                    )
                }
            }
        }
    }

    // MARK: - All Categories Grid

    private var allCategoriesGrid: some View {
        ForEach(EmojiCategory.allCases.filter { $0 != .frequentlyUsed }, id: \.self) { category in
            let categoryEmojis = EmojiData.shared.allEmojis.filter { $0.category == category }

            if !categoryEmojis.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(category.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)

                        Text("\(categoryEmojis.count)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }

                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(categoryEmojis) { emoji in
                            EmojiCell(
                                emoji: emoji,
                                isSelected: selectedEmoji?.id == emoji.id,
                                onSelect: {
                                    selectedEmoji = emoji
                                    isSearchFocused = true
                                }
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Filtered Grid

    private var filteredEmojiGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(filteredEmojis) { emoji in
                EmojiCell(
                    emoji: emoji,
                    isSelected: selectedEmoji?.id == emoji.id,
                    onSelect: {
                        selectedEmoji = emoji
                        isSearchFocused = true
                    }
                )
            }
        }
    }

    // MARK: - Emoji Grid Card

    // MARK: - Footer

    private var footer: some View {
        HStack {
            if let emoji = selectedEmoji {
                Text(emoji.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
            }

            Spacer()

            HStack(spacing: 16) {
                // Primary Action: Paste
                FooterButton(
                    action: {
                        if let emoji = selectedEmoji {
                            copyEmoji(emoji)
                        }
                    },
                    label: activeAppDetector.pasteLabel,
                    shortcutIcon: "return",
                    isPrimary: true
                )
                .keyboardShortcut(.return, modifiers: [])

                // Separator
                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 1, height: 14)

                // Secondary Action: Actions Menu
                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) {
                        isShowingActionsMenu.toggle()
                    }
                }) {
                    ActionsButtonContent(isActive: isShowingActionsMenu)
                }
                .buttonStyle(PlainButtonStyle())
                .keyboardShortcut("k", modifiers: .command)
            }
        }
        .frame(height: 38)  // Slightly taller to accommodate buttons
        .padding(.horizontal, 16)
        .padding(.top, 0)
        .padding(.bottom, 8)
    }

    // MARK: - Copied Toast

    private var copiedToastView: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.green)

                Text("Copied!")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
            )
        }
        .transition(.scale.combined(with: .opacity))
        .zIndex(100)
    }

    // MARK: - No Results View

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.2))

            Text("No emojis found")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary.opacity(0.8))

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    private func copyEmoji(_ emoji: Emoji) {
        // Copy to clipboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(emoji.symbol, forType: .string)

        // Record usage
        RankingEngine.shared.recordExecution(stableId: emoji.stableId)

        // Show copied animation (Disabled as per user request)
        // copiedEmoji = emoji
        // withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        //    showCopiedToast = true
        // }

        print("DEBUG: Copied emoji: \(emoji.symbol) - \(emoji.name)")

        // Auto-dismiss toast AND Paste to app
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Dismiss toast (Disabled)
            // withAnimation(.easeOut(duration: 0.2)) {
            //    showCopiedToast = false
            // }

            // Close Pulse and Paste
            NSApp.hide(nil)  // Hide Pulse window
            ActiveAppDetector.shared.pasteToPreviousApp()

            // Reset UI state for next time
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onDismiss()
            }
        }
    }

    // MARK: - Copy Only (No Dismiss)

    private func copyEmojiOnly(_ emoji: Emoji) {
        // Copy to clipboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(emoji.symbol, forType: .string)

        // Record usage
        RankingEngine.shared.recordExecution(stableId: emoji.stableId)

        print("DEBUG: Copied emoji (no dismiss): \(emoji.symbol) - \(emoji.name)")

        // Show copied toast
        copiedEmoji = emoji
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedToast = true
        }

        // Auto-dismiss toast after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.2)) {
                showCopiedToast = false
            }
        }

        // Keep window open - do NOT dismiss
    }
}

struct SmoothBackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        SmoothBackButton(configuration: configuration)
    }

    private struct SmoothBackButton: View {
        let configuration: Configuration
        @State private var isHovering = false

        var body: some View {
            configuration.label
                .foregroundColor(isHovering ? .primary : .secondary)
                .frame(width: 28, height: 28)  // Fixed square size for perfect circle
                .background(
                    Circle()
                        .fill(
                            Color.primary.opacity(
                                configuration.isPressed ? 0.1 : (isHovering ? 0.05 : 0.0)
                            )
                        )
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .contentShape(Circle())
                .onHover { hover in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        isHovering = hover
                    }
                }
        }
    }
}

private struct FilterButtonLabel: View {
    let selectedCategory: EmojiCategory?
    let isPresented: Bool
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 4) {
            Text(selectedCategory?.rawValue ?? "All")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)  // Raycast style: subtle text

            Image(systemName: "chevron.down")
                .font(.system(size: 9, weight: .bold))  // Smaller, bolder chevron
                .foregroundColor(.secondary.opacity(0.8))
                .rotationEffect(.degrees(isPresented ? 180 : 0))
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPresented)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.primary.opacity(isHovering ? 0.06 : 0.0))
        )
        .contentShape(Rectangle())
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hover
            }
        }
    }
}

private struct CategoryDropdown: View {
    @Binding var selectedCategory: EmojiCategory?
    @Binding var isPresented: Bool

    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    var filteredCategories: [EmojiCategory] {
        let all = EmojiCategory.allCases
        if searchText.isEmpty {
            return all
        }
        return all.filter { $0.rawValue.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Internal Search Bar
            HStack(alignment: .center, spacing: 0) {  // Removed spacing since icon is gone
                TextField("Search...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 14))
                    .focused($isSearchFocused)
                    .offset(y: 1.5)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)

            Divider().background(Color.white.opacity(0.1))

            ScrollView {
                VStack(spacing: 4) {
                    // "All" option
                    if searchText.isEmpty || "All".localizedCaseInsensitiveContains(searchText) {
                        CategoryRow(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            action: {
                                selectedCategory = nil
                                isPresented = false
                            },
                            isFirst: true
                        )
                    }

                    ForEach(filteredCategories, id: \.self) { category in
                        CategoryRow(
                            title: category.rawValue,
                            isSelected: selectedCategory == category,
                            action: {
                                selectedCategory = category
                                isPresented = false
                            },
                            isFirst: false
                        )
                    }
                }
                .padding(.top, 6)  // Fix: Prevent top item from being chopped off
                .padding(.bottom, 6)
                .padding(.horizontal, 4)
            }
            .padding(.vertical, 0)  // Remove outer vertical padding to let content scroll fully
            .scrollIndicators(.visible)
            .frame(height: 200)
        }
        .frame(width: 220)
        .liquidGlass(
            material: .popover,
            blendingMode: .withinWindow,
            cornerRadius: 12,
            hasBacking: true,
            backingOpacity: 0.40  // Slightly reduced for clearer glass feel
        )
        .onAppear {
            isSearchFocused = true
        }
    }
}

private struct CategoryRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var isFirst: Bool = false
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : .secondary)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .contentShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            ZStack {
                if isSelected {
                    // Cleaner Raycast-style Liquid Glass
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white.opacity(0.15))  // Crisp white tint
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.ultraThinMaterial)  // Frosted blur
                                .opacity(0.8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)  // Subtle edge
                        )
                } else if isHovering {
                    // Hover State
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white.opacity(0.08))  // Faint tint
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .opacity(0.4)  // Faint blur
                        )
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onHover { hover in
            isHovering = hover
        }
    }
}

private struct ActionsButtonContent: View {
    let isActive: Bool
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 6) {
            Text("Actions")
                .font(.system(size: 12, weight: isActive ? .semibold : .medium))
                .foregroundColor(isActive ? .primary : .secondary)

            HStack(spacing: 3) {
                // Command Key
                Text("⌘")
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 18, height: 18)
                    .background(Color.white.opacity(isActive ? 0.2 : 0.1))
                    .cornerRadius(4)
                    .foregroundColor(isActive ? .primary : .secondary)

                // K Key
                Text("K")
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 18, height: 18)
                    .background(Color.white.opacity(isActive ? 0.2 : 0.1))
                    .cornerRadius(4)
                    .foregroundColor(isActive ? .primary : .secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(isActive ? 0.15 : (isHovering ? 0.08 : 0.0)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white.opacity(isActive ? 0.1 : (isHovering ? 0.1 : 0)), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onHover { hover in
            withAnimation(.linear(duration: 0.1)) {
                isHovering = hover
            }
        }
    }
}
