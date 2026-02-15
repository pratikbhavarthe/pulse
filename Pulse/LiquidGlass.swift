//
//  LiquidGlass.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import AppKit
import SwiftUI

// MARK: - Visual Effect Blur (Base)

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var state: NSVisualEffectView.State = .active
    var cornerRadius: CGFloat = 0

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

// MARK: - Liquid Glass Modifier

struct LiquidGlassModifier: ViewModifier {
    var material: NSVisualEffectView.Material = .hudWindow
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var cornerRadius: CGFloat = 16
    var hasBacking: Bool = false
    var backingOpacity: Double = 0.65

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    VisualEffectBlur(
                        material: material,
                        blendingMode: blendingMode,
                        state: .active,
                        cornerRadius: cornerRadius
                    )

                    if hasBacking {
                        Color.black.opacity(backingOpacity)
                    }
                }
            )
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.35), radius: 25, x: 0, y: 15)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
    }
}

extension View {
    func liquidGlass(
        material: NSVisualEffectView.Material = .hudWindow,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        cornerRadius: CGFloat = 16,
        hasBacking: Bool = false,
        backingOpacity: Double = 0.65
    ) -> some View {
        self.modifier(
            LiquidGlassModifier(
                material: material,
                blendingMode: blendingMode,
                cornerRadius: cornerRadius,
                hasBacking: hasBacking,
                backingOpacity: backingOpacity
            ))
    }
}
