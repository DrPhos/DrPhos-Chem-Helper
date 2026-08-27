import Foundation

enum QuadraticSolution: Equatable {
    case twoReal(Double, Double)
    case oneReal(Double)
    case noReal
    case notQuadratic
}

struct QuadraticCalculator {
    static func solve(a: Double, b: Double, c: Double) -> QuadraticSolution {
        guard a != 0 else { return .notQuadratic }

        let discriminant = b * b - 4 * a * c
        if discriminant < 0 {
            return .noReal
        }
        if discriminant == 0 {
            return .oneReal(-b / (2 * a))
        }

        let root = sqrt(discriminant)
        return .twoReal((-b + root) / (2 * a), (-b - root) / (2 * a))
    }
}

struct PHResult: Equatable {
    let pH: Double
    let hydronium: Double
    let hydroxide: Double
}

struct PHCalculator {
    static let waterIonProduct = 1e-14

    static func from(pH: Double) -> PHResult? {
        guard pH.isFinite else { return nil }
        let hydronium = pow(10, -pH)
        return PHResult(
            pH: pH,
            hydronium: hydronium,
            hydroxide: waterIonProduct / hydronium
        )
    }

    static func fromHydronium(_ hydronium: Double) -> PHResult? {
        guard hydronium.isFinite, hydronium > 0 else { return nil }
        return PHResult(
            pH: -log10(hydronium),
            hydronium: hydronium,
            hydroxide: waterIonProduct / hydronium
        )
    }

    static func fromHydroxide(_ hydroxide: Double) -> PHResult? {
        guard hydroxide.isFinite, hydroxide > 0 else { return nil }
        let hydronium = waterIonProduct / hydroxide
        return PHResult(
            pH: -log10(hydronium),
            hydronium: hydronium,
            hydroxide: hydroxide
        )
    }

    static func solutionType(for pH: Double) -> String {
        if pH < 7 { return "acidic" }
        if pH > 7 { return "basic" }
        return "neutral"
    }
}

enum ScientificCalculatorClearMode: Equatable {
    case all
    case operation

    init(hasPendingOperation: Bool) {
        self = hasPendingOperation ? .operation : .all
    }
}

struct ScientificCalculatorInput: Equatable {
    private(set) var value = "0"
    private(set) var startsNewNumber = true
    private(set) var isEnteringExponent = false

    mutating func enterDigit(_ digit: Int) {
        precondition((0...9).contains(digit))

        if isEnteringExponent {
            guard value.contains("e") else { return }
            value += String(digit)
        } else if startsNewNumber {
            value = String(digit)
            startsNewNumber = false
        } else {
            value += String(digit)
        }
    }

    mutating func enterDecimal() {
        if startsNewNumber {
            value = "0."
            startsNewNumber = false
        } else if !currentMantissa.contains(".") {
            value += "."
        }
    }

    mutating func beginNewNumber() {
        startsNewNumber = true
        isEnteringExponent = false
    }

    mutating func beginExponent() {
        guard !startsNewNumber, !value.contains("e") else { return }
        value += "e"
        isEnteringExponent = true
    }

    mutating func toggleSign() {
        if isEnteringExponent, value.contains("e") {
            value = value.contains("e-")
                ? value.replacingOccurrences(of: "e-", with: "e")
                : value.replacingOccurrences(of: "e", with: "e-")
        } else if let number = Double(value) {
            value = String(number * -1)
        }
    }

    mutating func backspace() {
        guard !startsNewNumber, value != "0" else { return }
        value.removeLast()
        if value.isEmpty {
            value = "0"
            startsNewNumber = true
        }
        if !value.contains("e") {
            isEnteringExponent = false
        }
    }

    mutating func replaceValue(with newValue: String, startsNewNumber: Bool = false) {
        value = newValue
        self.startsNewNumber = startsNewNumber
        isEnteringExponent = false
    }

    mutating func clear() {
        self = ScientificCalculatorInput()
    }

    mutating func clear(for mode: ScientificCalculatorClearMode) {
        guard mode == .all else { return }
        clear()
    }

    private var currentMantissa: Substring {
        value.split(separator: "e", omittingEmptySubsequences: false)[0]
    }
}

enum ScientificCalculatorPrimaryDisplayFormatter {
    private static let locale = Locale(identifier: "en_US_POSIX")
    static let characterLimit = 12

    static func format(
        _ value: Double,
        characterLimit: Int = characterLimit
    ) -> String {
        guard value.isFinite else { return "Error" }

        if let decimal = fittedResult(
            value,
            style: .decimal,
            characterLimit: characterLimit
        ) {
            return decimal
        }

        return fittedResult(
            value,
            style: .scientific,
            characterLimit: characterLimit
        ) ?? "Error"
    }

    static func normal(_ value: String, significantFigures: Int) -> String {
        guard let number = Double(value) else { return value }
        guard number != 0 else { return "0" }

        let magnitude = floor(log10(abs(number)))
        let scale = pow(10, Double(significantFigures) - 1 - magnitude)
        let rounded = (number * scale).rounded() / scale

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesSignificantDigits = true
        formatter.maximumSignificantDigits = significantFigures
        formatter.minimumSignificantDigits = significantFigures
        return formatter.string(from: NSNumber(value: rounded)) ?? String(rounded)
    }

    static func scientific(_ value: String, significantFigures: Int) -> String {
        guard let number = Double(value) else { return value }

        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.maximumSignificantDigits = significantFigures
        formatter.minimumSignificantDigits = significantFigures
        formatter.exponentSymbol = "e"

        guard let formatted = formatter.string(from: NSNumber(value: number)) else {
            return String(number)
        }
        return scientificDisplayString(formatted)
    }

    private static func fittedResult(
        _ value: Double,
        style: NumberFormatter.Style,
        characterLimit: Int
    ) -> String? {
        guard characterLimit > 0 else { return nil }

        for significantDigits in stride(from: 15, through: 1, by: -1) {
            let formatter = NumberFormatter()
            formatter.locale = locale
            formatter.numberStyle = style
            formatter.usesGroupingSeparator = false
            formatter.usesSignificantDigits = true
            formatter.maximumSignificantDigits = significantDigits
            formatter.minimumSignificantDigits = 1
            formatter.maximumFractionDigits = 340
            formatter.exponentSymbol = "e"

            guard let formatted = formatter.string(from: NSNumber(value: value)) else {
                continue
            }

            let candidate = style == .scientific
                ? scientificDisplayString(formatted)
                : formatted

            if candidate.count <= characterLimit {
                return candidate
            }
        }

        return nil
    }

    private static func scientificDisplayString(_ value: String) -> String {
        let parts = value.components(separatedBy: "e")
        guard parts.count == 2 else { return value }

        let exponent = Int(parts[1]).map(String.init) ?? parts[1]
        return parts[0] + "×10" + superscript(exponent)
    }

    private static func superscript(_ exponent: String) -> String {
        let characters: [Character: Character] = [
            "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴",
            "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹",
            "-": "⁻", "+": "+"
        ]
        return String(exponent.compactMap { characters[$0] })
    }
}
