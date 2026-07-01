import Foundation

struct StoichiometryEngine {
    @discardableResult
    func calculate(compounds: inout [Compound]) -> Bool {
        let adjustedMoles = compounds.enumerated().compactMap { index, compound -> (index: Int, value: Double)? in
            guard !compound.formula.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  compound.molarMass.isFinite,
                  compound.molarMass > 0,
                  compound.coefficient > 0,
                  let enteredMoles = Double(compound.enteredMoles),
                  enteredMoles.isFinite,
                  enteredMoles > 0 else {
                return nil
            }

            let adjustedValue = enteredMoles / Double(compound.coefficient)
            guard adjustedValue.isFinite else { return nil }
            return (index, adjustedValue)
        }

        guard let minimum = adjustedMoles.min(by: { $0.value < $1.value }) else {
            return false
        }

        for index in compounds.indices {
            guard !compounds[index].formula.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  compounds[index].molarMass.isFinite,
                  compounds[index].molarMass > 0 else {
                compounds[index].calculatedMoles = ""
                compounds[index].calculatedGrams = ""
                continue
            }

            let calculatedMoles = minimum.value * Double(compounds[index].coefficient)
            guard calculatedMoles.isFinite else { continue }
            compounds[index].calculatedMoles = String(format: "%.4f", calculatedMoles)

            let calculatedGrams = calculatedMoles * compounds[index].molarMass
            guard calculatedGrams.isFinite else { continue }
            compounds[index].calculatedGrams = String(format: "%.4f", calculatedGrams)
            compounds[index].isLimiting = index == minimum.index

            if let enteredGrams = Double(compounds[index].enteredGrams), enteredGrams > calculatedGrams {
                compounds[index].excessGrams = String(format: "%.4f", enteredGrams - calculatedGrams)
            } else {
                compounds[index].excessGrams = ""
            }

            if let enteredMoles = Double(compounds[index].enteredMoles), enteredMoles > calculatedMoles {
                compounds[index].excessMoles = String(format: "%.4f", enteredMoles - calculatedMoles)
            } else {
                compounds[index].excessMoles = ""
            }
        }

        return true
    }

    func conditionType(for compounds: [Compound]) -> Int {
        var reactants = 0
        var products = 0

        for compound in compounds {
            let hasAmount = (Double(compound.enteredGrams) ?? 0) > 0
                || (Double(compound.enteredMoles) ?? 0) > 0
            guard hasAmount else { continue }

            if compound.isReactant {
                reactants += 1
            } else {
                products += 1
            }
        }

        if reactants == 1 && products == 0 { return 1 }
        if reactants > 1 && products == 0 { return 2 }
        if reactants == 0 && products == 1 { return 3 }
        if reactants > 0 && products > 0 { return 4 }
        return 0
    }
}
