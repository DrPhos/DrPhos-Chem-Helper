//
//  DrPhosResultBox.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 6/28/25.
//


import SwiftUI

struct DrPhosResultBox: View {
    var text: String
    var title: String = "Result"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).foregroundStyle(.secondary)
            Text(text).font(.title3.monospacedDigit()).textSelection(.enabled)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .accessibilityElement(children: .combine)
    }
}
