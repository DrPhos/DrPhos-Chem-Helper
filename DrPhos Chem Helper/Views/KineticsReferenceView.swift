import SwiftUI

struct KineticsView: View {
    @StateObject private var viewModel = KineticsNumbersViewModel()
    @State private var unknown: KineticsVariable = .time
    @State private var activeField: Binding<String>?
    @FocusState private var focusedField: KineticsField?

    private enum KineticsVariable: String, CaseIterable, Identifiable {
        case rateConstant = "Rate constant"
        case initialConcentration = "Initial concentration"
        case finalConcentration = "Final concentration"
        case time = "Time"

        var id: Self { self }
    }

    private enum KineticsField: Hashable {
        case rateConstant, initialConcentration, finalConcentration, time, halfLife
    }

    var body: some View {
        NavigationStack {
            DrPhosCalculatorScreen(
                title: "Kinetics Calculator",
                instructions: "Choose the reaction order, select the unknown, and enter the other three values."
            ) {
                reactionSection
                variablesSection

                if let error = viewModel.errorMessage {
                    DrPhosValidationMessage(message: error.replacingOccurrences(of: "\n", with: " "))
                }

                HStack(spacing: 12) {
                    DrPhosActionButton("Calculate", systemImage: "equal", action: calculate)
                    DrPhosActionButton("Clear", systemImage: "xmark", style: .destructive, action: clear)
                }

                if !resultText.isEmpty {
                    DrPhosResultBox(text: resultText)
                }

                halfLifeSection
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    CustomKeyboardToolbar(activeField: $activeField)
                }
            }
            .onTapGesture(perform: dismissKeyboard)
        }
    }

    private var reactionSection: some View {
        DrPhosCalculatorSection(title: "Reaction") {
            Picker("Reaction order", selection: $viewModel.selectedOrder) {
                ForEach(viewModel.orders, id: \.self, content: Text.init)
            }
            .pickerStyle(.segmented)

            Picker("Time unit", selection: $viewModel.selectedTimeUnit) {
                ForEach(viewModel.timeUnits, id: \.self, content: Text.init)
            }
            .pickerStyle(.menu)

            Picker("Calculate", selection: $unknown) {
                ForEach(KineticsVariable.allCases) { variable in
                    Text(variable.rawValue).tag(variable)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var variablesSection: some View {
        DrPhosCalculatorSection(title: "Known values") {
            VStack(spacing: 12) {
                kineticsField(
                    title: "Rate constant",
                    prompt: "Enter k",
                    text: rateConstantBinding,
                    unit: rateConstantUnit,
                    variable: .rateConstant,
                    focus: .rateConstant
                )
                kineticsField(
                    title: "Initial concentration",
                    prompt: "Enter [A]₀",
                    text: initialBinding,
                    unit: "concentration",
                    variable: .initialConcentration,
                    focus: .initialConcentration
                )
                kineticsField(
                    title: "Final concentration",
                    prompt: "Enter [A]ₜ",
                    text: finalBinding,
                    unit: "concentration",
                    variable: .finalConcentration,
                    focus: .finalConcentration
                )
                kineticsField(
                    title: "Time",
                    prompt: "Enter time",
                    text: timeBinding,
                    unit: timeUnit,
                    variable: .time,
                    focus: .time
                )
                DrPhosPrecisionControl(value: decimalPlacesBinding, range: 0...6)
            }
        }
    }

    private var halfLifeSection: some View {
        DrPhosCalculatorSection(title: "Half-life shortcut") {
            Text("Calculate k from a known half-life. Zero- and second-order reactions also require the initial concentration above.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack {
                TextField("Enter half-life", text: halfLifeBinding)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .halfLife)
                    .onTapGesture { activeField = halfLifeBinding }
                Text(timeUnit).foregroundStyle(.secondary)
            }

            DrPhosActionButton("Calculate k", systemImage: "function", action: calculateRateConstantFromHalfLife)
        }
    }

    private func kineticsField(
        title: String,
        prompt: String,
        text: Binding<String>,
        unit: String,
        variable: KineticsVariable,
        focus: KineticsField
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline.weight(.semibold))
            HStack {
                TextField(prompt, text: text)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: focus)
                    .disabled(unknown == variable)
                    .opacity(unknown == variable ? 0.55 : 1)
                    .onTapGesture { activeField = text }
                    .accessibilityHint(unknown == variable ? "Selected as the value to calculate" : "Enter a known value")
                Text(unit)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 72, alignment: .leading)
            }
        }
    }

    private var values: KineticsNumbers { viewModel.kineticsNumbers[0] }
    private var timeUnit: String { viewModel.timeUnitAbbreviations[viewModel.selectedTimeUnit] ?? "" }
    private var rateConstantUnit: String {
        (viewModel.rateConstantUnits[viewModel.selectedOrder] ?? "")
            .replacingOccurrences(of: "timeUnits", with: timeUnit)
    }

    private var resultText: String {
        var lines: [String] = []
        if !values.rateConstantCalculated.isEmpty { lines.append("k = \(values.rateConstantCalculated) \(rateConstantUnit)") }
        if !values.initialConcCalculated.isEmpty { lines.append("[A]₀ = \(values.initialConcCalculated)") }
        if !values.finalConcCalculated.isEmpty { lines.append("[A]ₜ = \(values.finalConcCalculated)") }
        if !values.timeCalculated.isEmpty { lines.append("t = \(values.timeCalculated) \(timeUnit)") }
        if !values.halfLifeCalculated.isEmpty { lines.append("t½ = \(values.halfLifeCalculated) \(timeUnit)") }
        return lines.joined(separator: "\n")
    }

    private var rateConstantBinding: Binding<String> { binding(\.rateConstantEntered) }
    private var initialBinding: Binding<String> { binding(\.initialConcEntered) }
    private var finalBinding: Binding<String> { binding(\.finalConcEntered) }
    private var timeBinding: Binding<String> { binding(\.timeEntered) }
    private var halfLifeBinding: Binding<String> { binding(\.halfLifeEntered) }
    private var decimalPlacesBinding: Binding<Int> { binding(\.decimalPlaces) }

    private func binding<Value>(_ keyPath: WritableKeyPath<KineticsNumbers, Value>) -> Binding<Value> {
        Binding(
            get: { viewModel.kineticsNumbers[0][keyPath: keyPath] },
            set: { viewModel.kineticsNumbers[0][keyPath: keyPath] = $0 }
        )
    }

    private func calculate() {
        dismissKeyboard()
        clearUnknownInput()
        viewModel.calculate()
    }

    private func clearUnknownInput() {
        switch unknown {
        case .rateConstant: viewModel.kineticsNumbers[0].rateConstantEntered = ""
        case .initialConcentration: viewModel.kineticsNumbers[0].initialConcEntered = ""
        case .finalConcentration: viewModel.kineticsNumbers[0].finalConcEntered = ""
        case .time: viewModel.kineticsNumbers[0].timeEntered = ""
        }
    }

    private func calculateRateConstantFromHalfLife() {
        dismissKeyboard()
        var number = viewModel.kineticsNumbers[0]
        viewModel.calculateKFromHalfLife(for: &number)
        viewModel.kineticsNumbers[0] = number
        if number.calculatedkFromHalfLife.isEmpty {
            viewModel.errorMessage = "Enter a valid half-life and any required initial concentration."
        } else {
            viewModel.errorMessage = nil
        }
    }

    private func clear() {
        dismissKeyboard()
        viewModel.clearAllNumbers()
    }

    private func dismissKeyboard() {
        UIApplication.shared.endEditing()
        focusedField = nil
        activeField = nil
    }
}

#Preview {
    KineticsView()
}
