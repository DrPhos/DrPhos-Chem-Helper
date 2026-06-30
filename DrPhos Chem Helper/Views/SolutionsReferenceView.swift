import SwiftUI

struct SolutionsView: View {
    @State private var mode: ConcentrationMode = .molarity
    @State private var unknown: ConcentrationVariable = .concentration
    @State private var concentration = ""
    @State private var top = ""
    @State private var bottom = ""
    @State private var concentrationResult = ""
    @State private var c1 = ""
    @State private var v1 = ""
    @State private var c2 = ""
    @State private var v2 = ""
    @State private var dilutionUnknown: DilutionVariable = .v2
    @State private var dilutionResult = ""
    @State private var decimals = 2
    @State private var error = ""

    private enum ConcentrationMode: String, CaseIterable, Identifiable {
        case molarity = "Molarity"
        case massMass = "Mass %"
        case massVolume = "Mass/volume %"
        case volumeVolume = "Volume %"
        var id: Self { self }
        var factor: Double { self == .molarity ? 1 : 100 }
        var symbol: String { self == .molarity ? "M" : "%" }
        var units: (String, String) {
            switch self {
            case .molarity: ("mol solute", "L solution")
            case .massMass: ("g solute", "g solution")
            case .massVolume: ("g solute", "mL solution")
            case .volumeVolume: ("mL solute", "mL solution")
            }
        }
    }

    private enum ConcentrationVariable: String, CaseIterable, Identifiable {
        case concentration = "Concentration", top = "Solute", bottom = "Solution"
        var id: Self { self }
    }

    private enum DilutionVariable: String, CaseIterable, Identifiable {
        case c1 = "C₁", v1 = "V₁", c2 = "C₂", v2 = "V₂"
        var id: Self { self }
    }

    var body: some View {
        DrPhosCalculatorScreen(
            title: "Solution Calculator",
            instructions: "Select the unknown, enter the known values, then calculate."
        ) {
            concentrationSection
            dilutionSection
            if !error.isEmpty { DrPhosValidationMessage(message: error) }
            DrPhosPrecisionControl(value: $decimals, range: 0...6)
            DrPhosActionButton("Clear all", systemImage: "xmark", style: .destructive, action: clear)
        }
    }

    private var concentrationSection: some View {
        DrPhosCalculatorSection(title: "Concentration") {
            Picker("Type", selection: $mode) {
                ForEach(ConcentrationMode.allCases) { Text($0.rawValue).tag($0) }
            }.pickerStyle(.menu)
            Picker("Unknown", selection: $unknown) {
                ForEach(ConcentrationVariable.allCases) { Text($0.rawValue).tag($0) }
            }.pickerStyle(.segmented)
            valueField("Concentration (\(mode.symbol))", text: $concentration, disabled: unknown == .concentration)
            valueField(mode.units.0, text: $top, disabled: unknown == .top)
            valueField(mode.units.1, text: $bottom, disabled: unknown == .bottom)
            DrPhosActionButton("Calculate concentration", systemImage: "equal", action: calculateConcentration)
            if !concentrationResult.isEmpty { DrPhosResultBox(text: concentrationResult) }
        }
    }

    private var dilutionSection: some View {
        DrPhosCalculatorSection(title: "Dilution — C₁V₁ = C₂V₂") {
            Picker("Unknown", selection: $dilutionUnknown) {
                ForEach(DilutionVariable.allCases) { Text($0.rawValue).tag($0) }
            }.pickerStyle(.segmented)
            valueField("C₁", text: $c1, disabled: dilutionUnknown == .c1)
            valueField("V₁", text: $v1, disabled: dilutionUnknown == .v1)
            valueField("C₂", text: $c2, disabled: dilutionUnknown == .c2)
            valueField("V₂", text: $v2, disabled: dilutionUnknown == .v2)
            DrPhosActionButton("Calculate dilution", systemImage: "equal", action: calculateDilution)
            if !dilutionResult.isEmpty { DrPhosResultBox(text: dilutionResult) }
        }
    }

    private func valueField(_ label: String, text: Binding<String>, disabled: Bool) -> some View {
        HStack {
            Text(label).frame(maxWidth: .infinity, alignment: .leading)
            TextField(disabled ? "Calculated" : "Enter value", text: text)
                .keyboardType(.decimalPad).textFieldStyle(.roundedBorder)
                .disabled(disabled).opacity(disabled ? 0.55 : 1)
                .frame(maxWidth: 180)
        }
    }

    private func calculateConcentration() {
        error = ""; concentrationResult = ""
        let factor = mode.factor
        switch unknown {
        case .concentration:
            guard let t = Double(top), let b = Double(bottom), b != 0 else { return invalid() }
            concentrationResult = "Concentration = \(format(t / b * factor)) \(mode.symbol)"
        case .top:
            guard let c = Double(concentration), let b = Double(bottom) else { return invalid() }
            concentrationResult = "\(mode.units.0) = \(format(c * b / factor))"
        case .bottom:
            guard let c = Double(concentration), let t = Double(top), c != 0 else { return invalid() }
            concentrationResult = "\(mode.units.1) = \(format(t * factor / c))"
        }
    }

    private func calculateDilution() {
        error = ""; dilutionResult = ""
        let result: Double?
        switch dilutionUnknown {
        case .c1: result = divide(c2, times: v2, by: v1)
        case .v1: result = divide(c2, times: v2, by: c1)
        case .c2: result = divide(c1, times: v1, by: v2)
        case .v2: result = divide(c1, times: v1, by: c2)
        }
        guard let result else { return invalid() }
        dilutionResult = "\(dilutionUnknown.rawValue) = \(format(result))"
    }

    private func divide(_ first: String, times second: String, by divisor: String) -> Double? {
        guard let a = Double(first), let b = Double(second), let d = Double(divisor), d != 0 else { return nil }
        return a * b / d
    }

    private func format(_ value: Double) -> String { String(format: "%.*f", decimals, value) }
    private func invalid() { error = "Enter valid values for all known quantities." }
    private func clear() {
        concentration = ""; top = ""; bottom = ""; concentrationResult = ""
        c1 = ""; v1 = ""; c2 = ""; v2 = ""; dilutionResult = ""; error = ""
    }
}

#Preview { SolutionsView() }
