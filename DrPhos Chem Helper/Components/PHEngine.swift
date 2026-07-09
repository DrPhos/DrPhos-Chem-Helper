import Foundation

enum PHSolutionClassification: String, Equatable {
    case acidic
    case neutral
    case basic
}

struct PHStrongResult: Equatable {
    let pH: Double
    let pOH: Double
    let hydronium: Double
    let hydroxide: Double
    let classification: PHSolutionClassification
}

struct PHWeakResult: Equatable {
    let pH: Double
    let pOH: Double
    let hydronium: Double
    let hydroxide: Double
    let classification: PHSolutionClassification
}

enum PHCalculationError: Error, Equatable, LocalizedError {
    case invalidValue(String)

    var errorDescription: String? {
        switch self {
        case .invalidValue(let message):
            message
        }
    }
}

enum PHEngine {
    static let waterIonProduct = 1e-14

    static func fromPH(_ pH: Double) throws -> PHStrongResult {
        try finite(pH, "Enter a finite pH value.")
        let hydronium = pow(10, -pH)
        let hydroxide = waterIonProduct / hydronium
        return try strongResult(pH: pH, hydronium: hydronium, hydroxide: hydroxide)
    }

    static func fromHydronium(_ hydronium: Double) throws -> PHStrongResult {
        let hydronium = try positive(hydronium, "Enter an [H₃O⁺] concentration greater than zero.")
        let pH = -log10(hydronium)
        let hydroxide = waterIonProduct / hydronium
        return try strongResult(pH: pH, hydronium: hydronium, hydroxide: hydroxide)
    }

    static func fromHydroxide(_ hydroxide: Double) throws -> PHStrongResult {
        let hydroxide = try positive(hydroxide, "Enter an [OH⁻] concentration greater than zero.")
        let pOH = -log10(hydroxide)
        let pH = 14 - pOH
        let hydronium = waterIonProduct / hydroxide
        return try strongResult(pH: pH, hydronium: hydronium, hydroxide: hydroxide)
    }

    static func classification(for pH: Double) -> PHSolutionClassification {
        if pH < 7 { return .acidic }
        if pH > 7 { return .basic }
        return .neutral
    }

    static func weakAcidPH(ka: Double, initialAcidConcentration: Double) throws -> PHWeakResult {
        let ka = try positive(ka, "Enter a Ka greater than zero.")
        let concentration = try positive(initialAcidConcentration, "Enter an initial acid concentration greater than zero.")
        let hydronium = try positiveQuadraticRoot(constant: ka, concentration: concentration)
        let pH = -log10(hydronium)
        return try weakResult(pH: pH, hydronium: hydronium)
    }

    static func weakBasePH(kb: Double, initialBaseConcentration: Double) throws -> PHWeakResult {
        let kb = try positive(kb, "Enter a Kb greater than zero.")
        let concentration = try positive(initialBaseConcentration, "Enter an initial base concentration greater than zero.")
        let hydroxide = try positiveQuadraticRoot(constant: kb, concentration: concentration)
        let hydronium = waterIonProduct / hydroxide
        let pH = -log10(hydronium)
        return try weakResult(pH: pH, hydronium: hydronium)
    }

    static func conjugateBasePH(ka: Double, initialConjugateBaseConcentration: Double) throws -> PHWeakResult {
        let ka = try positive(ka, "Enter a Ka greater than zero.")
        let kb = waterIonProduct / ka
        return try weakBasePH(kb: kb, initialBaseConcentration: initialConjugateBaseConcentration)
    }

    static func conjugateAcidPH(kb: Double, initialConjugateAcidConcentration: Double) throws -> PHWeakResult {
        let kb = try positive(kb, "Enter a Kb greater than zero.")
        let ka = waterIonProduct / kb
        return try weakAcidPH(ka: ka, initialAcidConcentration: initialConjugateAcidConcentration)
    }

    static func kaFromPH(pH: Double, acidConcentration: Double) throws -> Double {
        try finite(pH, "Enter a finite pH value.")
        let concentration = try positive(acidConcentration, "Enter an acid concentration greater than zero.")
        let hydronium = pow(10, -pH)
        return try finitePositive(pow(hydronium, 2) / concentration, "Unable to calculate a valid Ka.")
    }

