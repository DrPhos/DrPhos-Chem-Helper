import XCTest
@testable import DrPhos_Chem_Helper

final class FormulaParserTests: XCTestCase {
    func testBalancerHandlesTwoReactantsAndThreeProducts() {
        let values = ReactionBalancingEngine().solve(
            "C1Na2O3+Cl1H1=H2O1+C1O2+Cl1Na1"
        )
        let coefficients = ReactionBalancingEngine()
            .integerCoefficients(from: values)
            .map(\.value)

        XCTAssertEqual(coefficients, [1, 2, 1, 1, 2])
    }

    func testChemicalFormulaDisplayFormatting() {
        XCTAssertEqual(ChemicalFormulaFormatter.format("H2O"), "H₂O")
        XCTAssertEqual(ChemicalFormulaFormatter.format("Na2O"), "Na₂O")
        XCTAssertEqual(ChemicalFormulaFormatter.format("NaNO3"), "NaNO₃")
        XCTAssertEqual(ChemicalFormulaFormatter.format("Ca(NO3)2"), "Ca(NO₃)₂")
        XCTAssertEqual(ChemicalFormulaFormatter.format("Al2(SO4)3"), "Al₂(SO₄)₃")
    }

    func testEmptyFormulaIsValid() {
        let result = FormulaParser.parse("")

        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.parsedElements.isEmpty)
        XCTAssertEqual(result.formattedString, "")
    }

    func testSimpleFormulaCountsElements() {
        let result = FormulaParser.parse("H2O")

        XCTAssertTrue(result.isValid)
        XCTAssertEqual(counts(in: result), ["H": 2, "O": 1])
        XCTAssertEqual(result.formattedString, "H2O")
    }

    func testParentheticalFormulaAppliesMultiplier() {
        let result = FormulaParser.parse("Ca(NO3)2")

        XCTAssertTrue(result.isValid)
        XCTAssertEqual(counts(in: result), ["Ca": 1, "N": 2, "O": 6])
        XCTAssertEqual(result.formattedString, "CaN2O6")
    }

    func testMultiDigitSubscriptIsPreserved() {
        let result = FormulaParser.parse("C12H22O11")

        XCTAssertTrue(result.isValid)
        XCTAssertEqual(counts(in: result), ["C": 12, "H": 22, "O": 11])
    }

    func testUnknownElementIsRejected() {
        let result = FormulaParser.parse("Xx2")

        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.invalidElement, "Xx")
        XCTAssertEqual(result.formattedString, "Invalid Compound Format")
    }

    func testUnmatchedOpeningParenthesisIsRejected() {
        let result = FormulaParser.parse("Ca(OH")

        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.invalidElement, "Unmatched parentheses")
    }

    func testWaterMolarMass() throws {
        let mass = try XCTUnwrap(ChemistryCalculator.molarMass(for: "H2O"))

        XCTAssertEqual(mass, 18.015, accuracy: 0.0001)
    }

    func testParentheticalFormulaMolarMass() throws {
        let mass = try XCTUnwrap(ChemistryCalculator.molarMass(for: "Ca(NO3)2"))

        XCTAssertEqual(mass, 164.086, accuracy: 0.0001)
    }

    func testInvalidFormulaHasNoMolarMass() {
        XCTAssertNil(ChemistryCalculator.molarMass(for: "Xx2"))
    }

    private func counts(in result: FormulaParser.ParseResult) -> [String: Int] {
        Dictionary(result.parsedElements.map { ($0.symbol, $0.count) },
                   uniquingKeysWith: +)
    }
}

final class ChemistryCalculationsTests: XCTestCase {
    func testQuadraticWithTwoRealRoots() {
        XCTAssertEqual(QuadraticCalculator.solve(a: 1, b: -3, c: 2), .twoReal(2, 1))
    }

    func testQuadraticWithRepeatedRoot() {
        XCTAssertEqual(QuadraticCalculator.solve(a: 1, b: 2, c: 1), .oneReal(-1))
    }

