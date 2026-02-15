import SwiftUI

struct EmojiCell: View {
    let emoji: Emoji
    let isSelected: Bool
    let onSelect: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                // Card Background
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        isSelected
                            ? Color.white.opacity(0.12) : Color.white.opacity(0.04)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(
                                Color.white.opacity(isSelected ? 1.0 : 0),
                                lineWidth: 2)
                    )

                Text(emoji.symbol)
                    .font(.system(size: 26))
            }
            .frame(width: 52, height: 52)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        .tooltip(emoji.name, isVisible: isHovering)
    }
}

