//
//  PulseApp.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 08/02/26.
//

import SwiftUI

@main
struct PulseApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
