//
//  FileSearch.swift
//  Pulse
//
//  Created by Antigravity on 09/02/26.
//

import AppKit
import Combine
import Foundation

class FileSearchManager: NSObject, ObservableObject {
    static let shared = FileSearchManager()
    @Published var results: [SearchResult] = []

    private let query = NSMetadataQuery()
    private var lastQuery: String = ""

    private override init() {
        super.init()
        setupQuery()
    }

    private func setupQuery() {
        // We look for files in Documents, Downloads, Desktop + Home
        query.searchScopes = [
            NSMetadataQueryUserHomeScope,
            NSMetadataQueryLocalComputerScope,
        ]

        print("FileSearch: Configured scopes: \(query.searchScopes)")

        // Add sorting by last used or relevance? No, Spotlight does it.
        // We can sort by name for now.
        query.sortDescriptors = [NSSortDescriptor(key: NSMetadataItemFSNameKey, ascending: true)]

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queryDidUpdate),
            name: .NSMetadataQueryDidFinishGathering,
            object: query
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queryDidUpdate),
            name: .NSMetadataQueryDidUpdate,
            object: query
        )
    }

    func search(queryStr: String) {
        let trimmed = queryStr.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            self.results = []
            DispatchQueue.main.async {
                self.query.stop()
            }
            return
        }

        if trimmed == lastQuery { return }
        lastQuery = trimmed

        DispatchQueue.main.async {
            self.query.stop()

            // Spotlight predicate: case-insensitive name match
            self.query.predicate = NSPredicate(
                format: "(kMDItemDisplayName CONTAINS[cd] %@) OR (kMDItemFSName CONTAINS[cd] %@)",
                trimmed, trimmed)

            print(
                "FileSearch: Starting query for '\(trimmed)' in scopes: \(self.query.searchScopes)")
            if !self.query.start() {
                print("FileSearch: Failed to start query")
            }
        }
    }

    @objc private func queryDidUpdate(_ notification: Notification) {
        print("FileSearch: Received update notification (\(notification.name.rawValue))")
        query.disableUpdates()

        let workspace = NSWorkspace.shared
        var finalResults: [String: SearchResult] = [:]
        var folderResults: [String: SearchResult] = [:]
        var seenPaths = Set<String>()

        print("FileSearch: Found \(query.results.count) items")
        for item in query.results {
            guard let metadataItem = item as? NSMetadataItem,
                let path = metadataItem.value(forAttribute: NSMetadataItemPathKey) as? String,
                let name = metadataItem.value(forAttribute: NSMetadataItemDisplayNameKey)
                    as? String,
                let typeTree = metadataItem.value(forAttribute: kMDItemContentTypeTree as String)
                    as? [String]
            else { continue }

            if seenPaths.contains(path) { continue }
            seenPaths.insert(path)

            let pathLower = path.lowercased()
            let nameLower = name.lowercased()

            // Skip system clutter and hidden files
            let isMobileDocs = pathLower.contains("library/mobile documents")
            if (pathLower.contains("/library/") && !isMobileDocs)
                || pathLower.contains("/node_modules/") || pathLower.contains("/system/")
                || pathLower.contains("/private/") || pathLower.contains("/usr/")
                || pathLower.contains("/bin/") || pathLower.hasSuffix(".framework")
                || pathLower.hasSuffix(".tbd") || pathLower.hasSuffix(".dylib")
                || pathLower.hasSuffix(".a") || name.hasPrefix(".")
            {
                continue
            }

            let isFolder =
                typeTree.contains("public.folder") || typeTree.contains("com.apple.package")
                || typeTree.contains("public.symlink") || typeTree.contains("com.apple.alias-file")
            let icon = workspace.icon(forFile: path)
            let result = SearchResult(
                name: name,
                path: path,
                icon: icon,
                type: .file,
                isFolder: isFolder,
                stableId: "file_" + path
            )

            if isFolder {
                // Heuristic: Favor non-archive versions over archives, even if paths are longer.
                // Archives (like iCloud Drive (Archive)) are usually stagnant data.
                if let existing = folderResults[nameLower] {
                    let isCurrentArchive = pathLower.contains("archive")
                    let isExistingArchive = existing.path.lowercased().contains("archive")

                    if isExistingArchive && !isCurrentArchive {
                        // Current is better (primary vs archive)
                        folderResults[nameLower] = result
                    } else if !isExistingArchive && isCurrentArchive {
                        // Keep existing (it's already the primary)
                    } else if path.count < existing.path.count {
                        // Both same status, keep shortest
                        folderResults[nameLower] = result
                    }
                } else {
                    folderResults[nameLower] = result
                }
            } else {
                finalResults[path] = result
            }
        }

        let sortedResults = (Array(folderResults.values) + Array(finalResults.values))
            .prefix(100)
        let finalFileResults = Array(sortedResults)

        DispatchQueue.main.async {
            self.results = finalFileResults
            self.query.enableUpdates()
        }
    }
}
