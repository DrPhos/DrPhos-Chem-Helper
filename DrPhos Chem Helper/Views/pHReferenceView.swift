import SwiftUI

struct pHCalculatorView: View {
    @StateObject private var viewModel = pHViewModel()
    @State private var inputVariable: InputVariable = .pH
    @State private var showsWeakCalculations = false
    @State private var activeField: Binding<String>?
    @FocusState private var focusedField: Field?

    private enum InputVariable: String, CaseIterable, Identifiable {
        case pH = "pH"
        case hydronium = "[H₃O⁺]"
        case hydroxide = "[OH⁻]"
        var id: Self { self }
    }

    private enum Field: Hashable {
        case primary, ka, kb, acid, base
    }

    var body: some View {
        NavigationStack {
            DrPhosCalculatorScreen(
                title: "pH Calculator",
                instructions: "Choose one known value and calculate the remaining equilibrium values."
            ) {
                strongCalculationSection

                if isError {
                    DrPhosValidationMessage(message: viewModel.message)
                }

                HStack(spacing: 12) {
                    DrPhosActionButton("Calculate", systemImage: "equal", action: calculateStrong)
                    DrPhosActionButton("Clear", systemImage: "xmark", style: .destructive, action: clear)
                }

                if !strongResult.isEmpty {
                    DrPhosResultBox(text: strongResult)
                }

                weakCalculationSection
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    CustomKeyboardToolbar(activeField: $activeField)
                }
            }
            .onTapGesture(perform: dismissKeyboard)
        }
    }

    private var strongCalculationSection: some View {
        DrPhosCalculatorSection(title: "Strong acid or base") {
            Picker("Known value", selection: $inputVariable) {
                ForEach(InputVariable.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            HStack {
                Text(inputVariable.rawValue)
                    .font(.headline)
                    .frame(minWidth: 74, alignment: .leading)
                TextField("Enter \(inputVariable.rawValue)", text: primaryInput)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .primary)
                    .onTapGesture { activeField = primaryInput }
            }

            DrPhosPrecisionControl(value: decimalPlaces, range: 0...6)
        }
    }

    private var weakCalculationSection: some View {
        DrPhosCalculatorSection(title: "Weak acid or base") {
            DisclosureGroup("Advanced equilibrium calculation", isExpanded: $showsWeakCalculations) {
                VStack(spacing: 12) {
                    weakField("Ka", text: binding(\.KaEntered), field: .ka)
                    weakField("Kb", text: binding(\.KbEntered), field: .kb)
                    weakField("[HA]", text: binding(\.HAEntered), field: .acid)
                    weakField("[A⁻]", text: binding(\.AEntered), field: .base)
                    Text("Enter a valid supported pair, such as Ka and [HA], or Kb and [A⁻].")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    DrPhosActionButton("Calculate weak solution", systemImage: "function", action: calculateWeak)
                }
                .padding(.top, 12)
            }
        }
    }

    private func weakField(_ label: String, text: Binding<String>, field: Field) -> some View {
        HStack {
            Text(label).frame(width: 48, alignment: .leading)
            TextField("Enter \(label)", text: text)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: field)
                .onTapGesture { activeField = text }
        }
    }

    private var value: pHValues { viewModel.pHValue[0] }
    private var isError: Bool {
        !viewModel.message.isEmpty && viewModel.message != "values calculated successfully"
    }

    private var strongResult: String {
        var lines: [String] = []
        let pH = value.pHEntered.isEmpty ? value.pHCalculated : value.pHEntered
        let hydronium = value.H3OEntered.isEmpty ? value.H3OCalculated : value.H3OEntered
        let hydroxide = value.OHEntered.isEmpty ? value.OHCalculated : value.OHEntered
        if !pH.isEmpty { lines.append("pH = \(pH)") }
        if !hydronium.isEmpty { lines.append("[H₃O⁺] = \(hydronium) M") }
        if !hydroxide.isEmpty { lines.append("[OH⁻] = \(hydroxide) M") }
        if !value.KaCalculated.isEmpty { lines.append("Ka = \(value.KaCalculated)") }
        if !value.KbCalculated.isEmpty { lines.append("Kb = \(value.KbCalculated)") }
        if !viewModel.solutionType.isEmpty { lines.append("Solution is \(viewModel.solutionType).") }
        return lines.joined(separator: "\n")
    }

    private var primaryInput: Binding<String> {
        switch inputVariable {
        case .pH: binding(\.pHEntered)
        case .hydronium: binding(\.H3OEntered)
        case .hydroxide: binding(\.OHEntered)
        }
    }

    private var decimalPlaces: Binding<Int> { binding(\.decimalPlaces) }

    private func binding<Value>(_ keyPath: WritableKeyPath<pHValues, Value>) -> Binding<Value> {
        Binding(
            get: { viewModel.pHValue[0][keyPath: keyPath] },
            set: { viewModel.pHValue[0][keyPath: keyPath] = $0 }
        )
    }

    private func calculateStrong() {
        dismissKeyboard()
        clearOtherStrongInputs()
        viewModel.calculate()
    }

    private func clearOtherStrongInputs() {
        switch inputVariable {
        case .pH:
            viewModel.pHValue[0].H3OEntered = ""
            viewModel.pHValue[0].OHEntered = ""
        case .hydronium:
            viewModel.pHValue[0].pHEntered = ""
            viewModel.pHValue[0].OHEntered = ""
        case .hydroxide:
            viewModel.pHValue[0].pHEntered = ""
            viewModel.pHValue[0].H3OEntered = ""
        }
    }

    private func calculateWeak() {
        dismissKeyboard()
        viewModel.calculateWeak()
    }

    private func clear() {
        dismissKeyboard()
        viewModel.clearValues()
    }

    private func dismissKeyboard() {
        UIApplication.shared.endEditing()
        focusedField = nil
        activeField = nil
    }
}

#Preview {
    pHCalculatorView()
}
