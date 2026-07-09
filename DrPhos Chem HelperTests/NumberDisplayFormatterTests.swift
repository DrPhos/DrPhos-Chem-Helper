import XCTest
@testable import DrPhos_Chem_Helper

final class NumberDisplayFormatterTests: XCTestCase {
    func testFormatsNormalDecimalValues() {
        let value = NumberDisplayFormatter.format(
            12.3456,
            using: .decimal(decimalPlaces: 2)
        )

        XCTAssertEqual(value, .decimal("12.35"))
    }

    func testFormatsSmallScientificValues() {
        let value = NumberDisplayFormatter.format(
            0.000003788,
            using: .chemistry(decimalPlaces: 3)
        )

        XCTAssertEqual(value, .scientific(mantissa: "3.788", exponent: -6))
    }

    func testFormatsLargeScientificValuesAbove9999() {
        let value = NumberDisplayFormatter.format(
            15_932.33,
            using: .chemistry(decimalPlaces: 2)
        )

        XCTAssertEqual(value, .scientific(mantissa: "1.59", exponent: 4))
    }

    func testMantissaPrecisionFollowsDecimalPlaces() {
        XCTAssertEqual(
            NumberDisplayFormatter.format(0.00003788, using: .chemistry(decimalPlaces: 3)),
            .scientific(mantissa: "3.788", exponent: -5)
        )
        XCTAssertEqual(
            NumberDisplayFormatter.format(0.00003788, using: .chemistry(decimalPlaces: 2)),
            .scientific(mantissa: "3.79", exponent: -5)
        )
        XCTAssertEqual(
            NumberDisplayFormatter.format(0.00003788, using: .chemistry(decimalPlaces: 1)),
            .scientific(mantissa: "3.8", exponent: -5)
        )
    }

    func testNegativeExponent() {
        let value = NumberDisplayFormatter.format(
            0.0012,
            using: .scientific(decimalPlaces: 2)
        )

        XCTAssertEqual(value, .scientific(mantissa: "1.20", exponent: -3))
    }

    func testPositiveExponent() {
        let value = NumberDisplayFormatter.format(
            12_000,
            using: .scientific(decimalPlaces: 2)
        )

        XCTAssertEqual(value, .scientific(mantissa: "1.20", exponent: 4))
    }

    func testScientificMantissaNormalizesAfterRounding() {
        let value = NumberDisplayFormatter.format(
            99_995,
            using: .scientific(decimalPlaces: 2)
        )

        XCTAssertEqual(value, .scientific(mantissa: "1.00", exponent: 5))
    }

    func testZeroFormatsAsDecimal() {
        XCTAssertEqual(
            NumberDisplayFormatter.format(0, using: .chemistry(decimalPlaces: 3)),
            .decimal("0.000")
        )
        XCTAssertEqual(
            NumberDisplayFormatter.format(0, using: .scientific(decimalPlaces: 2)),
            .decimal("0.00")
        )
    }

    func testRejectsNaNAndInfinity() {
        XCTAssertEqual(
            NumberDisplayFormatter.format(.nan, using: .chemistry(decimalPlaces: 2)),
            .invalid
        )
        XCTAssertEqual(
            NumberDisplayFormatter.format(.infinity, using: .chemistry(decimalPlaces: 2)),
            .invalid
        )
        XCTAssertEqual(
            NumberDisplayFormatter.format(-Double.infinity, using: .chemistry(decimalPlaces: 2)),
            .invalid
        )
    }
}
