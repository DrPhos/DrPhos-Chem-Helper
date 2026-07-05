import SwiftUI

struct QuadradicEquationSolverView: View {
    @State private var a = ""
    @State private var b = ""
    @State private var c = ""
    @State private var solution = ""
    @State private var validationMessage = ""
    @State private var activeField: Field?

    private enum Field {
        case a, b, c

        var label: String {
            switch self {
            case .a: "a"
            case .b: "b"
            case .c: "c"
            }
        }
    }

    var body: some View {
        NavigationStack {
            DrPhosCalculatorScreen(
                title: "Quadratic Equation Solver",
                instructions: "Enter the coefficients for ax² + bx + c = 0."
            ) {
                DrPhosCalculatorSection(title: "Equation") {
                    VStack(spacing: 16) {
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
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if let activeField, let value = binding(for: activeField) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Editing coefficient \(activeField.label)")
                            .font(.headline)
                        CustomNumericKeypad(
                            value: value,
                            isActive: Binding(
                                get: { self.activeField != nil },
                                set: { if !$0 { self.activeField = nil } }
                            )
                        )
                        .id(activeField)
                    }
                    .frame(maxWidth: 680)
                    .padding()
                    .background(.regularMaterial)
                    .overlay(alignment: .top) { Divider() }
                    .shadow(color: .black.opacity(0.12), radius: 8, y: -2)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.18), value: activeField)
        }
    }

    @ViewBuilder
    private var coefficientFields: some View {
        coefficientField(label: "a", value: a, field: .a)
        coefficientField(label: "b", value: b, field: .b)
        coefficientField(label: "c", value: c, field: .c)
    }

    private func coefficientField(
        label: String,
        value: String,
        field: Field
    ) -> some View {
        VStack(spacing: 6) {
            Button {
                activeField = field
            } label: {
                Text(value.isEmpty ? "Enter \(label)" : value)
                    .font(.body.monospacedDigit())
                    .foregroundStyle(value.isEmpty ? .secondary : .primary)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(.background, in: RoundedRectangle(cornerRadius: 7))
                    .overlay {
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(activeField == field ? Color.accentColor : Color.secondary.opacity(0.35), lineWidth: 1.5)
                    }
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(label)
            .accessibilityValue(value.isEmpty ? "Empty" : value)

            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 84, maxWidth: 140)
    }

    private func binding(for field: Field?) -> Binding<String>? {
        switch field {
        case .a: $a
        case .b: $b
        case .c: $c
        case .none: nil
        }
    }

    private func solve() {
        dismissKeypad()
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
        dismissKeypad()
        a = ""
        b = ""
        c = ""
        solution = ""
        validationMessage = ""
    }

    private func dismissKeypad() {
        activeField = nil
    }
}

#Preview {
    QuadradicEquationSolverView()
}
