import SwiftUI

struct CombinedReactionView: View {
    @StateObject private var compoundsModel = CompoundsViewModel()
    @State private var compoundFormula = ""
    @State private var entrySide: ReactionSide?
    @State private var stage: ReactionWorkflowStage = .entering
    @State private var balanceError: String?
    @State private var stoichiometryError: String?
    @State private var isEditingAmount = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DrPhosSectionHeader(title: "Reaction Workflow")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Step 1")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("Enter the Reaction")
                        .font(.title2.weight(.semibold))
                    Text("Add every reactant and product before balancing.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    Button("Add Reactant") {
                        beginEntry(on: .reactant)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Add Product") {
                        beginEntry(on: .product)
                    }
                    .buttonStyle(.borderedProminent)
                }

                ReactionCompoundList(
                    compounds: compoundsModel.compounds,
                    removeCompound: compoundsModel.removeCompound
                )

                Button("Balance Reaction", action: balanceReaction)
                    .buttonStyle(.borderedProminent)
                    .tint(.seven)
                    .disabled(!canBalance)

                if let balanceError {
                    Text(balanceError)
                        .font(.callout)
                        .foregroundStyle(.red)
                }

                if stage != .entering {
                    BalancedReactionSection(compounds: compoundsModel.compounds)
                        .transition(.move(edge: .top).combined(with: .opacity))

                    StoichiometryWorkflowSection(
                        compoundsModel: compoundsModel,
                        calculationComplete: stage == .calculated,
                        isEditingAmount: $isEditingAmount,
                        errorMessage: stoichiometryError,
                        calculate: calculateStoichiometry,
                        clearAmounts: clearAmounts
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .frame(maxWidth: 680)
            .padding()
        }
        .sheet(item: $entrySide) { side in
            CompoundEntry(
                compoundFormula: $compoundFormula,
                isPresented: Binding(
                    get: { entrySide != nil },
                    set: { if !$0 { entrySide = nil } }
                ),
                onEnter: { addCompound(on: side) }
            )
        }
        .onChange(of: reactionSignature) { oldValue, newValue in
            guard oldValue != newValue else { return }
            invalidateBalance()
        }
        .animation(.easeInOut(duration: 0.25), value: stage)
    }

    private var canBalance: Bool {
        compoundsModel.compounds.contains(where: \.isReactant)
            && compoundsModel.compounds.contains(where: { !$0.isReactant })
    }

    private var reactionSignature: [ReactionTermSignature] {
        compoundsModel.compounds.map {
            ReactionTermSignature(id: $0.id, formula: $0.formula, isReactant: $0.isReactant)
        }
    }

    private func beginEntry(on side: ReactionSide) {
        compoundFormula = ""
        entrySide = side
    }

    private func addCompound(on side: ReactionSide) {
        switch side {
        case .reactant:
            compoundsModel.addReactant(formula: compoundFormula)
        case .product:
            compoundsModel.addProduct(formula: compoundFormula)
        }
        compoundFormula = ""
    }

    private func balanceReaction() {
        guard let coefficients = ReactionBalancingEngine().coefficients(for: compoundsModel.compounds) else {
            balanceError = "This reaction could not be balanced. Check each formula and try again."
            stage = .entering
            return
        }

        compoundsModel.applyCoefficients(coefficients)
        balanceError = nil
        stoichiometryError = nil
        stage = .balanced
    }

    private func invalidateBalance() {
        guard stage != .entering || balanceError != nil else { return }
        compoundsModel.clearEnteredAndCalculatedValues()
        balanceError = nil
        stoichiometryError = nil
        isEditingAmount = false
        stage = .entering
    }

    private func calculateStoichiometry() {
        let knownAmounts = compoundsModel.compounds.flatMap { compound -> [StoichiometryAmountKind] in
            var kinds: [StoichiometryAmountKind] = []
            if let grams = Double(compound.enteredGrams), grams.isFinite, grams > 0 {
                kinds.append(.grams)
            }
            if let moles = Double(compound.enteredMoles), moles.isFinite, moles > 0 {
                kinds.append(.moles)
            }
            return kinds
        }

        guard knownAmounts.count == 1, let inputKind = knownAmounts.first else {
            stoichiometryError = "Enter exactly one known amount in either grams or moles."
            return
        }

        let inputMode: StoichiometryView.InputMode = inputKind == .grams ? .grams : .moles
        compoundsModel.recordEnteredAmounts(inputMode: inputMode)
        guard compoundsModel.calculateStoichiometry() else {
            stoichiometryError = "Enter a positive known amount before calculating."
            return
        }

        stoichiometryError = nil
        isEditingAmount = false
        UIApplication.shared.endEditing()
        stage = .calculated
    }

    private func clearAmounts() {
        compoundsModel.clearEnteredAndCalculatedValues()
        stoichiometryError = nil
        isEditingAmount = false
        UIApplication.shared.endEditing()
        stage = .balanced
    }
}

private enum ReactionWorkflowStage: Equatable {
    case entering
    case balanced
    case calculated
}

