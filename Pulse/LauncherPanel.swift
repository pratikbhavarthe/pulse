//
//  LauncherPanel.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import AppKit

class LauncherPanel: NSPanel {
    override init(
        contentRect: NSRect, styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)

        self.isFloatingPanel = true
        self.level = .floating
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        self.becomesKeyOnlyIfNeeded = true
        self.acceptsMouseMovedEvents = true

        self.backgroundColor = .clear
        self.isOpaque = false  // Essential for Liquid Glass / VisualEffectView
        self.hasShadow = true
    }

    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }

    override func keyDown(with event: NSEvent) {
        NotificationCenter.default.post(name: .pulseKeyEvent, object: event)
        super.keyDown(with: event)
    }
}

// End of file
