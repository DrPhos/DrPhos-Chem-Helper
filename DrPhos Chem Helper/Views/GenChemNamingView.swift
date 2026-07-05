import SwiftUI

struct Compounds: Identifiable {
    var id: Int
    var userInput: String
    var compoundName: String
    var compoundFormula: String
    var nameToFormula: Bool
    var containsMetal: Bool
    var type: String
}

struct PeriodicTable: Identifiable {
    var id: Int
    var name: String
    var symbol: String
    var mass: Double
    var type: String
}

struct GenChemNamingView: View {
    @State var periodicTableString: [PeriodicTable] = [
        PeriodicTable(id: 1, name: "hydrogen", symbol: "H", mass: 1.00797, type: "non-metal"),
        PeriodicTable(id: 2, name: "helium", symbol: "He", mass: 4.00260, type: "non-metal"),
        PeriodicTable(id: 3, name: "lithium", symbol: "Li", mass: 6.941, type: "metal"),
        PeriodicTable(id: 4, name: "beryllium", symbol: "Be", mass: 9.01218, type: "metal"),
        PeriodicTable(id: 5, name: "boron", symbol: "B", mass: 10.81, type: "non-metal"),
        PeriodicTable(id: 6, name: "carbon", symbol: "C", mass: 12.011, type: "non-metal"),
        PeriodicTable(id: 7, name: "nitrogen", symbol: "N", mass: 14.0067, type: "non-metal"),
        PeriodicTable(id: 8, name: "oxygen", symbol: "O", mass: 15.9994, type: "non-metal"),
        PeriodicTable(id: 9, name: "fluorine", symbol: "F", mass: 18.998403, type: "non-metal"),
        PeriodicTable(id: 10, name: "neon", symbol: "Ne", mass: 20.180, type: "non-metal"),
        PeriodicTable(id: 11, name: "sodium", symbol: "Na", mass: 22.98977, type: "metal"),
        PeriodicTable(id: 12, name: "magnesium", symbol: "Mg", mass: 24.305, type: "metal"),
        PeriodicTable(id: 13, name: "aluminum", symbol: "Al", mass: 26.98154, type: "metal"),
        PeriodicTable(id: 14, name: "silicon", symbol: "Si", mass: 28.085, type: "non-metal"),
        PeriodicTable(id: 15, name: "phosphorus", symbol: "P", mass: 30.97376, type: "non-metal"),
        PeriodicTable(id: 16, name: "sulfur", symbol: "S", mass: 32.06, type: "non-metal"),
        PeriodicTable(id: 17, name: "chlorine", symbol: "Cl", mass: 35.453, type: "non-metal"),
        PeriodicTable(id: 18, name: "argon", symbol: "Ar", mass: 39.948, type: "non-metal"),
        PeriodicTable(id: 19, name: "potassium", symbol: "K", mass: 39.0983, type: "metal"),
        PeriodicTable(id: 20, name: "calcium", symbol: "Ca", mass: 40.078, type: "metal"),
        PeriodicTable(id: 21, name: "scandium", symbol: "Sc", mass: 44.9559, type: "metal"),
        PeriodicTable(id: 22, name: "titanium", symbol: "Ti", mass: 47.867, type: "metal"),
        PeriodicTable(id: 23, name: "vanadium", symbol: "V", mass: 50.9415, type: "metal"),
        PeriodicTable(id: 24, name: "chromium", symbol: "Cr", mass: 51.996, type: "metal"),
        PeriodicTable(id: 25, name: "manganese", symbol: "Mn", mass: 54.938, type: "metal"),
        PeriodicTable(id: 26, name: "iron", symbol: "Fe", mass: 55.845, type: "metal"),
        PeriodicTable(id: 27, name: "cobalt", symbol: "Co", mass: 58.9332, type: "metal"),
        PeriodicTable(id: 28, name: "nickel", symbol: "Ni", mass: 58.693, type: "metal"),
        PeriodicTable(id: 29, name: "copper", symbol: "Cu", mass: 63.546, type: "metal"),
        PeriodicTable(id: 30, name: "zinc", symbol: "Zn", mass: 65.38, type: "metal")
    ]
    @State var compoundString: [Compounds] = []
    @State var userInput: String = ""
    @State var nameToFormula: Bool = false
    @State var containsMetal: Bool = false
    @State var parsedMolecularFormula = ""
    @State var molecularNameString = ""
    @State private var showCompoundEntry = false

    var body: some View {
        VStack {
            Text("Compound Information")
                .font(.title)
                .fontWeight(.bold)

            Spacer()

            HStack(alignment: .center) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Type:")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if let firstCompound = compoundString.first {
                            Text(firstCompound.type)
                        }
                    }

                    HStack {
                        Text("Formula:")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        TextFormatFormula(parsedFormula: parsedMolecularFormula)
                    }

