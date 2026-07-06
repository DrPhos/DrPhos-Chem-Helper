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
    @State private var showingClearReactionConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.sectionSpacing) {
                DrPhosSectionHeader(title: "Reaction Workflow")

                WorkflowStepCard(
                    step: 1,
                    title: "Enter the Reaction",
                    detail: "Add every reactant and product, then balance the equation.",
                    status: stage == .entering ? .current : .complete
                ) {
                    ReactionCompoundList(
                        compounds: compoundsModel.compounds,
                        addReactant: { beginEntry(on: .reactant) },
                        addProduct: { beginEntry(on: .product) },
                        removeCompound: { id in
                            withAnimation(.easeOut(duration: 0.16)) {
                                compoundsModel.removeCompound(id: id)
                            }
                        }
                    )

                    Button(action: balanceReaction) {
                        Label("Balance Reaction", systemImage: "arrow.triangle.2.circlepath")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.seven)
                    .disabled(!canBalance)

                    if let balanceError {
                        WorkflowErrorMessage(message: balanceError)
                    }

                    if !compoundsModel.compounds.isEmpty {
                        Button("Start New Reaction", role: .destructive) {
                            showingClearReactionConfirmation = true
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
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
            .frame(maxWidth: AppTheme.readableContentWidth)
            .padding(AppTheme.screenPadding)
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
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let activeAmountField, stage != .entering {
                reactionAmountKeypad(for: activeAmountField)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.18), value: activeAmountField)
        .confirmationDialog(
            "Start a New Reaction?",
            isPresented: $showingClearReactionConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear Current Reaction", role: .destructive, action: clearReaction)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the current reaction, amounts, results, and saved draft.")
        }
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
        withAnimation(.easeOut(duration: 0.16)) {
            switch side {
            case .reactant:
                compoundsModel.addReactant(formula: compoundFormula)
            case .product:
                compoundsModel.addProduct(formula: compoundFormula)
            }
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
        withAnimation(.easeInOut(duration: 0.25)) {
            stage = .balanced
        }
    }

    private func invalidateBalance() {
        guard !isRestoringDraft else { return }
        guard stage != .entering || balanceError != nil else { return }
        compoundsModel.clearEnteredAndCalculatedValues()
        balanceError = nil
        stoichiometryError = nil
        activeAmountField = nil
        withAnimation(.easeInOut(duration: 0.2)) {
            stage = .entering
        }
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
        withAnimation(.easeInOut(duration: 0.22)) {
            stage = .calculated
        }
    }

    private func clearAmounts() {
        compoundsModel.clearEnteredAndCalculatedValues()
        stoichiometryError = nil
        activeAmountField = nil
        withAnimation(.easeInOut(duration: 0.18)) {
            stage = .balanced
        }
    }

    private func clearReaction() {
        withAnimation(.easeInOut(duration: 0.2)) {
            compoundsModel.clearCompounds()
            compoundFormula = ""
            entrySide = nil
            stage = .entering
            balanceError = nil
            stoichiometryError = nil
            activeAmountField = nil
        }
        reactionDraftData = Data()
        UIApplication.shared.endEditing()
    }

    private func reactionAmountKeypad(for field: ReactionAmountField) -> some View {
        let amount = reactionAmountBinding(for: field, in: compoundsModel)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Text("Editing \(field.kind.label) for \(ChemicalFormulaFormatter.format(formula(for: field.compoundID)))")
                    .font(.headline)
                Spacer()
                Text(amount.wrappedValue.isEmpty ? "—" : amount.wrappedValue)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(amount.wrappedValue.isEmpty ? .secondary : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            CustomNumericKeypad(
                value: amount,
                isActive: Binding(
                    get: { activeAmountField != nil },
                    set: { if !$0 { activeAmountField = nil } }
                ),
                showsDisplay: false
            )
            .id(field)
        }
        .frame(maxWidth: 560)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(Color.secondary.opacity(0.2))
        }
        .shadow(color: .black.opacity(0.12), radius: 8, y: -2)
        .padding(.horizontal, 8)
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

private enum WorkflowStepStatus {
    case current
    case complete
}

private struct WorkflowStepCard<Content: View>: View {
    let step: Int
    let title: String
    let detail: String?
    let status: WorkflowStepStatus
    let content: Content

    init(
        step: Int,
        title: String,
        detail: String? = nil,
        status: WorkflowStepStatus,
        @ViewBuilder content: () -> Content
    ) {
        self.step = step
        self.title = title
        self.detail = detail
        self.status = status
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(status == .complete ? Color.green : Color.accentColor)
                    if status == .complete {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    } else {
                        Text("\(step)")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Step \(step)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(title)
                        .font(.title2.weight(.semibold))
                    if let detail {
                        Text(detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}

private struct WorkflowErrorMessage: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.callout)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
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
    let addReactant: () -> Void
    let addProduct: () -> Void
    let removeCompound: (UUID) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ReactionSideRow(
                title: "Reactants",
                compounds: compounds.filter(\.isReactant),
                addCompound: addReactant,
                removeCompound: removeCompound
            )

            Image(systemName: "arrow.down")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)

            ReactionSideRow(
                title: "Products",
                compounds: compounds.filter { !$0.isReactant },
                addCompound: addProduct,
                removeCompound: removeCompound
            )
        }
    }
}

private struct ReactionSideRow: View {
    let title: String
    let compounds: [Compound]
    let addCompound: () -> Void
    let removeCompound: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Button(action: addCompound) {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityLabel("Add \(title.dropLast())")
            }

            if compounds.isEmpty {
                Text("Add at least one \(title.dropLast().lowercased()).")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
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
                                        .frame(width: 32, height: 32)
                                        .contentShape(Rectangle())
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
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3))
        )
    }
}