    func testQuadraticWithoutRealRoots() {
        XCTAssertEqual(QuadraticCalculator.solve(a: 1, b: 0, c: 1), .noReal)
    }

    func testZeroLeadingCoefficientIsNotQuadratic() {
        XCTAssertEqual(QuadraticCalculator.solve(a: 0, b: 2, c: 1), .notQuadratic)
    }

    func testPHFromHydronium() throws {
        let result = try XCTUnwrap(PHCalculator.fromHydronium(1e-3))
        XCTAssertEqual(result.pH, 3, accuracy: 1e-12)
        XCTAssertEqual(result.hydroxide, 1e-11, accuracy: 1e-20)
    }

    func testPHFromHydroxide() throws {
        let result = try XCTUnwrap(PHCalculator.fromHydroxide(1e-5))
        XCTAssertEqual(result.pH, 9, accuracy: 1e-12)
    }

    func testInvalidConcentrationsAreRejected() {
        XCTAssertNil(PHCalculator.fromHydronium(0))
        XCTAssertNil(PHCalculator.fromHydroxide(-1))
    }

    func testSolutionType() {
        XCTAssertEqual(PHCalculator.solutionType(for: 2), "acidic")
        XCTAssertEqual(PHCalculator.solutionType(for: 7), "neutral")
        XCTAssertEqual(PHCalculator.solutionType(for: 12), "basic")
    }
}

final class ScientificCalculatorInputTests: XCTestCase {
    func testClearCancelsPendingOperationBeforeAllClear() {
        var input = ScientificCalculatorInput()
        input.enterDigit(1)
        input.enterDigit(2)
        input.beginNewNumber()

        let operationMode = ScientificCalculatorClearMode(hasPendingOperation: true)
        XCTAssertEqual(operationMode, .operation)

        input.clear(for: operationMode)
        XCTAssertEqual(input.value, "12")
        XCTAssertTrue(input.startsNewNumber)

        let allClearMode = ScientificCalculatorClearMode(hasPendingOperation: false)
        XCTAssertEqual(allClearMode, .all)

        input.clear(for: allClearMode)
        XCTAssertEqual(input, ScientificCalculatorInput())
    }

    func testOperationClearPreservesCurrentSecondOperandEntry() {
        var input = ScientificCalculatorInput()
        input.enterDigit(5)

        input.clear(for: .operation)

        XCTAssertEqual(input.value, "5")
        XCTAssertFalse(input.startsNewNumber)
    }

    func testDecimalCanBeginEachOperand() {
        var input = ScientificCalculatorInput()

        input.enterDecimal()
        input.enterDigit(3)
        input.enterDigit(5)
        XCTAssertEqual(input.value, "0.35")

        input.beginNewNumber()
        input.enterDecimal()
        input.enterDigit(1)
        XCTAssertEqual(input.value, "0.1")
    }

    func testSecondDecimalInSameOperandIsIgnored() {
        var input = ScientificCalculatorInput()

        input.enterDigit(1)
        input.enterDecimal()
        input.enterDigit(2)
        input.enterDecimal()
        input.enterDigit(3)

        XCTAssertEqual(input.value, "1.23")
    }

    func testExponentDoesNotConfuseMantissaDecimalRule() {
        var input = ScientificCalculatorInput()

        input.enterDigit(1)
        input.enterDecimal()
        input.enterDigit(2)
        input.beginExponent()
        input.enterDigit(3)

        XCTAssertEqual(input.value, "1.2e3")
    }
}

final class NumericInputEditorTests: XCTestCase {
    func testSignCanBeAddedBeforeEnteringDigits() {
        XCTAssertEqual(NumericInputEditor.togglingSign(of: ""), "-")
    }

    func testSignIsPrependedToExistingNumber() {
        XCTAssertEqual(NumericInputEditor.togglingSign(of: "2.5"), "-2.5")
    }

