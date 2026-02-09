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
                if let query = self?.lastQuery {
                    self?.search(query: query)
                }
            }
            .store(in: &cancellables)

        // Listen to FileSearch updates
        FileSearchManager.shared.$results
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                // Only re-run search if we actually have a query
                if !self.lastQuery.isEmpty {
                    self.search(query: self.lastQuery)
                }
            }
            .store(in: &cancellables)
    }

    private var lastQuery: String = ""

    func search(query: String) {
        lastQuery = query
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

            // 4. Extensions
            if !query.isEmpty {
                let exts = ExtensionManager.shared.extensions
                let matches = exts.filter { $0.name.fuzzyMatch(query) }
                newResults.append(contentsOf: matches)
            }

            // 5. Files
            if !query.isEmpty {
                // Ensure query is started if needed
                FileSearchManager.shared.search(queryStr: query)

                // Get CURRENT results. The listener will trigger a re-search
                // once the async Spotlight query finishes.
                let files = FileSearchManager.shared.results
                newResults.append(contentsOf: files)
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
