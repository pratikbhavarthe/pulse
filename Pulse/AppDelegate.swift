//
//  AppDelegate.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 08/02/26.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var panel: LauncherPanel!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView()

        panel = LauncherPanel()
        panel.contentView = NSHostingView(rootView: contentView)
        panel.makeKeyAndOrderFront(nil)

        NSApp.activate(ignoringOtherApps: true)
        panel.orderFrontRegardless()
    }
}
