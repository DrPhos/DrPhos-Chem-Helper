import XCTest
@testable import DrPhos_Chem_Helper

final class KineticsEngineTests: XCTestCase {
    func testZeroOrderSolvesForRateConstant() throws {
        let result = try solve(
            order: .zero,
            unknown: .rateConstant,
            initialConcentration: 1.0,
            finalConcentration: 0.4,
            time: 30
        )

        XCTAssertEqual(result.value, 0.02, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "[conc] · s⁻¹")
        XCTAssertEqual(try XCTUnwrap(result.halfLife), 25, accuracy: 1e-12)
    }

    func testZeroOrderSolvesForTime() throws {
        let result = try solve(
            order: .zero,
            unknown: .time,
            rateConstant: 0.02,
            initialConcentration: 1.0,
            finalConcentration: 0.4
        )

        XCTAssertEqual(result.value, 30, accuracy: 1e-12)
    }

    func testZeroOrderSolvesForInitialConcentration() throws {
        let result = try solve(
            order: .zero,
            unknown: .initialConcentration,
            rateConstant: 0.02,
            finalConcentration: 0.4,
            time: 30
        )

        XCTAssertEqual(result.value, 1.0, accuracy: 1e-12)
    }

    func testZeroOrderSolvesForFinalConcentration() throws {
        let result = try solve(
            order: .zero,
            unknown: .finalConcentration,
            rateConstant: 0.02,
            initialConcentration: 1.0,
            time: 30
        )

        XCTAssertEqual(result.value, 0.4, accuracy: 1e-12)
    }

    func testZeroOrderSolvesForHalfLife() throws {
        let result = try solve(
            order: .zero,
            unknown: .halfLife,
            rateConstant: 0.02,
            initialConcentration: 1.0
        )

        XCTAssertEqual(result.value, 25, accuracy: 1e-12)
    }

    func testZeroOrderSolvesRateConstantFromHalfLifeUsingCorrectFormula() throws {
        let input = KineticsInput(
            order: .zero,
            timeUnit: .seconds,
            unknown: .halfLife,
            rateConstant: nil,
            initialConcentration: 1.0,
            finalConcentration: nil,
            time: nil,
            halfLife: 25
        )

        let k = try KineticsEngine.rateConstantFromHalfLife(input)

        XCTAssertEqual(k, 0.02, accuracy: 1e-12)
    }

    func testZeroOrderReturnsRateConstantResultFromHalfLifeUsingCorrectFormula() throws {
        let result = try KineticsEngine.calculateRateConstantFromHalfLife(
            KineticsInput(
                order: .zero,
                timeUnit: .minutes,
                unknown: .rateConstant,
                rateConstant: nil,
                initialConcentration: 1.0,
                finalConcentration: nil,
                time: nil,
                halfLife: 25
            )
        )

        XCTAssertEqual(result.unknown, .rateConstant)
        XCTAssertEqual(result.value, 0.02, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "[conc] · min⁻¹")
    }

    func testFirstOrderSolvesForRateConstant() throws {
        let result = try solve(
            order: .first,
            unknown: .rateConstant,
            initialConcentration: 1.0,
            finalConcentration: 0.25,
            time: 10
        )

        XCTAssertEqual(result.value, 0.13862943611198905, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "s⁻¹")
        XCTAssertEqual(try XCTUnwrap(result.halfLife), 5, accuracy: 1e-12)
    }

    func testFirstOrderSolvesForTime() throws {
        let result = try solve(
            order: .first,
            unknown: .time,
            rateConstant: 0.13862943611198905,
            initialConcentration: 1.0,
            finalConcentration: 0.25
        )

        XCTAssertEqual(result.value, 10, accuracy: 1e-10)
    }

    func testFirstOrderSolvesForInitialConcentration() throws {
        let result = try solve(
            order: .first,
            unknown: .initialConcentration,
            rateConstant: 0.13862943611198905,
            finalConcentration: 0.25,
            time: 10
        )

        XCTAssertEqual(result.value, 1.0, accuracy: 1e-10)
    }

    func testFirstOrderSolvesForFinalConcentration() throws {
        let result = try solve(
            order: .first,
            unknown: .finalConcentration,
            rateConstant: 0.13862943611198905,
            initialConcentration: 1.0,
            time: 10
        )

        XCTAssertEqual(result.value, 0.25, accuracy: 1e-10)
    }

    func testFirstOrderSolvesForHalfLife() throws {
        let result = try solve(
            order: .first,
            unknown: .halfLife,
            rateConstant: 0.13862943611198905
        )

        XCTAssertEqual(result.value, 5, accuracy: 1e-12)
    }

