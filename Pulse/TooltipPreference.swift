import SwiftUI

// MARK: - Tooltip Data Model

struct TooltipData: Equatable {
    let text: String
    let frame: CGRect
}

// MARK: - Preference Key

struct TooltipPreferenceKey: PreferenceKey {
    static var defaultValue: TooltipData? = nil

    static func reduce(value: inout TooltipData?, nextValue: () -> TooltipData?) {
        value = nextValue() ?? value
    }
}

// MARK: - Tooltip Modifier

struct TooltipModifier: ViewModifier {
    let text: String
    let isVisible: Bool

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: TooltipPreferenceKey.self,
                            value: isVisible
                                ? TooltipData(
                                    text: text,
                                    frame: geometry.frame(in: .global)
                                ) : nil
                        )
                }
            )
    }
}

extension View {
    func tooltip(_ text: String, isVisible: Bool) -> some View {
        self.modifier(TooltipModifier(text: text, isVisible: isVisible))
    }
}

// MARK: - Tooltip Overlay View

struct TooltipOverlay: View {
    let tooltipData: TooltipData?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let data = tooltipData {
                    let tooltipContent = Text(data.text)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            // Liquid glass effect matching filter dropdown
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                                .background(
                                    VisualEffectBlur(
                                        material: .popover,
                                        blendingMode: .withinWindow,
                                        state: .active,
                                        cornerRadius: 8
                                    )
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                                )
                        )
                        .fixedSize()

                    // Calculate smart position to avoid clipping
                    let baseY = data.frame.maxY + 18
                    let centerX = data.frame.midX

                    // Estimate tooltip width (approximate based on text length)
                    let estimatedWidth = CGFloat(data.text.count) * 7 + 20  // rough estimate
                    let halfWidth = estimatedWidth / 2

                    // Adjust X position to stay within bounds
                    let minX: CGFloat = halfWidth + 8  // 8px padding from edge
                    let maxX = geometry.size.width - halfWidth - 8
                    let adjustedX = min(max(centerX, minX), maxX)

                    tooltipContent
                        .position(x: adjustedX, y: baseY)
                        .allowsHitTesting(false)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .animation(.easeInOut(duration: 0.15), value: tooltipData?.text)
        }
    }
}
