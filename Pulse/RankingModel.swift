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
        let queryLower = query.lowercased()
        let nameLower = candidate.name.lowercased()

        // 1. Base String Similarity Score
        var baseScore = 0.0
        if nameLower == queryLower {
            baseScore = 20.0  // Strong boost for exact name match
        } else if nameLower.hasPrefix(queryLower) {
            baseScore = 10.0  // Good boost for prefix match
        } else {
            baseScore = 1.0  // Basic match
        }

        // 2. Folder Type Multiplier (Folders are usually better targets for generalized queries)
        var multiplier = 1.0
        if candidate.isFolder {
            multiplier *= 1.5
        }

        // 3. Path Depth Decay (Intelligence: Real system/work folders are closer to roots)
        // We use an exponential decay: score / (1 + depth)
        let components = candidate.path.components(separatedBy: "/")
        // depth factor: 1.0 for root, decreasing as we go deeper
        let depthFactor = 5.0 / (1.0 + Double(components.count))

        // 4. User Environment Bias
        var environmentBias = 1.0
        let homeDir = NSHomeDirectory()
        if candidate.path.hasPrefix(homeDir) {
            environmentBias += 2.0

            // Extra bias for shallow items in Home (e.g., Desktop, Projects)
            if components.count <= 4 {
                environmentBias += 3.0
            }
        }

        // Intelligence: Penalize archives, backups, and secondary copies
        let pathLower = candidate.path.lowercased()
        if pathLower.contains("archive") || pathLower.contains("backup")
            || pathLower.contains("snapshot")
        {
            environmentBias *= 0.1
        }

        // 5. Frequency & Recency (Learning from User Behavior)
        var usageScore = 0.0
        if let usage = usageStats[candidate.stableId] {
            usageScore += log(Double(usage.count + 1)) * 5.0

            let timeSince = Date().timeIntervalSince(usage.lastUsed)
            if timeSince < 3600 {
                usageScore += 10.0
            }  // Heavy boost for immediate re-use
            else if timeSince < 86400 {
                usageScore += 5.0
            }
        }

        // Final Aggregate Calculation
        return (baseScore * multiplier * depthFactor * environmentBias) + usageScore
    }
}
