import Foundation

enum ReactionOrder: String, CaseIterable, Hashable {
    case zero = "Zero Order"
    case first = "First Order"
    case second = "Second Order"
}

enum TimeUnit: String, CaseIterable, Hashable {
    case seconds = "Seconds"
    case minutes = "Minutes"
    case hours = "Hours"
    case days = "Days"
    case years = "Years"

    var abbreviation: String {
        switch self {
        case .seconds: "s"
        case .minutes: "min"
        case .hours: "h"
        case .days: "days"
        case .years: "years"
        }
    }
}

enum KineticsUnknown: Hashable {
    case rateConstant
    case time
    case initialConcentration
    case finalConcentration
    case halfLife
}

struct KineticsInput: Equatable {
    var order: ReactionOrder
    var timeUnit: TimeUnit
    var unknown: KineticsUnknown
    var rateConstant: Double?
    var initialConcentration: Double?
    var finalConcentration: Double?
    var time: Double?
    var halfLife: Double?
}

struct KineticsResult: Equatable {
    var unknown: KineticsUnknown
    var value: Double
    var unit: String
    var halfLife: Double?
    var halfLifeUnit: String
}

enum KineticsCalculationError: Error, Equatable, LocalizedError {
    case missingValue(String)
    case invalidValue(String)
    case finalConcentrationGreaterThanInitial
    case nonPhysicalResult(String)

    var errorDescription: String? {
        switch self {
        case .missingValue(let message), .invalidValue(let message), .nonPhysicalResult(let message):
            message
        case .finalConcentrationGreaterThanInitial:
            "The final concentration must be less than the initial concentration."
        }
    }
}

enum KineticsEngine {
    static func solve(_ input: KineticsInput) -> Result<KineticsResult, KineticsCalculationError> {
        do {
            return .success(try calculate(input))
        } catch let error as KineticsCalculationError {
            return .failure(error)
        } catch {
            return .failure(.invalidValue("Unable to calculate kinetics result."))
        }
    }

    static func solveRateConstantFromHalfLife(_ input: KineticsInput) -> Result<KineticsResult, KineticsCalculationError> {
        do {
            return .success(try calculateRateConstantFromHalfLife(input))
        } catch let error as KineticsCalculationError {
            return .failure(error)
        } catch {
            return .failure(.invalidValue("Unable to calculate rate constant from half-life."))
        }
    }

    static func calculate(_ input: KineticsInput) throws -> KineticsResult {
        switch input.unknown {
        case .rateConstant:
            return try solveRateConstant(input)
        case .time:
            return try solveTime(input)
        case .initialConcentration:
            return try solveInitialConcentration(input)
        case .finalConcentration:
            return try solveFinalConcentration(input)
        case .halfLife:
            return try solveHalfLife(input)
        }
    }

    static func calculateRateConstantFromHalfLife(_ input: KineticsInput) throws -> KineticsResult {
        let k = try rateConstantFromHalfLife(input)
        return try result(
            unknown: .rateConstant,
            value: k,
            unit: rateConstantUnit(for: input.order, timeUnit: input.timeUnit),
            order: input.order,
            initialConcentration: input.initialConcentration,
            rateConstant: k,
            timeUnit: input.timeUnit,
            includeHalfLife: false
        )
    }

    static func rateConstantUnit(for order: ReactionOrder, timeUnit: TimeUnit) -> String {
        switch order {
        case .zero:
            "[conc] · \(timeUnit.abbreviation)⁻¹"
        case .first:
            "\(timeUnit.abbreviation)⁻¹"
        case .second:
            "[conc]⁻¹ · \(timeUnit.abbreviation)⁻¹"
        }
    }

    private static func solveRateConstant(_ input: KineticsInput) throws -> KineticsResult {
        let a0 = try required(input.initialConcentration, "Enter an initial concentration.")
        let a = try required(input.finalConcentration, "Enter a final concentration.")
        let time = try positive(input.time, "Enter a time greater than zero.")
        try validateConcentrationDecrease(initial: a0, final: a)

        let k: Double
        switch input.order {
        case .zero:
            k = (a0 - a) / time
        case .first:
            k = -log(a / a0) / time
        case .second:
            k = (1 / a - 1 / a0) / time
        }

        return try result(
            unknown: .rateConstant,
            value: k,
            unit: rateConstantUnit(for: input.order, timeUnit: input.timeUnit),
            order: input.order,
            initialConcentration: a0,
            rateConstant: k,
            timeUnit: input.timeUnit
        )
    }

    private static func solveTime(_ input: KineticsInput) throws -> KineticsResult {
        let k = try positive(input.rateConstant, "Enter a rate constant greater than zero.")
        let a0 = try required(input.initialConcentration, "Enter an initial concentration.")
        let a = try required(input.finalConcentration, "Enter a final concentration.")
        try validateConcentrationDecrease(initial: a0, final: a)

        let time: Double
        switch input.order {
        case .zero:
            time = (a0 - a) / k
        case .first:
            time = -log(a / a0) / k
        case .second:
            time = (1 / a - 1 / a0) / k
        }

        return try result(
            unknown: .time,
            value: time,
            unit: input.timeUnit.abbreviation,
            order: input.order,
            initialConcentration: a0,
            rateConstant: k,
            timeUnit: input.timeUnit
        )
    }