    func testSignCanBeRemoved() {
        XCTAssertEqual(NumericInputEditor.togglingSign(of: "-2.5"), "2.5")
    }
}

final class CustomNumericInputEditorTests: XCTestCase {
    func testBuildsDecimalValue() {
        var value = ""
        for digit: Character in "12" {
            value = CustomNumericInputEditor.appendingDigit(digit, to: value)
        }
        value = CustomNumericInputEditor.appendingDecimal(to: value)
        value = CustomNumericInputEditor.appendingDigit("5", to: value)
        XCTAssertEqual(value, "12.5")
    }

    func testOnlyOneMantissaDecimalIsAllowed() {
        XCTAssertEqual(CustomNumericInputEditor.appendingDecimal(to: "12.5"), "12.5")
        XCTAssertEqual(CustomNumericInputEditor.appendingDecimal(to: "1e2"), "1e2")
    }

    func testSignTogglesMantissaBeforeExponent() {
        XCTAssertEqual(CustomNumericInputEditor.togglingSign(of: "12.5"), "-12.5")
        XCTAssertEqual(CustomNumericInputEditor.togglingSign(of: "-12.5"), "12.5")
    }

    func testExponentMarkerIsInsertedOnce() {
        XCTAssertEqual(CustomNumericInputEditor.insertingExponentMarker(in: "6.02"), "6.02e")
        XCTAssertEqual(CustomNumericInputEditor.insertingExponentMarker(in: "6.02e"), "6.02e")
        XCTAssertEqual(CustomNumericInputEditor.insertingExponentMarker(in: ""), "")
    }

    func testSignTogglesExponentAfterMarker() {
        XCTAssertEqual(CustomNumericInputEditor.togglingSign(of: "1.2e"), "1.2e-")
        XCTAssertEqual(CustomNumericInputEditor.togglingSign(of: "1.2e-4"), "1.2e4")
    }

    func testDeleteWorksThroughScientificNotation() {
        var value = "6.02e23"
        value = CustomNumericInputEditor.deletingLastCharacter(from: value)
        XCTAssertEqual(value, "6.02e2")
        value = CustomNumericInputEditor.deletingLastCharacter(from: value)
        value = CustomNumericInputEditor.deletingLastCharacter(from: value)
        XCTAssertEqual(value, "6.02")
    }

    func testFiniteScientificNotationParses() {
        XCTAssertEqual(CustomNumericInputEditor.parsedFiniteValue(from: "6.02e23"), 6.02e23)
        XCTAssertEqual(CustomNumericInputEditor.parsedFiniteValue(from: "-1.2e-4"), -1.2e-4)
        XCTAssertNil(CustomNumericInputEditor.parsedFiniteValue(from: "1e9999"))
    }
}

final class ToolAccessTests: XCTestCase {
    func testIncludedToolIsUnlocked() {
        let access = ToolAccess(includedTools: [.ph])

        XCTAssertEqual(access.status(for: .ph), .included)
        XCTAssertTrue(access.canUse(.ph))
        XCTAssertEqual(access.status(for: .kinetics), .locked)
    }

    func testIndividualPurchaseUnlocksOnlyPurchasedTool() {
        let access = ToolAccess(purchasedTools: [.kinetics])

        XCTAssertEqual(access.status(for: .kinetics), .purchased)
        XCTAssertFalse(access.canUse(.stoichiometry))
    }

    func testFullSuiteUnlocksEveryTool() {
        let access = ToolAccess(hasFullSuite: true)

        XCTAssertTrue(ToolID.allCases.allSatisfy(access.canUse))
        XCTAssertEqual(access.status(for: .balancer), .fullSuite)
    }

    func testFullAccessConfigurationPreservesCurrentBehavior() {
        XCTAssertTrue(ToolID.allCases.allSatisfy(ToolAccess.fullAccess.canUse))
    }
}