private struct ReactionTermSignature: Equatable {
    let id: UUID
    let formula: String
    let isReactant: Bool
}

private enum ReactionSide: String, Identifiable {
    case reactant
    case product

    var id: Self { self }
}

private struct ReactionCompoundList: View {
    let compounds: [Compound]
    let removeCompound: (UUID) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ReactionSideRow(
                title: "Reactants",
                compounds: compounds.filter(\.isReactant),
                removeCompound: removeCompound
            )

            Image(systemName: "arrow.down")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)

            ReactionSideRow(
                title: "Products",
                compounds: compounds.filter { !$0.isReactant },
                removeCompound: removeCompound
            )
        }
    }
}

private struct ReactionSideRow: View {
    let title: String
    let compounds: [Compound]
    let removeCompound: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            if compounds.isEmpty {
                Text("None added")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(compounds) { compound in
                            HStack(spacing: 8) {
                                Text(compound.formula)
                                    .font(.headline)
                                Button {
                                    removeCompound(compound.id)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(.red)
                                .accessibilityLabel("Remove \(compound.formula)")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.phostext.opacity(0.45))
        )
    }
}

private struct BalancedReactionSection: View {
    let compounds: [Compound]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Step 2")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Balanced Reaction")
                .font(.title2.weight(.semibold))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    equationTerms(compounds.filter(\.isReactant))
                    Image(systemName: "arrow.right")
                        .font(.headline)
                    equationTerms(compounds.filter { !$0.isReactant })
                }
                .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.seven.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func equationTerms(_ compounds: [Compound]) -> some View {
        ForEach(Array(compounds.enumerated()), id: \.element.id) { index, compound in
            if index > 0 {
                Text("+")
            }
            HStack(spacing: 3) {
                Text("\(compound.coefficient)")
                    .fontWeight(.semibold)
                Text(compound.formula)
            }
            .font(.title3)
        }
    }
}

private struct StoichiometryWorkflowSection: View {
    @ObservedObject var compoundsModel: CompoundsViewModel
    let calculationComplete: Bool
    @Binding var isEditingAmount: Bool
    let errorMessage: String?
    let calculate: () -> Void
    let clearAmounts: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Step 3")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Enter One Known Amount")
                .font(.title2.weight(.semibold))
            Text("Use either grams or moles for one compound, then calculate the remaining amounts.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                ForEach(compoundsModel.compounds) { compound in
                    StoichiometryAmountRow(
                        compound: compound,
                        grams: amountBinding(for: compound.id, kind: .grams),
                        moles: amountBinding(for: compound.id, kind: .moles),
                        calculationComplete: calculationComplete,
                        isEditingAmount: $isEditingAmount
                    )
                }
            }

            if isEditingAmount {
                HStack {
                    Spacer()
                    Button("Done") {
                        isEditingAmount = false
                        UIApplication.shared.endEditing()
                    }
                    .buttonStyle(.bordered)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(.red)
            }

            HStack {
                Button("Calculate Stoichiometry", action: calculate)
                    .buttonStyle(.borderedProminent)
                    .disabled(calculationComplete)

                Button("Clear Amounts", action: clearAmounts)
                    .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.phosblue1.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private func amountBinding(for compoundID: UUID, kind: StoichiometryAmountKind) -> Binding<String> {
        Binding(
            get: {
                guard let compound = compoundsModel.compounds.first(where: { $0.id == compoundID }) else {
                    return ""
                }
                return kind == .grams ? compound.enteredGrams : compound.enteredMoles
            },
            set: { newValue in
                guard isValidAmountInput(newValue),
                      let index = compoundsModel.compounds.firstIndex(where: { $0.id == compoundID }) else {
                    return
                }
                switch kind {
                case .grams:
                    compoundsModel.compounds[index].enteredGrams = newValue
                case .moles:
                    compoundsModel.compounds[index].enteredMoles = newValue
                }
            }
        )
    }

    private func isValidAmountInput(_ value: String) -> Bool {
        if value.isEmpty { return true }
        var decimalCount = 0
        for character in value {
            if character == "." {
                decimalCount += 1
                if decimalCount > 1 { return false }
            } else if !character.isNumber {
                return false
            }
        }
        return true
    }
}

private struct StoichiometryAmountRow: View {
    let compound: Compound
    @Binding var grams: String
    @Binding var moles: String
    let calculationComplete: Bool
    @Binding var isEditingAmount: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(compound.coefficient) \(compound.formula)")
                    .font(.headline)
                Spacer()
                Text(String(format: "%.2f g/mol", compound.molarMass))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                TextField("grams", text: $grams, onEditingChanged: { isEditingAmount = $0 })
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .disabled(calculationComplete)
                Text("g")

                TextField("moles", text: $moles, onEditingChanged: { isEditingAmount = $0 })
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .disabled(calculationComplete)
                Text("mol")
            }

            if calculationComplete {
                Text("Calculated: \(compound.calculatedGrams) g • \(compound.calculatedMoles) mol")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    CombinedReactionView()
}