    func testFirstOrderReturnsRateConstantResultFromHalfLife() throws {
        let result = try KineticsEngine.calculateRateConstantFromHalfLife(
            KineticsInput(
                order: .first,
                timeUnit: .hours,
                unknown: .rateConstant,
                rateConstant: nil,
                initialConcentration: nil,
                finalConcentration: nil,
                time: nil,
                halfLife: 5
            )
        )

        XCTAssertEqual(result.unknown, .rateConstant)
        XCTAssertEqual(result.value, 0.13862943611198905, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "h⁻¹")
    }

    func testSecondOrderSolvesForRateConstant() throws {
        let result = try solve(
            order: .second,
            unknown: .rateConstant,
            initialConcentration: 1.0,
            finalConcentration: 0.25,
            time: 12
        )

        XCTAssertEqual(result.value, 0.25, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "[conc]⁻¹ · s⁻¹")
        XCTAssertEqual(try XCTUnwrap(result.halfLife), 4, accuracy: 1e-12)
    }

    func testSecondOrderSolvesForTime() throws {
        let result = try solve(
            order: .second,
            unknown: .time,
            rateConstant: 0.25,
            initialConcentration: 1.0,
            finalConcentration: 0.25
        )

        XCTAssertEqual(result.value, 12, accuracy: 1e-12)
    }

    func testSecondOrderSolvesForInitialConcentration() throws {
        let result = try solve(
            order: .second,
            unknown: .initialConcentration,
            rateConstant: 0.25,
            finalConcentration: 0.25,
            time: 12
        )

        XCTAssertEqual(result.value, 1.0, accuracy: 1e-12)
    }

    func testSecondOrderSolvesForFinalConcentration() throws {
        let result = try solve(
            order: .second,
            unknown: .finalConcentration,
            rateConstant: 0.25,
            initialConcentration: 1.0,
            time: 12
        )

        XCTAssertEqual(result.value, 0.25, accuracy: 1e-12)
    }

    func testSecondOrderSolvesForHalfLife() throws {
        let result = try solve(
            order: .second,
            unknown: .halfLife,
            rateConstant: 0.25,
            initialConcentration: 1.0
        )

        XCTAssertEqual(result.value, 4, accuracy: 1e-12)
    }

    func testSecondOrderReturnsRateConstantResultFromHalfLife() throws {
        let result = try KineticsEngine.calculateRateConstantFromHalfLife(
            KineticsInput(
                order: .second,
                timeUnit: .days,
                unknown: .rateConstant,
                rateConstant: nil,
                initialConcentration: 1.0,
                finalConcentration: nil,
                time: nil,
                halfLife: 4
            )
        )

        XCTAssertEqual(result.unknown, .rateConstant)
        XCTAssertEqual(result.value, 0.25, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "[conc]⁻¹ · days⁻¹")
    }

    func testScientificNotationFormatterUsesChemistryDisplayThresholds() {
        XCTAssertTrue(ScientificNotationFormatter.shouldUseScientificNotation(0.0000034))
        XCTAssertTrue(ScientificNotationFormatter.shouldUseScientificNotation(100_000))
        XCTAssertFalse(ScientificNotationFormatter.shouldUseScientificNotation(0.001))
        XCTAssertFalse(ScientificNotationFormatter.shouldUseScientificNotation(99999.99))
        XCTAssertEqual(ScientificNotationFormatter.format(0.0000034, decimalPlaces: 2), "3.4 x10^-6")
    }

    func testEngineReturnsValidationErrorForMissingInput() {
        let result = KineticsEngine.solve(
            KineticsInput(
                order: .first,
                timeUnit: .seconds,
                unknown: .time,
                rateConstant: 0.1,
                initialConcentration: nil,
                finalConcentration: 0.5,
                time: nil,
                halfLife: nil
            )
        )

        guard case .failure(.missingValue) = result else {
            return XCTFail("Expected missing-value error, got \(result)")
        }
    }

    private func solve(
        order: ReactionOrder,
        unknown: KineticsUnknown,
        rateConstant: Double? = nil,
        initialConcentration: Double? = nil,
        finalConcentration: Double? = nil,
        time: Double? = nil,
        halfLife: Double? = nil
    ) throws -> KineticsResult {
        try KineticsEngine.calculate(
            KineticsInput(
                order: order,
                timeUnit: .seconds,
                unknown: unknown,
                rateConstant: rateConstant,
                initialConcentration: initialConcentration,
                finalConcentration: finalConcentration,
                time: time,
                halfLife: halfLife
            )
        )
    }
}
