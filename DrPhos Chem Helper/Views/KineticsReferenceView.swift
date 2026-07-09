import SwiftUI

struct KineticsView: View {
    @State private var reactionOrder: ReactionOrder = .first
    @State private var timeUnit: TimeUnit = .seconds
    @State private var unknown: KineticsUnknown = .time
    @State private var rateConstantMethod: RateConstantMethod = .concentrationTime
    @State private var activeField: KineticsField?

    @State private var rateConstant = ""
    @State private var initialConcentration = ""
    @State private var finalConcentration = ""
    @State private var time = ""
    @State private var halfLife = ""

    @State private var decimalPlaces = 3
    @State private var result: KineticsResult?
    @State private var validationMessage: String?

    fileprivate enum KineticsField: Hashable {
        case rateConstant, initialConcentration, finalConcentration, time, halfLife
    }

    private enum RateConstantMethod: String, CaseIterable, Identifiable {
        case concentrationTime = "Concentration/time data"
        case halfLife = "Half-life data"

        var id: Self { self }
    }

    private let workflowTimeUnits: [TimeUnit] = [.seconds, .minutes, .hours, .days]

    var body: some View {
        NavigationStack {
            DrPhosCalculatorScreen(
                title: "Kinetics Calculator",
                instructions: "Work from top to bottom: choose the reaction setup, pick what to solve, enter the required known values, then calculate."
            ) {
                orderSection
                timeUnitSection
                unknownSection
                knownValuesSection
                calculateSection
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if let activeField {
                    numericKeypad(for: activeField)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.18), value: activeField)
            .animation(.easeInOut(duration: 0.2), value: unknown)
            .animation(.easeInOut(duration: 0.2), value: result?.value)
        }
    }

    private var orderSection: some View {
        workflowSection(step: 1, title: "Choose reaction order") {
            wheelPicker("Reaction order", selection: $reactionOrder, options: ReactionOrder.allCases)
        }
    }

    private var timeUnitSection: some View {
        workflowSection(step: 2, title: "Choose time units") {
            wheelPicker("Time units", selection: $timeUnit, options: workflowTimeUnits)
        }
    }

    private var unknownSection: some View {
        workflowSection(step: 3, title: "Choose unknown variable") {
            wheelPicker("Unknown", selection: $unknown, options: KineticsUnknown.workflowCases)
        }
    }

    private var knownValuesSection: some View {
        workflowSection(step: 4, title: "Enter required known values") {
            VStack(alignment: .leading, spacing: 12) {
                if unknown == .rateConstant {
                    Picker("Calculate k from", selection: $rateConstantMethod) {
                        ForEach(RateConstantMethod.allCases) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: rateConstantMethod) { _, _ in
                        activeField = nil
                        result = nil
                        validationMessage = nil
                    }
                }

                Text(inputGuidance)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                ForEach(requiredFields, id: \.self) { field in
                    kineticsInputField(for: field)
                }
            }
        }
    }

