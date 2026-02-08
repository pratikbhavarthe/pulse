//
//  main.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()

app.setActivationPolicy(.accessory)   // ← THIS IS THE MAGIC LINE

app.delegate = delegate
app.run()
