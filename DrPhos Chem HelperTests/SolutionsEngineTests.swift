import XCTest
@testable import DrPhos_Chem_Helper

final class SolutionsEngineTests: XCTestCase {
    func testSolvesMolarity() throws {
        let result = try solve(
            problemType: .molarity,
            unknown: .concentration,
            soluteAmount: 0.5,
            solutionAmount: 2
        )

        XCTAssertEqual(result.value, 0.25, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "M")
    }

    func testSolvesMoles() throws {
        let result = try solve(
            problemType: .molarity,
            unknown: .soluteAmount,
            concentration: 0.25,
            solutionAmount: 2
        )

        XCTAssertEqual(result.value, 0.5, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "mol solute")
    }

    func testSolvesLiters() throws {
        let result = try solve(
            problemType: .molarity,
            unknown: .solutionAmount,
            concentration: 0.25,
            soluteAmount: 0.5
        )

        XCTAssertEqual(result.value, 2, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "L solution")
    }

    func testSolvesMassPercent() throws {
        let result = try solve(
            problemType: .massPercent,
            unknown: .concentration,
            soluteAmount: 5,
            solutionAmount: 100
        )

        XCTAssertEqual(result.value, 5, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "%")
    }

    func testSolvesSoluteAmountForPercentConcentration() throws {
        let result = try solve(
            problemType: .massVolumePercent,
            unknown: .soluteAmount,
            concentration: 5,
            solutionAmount: 250
        )

        XCTAssertEqual(result.value, 12.5, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "g solute")
    }

    func testSolvesSolutionAmountForPercentConcentration() throws {
        let result = try solve(
            problemType: .volumeVolumePercent,
            unknown: .solutionAmount,
            concentration: 25,
            soluteAmount: 10
        )

        XCTAssertEqual(result.value, 40, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "mL solution")
    }

    func testSolvesDilutionC1() throws {
        let result = try solve(
            problemType: .dilution,
            unknown: .c1,
            v1: 2,
            c2: 0.5,
            v2: 10
        )

        XCTAssertEqual(result.value, 2.5, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "concentration")
    }

    func testSolvesDilutionV1() throws {
        let result = try solve(
            problemType: .dilution,
            unknown: .v1,
            c1: 2.5,
            c2: 0.5,
            v2: 10
        )

        XCTAssertEqual(result.value, 2, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "volume")
    }

    func testSolvesDilutionC2() throws {
        let result = try solve(
            problemType: .dilution,
            unknown: .c2,
            c1: 2.5,
            v1: 2,
            v2: 10
        )

        XCTAssertEqual(result.value, 0.5, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "concentration")
    }

    func testSolvesDilutionV2() throws {
        let result = try solve(
            problemType: .dilution,
            unknown: .v2,
            c1: 2.5,
            v1: 2,
            c2: 0.5
        )

        XCTAssertEqual(result.value, 10, accuracy: 1e-12)
        XCTAssertEqual(result.unit, "volume")
    }

    func testRejectsMissingInput() {
        let result = SolutionsEngine.solve(
            SolutionsInput(
                problemType: .molarity,
                unknown: .concentration,
                soluteAmount: 0.5
            )
        )

        XCTAssertEqual(result.error, .missingValue("Enter a nonzero solution amount."))
    }

    func testRejectsDivideByZeroForConcentration() {
        let result = SolutionsEngine.solve(
            SolutionsInput(
                problemType: .molarity,
                unknown: .concentration,
                soluteAmount: 0.5,
                solutionAmount: 0
            )
        )

        XCTAssertEqual(result.error, .divideByZero("Enter a nonzero solution amount."))
    }

    func testRejectsDivideByZeroForDilution() {
        let result = SolutionsEngine.solve(
            SolutionsInput(
                problemType: .dilution,
                unknown: .v2,
                c1: 2.5,
                v1: 2,
                c2: 0
            )
        )

        XCTAssertEqual(result.error, .divideByZero("Enter a nonzero C₂."))
    }

    private func solve(
        problemType: SolutionProblemType,
        unknown: SolutionUnknown,
        concentration: Double? = nil,
        soluteAmount: Double? = nil,
        solutionAmount: Double? = nil,
        c1: Double? = nil,
        v1: Double? = nil,
        c2: Double? = nil,
        v2: Double? = nil
    ) throws -> SolutionsResult {
        try SolutionsEngine.calculate(
            SolutionsInput(
                problemType: problemType,
                unknown: unknown,
                concentration: concentration,
                soluteAmount: soluteAmount,
                solutionAmount: solutionAmount,
                c1: c1,
                v1: v1,
                c2: c2,
                v2: v2
            )
        )
    }
}

private extension Result where Success == SolutionsResult, Failure == SolutionsCalculationError {
    var error: SolutionsCalculationError? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}
