import XCTest
@testable import DrPhos_Chem_Helper

final class ChemistryEngineRegressionTests: XCTestCase {
    private struct StoichiometryExpectation {
        let enteredGrams: [String: Double]
        let expectedCalculatedGrams: [String: Double]
        let limitingFormula: String?
        let expectedExcessGrams: [String: Double]
    }

    private struct ReactionCase {
        let reaction: String
        let expectedCoefficients: [Int]
        let expectedMolarMasses: [String: Double]
        let stoichiometry: [StoichiometryExpectation]

        init(
            _ reaction: String,
            coefficients: [Int],
            molarMasses: [String: Double] = [:],
            stoichiometry: [StoichiometryExpectation] = []
        ) {
            self.reaction = reaction
            self.expectedCoefficients = coefficients
            self.expectedMolarMasses = molarMasses
            self.stoichiometry = stoichiometry
        }
    }

    private let cases: [ReactionCase] = [
        ReactionCase(
            "H2 + O2 -> H2O",
            coefficients: [2, 1, 2],
            molarMasses: ["H2": 2.016, "O2": 31.998, "H2O": 18.015],
            stoichiometry: [
                StoichiometryExpectation(
                    enteredGrams: ["H2": 10],
                    expectedCalculatedGrams: ["O2": 79.36, "H2O": 89.36],
                    limitingFormula: "H2",
                    expectedExcessGrams: [:]
                ),
                StoichiometryExpectation(
                    enteredGrams: ["H2": 10, "O2": 10],
                    expectedCalculatedGrams: ["H2O": 11.26],
                    limitingFormula: "O2",
                    expectedExcessGrams: ["H2": 8.74]
                )
            ]
        ),
        ReactionCase(
            "Na2CO3 + HCl -> H2O + CO2 + NaCl",
            coefficients: [1, 2, 1, 1, 2],
            molarMasses: ["Na2CO3": 105.988, "HCl": 36.458, "NaCl": 58.440]
        ),
        ReactionCase(
            "C3H8 + O2 -> CO2 + H2O",
            coefficients: [1, 5, 3, 4],
            stoichiometry: [
                StoichiometryExpectation(
                    enteredGrams: ["C3H8": 44, "O2": 100],
                    expectedCalculatedGrams: ["CO2": 82.52, "H2O": 45.04],
                    limitingFormula: "O2",
                    expectedExcessGrams: ["C3H8": 16.44]
                )
            ]
        ),
        ReactionCase("Al + H2SO4 -> Al2(SO4)3 + H2", coefficients: [2, 3, 1, 3]),
        ReactionCase("Ca(OH)2 + H3PO4 -> Ca3(PO4)2 + H2O", coefficients: [3, 2, 1, 6]),
        ReactionCase("Fe2O3 + CO -> Fe + CO2", coefficients: [1, 3, 2, 3]),
        ReactionCase("FeS2 + O2 -> Fe2O3 + SO2", coefficients: [4, 11, 2, 8]),
        ReactionCase(
            "KMnO4 + HCl -> KCl + MnCl2 + H2O + Cl2",
            coefficients: [2, 16, 2, 2, 8, 5]
        )
    ]

    func testBalancingRegressionCases() {
        let engine = ReactionBalancingEngine()
        for testCase in cases {
            XCTAssertEqual(
                engine.coefficients(for: testCase.reaction),
                testCase.expectedCoefficients,
                "Balancing regression: \(testCase.reaction)"
            )
        }
    }

    func testMolarMassRegressionCases() throws {
        for testCase in cases {
            for (formula, expectedMass) in testCase.expectedMolarMasses {
                let mass = try XCTUnwrap(
                    ChemistryCalculator.molarMass(for: formula),
                    "Molar mass unavailable for \(formula)"
                )
                XCTAssertEqual(mass, expectedMass, accuracy: 0.001, "Molar mass regression: \(formula)")
            }
        }
    }

    func testStoichiometryRegressionCases() throws {
        for testCase in cases {
            for expectation in testCase.stoichiometry {
                var compounds = try makeCompounds(
                    reaction: testCase.reaction,
                    coefficients: testCase.expectedCoefficients,
                    enteredGrams: expectation.enteredGrams
                )

                XCTAssertTrue(
                    StoichiometryEngine().calculate(compounds: &compounds),
                    "Stoichiometry did not calculate: \(testCase.reaction)"
                )

                for (formula, expectedGrams) in expectation.expectedCalculatedGrams {
                    let compound = try compound(formula, in: compounds)
                    let actualGrams = try XCTUnwrap(Double(compound.calculatedGrams))
                    XCTAssertEqual(actualGrams, expectedGrams, accuracy: 0.02, "Product regression: \(formula)")
                }

                if let limitingFormula = expectation.limitingFormula {
                    XCTAssertTrue(try compound(limitingFormula, in: compounds).isLimiting)
                }

                for (formula, expectedExcess) in expectation.expectedExcessGrams {
                    let actualExcess = try XCTUnwrap(Double(try compound(formula, in: compounds).excessGrams))
                    XCTAssertEqual(actualExcess, expectedExcess, accuracy: 0.02, "Excess regression: \(formula)")
                }

                for compound in compounds {
                    if let grams = Double(compound.calculatedGrams) {
                        XCTAssertTrue(grams.isFinite, "Non-finite grams for \(compound.formula)")
                    }
                    if let moles = Double(compound.calculatedMoles) {
                        XCTAssertTrue(moles.isFinite, "Non-finite moles for \(compound.formula)")
                    }
                }
            }
        }
    }

    private func makeCompounds(
        reaction: String,
        coefficients: [Int],
        enteredGrams: [String: Double]
    ) throws -> [Compound] {
        let sides = reaction.replacingOccurrences(of: "->", with: "=").components(separatedBy: "=")
        XCTAssertEqual(sides.count, 2)
        let reactants = sides[0].components(separatedBy: "+").map { trimmed($0) }
        let products = sides[1].components(separatedBy: "+").map { trimmed($0) }
        let terms = reactants.map { ($0, true) } + products.map { ($0, false) }
        XCTAssertEqual(terms.count, coefficients.count)

        var compounds: [Compound] = []
        for index in terms.indices {
            let term = terms[index]
            let coefficient = coefficients[index]
            let formula = term.0
            let mass = try XCTUnwrap(ChemistryCalculator.molarMass(for: formula))
            let grams = enteredGrams[formula]
            let moles = grams.map { $0 / mass }
            compounds.append(Compound(
                formula: formula,
                molarMass: mass,
                enteredGrams: grams.map { String($0) } ?? "",
                calculatedGrams: "",
                excessGrams: "",
                enteredMoles: moles.map { String($0) } ?? "",
                calculatedMoles: "",
                excessMoles: "",
                coefficient: coefficient,
                isReactant: term.1,
                parsedFormula: FormulaParser.parse(formula).formattedString,
                isLimiting: false
            ))
        }
        return compounds
    }

    private func compound(_ formula: String, in compounds: [Compound]) throws -> Compound {
        try XCTUnwrap(compounds.first(where: { $0.formula == formula }))
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
