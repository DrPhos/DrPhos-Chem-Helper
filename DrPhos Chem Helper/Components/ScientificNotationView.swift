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
    private var mantissa: String
    private var exponent: Int?
    var exponentFont: Font = .system(size: 16, weight: .semibold)
    var exponentOffset: CGFloat = 8

    init(
        number: String,
        exponentFont: Font = .system(size: 16, weight: .semibold),
        exponentOffset: CGFloat = 8
    ) {
        let components = number.split(separator: "^", maxSplits: 1)
        mantissa = String(components[0])
            .replacingOccurrences(of: " x10", with: " × 10")
        exponent = components.count > 1
            ? Int(String(components[1]).replacingOccurrences(of: "+", with: ""))
            : nil
        self.exponentFont = exponentFont
        self.exponentOffset = exponentOffset
    }

    init(
        mantissa: String,
        exponent: Int,
        exponentFont: Font = .system(size: 16, weight: .semibold),
        exponentOffset: CGFloat = 8
    ) {
        self.mantissa = "\(mantissa) × 10"
        self.exponent = exponent
        self.exponentFont = exponentFont
        self.exponentOffset = exponentOffset
    }

    var body: some View {
        let exponentText = exponent.map { Self.superscript(String($0)) } ?? ""

        return HStack(spacing: 0) {
            Text(mantissa)
            Text(exponentText)
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
