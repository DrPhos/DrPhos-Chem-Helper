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

    private var currentMantissa: Substring {
        value.split(separator: "e", omittingEmptySubsequences: false)[0]
    }
}
