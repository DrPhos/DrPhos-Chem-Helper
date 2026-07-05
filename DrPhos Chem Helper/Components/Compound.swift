//
//  Compound.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 7/26/25.
//


//
//  CompoundEntry.swift
//  062524_stoichiometry_full
//
//  Created by Monte Helm on 6/25/24.
//

import SwiftUI

let atomicMasses:[String:Double]=[
    "H":1.00797,"He":4.00260,"Li":6.941,"Be":9.01218,"B":10.81,"C":12.011,
    "N":14.0067,"O":15.9994,"F":18.998403,"Ne":20.180,"Na":22.98977,"Mg":24.305,
    "Al":26.98154,"Si":28.085,"P":30.97376,"S":32.06,"Cl":35.453,"Ar":39.948,
    "K":39.0983,"Ca":40.078,"Sc":44.9559,"Ti":47.867,"V":50.9415,"Cr":51.996,
    "Mn":54.938,"Fe":55.845,"Co":58.9332,"Ni":58.693,"Cu":63.546,"Zn":65.38,
    "Ga":69.723,"Ge":72.630,"As":74.922,"Se":78.971,"Br":79.904,"Kr":83.798,
    "Rb":85.468,"Sr":87.62,"Y":88.906,"Zr":91.224,"Nb":92.906,"Mo":95.95,
    "Tc":97,"Ru":101.07,"Rh":102.906,"Pd":106.42,"Ag":107.868,"Cd":112.411,
    "In":114.818,"Sn":118.71,"Sb":121.76,"Te":127.60,"I":126.904,"Xe":131.293,
    "Cs":132.905,"Ba":137.327,"La":138.905,"Ce":140.116,"Pr":140.908,"Nd":144.242,
    "Pm":145,"Sm":150.36,"Eu":151.964,"Gd":157.25,"Tb":158.925,"Dy":162.5,
    "Ho":164.93,"Er":167.259,"Tm":168.934,"Yb":173.054,"Lu":174.967,"Hf":178.49,
    "Ta":180.948,"W":183.84,"Re":186.207,"Os":190.23,"Ir":192.217,"Pt":195.084,
    "Au":196.967,"Hg":200.59,"Tl":204.383,"Pb":207.2,"Bi":208.98,"Po":209,
    "At":210,"Rn":222,"Fr":223,"Ra":226,"Ac":227,"Th":232.038,"Pa":231.036,
    "U":238.029,"Np":237,"Pu":244,"Am":243,"Cm":247,"Bk":247,"Cf":251,
    "Es":252,"Fm":257,"Md":258,"No":259,"Lr":266,"Rf":267,"Db":268,"Sg":269,
    "Bh":270,"Hs":269,"Mt":278,"Ds":281,"Rg":282,"Cn":285,"Nh":286,"Fl":289,
    "Mc":289,"Lv":293,"Ts":294,"Og":294
]

struct Compound:Identifiable{
    var id=UUID()
    var formula:String
    var molarMass:Double
    var enteredGrams:String
    var calculatedGrams:String
    var excessGrams:String
    var enteredMoles:String
    var calculatedMoles:String
    var excessMoles:String
    var coefficient:Int
    var isReactant:Bool
    var parsedFormula:String
    var isLimiting:Bool
}

class CompoundsViewModel:ObservableObject{
    @Published var compounds:[Compound]=[]
    
    func addReactant(formula:String){
        guard !formula.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let parsedFormula=parseChemicalFormula(formula)
        let molarMass=calculateMolarMass(parsedFormula)
        let newCompound=Compound(
            formula:formula,
            molarMass:molarMass,
            enteredGrams:"",
            calculatedGrams:"",
            excessGrams:"",
            enteredMoles:"",
            calculatedMoles:"",
            excessMoles:"",
            coefficient:1,
            isReactant:true,
            parsedFormula:parsedFormula,
            isLimiting:false
        )
        var updatedCompounds = compounds
        resetAmounts(in: &updatedCompounds)
        updatedCompounds.append(newCompound)
        compounds = updatedCompounds
    }
    