                    HStack {
                        Text("Name: ")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if let firstCompound = compoundString.first {
                            Text(firstCompound.compoundName)
                        }
                    }
                }
                .padding()
                .padding(.horizontal, 10)
                Spacer()
            }

            HStack {
                Spacer()
                ZStack {
                    TextField("Enter Compound Name or Formula", text: $userInput)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 300, minHeight: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.numbers, lineWidth: 1)
                        )
                    Color.white.opacity(0.001)
                        .contentShape(Rectangle())
                        .allowsHitTesting(true)
                        .onTapGesture {
                            showCompoundEntry = true
                        }
                }
                .frame(height: 40)

                Button(action: {
                    userInput = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.numbers)
                        .background(Circle().fill(Color.phostextrev))
                        .overlay(
                            Circle().stroke(Color.phosred1, lineWidth: 3)
                        )
                }
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityLabel("Clear compound")

                Spacer().frame(width: 20)
            }
            .sheet(isPresented: $showCompoundEntry) {
                CompoundEntry(compoundFormula: $userInput, isPresented: $showCompoundEntry)
            }
            .padding(.vertical, 10)

            NumbersView(compoundFormula: $userInput)
                .padding(.top, 5)

            HStack {
                Spacer()

                Button("Convert") {
                    nameOrFormula(userInput: userInput)
                    whatLogic()
                }
                .padding(5)
                .font(.headline)
                .background(Color.phosblue1)
                .foregroundColor(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                )

                Spacer()

                Button("Clear", action: {
                    clear()
                    
                })
                .padding(5)
                .font(.headline)
                .background(Color.phosred1)
                .foregroundColor(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                )

                Spacer()
            }
            .padding(.vertical, 8)

            Spacer()

            PeriodicTableView(compoundFormula: $userInput)

            Spacer()
        }
