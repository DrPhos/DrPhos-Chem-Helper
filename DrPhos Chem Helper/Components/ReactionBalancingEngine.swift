import Foundation

struct ReactionBalancingEngine {
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

        var matrix: [[Int]] = []
        for element in elements {
            var row = moleculeCounts(for: element, in: left)
            row.append(contentsOf: moleculeCounts(for: element, in: right))
            matrix.append(row)
        }

        var reducedMatrix = matrix.map { $0.map(Double.init) }
        guard !reducedMatrix.isEmpty, !(reducedMatrix.first?.isEmpty ?? true) else { return [] }
        convertToReducedEchelonForm(&reducedMatrix)
        return multiplyToWholeNumbers(reducedMatrix.map { $0.last ?? 0 })
    }

    func integerCoefficients(from values: [Double]) -> [(id: Int, value: Int)] {
        values
            .enumerated()
            .map { (id: $0.offset, value: Int($0.element)) }
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

    private func convertToReducedEchelonForm(_ matrix: inout [[Double]]) {
        let rowCount = matrix.count
        guard rowCount > 0, let colCount = matrix.first?.count, colCount > 0 else { return }

        var lead = 0
        for row in 0..<rowCount {
            guard lead < colCount else { return }

            var pivotRow = row
            while matrix[pivotRow][lead] == 0 {
                pivotRow += 1
                if pivotRow == rowCount {
                    pivotRow = row
                    lead += 1
                    guard lead < colCount else { return }
                }
            }

            matrix.swapAt(pivotRow, row)
            let pivot = matrix[row][lead]
            guard pivot != 0 else { continue }

            for column in 0..<colCount {
                matrix[row][column] /= pivot
            }
            for otherRow in 0..<rowCount where otherRow != row {
                let multiplier = matrix[otherRow][lead]
                for column in 0..<colCount {
                    matrix[otherRow][column] -= multiplier * matrix[row][column]
                }
            }
            lead += 1
        }
    }

    private func multiplyToWholeNumbers(_ numbers: [Double]) -> [Double] {
        let tolerance = 0.0001
        for constant in 1...100 {
            let multiplied = numbers.map { $0 * Double(constant) }
            if multiplied.allSatisfy({ abs($0 - round($0)) < tolerance }) {
                return multiplied.map { abs($0) } + [Double(constant)]
            }
        }
        return []
    }
}
