import SwiftUI
import Combine

struct ReactionDraftV1: Codable {
    static let currentVersion = 1

    enum Stage: String, Codable {
        case entering
        case balanced
        case calculated
    }

    struct DraftCompound: Codable {
        let id: UUID
        let formula: String
        let molarMass: Double
        let enteredGrams: String
        let calculatedGrams: String
        let excessGrams: String
        let enteredMoles: String
        let calculatedMoles: String
        let excessMoles: String
        let coefficient: Int
        let isReactant: Bool
        let parsedFormula: String
        let isLimiting: Bool
    }

    let version: Int
    let compounds: [DraftCompound]
    let stage: Stage
    let isBalanced: Bool
}

struct CombinedReactionView: View {
    @AppStorage("reactionWorkflowDraft.v1") private var reactionDraftData: Data = Data()
    @StateObject private var compoundsModel = CompoundsViewModel()
    @State private var compoundFormula = ""
    @State private var entrySide: ReactionSide?
    @State private var stage: ReactionWorkflowStage = .entering
    @State private var balanceError: String?
    @State private var stoichiometryError: String?
    @State private var activeAmountField: ReactionAmountField?
    @State private var isRestoringDraft = false

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

                HStack {
                    Button("Balance Reaction", action: balanceReaction)
                        .buttonStyle(.borderedProminent)
                        .tint(.seven)
                        .disabled(!canBalance)

                    if !compoundsModel.compounds.isEmpty {
                        Button("Clear Reaction", role: .destructive, action: clearReaction)
                            .buttonStyle(.bordered)
                    }
                }

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
                        activeAmountField: $activeAmountField,
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
        .onReceive(compoundsModel.$compounds.dropFirst()) { _ in
            saveDraft()
        }
        .onChange(of: stage) { _, _ in
            saveDraft()
        }
        .onAppear(perform: restoreDraft)
        .animation(.easeInOut(duration: 0.25), value: stage)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let activeAmountField, stage != .entering {
                reactionAmountKeypad(for: activeAmountField)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.18), value: activeAmountField)
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
        guard !isRestoringDraft else { return }
        guard stage != .entering || balanceError != nil else { return }
        compoundsModel.clearEnteredAndCalculatedValues()
        balanceError = nil
        stoichiometryError = nil
        activeAmountField = nil
        stage = .entering
    }

    private func calculateStoichiometry() {
        guard compoundsModel.prepareEnteredAmountsForStoichiometry() else {
            stoichiometryError = "Enter one or more positive amounts. Use either grams or moles for each compound."
            return
        }
        guard compoundsModel.calculateStoichiometry() else {
            stoichiometryError = "Enter a positive known amount before calculating."
            return
        }

        stoichiometryError = nil
        activeAmountField = nil
        stage = .calculated
    }

    private func clearAmounts() {
        compoundsModel.clearEnteredAndCalculatedValues()
        stoichiometryError = nil
        activeAmountField = nil
        stage = .balanced
    }

    private func clearReaction() {
        compoundsModel.clearCompounds()
        compoundFormula = ""
        entrySide = nil
        stage = .entering
        balanceError = nil
        stoichiometryError = nil
        activeAmountField = nil
        reactionDraftData = Data()
        UIApplication.shared.endEditing()
    }

    private func reactionAmountKeypad(for field: ReactionAmountField) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Editing \(field.kind.label) for \(formula(for: field.compoundID))")
                .font(.headline)

            CustomNumericKeypad(
                value: reactionAmountBinding(for: field, in: compoundsModel),
                isActive: Binding(
                    get: { activeAmountField != nil },
                    set: { if !$0 { activeAmountField = nil } }
                )
            )
            .id(field)
        }
        .frame(maxWidth: 680)
        .padding()
        .background(.regularMaterial)
        .overlay(alignment: .top) { Divider() }
        .shadow(color: .black.opacity(0.12), radius: 8, y: -2)
    }

    private func formula(for compoundID: UUID) -> String {
        compoundsModel.compounds.first(where: { $0.id == compoundID })?.formula ?? "compound"
    }

    private func saveDraft() {
        guard !isRestoringDraft else { return }
        guard !compoundsModel.compounds.isEmpty else {
            reactionDraftData = Data()
            return
        }

        let draft = ReactionDraftV1(
            version: ReactionDraftV1.currentVersion,
            compounds: compoundsModel.compounds.map { compound in
                ReactionDraftV1.DraftCompound(
                    id: compound.id,
                    formula: compound.formula,
                    molarMass: compound.molarMass,
                    enteredGrams: compound.enteredGrams,
                    calculatedGrams: compound.calculatedGrams,
                    excessGrams: compound.excessGrams,
                    enteredMoles: compound.enteredMoles,
                    calculatedMoles: compound.calculatedMoles,
                    excessMoles: compound.excessMoles,
                    coefficient: compound.coefficient,
                    isReactant: compound.isReactant,
                    parsedFormula: compound.parsedFormula,
                    isLimiting: compound.isLimiting
                )
            },
            stage: draftStage,
            isBalanced: stage != .entering
        )

        if let encoded = try? JSONEncoder().encode(draft) {
            reactionDraftData = encoded
        }
    }

    private func restoreDraft() {
        guard compoundsModel.compounds.isEmpty,
              !reactionDraftData.isEmpty,
              let draft = try? JSONDecoder().decode(ReactionDraftV1.self, from: reactionDraftData),
              draft.version == ReactionDraftV1.currentVersion,
              !draft.compounds.isEmpty else {
            return
        }

        isRestoringDraft = true
        compoundsModel.compounds = draft.compounds.map { saved in
            Compound(
                id: saved.id,
                formula: saved.formula,
                molarMass: saved.molarMass,
                enteredGrams: saved.enteredGrams,
                calculatedGrams: saved.calculatedGrams,
                excessGrams: saved.excessGrams,
                enteredMoles: saved.enteredMoles,
                calculatedMoles: saved.calculatedMoles,
                excessMoles: saved.excessMoles,
                coefficient: saved.coefficient,
                isReactant: saved.isReactant,
                parsedFormula: saved.parsedFormula,
                isLimiting: saved.isLimiting
            )
        }

        let restoredStage = workflowStage(for: draft)
        DispatchQueue.main.async {
            stage = restoredStage
            isRestoringDraft = false
        }
    }

    private var draftStage: ReactionDraftV1.Stage {
        switch stage {
        case .entering: return .entering
        case .balanced: return .balanced
        case .calculated: return .calculated
        }
    }

    private func workflowStage(for draft: ReactionDraftV1) -> ReactionWorkflowStage {
        guard draft.isBalanced else { return .entering }
        switch draft.stage {
        case .entering: return .entering
        case .balanced: return .balanced
        case .calculated: return .calculated
        }
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
                                Text(ChemicalFormulaFormatter.format(compound.formula))
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
                Text(ChemicalFormulaFormatter.format(compound.formula))
            }
            .font(.title3)
        }
    }
}

