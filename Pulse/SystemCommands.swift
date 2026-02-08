//
//  SystemCommands.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import AppKit

struct SystemCommand: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let action: () -> Void
    let iconName: String

    static func == (lhs: SystemCommand, rhs: SystemCommand) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func runShell(_ command: String) {
        print("SystemCommand: Running Shell: \(command)")
        let process = Process()
        process.launchPath = "/bin/bash"  // Use /bin/bash or /bin/zsh
        process.arguments = ["-c", command]
        try? process.run()
    }

    static func runScript(_ source: String) {
        print("SystemCommand: Running AppleScript: \(source)")
        var error: NSDictionary?
        if let script = NSAppleScript(source: source) {
            script.executeAndReturnError(&error)
            if let error = error {
                print("SystemCommand Script Error: \(error)")
            }
        }
    }

    static let all: [SystemCommand] = [
        SystemCommand(
            name: "Sleep",
            action: {
                // pmset sleepnow is instant and reliable
                runShell("pmset sleepnow")
            }, iconName: "moon.fill"),
        SystemCommand(
            name: "Restart",
            action: {
                // Restart via Finder is usually safe
                runScript("tell application \"Finder\" to restart")
            }, iconName: "restart.circle.fill"),
        SystemCommand(
            name: "Shut Down",
            action: {
                // Shut Down via Finder
                runScript("tell application \"Finder\" to shut down")
            }, iconName: "power.circle.fill"),
        SystemCommand(
            name: "Lock Screen",
            action: {
                // Updated Lock Screen command (Display Sleep)
                // Works without accessibility permissions
                runShell("pmset displaysleepnow")
            }, iconName: "lock.fill"),
        SystemCommand(
            name: "Empty Trash",
            action: {
                runScript("tell application \"Finder\" to empty trash")
            }, iconName: "trash.fill"),
    ]

    var asSearchResult: SearchResult {
        SearchResult(
            name: name,
            path: "system",
            icon: NSImage(systemSymbolName: iconName, accessibilityDescription: nil) ?? NSImage(),
            type: .system,
            stableId: "system.\(name.lowercased().replacingOccurrences(of: " ", with: "."))",
            action: action
        )
    }
}
