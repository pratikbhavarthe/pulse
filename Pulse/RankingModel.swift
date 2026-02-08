//
//  RankingModel.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import Foundation

struct CommandUsage: Codable {
    let id: String
    var count: Int
    var lastUsed: Date
}

class RankingEngine {
    static let shared = RankingEngine()

    private var usageStats: [String: CommandUsage] = [:]
    private let statsURL: URL

    private init() {
        // Setup file path in Application Support
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupport = urls.first!.appendingPathComponent("Pulse")

        // Ensure directory exists
        try? fileManager.createDirectory(at: appSupport, withIntermediateDirectories: true)

        self.statsURL = appSupport.appendingPathComponent("ranking_data.json")
        load()
    }

    // MARK: - Persistence

    private func load() {
        guard let data = try? Data(contentsOf: statsURL),
            let stats = try? JSONDecoder().decode([String: CommandUsage].self, from: data)
        else {
            return
        }
        self.usageStats = stats
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(usageStats) else { return }
        try? data.write(to: statsURL)
    }

    // MARK: - API

    func recordExecution(stableId: String) {
        if var usage = usageStats[stableId] {
            usage.count += 1
            usage.lastUsed = Date()
            usageStats[stableId] = usage
        } else {
            usageStats[stableId] = CommandUsage(id: stableId, count: 1, lastUsed: Date())
        }

        // Async save to avoid blocking UI
        DispatchQueue.global(qos: .background).async {
            self.save()
        }
    }

    func score(candidate: SearchResult, query: String) -> Double {
        // 1. Base Score (Fuzzy Match)
        // Simple boolean match logic currently returns 1.0 or 0.0,
        // but we should ideally integrate a fuzzy score.
        // For now, if it matches, base = 1.0
        let baseScore = 1.0

        // 2. Frequency Boost
        var boost = 0.0
        if let usage = usageStats[candidate.stableId] {
            // Logarithmic scale prevents frequently used items from dominating excessively
            boost += log(Double(usage.count + 1)) * 2.0

            // Recency Boost (Decay)
            // Example: Used within last hour = +2, last day = +1
            let timeSince = Date().timeIntervalSince(usage.lastUsed)
            if timeSince < 3600 { boost += 2.0 } else if timeSince < 86400 { boost += 1.0 }
        }

        return baseScore + boost
    }
}
