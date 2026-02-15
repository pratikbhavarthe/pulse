//
//  QuicklinkEditorView.swift
//  Pulse
//
//  UI for creating and editing Quicklinks
//

import SwiftUI

struct QuicklinkEditorView: View {
    @Environment(\.dismiss) var dismiss

    // Identifiable state for editing existing link
    var editingLink: Quicklink?

    @State private var name: String = ""
    @State private var link: String = ""
    @State private var icon: String = "link"
    @State private var openWith: String = ""

    // Icons for selection
    let icons = ["link", "globe", "folder", "doc.text", "terminal", "gear", "star"]

    init(editingLink: Quicklink? = nil, initialLink: String = "") {
        self.editingLink = editingLink
        _name = State(initialValue: editingLink?.name ?? "")
        _link = State(initialValue: editingLink?.link ?? initialLink)
        _icon = State(initialValue: editingLink?.icon ?? "link")
        _openWith = State(initialValue: editingLink?.openWith ?? "")
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(editingLink == nil ? "Create Quicklink" : "Edit Quicklink")
                .font(.headline)

            // FORM
            VStack(alignment: .leading, spacing: 12) {
                // Name
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("e.g. Search Google", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // Link
                VStack(alignment: .leading, spacing: 4) {
                    Text("Link or URL")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("https://...", text: $link)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("Tip: Use {argument} for dynamic queries, {clipboard} for copied text")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // Icon Selection
                VStack(alignment: .leading, spacing: 4) {
                    Text("Icon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 12) {
                        ForEach(icons, id: \.self) { iconName in
                            Button(action: { icon = iconName }) {
                                Image(systemName: iconName)
                                    .font(.system(size: 16))
                                    .padding(8)
                                    .background(
                                        icon == iconName
                                            ? Color.accentColor.opacity(0.2) : Color.clear
                                    )
                                    .clipShape(Circle())
                                    .foregroundColor(icon == iconName ? .accentColor : .primary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }

                // Open With (Optional)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Open With (Optional)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("App Name (e.g. Chrome)", text: $openWith)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)

            // Buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Save Quicklink") {
                    save()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.isEmpty || link.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 450)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 20)
    }

    private func save() {
        if let editingId = editingLink?.id {
            QuicklinkManager.shared.deleteQuicklink(id: editingId)
        }

        QuicklinkManager.shared.addQuicklink(
            name: name,
            link: link,
            icon: icon,
            openWith: openWith.isEmpty ? nil : openWith
        )

        dismiss()
    }
}