    func addProduct(formula:String){
        guard !formula.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let parsedFormula=parseChemicalFormula(formula)
        let molarMass=calculateMolarMass(parsedFormula)
        let newCompound=Compound(
            formula:formula,
            molarMass:molarMass,
            enteredGrams:"",
            calculatedGrams:"",
            excessGrams:"",
            enteredMoles:"",
            calculatedMoles:"",
            excessMoles:"",
            coefficient:1,
            isReactant:false,
            parsedFormula:parsedFormula,
            isLimiting:false
        )
        var updatedCompounds = compounds
        resetAmounts(in: &updatedCompounds)
        updatedCompounds.append(newCompound)
        compounds = updatedCompounds
    }

    func parseChemicalFormula(_ formula:String)->String{
        var stack:[[String:Int]]=[[:]]
        var i=0

        while i<formula.count{
            let index=formula.index(formula.startIndex,offsetBy:i)
            let char=formula[index]

            if char.isUppercase{
                var element=String(char)
                i+=1
                if i<formula.count{
                    let nextIndex=formula.index(formula.startIndex,offsetBy:i)
                    let nextChar=formula[nextIndex]
                    if nextChar.isLowercase{
                        element.append(nextChar)
                        i+=1
                    }
                }
                var num=0
                while i<formula.count,let digit=formula[formula.index(formula.startIndex,offsetBy:i)].wholeNumberValue{
                    num=num*10+digit
                    i+=1
                }
                num=max(num,1)
                stack[stack.count-1][element,default:0]+=num
            }else if char=="("||char=="["{
                stack.append([:])
                i+=1
            }else if char==")"||char=="]"{
                i+=1
                var num=0
                while i<formula.count,let digit=formula[formula.index(formula.startIndex,offsetBy:i)].wholeNumberValue{
                    num=num*10+digit
                    i+=1
                }
                num=max(num,1)
                let popped=stack.removeLast()
                for(element,count)in popped{
                    stack[stack.count-1][element,default:0]+=count*num
                }
            }else{
                i+=1
            }
        }

        let finalCounts:[String:Int]=stack.reduce(into:[:]){(result,dict)in
            for(element,count)in dict{
                result[element,default:0]+=count
            }
        }

        let sortedElements=finalCounts.keys.sorted()
        let result=sortedElements.map{element in
            let count=finalCounts[element]!
            return"\(element)\(count)"
        }.joined()

        return result
    }

    func calculateMolarMass(_ formula:String)->Double{
        var mass=0.0
        var currentElement=""
        var currentCount=""

        for char in formula{
            if char.isUppercase{
                if !currentElement.isEmpty{
                    mass+=atomicMasses[currentElement,default:0.0]*(Double(currentCount) ?? 1)
                }
                currentElement=String(char)
                currentCount=""
            }else if char.isLowercase{
                currentElement.append(char)
            }else if char.isNumber{
                currentCount.append(char)
            }
        }

        if !currentElement.isEmpty{
            mass+=atomicMasses[currentElement,default:0.0]*(Double(currentCount) ?? 1)
        }

        return mass
    }

    func recordEnteredAmounts(inputMode: StoichiometryView.InputMode){
        for index in compounds.indices{
            let compound = compounds[index]
            let hasValidFormula = !compound.formula.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && compound.molarMass.isFinite
                && compound.molarMass > 0

            guard hasValidFormula else {
                compounds[index].enteredMoles = ""
                compounds[index].calculatedGrams = ""
                compounds[index].calculatedMoles = ""
                continue
            }

            if inputMode == .grams{
                guard !compound.enteredGrams.isEmpty else {
                    compounds[index].enteredMoles = ""
                    continue
                }
                guard let grams = Double(compound.enteredGrams), grams.isFinite, grams >= 0 else {
                    compounds[index].enteredMoles = ""
                    continue
                }
                let moles = grams / compound.molarMass
                compounds[index].enteredMoles = moles.isFinite ? String(moles) : ""
            }else if inputMode == .moles{
                guard !compound.enteredMoles.isEmpty else {
                    compounds[index].enteredGrams = ""
                    continue
                }
                guard let moles = Double(compound.enteredMoles), moles.isFinite, moles >= 0 else {
                    compounds[index].enteredGrams = ""
                    continue
                }
                let grams = moles * compound.molarMass
                compounds[index].enteredGrams = grams.isFinite ? String(grams) : ""
            }
        }
    }

