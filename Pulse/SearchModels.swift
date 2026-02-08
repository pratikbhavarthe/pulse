//
//  SearchModels.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import AppKit
import Combine

public enum ResultType {
    case app
    case system
    case calculator
}

public struct SearchResult: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    public let path: String
    public let icon: NSImage
    public let type: ResultType
    public let action: (() -> Void)?

    public init(
        name: String, path: String, icon: NSImage, type: ResultType = .app,
        action: (() -> Void)? = nil
    ) {
        self.name = name
        self.path = path
        self.icon = icon
        self.type = type
        self.action = action
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(name)
    }

    public static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.path == rhs.path && lhs.name == rhs.name
    }
}