    private var calculateSection: some View {
        workflowSection(step: 5, title: "Calculate") {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    DrPhosActionButton("Calculate", systemImage: "equal", action: calculate)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    DrPhosActionButton("Clear", systemImage: "xmark", style: .destructive, action: clear)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }

                if let validationMessage {
                    DrPhosValidationMessage(message: validationMessage)
                }

                if let result {
                    resultCard(result)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    private func workflowSection<Content: View>(
        step: Int,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        DrPhosCalculatorSection(title: "Step \(step) — \(title)") {
            content()
        }
    }

    private func wheelPicker<Value: Hashable & Identifiable & CustomStringConvertible>(
        _ title: String,
        selection: Binding<Value>,
        options: [Value]
    ) -> some View {
        Picker(title, selection: selection) {
            ForEach(options) { option in
                Text(option.description).tag(option)
            }
        }
        .pickerStyle(.wheel)
        .frame(height: 112)
        .clipped()
        .onChange(of: selection.wrappedValue) { _, _ in
            activeField = nil
            result = nil
            validationMessage = nil
            if unknown != .rateConstant {
                rateConstantMethod = .concentrationTime
            }
        }
    }

    private func kineticsInputField(for field: KineticsField) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(field.title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(unit(for: field))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            numericFieldButton(
                prompt: field.prompt,
                text: binding(for: field),
                field: field
            )
        }
    }

    private func numericFieldButton(
        prompt: String,
        text: Binding<String>,
        field: KineticsField
    ) -> some View {
        Button {
            activeField = field
        } label: {
            Text(text.wrappedValue.isEmpty ? prompt : text.wrappedValue)
                .font(.title3.monospacedDigit())
                .foregroundStyle(text.wrappedValue.isEmpty ? .secondary : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .padding(.horizontal, 12)
                .background(.background, in: RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            activeField == field ? Color.accentColor : Color.secondary.opacity(0.35),
                            lineWidth: activeField == field ? 2 : 1.5
                        )
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(field.title)
        .accessibilityValue(text.wrappedValue.isEmpty ? "Empty" : text.wrappedValue)
    }

    private func numericKeypad(for field: KineticsField) -> some View {
        let value = binding(for: field)
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Editing \(field.title.lowercased())")
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

    private func resultCard(_ result: KineticsResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text(result.unknown.resultTitle)
                    .font(.headline)
                Spacer()
                DrPhosDecimalControl(value: $decimalPlaces, range: 0...6)
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(result.unknown.symbol)
                    .font(.title3.weight(.semibold))
                Text("=")
                    .font(.title3.weight(.semibold))
                formattedValue(result.value)
                Text(result.unit)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Text(formulaContext)
                .font(.footnote)
                .foregroundStyle(.secondary)

            if let halfLife = result.halfLife, result.unknown != .halfLife {
                Divider()
                HStack {
                    Text("Half-life")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    HStack(spacing: 4) {
                        formattedValue(
                            halfLife,
                            font: .system(.subheadline, design: .rounded).weight(.semibold),
                            exponentFont: .system(size: 14, weight: .semibold),
                            exponentOffset: 6
                        )
                        Text(result.halfLifeUnit)
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.phosgreen1.opacity(0.12), in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(Color.phosgreen1.opacity(0.35))
        }
    }

    private var requiredFields: [KineticsField] {
        switch unknown {
        case .rateConstant:
            if rateConstantMethod == .halfLife {
                reactionOrder == .first ? [.halfLife] : [.halfLife, .initialConcentration]
            } else {
                [.initialConcentration, .finalConcentration, .time]
            }
        case .time:
            [.rateConstant, .initialConcentration, .finalConcentration]
        case .initialConcentration:
            [.rateConstant, .finalConcentration, .time]
        case .finalConcentration:
            [.rateConstant, .initialConcentration, .time]
        case .halfLife:
            reactionOrder == .first ? [.rateConstant] : [.rateConstant, .initialConcentration]
        }
    }

    private var inputGuidance: String {
        switch unknown {
        case .rateConstant:
            if rateConstantMethod == .halfLife {
                reactionOrder == .first
                    ? "Enter half-life to solve for k."
                    : "Enter half-life and [A]₀ to solve for k."
            } else {
                "Enter concentrations and elapsed time to solve for k."
            }
        case .time:
            "Enter k, [A]₀, and [A]ₜ to solve for elapsed time."
        case .initialConcentration:
            "Enter k, [A]ₜ, and time to solve for [A]₀."
        case .finalConcentration:
            "Enter k, [A]₀, and time to solve for [A]ₜ."
        case .halfLife:
            reactionOrder == .first
                ? "First-order half-life only requires k."
                : "Zero- and second-order half-life require k and [A]₀."
        }
    }

    private var formulaContext: String {
        if unknown == .rateConstant, rateConstantMethod == .halfLife {
            switch reactionOrder {
            case .zero:
                "k = [A]₀ / (2t½)"
            case .first:
                "k = ln(2) / t½"
            case .second:
                "k = 1 / (t½[A]₀)"
            }
        } else {
            integratedRateLawContext
        }
    }

    private var integratedRateLawContext: String {
        switch reactionOrder {
        case .zero:
            "[A]ₜ = [A]₀ − kt"
        case .first:
            "[A]ₜ = [A]₀e⁻ᵏᵗ"
        case .second:
            "1/[A]ₜ = 1/[A]₀ + kt"
        }
    }

    private func unit(for field: KineticsField) -> String {
        switch field {
        case .rateConstant:
            KineticsEngine.rateConstantUnit(for: reactionOrder, timeUnit: timeUnit)
        case .initialConcentration, .finalConcentration:
            "M"
        case .time, .halfLife:
            timeUnit.abbreviation
        }
    }

    private func binding(for field: KineticsField) -> Binding<String> {
        switch field {
        case .rateConstant:
            $rateConstant
        case .initialConcentration:
            $initialConcentration
        case .finalConcentration:
            $finalConcentration
        case .time:
            $time
        case .halfLife:
            $halfLife
        }
    }

    private func calculate() {
        activeField = nil
        validationMessage = nil
        result = nil

        let input = KineticsInput(
            order: reactionOrder,
            timeUnit: timeUnit,
            unknown: unknown,
            rateConstant: Double(rateConstant),
            initialConcentration: Double(initialConcentration),
            finalConcentration: Double(finalConcentration),
            time: Double(time),
            halfLife: Double(halfLife)
        )

        let calculationResult: Result<KineticsResult, KineticsCalculationError>
        if unknown == .rateConstant, rateConstantMethod == .halfLife {
            calculationResult = KineticsEngine.solveRateConstantFromHalfLife(input)
        } else {
            calculationResult = KineticsEngine.solve(input)
        }

        switch calculationResult {
        case .success(let calculation):
            result = calculation
        case .failure(let error):
            validationMessage = error.localizedDescription
        }
    }

    private func clear() {
        activeField = nil
        rateConstant = ""
        initialConcentration = ""
        finalConcentration = ""
        time = ""
        halfLife = ""
        result = nil
        validationMessage = nil
        decimalPlaces = 3
        rateConstantMethod = .concentrationTime
    }

    private func format(_ value: Double) -> String {
        NumberDisplayFormatter
            .format(value, using: .kinetics(decimalPlaces: decimalPlaces))
            .plainText
    }

    @ViewBuilder
    private func formattedValue(
        _ value: Double,
        font: Font = .system(.title2, design: .rounded).weight(.bold),
        exponentFont: Font = .system(size: 20, weight: .semibold),
        exponentOffset: CGFloat = 9
    ) -> some View {
        switch NumberDisplayFormatter.format(value, using: .kinetics(decimalPlaces: decimalPlaces)) {
        case .scientific(let mantissa, let exponent):
            ScientificNotationView(
                mantissa: mantissa,
                exponent: exponent,
                exponentFont: exponentFont,
                exponentOffset: exponentOffset
            )
                .font(font)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        case .decimal(let value):
            Text(value)
                .font(font)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        case .invalid:
            Text("Invalid")
                .font(font)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
    }
}

extension ReactionOrder: Identifiable, CustomStringConvertible {
    var id: Self { self }
    var description: String { rawValue.replacingOccurrences(of: " Order", with: " order") }
}

extension TimeUnit: Identifiable, CustomStringConvertible {
    var id: Self { self }
    var description: String { rawValue.lowercased() }
}

extension KineticsUnknown: Identifiable, CustomStringConvertible {
    static var workflowCases: [KineticsUnknown] {
        [.rateConstant, .time, .initialConcentration, .finalConcentration, .halfLife]
    }

    var id: Self { self }

    var description: String {
        switch self {
        case .rateConstant:
            "k"
        case .time:
            "time"
        case .initialConcentration:
            "initial concentration [A]₀"
        case .finalConcentration:
            "final concentration [A]ₜ"
        case .halfLife:
            "half-life"
        }
    }

    var symbol: String {
        switch self {
        case .rateConstant:
            "k"
        case .time:
            "t"
        case .initialConcentration:
            "[A]₀"
        case .finalConcentration:
            "[A]ₜ"
        case .halfLife:
            "t½"
        }
    }

    var resultTitle: String {
        switch self {
        case .rateConstant:
            "Rate constant"
        case .time:
            "Elapsed time"
        case .initialConcentration:
            "Initial concentration"
        case .finalConcentration:
            "Final concentration"
        case .halfLife:
            "Half-life"
        }
    }
}

private extension KineticsView.KineticsField {
    var title: String {
        switch self {
        case .rateConstant:
            "Rate constant k"
        case .initialConcentration:
            "Initial concentration [A]₀"
        case .finalConcentration:
            "Final concentration [A]ₜ"
        case .time:
            "Time"
        case .halfLife:
            "Half-life"
        }
    }

    var prompt: String {
        switch self {
        case .rateConstant:
            "Enter k"
        case .initialConcentration:
            "Enter [A]₀"
        case .finalConcentration:
            "Enter [A]ₜ"
        case .time:
            "Enter time"
        case .halfLife:
            "Enter half-life"
        }
    }
}

#Preview {
    KineticsView()
}
