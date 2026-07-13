import Foundation

enum NumberDisplayMode: Equatable {
    case decimal
    case scientific
    case automatic
}

struct NumberDisplayFormat: Equatable {
    var decimalPlaces: Int
    var mode: NumberDisplayMode
    var scientificLowerThreshold: Double?
    var scientificUpperThreshold: Double?

    init(
        decimalPlaces: Int,
        mode: NumberDisplayMode = .automatic,
        scientificLowerThreshold: Double? = 0.001,
        scientificUpperThreshold: Double? = 9_999
    ) {
        self.decimalPlaces = decimalPlaces
        self.mode = mode
        self.scientificLowerThreshold = scientificLowerThreshold
        self.scientificUpperThreshold = scientificUpperThreshold
    }

    static func decimal(decimalPlaces: Int) -> NumberDisplayFormat {
        NumberDisplayFormat(
            decimalPlaces: decimalPlaces,
            mode: .decimal,
            scientificLowerThreshold: nil,
            scientificUpperThreshold: nil
        )
    }

    static func scientific(decimalPlaces: Int) -> NumberDisplayFormat {
        NumberDisplayFormat(
            decimalPlaces: decimalPlaces,
            mode: .scientific,
            scientificLowerThreshold: nil,
            scientificUpperThreshold: nil
        )
    }

    static func chemistry(decimalPlaces: Int) -> NumberDisplayFormat {
        NumberDisplayFormat(decimalPlaces: decimalPlaces)
    }

    static func kinetics(decimalPlaces: Int) -> NumberDisplayFormat {
        NumberDisplayFormat(
            decimalPlaces: decimalPlaces,
            mode: .automatic,
            scientificLowerThreshold: 0.001,
            scientificUpperThreshold: 9_999
        )
    }
}

enum NumberDisplayValue: Equatable {
    case decimal(String)
    case scientific(mantissa: String, exponent: Int)
    case invalid

    var plainText: String {
        switch self {
        case .decimal(let value):
            value
        case .scientific(let mantissa, let exponent):
            "\(mantissa) x10^\(exponent)"
        case .invalid:
            "Invalid"
        }
    }
}

enum NumberDisplayFormatter {
    static func format(_ value: Double, using format: NumberDisplayFormat) -> NumberDisplayValue {
        guard value.isFinite else { return .invalid }

        switch format.mode {
        case .decimal:
            return .decimal(decimalString(value, decimalPlaces: format.decimalPlaces))
        case .scientific:
            return scientificValue(value, decimalPlaces: format.decimalPlaces)
        case .automatic:
            if shouldUseScientificNotation(value, using: format) {
                return scientificValue(value, decimalPlaces: format.decimalPlaces)
            }
            return .decimal(decimalString(value, decimalPlaces: format.decimalPlaces))
        }
    }

    static func shouldUseScientificNotation(_ value: Double, using format: NumberDisplayFormat) -> Bool {
        guard value.isFinite else { return false }

        let absoluteValue = abs(value)
        guard absoluteValue != 0 else { return false }

        // Automatic formatting must never turn a valid nonzero result into a
        // displayed zero at the selected precision.
        let zeroRoundingThreshold = 0.5 * pow(10, Double(-clamped(format.decimalPlaces)))
        if absoluteValue < zeroRoundingThreshold {
            return true
        }

        if let lowerThreshold = format.scientificLowerThreshold,
           absoluteValue < lowerThreshold {
            return true
        }

        if let upperThreshold = format.scientificUpperThreshold,
           absoluteValue > upperThreshold {
            return true
        }

        return false
    }

    private static func decimalString(_ value: Double, decimalPlaces: Int) -> String {
        String(format: "%.\(clamped(decimalPlaces))f", value)
    }

    private static func scientificValue(_ value: Double, decimalPlaces: Int) -> NumberDisplayValue {
        guard value != 0 else {
            return .decimal(decimalString(0, decimalPlaces: decimalPlaces))
        }

        var exponent = Int(floor(log10(abs(value))))
        var mantissa = value / pow(10, Double(exponent))
        let roundedMantissa = Double(decimalString(mantissa, decimalPlaces: decimalPlaces)) ?? mantissa

        if abs(roundedMantissa) >= 10 {
            mantissa = roundedMantissa / 10
            exponent += 1
        }

        return .scientific(
            mantissa: decimalString(mantissa, decimalPlaces: decimalPlaces),
            exponent: exponent
        )
    }

    private static func clamped(_ decimalPlaces: Int) -> Int {
        min(max(decimalPlaces, 0), 12)
    }
}
