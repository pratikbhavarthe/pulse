//
//  LauncherPanel.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 08/02/26.
//

import AppKit

class LauncherPanel: NSPanel {

    init() {
        let screenRect = NSScreen.main?.frame ?? .zero
        let width: CGFloat = 700
        let height: CGFloat = 120

        let rect = NSRect(
            x: (screenRect.width - width) / 2,
            y: screenRect.height * 0.66,
            width: width,
            height: height
        )

        super.init(
            contentRect: rect,
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        // Launcher behavior
        self.isFloatingPanel = true
        self.level = .floating
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Important for keyboard events
        self.becomesKeyOnlyIfNeeded = true
        self.acceptsMouseMovedEvents = true
    }

    // Allow panel to receive key events
    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }

    // Forward key events to SwiftUI
    override func keyDown(with event: NSEvent) {
        NotificationCenter.default.post(name: .pulseKeyEvent, object: event)
        super.keyDown(with: event)
    }
}
