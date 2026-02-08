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
            y: (screenRect.height - height) / 2,
            width: width,
            height: height
        )
        
        super.init(
            contentRect: rect,
            styleMask: [.nonactivatingPanel, .titled],
            backing: .buffered,
            defer: false
        )
        
        self.isFloatingPanel = true
        self.level = .floating
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }
}
