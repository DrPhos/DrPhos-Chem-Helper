import SwiftUI

struct pHCalculatorView: View {
    @State private var problemType: PHProblemType = .conversions
    @State private var conversionKnown: PHConversionKnown = .pH
    @State private var weakCalculation: PHWeakCalculation = .weakAcid
    @State private var bufferUnknown: PHInputField = .pH
    @State private var bufferConstantMode: PHBufferConstantMode = .pKa
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
                    .onChange(of: problemType) { _, newValue in
                        if newValue == .buffer {
                            bufferUnknown = .pH
                            bufferConstantMode = .pKa
                        }
                        resetCalculation(keepInputs: false)
                    }
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
                        if let result, !result.isBuffer {
                            resultCard(result)
                        }

                        if let validationMessage {
                            DrPhosValidationMessage(message: validationMessage)
                        }

                        HStack(spacing: 12) {
                            DrPhosActionButton("Calculate", systemImage: "equal", action: calculate)

                            DrPhosDecimalControl(value: $decimalPlaces, range: 0...8)
                                .fixedSize(horizontal: true, vertical: false)
                        }

                        HStack {
                            Spacer()

                            DrPhosActionButton("Clear", systemImage: "xmark", style: .destructive, action: clear)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                                .frame(maxWidth: 180)
                        }
                    }
                }

            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if let activeField {
                    numericKeypad(for: activeField)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.18), value: activeField)
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
                    weakCalculationLabel(calculation)
                        .tag(calculation)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxHeight: 150)
            .clipped()
            .onChange(of: weakCalculation) { _, _ in resetCalculation(keepInputs: false) }
        case .buffer:
            bufferEquationInterface
        }
    }

    @ViewBuilder
    private func weakCalculationLabel(_ calculation: PHWeakCalculation) -> some View {
        switch calculation {
        case .weakAcid:
            HStack(spacing: 0) {
                Text("pH from ")
                PHSymbolText(.ka)
                Text(" and [HA]")
            }
        case .weakBase:
            HStack(spacing: 0) {
                Text("pH from ")
                PHSymbolText(.kb)
                Text(" and [A⁻]")
            }
        case .conjugateBase:
            HStack(spacing: 0) {
                Text("pH from ")
                PHSymbolText(.ka)
                Text(" and [A⁻]")
            }
        case .conjugateAcid:
            HStack(spacing: 0) {
                Text("pH from ")
                PHSymbolText(.kb)
                Text(" and [HA]")
            }
        case .kaFromPH:
            HStack(spacing: 0) {
                PHSymbolText(.ka)
                Text(" from pH and [HA]")
            }
        case .kbFromPH:
            HStack(spacing: 0) {
                PHSymbolText(.kb)
                Text(" from pH and [A⁻]")
            }
        }
    }

    private var bufferEquationInterface: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Unknown")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(bufferUnknown.accessibilityTitle)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.phosgreen1)
            }

            Picker("Acid constant input", selection: $bufferConstantMode) {
                Text("pKₐ").tag(PHBufferConstantMode.pKa)
                Text("Kₐ").tag(PHBufferConstantMode.ka)
            }
            .pickerStyle(.segmented)
            .onChange(of: bufferConstantMode) { oldValue, newValue in
                if bufferUnknown == oldValue.field {
                    bufferUnknown = newValue.field
                }
                result = nil
                validationMessage = nil
                activeField = nil
            }

            Text("Tap a variable in the equation to choose what to solve for.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            bufferEquationEditor

            if let result, result.isBuffer, let context = result.context {
                Text(context)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var bufferEquationEditor: some View {
        VStack(spacing: 10) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: 4) {
                    bufferVariableBox(.pH)
                    Text("=")
                        .font(.headline.weight(.semibold))
                    bufferVariableBox(bufferConstantMode.field)
                    Text("+")
                        .font(.headline.weight(.semibold))
                    Text("log(")
                        .font(.subheadline.weight(.semibold))
                    bufferFraction
                    Text(")")
                        .font(.subheadline.weight(.semibold))
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 10) {
                    HStack(alignment: .center, spacing: 5) {
                        bufferVariableBox(.pH)
                        Text("=")
                            .font(.headline.weight(.semibold))
                        bufferVariableBox(bufferConstantMode.field)
                    }

                    HStack(alignment: .center, spacing: 5) {
                        Text("+ log(")
                            .font(.headline.weight(.semibold))
                        bufferFraction
                        Text(")")
                            .font(.headline.weight(.semibold))
                    }
                }
                .frame(maxWidth: .infinity)
            }

            Text("[A⁻] = base form, [HA] = acid form")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }

    private var bufferFraction: some View {
        VStack(spacing: 4) {
            bufferVariableBox(.base)
            Rectangle()
                .frame(width: 78, height: 1.5)
                .foregroundStyle(.primary)
            bufferVariableBox(.acid)
        }
    }

    private var bufferEquationResultDisplay: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                bufferVariableBox(.pH)
                Text("=")
                    .font(.title3.weight(.semibold))
                bufferVariableBox(bufferConstantMode.field)
            }

            HStack(alignment: .center, spacing: 8) {
                Text("+ log(")
                    .font(.title3.weight(.semibold))

                VStack(spacing: 6) {
                    bufferVariableBox(.base)
                    Rectangle()
                        .frame(width: 116, height: 1.5)
                        .foregroundStyle(.primary)
                    bufferVariableBox(.acid)
                }

                Text(")")
                    .font(.title3.weight(.semibold))
            }

            Text("[A⁻] = base form, [HA] = acid form")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }

    private func bufferVariableBox(_ field: PHInputField) -> some View {
        Button {
            bufferUnknown = field
            result = nil
            validationMessage = nil
            activeField = nil
        } label: {
            VStack(spacing: 5) {
                if bufferUnknown == field, field != .acid {
                    phInputLabel(field, font: .caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                HStack(spacing: 0) {
                    bufferBoxValueContent(for: field)
                }
                .frame(minWidth: bufferBoxMinWidth(for: field), minHeight: 38)
                .padding(.horizontal, 6)
                .background(bufferBoxBackground(for: field), in: RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(bufferBoxStroke(for: field), lineWidth: bufferUnknown == field ? 2 : 1.25)
                }

                if bufferUnknown == field, field == .acid {
                    phInputLabel(field, font: .caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Solve for \(field.accessibilityTitle)")
    }

    @ViewBuilder
    private func bufferBoxValueContent(for field: PHInputField) -> some View {
        if let value = bufferDisplayedResultValue(for: field) {
            formattedValue(value, prominent: field == bufferUnknown)
        } else if bufferUnknown == field {
            Text("?")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
        } else if field == .ka, let value = CustomNumericInputEditor.parsedFiniteValue(from: rawValue(for: field)) {
            formattedValue(value)
        } else if rawValue(for: field).isEmpty {
            phInputLabel(field, font: .subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        } else {
            Text(rawValue(for: field))
                .font(.subheadline.monospacedDigit().weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
    }

    private func bufferBoxMinWidth(for field: PHInputField) -> CGFloat {
        switch field {
        case .base, .acid:
            64
        default:
            54
        }
    }

    private func bufferDisplayedResultValue(for field: PHInputField) -> Double? {
        guard result?.isBuffer == true else { return nil }
        return result?.value(for: field)?.value
    }

    private func bufferBoxBackground(for field: PHInputField) -> Color {
        if result?.isBuffer == true, field == bufferUnknown {
            return Color.phosgreen1.opacity(0.22)
        }

        if field == bufferUnknown {
            return Color.accentColor.opacity(0.12)
        }

        return Color.white.opacity(0.65)
    }

    private func bufferBoxStroke(for field: PHInputField) -> Color {
        if result?.isBuffer == true, field == bufferUnknown {
            return Color.phosgreen1.opacity(0.75)
        }

        if field == bufferUnknown {
            return Color.accentColor.opacity(0.8)
        }

        return Color.secondary.opacity(0.25)
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
                phInputLabel(field, font: .headline)
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
        .accessibilityLabel(field.accessibilityTitle)
        .accessibilityValue(rawValue(for: field).isEmpty ? "Empty" : rawValue(for: field))
    }

    private func numericKeypad(for field: PHInputField) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 4) {
                    Text("Editing")
                    phInputLabel(field, font: .headline)
                }
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

    @ViewBuilder
    private func phInputLabel(_ field: PHInputField, font: Font) -> some View {
        switch field {
        case .ka:
            PHSymbolText(.ka, font: font)
        case .kb:
            PHSymbolText(.kb, font: font)
        case .pKa:
            PHSymbolText(.pKa, font: font)
        default:
            Text(field.title)
                .font(font)
        }
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
            phInputLabel(row.field, font: row.isPrimary ? .title3.weight(.semibold) : .subheadline.weight(.semibold))
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
                equationBox(label: "pKₐ", value: result.value(for: .pKa), highlight: result.highlightedField == .pKa)
                Text("+")
                    .font(.title3.weight(.semibold))
                Text("log(")
                    .font(.headline)
            }

            HStack(alignment: .center, spacing: 8) {
                Spacer(minLength: 0)
                equationBox(label: "[A⁻]/[HA]", value: result.value(for: .ratio), highlight: result.highlightedField == .ratio)
                Text(")")
                    .font(.headline)
                Spacer(minLength: 0)
            }

            Text("base / acid ratio")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("[A⁻] = base form, [HA] = acid form")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    private func equationBox(label: String, value: PHResultRow?, highlight: Bool) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
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
            bufferRequiredFields
        }
    }

    private var bufferRequiredFields: [PHInputField] {
        [.pH, bufferConstantMode.field, .base, .acid].filter { $0 != bufferUnknown }
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
            context = "Solved from Kₐ and initial [HA]."
        case .weakBase:
            weak = try PHEngine.weakBasePH(kb: required(.kb), initialBaseConcentration: required(.base))
            title = "Weak base result"
            context = "Solved from Kb and initial [A⁻]."
        case .conjugateBase:
            weak = try PHEngine.conjugateBasePH(ka: required(.ka), initialConjugateBaseConcentration: required(.base))
            title = "[A⁻] result"
            context = "Used Kb = Kw / Kₐ for [A⁻]."
        case .conjugateAcid:
            weak = try PHEngine.conjugateAcidPH(kb: required(.kb), initialConjugateAcidConcentration: required(.acid))
            title = "[HA] result"
            context = "Used Kₐ = Kw / Kb for [HA]."
        case .kaFromPH:
            let ka = try PHEngine.kaFromPH(pH: required(.pH), acidConcentration: required(.acid))
            return PHDisplayResult(
                title: "Weak acid constant",
                rows: [PHResultRow(field: .ka, label: "Kₐ", value: ka, unit: nil, isPrimary: true)],
                context: "Current app approximation: Kₐ = [H₃O⁺]² / [HA]."
            )
        case .kbFromPH:
            let kb = try PHEngine.kbFromPH(pH: required(.pH), baseConcentration: required(.base))
            return PHDisplayResult(
                title: "Weak base constant",
                rows: [PHResultRow(field: .kb, label: "Kb", value: kb, unit: nil, isPrimary: true)],
                context: "Current app approximation: Kb = [OH⁻]² / [A⁻]."
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
        switch bufferUnknown {
        case .pH:
            let constant = try bufferConstant()
            let base = try requiredPositive(.base)
            let acid = try requiredPositive(.acid)
            let ratio = try finitePositive(base / acid, "Unable to calculate a valid [A⁻]/[HA] ratio.")
            let pH = try PHEngine.bufferPH(pKa: constant.pKa, baseAcidRatio: ratio)
            return bufferDisplayResult(
                pH: pH,
                pKa: constant.pKa,
                ka: constant.ka,
                base: base,
                acid: acid,
                highlightedField: .pH,
                context: constant.context
            )
        case .pKa, .ka:
            let pH = try required(.pH)
            let base = try requiredPositive(.base)
            let acid = try requiredPositive(.acid)
            let ratio = try finitePositive(base / acid, "Unable to calculate a valid [A⁻]/[HA] ratio.")
            let pKa = try PHEngine.bufferPKa(pH: pH, baseAcidRatio: ratio)
            let ka = try PHEngine.ka(fromPKa: pKa)
            return bufferDisplayResult(
                pH: pH,
                pKa: pKa,
                ka: ka,
                base: base,
                acid: acid,
                highlightedField: bufferConstantMode.field,
                context: bufferConstantMode == .ka ? "Calculated Kₐ from pKₐ after solving the equation." : nil
            )
        case .base:
            let pH = try required(.pH)
            let constant = try bufferConstant()
            let acid = try requiredPositive(.acid)
            let ratio = try PHEngine.bufferBaseAcidRatio(pH: pH, pKa: constant.pKa)
            let base = try finitePositive(ratio * acid, "Unable to calculate a valid [A⁻].")
            return bufferDisplayResult(
                pH: pH,
                pKa: constant.pKa,
                ka: constant.ka,
                base: base,
                acid: acid,
                highlightedField: .base,
                context: constant.context
            )
        case .acid:
            let pH = try required(.pH)
            let constant = try bufferConstant()
            let base = try requiredPositive(.base)
            let ratio = try PHEngine.bufferBaseAcidRatio(pH: pH, pKa: constant.pKa)
            let acid = try finitePositive(base / ratio, "Unable to calculate a valid [HA].")
            return bufferDisplayResult(
                pH: pH,
                pKa: constant.pKa,
                ka: constant.ka,
                base: base,
                acid: acid,
                highlightedField: .acid,
                context: constant.context
            )
        default:
            throw PHCalculationError.invalidValue("Choose pH, pKₐ, Kₐ, [A⁻], or [HA] as the buffer unknown.")
        }
    }

    private func bufferDisplayResult(
        pH: Double,
        pKa: Double,
        ka: Double?,
        base: Double,
        acid: Double,
        highlightedField: PHInputField,
        context: String? = nil
    ) -> PHDisplayResult {
        let constantField = bufferConstantMode.field
        let constantValue = bufferConstantMode == .ka ? ka ?? pow(10, -pKa) : pKa

        return PHDisplayResult(
            title: "Henderson-Hasselbalch",
            rows: [
                PHResultRow(field: .pH, label: "pH", value: pH, unit: nil, isPrimary: highlightedField == .pH),
                PHResultRow(field: constantField, label: constantField.title, value: constantValue, unit: nil, isPrimary: highlightedField == constantField),
                PHResultRow(field: .base, label: "[A⁻]", value: base, unit: "M", isPrimary: highlightedField == .base),
                PHResultRow(field: .acid, label: "[HA]", value: acid, unit: "M", isPrimary: highlightedField == .acid)
            ],
            context: context ?? "pH = pKₐ + log([A⁻]/[HA])",
            isBuffer: true,
            highlightedField: highlightedField
        )
    }

    private func bufferConstant() throws -> (pKa: Double, ka: Double?, context: String?) {
        switch bufferConstantMode {
        case .pKa:
            return (try required(.pKa), nil, nil)
        case .ka:
            let ka = try requiredPositive(.ka)
            let pKa = try PHEngine.pKa(fromKa: ka)
            return (pKa, ka, "Converted Kₐ to pKₐ for the Henderson-Hasselbalch equation.")
        }
    }

    private func required(_ field: PHInputField) throws -> Double {
        guard let value = CustomNumericInputEditor.parsedFiniteValue(from: rawValue(for: field)) else {
            throw PHCalculationError.invalidValue("Enter a valid value for \(field.title).")
        }
        return value
    }

    private func requiredPositive(_ field: PHInputField) throws -> Double {
        let value = try required(field)
        return try finitePositive(value, "\(field.accessibilityTitle) must be greater than zero.")
    }

    private func finitePositive(_ value: Double, _ message: String) throws -> Double {
        guard value.isFinite, value > 0 else {
            throw PHCalculationError.invalidValue(message)
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
        case .buffer: "Select unknown in equation"
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
    case weakAcid = "pH from Kₐ and [HA]"
    case weakBase = "pH from Kb and [A⁻]"
    case conjugateBase = "pH from Kₐ and [A⁻]"
    case conjugateAcid = "pH from Kb and [HA]"
    case kaFromPH = "Kₐ from pH and [HA]"
    case kbFromPH = "Kb from pH and [A⁻]"

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

private enum PHBufferConstantMode: String, CaseIterable, Identifiable {
    case pKa
    case ka

    var id: Self { self }

    var field: PHInputField {
        switch self {
        case .pKa: .pKa
        case .ka: .ka
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
        case .ka: "Kₐ"
        case .kb: "Kb"
        case .acid: "[HA]"
        case .base: "[A⁻]"
        case .pKa: "pKₐ"
        case .ratio: "[A⁻]/[HA] ratio"
        }
    }

    var accessibilityTitle: String {
        switch self {
        case .ka: "Ka"
        case .kb: "Kb"
        case .pKa: "pKa"
        default: title
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

private enum PHSymbol {
    case ka
    case kb
    case pKa
}

private struct PHSymbolText: View {
    let symbol: PHSymbol
    var font: Font
    var subscriptFont: Font
    var subscriptOffset: CGFloat

    init(
        _ symbol: PHSymbol,
        font: Font = .body,
        subscriptFont: Font = .caption,
        subscriptOffset: CGFloat = -3
    ) {
        self.symbol = symbol
        self.font = font
        self.subscriptFont = subscriptFont
        self.subscriptOffset = subscriptOffset
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            if symbol == .pKa {
                Text("p")
                    .font(font)
            }

            Text("K")
                .font(font)

            Text(symbol == .kb ? "b" : "a")
                .font(subscriptFont)
                .baselineOffset(subscriptOffset)
        }
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        switch symbol {
        case .ka: "Ka"
        case .kb: "Kb"
        case .pKa: "pKa"
        }
    }
}

#Preview {
    pHCalculatorView()
}
