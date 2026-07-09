import SwiftUI

struct DrPhosCalculatorScreen<Content: View>: View {
    let title: String
    let instructions: String?
    let content: Content

    init(title: String, instructions: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.instructions = instructions
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.sectionSpacing) {
                DrPhosSectionHeader(title: title)
                if let instructions {
                    Text(instructions)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                content
            }
            .frame(maxWidth: AppTheme.readableContentWidth)
            .frame(maxWidth: .infinity)
            .padding(AppTheme.screenPadding)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

struct DrPhosCalculatorSection<Content: View>: View {
    let title: String?
    let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title { Text(title).font(.headline) }
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}

struct DrPhosLabeledNumberField<FocusValue: Hashable>: View {
    let label: String
    let prompt: String
    @Binding var text: String
    let focus: FocusState<FocusValue?>.Binding
    let focusValue: FocusValue

    var body: some View {
        VStack(spacing: 6) {
            TextField(prompt, text: $text)
                .keyboardType(.decimalPad)
                .frame(minHeight: 44)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .focused(focus, equals: focusValue)
                .accessibilityLabel(label)
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 84, maxWidth: 140)
    }
}

enum DrPhosActionStyle {
    case primary, secondary, destructive

    var color: Color {
        switch self {
        case .primary: AppTheme.enterButtonColor
        case .secondary: .secondary
        case .destructive: AppTheme.clearButtonColor
        }
    }
}

struct DrPhosActionButton: View {
    let title: String
    let systemImage: String?
    let style: DrPhosActionStyle
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, style: DrPhosActionStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage { Label(title, systemImage: systemImage) }
                else { Text(title) }
            }
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.borderedProminent)
        .tint(style.color)
    }
}

struct DrPhosValidationMessage: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.subheadline)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("Error: \(message)")
    }
}

struct DrPhosDecimalControl: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    var label: String = "Decimals"

    var body: some View {
        HStack(spacing: 6) {
            Button {
                value = clamped(value - 1)
            } label: {
                Image(systemName: "minus.circle")
            }
            .buttonStyle(.plain)
            .disabled(value <= range.lowerBound)

            VStack(spacing: 0) {
                Text(label)
                    .font(.caption2)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                Text("\(value)")
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .accessibilityHidden(true)
            }

            Button {
                value = clamped(value + 1)
            } label: {
                Image(systemName: "plus.circle")
            }
            .buttonStyle(.plain)
            .disabled(value >= range.upperBound)
        }
        .foregroundStyle(Color.numbers)
        .onAppear {
            value = clamped(value)
        }
        .onChange(of: value) { _, newValue in
            value = clamped(newValue)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Decimal places")
        .accessibilityValue("\(value)")
    }

    private func clamped(_ newValue: Int) -> Int {
        min(max(newValue, range.lowerBound), range.upperBound)
    }
}

struct DrPhosPrecisionControl: View {
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        DrPhosDecimalControl(value: $value, range: range)
    }
}
