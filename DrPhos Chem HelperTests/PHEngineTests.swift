import XCTest
@testable import DrPhos_Chem_Helper

final class PHEngineTests: XCTestCase {
    func testPHCalculatesHydroniumAndHydroxide() throws {
        let result = try PHEngine.fromPH(3)

        XCTAssertEqual(result.pH, 3, accuracy: 1e-12)
        XCTAssertEqual(result.pOH, 11, accuracy: 1e-12)
        XCTAssertEqual(result.hydronium, 1e-3, accuracy: 1e-15)
        XCTAssertEqual(result.hydroxide, 1e-11, accuracy: 1e-20)
        XCTAssertEqual(result.classification, .acidic)
    }

    func testHydroniumCalculatesPHAndHydroxide() throws {
        let result = try PHEngine.fromHydronium(1e-5)

        XCTAssertEqual(result.pH, 5, accuracy: 1e-12)
        XCTAssertEqual(result.pOH, 9, accuracy: 1e-12)
        XCTAssertEqual(result.hydroxide, 1e-9, accuracy: 1e-18)
        XCTAssertEqual(result.classification, .acidic)
    }

    func testHydroxideCalculatesPHAndHydronium() throws {
        let result = try PHEngine.fromHydroxide(1e-5)

        XCTAssertEqual(result.pH, 9, accuracy: 1e-12)
        XCTAssertEqual(result.pOH, 5, accuracy: 1e-12)
        XCTAssertEqual(result.hydronium, 1e-9, accuracy: 1e-18)
        XCTAssertEqual(result.classification, .basic)
    }

    func testSolutionClassification() {
        XCTAssertEqual(PHEngine.classification(for: 2), .acidic)
        XCTAssertEqual(PHEngine.classification(for: 7), .neutral)
        XCTAssertEqual(PHEngine.classification(for: 12), .basic)
    }

    func testWeakAcidPHFromKaAndInitialAcid() throws {
        let result = try PHEngine.weakAcidPH(ka: 1.8e-5, initialAcidConcentration: 0.1)

        XCTAssertEqual(result.hydronium, 0.001332670973077975, accuracy: 1e-15)
        XCTAssertEqual(result.pH, 2.8752770615501357, accuracy: 1e-12)
        XCTAssertEqual(result.hydroxide, 7.50372762821097e-12, accuracy: 1e-23)
    }

    func testWeakBasePHFromKbAndInitialBase() throws {
        let result = try PHEngine.weakBasePH(kb: 1.8e-5, initialBaseConcentration: 0.1)

        XCTAssertEqual(result.hydroxide, 0.001332670973077975, accuracy: 1e-15)
        XCTAssertEqual(result.pH, 11.124722938449864, accuracy: 1e-12)
        XCTAssertEqual(result.hydronium, 7.50372762821097e-12, accuracy: 1e-23)
    }

    func testConjugateBasePHUsesKwOverKa() throws {
        let result = try PHEngine.conjugateBasePH(ka: 1.8e-5, initialConjugateBaseConcentration: 0.1)

        XCTAssertEqual(result.hydroxide, 7.453282152397604e-6, accuracy: 1e-18)
        XCTAssertEqual(result.pH, 8.87234756224862, accuracy: 1e-12)
    }

    func testConjugateAcidPHUsesKwOverKb() throws {
        let result = try PHEngine.conjugateAcidPH(kb: 1.8e-5, initialConjugateAcidConcentration: 0.1)

        XCTAssertEqual(result.hydronium, 7.453282152397604e-6, accuracy: 1e-18)
        XCTAssertEqual(result.pH, 5.1276524377513795, accuracy: 1e-12)
    }

    func testKaFromPHAndAcidConcentrationUsesCurrentApproximation() throws {
        let ka = try PHEngine.kaFromPH(pH: 3, acidConcentration: 0.1)

        XCTAssertEqual(ka, 1e-5, accuracy: 1e-18)
    }

    func testKbFromPHAndBaseConcentrationUsesCurrentApproximation() throws {
        let kb = try PHEngine.kbFromPH(pH: 11, baseConcentration: 0.1)

        XCTAssertEqual(kb, 1e-5, accuracy: 1e-18)
    }

    func testPKaFromKa() throws {
        let pKa = try PHEngine.pKa(fromKa: 1.8e-5)

        XCTAssertEqual(pKa, 4.744727494896694, accuracy: 1e-12)
    }

    func testKaFromPKa() throws {
        let ka = try PHEngine.ka(fromPKa: 4.744727494896694)

        XCTAssertEqual(ka, 1.8e-5, accuracy: 1e-18)
    }

    func testBufferPHFromPKaAndRatio() throws {
        let pH = try PHEngine.bufferPH(pKa: 4.76, baseAcidRatio: 2)

        XCTAssertEqual(pH, 5.061029995663981, accuracy: 1e-12)
    }

    func testBufferPHFromKaAndRatio() throws {
        let pH = try PHEngine.bufferPH(ka: 1.8e-5, baseAcidRatio: 2)

        XCTAssertEqual(pH, 5.045757490560675, accuracy: 1e-12)
    }

    func testBufferPKaFromPHAndRatio() throws {
        let pKa = try PHEngine.bufferPKa(pH: 5.061029995663981, baseAcidRatio: 2)

        XCTAssertEqual(pKa, 4.76, accuracy: 1e-12)
    }

    func testBufferRatioFromPHAndPKa() throws {
        let ratio = try PHEngine.bufferBaseAcidRatio(pH: 5.061029995663981, pKa: 4.76)

        XCTAssertEqual(ratio, 2, accuracy: 1e-12)
    }

    func testInvalidConcentrationsAreRejected() {
        XCTAssertThrowsError(try PHEngine.fromHydronium(0))
        XCTAssertThrowsError(try PHEngine.fromHydroxide(-1))
        XCTAssertThrowsError(try PHEngine.weakAcidPH(ka: 1e-5, initialAcidConcentration: 0))
        XCTAssertThrowsError(try PHEngine.weakBasePH(kb: 1e-5, initialBaseConcentration: -.infinity))
    }

    func testInvalidConstantsAndRatiosAreRejected() {
        XCTAssertThrowsError(try PHEngine.weakAcidPH(ka: 0, initialAcidConcentration: 0.1))
        XCTAssertThrowsError(try PHEngine.weakBasePH(kb: -.nan, initialBaseConcentration: 0.1))
        XCTAssertThrowsError(try PHEngine.pKa(fromKa: -1e-5))
        XCTAssertThrowsError(try PHEngine.ka(fromPKa: .infinity))
        XCTAssertThrowsError(try PHEngine.bufferPH(pKa: 4.76, baseAcidRatio: 0))
        XCTAssertThrowsError(try PHEngine.bufferPH(ka: 0, baseAcidRatio: 1))
        XCTAssertThrowsError(try PHEngine.bufferPKa(pH: 5, baseAcidRatio: -1))
        XCTAssertThrowsError(try PHEngine.bufferBaseAcidRatio(pH: .nan, pKa: 4.76))
    }
}
