import SwiftUI

struct QuadradicEquationSolverView: View {
    @State private var a = ""
    @State private var b = ""
    @State private var c = ""
    @State private var solution = ""
    @State private var validationMessage = ""
    @State private var activeField: Binding<String>?
    @FocusState private var focusedField: Field?

    private enum Field {
        case a, b, c
    }

    var body: some View {
        NavigationStack {
            DrPhosCalculatorScreen(
                title: "Quadratic Equation Solver",
                instructions: "Enter the coefficients for ax² + bx + c = 0."
            ) {
                DrPhosCalculatorSection(title: "Equation") {
                    VStack(spacing: 16) {
                        NumbersView(compoundFormula: activeField ?? .constant(""))
                        NumbersSecondRowView(compoundFormula: activeField ?? .constant(""))

                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: 16) { coefficientFields }
                            VStack(spacing: 12) { coefficientFields }
                        }
                    }
                }

                if !validationMessage.isEmpty {
                    DrPhosValidationMessage(message: validationMessage)
                }

                HStack(spacing: 12) {
                    DrPhosActionButton("Solve", systemImage: "equal", action: solve)
                    DrPhosActionButton("Clear", systemImage: "xmark", style: .destructive, action: clear)
                }

                if !solution.isEmpty {
                    DrPhosResultBox(text: solution)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    CustomKeyboardToolbar(activeField: $activeField)
                }
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
                focusedField = nil
                activeField = nil
            }
        }
    }

    @ViewBuilder
    private var coefficientFields: some View {
        coefficientField(label: "a", prompt: "Enter a", text: $a, field: .a)
        coefficientField(label: "b", prompt: "Enter b", text: $b, field: .b)
        coefficientField(label: "c", prompt: "Enter c", text: $c, field: .c)
    }

    private func coefficientField(
        label: String,
        prompt: String,
        text: Binding<String>,
        field: Field
    ) -> some View {
        DrPhosLabeledNumberField(
            label: label,
            prompt: prompt,
            text: text,
            focus: $focusedField,
            focusValue: field
        )
        .onTapGesture { activeField = text }
    }

    private func solve() {
        dismissKeyboard()
        validationMessage = ""
        solution = ""

        guard let aValue = Double(a), let bValue = Double(b), let cValue = Double(c) else {
            validationMessage = "Enter a valid number for each coefficient."
            return
        }

        switch QuadraticCalculator.solve(a: aValue, b: bValue, c: cValue) {
        case .noReal:
            solution = "No real solutions"
        case .oneReal(let x):
            solution = "x = \(x)"
        case .twoReal(let x1, let x2):
            solution = "x₁ = \(x1)\nx₂ = \(x2)"
        case .notQuadratic:
            validationMessage = "The coefficient a must not be zero."
        }
    }

    private func clear() {
        dismissKeyboard()
        a = ""
        b = ""
        c = ""
        solution = ""
        validationMessage = ""
    }

    private func dismissKeyboard() {
        UIApplication.shared.endEditing()
        focusedField = nil
        activeField = nil
    }
}

#Preview {
    QuadradicEquationSolverView()
}
