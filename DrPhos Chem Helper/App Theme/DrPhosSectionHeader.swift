//
//  DrPhosSectionHeader.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 6/28/25.
//


import SwiftUI

struct DrPhosSectionHeader: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.largeTitle.bold())
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
        
    }
}
