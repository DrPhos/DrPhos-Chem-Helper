import SwiftUI

struct pHCalculatorView: View {
    @State private var problemType: PHProblemType = .conversions
    @State private var conversionKnown: PHConversionKnown = .pH
    @State private var weakCalculation: PHWeakCalculation = .weakAcid
    @State private var bufferCalculation: PHBufferCalculation = .phFromPKa
    @State private var decimalPlaces = 2
    @State private var activeField: PHInputField?
    @State private var values: [PHInputField: String] = [:]
    @State private var result: PHDisplayResult?
    @State private var validationMessage: String?

    var body: some View {
        NavigationStack {
            DrPhosCalculatorScreen(
                title: "pH Calculator",
                instructions: "Choose the acid-base problem type, enter the known values, and calculate the missing pH relationship."
            ) {
                stepSection("Step 1", title: "Choose pH problem type") {
                    Picker("Problem type", selection: $problemType) {
                        ForEach(PHProblemType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: problemType) { _, _ in resetCalculation(keepInputs: false) }
                }

                stepSection("Step 2", title: problemType.stepTwoTitle) {
                    calculationPicker
                }

                stepSection("Step 3", title: "Enter known values") {
                    VStack(spacing: 12) {
                        ForEach(requiredFields) { field in
                            inputRow(for: field)
                        }
                    }
                }

                stepSection("Step 4", title: "Calculate") {
                    VStack(spacing: 14) {
                        HStack(spacing: 12) {
                            DrPhosActionButton("Calculate", systemImage: "equal", action: calculate)
                            DrPhosActionButton("Clear", systemImage: "xmark", style: .destructive, action: clear)
                        }

                        HStack {
                            Spacer()
                            DrPhosDecimalControl(value: $decimalPlaces, range: 0...8)
                        }

                        if let validationMessage {
                            DrPhosValidationMessage(message: validationMessage)
                        }

                        if let result {
                            resultCard(result)
                        }
                    }
                }

                if let activeField {
                    numericKeypad(for: activeField)
                }
            }
        }
    }

    @ViewBuilder
    private var calculationPicker: some View {
        switch problemType {
        case .conversions:
            Picker("Known value", selection: $conversionKnown) {
                ForEach(PHConversionKnown.allCases) { known in
                    Text(known.rawValue).tag(known)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxHeight: 130)
            .clipped()
            .onChange(of: conversionKnown) { _, _ in resetCalculation(keepInputs: false) }
        case .weak:
            Picker("Calculation", selection: $weakCalculation) {
                ForEach(PHWeakCalculation.allCases) { calculation in
                    Text(calculation.rawValue).tag(calculation)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxHeight: 150)
            .clipped()
            .onChange(of: weakCalculation) { _, _ in resetCalculation(keepInputs: false) }
        case .buffer:
            Picker("Buffer calculation", selection: $bufferCalculation) {
                ForEach(PHBufferCalculation.allCases) { calculation in
                    Text(calculation.rawValue).tag(calculation)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxHeight: 150)
            .clipped()
            .onChange(of: bufferCalculation) { _, _ in resetCalculation(keepInputs: false) }
        }
    }

    private func stepSection<Content: View>(
        _ step: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        DrPhosCalculatorSection(title: "\(step) — \(title)") {
            content()
        }
    }

    private func inputRow(for field: PHInputField) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(field.title)
                    .font(.headline)
                Spacer()
                if let unit = field.unit {
                    Text(unit)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            fieldButton(for: field)
        }
    }

    private func fieldButton(for field: PHInputField) -> some View {
        Button {
            activeField = field
            validationMessage = nil
        } label: {
            Text(rawValue(for: field).isEmpty ? "Enter" : rawValue(for: field))
                .font(.title3.monospacedDigit())
                .foregroundStyle(rawValue(for: field).isEmpty ? .secondary : .primary)
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
        .accessibilityValue(rawValue(for: field).isEmpty ? "Empty" : rawValue(for: field))
    }

    private func numericKeypad(for field: PHInputField) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Editing \(field.title)")
                    .font(.headline)
                Spacer()
                Text(rawValue(for: field).isEmpty ? "—" : rawValue(for: field))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(rawValue(for: field).isEmpty ? .secondary : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            CustomNumericKeypad(
                value: binding(for: field),
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

    private func resultCard(_ result: PHDisplayResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(result.title)
                .font(.headline)

            if result.isBuffer {
                bufferEquation(result)
            } else {
                VStack(spacing: 8) {
                    ForEach(result.rows) { row in
                        resultRow(row)
                    }
                }
            }

            if let context = result.context {
                Text(context)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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

    private func resultRow(_ row: PHResultRow) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(row.label)
                .font(row.isPrimary ? .title3.weight(.semibold) : .subheadline.weight(.semibold))
            Text("=")
                .foregroundStyle(.secondary)
            formattedValue(row.value, prominent: row.isPrimary)
            if let unit = row.unit {
                Text(unit)
                    .font(row.isPrimary ? .title3.weight(.semibold) : .subheadline.weight(.semibold))
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
    }

    private func bufferEquation(_ result: PHDisplayResult) -> some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                equationBox(label: "pH", value: result.value(for: .pH), highlight: result.highlightedField == .pH)
                Text("=")
                    .font(.title3.weight(.semibold))
                equationBox(label: "pKa", value: result.value(for: .pKa), highlight: result.highlightedField == .pKa)
                Text("+ log")
                    .font(.headline)
            }

            HStack(alignment: .center, spacing: 10) {
                VStack(spacing: 5) {
                    equationBox(label: "[A⁻]", value: result.value(for: .ratio), highlight: result.highlightedField == .ratio)
                    Rectangle()
                        .frame(width: 96, height: 1.5)
                        .foregroundStyle(.primary)
                    Text("[HA]")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text("ratio")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    private func equationBox(label: String, value: PHResultRow?, highlight: Bool) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(spacing: 0) {
                if let value {
                    formattedValue(value.value, prominent: highlight)
                } else {
                    Text("?")
                        .font(.title3.weight(.bold))
                }
            }
            .frame(minWidth: 82, minHeight: 40)
            .padding(.horizontal, 8)
            .background(highlight ? Color.phosgreen1.opacity(0.22) : Color.white.opacity(0.65), in: RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(highlight ? Color.phosgreen1.opacity(0.7) : Color.secondary.opacity(0.25), lineWidth: highlight ? 2 : 1)
            }
        }
    }

    @ViewBuilder
    private func formattedValue(_ value: Double, prominent: Bool = false) -> some View {
        let font: Font = prominent
            ? .system(.title3, design: .rounded).weight(.bold)
            : .system(.subheadline, design: .rounded).weight(.semibold)

        switch NumberDisplayFormatter.format(value, using: .chemistry(decimalPlaces: decimalPlaces)) {
        case .decimal(let text):
            Text(text)
                .font(font)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        case .scientific(let mantissa, let exponent):
            ScientificNotationView(
                mantissa: mantissa,
                exponent: exponent,
                exponentFont: prominent ? .system(size: 18, weight: .semibold) : .system(size: 13, weight: .semibold),
                exponentOffset: prominent ? 8 : 6
            )
            .font(font)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.65)
        case .invalid:
            Text("Invalid")
                .font(font)
                .monospacedDigit()
        }
    }

    private var requiredFields: [PHInputField] {
        switch problemType {
        case .conversions:
            [conversionKnown.field]
        case .weak:
            weakCalculation.requiredFields
        case .buffer:
            bufferCalculation.requiredFields
        }
    }

    private func calculate() {
        activeField = nil
        validationMessage = nil

        do {
            result = try makeResult()
        } catch let error as PHCalculationError {
            result = nil
            validationMessage = error.localizedDescription
        } catch {
            result = nil
            validationMessage = "Unable to calculate pH result."
        }
    }

    private func makeResult() throws -> PHDisplayResult {
        switch problemType {
        case .conversions:
            return try conversionResult()
        case .weak:
            return try weakResult()
        case .buffer:
            return try bufferResult()
        }
    }

    private func conversionResult() throws -> PHDisplayResult {
        let strong: PHStrongResult
        switch conversionKnown {
        case .pH:
            strong = try PHEngine.fromPH(required(.pH))
        case .pOH:
            strong = try PHEngine.fromHydroxide(pow(10, -required(.pOH)))
        case .hydronium:
            strong = try PHEngine.fromHydronium(required(.hydronium))
        case .hydroxide:
            strong = try PHEngine.fromHydroxide(required(.hydroxide))
        }

        return PHDisplayResult(
            title: "Equilibrium values",
            rows: [
                PHResultRow(field: .pH, label: "pH", value: strong.pH, unit: nil, isPrimary: conversionKnown.field != .pH),
                PHResultRow(field: .pOH, label: "pOH", value: strong.pOH, unit: nil, isPrimary: conversionKnown.field != .pOH),
                PHResultRow(field: .hydronium, label: "[H₃O⁺]", value: strong.hydronium, unit: "M", isPrimary: conversionKnown.field != .hydronium),
                PHResultRow(field: .hydroxide, label: "[OH⁻]", value: strong.hydroxide, unit: "M", isPrimary: conversionKnown.field != .hydroxide)
            ],
            context: "Solution is \(strong.classification.rawValue)."
        )
    }

    private func weakResult() throws -> PHDisplayResult {
        let weak: PHWeakResult
        let title: String
        let context: String

        switch weakCalculation {
        case .weakAcid:
            weak = try PHEngine.weakAcidPH(ka: required(.ka), initialAcidConcentration: required(.acid))
            title = "Weak acid result"
            context = "Solved from Ka and initial [HA]."
        case .weakBase:
            weak = try PHEngine.weakBasePH(kb: required(.kb), initialBaseConcentration: required(.base))
            title = "Weak base result"
            context = "Solved from Kb and initial base concentration."
        case .conjugateBase:
            weak = try PHEngine.conjugateBasePH(ka: required(.ka), initialConjugateBaseConcentration: required(.base))
            title = "Conjugate base result"
            context = "Used Kb = Kw / Ka."
        case .conjugateAcid:
            weak = try PHEngine.conjugateAcidPH(kb: required(.kb), initialConjugateAcidConcentration: required(.acid))
            title = "Conjugate acid result"
            context = "Used Ka = Kw / Kb."
        case .kaFromPH:
            let ka = try PHEngine.kaFromPH(pH: required(.pH), acidConcentration: required(.acid))
            return PHDisplayResult(
                title: "Weak acid constant",
                rows: [PHResultRow(field: .ka, label: "Ka", value: ka, unit: nil, isPrimary: true)],
                context: "Current app approximation: Ka = [H₃O⁺]² / [HA]."
            )
        case .kbFromPH:
            let kb = try PHEngine.kbFromPH(pH: required(.pH), baseConcentration: required(.base))
            return PHDisplayResult(
                title: "Weak base constant",
                rows: [PHResultRow(field: .kb, label: "Kb", value: kb, unit: nil, isPrimary: true)],
                context: "Current app approximation: Kb = [OH⁻]² / base concentration."
            )
        }

        return PHDisplayResult(
            title: title,
            rows: [
                PHResultRow(field: .pH, label: "pH", value: weak.pH, unit: nil, isPrimary: true),
                PHResultRow(field: .pOH, label: "pOH", value: weak.pOH, unit: nil),
                PHResultRow(field: .hydronium, label: "[H₃O⁺]", value: weak.hydronium, unit: "M"),
                PHResultRow(field: .hydroxide, label: "[OH⁻]", value: weak.hydroxide, unit: "M")
            ],
            context: "\(context) Solution is \(weak.classification.rawValue)."
        )
    }

    private func bufferResult() throws -> PHDisplayResult {
        switch bufferCalculation {
        case .phFromPKa:
            let pKa = try required(.pKa)
            let ratio = try required(.ratio)
            let pH = try PHEngine.bufferPH(pKa: pKa, baseAcidRatio: ratio)
            return bufferDisplayResult(pH: pH, pKa: pKa, ratio: ratio, highlightedField: .pH)
        case .phFromKa:
            let ka = try required(.ka)
            let pKa = try PHEngine.pKa(fromKa: ka)
            let ratio = try required(.ratio)
            let pH = try PHEngine.bufferPH(ka: ka, baseAcidRatio: ratio)
            return bufferDisplayResult(pH: pH, pKa: pKa, ratio: ratio, highlightedField: .pH, context: "Converted Ka to pKa first.")
        case .pKaFromPH:
            let pH = try required(.pH)
            let ratio = try required(.ratio)
            let pKa = try PHEngine.bufferPKa(pH: pH, baseAcidRatio: ratio)
            return bufferDisplayResult(pH: pH, pKa: pKa, ratio: ratio, highlightedField: .pKa)
        case .ratioFromPH:
            let pH = try required(.pH)
            let pKa = try required(.pKa)
            let ratio = try PHEngine.bufferBaseAcidRatio(pH: pH, pKa: pKa)
            return bufferDisplayResult(pH: pH, pKa: pKa, ratio: ratio, highlightedField: .ratio)
        }
    }

    private func bufferDisplayResult(
        pH: Double,
        pKa: Double,
        ratio: Double,
        highlightedField: PHInputField,
        context: String? = nil
    ) -> PHDisplayResult {
        PHDisplayResult(
            title: "Henderson-Hasselbalch",
            rows: [
                PHResultRow(field: .pH, label: "pH", value: pH, unit: nil, isPrimary: highlightedField == .pH),
                PHResultRow(field: .pKa, label: "pKa", value: pKa, unit: nil, isPrimary: highlightedField == .pKa),
                PHResultRow(field: .ratio, label: "[A⁻]/[HA]", value: ratio, unit: nil, isPrimary: highlightedField == .ratio)
            ],
            context: context ?? "pH = pKa + log([A⁻]/[HA])",
            isBuffer: true,
            highlightedField: highlightedField
        )
    }

    private func required(_ field: PHInputField) throws -> Double {
        guard let value = CustomNumericInputEditor.parsedFiniteValue(from: rawValue(for: field)) else {
            throw PHCalculationError.invalidValue("Enter a valid value for \(field.title).")
        }
        return value
    }

    private func clear() {
        values = [:]
        result = nil
        validationMessage = nil
        activeField = nil
    }

    private func resetCalculation(keepInputs: Bool) {
        result = nil
        validationMessage = nil
        activeField = nil
        if !keepInputs {
            values = [:]
        }
    }

    private func binding(for field: PHInputField) -> Binding<String> {
        Binding(
            get: { rawValue(for: field) },
            set: {
                values[field] = $0
                result = nil
                validationMessage = nil
            }
        )
    }

    private func rawValue(for field: PHInputField) -> String {
        values[field, default: ""]
    }
}

private enum PHProblemType: String, CaseIterable, Identifiable {
    case conversions = "Conversions"
    case weak = "Weak acid/base"
    case buffer = "Buffer"

    var id: Self { self }

    var stepTwoTitle: String {
        switch self {
        case .conversions: "Choose known value"
        case .weak: "Choose weak solution calculation"
        case .buffer: "Choose buffer calculation"
        }
    }
}

private enum PHConversionKnown: String, CaseIterable, Identifiable {
    case pH = "pH"
    case pOH = "pOH"
    case hydronium = "[H₃O⁺]"
    case hydroxide = "[OH⁻]"

    var id: Self { self }

    var field: PHInputField {
        switch self {
        case .pH: .pH
        case .pOH: .pOH
        case .hydronium: .hydronium
        case .hydroxide: .hydroxide
        }
    }
}

private enum PHWeakCalculation: String, CaseIterable, Identifiable {
    case weakAcid = "pH from Ka and [HA]"
    case weakBase = "pH from Kb and base concentration"
    case conjugateBase = "Conjugate base from Ka"
    case conjugateAcid = "Conjugate acid from Kb"
    case kaFromPH = "Ka from pH and [HA]"
    case kbFromPH = "Kb from pH and base concentration"

    var id: Self { self }

    var requiredFields: [PHInputField] {
        switch self {
        case .weakAcid:
            [.ka, .acid]
        case .weakBase:
            [.kb, .base]
        case .conjugateBase:
            [.ka, .base]
        case .conjugateAcid:
            [.kb, .acid]
        case .kaFromPH:
            [.pH, .acid]
        case .kbFromPH:
            [.pH, .base]
        }
    }
}

private enum PHBufferCalculation: String, CaseIterable, Identifiable {
    case phFromPKa = "pH from pKa and ratio"
    case phFromKa = "pH from Ka and ratio"
    case pKaFromPH = "pKa from pH and ratio"
    case ratioFromPH = "Ratio from pH and pKa"

    var id: Self { self }

    var requiredFields: [PHInputField] {
        switch self {
        case .phFromPKa:
            [.pKa, .ratio]
        case .phFromKa:
            [.ka, .ratio]
        case .pKaFromPH:
            [.pH, .ratio]
        case .ratioFromPH:
            [.pH, .pKa]
        }
    }
}

private enum PHInputField: String, CaseIterable, Identifiable, Hashable {
    case pH
    case pOH
    case hydronium
    case hydroxide
    case ka
    case kb
    case acid
    case base
    case pKa
    case ratio

    var id: Self { self }

    var title: String {
        switch self {
        case .pH: "pH"
        case .pOH: "pOH"
        case .hydronium: "[H₃O⁺]"
        case .hydroxide: "[OH⁻]"
        case .ka: "Ka"
        case .kb: "Kb"
        case .acid: "[HA]"
        case .base: "[A⁻] / base"
        case .pKa: "pKa"
        case .ratio: "[A⁻]/[HA] ratio"
        }
    }

    var unit: String? {
        switch self {
        case .hydronium, .hydroxide, .acid, .base:
            "M"
        default:
            nil
        }
    }
}

private struct PHResultRow: Identifiable {
    let id = UUID()
    let field: PHInputField
    let label: String
    let value: Double
    let unit: String?
    var isPrimary = false
}

private struct PHDisplayResult {
    let title: String
    let rows: [PHResultRow]
    let context: String?
    var isBuffer = false
    var highlightedField: PHInputField?

    func value(for field: PHInputField) -> PHResultRow? {
        rows.first { $0.field == field }
    }
}

#Preview {
    pHCalculatorView()
}
