//
//  DrPhosTextField.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 6/28/25.
//


import SwiftUI

struct DrPhosTextField: View {
    var title: String
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding? = nil

    var body: some View {
        TextField(title, text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(minHeight: 44)
            .font(AppTheme.standardFont())
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.numbers, lineWidth: 1)
            )
            .applyFocus(isFocused)
    }
}

extension View {
    @ViewBuilder
    func applyFocus(_ binding: FocusState<Bool>.Binding?) -> some View {
        if let binding = binding {
            self.focused(binding)
        } else {
            self
        }
    }
}
