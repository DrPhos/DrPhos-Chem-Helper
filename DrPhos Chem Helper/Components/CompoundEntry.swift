//
//  DrPhosCompoundEntry.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 6/29/25.
//


import SwiftUI

struct CompoundEntry: View {
    @Binding var compoundFormula: String
    @Binding var isPresented: Bool
    @AppStorage("recentCompounds") private var recentCompoundsData: Data = Data()
    @State private var recentCompounds: [String] = []
    var onEnter: () -> Void = {}

    init(compoundFormula: Binding<String>, isPresented: Binding<Bool>, onEnter: @escaping () -> Void = {}) {
        _compoundFormula = compoundFormula
        _isPresented = isPresented
        self.onEnter = onEnter
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    DrPhosTextField(title: "Compound", text: $compoundFormula)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 1)
                        .overlay(
                            HStack {
                                Spacer()
                                if !compoundFormula.isEmpty {
                                    Button(action: {
                                        compoundFormula = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.numbers)
                                    }
                                    .padding(.trailing, 10)
                                }
                            }
                        )
                        .accessibilityLabel("Chemical formula or compound name")

                    DrPhosButton(title: "Enter", backgroundColor: AppTheme.enterButtonColor) {
                        if !compoundFormula.isEmpty {
                            recentCompounds.removeAll(where: { $0 == compoundFormula })
                            recentCompounds.insert(compoundFormula, at: 0)
                            recentCompounds = Array(recentCompounds.prefix(5))
                            if let encoded = try? JSONEncoder().encode(recentCompounds) {
                                recentCompoundsData = encoded
                            }
                            onEnter()
                            isPresented = false
                        }
                    }
                }

                NumbersView(compoundFormula: $compoundFormula)
                PeriodicTableView(compoundFormula: $compoundFormula)
                    .accessibilityLabel("Periodic table element picker")
                
                Divider()
                    .padding(.top, 10)

                if !recentCompounds.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(recentCompounds, id: \.self) { compound in
                                Button(action: {
                                    compoundFormula = compound
                                }) {
                                    Text(compound)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.numbers)
                                        .foregroundColor(.numberstext)
                                        .cornerRadius(8)
                                }
                                .accessibilityLabel("Use recent entry \(compound)")
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
            .onAppear {
                if let saved = try? JSONDecoder().decode([String].self, from: recentCompoundsData) {
                    recentCompounds = saved
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    CompoundEntry(compoundFormula: .constant(""), isPresented: .constant(true), onEnter: {})
}
