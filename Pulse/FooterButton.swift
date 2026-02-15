import SwiftUI

struct FooterButton: View {
    let action: () -> Void
    let label: String
    let shortcutIcon: String
    var isPrimary: Bool = false

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 6) {  // Tighter spacing, centered alignment
                Text(label)
                    .font(.system(size: 12, weight: isPrimary ? .semibold : .medium))
                    .foregroundColor(isPrimary ? .primary.opacity(0.9) : .secondary)
                    .fixedSize()  // Prevent text truncation/layout shifts

                Image(systemName: shortcutIcon)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 18, height: 18)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(4)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(isHovering ? 0.12 : 0.0))  // Transparent default
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(isHovering ? 0.1 : 0), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hover in
            withAnimation(.linear(duration: 0.1)) {
                isHovering = hover
            }
        }
    }
}
