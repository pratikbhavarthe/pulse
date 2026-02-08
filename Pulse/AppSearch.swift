//
//  AppSearch.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import AppKit
import Combine

class AppSearch: ObservableObject {
    static let shared = AppSearch()
    @Published var apps: [SearchResult] = []
    private var isScanning = false

    private init() {
        scanApps()
    }

    func scanApps() {
        guard !isScanning else { return }
        isScanning = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var foundApps: [SearchResult] = []
            let directories = [
                "/Applications",
                "/Applications/Utilities",
                "/System/Applications",
                "/System/Applications/Utilities",
                "/System/Library/CoreServices",  // Finder is here
                "/System/Library/CoreServices/Applications",
                ("~" as NSString).expandingTildeInPath + "/Applications",
                ("~" as NSString).expandingTildeInPath + "/Applications/Utilities",
            ]
            let fileManager = FileManager.default
            let workspace = NSWorkspace.shared

            for dir in directories {
                guard let contents = try? fileManager.contentsOfDirectory(atPath: dir) else {
                    continue
                }
                for item in contents {
                    if item.hasSuffix(".app") {
                        let path = (dir as NSString).appendingPathComponent(item)
                        let name = (item as NSString).deletingPathExtension
                        let icon = workspace.icon(forFile: path)

                        // Attempt to get Bundle Identifier for stable ID
                        let bundle = Bundle(path: path)
                        let stableId = bundle?.bundleIdentifier ?? path

                        let result = SearchResult(
                            name: name, path: path, icon: icon, type: ResultType.app,
                            stableId: stableId)
                        foundApps.append(result)
                    }
                }
            }
            DispatchQueue.main.async {
                self?.apps = foundApps
                self?.isScanning = false
            }
        }
    }
}

extension String {
    func fuzzyMatch(_ query: String) -> Bool {
        if query.isEmpty { return true }

        let queryString = query.lowercased()
        let selfString = self.lowercased()

        var remainder = queryString[...]
        for char in selfString {
            if let first = remainder.first, char == first {
                remainder.removeFirst()
                if remainder.isEmpty { return true }
            }
        }
        return false
    }
}
