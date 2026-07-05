import Foundation

struct ReactionBalancingEngine {
    func coefficients(for reaction: String) -> [Int]? {
        guard let normalizedReaction = normalizedReaction(from: reaction) else { return nil }
        let coefficients = integerCoefficients(from: solve(normalizedReaction)).map(\.value)
        return coefficients.isEmpty ? nil : coefficients
    }

    func coefficients(for compounds: [Compound]) -> [UUID: Int]? {
        let reactants = compounds.filter(\.isReactant)
        let products = compounds.filter { !$0.isReactant }
        guard !reactants.isEmpty, !products.isEmpty else { return nil }

        let orderedCompounds = reactants + products
        guard orderedCompounds.allSatisfy({ !$0.parsedFormula.isEmpty }) else { return nil }

        let reaction = reactants.map(\.parsedFormula).joined(separator: "+")
            + "="
            + products.map(\.parsedFormula).joined(separator: "+")
        let coefficients = integerCoefficients(from: solve(reaction)).map(\.value)
        guard coefficients.count == orderedCompounds.count,
              coefficients.allSatisfy({ $0 > 0 }) else {
            return nil
        }

        return Dictionary(uniqueKeysWithValues: zip(orderedCompounds.map(\.id), coefficients))
    }

    func solve(_ reaction: String) -> [Double] {
        let components = reaction.components(separatedBy: "=")
        guard components.count == 2 else { return [] }

        let left = components[0].components(separatedBy: "+")
        let right = components[1].components(separatedBy: "+")
        guard !left.isEmpty, !right.isEmpty else { return [] }

        var elements = Set(
            reaction
                .replacingOccurrences(of: "\\d+|\\+|=", with: "", options: .regularExpression)
                .matchAll1(regex: "([A-Z][a-z]*)|([A-Z]*)")
                .map { $0[0] }
        )
        elements.remove("")
        guard !elements.isEmpty else { return [] }

        var matrix: [[Double]] = []
        for element in elements {
            var row = moleculeCounts(for: element, in: left).map(Double.init)
            row.append(contentsOf: moleculeCounts(for: element, in: right).map { -Double($0) })
            matrix.append(row)
        }

        return nullSpaceCoefficients(for: matrix)
    }

    func integerCoefficients(from values: [Double]) -> [(id: Int, value: Int)] {
        values
            .enumerated()
            .map { (id: $0.offset, value: Int($0.element.rounded())) }
            .filter { $0.value != 0 }
    }

    private func moleculeCounts(for element: String, in molecules: [String]) -> [Int] {
        molecules.map { molecule in
            let pattern = "\(element)(\\d+)"
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(
                    in: molecule,
                    range: NSRange(location: 0, length: molecule.utf16.count)
                  ),
                  let range = Range(match.range(at: 1), in: molecule),
                  let count = Int(molecule[range]) else {
                return 0
            }
            return count
        }
    }

    private func normalizedReaction(from reaction: String) -> String? {
        let canonical = reaction
            .replacingOccurrences(of: "-->", with: "=")
            .replacingOccurrences(of: "->", with: "=")
            .replacingOccurrences(of: "→", with: "=")
        let sides = canonical.components(separatedBy: "=")
        guard sides.count == 2 else { return nil }

        let left = normalizedFormulas(in: sides[0])
        let right = normalizedFormulas(in: sides[1])
        guard let left, let right, !left.isEmpty, !right.isEmpty else { return nil }
        return left.joined(separator: "+") + "=" + right.joined(separator: "+")
    }

    private func normalizedFormulas(in side: String) -> [String]? {
        let formulas = side
            .components(separatedBy: "+")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard !formulas.isEmpty, formulas.allSatisfy({ !$0.isEmpty }) else { return nil }

        var normalized: [String] = []
        for formula in formulas {
            let result = FormulaParser.parse(formula)
            guard result.isValid, !result.parsedElements.isEmpty else { return nil }
            let counts = Dictionary(
                result.parsedElements.map { ($0.symbol, $0.count) },
                uniquingKeysWith: +
            )
            normalized.append(
                counts
                    .sorted { $0.key < $1.key }
                    .map { "\($0.key)\($0.value)" }
                    .joined()
            )
        }
        return normalized
    }

    private func nullSpaceCoefficients(for matrix: [[Double]]) -> [Double] {
        guard !matrix.isEmpty, let columnCount = matrix.first?.count, columnCount > 1 else {
            return []
        }

        var reduced = matrix
        let pivotColumns = reduceToRowEchelonForm(&reduced)
        let freeColumns = (0..<columnCount).filter { !pivotColumns.contains($0) }
        guard freeColumns.count == 1, let freeColumn = freeColumns.first else { return [] }

        var solution = Array(repeating: 0.0, count: columnCount)
        solution[freeColumn] = 1

        for (row, pivotColumn) in pivotColumns.enumerated() where row < reduced.count {
            var sum = 0.0
            for column in freeColumns {
                sum += reduced[row][column] * solution[column]
            }
            solution[pivotColumn] = -sum
        }

        let tolerance = 0.0001
        guard solution.allSatisfy({ $0.isFinite && abs($0) > tolerance }) else { return [] }
        if solution.allSatisfy({ $0 < 0 }) {
            solution = solution.map { -$0 }
        }
        guard solution.allSatisfy({ $0 > 0 }) else { return [] }

        return scaleToSmallestWholeNumbers(solution)
    }

    private func reduceToRowEchelonForm(_ matrix: inout [[Double]]) -> [Int] {
        let tolerance = 1e-10
        let rowCount = matrix.count
        let columnCount = matrix[0].count
        var pivotColumns: [Int] = []
        var pivotRow = 0

        for column in 0..<columnCount where pivotRow < rowCount {
            guard let selectedRow = (pivotRow..<rowCount).first(where: {
                abs(matrix[$0][column]) > tolerance
            }) else {
                continue
            }

            matrix.swapAt(selectedRow, pivotRow)
            let pivot = matrix[pivotRow][column]
            for currentColumn in 0..<columnCount {
                matrix[pivotRow][currentColumn] /= pivot
            }

            for row in 0..<rowCount where row != pivotRow {
                let multiplier = matrix[row][column]
                guard abs(multiplier) > tolerance else { continue }
                for currentColumn in 0..<columnCount {
                    matrix[row][currentColumn] -= multiplier * matrix[pivotRow][currentColumn]
                }
            }

            pivotColumns.append(column)
            pivotRow += 1
        }

        return pivotColumns
    }

    private func scaleToSmallestWholeNumbers(_ numbers: [Double]) -> [Double] {
        let tolerance = 0.0001
        for constant in 1...100 {
            let multiplied = numbers.map { $0 * Double(constant) }
            if multiplied.allSatisfy({ abs($0 - round($0)) < tolerance }) {
                let integers = multiplied.map { abs(Int($0.rounded())) }
                let divisor = integers.reduce(0, greatestCommonDivisor)
                guard divisor > 0 else { return [] }
                return integers.map { Double($0 / divisor) }
            }
        }
        return []
    }

    private func greatestCommonDivisor(_ lhs: Int, _ rhs: Int) -> Int {
        var a = abs(lhs)
        var b = abs(rhs)
        while b != 0 {
            (a, b) = (b, a % b)
        }
        return a
    }
}
