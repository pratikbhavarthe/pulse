//
//  PulseApp.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import AppKit
import Combine
import QuartzCore
import SwiftUI

// MARK: - Window Components

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
        self.isOpaque = false
        self.hasShadow = true
    }

    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }

    override func keyDown(with event: NSEvent) {
        NotificationCenter.default.post(name: .pulseKeyEvent, object: event)
        super.keyDown(with: event)
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var launcherPanel: LauncherPanel!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize background services
        _ = ActiveAppDetector.shared

        let contentView = ContentView()
        let screenRect = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let width: CGFloat = 770  // Match ContentView
        let height: CGFloat = 450  // Match ContentView

        let rect = NSRect(
            x: (screenRect.width - width) / 2,
            y: screenRect.height * 0.6,  // Slightly higher visual center
            width: width,
            height: height
        )

        launcherPanel = LauncherPanel(
            contentRect: rect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.wantsLayer = true
        hostingView.layer?.cornerRadius = 16  // Tighter corner
        hostingView.layer?.masksToBounds = true
        hostingView.layer?.cornerCurve = .continuous  // Smoother corners for "Liquid" feel

        launcherPanel.contentView = hostingView

        // Remove window title bar padding
        launcherPanel.titlebarAppearsTransparent = true
        launcherPanel.titleVisibility = .hidden

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

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("hidePulse"), object: nil, queue: .main
        ) { [weak self] _ in
            self?.launcherPanel.orderOut(nil)
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
            // Capture the previous app before showing Pulse
            ActiveAppDetector.shared.capturePreviousApp()

            launcherPanel.makeKeyAndOrderFront(nil)
            NSRunningApplication.current.activate(options: .activateIgnoringOtherApps)
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
