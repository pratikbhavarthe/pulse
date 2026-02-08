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
        
        // Create SwiftUI content
        let contentView = ContentView()
        
        // Create panel
        panel = LauncherPanel()
        panel.contentView = NSHostingView(rootView: contentView)
        
        // Show once on launch (temporary for testing)
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        // Register hotkey listeners
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleHotkey(event)
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleHotkey(event)
            return event
        }
    }
    
    func handleHotkey(_ event: NSEvent) {
        // Option + Space
        if event.modifierFlags.contains(.option) && event.keyCode == 49 {
            togglePanel()
        }
    }
    
    func togglePanel() {  
        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
