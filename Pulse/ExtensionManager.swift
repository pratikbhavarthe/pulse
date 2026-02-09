//
//  ExtensionManager.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import AppKit
import Combine
import Foundation

class ExtensionManager: ObservableObject {
    static let shared = ExtensionManager()
    @Published var extensions: [SearchResult] = []

    // Directory: ~/Library/Application Support/Pulse/Extensions
    private let extensionsURL: URL? = {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first
        let pulseDir = appSupport?.appendingPathComponent("Pulse")
        let extensionsDir = pulseDir?.appendingPathComponent("Extensions")
        return extensionsDir
    }()

    private init() {
        createExtensionsDirectoryIfNeeded()
        scanExtensions()
    }

    private func createExtensionsDirectoryIfNeeded() {
        guard let url = extensionsURL else { return }
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

        // Create sample extension if empty
        let samplePath = url.appendingPathComponent("hello.sh")
        if !FileManager.default.fileExists(atPath: samplePath.path) {
            let sampleScript = """
                #!/bin/bash

                # @pulse.title: Hello World
                # @pulse.command: hello
                # @pulse.icon: 👋

                echo "Hello from Pulse Extension!"
                """
            try? sampleScript.write(to: samplePath, atomically: true, encoding: .utf8)
            try? FileManager.default.setAttributes(
                [.posixPermissions: 0o755], ofItemAtPath: samplePath.path)
        }
    }

    func scanExtensions() {
        guard let url = extensionsURL else { return }
        guard
            let contents = try? FileManager.default.contentsOfDirectory(
                at: url, includingPropertiesForKeys: nil)
        else { return }

        var foundExtensions: [SearchResult] = []

        for fileURL in contents {
            // Read first few lines for metadata
            guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { continue }
            let lines = content.components(separatedBy: .newlines)

            var title: String?
            var command: String?

            for line in lines.prefix(10) {
                if line.contains("@pulse.title:") {
                    title = line.components(separatedBy: ":").last?.trimmingCharacters(
                        in: .whitespaces)
                }
                if line.contains("@pulse.command:") {
                    command = line.components(separatedBy: ":").last?.trimmingCharacters(
                        in: .whitespaces)
                }
            }

            if let title = title, let command = command {
                // Use generic icon for now
                let defaultIcon = NSWorkspace.shared.icon(forFile: fileURL.path)

                let result = SearchResult(
                    name: title,
                    path: fileURL.path,
                    icon: defaultIcon,
                    type: .plugin,  // Need to add this case
                    stableId: "ext_" + command
                )
                foundExtensions.append(result)
            }
        }

        DispatchQueue.main.async {
            self.extensions = foundExtensions
        }
    }

    func execute(_ path: String) {
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        // Determine interpreter
        if path.hasSuffix(".sh") {
            task.launchPath = "/bin/bash"
            task.arguments = [path]
        } else if path.hasSuffix(".py") {
            task.launchPath = "/usr/bin/python3"
            task.arguments = [path]
        } else if path.hasSuffix(".js") {
            task.launchPath = "/usr/bin/node"  // might not exist
            task.arguments = [path]
        } else {
            task.launchPath = path  // executable directly
        }

        do {
            try task.run()

            // Read output
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(
                in: .whitespacesAndNewlines), !output.isEmpty
            {
                print("Extension Output: \(output)")
                // Copy to clipboard
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(output, forType: .string)
            } else {
                print("Extension ran but output was empty/nil")
            }
        } catch {
            print("Failed to run extension: \(error)")
        }
    }
}
