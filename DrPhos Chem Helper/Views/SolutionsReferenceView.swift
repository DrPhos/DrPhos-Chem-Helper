import SwiftUI

struct SolutionsView: View {
    @State private var problemType: SolutionWorkflowProblem = .percent
    @State private var percentType: PercentConcentrationType = .massMass
    @State private var activeField: SolutionInputField?

    @State private var concentration = ""
    @State private var soluteAmount = ""
    @State private var solutionAmount = ""
    @State private var c1 = ""
    @State private var v1 = ""
    @State private var c2 = ""
    @State private var v2 = ""

    @State private var decimalPlaces = 2
    @State private var result: SolutionsResult?
    @State private var validationMessage: String?

    private var engineProblemType: SolutionProblemType {
        switch problemType {
        case .percent:
            percentType.engineProblemType
        case .molarity:
            .molarity
        case .dilution:
            .dilution
        }
    }

    private var equationFields: [SolutionInputField] {
        switch problemType {
        case .percent, .molarity:
            [.concentration, .soluteAmount, .solutionAmount]
        case .dilution:
            [.c1, .v1, .c2, .v2]
        }
    }

    var body: some View {
        DrPhosCalculatorScreen(
            title: "Solution Concentrations",
            instructions: "Choose a solution equation, fill in the known values, and leave the unknown blank."
        ) {
            equationTypeSection
            equationSection
            actionSection
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let activeField {
                numericKeypad(for: activeField)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.18), value: activeField)
        .animation(.easeInOut(duration: 0.2), value: problemType)
        .animation(.easeInOut(duration: 0.22), value: result?.value)
    }

