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

struct ScientificNotationView: View {
    var number: String

    var body: some View {
        let components = number.split(separator: "^")
        let base = String(components[0])
        let exponent = components.count > 1 ? String(components[1]) : ""

        return HStack(spacing: 0) {
            Text(base)
            Text(exponent)
                .font(.system(size: 12))
                .baselineOffset(10)
        }
    }
}

extension Double {
    func formattedScientific(decimalPlaces: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.positiveFormat = "0.#E+0"
        formatter.negativeFormat = "0.#E-0"
        formatter.exponentSymbol = "e"
        formatter.maximumFractionDigits = decimalPlaces
        if let formattedString = formatter.string(for: self) {
            return formattedString.replacingOccurrences(of: "e", with: " x10^")
        }
        return String(self)
    }
}
