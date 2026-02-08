//
//  SearchOrchestrator.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import AppKit
import Combine

class SearchOrchestrator: ObservableObject {
    static let shared = SearchOrchestrator()

    @Published var results: [SearchResult] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Listen to AppSearch updates
        AppSearch.shared.$apps
            .sink { [weak self] _ in
                // When apps update, we might re-trigger search if we had a query state.
                // But Orchestrator usually reacts to query input.
            }
            .store(in: &cancellables)
    }

    func search(query: String) {
        var newResults: [SearchResult] = []

        // 1. Calculator
        if let calcResult = Calculator.evaluate(query) {
            newResults.append(
                SearchResult(
                    name: "= \(calcResult)",
                    path: calcResult,  // Storing result in path for simplicity
                    icon: NSImage(systemSymbolName: "function", accessibilityDescription: nil)
                        ?? NSImage(),
                    type: .calculator,
                    stableId: "calc.\(query)",
                    action: nil  // Execute handled in SearchResult.execute
                ))
        }

        // 2. System Commands
        if !query.isEmpty {
            let sys = SystemCommand.all.filter { $0.name.fuzzyMatch(query) }
            newResults.append(contentsOf: sys.map { $0.asSearchResult })
        }

        // 3. Apps
        let apps = AppSearch.shared.apps
        if query.isEmpty {
            // Empty query behavior
        } else {
            let matches = apps.filter { $0.name.fuzzyMatch(query) }
            newResults.append(contentsOf: matches)
        }

        // 4. Ranking
        newResults.sort {
            let score1 = RankingEngine.shared.score(candidate: $0, query: query)
            let score2 = RankingEngine.shared.score(candidate: $1, query: query)
            return score1 > score2
        }

        // Update generic results
        self.results = newResults
    }
}
