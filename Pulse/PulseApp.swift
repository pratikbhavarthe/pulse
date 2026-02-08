//
//  PulseApp.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import AppKit
import SwiftUI

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var launcherPanel: LauncherPanel!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView()
        let screenRect = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let width: CGFloat = 700
        let height: CGFloat = 120  // Initial height, expands with content

        let rect = NSRect(
            x: (screenRect.width - width) / 2,
            y: screenRect.height * 0.66,
            width: width,
            height: height
        )

        launcherPanel = LauncherPanel(
            contentRect: rect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        launcherPanel.contentView = NSHostingView(rootView: contentView)
        launcherPanel.center()
        launcherPanel.makeKeyAndOrderFront(nil)

        NSApp.setActivationPolicy(.accessory)

        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleHotkey(event)
        }

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleHotkey(event)
            return event
        }
    }

    func handleHotkey(_ event: NSEvent) {
        if event.modifierFlags.contains(.option) && event.keyCode == 49 {
            togglePanel()
        }
    }

    func togglePanel() {
        if launcherPanel.isVisible {
            launcherPanel.orderOut(nil)
        } else {
            launcherPanel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

// MARK: - Entry Point

@main
struct PulseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
 
