//
//  HighlightText.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import SwiftUI

struct HighlightText: View {
    let text: String
    let query: String

    var body: some View {
        Group {
            if query.isEmpty {
                Text(text)
            } else if let range = text.range(of: query, options: .caseInsensitive) {
                // Split text
                let prefix = String(text[..<range.lowerBound])
                let match = String(text[range])
                let suffix = String(text[range.upperBound...])

                // Use HStack for compatibility
                HStack(spacing: 0) {
                    Text(prefix)
                    Text(match).bold()
                    Text(suffix)
                }
            } else {
                Text(text)
            }
        }
    }
}
