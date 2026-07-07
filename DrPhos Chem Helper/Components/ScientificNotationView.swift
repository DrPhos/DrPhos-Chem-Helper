//
//  ScientificNotationView.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 7/26/25.
//


//
//  SciNotation.swift
//  DrPhos Chem Helper
//
//  Created by Monte Helm on 7/5/24.

import SwiftUI

enum ScientificNotationFormatter {
    static func shouldUseScientificNotation(_ value: Double) -> Bool {
        guard value.isFinite else { return false }
        let absoluteValue = abs(value)
        return absoluteValue != 0 && (absoluteValue < 0.001 || absoluteValue >= 100_000)
    }

    static func format(_ value: Double, decimalPlaces: Int) -> String {
        guard value.isFinite else { return "Invalid" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.exponentSymbol = " x10^"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = decimalPlaces
        formatter.positiveFormat = "0.###E+0"
        formatter.negativeFormat = "-0.###E+0"

        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}

struct ScientificNotationView: View {
    var number: String
    var exponentFont: Font = .system(size: 16, weight: .semibold)
    var exponentOffset: CGFloat = 8

    var body: some View {
        let components = number.split(separator: "^", maxSplits: 1)
        let base = String(components[0])
            .replacingOccurrences(of: " x10", with: " × 10")
        let exponent = components.count > 1
            ? Self.superscript(String(components[1]))
            : ""

        return HStack(spacing: 0) {
            Text(base)
            Text(exponent)
                .font(exponentFont)
                .baselineOffset(exponentOffset)
        }
    }

    private static func superscript(_ text: String) -> String {
        let characters: [Character: Character] = [
            "0": "⁰",
            "1": "¹",
            "2": "²",
            "3": "³",
            "4": "⁴",
            "5": "⁵",
            "6": "⁶",
            "7": "⁷",
            "8": "⁸",
            "9": "⁹",
            "+": "⁺",
            "-": "⁻"
        ]
        return String(text.map { characters[$0] ?? $0 })
    }
}

extension Double {
    func formattedScientific(decimalPlaces: Int) -> String {
        ScientificNotationFormatter.format(self, decimalPlaces: decimalPlaces)
    }
}
