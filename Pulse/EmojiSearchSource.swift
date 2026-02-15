//
//  EmojiSearchSource.swift
//  Pulse
//
//  Emoji search source with clipboard copy
//

import AppKit
import Foundation

class EmojiSearchSource {
    let name = "Emojis"
    let priority = 3

    func search(query: String) -> [SearchResult] {
        let emojis = EmojiData.shared.search(query: query)

        return emojis.map { emoji in
            SearchResult(
                name: emoji.name,
                path: emoji.symbol,  // Store emoji symbol in path
                icon: NSImage(),  // Empty icon, we'll use customIcon
                symbolName: nil,
                customIcon: emoji.symbol,
                type: .emoji,
                subtitle: emoji.category.rawValue,
                stableId: emoji.stableId,
                action: {
                    copyToClipboard(emoji.symbol)
                    print("DEBUG: Copied emoji to clipboard: \(emoji.symbol)")
                }
            )
        }
    }
}

private func copyToClipboard(_ text: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)
}
