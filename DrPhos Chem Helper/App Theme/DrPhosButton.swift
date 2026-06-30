//
//  DrPhosButton.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 6/28/25.
//


import SwiftUI

struct DrPhosButton: View {
    var title: String
    var systemImage: String? = nil
    var backgroundColor: Color = AppTheme.enterButtonColor
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(AppTheme.standardFont())
            }
            .frame(minHeight: 44)
            .padding(.horizontal, 5)
            .background(backgroundColor)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.numbers, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

}

struct DrPhosButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            DrPhosButton(title: "Enter", backgroundColor: AppTheme.enterButtonColor) {
                print("Enter tapped")
            }

            DrPhosButton(title: "Clear", systemImage: "xmark", backgroundColor: AppTheme.clearButtonColor) {
                print("Clear tapped")
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
