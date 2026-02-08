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

    static let all: [SystemCommand] = [
        SystemCommand(
            name: "Sleep",
            action: {
                let source = "tell application \"Finder\" to sleep"
                NSAppleScript(source: source)?.executeAndReturnError(nil)
            }, iconName: "moon.fill"),
        SystemCommand(
            name: "Restart",
            action: {
                let source = "tell application \"Finder\" to restart"
                NSAppleScript(source: source)?.executeAndReturnError(nil)
            }, iconName: "restart.circle.fill"),
        SystemCommand(
            name: "Shut Down",
            action: {
                let source = "tell application \"Finder\" to shut down"
                NSAppleScript(source: source)?.executeAndReturnError(nil)
            }, iconName: "power.circle.fill"),
        SystemCommand(
            name: "Lock Screen",
            action: {
                let source =
                    "tell application \"System Events\" to keystroke \"q\" using {control down, command down}"
                NSAppleScript(source: source)?.executeAndReturnError(nil)
            }, iconName: "lock.fill"),
        SystemCommand(
            name: "Empty Trash",
            action: {
                let source = "tell application \"Finder\" to empty trash"
                NSAppleScript(source: source)?.executeAndReturnError(nil)
            }, iconName: "trash.fill"),
    ]
}
