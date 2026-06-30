//
//  NumbersView.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 6/29/25.
//
import SwiftUI

struct NumbersView: View {
    let numberOfRows = 1
    let numberOfColumns = 11
    let buttonWidth: CGFloat = 30
    
    let buttonLabels: [[String]] = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "⌫"]
    ]
    
    @Binding var compoundFormula: String
    
    func handleButtonTap(_ buttonLabel: String) {
        if buttonLabel == "⌫" {
            compoundFormula = String(compoundFormula.dropLast())
        } else {
            compoundFormula += buttonLabel
        }
    }
    
    var body: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(buttonWidth), spacing: 2), count: numberOfColumns), spacing: 1) {
                ForEach(0..<numberOfRows, id: \.self) { row in
                    ForEach(0..<numberOfColumns, id: \.self) { column in
                        let buttonLabel = buttonLabels[row][column]
                        if buttonLabel.isEmpty {
                            Color.clear.frame(width: buttonWidth, height: 40).hidden()
                        } else {
                            Button(action: { handleButtonTap(buttonLabel) }) {
                                Group {
                                    if buttonLabel == "⌫" {
                                        Image(systemName: "delete.left")
                                    } else {
                                        Text(buttonLabel)
                                    }
                                }
                                .frame(width: buttonWidth, height: 30)
                                .background(Color.numbers)
                                .foregroundColor(.numberstext)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
            }
        }
    }
}


struct NumbersSecondRowView: View {
    @Binding var compoundFormula: String
    let buttonWidth: CGFloat = 45
    
    func handleButtonTap(_ label: String) {
        if label == "x10^" {
            compoundFormula += "e"
        } else {
            compoundFormula += label
        }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach([".", "-", "x10^"], id: \.self) { label in
                Button(action: { handleButtonTap(label) }) {
                    Text(label)
                        .frame(width: buttonWidth, height: 30)
                        .background(Color.numbers)
                        .foregroundColor(.numberstext)
                        .cornerRadius(10)
                }
            }
        }
    }
}
