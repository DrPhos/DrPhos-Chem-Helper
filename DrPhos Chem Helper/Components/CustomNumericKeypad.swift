import SwiftUI

enum CustomNumericInputEditor {
    static func appendingDigit(_ digit: Character, to value: String) -> String {
        guard digit.isNumber else { return value }
        return value + String(digit)
    }

    static func appendingDecimal(to value: String) -> String {
        guard exponentIndex(in: value) == nil else { return value }
        let unsignedMantissa = value.hasPrefix("-") ? String(value.dropFirst()) : value
        guard !unsignedMantissa.contains(".") else { return value }
        if value.isEmpty { return "0." }
        if value == "-" { return "-0." }
        return value + "."
    }

    static func insertingExponentMarker(in value: String) -> String {
        guard exponentIndex(in: value) == nil,
              let number = Double(value),
              number.isFinite else {
            return value
        }
        return value + "e"
    }

    static func togglingSign(of value: String) -> String {
        guard let exponentIndex = exponentIndex(in: value) else {
            return value.hasPrefix("-") ? String(value.dropFirst()) : "-" + value
        }

        let exponentStart = value.index(after: exponentIndex)
        let throughMarker = String(value[...exponentIndex])
        let exponent = String(value[exponentStart...])
        return exponent.hasPrefix("-")
            ? throughMarker + exponent.dropFirst()
            : throughMarker + "-" + exponent
    }

    static func deletingLastCharacter(from value: String) -> String {
        value.isEmpty ? value : String(value.dropLast())
    }

    static func parsedFiniteValue(from value: String) -> Double? {
        guard let number = Double(value), number.isFinite else { return nil }
        return number
    }

    private static func exponentIndex(in value: String) -> String.Index? {
        value.firstIndex(where: { $0 == "e" || $0 == "E" })
    }
}

struct CustomNumericKeypad: View {
    @Binding var value: String
    @Binding var isActive: Bool
    var showsDisplay = true

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        VStack(spacing: 12) {
            if showsDisplay {
                Button {
                    isActive = true
                } label: {
                    HStack {
                        Text(value.isEmpty ? "Tap to enter a value" : value)
                            .foregroundStyle(value.isEmpty ? .secondary : .primary)
                        Spacer()
                    }
                    .font(.title2.monospacedDigit())
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(.background, in: RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isActive ? Color.accentColor : Color.secondary.opacity(0.35), lineWidth: 1.5)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Numeric value")
                .accessibilityValue(value.isEmpty ? "Empty" : value)
            }

            if isActive {
                LazyVGrid(columns: columns, spacing: 10) {
                    digitButton("7")
                    digitButton("8")
                    digitButton("9")
                    actionButton("Delete", systemImage: "delete.left") {
                        value = CustomNumericInputEditor.deletingLastCharacter(from: value)
                    }

                    digitButton("4")
                    digitButton("5")
                    digitButton("6")
                    actionButton("Clear") { value = "" }

                    digitButton("1")
                    digitButton("2")
                    digitButton("3")
                    actionButton("+/−") {
                        value = CustomNumericInputEditor.togglingSign(of: value)
                    }

                    actionButton(".") {
                        value = CustomNumericInputEditor.appendingDecimal(to: value)
                    }
                    digitButton("0")
                    actionButton("×10^") {
                        value = CustomNumericInputEditor.insertingExponentMarker(in: value)
                    }
                    actionButton("Done", tint: .accentColor) {
                        isActive = false
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.18), value: isActive)
    }

    private func digitButton(_ digit: Character) -> some View {
        Button(String(digit)) {
            value = CustomNumericInputEditor.appendingDigit(digit, to: value)
        }
        .buttonStyle(NumericKeyButtonStyle())
    }

    private func actionButton(
        _ title: String,
        systemImage: String? = nil,
        tint: Color = .secondary,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            if let systemImage {
                Image(systemName: systemImage)
            } else {
                Text(title)
            }
        }
        .buttonStyle(NumericKeyButtonStyle(tint: tint))
        .accessibilityLabel(title)
    }
}

private struct NumericKeyButtonStyle: ButtonStyle {
    var tint: Color = .secondary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 50)
            .contentShape(Rectangle())
            .background(
                tint.opacity(configuration.isPressed ? 0.3 : 0.14),
                in: RoundedRectangle(cornerRadius: 10)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}