    private static func solveInitialConcentration(_ input: KineticsInput) throws -> KineticsResult {
        let k = try positive(input.rateConstant, "Enter a rate constant greater than zero.")
        let a = try required(input.finalConcentration, "Enter a final concentration.")
        let time = try required(input.time, "Enter a time.")

        let a0: Double
        switch input.order {
        case .zero:
            a0 = a + k * time
        case .first:
            a0 = a / exp(-k * time)
        case .second:
            a0 = 1 / ((1 / a) - k * time)
        }

        return try result(
            unknown: .initialConcentration,
            value: a0,
            unit: "concentration",
            order: input.order,
            initialConcentration: a0,
            rateConstant: k,
            timeUnit: input.timeUnit
        )
    }

    private static func solveFinalConcentration(_ input: KineticsInput) throws -> KineticsResult {
        let k = try positive(input.rateConstant, "Enter a rate constant greater than zero.")
        let a0 = try required(input.initialConcentration, "Enter an initial concentration.")
        let time = try required(input.time, "Enter a time.")

        let a: Double
        switch input.order {
        case .zero:
            a = a0 - k * time
        case .first:
            a = a0 * exp(-k * time)
        case .second:
            a = 1 / ((1 / a0) + k * time)
        }

        return try result(
            unknown: .finalConcentration,
            value: a,
            unit: "concentration",
            order: input.order,
            initialConcentration: a0,
            rateConstant: k,
            timeUnit: input.timeUnit
        )
    }

    private static func solveHalfLife(_ input: KineticsInput) throws -> KineticsResult {
        let k = try positive(input.rateConstant, "Enter a rate constant greater than zero.")
        let a0 = input.initialConcentration
        let halfLife = try halfLife(order: input.order, rateConstant: k, initialConcentration: a0)

        return try result(
            unknown: .halfLife,
            value: halfLife,
            unit: input.timeUnit.abbreviation,
            order: input.order,
            initialConcentration: a0,
            rateConstant: k,
            timeUnit: input.timeUnit,
            includeHalfLife: false
        )
    }

    static func rateConstantFromHalfLife(_ input: KineticsInput) throws -> Double {
        let tHalf = try positive(input.halfLife, "Enter a half-life greater than zero.")

        switch input.order {
        case .zero:
            let a0 = try required(input.initialConcentration, "Enter an initial concentration.")
            return try finitePositive(a0 / (2 * tHalf), "Calculated rate constant is not valid.")
        case .first:
            return try finitePositive(log(2) / tHalf, "Calculated rate constant is not valid.")
        case .second:
            let a0 = try positive(input.initialConcentration, "Enter an initial concentration greater than zero.")
            return try finitePositive(1 / (tHalf * a0), "Calculated rate constant is not valid.")
        }
    }

    private static func halfLife(
        order: ReactionOrder,
        rateConstant k: Double,
        initialConcentration a0: Double?
    ) throws -> Double {
        switch order {
        case .zero:
            let a0 = try required(a0, "Enter an initial concentration.")
            return try finitePositive(a0 / (2 * k), "Calculated half-life is not valid.")
        case .first:
            return try finitePositive(log(2) / k, "Calculated half-life is not valid.")
        case .second:
            let a0 = try positive(a0, "Enter an initial concentration greater than zero.")
            return try finitePositive(1 / (k * a0), "Calculated half-life is not valid.")
        }
    }

    private static func result(
        unknown: KineticsUnknown,
        value: Double,
        unit: String,
        order: ReactionOrder,
        initialConcentration: Double?,
        rateConstant: Double,
        timeUnit: TimeUnit,
        includeHalfLife: Bool = true
    ) throws -> KineticsResult {
        let checkedValue = try finite(value, "Calculated result is not valid.")
        let halfLife = includeHalfLife
            ? try halfLife(order: order, rateConstant: rateConstant, initialConcentration: initialConcentration)
            : nil
        return KineticsResult(
            unknown: unknown,
            value: checkedValue,
            unit: unit,
            halfLife: halfLife,
            halfLifeUnit: timeUnit.abbreviation
        )
    }

    private static func required(_ value: Double?, _ message: String) throws -> Double {
        guard let value, value.isFinite else {
            throw KineticsCalculationError.missingValue(message)
        }
        return value
    }

    private static func positive(_ value: Double?, _ message: String) throws -> Double {
        try finitePositive(required(value, message), message)
    }

    private static func finitePositive(_ value: Double, _ message: String) throws -> Double {
        let value = try finite(value, message)
        guard value > 0 else {
            throw KineticsCalculationError.invalidValue(message)
        }
        return value
    }

    private static func finite(_ value: Double, _ message: String) throws -> Double {
        guard value.isFinite else {
            throw KineticsCalculationError.nonPhysicalResult(message)
        }
        return value
    }

    private static func validateConcentrationDecrease(initial a0: Double, final a: Double) throws {
        guard a0 > 0, a > 0 else {
            throw KineticsCalculationError.invalidValue("Concentrations must be greater than zero.")
        }
        guard a <= a0 else {
            throw KineticsCalculationError.finalConcentrationGreaterThanInitial
        }
    }
}
