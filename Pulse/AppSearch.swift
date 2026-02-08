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
                "/System/Applications",
                "/System/Library/CoreServices/Applications",
                ("~" as NSString).expandingTildeInPath + "/Applications",
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
                        // Note: icon(forFile:) is safe to call here, but drawing must be on main thread
                        let icon = workspace.icon(forFile: path)
                        let result = SearchResult(name: name, path: path, icon: icon, type: .app)
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