    static func kbFromPH(pH: Double, baseConcentration: Double) throws -> Double {
        try finite(pH, "Enter a finite pH value.")
        let concentration = try positive(baseConcentration, "Enter a base concentration greater than zero.")
        let hydronium = pow(10, -pH)
        let hydroxide = waterIonProduct / hydronium
        return try finitePositive(pow(hydroxide, 2) / concentration, "Unable to calculate a valid Kb.")
    }

    static func pKa(fromKa ka: Double) throws -> Double {
        let ka = try positive(ka, "Enter a Ka greater than zero.")
        return -log10(ka)
    }

    static func ka(fromPKa pKa: Double) throws -> Double {
        try finite(pKa, "Enter a finite pKa value.")
        return try finitePositive(pow(10, -pKa), "Unable to calculate a valid Ka.")
    }

    static func bufferPH(pKa: Double, baseAcidRatio ratio: Double) throws -> Double {
        try finite(pKa, "Enter a finite pKa value.")
        let ratio = try positive(ratio, "Enter a base/acid ratio greater than zero.")
        return pKa + log10(ratio)
    }

    static func bufferPH(ka: Double, baseAcidRatio ratio: Double) throws -> Double {
        let pKa = try pKa(fromKa: ka)
        return try bufferPH(pKa: pKa, baseAcidRatio: ratio)
    }

    static func bufferPKa(pH: Double, baseAcidRatio ratio: Double) throws -> Double {
        try finite(pH, "Enter a finite pH value.")
        let ratio = try positive(ratio, "Enter a base/acid ratio greater than zero.")
        return pH - log10(ratio)
    }

    static func bufferBaseAcidRatio(pH: Double, pKa: Double) throws -> Double {
        try finite(pH, "Enter a finite pH value.")
        try finite(pKa, "Enter a finite pKa value.")
        return try finitePositive(pow(10, pH - pKa), "Unable to calculate a valid base/acid ratio.")
    }

    private static func strongResult(pH: Double, hydronium: Double, hydroxide: Double) throws -> PHStrongResult {
        try finite(pH, "Unable to calculate a valid pH.")
        try finitePositive(hydronium, "Unable to calculate a valid [H₃O⁺].")
        try finitePositive(hydroxide, "Unable to calculate a valid [OH⁻].")
        return PHStrongResult(
            pH: pH,
            pOH: -log10(hydroxide),
            hydronium: hydronium,
            hydroxide: hydroxide,
            classification: classification(for: pH)
        )
    }

    private static func weakResult(pH: Double, hydronium: Double) throws -> PHWeakResult {
        let hydroxide = waterIonProduct / hydronium
        try finite(pH, "Unable to calculate a valid pH.")
        try finitePositive(hydronium, "Unable to calculate a valid [H₃O⁺].")
        try finitePositive(hydroxide, "Unable to calculate a valid [OH⁻].")
        return PHWeakResult(
            pH: pH,
            pOH: -log10(hydroxide),
            hydronium: hydronium,
            hydroxide: hydroxide,
            classification: classification(for: pH)
        )
    }

    private static func positiveQuadraticRoot(constant: Double, concentration: Double) throws -> Double {
        let discriminant = pow(constant, 2) + 4 * constant * concentration
        try finite(discriminant, "Unable to calculate a valid equilibrium concentration.")
        let root = (-constant + sqrt(discriminant)) / 2
        return try finitePositive(root, "Unable to calculate a valid equilibrium concentration.")
    }

    private static func positive(_ value: Double, _ message: String) throws -> Double {
        guard value.isFinite, value > 0 else {
            throw PHCalculationError.invalidValue(message)
        }
        return value
    }

    private static func finite(_ value: Double, _ message: String) throws {
        guard value.isFinite else {
            throw PHCalculationError.invalidValue(message)
        }
    }

    @discardableResult
    private static func finitePositive(_ value: Double, _ message: String) throws -> Double {
        guard value.isFinite, value > 0 else {
            throw PHCalculationError.invalidValue(message)
        }
        return value
    }
}