private struct StoichiometryWorkflowSection: View {
    @ObservedObject var compoundsModel: CompoundsViewModel
    let calculationComplete: Bool
    @Binding var activeAmountField: ReactionAmountField?
    let errorMessage: String?
    let calculate: () -> Void
    let clearAmounts: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Step 3")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Enter One or More Known Amounts")
                .font(.title2.weight(.semibold))
            Text("Use either grams or moles for each known compound. Multiple reactant amounts will determine the limiting reagent.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                ForEach(compoundsModel.compounds) { compound in
                    StoichiometryAmountRow(
                        compound: compound,
                        calculationComplete: calculationComplete,
                        activeAmountField: $activeAmountField
                    )
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

}

private struct StoichiometryAmountRow: View {
    let compound: Compound
    let calculationComplete: Bool
    @Binding var activeAmountField: ReactionAmountField?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(compound.coefficient) \(ChemicalFormulaFormatter.format(compound.formula))")
                    .font(.headline)
                Spacer()
                Text(String(format: "%.2f g/mol", compound.molarMass))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                amountButton(kind: .grams, value: compound.enteredGrams, unit: "g")
                amountButton(kind: .moles, value: compound.enteredMoles, unit: "mol")
            }

            if calculationComplete {
                Text("Calculated: \(compound.calculatedGrams) g • \(compound.calculatedMoles) mol")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if compound.isReactant && compound.isLimiting {
                    Label("Limiting reagent", systemImage: "checkmark.circle.fill")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.green)
                }

                if compound.isReactant && (!compound.excessGrams.isEmpty || !compound.excessMoles.isEmpty) {
                    Text("Excess remaining: \(compound.excessGrams) g • \(compound.excessMoles) mol")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 10))
    }

    private func amountButton(kind: StoichiometryAmountKind, value: String, unit: String) -> some View {
        let field = ReactionAmountField(compoundID: compound.id, kind: kind)
        return Button {
            activeAmountField = field
        } label: {
            HStack {
                Text(value.isEmpty ? kind.label : value)
                    .font(.body.monospacedDigit())
                    .foregroundStyle(value.isEmpty ? .secondary : .primary)
                Spacer(minLength: 6)
                Text(unit)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(.background, in: RoundedRectangle(cornerRadius: 7))
            .overlay {
                RoundedRectangle(cornerRadius: 7)
                    .stroke(activeAmountField == field ? Color.accentColor : Color.secondary.opacity(0.35), lineWidth: 1.5)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(calculationComplete)
        .accessibilityLabel("\(kind.label) for \(compound.formula)")
        .accessibilityValue(value.isEmpty ? "Empty" : value)
    }
}

private struct ReactionAmountField: Hashable {
    let compoundID: UUID
    let kind: StoichiometryAmountKind
}

private extension StoichiometryAmountKind {
    var label: String {
        switch self {
        case .grams: "grams"
        case .moles: "moles"
        }
    }
}

private func reactionAmountBinding(
    for field: ReactionAmountField,
    in compoundsModel: CompoundsViewModel
) -> Binding<String> {
    Binding(
        get: {
            guard let compound = compoundsModel.compounds.first(where: { $0.id == field.compoundID }) else {
                return ""
            }
            return field.kind == .grams ? compound.enteredGrams : compound.enteredMoles
        },
        set: { newValue in
            guard let index = compoundsModel.compounds.firstIndex(where: { $0.id == field.compoundID }) else {
                return
            }
            switch field.kind {
            case .grams:
                compoundsModel.compounds[index].enteredGrams = newValue
            case .moles:
                compoundsModel.compounds[index].enteredMoles = newValue
            }
        }
    )
}

#Preview {
    CombinedReactionView()
}
