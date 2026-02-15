//
//  ConfirmationPopup.swift
//  Premium confirmation popup with micro-interactions
//

import SwiftUI

struct ConfirmationPopup: View {
    let message: String
    let confirmText: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    @State private var isHoveringCancel = false
    @State private var isHoveringConfirm = false
    @State private var scale: CGFloat = 0.95
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Semi-transparent background with blur effect
            Color.black.opacity(0.6)
                .frame(width: 770, height: 450)
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.15)) {
                        onCancel()
                    }
                }

            // Popup card
            VStack(spacing: 24) {
                // Warning icon with subtle glow
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(.yellow.opacity(0.9))
                    .shadow(color: .yellow.opacity(0.3), radius: 8, x: 0, y: 2)

                // Message
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)

                // Buttons with hover effects
                HStack(spacing: 12) {
                    // Cancel button
                    Button(action: {
                        print("DEBUG: Cancel button clicked")
                        onCancel()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(isHoveringCancel ? 1.0 : 0.85))
                            .frame(width: 130, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color.white.opacity(isHoveringCancel ? 0.18 : 0.12))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(
                                        Color.white.opacity(isHoveringCancel ? 0.25 : 0.15),
                                        lineWidth: 1)
                            )
                            .scaleEffect(isHoveringCancel ? 1.02 : 1.0)
                            .shadow(
                                color: .black.opacity(isHoveringCancel ? 0.2 : 0), radius: 8, x: 0,
                                y: 4
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { hovering in
                        withAnimation(.easeOut(duration: 0.15)) {
                            isHoveringCancel = hovering
                        }
                    }

                    // Confirm button (destructive)
                    Button(action: {
                        print("DEBUG: Confirm button clicked - executing pendingAction")
                        onConfirm()
                    }) {
                        Text(confirmText)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 130, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.red.opacity(isHoveringConfirm ? 0.95 : 0.85),
                                                Color.red.opacity(isHoveringConfirm ? 0.85 : 0.75),
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color.red.opacity(0.5), lineWidth: 1)
                            )
                            .scaleEffect(isHoveringConfirm ? 1.02 : 1.0)
                            .shadow(
                                color: .red.opacity(isHoveringConfirm ? 0.4 : 0.2),
                                radius: isHoveringConfirm ? 12 : 8, x: 0, y: 4
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { hovering in
                        withAnimation(.easeOut(duration: 0.15)) {
                            isHoveringConfirm = hovering
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 36)
            .padding(.horizontal, 24)
            .frame(width: 420)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(NSColor.windowBackgroundColor).opacity(0.98))
                    .shadow(color: .black.opacity(0.5), radius: 50, x: 0, y: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05),
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.5
                    )
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    scale = 1.0
                }
                withAnimation(.easeOut(duration: 0.2)) {
                    opacity = 1.0
                }
            }
        }
    }
}
