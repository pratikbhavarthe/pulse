import SwiftUI

struct CustomScrollView<Content: View>: View {
    let content: Content

    // State for scrollbar calculation
    @State private var contentHeight: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var visibleHeight: CGFloat = 0
    @State private var isHovering: Bool = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { outerGeo in
            ZStack(alignment: .topTrailing) {
                ScrollView(showsIndicators: false) {
                    content
                        .padding(.horizontal, 14)  // Symmetric padding for consistency
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .preference(
                                        key: ScrollOffsetKey.self,
                                        value: geo.frame(in: .named("customScroll")).minY
                                    )
                                    .preference(key: ContentHeightKey.self, value: geo.size.height)
                            }
                        )
                }
                .coordinateSpace(name: "customScroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    scrollOffset = value
                }
                .onPreferenceChange(ContentHeightKey.self) { value in
                    contentHeight = value
                }
                .onAppear {
                    visibleHeight = outerGeo.size.height
                }
                .onChange(of: outerGeo.size.height) { newHeight in
                    visibleHeight = newHeight
                }

                // Custom Scrollbar
                if contentHeight > visibleHeight {
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.white.opacity(isHovering ? 0.6 : 0.4))
                        .frame(width: 5, height: scrollbarHeight)  // Thicker (5px)
                        .offset(y: scrollbarOffset)
                        .padding(.trailing, 4)  // Gap from edge
                        .padding(.top, 2)
                        .opacity(1)
                        .animation(.easeInOut(duration: 0.2), value: isHovering)
                }
            }
            .onHover { hovering in
                isHovering = hovering
            }
        }
    }

    private var scrollbarHeight: CGFloat {
        let ratio = visibleHeight / contentHeight
        // Cap height between 15 and 30 for VERY small "pill" look
        return min(max(15, visibleHeight * ratio), 30)
    }

    private var scrollbarOffset: CGFloat {
        guard contentHeight > visibleHeight else { return 0 }

        let maxScrollOffset = contentHeight - visibleHeight
        let maxIndicatorOffset = visibleHeight - scrollbarHeight - 4

        // Inverted coordinate system: scrollOffset is negative when scrolling down
        // so -scrollOffset is positive progress
        let progress = -scrollOffset / maxScrollOffset

        // Clamp progress
        let clampedProgress = min(max(progress, 0), 1)

        return clampedProgress * maxIndicatorOffset 
    }
}

// Preference Keys
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
