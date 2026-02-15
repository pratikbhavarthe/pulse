//
//  ActiveAppDetector.swift
//  Pulse
//
//  Detects the previously active application for smart paste detection
//

import AppKit
import Combine
import Foundation

class ActiveAppDetector: ObservableObject {
    static let shared = ActiveAppDetector()

    @Published var previousAppName: String = "Application"
    @Published var previousAppBundleID: String?

    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Start tracking immediately
        setupAppTracking()
    }

    private func setupAppTracking() {
        NSWorkspace.shared.notificationCenter.publisher(
            for: NSWorkspace.didActivateApplicationNotification
        )
        .compactMap { $0.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication }
        .sink { [weak self] app in
            self?.handleAppActivation(app)
        }
        .store(in: &cancellables)

        // Initial capture
        if let current = NSWorkspace.shared.frontmostApplication {
            handleAppActivation(current)
        }
    }

    private func handleAppActivation(_ app: NSRunningApplication) {
        // Ignore Pulse itself
        if app.bundleIdentifier == Bundle.main.bundleIdentifier {
            return
        }

        // Update state
        DispatchQueue.main.async {
            self.previousAppBundleID = app.bundleIdentifier
            self.previousAppName = app.localizedName ?? "Application"
            print("DEBUG: Tracked active app: \(self.previousAppName)")
        }
    }

    // Kept for compatibility but mostly no-op now since we track live
    func capturePreviousApp() {
        // If we somehow missed it, try one last check
        if let front = NSWorkspace.shared.frontmostApplication,
            front.bundleIdentifier != Bundle.main.bundleIdentifier
        {
            handleAppActivation(front)
        }
    }

    /// Returns a user-friendly paste label
    var pasteLabel: String {
        return "Paste to \(previousAppName)"
    }

    /// Pastes the clipboard content to the previously active application
    func pasteToPreviousApp() {
        guard let bundleID = previousAppBundleID else { return }

        // 1. Activate the previous app
        if let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).first
        {
            // Using modern API
            app.activate(options: .activateIgnoringOtherApps)
        }

        // 2. Wait a tiny bit for focus to switch, then send Cmd+V
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.25) {
            let src = CGEventSource(stateID: .hidSystemState)

            let cmdDown = CGEvent(keyboardEventSource: src, virtualKey: 0x37, keyDown: true)  // kVK_Command
            let vDown = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: true)  // kVK_ANSI_V
            let vUp = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: false)
            let cmdUp = CGEvent(keyboardEventSource: src, virtualKey: 0x37, keyDown: false)

            cmdDown?.flags = .maskCommand
            vDown?.flags = .maskCommand
            vUp?.flags = .maskCommand

            cmdDown?.post(tap: .cghidEventTap)
            vDown?.post(tap: .cghidEventTap)
            vUp?.post(tap: .cghidEventTap)
            cmdUp?.post(tap: .cghidEventTap)

            print("DEBUG: Sent Cmd+V to \(self.previousAppName)")
        }
    }
}
