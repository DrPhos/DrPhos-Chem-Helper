//
//  CustomKeyboardToolbar.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 7/26/25.
//


import SwiftUI

struct CustomKeyboardToolbar: View {
    @Binding var activeField: Binding<String>?

    var body: some View {
    
            Spacer()
            
            Text("Sci. Notation: ")
            
            Button {
                if let activeField = activeField {
                    activeField.wrappedValue += "e"
                }
            } label: {
                Text("x10^")
            }
            .padding(.trailing, 10)
            
            Text("Negative: ")
            
            Button {
                if let activeField = activeField {
                    activeField.wrappedValue = NumericInputEditor.togglingSign(of: activeField.wrappedValue)
                }
            } label: {
                Text("(—)")
            }
            
            Spacer()
            
            Button {
                activeField = nil
                UIApplication.shared.endEditing()
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .imageScale(.medium)
            }
     
    }
}

enum NumericInputEditor {
    static func togglingSign(of value: String) -> String {
        if value.hasPrefix("-") {
            return String(value.dropFirst())
        }
        return "-" + value
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