    @discardableResult
    func prepareEnteredAmountsForStoichiometry() -> Bool {
        var updatedCompounds = compounds
        var knownAmountCount = 0

        for index in updatedCompounds.indices {
            let compound = updatedCompounds[index]
            let gramsText = compound.enteredGrams.trimmingCharacters(in: .whitespacesAndNewlines)
            let molesText = compound.enteredMoles.trimmingCharacters(in: .whitespacesAndNewlines)
            let grams = Double(gramsText)
            let moles = Double(molesText)

            let hasGrams = !gramsText.isEmpty
            let hasMoles = !molesText.isEmpty
            guard !(hasGrams && hasMoles),
                  !hasGrams || (grams?.isFinite == true && (grams ?? 0) > 0),
                  !hasMoles || (moles?.isFinite == true && (moles ?? 0) > 0),
                  compound.molarMass.isFinite,
                  compound.molarMass > 0 else {
                return false
            }

            if let grams, hasGrams {
                let convertedMoles = grams / compound.molarMass
                guard convertedMoles.isFinite else { return false }
                updatedCompounds[index].enteredMoles = String(convertedMoles)
                knownAmountCount += 1
            } else if let moles, hasMoles {
                let convertedGrams = moles * compound.molarMass
                guard convertedGrams.isFinite else { return false }
                updatedCompounds[index].enteredGrams = String(convertedGrams)
                knownAmountCount += 1
            }
        }

        guard knownAmountCount > 0 else { return false }
        compounds = updatedCompounds
        return true
    }

    func clearEnteredAndCalculatedValues(){
        var updatedCompounds = compounds
        guard resetAmounts(in: &updatedCompounds) else { return }
        compounds = updatedCompounds
    }

    @discardableResult
    func calculateStoichiometry() -> Bool {
        var updatedCompounds = compounds
        guard StoichiometryEngine().calculate(compounds: &updatedCompounds) else { return false }
        compounds = updatedCompounds
        return true
    }

    func updateCoefficient(compoundID: UUID, coefficient: Int) {
        guard let index = compounds.firstIndex(where: { $0.id == compoundID }),
              compounds[index].coefficient != coefficient else { return }

        var updatedCompounds = compounds
        updatedCompounds[index].coefficient = coefficient
        resetAmounts(in: &updatedCompounds)
        compounds = updatedCompounds
    }

    func applyCoefficients(_ coefficients: [UUID: Int]) {
        guard compounds.allSatisfy({ coefficients[$0.id] != nil }) else { return }

        var updatedCompounds = compounds
        for index in updatedCompounds.indices {
            updatedCompounds[index].coefficient = coefficients[updatedCompounds[index].id] ?? 1
        }
        resetAmounts(in: &updatedCompounds)
        compounds = updatedCompounds
    }

    func clearCompounds(){
        compounds.removeAll()
    }

    func removeCompound(id: UUID) {
        guard compounds.contains(where: { $0.id == id }) else { return }
        var updatedCompounds = compounds.filter { $0.id != id }
        resetAmounts(in: &updatedCompounds)
        compounds = updatedCompounds
    }

    @discardableResult
    private func resetAmounts(in compounds: inout [Compound]) -> Bool {
        var changed = false
        for index in compounds.indices {
            let hasValues = !compounds[index].enteredGrams.isEmpty
                || !compounds[index].calculatedGrams.isEmpty
                || !compounds[index].excessGrams.isEmpty
                || !compounds[index].enteredMoles.isEmpty
                || !compounds[index].calculatedMoles.isEmpty
                || !compounds[index].excessMoles.isEmpty
                || compounds[index].isLimiting
            guard hasValues else { continue }

            changed = true
            compounds[index].enteredGrams = ""
            compounds[index].calculatedGrams = ""
            compounds[index].excessGrams = ""
            compounds[index].enteredMoles = ""
            compounds[index].calculatedMoles = ""
            compounds[index].excessMoles = ""
            compounds[index].isLimiting = false
        }
        return changed
    }
}