//        .padding(.top, -50)
    }
    
    private var deleteButton: some View {
        Button(action: clearInput) {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.numbers)
                .background(Circle().fill(Color.white))
                .overlay(
                    Circle()
                        .stroke(Color.phosred1, lineWidth: 3)
                )
        }
        .frame(minWidth: 44, minHeight: 44)
        .accessibilityLabel("Clear compound")
        .padding(.leading, -24)
    }
    
    private func clearInput() {
        userInput = ""
    }

    func clear() {
        userInput = ""
        compoundString.removeAll()
        parsedMolecularFormula = ""
    }

    func nameOrFormula(userInput: String) {
        let lowercasedInput = userInput.lowercased()
        for element in periodicTableString {
            let elementNameLowercased = element.name.lowercased()
            let elementType = element.type.lowercased()

            if lowercasedInput.contains(elementNameLowercased) {
                if elementType == "metal" {
                    print("Found metal \(element.name)")
                    compoundString = [Compounds(
                        id: 1,
                        userInput: userInput,
                        compoundName: userInput,
                        compoundFormula: "",
                        nameToFormula: true,
                        containsMetal: true,
                        type: "ionic"
                    )]
                } else {
                    print("Found non-metal \(element.name)")
                    compoundString = [Compounds(
                        id: 1,
                        userInput: userInput,
                        compoundName: userInput,
                        compoundFormula: "",
                        nameToFormula: true,
                        containsMetal: false,
                        type: "molecular (covalent)"
                    )]
                }
                return
            }

            let elementSymbol = element.symbol
            if let firstChar = userInput.first, let secondChar = userInput.dropFirst().first {
                let isFirstCharUppercase = firstChar.isUppercase
                let isSecondCharLowercase = secondChar.isLowercase
                
                var inputPrefix: String
                if isFirstCharUppercase && isSecondCharLowercase {
                    inputPrefix = String([firstChar, secondChar])
                } else if isFirstCharUppercase {
                    inputPrefix = String(firstChar)
                } else {
                    inputPrefix = ""
                }

                if inputPrefix == elementSymbol {
                    if elementType == "metal" {
                        print("Found metal \(element.name)")
                        compoundString = [Compounds(
                            id: 1,
                            userInput: userInput,
                            compoundName: "",
                            compoundFormula: userInput,
                            nameToFormula: false,
                            containsMetal: true,
                            type: "ionic"
                        )]
                    } else {
                        print("Found non-metal \(element.name)")
                        compoundString = [Compounds(
                            id: 1,
                            userInput: userInput,
                            compoundName: "",
                            compoundFormula: userInput,
                            nameToFormula: false,
                            containsMetal: false,
                            type: "molecular (covalent)"
                        )]
                    }
                    return
                }
            }
        }

        print("No matching element found for \(userInput)")
        compoundString = [Compounds(
            id: 1,
            userInput: userInput,
            compoundName: "",
            compoundFormula: userInput,
            nameToFormula: false,
            containsMetal: false,
            type: ""
        )]
    }

    func whatLogic() {
        guard let firstCompound = compoundString.first else { return }

        if firstCompound.nameToFormula && firstCompound.containsMetal {
            print("Logic for ionic name-to-formula")
            _ = ionicNameToFormula(compounds: firstCompound)
        } else if firstCompound.nameToFormula && !firstCompound.containsMetal {
            print("Logic for molecular name-to-formula")
            molecularNameToFormula()
        } else if !firstCompound.nameToFormula && firstCompound.containsMetal {
            print("Logic for ionic formula-to-name")
            ionicFormulaToName()
        } else if !firstCompound.nameToFormula && !firstCompound.containsMetal {
            print("Logic for molecular formula-to-name")
            _ = molecularFormulaToName()
            print("molecularName: \(molecularNameString)")
        }
    }

    func molecularNameToFormula() {
        var molecularCompoundString = [(word: String, prefix: String, prefixnumber: Int, elementname: String)]()
        print("Running molecularNametoFormula Function")

        let words = userInput.lowercased().components(separatedBy: " ")
        let molecularPrefixes: [String: Int] = [
            "mono": 1,
            "di": 2,
            "tri": 3,
            "tetra": 4,
            "penta": 5,
            "hexa": 6,
            "hepta": 7,
            "octa": 8,
            "nona": 9,
            "deca": 10
        ]

        for (index, word) in words.enumerated() {
            var prefix = ""
            var elementName = word

            for (molecularPrefix, _) in molecularPrefixes {
                if word.hasPrefix(molecularPrefix) {
                    prefix = molecularPrefix
                    elementName = String(word.dropFirst(molecularPrefix.count))
                    break
                }
            }

            let defaultPrefixNumber = (index == 0) ? 1 : 0
            let tuple = (word: word, prefix: prefix, prefixnumber: molecularPrefixes[prefix] ?? defaultPrefixNumber, elementname: elementName.lowercased())
            molecularCompoundString.append(tuple)
        }

        print("Parsed Molecular Name: \(molecularCompoundString)")
        _ = buildParsedFormula(molecularCompoundString: molecularCompoundString)
    }

    func buildParsedFormula(molecularCompoundString: [(word: String, prefix: String, prefixnumber: Int, elementname: String)]) -> String {
        let periodicTable: [String: [(Double, String, String)]] = [
            "H": [(1.00797, "non-metal", "hydrogen"), (1.00797, "non-metal", "hydride")],
            "He": [(4.00260, "non-metal", "helium")],
            "Li": [(6.941, "metal", "lithium")],
            "Be": [(9.01218, "metal", "beryllium")],
            "B": [(10.81, "non-metal", "boron"), (10.81, "non-metal", "boride")],
            "C": [(12.011, "non-metal", "carbon"), (12.011, "non-metal", "carbide")],
            "N": [(14.0067, "non-metal", "nitrogen"), (14.0067, "non-metal", "nitride")],
            "O": [(15.9994, "non-metal", "oxygen"), (15.9994, "non-metal", "oxide")],
            "F": [(18.998403, "non-metal", "fluorine"), (18.998403, "non-metal", "fluoride")],
            "Ne": [(20.180, "non-metal", "neon")],
            "Na": [(22.98977, "metal", "sodium")],
            "Mg": [(24.305, "metal", "magnesium")],
            "Al": [(26.98154, "metal", "aluminum")],
            "Si": [(28.085, "non-metal", "silicide")],
            "P": [(30.97376, "non-metal", "phosphorus"), (30.97376, "non-metal", "phosphide")],
            "S": [(32.06, "non-metal", "sulfur"), (32.06, "non-metal", "sulfide")],
            "Cl": [(35.453, "non-metal", "chlorine"), (35.453, "non-metal", "chloride")]
        ]

        for tuple in molecularCompoundString {
            let elementName = tuple.elementname.lowercased()
            if let elements = periodicTable.values.first(where: { $0.contains { $0.2.lowercased() == elementName } }), let _ = elements.first {
                let elementSymbol = periodicTable.first { $0.value.contains { $0.2.lowercased() == elementName } }?.key ?? ""
                let prefixNumber = tuple.prefixnumber
                parsedMolecularFormula += "\(elementSymbol)\(prefixNumber)"

                if let lastCompound = compoundString.last {
                    var updatedCompound = lastCompound
                    updatedCompound.compoundFormula = parsedMolecularFormula
                    compoundString[compoundString.count - 1] = updatedCompound
                }
            } else {
                print("Element \(elementName) not found in the periodic table.")
            }
        }
        
        return parsedMolecularFormula
    }

    func molecularFormulaToName() -> String {
        print("compoundString Input \(compoundString)")
        guard let compounds = compoundString.first?.compoundFormula else {
            print("No compounds in the array")
            return ""
        }

        var result = [(element: String, count: Int)]()
        let periodicTable: [String: [(Double, String, String)]] = [
            "H": [(1.00797, "non-metal", "hydrogen"), (1.00797, "non-metal", "hydride")],
            "He": [(4.00260, "non-metal", "helium")],
            "Li": [(6.941, "metal", "lithium")],
            "Be": [(9.01218, "metal", "beryllium")],
            "B": [(10.81, "non-metal", "boron"), (10.81, "non-metal", "boride")],
            "C": [(12.011, "non-metal", "carbon"), (12.011, "non-metal", "carbide")],
            "N": [(14.0067, "non-metal", "nitrogen"), (14.0067, "non-metal", "nitride")],
            "O": [(15.9994, "non-metal", "oxygen"), (15.9994, "non-metal", "oxide")],
            "F": [(18.998403, "non-metal", "fluorine"), (18.998403, "non-metal", "fluoride")],
            "Ne": [(20.180, "non-metal", "neon")],
            "Na": [(22.98977, "metal", "sodium")],
            "Mg": [(24.305, "metal", "magnesium")],
            "Al": [(26.98154, "metal", "aluminum")],
            "Si": [(28.085, "non-metal", "silicide")],
            "P": [(30.97376, "non-metal", "phosphorus"), (30.97376, "non-metal", "phosphide")],
            "S": [(32.06, "non-metal", "sulfur"), (32.06, "non-metal", "sulfide")],
            "Cl": [(35.453, "non-metal", "chlorine"), (35.453, "non-metal", "chloride")]
        ]

        let pattern = #"([A-Z][a-z]*)(\d*)"# // regex to match elements and their counts
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: compounds, options: [], range: NSRange(location: 0, length: compounds.utf16.count))

        for match in matches {
            let elementRange = Range(match.range(at: 1), in: compounds)!
            let countRange = Range(match.range(at: 2), in: compounds)!
            let element = String(compounds[elementRange])
            let countString = String(compounds[countRange])
            let count = Int(countString) ?? 1
            result.append((element, count))
        }

        let molecularPrefixes: [String: Int] = [
            "mono": 1,
            "di": 2,
            "tri": 3,
            "tetra": 4,
            "penta": 5,
            "hexa": 6,
            "hepta": 7,
            "octa": 8,
            "nona": 9,
            "deca": 10
        ]

        if !result.isEmpty {
            var isFirstElement = true

            let formattedElements = result.enumerated().map { (index, elementInfo) -> String in
                let elementData = periodicTable[elementInfo.element] ?? [(0, "unknown", "unknown")]
                let elementName = (index == 1 && elementData.count > 1) ? elementData[1].2 : elementData[0].2
                let prefix = molecularPrefixes.first { $0.value == elementInfo.count }?.key ?? "unknown"
                let formattedPrefix = isFirstElement && prefix == "mono" ? "" : prefix
                isFirstElement = false
                return "\(formattedPrefix)\(elementName)"
            }

            molecularNameString = formattedElements.joined(separator: " ")

            if var firstCompound = compoundString.first {
                firstCompound.compoundName = molecularNameString
                compoundString[0] = firstCompound
            }
            
            // Update parsedMolecularFormula here
            parsedMolecularFormula = compounds
            
            return molecularNameString
        }
        return molecularNameString
    }

    func ionicNameToFormula(compounds: Compounds) -> String? {
        struct Cation {
            let name: String
            let symbol: String
            let charge: Int
        }

        struct Anion {
            let name: String
            var symbol: String
            let charge: Int
        }

        let cations: [String: Cation] = [
            "ammonium": Cation(name: "ammonium", symbol: "NH4", charge: 1),
            "hydrogen": Cation(name: "hydrogen", symbol: "H", charge: 1),
            "lithium": Cation(name: "lithium", symbol: "Li", charge: 1),
            "sodium": Cation(name: "sodium", symbol: "Na", charge: 1),
            "potassium": Cation(name: "potassium", symbol: "K", charge: 1),
            "rubidium": Cation(name: "rubidium", symbol: "Rb", charge: 1),
            "cesium": Cation(name: "cesium", symbol: "Cs", charge: 1),
            "francium": Cation(name: "francium", symbol: "Fr", charge: 1),
            "beryllium": Cation(name: "beryllium", symbol: "Be", charge: 2),
            "magnesium": Cation(name: "magnesium", symbol: "Mg", charge: 2),
            "calcium": Cation(name: "calcium", symbol: "Ca", charge: 2),
            "strontium": Cation(name: "strontium", symbol: "Sr", charge: 2),
            "barium": Cation(name: "barium", symbol: "Ba", charge: 2),
            "radium": Cation(name: "radium", symbol: "Ra", charge: 2),
            "iron(II)": Cation(name: "iron(II)", symbol: "Fe", charge: 2),
            "iron(III)": Cation(name: "iron(III)", symbol: "Fe", charge: 3),
            "manganese(II)": Cation(name: "manganese(II)", symbol: "Mn", charge: 2),
            "manganese(III)": Cation(name: "manganese(III)", symbol: "Mn", charge: 3),
            "manganese(IV)": Cation(name: "manganese(IV)", symbol: "Mn", charge: 4),
            "manganese(V)": Cation(name: "manganese(V)", symbol: "Mn", charge: 5),
            "titanium(IV)": Cation(name: "titanium(IV)", symbol: "Ti", charge: 4),
            "copper(I)": Cation(name: "copper(I)", symbol: "Cu", charge: 1),
            "copper(II)": Cation(name: "copper(II)", symbol: "Cu", charge: 2),
            "lead(II)": Cation(name: "lead(II)", symbol: "Pb", charge: 2),
            "lead(IV)": Cation(name: "lead(IV)", symbol: "Pb", charge: 4),
            "mercury(I)": Cation(name: "mercury(I)", symbol: "Hg", charge: 1),
            "mercury(II)": Cation(name: "mercury(II)", symbol: "Hg", charge: 2),
            "tin(II)": Cation(name: "tin(II)", symbol: "Sn", charge: 2),
            "tin(IV)": Cation(name: "tin(IV)", symbol: "Sn", charge: 4)
        ]

        let anions: [String: Anion] = [
            "hydride": Anion(name: "hydride", symbol: "H", charge: -1),
            "fluoride": Anion(name: "fluoride", symbol: "F", charge: -1),
            "chloride": Anion(name: "chloride", symbol: "Cl", charge: -1),
            "bromide": Anion(name: "bromide", symbol: "Br", charge: -1),
            "iodide": Anion(name: "iodide", symbol: "I", charge: -1),
            "astatide": Anion(name: "astatide", symbol: "At", charge: -1),
            "oxide": Anion(name: "oxide", symbol: "O", charge: -2),
            "sulfide": Anion(name: "sulfide", symbol: "S", charge: -2),
            "selenide": Anion(name: "selenide", symbol: "Se", charge: -2),
            "telluride": Anion(name: "telluride", symbol: "Te", charge: -2),
            "nitride": Anion(name: "nitride", symbol: "N", charge: -3),
            "phosphide": Anion(name: "phosphide", symbol: "P", charge: -3),
            "arsenide": Anion(name: "arsenide", symbol: "As", charge: -3),
            "nitrate": Anion(name: "nitrate", symbol: "(NO3)", charge: -1),
            "hydroxide": Anion(name: "hydroxide", symbol: "(OH)", charge: -1),
            "sulfate": Anion(name: "sulfate", symbol: "(SO4)", charge: -2),
            "carbonate": Anion(name: "carbonate", symbol: "(CO3)", charge: -2),
            "phosphate": Anion(name: "phosphate", symbol: "(PO4)", charge: -3),
            "cyanide": Anion(name: "cyanide", symbol: "(CN)", charge: -1),
            "thiocyanate": Anion(name: "thiocyanate", symbol: "(SCN)", charge: -1),
            "bromate": Anion(name: "bromate", symbol: "(BrO3)", charge: -1),
            "chlorate": Anion(name: "chlorate", symbol: "(ClO3)", charge: -1),
            "chlorite": Anion(name: "chlorite", symbol: "(ClO2)", charge: -1),
            "sulfite": Anion(name: "sulfite", symbol: "(SO3)", charge: -2),
            "nitrite": Anion(name: "nitrite", symbol: "(NO2)", charge: -1)
        ]

        let compoundNameComponents = compounds.compoundName.components(separatedBy: " ")

        guard compoundNameComponents.count == 2 else {
            return nil // Invalid compound name format
        }

        let firstWord = compoundNameComponents[0]
        let secondWord = compoundNameComponents[1]

        if let userCation = cations[firstWord], let userAnion = anions[secondWord] {
            let cationSymbol = userCation.symbol
            let cationCharge = userCation.charge
            let anionSymbol = userAnion.symbol
            let anionCharge = userAnion.charge

            var cationSubscript = 0
            var anionSubscript = 0

            cationSubscript = -(anionCharge)
            anionSubscript = cationCharge

            if cationSubscript == anionSubscript {
                cationSubscript = 1
                anionSubscript = 1
            } else if cationSubscript == 2 && anionSubscript == 4 {
                cationSubscript = 1
                anionSubscript = 2
            }

            let formula = "\(cationSymbol)\(cationSubscript > 1 ? "\(cationSubscript)" : "")\(anionSymbol)\(anionSubscript > 1 ? "\(anionSubscript)" : "")"

            parsedMolecularFormula = formula

            if let lastCompound = compoundString.last {
                var updatedCompound = lastCompound
                updatedCompound.compoundFormula = parsedMolecularFormula
                compoundString[compoundString.count - 1] = updatedCompound
            }

            return formula
        } else {
            return nil // Cation or anion not found for given words
        }
    }

    func ionicFormulaToName() {
        struct CationsFtN {
            let name: String
            let symbol: String
            let charge: Int
            var tMetal: Bool
        }

        struct AnionsFtN {
            let name: String
            let symbol: String
            let charge: Int
        }

        let cationsFtN: [String: CationsFtN] = [
            "NH4": CationsFtN(name: "ammonium", symbol: "NH4", charge: 1, tMetal: false),
            "H": CationsFtN(name: "hydrogen", symbol: "H", charge: 1, tMetal: false),
            "Li": CationsFtN(name: "lithium", symbol: "Li", charge: 1, tMetal: false),
            "Na": CationsFtN(name: "sodium", symbol: "Na", charge: 1, tMetal: false),
            "K": CationsFtN(name: "potassium", symbol: "K", charge: 1, tMetal: false),
            "Rb": CationsFtN(name: "rubidium", symbol: "Rb", charge: 1, tMetal: false),
            "Cs": CationsFtN(name: "cesium", symbol: "Cs", charge: 1, tMetal: false),
            "Fr": CationsFtN(name: "francium", symbol: "Fr", charge: 1, tMetal: false),
            "Be": CationsFtN(name: "beryllium", symbol: "Be", charge: 2, tMetal: false),
            "Mg": CationsFtN(name: "magnesium", symbol: "Mg", charge: 2, tMetal: false),
            "Ca": CationsFtN(name: "calcium", symbol: "Ca", charge: 2, tMetal: false),
            "Sr": CationsFtN(name: "strontium", symbol: "Sr", charge: 2, tMetal: false),
            "Ba": CationsFtN(name: "barium", symbol: "Ba", charge: 2, tMetal: false),
            "Ra": CationsFtN(name: "radium", symbol: "Ra", charge: 2, tMetal: false),
            "Sc": CationsFtN(name: "scandium", symbol: "Sc", charge: 1, tMetal: true),
            "Ti": CationsFtN(name: "titanium", symbol: "Ti", charge: 1, tMetal: true),
            "V": CationsFtN(name: "vandium", symbol: "V", charge: 1, tMetal: true),
            "Cr": CationsFtN(name: "chromium", symbol: "Cr", charge: 1, tMetal: true),
            "Mn": CationsFtN(name: "manganese", symbol: "Mn", charge: 1, tMetal: true),
            "Fe": CationsFtN(name: "iron", symbol: "Fe", charge: 1, tMetal: true),
            "Co": CationsFtN(name: "cobalt", symbol: "Co", charge: 1, tMetal: true),
            "Ni": CationsFtN(name: "nickel", symbol: "Ni", charge: 1, tMetal: true),
            "Cu": CationsFtN(name: "copper", symbol: "Cu", charge: 1, tMetal: true),
            "Zn": CationsFtN(name: "zinc", symbol: "Zn", charge: 1, tMetal: true),
            "Al": CationsFtN(name: "aluminum", symbol: "Al", charge: 1, tMetal: true),
            "Ga": CationsFtN(name: "gallium", symbol: "Ga", charge: 1, tMetal: true),
            "Y": CationsFtN(name: "yttrium", symbol: "Y", charge: 1, tMetal: true),
            "Zr": CationsFtN(name: "zirconium", symbol: "Zr", charge: 1, tMetal: true),
            "Nb": CationsFtN(name: "niobium", symbol: "Nb", charge: 1, tMetal: true),
            "Mo": CationsFtN(name: "molybdenum", symbol: "Mo", charge: 1, tMetal: true),
            "Tc": CationsFtN(name: "technetium", symbol: "Tc", charge: 1, tMetal: true),
            "Ru": CationsFtN(name: "ruthenium", symbol: "Ru", charge: 1, tMetal: true),
            "Rh": CationsFtN(name: "rhodium", symbol: "Rh", charge: 1, tMetal: true),
            "Pd": CationsFtN(name: "palladium", symbol: "Pd", charge: 1, tMetal: true),
            "Ag": CationsFtN(name: "silver", symbol: "Ag", charge: 1, tMetal: true),
            "Cd": CationsFtN(name: "cadmium", symbol: "Cd", charge: 1, tMetal: true),
            "In": CationsFtN(name: "indium", symbol: "In", charge: 1, tMetal: true),
            "Sn": CationsFtN(name: "tin", symbol: "Sn", charge: 1, tMetal: true),
            "W": CationsFtN(name: "tungsten", symbol: "W", charge: 1, tMetal: true),
            "Re": CationsFtN(name: "rhenium", symbol: "Re", charge: 1, tMetal: true),
            "Ir": CationsFtN(name: "iridium", symbol: "Ir", charge: 1, tMetal: true),
            "Pt": CationsFtN(name: "platinum", symbol: "Pt", charge: 1, tMetal: true),
            "Au": CationsFtN(name: "gold", symbol: "Au", charge: 1, tMetal: true),
            "Hg": CationsFtN(name: "mercury", symbol: "Hg", charge: 1, tMetal: true),
            "Tl": CationsFtN(name: "thallium", symbol: "Tl", charge: 1, tMetal: true),
            "Pb": CationsFtN(name: "lead", symbol: "Pb", charge: 1, tMetal: true),
            "Bi": CationsFtN(name: "bismuth", symbol: "Bi", charge: 1, tMetal: true)
        ]

        let anionsFtN: [String: AnionsFtN] = [
            "H": AnionsFtN(name: "hydride", symbol: "H", charge: -1),
            "F": AnionsFtN(name: "fluoride", symbol: "F", charge: -1),
            "Cl": AnionsFtN(name: "chloride", symbol: "Cl", charge: -1),
            "Br": AnionsFtN(name: "bromide", symbol: "Br", charge: -1),
            "I": AnionsFtN(name: "iodide", symbol: "I", charge: -1),
            "At": AnionsFtN(name: "astatide", symbol: "At", charge: -1),
            "O": AnionsFtN(name: "oxide", symbol: "O", charge: -2),
            "S": AnionsFtN(name: "sulfide", symbol: "S", charge: -2),
            "Se": AnionsFtN(name: "selenide", symbol: "Se", charge: -2),
            "Te": AnionsFtN(name: "telluride", symbol: "Te", charge: -2),
            "N": AnionsFtN(name: "nitride", symbol: "N", charge: -3),
            "P": AnionsFtN(name: "phosphide", symbol: "P", charge: -3),
            "As": AnionsFtN(name: "arsenide", symbol: "As", charge: -3),
            "NO3": AnionsFtN(name: "nitrate", symbol: "NO3", charge: -1),
            "OH": AnionsFtN(name: "hydroxide", symbol: "OH", charge: -1),
            "SO4": AnionsFtN(name: "sulfate", symbol: "SO4", charge: -2),
            "CO3": AnionsFtN(name: "carbonate", symbol: "CO3", charge: -2),
            "PO4": AnionsFtN(name: "phosphate", symbol: "PO4", charge: -3),
            "CN": AnionsFtN(name: "cyanide", symbol: "CN", charge: -1),
            "SCN": AnionsFtN(name: "thiocyanate", symbol: "SCN", charge: -1),
            "BrO3": AnionsFtN(name: "bromate", symbol: "BrO3", charge: -1),
            "ClO3": AnionsFtN(name: "chlorate", symbol: "ClO3", charge: -1),
            "ClO2": AnionsFtN(name: "chlorite", symbol: "ClO2", charge: -1),
            "SO3": AnionsFtN(name: "sulfite", symbol: "SO3", charge: -2),
            "NO2": AnionsFtN(name: "nitrite", symbol: "NO2", charge: -1)
        ]

        var cationName = ""
        var anionName = ""
        var romanNumeral = ""
        var totalAnionCharge = 0
        var cationCharge = 0

        let compoundFormula = userInput

        var i = compoundFormula.startIndex
        var ionCount = 0
        var cation = true
        var numberOfCations = 0
        var cationSymbol = ""
        var openParenthesesCount = 0
        var tempAnionCharge = 0

        cationName.removeAll()
        romanNumeral.removeAll()
        anionName.removeAll()

        while i < compoundFormula.endIndex {
            var char = compoundFormula[i]

            if i == compoundFormula.startIndex, compoundFormula.distance(from: i, to: compoundFormula.endIndex) >= 3 {
                let startIndex = compoundFormula.index(i, offsetBy: 3)
                let prefix = compoundFormula[i..<startIndex]

                if prefix == "NH4" {
                    let elementSymbol = "NH4"
                    if let tempName = cationsFtN[elementSymbol] {
                        cationName = tempName.name
                        print("cationName \(cationName)")
                    }
                    ionCount += 1
                    i = startIndex
                    cation = false
                    numberOfCations = 1
                    continue
                }
            }

            if i == compoundFormula.startIndex, compoundFormula.distance(from: i, to: compoundFormula.endIndex) >= 5 {
                let startIndex = compoundFormula.index(i, offsetBy: 5)
                let prefix = compoundFormula[i..<startIndex]

                if prefix == "(NH4)" {
                    cationName = "ammonium"
                    i = startIndex
                    cation = false
                    numberOfCations = 1
                    print("cation name: \(cationName)")

                    char = compoundFormula[i]

                    if char.isNumber {
                        i = compoundFormula.index(after: i)

                        if i < compoundFormula.endIndex {
                            char = compoundFormula[i]
                        }
                    }
                    continue
                }
            }

            if cation == true && char.isLetter {
                var elementSymbol = String(char)
                i = compoundFormula.index(after: i)

                if i < compoundFormula.endIndex {
                    char = compoundFormula[i]
                }

                while i < compoundFormula.endIndex && compoundFormula[i].isLowercase {
                    elementSymbol.append(compoundFormula[i])
                    i = compoundFormula.index(after: i)

                    if i < compoundFormula.endIndex {
                        char = compoundFormula[i]
                    }
                }
                ionCount += 1
                var subscriptValue = ""

                while i < compoundFormula.endIndex && compoundFormula[i].isNumber {
                    subscriptValue.append(compoundFormula[i])
                    i = compoundFormula.index(after: i)

                    if i < compoundFormula.endIndex {
                        char = compoundFormula[i]
                    }
                }

                let multiplier = Double(subscriptValue) ?? 1.0
                numberOfCations = ionCount * Int(multiplier)
                print("cationCount \(numberOfCations)")

                if let tempSymbol = cationsFtN[elementSymbol] {
                    cationSymbol = tempSymbol.symbol
                    print("cationSymbol \(cationSymbol)")
                } else {
                    print("Error: Unrecognized cation symbol \(elementSymbol)")
                    return
                }

                if let tempName = cationsFtN[elementSymbol] {
                    cationName = tempName.name
                    print("cationName \(cationName)")
                } else {
                    print("Error: Unrecognized cation symbol \(elementSymbol)")
                    return
                }

                cation = false
                elementSymbol.removeAll()
                subscriptValue.removeAll()

                if i < compoundFormula.endIndex {
                    char = compoundFormula[i]
                }

                if i == compoundFormula.endIndex {
                    print("no anion")
                    anionName = "(no anion found)"
                    return
                }
            }

            if char == "(" {
                openParenthesesCount += 1
                i = compoundFormula.index(after: i)
                if i < compoundFormula.endIndex {
                    char = compoundFormula[i]
                }

                while openParenthesesCount > 0 && i < compoundFormula.endIndex {
                    if char.isLetter {
                        var elementSymbol = String(char)
                        i = compoundFormula.index(after: i)

                        while i < compoundFormula.endIndex && char != ")" {
                            openParenthesesCount -= 1
                            elementSymbol.append(compoundFormula[i])
                            i = compoundFormula.index(after: i)

                            if i < compoundFormula.endIndex {
                                char = compoundFormula[i]
                            }
                        }

                        if i < compoundFormula.endIndex {
                            char = compoundFormula[i]
                        }

                        if let anion = anionsFtN[elementSymbol] {
                            tempAnionCharge = anion.charge
                            anionName = anion.name
                            print("anion name: \(anionName)")
                            print("anion charge: \(tempAnionCharge)")
                        } else {
                            print("Error: Unrecognized anion symbol \(elementSymbol)")
                            return
                        }
                    }
                    var subscriptValue = ""
                    i = compoundFormula.index(after: i)

                    while i < compoundFormula.endIndex && compoundFormula[i].isNumber {
                        subscriptValue.append(compoundFormula[i])
                        i = compoundFormula.index(after: i)

                        if i < compoundFormula.endIndex {
                            char = compoundFormula[i]
                        }
                    }

                    let multiplier = Double(subscriptValue) ?? 1.0
                    totalAnionCharge = tempAnionCharge * Int(multiplier)
                    print("totalCharge \(totalAnionCharge)")

                    subscriptValue.removeAll()

                    cationCharge = abs(totalAnionCharge) / numberOfCations
                    print("cationCharge \(cationCharge)")

                    if i < compoundFormula.endIndex {
                        char = compoundFormula[i]
                    }
                }
            }

            if char.isLetter {
                var elementSymbol = String(char)
                i = compoundFormula.index(after: i)

                if i < compoundFormula.endIndex {
                    char = compoundFormula[i]
                }

                while i < compoundFormula.endIndex && compoundFormula[i].isLowercase {
                    elementSymbol.append(compoundFormula[i])
                    i = compoundFormula.index(after: i)

                    if i < compoundFormula.endIndex {
                        char = compoundFormula[i]
                    }
                }

                while i < compoundFormula.endIndex && compoundFormula[i].isUppercase {
                    elementSymbol.append(compoundFormula[i])
                    i = compoundFormula.index(after: i)

                    while i < compoundFormula.endIndex && compoundFormula[i].isNumber {
                        elementSymbol.append(compoundFormula[i])
                        i = compoundFormula.index(after: i)


                        
                        if i < compoundFormula.endIndex {
                            char = compoundFormula[i]
                        }
                    }
                    
                    if i < compoundFormula.endIndex {
                        char = compoundFormula[i]
                    }
                }
                
                if let anion = anionsFtN[elementSymbol] {
                    tempAnionCharge = anion.charge
                    anionName = anion.name
                    print("anion name: \(anionName)")
                    print("anion charge: \(tempAnionCharge)")
                } // anion name and charge
                
                else {
                    print("Anion not found")
                }
                
                var subscriptValue = ""
                
                while i < compoundFormula.endIndex && compoundFormula[i].isNumber {
                    subscriptValue.append(compoundFormula[i])
                    i = compoundFormula.index(after: i)
                    
                    if i < compoundFormula.endIndex {
                        char = compoundFormula[i]
                    }
                } // anion subscript
                
                
                let multiplier = Double(subscriptValue) ?? 1.0
                totalAnionCharge = tempAnionCharge * Int(multiplier)
                print("totalCharge \(totalAnionCharge)")
                
                subscriptValue.removeAll()
                
                cationCharge = abs(totalAnionCharge)/numberOfCations
                print("cationCharge \(cationCharge)")
                
                if i < compoundFormula.endIndex {
                    char = compoundFormula[i]
                }
                
            } // anion name, charge, total charge, cation charge
            
        }
        
        if cationSymbol.isEmpty {
            // Handle the case where no cation was found
            print("Error: No cation found.")
            return
        }
        
        if let cationInfo = cationsFtN[cationSymbol] {
            if cationInfo.tMetal == true {
                print("\(cationSymbol) is a transition metal.")
                convertToRoman(cationCharge)
                print("Roman Number \(romanNumeral)")
            } else {
                romanNumeral = ""
                print("\(cationSymbol) is not a transition metal.")
            }
        } else {
            print("Cation information not found.")
        }
        
        func convertToRoman(_ charge: Int) {
            guard charge > 0 && charge < 10 else {
                romanNumeral = "Invalid input. Please enter a number between 1 and 9."
                return
            }
            
            let numerals: [Int: String] = [1: "(I)", 2: "(II)", 3: "(III)", 4: "(IV)", 5: "(V)", 6: "(VI)", 7: "(VII)", 8: "(VIII)", 9: "(IX)"]
            
            romanNumeral = numerals[charge] ?? ""
        } // Roman Numerals for tMetals
        
        let ionicNameString = ("  \(cationName)\(romanNumeral) \(anionName)  ")
        
        if let firstCompound = compoundString.first {
            parsedMolecularFormula = firstCompound.compoundFormula
            // Update the compoudString array with the modified firstCompound
            compoundString[0] = firstCompound}
        
        if var firstCompound = compoundString.first {
            firstCompound.compoundName = ionicNameString
            // Update the compoudString array with the modified firstCompound
            compoundString[0] = firstCompound}
        
    }
    
}

struct TextFormatFormula: View {
    
    let parsedFormula: String

    var body: some View {
        Text(ChemicalFormulaFormatter.format(parsedFormula, omittingOnes: true))
    }
}

#Preview {
    GenChemNamingView()
}