private struct BalancedReactionSection: View {
    let compounds: [Compound]

    var body: some View {
        WorkflowStepCard(
            step: 2,
            title: "Balanced Reaction",
            detail: "Use these coefficients for the stoichiometry calculation.",
            status: .complete
        ) {
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
    @State private var displayedDecimalPlaces = 2

    var body: some View {
        WorkflowStepCard(
            step: 3,
            title: calculationComplete ? "Stoichiometry Results" : "Enter Known Amounts",
            detail: "Enter grams or moles for one or more compounds. Multiple reactants determine the limiting reagent.",
            status: calculationComplete ? .complete : .current
        ) {
            AmountGroup(
                title: "Reactants",
                compounds: compoundsModel.compounds.filter(\.isReactant),
                calculationComplete: calculationComplete,
                displayedDecimalPlaces: displayedDecimalPlaces,
                activeAmountField: $activeAmountField
            )

            AmountGroup(
                title: "Products",
                compounds: compoundsModel.compounds.filter { !$0.isReactant },
                calculationComplete: calculationComplete,
                displayedDecimalPlaces: displayedDecimalPlaces,
                activeAmountField: $activeAmountField
            )

            if let errorMessage {
                WorkflowErrorMessage(message: errorMessage)
            }

            VStack(spacing: 10) {
                Button(action: calculate) {
                    Label("Calculate Stoichiometry", systemImage: "equal.circle")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                    .buttonStyle(.borderedProminent)
                    .disabled(calculationComplete)

                HStack {
                    if calculationComplete {
                        decimalAdjustmentButtons
                    }

                    Spacer()

                    Button("Clear Amounts", action: clearAmounts)
                        .buttonStyle(.bordered)
                }
            }
        }
    }

    private var decimalAdjustmentButtons: some View {
        HStack(spacing: 4) {
            Button {
                if displayedDecimalPlaces < 6 {
                    displayedDecimalPlaces += 1
                }
            } label: {
                Image(systemName: "plus.circle")
            }
            .buttonStyle(.plain)
            .disabled(displayedDecimalPlaces == 6)

            Text("Decimals")
                .font(.caption2)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Button {
                if displayedDecimalPlaces > 0 {
                    displayedDecimalPlaces -= 1
                }
            } label: {
                Image(systemName: "minus.circle")
            }
            .buttonStyle(.plain)
            .disabled(displayedDecimalPlaces == 0)
        }
        .foregroundStyle(Color.numbers)
    }

}

private struct AmountGroup: View {
    let title: String
    let compounds: [Compound]
    let calculationComplete: Bool
    let displayedDecimalPlaces: Int
    @Binding var activeAmountField: ReactionAmountField?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(compounds) { compound in
                    StoichiometryAmountRow(
                        compound: compound,
                        calculationComplete: calculationComplete,
                        displayedDecimalPlaces: displayedDecimalPlaces,
                        activeAmountField: $activeAmountField
                    )
                }
            }
        }
        .padding(12)
        .background(
            (title == "Reactants" ? Color.orange : Color.blue).opacity(0.06),
            in: RoundedRectangle(cornerRadius: 10)
        )
    }
}

