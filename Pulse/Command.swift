//
//  Command.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import AppKit

public protocol Command: Identifiable {
    var id: UUID { get }
    var stableId: String { get }  // For persistence/ranking
    var name: String { get }
    var icon: NSImage { get }
    var score: Double { get }

    func execute()
}

// Default implementation for score since it comes from RankingEngine external logic usually,
// but for protocol compliance we might want it here or calculated externally.
// Let's keep it simple: The logic calculates score. The object might hold it if needed for sorting.
// For now, let's say Command just needs execution. Score is metadata.

extension Command {
    // Helper to run safely
    func run() {
        execute()
        // Record usage
        RankingEngine.shared.recordExecution(stableId: stableId)
    }
}
