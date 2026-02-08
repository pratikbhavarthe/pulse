//
//  Calculator.swift
//  Pulse
//
//  Created by Pratik Bhavarthe on 09/02/26.
//

import Foundation
import JavaScriptCore

struct Calculator {
    static let context: JSContext = {
        let ctx = JSContext()!
        // Inject standard Math functions globally for easier access
        ctx.evaluateScript(
            "var sqrt = Math.sqrt; var pow = Math.pow; var sin = Math.sin; var cos = Math.cos; var tan = Math.tan; var log = Math.log; var PI = Math.PI; var E = Math.E;"
        )
        return ctx
    }()

    static func evaluate(_ expression: String) -> String? {
        // 1. Clean the input
        let cleaned = expression.lowercased()
            .replacingOccurrences(of: "calc", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "^", with: "**")  // Support ^ as power

        if cleaned.isEmpty { return nil }

        // 2. Pre-check: Must contain at least one number or constant
        let hasNumber = cleaned.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
        if !hasNumber && !cleaned.contains("pi") && !cleaned.contains("e") { return nil }

        // 3. Safety Check: Filter out dangerous chars (braces, brackets, quotes) to prevent JS injection/execution of arbitrary code
        let riskyChars = CharacterSet(charactersIn: "{}[]'\"`$;")
        if cleaned.rangeOfCharacter(from: riskyChars) != nil {
            return nil
        }

        // 4. Evaluate safely using JavaScriptCore
        // This avoids the crash issues associated with NSExpression
        let result = context.evaluateScript(cleaned)

        if let res = result, !res.isUndefined, !res.isNull, let num = res.toNumber() {
            let doubleVal = num.doubleValue

            // Check for valid number
            if doubleVal.isNaN || doubleVal.isInfinite { return nil }

            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 4
            return formatter.string(from: NSNumber(value: doubleVal))
        }

        return nil
    }
}