private struct StoichiometryAmountRow: View {
    let compound: Compound
    let calculationComplete: Bool
    let displayedDecimalPlaces: Int
    @Binding var activeAmountField: ReactionAmountField?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("\(compound.coefficient)")
                    .font(.headline.bold())
                    .foregroundStyle(.black)
                    .underline()

                Text(ChemicalFormulaFormatter.format(compound.formula))
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    .layoutPriority(1)

                Spacer(minLength: 8)

                Text(String(format: "%.2f g/mol", compound.molarMass))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }

            HStack(alignment: .top, spacing: 12) {
                amountField(
                    title: "Grams",
                    kind: .grams,
                    value: compound.enteredGrams
                )
                amountField(
                    title: "Moles",
                    kind: .moles,
                    value: compound.enteredMoles
                )
            }

            if calculationComplete {
                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Calculated Amounts")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)

                    HStack(alignment: .top, spacing: 12) {
                        resultField(
                            title: "Grams",
                            value: compound.calculatedGrams,
                            unit: "g"
                        )
                        resultField(
                            title: "Moles",
                            value: compound.calculatedMoles,
                            unit: "mol"
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    if compound.isReactant && compound.isLimiting {
                        resultBadge(
                            "Limiting: \(formattedResult(compound.enteredGrams)) g / \(formattedResult(compound.enteredMoles)) mol",
                            systemImage: "checkmark.circle.fill",
                            color: .green
                        )
                    }
                    if compound.isReactant && (!compound.excessGrams.isEmpty || !compound.excessMoles.isEmpty) {
                        resultBadge(
                            "Excess: \(formattedResult(compound.excessGrams)) g / \(formattedResult(compound.excessMoles)) mol",
                            systemImage: "arrow.down.circle.fill",
                            color: .orange
                        )
                    }
                }
            }
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 10))
    }

    private func amountField(
        title: String,
        kind: StoichiometryAmountKind,
        value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            amountButton(kind: kind, value: value)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func amountButton(kind: StoichiometryAmountKind, value: String) -> some View {
        let field = ReactionAmountField(compoundID: compound.id, kind: kind)
        return Button {
            activeAmountField = field
        } label: {
            Text(displayedAmount(value))
                    .font(.body.monospacedDigit())
                    .foregroundStyle(value.isEmpty ? .secondary : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
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

    private func displayedAmount(_ value: String) -> String {
        guard !value.isEmpty else { return "Enter" }
        guard calculationComplete else { return value }
        return formattedResult(value)
    }

    private func resultField(title: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value.isEmpty ? "—" : "\(formattedResult(value)) \(unit)")
                .font(.footnote.weight(.semibold).monospacedDigit())
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formattedResult(_ value: String) -> String {
        guard let number = Double(value), number.isFinite else { return "—" }
        return String(format: "%.*f", displayedDecimalPlaces, number)
    }

    private func resultBadge(_ title: String, systemImage: String, color: Color) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(color.opacity(0.1), in: Capsule())
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