    private var equationTypeSection: some View {
        DrPhosCalculatorSection(title: "Choose equation") {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Problem type", selection: $problemType) {
                    ForEach(SolutionWorkflowProblem.allCases) { problem in
                        Text(problem.description).tag(problem)
                    }
                }
                .pickerStyle(.segmented)

                if problemType == .percent {
                    Picker("Percent type", selection: $percentType) {
                        ForEach(PercentConcentrationType.allCases) { type in
                            Text(type.description).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Text(problemType.guidance)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .onChange(of: problemType) { _, _ in
                clearForEquationChange()
            }
            .onChange(of: percentType) { _, _ in
                clearCalculation()
            }
        }
    }

    private var equationSection: some View {
        VStack(alignment: .center, spacing: 18) {
            Text(equationTitle)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            switch problemType {
            case .percent:
                percentEquation
            case .molarity:
                molarityEquation
            case .dilution:
                dilutionEquation
            }

            if let validationMessage {
                DrPhosValidationMessage(message: validationMessage)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private var actionSection: some View {
        DrPhosCalculatorSection {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 12) {
                    DrPhosActionButton("Calculate", systemImage: "equal", action: calculate)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    DrPhosDecimalControl(value: $decimalPlaces, range: 0...6)
                        .fixedSize(horizontal: true, vertical: false)
                }

                HStack {
                    Spacer()

                    DrPhosActionButton("Clear", systemImage: "xmark", style: .destructive, action: clearAll)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .frame(maxWidth: 180)
                }
            }
        }
    }

    private var percentEquation: some View {
        VStack(spacing: 18) {
            HStack(alignment: .center, spacing: 12) {
                equationTerm(
                    field: .concentration,
                    label: percentType.equationLabel
                )
                    .frame(maxWidth: 120)

                Text("=")
                    .font(.largeTitle.weight(.semibold))

                VStack(spacing: 8) {
                    equationTerm(
                        field: .soluteAmount,
                        label: engineProblemType.soluteUnit
                    )
                    Rectangle()
                        .fill(Color.primary.opacity(0.75))
                        .frame(height: 1.5)
                    equationTerm(
                        field: .solutionAmount,
                        label: engineProblemType.solutionUnit
                    )
                }
                .frame(maxWidth: 220)

                Text("× 100")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var molarityEquation: some View {
        VStack(spacing: 18) {
            HStack(alignment: .center, spacing: 12) {
                equationTerm(
                    field: .concentration,
                    label: "M"
                )
                    .frame(maxWidth: 120)

                Text("=")
                    .font(.largeTitle.weight(.semibold))

                VStack(spacing: 8) {
                    equationTerm(
                        field: .soluteAmount,
                        label: "mol solute"
                    )
                    Rectangle()
                        .fill(Color.primary.opacity(0.75))
                        .frame(height: 1.5)
                    equationTerm(
                        field: .solutionAmount,
                        label: "L solution"
                    )
                }
                .frame(maxWidth: 240)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var dilutionEquation: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 8) {
                groupedEquationInput(.c1)
                groupedEquationInput(.v1)

                Text("=")
                    .font(.largeTitle.weight(.semibold))
                    .padding(.horizontal, 2)

                groupedEquationInput(.c2)
                groupedEquationInput(.v2)
            }
            .padding(.vertical, 4)
        }
    }

    private func groupedEquationInput(_ field: SolutionInputField) -> some View {
        VStack(spacing: 5) {
            HStack(spacing: 3) {
                Text("(")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)
                equationInputBox(for: field)
                    .frame(width: 116)
                Text(")")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            equationUnitLabel(field.shortSymbol(for: engineProblemType))
        }
    }

    private func equationTerm(field: SolutionInputField, label: String) -> some View {
        VStack(spacing: 5) {
            equationInputBox(for: field)
            equationUnitLabel(label)
        }
    }

    private func equationInputBox(for field: SolutionInputField) -> some View {
        Button {
            activeField = field
            if result?.unknown == field.unknown {
                result = nil
                binding(for: field).wrappedValue = ""
            } else {
                clearCalculation()
                activeField = field
            }
        } label: {
            Text(equationDisplayText(for: field))
                .font(inputValueFont(for: field))
                .foregroundStyle(inputValueColor(for: field))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .frame(maxWidth: .infinity, minHeight: 42)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(inputBackground(for: field), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(inputBorderColor(for: field), lineWidth: inputBorderWidth(for: field))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(field.title(for: engineProblemType))
        .accessibilityValue(equationDisplayText(for: field))
    }

    private func equationUnitLabel(_ label: String) -> some View {
        Text(label)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.75)
    }

    private func numericKeypad(for field: SolutionInputField) -> some View {
        let value = binding(for: field)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Editing \(field.title(for: engineProblemType).lowercased())")
                    .font(.headline)
                Spacer()
                Text(value.wrappedValue.isEmpty ? "—" : value.wrappedValue)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(value.wrappedValue.isEmpty ? .secondary : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            CustomNumericKeypad(
                value: value,
                isActive: Binding(
                    get: { activeField != nil },
                    set: { if !$0 { activeField = nil } }
                ),
                showsDisplay: false
            )
            .id(field)
            .onChange(of: value.wrappedValue) { _, _ in
                result = nil
                validationMessage = nil
            }
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

    private var equationTitle: String {
        switch problemType {
        case .percent:
            "Percent Composition"
        case .molarity:
            "Molarity"
        case .dilution:
            "Dilution"
        }
    }

    private func equationDisplayText(for field: SolutionInputField) -> String {
        if result?.unknown == field.unknown {
            return formattedNumber(result?.value) ?? "Invalid"
        }

        let text = binding(for: field).wrappedValue
        guard !text.isEmpty else {
            return field.placeholder(for: engineProblemType)
        }

        if activeField == field {
            return text
        }

        return formattedNumber(CustomNumericInputEditor.parsedFiniteValue(from: text)) ?? text
    }

    private func formattedNumber(_ value: Double?) -> String? {
        guard let value else { return nil }

        switch NumberDisplayFormatter.format(value, using: .chemistry(decimalPlaces: decimalPlaces)) {
        case .decimal(let value):
            return value
        case .scientific(let mantissa, let exponent):
            return "\(mantissa) × 10\(superscript(String(exponent)))"
        case .invalid:
            return "Invalid"
        }
    }

    private func inputValueFont(for field: SolutionInputField) -> Font {
        result?.unknown == field.unknown
            ? .system(.title3, design: .rounded).weight(.bold)
            : .system(.title3, design: .rounded).weight(.semibold)
    }

    private func inputValueColor(for field: SolutionInputField) -> Color {
        if result?.unknown == field.unknown {
            return .primary
        }

        return binding(for: field).wrappedValue.isEmpty ? .secondary : .primary
    }

    private func inputBackground(for field: SolutionInputField) -> Color {
        if result?.unknown == field.unknown {
            return Color.phosgreen1.opacity(0.18)
        }

        if inferredUnknown == field.unknown {
            return Color.phosgreen1.opacity(0.08)
        }

        if activeField == field {
            return Color.accentColor.opacity(0.08)
        }

        return Color(.systemBackground)
    }

    private func inputBorderColor(for field: SolutionInputField) -> Color {
        if result?.unknown == field.unknown {
            return Color.phosgreen1.opacity(0.75)
        }

        if inferredUnknown == field.unknown {
            return Color.phosgreen1.opacity(0.55)
        }

        if activeField == field {
            return .accentColor
        }

        return Color.secondary.opacity(0.35)
    }

    private func inputBorderWidth(for field: SolutionInputField) -> CGFloat {
        result?.unknown == field.unknown || activeField == field || inferredUnknown == field.unknown ? 2 : 1.5
    }

    private func calculate() {
        activeField = nil
        validationMessage = nil
        result = nil

        guard let unknown = inferredUnknown else {
            validationMessage = problemType == .dilution
                ? "Enter any three values and leave one dilution value blank."
                : "Enter any two values and leave one value blank."
            return
        }

        let input = SolutionsInput(
            problemType: engineProblemType,
            unknown: unknown,
            concentration: parsedValue(for: .concentration),
            soluteAmount: parsedValue(for: .soluteAmount),
            solutionAmount: parsedValue(for: .solutionAmount),
            c1: parsedValue(for: .c1),
            v1: parsedValue(for: .v1),
            c2: parsedValue(for: .c2),
            v2: parsedValue(for: .v2)
        )

        switch SolutionsEngine.solve(input) {
        case .success(let calculation):
            result = calculation
        case .failure(let error):
            validationMessage = error.localizedDescription
        }
    }

    private var inferredUnknown: SolutionUnknown? {
        let emptyFields = equationFields.filter { binding(for: $0).wrappedValue.isEmpty }
        guard emptyFields.count == 1 else { return nil }
        return emptyFields[0].unknown
    }

    private func clearAll() {
        activeField = nil
        concentration = ""
        soluteAmount = ""
        solutionAmount = ""
        c1 = ""
        v1 = ""
        c2 = ""
        v2 = ""
        result = nil
        validationMessage = nil
        decimalPlaces = 2
    }

    private func clearForEquationChange() {
        clearAll()
    }

    private func clearCalculation() {
        activeField = nil
        result = nil
        validationMessage = nil
    }

    private func parsedValue(for field: SolutionInputField) -> Double? {
        CustomNumericInputEditor.parsedFiniteValue(from: binding(for: field).wrappedValue)
    }

    private func binding(for field: SolutionInputField) -> Binding<String> {
        switch field {
        case .concentration:
            $concentration
        case .soluteAmount:
            $soluteAmount
        case .solutionAmount:
            $solutionAmount
        case .c1:
            $c1
        case .v1:
            $v1
        case .c2:
            $c2
        case .v2:
            $v2
        }
    }

    private func superscript(_ text: String) -> String {
        let characters: [Character: Character] = [
            "0": "⁰",
            "1": "¹",
            "2": "²",
            "3": "³",
            "4": "⁴",
            "5": "⁵",
            "6": "⁶",
            "7": "⁷",
            "8": "⁸",
            "9": "⁹",
            "+": "⁺",
            "-": "⁻"
        ]
        return String(text.map { characters[$0] ?? $0 })
    }
}

private enum SolutionWorkflowProblem: String, CaseIterable, Identifiable, CustomStringConvertible {
    case percent = "Percent"
    case molarity = "Molarity"
    case dilution = "Dilution"

    var id: Self { self }
    var description: String { rawValue }

    var guidance: String {
        switch self {
        case .percent:
            "Percent composition compares solute amount to total solution amount."
        case .molarity:
            "Molarity relates moles of solute to liters of solution."
        case .dilution:
            "Dilution keeps C₁V₁ equal to C₂V₂."
        }
    }
}

private enum PercentConcentrationType: String, CaseIterable, Identifiable, CustomStringConvertible {
    case massMass = "% m/m"
    case massVolume = "% m/v"
    case volumeVolume = "% v/v"

    var id: Self { self }
    var description: String { rawValue }

    var equationLabel: String {
        switch self {
        case .massMass:
            "%(m/m)"
        case .massVolume:
            "%(m/v)"
        case .volumeVolume:
            "%(v/v)"
        }
    }

    var engineProblemType: SolutionProblemType {
        switch self {
        case .massMass:
            .massPercent
        case .massVolume:
            .massVolumePercent
        case .volumeVolume:
            .volumeVolumePercent
        }
    }
}

private enum SolutionInputField: Hashable, Identifiable {
    case concentration
    case soluteAmount
    case solutionAmount
    case c1
    case v1
    case c2
    case v2

    var id: Self { self }

    var unknown: SolutionUnknown {
        switch self {
        case .concentration:
            .concentration
        case .soluteAmount:
            .soluteAmount
        case .solutionAmount:
            .solutionAmount
        case .c1:
            .c1
        case .v1:
            .v1
        case .c2:
            .c2
        case .v2:
            .v2
        }
    }

    func title(for problemType: SolutionProblemType) -> String {
        switch self {
        case .concentration:
            problemType == .molarity ? "Molarity" : "Percent composition"
        case .soluteAmount:
            problemType.soluteUnit
        case .solutionAmount:
            problemType.solutionUnit
        case .c1:
            "Initial concentration C₁"
        case .v1:
            "Initial volume V₁"
        case .c2:
            "Final concentration C₂"
        case .v2:
            "Final volume V₂"
        }
    }

    func placeholder(for problemType: SolutionProblemType) -> String {
        "?"
    }

    func shortSymbol(for problemType: SolutionProblemType) -> String {
        switch self {
        case .concentration:
            problemType == .molarity ? "M" : "%"
        case .soluteAmount:
            "solute"
        case .solutionAmount:
            "solution"
        case .c1:
            "C₁"
        case .v1:
            "V₁"
        case .c2:
            "C₂"
        case .v2:
            "V₂"
        }
    }
}

#Preview {
    SolutionsView()
}
