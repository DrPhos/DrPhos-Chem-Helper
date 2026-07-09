import Foundation

enum SolutionProblemType: Equatable {
    case molarity
    case massPercent
    case massVolumePercent
    case volumeVolumePercent
    case dilution

    var concentrationFactor: Double {
        switch self {
        case .molarity, .dilution:
            1
        case .massPercent, .massVolumePercent, .volumeVolumePercent:
            100
        }
    }

    var concentrationUnit: String {
        switch self {
        case .molarity:
            "M"
        case .massPercent, .massVolumePercent, .volumeVolumePercent:
            "%"
        case .dilution:
            ""
        }
    }

    var soluteUnit: String {
        switch self {
        case .molarity:
            "mol solute"
        case .massPercent, .massVolumePercent:
            "g solute"
        case .volumeVolumePercent:
            "mL solute"
        case .dilution:
            ""
        }
    }

    var solutionUnit: String {
        switch self {
        case .molarity:
            "L solution"
        case .massPercent:
            "g solution"
        case .massVolumePercent, .volumeVolumePercent:
            "mL solution"
        case .dilution:
            ""
        }
    }
}

enum SolutionUnknown: Hashable {
    case concentration
    case soluteAmount
    case solutionAmount
    case c1
    case v1
    case c2
    case v2
}

struct SolutionsInput: Equatable {
    var problemType: SolutionProblemType
    var unknown: SolutionUnknown
    var concentration: Double?
    var soluteAmount: Double?
    var solutionAmount: Double?
    var c1: Double?
    var v1: Double?
    var c2: Double?
    var v2: Double?

    init(
        problemType: SolutionProblemType,
        unknown: SolutionUnknown,
        concentration: Double? = nil,
        soluteAmount: Double? = nil,
        solutionAmount: Double? = nil,
        c1: Double? = nil,
        v1: Double? = nil,
        c2: Double? = nil,
        v2: Double? = nil
    ) {
        self.problemType = problemType
        self.unknown = unknown
        self.concentration = concentration
        self.soluteAmount = soluteAmount
        self.solutionAmount = solutionAmount
        self.c1 = c1
        self.v1 = v1
        self.c2 = c2
        self.v2 = v2
    }
}

struct SolutionsResult: Equatable {
    var problemType: SolutionProblemType
    var unknown: SolutionUnknown
    var value: Double
    var unit: String
}

enum SolutionsCalculationError: Error, Equatable, LocalizedError {
    case missingValue(String)
    case invalidValue(String)
    case divideByZero(String)
    case unsupportedUnknown(String)

    var errorDescription: String? {
        switch self {
        case .missingValue(let message),
             .invalidValue(let message),
             .divideByZero(let message),
             .unsupportedUnknown(let message):
            message
        }
    }
}

enum SolutionsEngine {
    static func solve(_ input: SolutionsInput) -> Result<SolutionsResult, SolutionsCalculationError> {
        do {
            return .success(try calculate(input))
        } catch let error as SolutionsCalculationError {
            return .failure(error)
        } catch {
            return .failure(.invalidValue("Unable to calculate solution result."))
        }
    }

    static func calculate(_ input: SolutionsInput) throws -> SolutionsResult {
        switch input.problemType {
        case .molarity, .massPercent, .massVolumePercent, .volumeVolumePercent:
            return try calculateConcentration(input)
        case .dilution:
            return try calculateDilution(input)
        }
    }

    private static func calculateConcentration(_ input: SolutionsInput) throws -> SolutionsResult {
        let factor = input.problemType.concentrationFactor

        switch input.unknown {
        case .concentration:
            let solute = try required(input.soluteAmount, "Enter a solute amount.")
            let solution = try nonZero(input.solutionAmount, "Enter a nonzero solution amount.")
            return SolutionsResult(
                problemType: input.problemType,
                unknown: input.unknown,
                value: solute / solution * factor,
                unit: input.problemType.concentrationUnit
            )

        case .soluteAmount:
            let concentration = try required(input.concentration, "Enter a concentration.")
            let solution = try required(input.solutionAmount, "Enter a solution amount.")
            return SolutionsResult(
                problemType: input.problemType,
                unknown: input.unknown,
                value: concentration * solution / factor,
                unit: input.problemType.soluteUnit
            )

        case .solutionAmount:
            let concentration = try nonZero(input.concentration, "Enter a nonzero concentration.")
            let solute = try required(input.soluteAmount, "Enter a solute amount.")
            return SolutionsResult(
                problemType: input.problemType,
                unknown: input.unknown,
                value: solute * factor / concentration,
                unit: input.problemType.solutionUnit
            )

        case .c1, .v1, .c2, .v2:
            throw SolutionsCalculationError.unsupportedUnknown("Choose a concentration unknown for this problem type.")
        }
    }

    private static func calculateDilution(_ input: SolutionsInput) throws -> SolutionsResult {
        let value: Double

        switch input.unknown {
        case .c1:
            value = try divide(
                try required(input.c2, "Enter C₂."),
                times: try required(input.v2, "Enter V₂."),
                by: input.v1,
                divisorMessage: "Enter a nonzero V₁."
            )
        case .v1:
            value = try divide(
                try required(input.c2, "Enter C₂."),
                times: try required(input.v2, "Enter V₂."),
                by: input.c1,
                divisorMessage: "Enter a nonzero C₁."
            )
        case .c2:
            value = try divide(
                try required(input.c1, "Enter C₁."),
                times: try required(input.v1, "Enter V₁."),
                by: input.v2,
                divisorMessage: "Enter a nonzero V₂."
            )
        case .v2:
            value = try divide(
                try required(input.c1, "Enter C₁."),
                times: try required(input.v1, "Enter V₁."),
                by: input.c2,
                divisorMessage: "Enter a nonzero C₂."
            )
        case .concentration, .soluteAmount, .solutionAmount:
            throw SolutionsCalculationError.unsupportedUnknown("Choose a dilution unknown for this problem type.")
        }

        return SolutionsResult(
            problemType: input.problemType,
            unknown: input.unknown,
            value: value,
            unit: dilutionUnit(for: input.unknown)
        )
    }

    private static func divide(
        _ first: Double,
        times second: Double,
        by divisor: Double?,
        divisorMessage: String
    ) throws -> Double {
        let divisor = try nonZero(divisor, divisorMessage)
        let value = first * second / divisor
        guard value.isFinite else {
            throw SolutionsCalculationError.invalidValue("The calculated result is not finite.")
        }
        return value
    }

    private static func required(_ value: Double?, _ message: String) throws -> Double {
        guard let value else {
            throw SolutionsCalculationError.missingValue(message)
        }
        guard value.isFinite else {
            throw SolutionsCalculationError.invalidValue(message)
        }
        return value
    }

    private static func nonZero(_ value: Double?, _ message: String) throws -> Double {
        let value = try required(value, message)
        guard value != 0 else {
            throw SolutionsCalculationError.divideByZero(message)
        }
        return value
    }

    private static func dilutionUnit(for unknown: SolutionUnknown) -> String {
        switch unknown {
        case .c1, .c2:
            "concentration"
        case .v1, .v2:
            "volume"
        case .concentration, .soluteAmount, .solutionAmount:
            ""
        }
    }
}
