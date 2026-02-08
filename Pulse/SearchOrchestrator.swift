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
    private var searchWorkItem: DispatchWorkItem?

    init() {
        // Listen to AppSearch updates
        AppSearch.shared.$apps
            .sink { [weak self] _ in
                // Re-run search if query exists?
                // For now, let next keystroke trigger it.
            }
            .store(in: &cancellables)
    }

    func search(query: String) {
        // Cancel previous pending search
        searchWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            var newResults: [SearchResult] = []

            // 1. Calculator (Fast, logic in background is safer)
            if let calcResult = Calculator.evaluate(query) {
                newResults.append(
                    SearchResult(
                        name: "= \(calcResult)",
                        path: calcResult,
                        icon: NSImage(systemSymbolName: "function", accessibilityDescription: nil)
                            ?? NSImage(),
                        type: .calculator,
                        stableId: "calc.\(query)",
                        action: nil
                    ))
            }

            // 2. System Commands
            if !query.isEmpty {
                let sys = SystemCommand.all.filter { $0.name.fuzzyMatch(query) }
                newResults.append(contentsOf: sys.map { $0.asSearchResult })
            }

            // 3. Apps
            let apps = AppSearch.shared.apps
            if !query.isEmpty {
                let matches = apps.filter { $0.name.fuzzyMatch(query) }
                newResults.append(contentsOf: matches)
            }

            // 4. Ranking
            newResults.sort {
                let score1 = RankingEngine.shared.score(candidate: $0, query: query)
                let score2 = RankingEngine.shared.score(candidate: $1, query: query)
                return score1 > score2
            }

            // Check cancellation before updating UI
            if self.searchWorkItem?.isCancelled == true { return }

            DispatchQueue.main.async {
                self.results = newResults
            }
        }

        self.searchWorkItem = workItem
        DispatchQueue.global(qos: .userInitiated).async(execute: workItem)
    }
}
