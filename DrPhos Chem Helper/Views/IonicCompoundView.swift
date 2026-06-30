// MARK: Ion symbol formatting applied — return here if display issues occur
func formattedIonSymbol(_ symbol: String) -> Text {
    var result = Text("")
    for char in symbol {
        if char.isNumber {
            result = result + Text(String(char))
                .font(.title2)
                .baselineOffset(-5)
        } else {
            result = result + Text(String(char))
                .font(.title)
        }
    }
    return result
    
}
//
//  Cations.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 7/23/25.
//

import SwiftUI

struct Cations {
    let name: String
    let symbol: String
    let charge: Int
}

struct Anions {
    let name: String
    let symbol: String
    let charge: Int
}

let cations: [String: Cations] = [
    "aluminum(I)": Cations(name: "aluminum(I)", symbol: "Al", charge: 1),
    "aluminum(III)": Cations(name: "aluminum(III)", symbol: "Al", charge: 3),
    "ammonium": Cations(name: "ammonium", symbol: "NH4", charge: 1),
    "antimony(II)": Cations(name: "antimony(II)", symbol: "Sb", charge: 2),
    "barium": Cations(name: "barium", symbol: "Ba", charge: 2),
    "beryllium": Cations(name: "beryllium", symbol: "Be", charge: 2),
    "bismuth(III)": Cations(name: "bismuth(III)", symbol: "Bi", charge: 3),
    "cadmium(II)": Cations(name: "cadmium(II)", symbol: "Cd", charge: 2),
    "calcium": Cations(name: "calcium", symbol: "Ca", charge: 2),
    "cerium(IV)": Cations(name: "cerium(IV)", symbol: "Ce", charge: 4),
    "cesium": Cations(name: "cesium", symbol: "Cs", charge: 1),
    "chromium(II)": Cations(name: "chromium(II)", symbol: "Cr", charge: 2),
    "chromium(III)": Cations(name: "chromium(III)", symbol: "Cr", charge: 3),
    "chromium(VI)": Cations(name: "chromium(VI)", symbol: "Cr", charge: 6),
    "cobalt(I)": Cations(name: "cobalt(I)", symbol: "Co", charge: 1),
    "cobalt(II)": Cations(name: "cobalt(II)", symbol: "Co", charge: 2),
    "cobalt(III)": Cations(name: "cobalt(III)", symbol: "Co", charge: 3),
    "copper(I)": Cations(name: "copper(I)", symbol: "Cu", charge: 1),
    "copper(II)": Cations(name: "copper(II)", symbol: "Cu", charge: 2),
    "francium": Cations(name: "francium", symbol: "Fr", charge: 1),
    "gallium(III)": Cations(name: "gallium(III)", symbol: "Ga", charge: 3),
    "gold(I)": Cations(name: "gold(I)", symbol: "Au", charge: 1),
    "hydrogen": Cations(name: "hydrogen", symbol: "H", charge: 1),
    "indium(III)": Cations(name: "indium(III)", symbol: "In", charge: 3),
    "iron(I)": Cations(name: "iron(I)", symbol: "Fe", charge: 1),
    "iron(II)": Cations(name: "iron(II)", symbol: "Fe", charge: 2),
    "iron(III)": Cations(name: "iron(III)", symbol: "Fe", charge: 3),
    "iron(IV)": Cations(name: "iron(IV)", symbol: "Fe", charge: 4),
    "lanthanum(III)": Cations(name: "lanthanum(III)", symbol: "La", charge: 3),
    "lead(II)": Cations(name: "lead(II)", symbol: "Pb", charge: 2),
    "lead(IV)": Cations(name: "lead(IV)", symbol: "Pb", charge: 4),
    "lithium": Cations(name: "lithium", symbol: "Li", charge: 1),
    "magnesium": Cations(name: "magnesium", symbol: "Mg", charge: 2),
    "manganese(II)": Cations(name: "manganese(II)", symbol: "Mn", charge: 2),
    "manganese(III)": Cations(name: "manganese(III)", symbol: "Mn", charge: 3),
    "manganese(IV)": Cations(name: "manganese(IV)", symbol: "Mn", charge: 4),
    "manganese(V)": Cations(name: "manganese(V)", symbol: "Mn", charge: 5),
    "manganese(VI)": Cations(name: "manganese(VI)", symbol: "Mn", charge: 6),
    "mercury(I)": Cations(name: "mercury(I)", symbol: "Hg", charge: 1),
    "mercury(II)": Cations(name: "mercury(II)", symbol: "Hg", charge: 2),
    "mercury(III)": Cations(name: "mercury(III)", symbol: "Hg", charge: 3),
    "molybdenum(VI)": Cations(name: "molybdenum(VI)", symbol: "Mo", charge: 6),
    "neodymium(III)": Cations(name: "neodymium(III)", symbol: "Nd", charge: 3),
    "nickel(I)": Cations(name: "nickel(I)", symbol: "Ni", charge: 1),
    "nickel(II)": Cations(name: "nickel(II)", symbol: "Ni", charge: 2),
    "nickel(III)": Cations(name: "nickel(III)", symbol: "Ni", charge: 3),
    "niobium(III)": Cations(name: "niobium(III)", symbol: "Nb", charge: 3),
    "niobium(V)": Cations(name: "niobium(V)", symbol: "Nb", charge: 5),
    "palladium(II)": Cations(name: "palladium(II)", symbol: "Pd", charge: 2),
    "palladium(IV)": Cations(name: "palladium(IV)", symbol: "Pd", charge: 4),
    "platinum(II)": Cations(name: "platinum(II)", symbol: "Pt", charge: 2),
    "platinum(IV)": Cations(name: "platinum(IV)", symbol: "Pt", charge: 4),
    "potassium": Cations(name: "potassium", symbol: "K", charge: 1),
    "radium": Cations(name: "radium", symbol: "Ra", charge: 2),
    "rhenium(I)": Cations(name: "rhenium(I)", symbol: "Re", charge: 1),
    "rhodium(III)": Cations(name: "rhodium(III)", symbol: "Rh", charge: 3),
    "rubidium": Cations(name: "rubidium", symbol: "Rb", charge: 1),
    "ruthenium(III)": Cations(name: "ruthenium(III)", symbol: "Ru", charge: 3),
    "ruthenium(IV)": Cations(name: "ruthenium(IV)", symbol: "Ru", charge: 4),
    "scandium(III)": Cations(name: "scandium(III)", symbol: "Sc", charge: 3),
    "silver(I)": Cations(name: "silver(I)", symbol: "Ag", charge: 1),
    "sodium": Cations(name: "sodium", symbol: "Na", charge: 1),
    "strontium": Cations(name: "strontium", symbol: "Sr", charge: 2),
    "technetium(VII)": Cations(name: "technetium(VII)", symbol: "Tc", charge: 7),
    "thallium(I)": Cations(name: "thallium(I)", symbol: "Tl", charge: 1),
    "thorium(IV)": Cations(name: "thorium(IV)", symbol: "Th", charge: 4),
    "tin(II)": Cations(name: "tin(II)", symbol: "Sn", charge: 2),
    "tin(IV)": Cations(name: "tin(IV)", symbol: "Sn", charge: 4),
    "titanium(II)": Cations(name: "titanium(II)", symbol: "Ti", charge: 2),
    "titanium(III)": Cations(name: "titanium(III)", symbol: "Ti", charge: 3),
    "titanium(IV)": Cations(name: "titanium(IV)", symbol: "Ti", charge: 4),
    "uranium(IV)": Cations(name: "uranium(IV)", symbol: "U", charge: 4),
    "uranium(VI)": Cations(name: "uranium(VI)", symbol: "UO2", charge: 2),
    "vanadium(III)": Cations(name: "vanadium(III)", symbol: "V", charge: 3),
    "vanadium(IV)": Cations(name: "vanadium(IV)", symbol: "VO", charge: 2),
    "vandium(II)": Cations(name: "vandium(II)", symbol: "V", charge: 3),
    "vandium(V)": Cations(name: "vandium(V)", symbol: "V", charge: 5),
    "yttrium(III)": Cations(name: "yttrium(III)", symbol: "Y", charge: 3),
    "zinc(II)": Cations(name: "zinc(II)", symbol: "Zn", charge: 2),
    "zirconium(II)": Cations(name: "zirconium(II)", symbol: "Zr", charge: 2),
    "zirconium(IV)": Cations(name: "zirconium(IV)", symbol: "Zr", charge: 4),
] // cation dictionary
let anions: [String: Anions] = [
    "hydride": Anions(name: "hydride", symbol: "H", charge: -1),
    "fluoride": Anions(name: "fluoride", symbol: "F", charge: -1),
    "chloride": Anions(name: "chloride", symbol: "Cl", charge: -1),
    "bromide": Anions(name: "bromide", symbol: "Br", charge: -1),
    "iodide": Anions(name: "iodide", symbol: "I", charge: -1),
    "astatide": Anions(name: "astatide", symbol: "At", charge: -1),
    "oxide": Anions(name: "oxide", symbol: "O", charge: -2),
    "sulfide": Anions(name: "sulfide", symbol: "S", charge: -2),
    "selenide": Anions(name: "selenide", symbol: "Se", charge: -2),
    "telluride": Anions(name: "telluride", symbol: "Te", charge: -2),
    "nitride": Anions(name: "nitride", symbol: "N", charge: -3),
    "phosphide": Anions(name: "phosphide", symbol: "P", charge: -3),
    "arsenide": Anions(name: "arsenide", symbol: "As", charge: -3),
    "nitrate": Anions(name: "nitrate", symbol: "NO3", charge: -1),
    "hydroxide": Anions(name: "hydroxide", symbol: "OH", charge: -1),
    "sulfate": Anions(name: "sulfate", symbol: "SO4", charge: -2),
    "carbonate": Anions(name: "carbonate", symbol: "CO3", charge: -2),
    "phosphate": Anions(name: "phosphate", symbol: "PO4", charge: -3),
    "cyanide": Anions(name: "cyanide", symbol: "CN", charge: -1),
    "thiocyanate": Anions(name: "thiocyanate", symbol: "SCN", charge: -1),
    "bromate": Anions(name: "bromate", symbol: "BrO3", charge: -1),
    "chlorate": Anions(name: "chlorate", symbol: "ClO3", charge: -1),
    "chlorite": Anions(name: "chlorite", symbol: "ClO2", charge: -1),
    "sulfite": Anions(name: "sulfite", symbol: "SO3", charge: -2),
    "nitrite": Anions(name: "nitrite", symbol: "NO2", charge: -1),
    // Inserted entries:
    "poloniumide": Anions(name: "poloniumide", symbol: "Po", charge: -2),
    "antimonide": Anions(name: "antimonide", symbol: "Sb", charge: -3),
    "bismuthide": Anions(name: "bismuthide", symbol: "Bi", charge: -3),
    "carbide": Anions(name: "carbide", symbol: "C", charge: -4),
    "silicide": Anions(name: "silicide", symbol: "Si", charge: -4),
    "acetate": Anions(name: "acetate", symbol: "C2H3O2", charge: -1),
    // Newly added entries:
    "perchlorate": Anions(name: "perchlorate", symbol: "ClO4", charge: -1),
    "permanganate": Anions(name: "permanganate", symbol: "MnO4", charge: -1),
    "dichromate": Anions(name: "dichromate", symbol: "Cr2O7", charge: -2),
    "chromate": Anions(name: "chromate", symbol: "CrO4", charge: -2),
    "hydrogen carbonate": Anions(name: "hydrogen carbonate", symbol: "HCO3", charge: -1),
    "hydrogen sulfate": Anions(name: "hydrogen sulfate", symbol: "HSO4", charge: -1),
    "hydrogen phosphate": Anions(name: "hydrogen phosphate", symbol: "HPO4", charge: -2),
    "dihydrogen phosphate": Anions(name: "dihydrogen phosphate", symbol: "H2PO4", charge: -1),
    // Additional entries:
    "peroxide": Anions(name: "peroxide", symbol: "O2", charge: -2),
    "hypochlorite": Anions(name: "hypochlorite", symbol: "ClO", charge: -1),
    "perbromate": Anions(name: "perbromate", symbol: "BrO4", charge: -1),
    "periodate": Anions(name: "periodate", symbol: "IO4", charge: -1),
    "oxalate": Anions(name: "oxalate", symbol: "C2O4", charge: -2),
    "tartrate": Anions(name: "tartrate", symbol: "C4H4O6", charge: -2),
    "thiosulfate": Anions(name: "thiosulfate", symbol: "S2O3", charge: -2),
    // Newly inserted entries before closing bracket:
    "arsenate": Anions(name: "arsenate", symbol: "AsO4", charge: -3),
    "borate": Anions(name: "borate", symbol: "BO3", charge: -3),
    "bromite": Anions(name: "bromite", symbol: "BrO2", charge: -1),
    "hypobromite": Anions(name: "hypobromite", symbol: "BrO", charge: -1),
    "iodate": Anions(name: "iodate", symbol: "IO3", charge: -1),
    "iodite": Anions(name: "iodite", symbol: "IO2", charge: -1),
    "hypoiodite": Anions(name: "hypoiodite", symbol: "IO", charge: -1),
    "tellurate": Anions(name: "tellurate", symbol: "TeO4", charge: -2),
] // anion dictionary

struct IonicCompoundBuilderView: View {
    @State private var selectedCation: String = "Cations"
    @State private var selectedAnion: String = "Anions"
    

    private var cationSymbols: String {
        return cations[selectedCation]?.symbol ?? "Unknown Cation"
    }
    private var anionSymbols: String {
        return anions[selectedAnion]?.symbol ?? "Unknown Anion"
    }

    var body: some View {
        VStack {
            
            DrPhosSectionHeader(title: "Ionic Compound Builder")
                .fontWeight(.bold)

            FormulaView(userCation: $selectedCation, userAnion: $selectedAnion)
                .padding(10)
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(Color.numbers)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.numbers, lineWidth: 2)
                )
                .padding(.top, 10)
            
            HStack {
                Spacer()
                
                VStack {
                    
                    Text("Cation")
                        .font(.title)
                        .underline()
                        .foregroundColor(Color.phosblue1)
                        .padding(.bottom, 4)
                    
                    if let cation = cations[selectedCation] {
                        HStack(spacing: 2) {
                            formattedIonSymbol(cationSymbols)
                            Text(" = +\(cation.charge)")
                                .font(.title)
                        }
                        .foregroundColor(Color.phosblue1)
                    }
                    
                    Picker("Select Cation", selection: $selectedCation) {
                        ForEach(cations.keys.sorted(), id: \.self) { cation in
                            Text(cation)
                                .foregroundColor(Color.phosblue1)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.phosblue1, lineWidth: 1)
                    )
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: 180)
                
                    
                }
                
                Spacer()
                
                VStack {
                    Text("Anion")
                        .font(.title)
                        .foregroundColor(Color.phosred1)
                        .underline()
                        .padding(.bottom, 4)
                    
                    if let anion = anions[selectedAnion] {
                        HStack(spacing: 2) {
                            formattedIonSymbol(anionSymbols)
                            Text(" = \(anion.charge)")
                                .font(.title)
                        }
                        .foregroundColor(Color.phosred1)
                    }
                    
                    
                    Picker("Select Anion", selection: $selectedAnion) {
                        ForEach(anions.keys.sorted(), id: \.self) { anion in
                            Text(anion)
                                .foregroundColor(Color.phosred1)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.phosred1, lineWidth: 1)
                    )
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: 180)
          
                }
                
                
                Spacer()
            }
            

            Spacer()
        }
//        .padding(.top, -50)
        .onAppear {
            let middleCationIndex = cations.keys.sorted().count / 2
            selectedCation = Array(cations.keys.sorted())[middleCationIndex]

            let middleAnionIndex = anions.keys.sorted().count / 2
            selectedAnion = Array(anions.keys.sorted())[middleAnionIndex]
        }
    }
}

struct FormulaView: View {
    @Binding var userCation: String
    @Binding var userAnion: String
    @State private var cationName = ""
    @State private var anionName = ""
    @State private var cationSymbol = ""
    @State private var anionSymbol = ""
    @State private var cationCharge = 0
    @State private var anionCharge = 0
    @State private var cationSubscript = 0
    @State private var anionSubscript = 0
    @State private var shouldUpdateResult = false

    var body: some View {
        HStack(spacing: 0) {
            if shouldUpdateResult {
                
                if cationName == "ammonium" && cationSubscript == 1 {
                    ammonium()
                } // NH4 without parentheses
                
                else if cationName == "ammonium" && cationSubscript > 1 {
                    ammoniumPar()
                } // NH4 with parentheses
                
                else {
                    Text("\(cationSymbol)")
                        .font(.title)
                        .baselineOffset(2)
                } // cation symbol
                
                Text(cationSubscript > 1 ? "\(cationSubscript)" : "")
                    .font(.title2)
                    .baselineOffset(-15)
                
                if anionName == "nitrate" && anionSubscript == 1 {
                    nitrate()
                } // NO3 with no parentheses
                
                else if anionName == "nitrate" && anionSubscript > 1 {
                    nitratePar()
                } // NO3 with parentheses
                
                else if anionName == "hydroxide" && anionSubscript == 1 {
                    hydroxide()
                } // OH with no parentheses
                
                else if anionName == "hydroxide" && anionSubscript > 1 {
                    hydroxidePar()
                } // OH with parentheses
                
                else if anionName == "phosphate" && anionSubscript == 1 {
                    phosphate()
                } // PO4 without parentheses
                
                else if anionName == "phosphate" && anionSubscript > 1 {
                    phosphatePar()
                } // PO4 with parentheses
                
                else if anionName == "sulfate" && anionSubscript == 1 {
                    sulfate()
                } // SO4 without parentheses
                
                else if anionName == "sulfate" && anionSubscript > 1 {
                    sulfatePar()
                } // SO4 with parentheses
                
                else if anionName == "carbonate" && anionSubscript == 1 {
                    carbonate()
                } // CO3 without parentheses
                
                else if anionName == "carbonate" && anionSubscript > 1 {
                    carbonatePar()
                } // CO3 with parentheses
                
                else if anionName == "cyanide" && anionSubscript == 1 {
                    cyanide()
                } // CN with no parentheses
                
                else if anionName == "cyanide" && anionSubscript > 1 {
                    cyanidePar()
                } // CN with parentheses
                
                else if anionName == "thiocyanate" && anionSubscript == 1 {
                    thiocyanate()
                } // SCN with no parentheses
                
                else if anionName == "thiocyanate" && anionSubscript > 1 {
                    thiocyanatePar()
                } // SCN with parentheses
                
                else if anionName == "bromate" && anionSubscript == 1 {
                    bromate()
                } // BrO3 without parentheses
                
                else if anionName == "bromate" && anionSubscript > 1 {
                    bromatePar()
                } // BrO3 with parentheses

                else if anionName == "bromite" && anionSubscript == 1 {
                    bromite()
                } // BrO2 without parentheses

                else if anionName == "bromite" && anionSubscript > 1 {
                    bromitePar()
                } // BrO2 with parentheses

                else if anionName == "perbromate" && anionSubscript == 1 {
                    perbromate()
                } else if anionName == "perbromate" && anionSubscript > 1 {
                    perbromatePar()
                }
                
                else if anionName == "chlorate" && anionSubscript == 1 {
                    chlorate()
                } // ClO3 without parentheses
                
                else if anionName == "chlorate" && anionSubscript > 1 {
                    chloratePar()
                } // ClO3 with parentheses
                
                else if anionName == "chlorite" && anionSubscript == 1 {
                    chlorite()
                } // ClO2 without parentheses
                
                else if anionName == "chlorite" && anionSubscript > 1 {
                    chloritePar()
                } // ClO2 with parentheses
                
                else if anionName == "sulfite" && anionSubscript == 1 {
                    sulfite()
                } // SO3 without parentheses
                
                else if anionName == "sulfite" && anionSubscript > 1 {
                    sulfitePar()
                } // SO3 with parentheses
                
                else if anionName == "nitrite" && anionSubscript == 1 {
                    nitrite()
                } // NO2 without parentheses
                
                else if anionName == "nitrite" && anionSubscript > 1 {
                    nitritePar()
                } // NO2 with parentheses

                else if anionName == "acetate" && anionSubscript == 1 {
                    acetate()
                } // C2H3O2 without parentheses

                else if anionName == "acetate" && anionSubscript > 1 {
                    acetatePar()
                } // C2H3O2 with parentheses
                
                else if anionName == "perchlorate" && anionSubscript == 1 {
                    perchlorate()
                } else if anionName == "perchlorate" && anionSubscript > 1 {
                    perchloratePar()
                }

                else if anionName == "permanganate" && anionSubscript == 1 {
                    permanganate()
                } else if anionName == "permanganate" && anionSubscript > 1 {
                    permanganatePar()
                }

                else if anionName == "dichromate" && anionSubscript == 1 {
                    dichromate()
                } else if anionName == "dichromate" && anionSubscript > 1 {
                    dichromatePar()
                }

                else if anionName == "chromate" && anionSubscript == 1 {
                    chromate()
                } else if anionName == "chromate" && anionSubscript > 1 {
                    chromatePar()
                }
                
                else if anionName == "hydrogen carbonate" && anionSubscript == 1 {
                    hydrogenCarbonate()
                } else if anionName == "hydrogen carbonate" && anionSubscript > 1 {
                    hydrogenCarbonatePar()
                }

                else if anionName == "hydrogen phosphate" && anionSubscript == 1 {
                    hydrogenPhosphate()
                } else if anionName == "hydrogen phosphate" && anionSubscript > 1 {
                    hydrogenPhosphatePar()
                }
   
                else if anionName == "hydrogen sulfate" && anionSubscript == 1 {
                    hydrogenSulfate()
                } else if anionName == "hydrogen sulfate" && anionSubscript > 1 {
                    hydrogenSulfatePar()
                }
                
                else if anionName == "hypobromite" && anionSubscript == 1 {
                    hypobromite()
                } else if anionName == "hypobromite" && anionSubscript > 1 {
                    hypobromitePar()
                }
                else if anionName == "hypochlorite" && anionSubscript == 1 {
                    hypochlorite()
                } else if anionName == "hypochlorite" && anionSubscript > 1 {
                    hypochloritePar()
                }
                else if anionName == "hypoiodite" && anionSubscript == 1 {
                    hypoiodite()
                } else if anionName == "hypoiodite" && anionSubscript > 1 {
                    hypoioditePar()
                }
                // Arsenate handling
                else if anionName == "arsenate" && anionSubscript == 1 {
                    arsenate()
                } else if anionName == "arsenate" && anionSubscript > 1 {
                    arsenatePar()
                }
                else if anionName == "borate" && anionSubscript == 1 {
                    borate()
                } else if anionName == "borate" && anionSubscript > 1 {
                    boratePar()
                }
                else if anionName == "iodate" && anionSubscript == 1 {
                    iodate()
                } else if anionName == "iodate" && anionSubscript > 1 {
                    iodatePar()
                }
                else if anionName == "periodate" && anionSubscript == 1 {
                    periodate()
                } else if anionName == "periodate" && anionSubscript > 1 {
                    periodatePar()
                }
                else if anionName == "iodite" && anionSubscript == 1 {
                    iodite()
                } else if anionName == "iodite" && anionSubscript > 1 {
                    ioditePar()
                }
                else if anionName == "oxalate" && anionSubscript == 1 {
                    oxalate()
                } else if anionName == "oxalate" && anionSubscript > 1 {
                    oxalatePar()
                }
                else if anionName == "tartrate" && anionSubscript == 1 {
                    tartrate()
                } else if anionName == "tartrate" && anionSubscript > 1 {
                    tartratePar()
                }
                else if anionName == "dihydrogen phosphate" && anionSubscript == 1 {
                    dihydrogenPhosphate()
                } else if anionName == "dihydrogen phosphate" && anionSubscript > 1 {
                    dihydrogenPhosphatePar()
                }
                else if anionName == "peroxide" && anionSubscript == 1 {
                    peroxide()
                } else if anionName == "peroxide" && anionSubscript > 1 {
                    peroxidePar()
                }
                else if anionName == "thiosulfate" && anionSubscript == 1 {
                    thiosulfate()
                } else if anionName == "thiosulfate" && anionSubscript > 1 {
                    thiosulfatePar()
                }
                else {
                    Text("\(anionSymbol)")
                        .font(.title)
                        .baselineOffset(0)
                } // anion symbol
                
                Text(anionSubscript > 1 ? "\(anionSubscript)" : "")
                    .font(.title2)
                    .baselineOffset(-10)
    
            }
        }
        .onChange(of: userCation) {
            updateResult()
        }
        .onChange(of: userAnion) {
            updateResult()
        }
    }

    func updateResult() {
        findCationCharge()
        findAnionCharge()
        findSubscripts()
        shouldUpdateResult = true
    }

    func findCationCharge() {
        if let cation = cations[userCation] {
            cationSymbol = cation.symbol
            cationCharge = cation.charge
            cationName = cation.name
        }
    }

    func findAnionCharge() {
        if let anion = anions[userAnion] {
            anionSymbol = anion.symbol
            anionCharge = anion.charge
            anionName = anion.name
        }
    }

    func findSubscripts() {
        cationSubscript = -(anionCharge)
        anionSubscript = cationCharge

        if cationSubscript == anionSubscript {
            cationSubscript = 1
            anionSubscript = 1
        } else if cationSubscript == 2 && anionSubscript == 4 {
            cationSubscript = 1
            anionSubscript = 2
        }
    }
    
    func hydroxide() -> some View {
        Text("OH")
            .font(.title)
            .baselineOffset(0)
    } // hydroxide without parentheses
    
    func hydroxidePar() -> some View {
        Text("(OH)")
            .font(.title)
    } // hydroxide with parentheses
    
    func nitrate() -> some View {
        Text("NO")
            .font(.title)
            .baselineOffset(0)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(0)
        
    } // nitrate without parentheses
    
    // MARK: - Iodate functions
    func iodate() -> some View {
        Text("IO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
    } // iodate without parentheses

    func iodatePar() -> some View {
        Text("(IO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // iodate with parentheses

    // MARK: - Periodate functions
    func periodate() -> some View {
        Text("IO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
    } // periodate without parentheses

    func periodatePar() -> some View {
        Text("(IO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // periodate with parentheses\
    // MARK: - Peroxide functions
    func peroxide() -> some View {
        Text("O")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
    } // peroxide without parentheses

    func peroxidePar() -> some View {
        Text("(O")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // peroxide with parentheses
    
    func iodite() -> some View {
        Text("IO")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
    } // iodite without parentheses

    func ioditePar() -> some View {
        Text("(IO")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // iodite with parentheses
    
    func nitratePar() -> some View {
        Text("(NO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
            .baselineOffset(0)
    } // nitrate with parentheses
    
    func phosphate() -> some View {
        Text("PO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        
    } // phosphate without parentheses
    
    func phosphatePar() -> some View {
        Text("(PO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // phosphate with parentheses
    
    // MARK: - Hydrogen phosphate functions
    func hydrogenPhosphate() -> some View {
        Text("HPO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
    } // hydrogen phosphate without parentheses

    func hydrogenPhosphatePar() -> some View {
        Text("(HPO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // hydrogen phosphate with parentheses
    
    func hydrogenSulfate() -> some View {
        Text("HSO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
    } // hydrogen sulfate without parentheses

    func hydrogenSulfatePar() -> some View {
        Text("(HSO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // hydrogen sulfate with parentheses
    
    func hydrogenCarbonate() -> some View {
        Text("HCO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
    } // hydrogen carbonate without parentheses

    func hydrogenCarbonatePar() -> some View {
        Text("(HCO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // hydrogen carbonate with parentheses
    
    // MARK: - Dihydrogen phosphate functions
    func dihydrogenPhosphate() -> some View {
        Text("H")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text("PO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
    }

    func dihydrogenPhosphatePar() -> some View {
        Text("(H")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text("PO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    }
    
    func sulfate() -> some View {
        Text("SO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        
    } // sulfate without parentheses
    
    func sulfatePar() -> some View {
        Text("(SO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // sulfate with parentheses
    
    func carbonate() -> some View {
        Text("CO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
        
    } // carbonate without parentheses
    
    func carbonatePar() -> some View {
        Text("(CO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // carbonate with parentheses
    
    func ammonium() -> some View {
        Text("NH")
            .font(.title)
            .baselineOffset(0)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        
    } // ammonium without parentheses
    
    func ammoniumPar() -> some View {
        Text("(NH")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // ammonium with parentheses
    
    func cyanide() -> some View {
        Text("CN")
            .font(.title)
            .baselineOffset(0)
    } // cyanide without parentheses
    
    func cyanidePar() -> some View {
        Text("(CN)")
            .font(.title)
    } // cyanide with parentheses
    
    func thiocyanate() -> some View {
        Text("SCN")
            .font(.title)
            .baselineOffset(0)
    } // thiocyanate without parentheses
    
    func thiocyanatePar() -> some View {
        Text("(SCN)")
            .font(.title)
    } // thiocyanate with parentheses
    
    func bromate() -> some View {
        Text("BrO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
        
    } // bromate without parentheses
    
    func bromatePar() -> some View {
        Text("(BrO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // bromate with parentheses
    
    func chlorate() -> some View {
        Text("ClO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
        
    } // chlorate without parentheses
    
    func chloratePar() -> some View {
        Text("(ClO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // chlorate with parentheses
    
    func chlorite() -> some View {
        Text("ClO")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        
    } // chlorite without parentheses
    
    func chloritePar() -> some View {
        Text("(ClO")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // chlorite with parentheses
    
    func sulfite() -> some View {
        Text("SO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
        
    } // sulfite without parentheses

    func sulfitePar() -> some View {
        Text("(SO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // sulfite with parentheses
    
    func nitrite() -> some View {
        Text("NO")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
    } // nitrite without parentheses
    
    func nitritePar() -> some View {
        Text("(NO")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // nitrite with parentheses

    func acetate() -> some View {
        Text("C")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text("H")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text("O")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
    } // acetate without parentheses

    func acetatePar() -> some View {
        let carbon = Text("(C").font(.title)
            + Text("2").font(.title2).baselineOffset(-5)
        let hydrogen = Text("H").font(.title)
            + Text("3").font(.title2).baselineOffset(-5)
        let oxygen = Text("O").font(.title)
            + Text("2").font(.title2).baselineOffset(-5)

        return carbon + hydrogen + oxygen + Text(")").font(.title)
    } // acetate with parentheses

    func perchlorate() -> some View {
        Text("ClO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
    }

    func perchloratePar() -> some View {
        Text("(ClO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    }

    func permanganate() -> some View {
        Text("MnO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
    }

    func permanganatePar() -> some View {
        Text("(MnO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    }

    func dichromate() -> some View {
        Text("Cr")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text("O")
            .font(.title)
        +
        Text("7")
            .font(.title2)
            .baselineOffset(-5)
    }

    func dichromatePar() -> some View {
        Text("(Cr")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text("O")
            .font(.title)
        +
        Text("7")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    }

    func chromate() -> some View {
        Text("CrO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
    }

    func chromatePar() -> some View {
        Text("(CrO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    }
    
    // MARK: - Bromite functions
    func bromite() -> some View {
        Text("BrO")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
    } // bromite without parentheses

    func bromitePar() -> some View {
        Text("(BrO")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // bromite with parentheses
    
    // MARK: - Hypobromite functions
    func hypobromite() -> some View {
        Text("BrO")
            .font(.title)
    } // hypobromite without parentheses

    func hypobromitePar() -> some View {
        Text("(BrO)")
            .font(.title)
    } // hypobromite with parentheses

    // MARK: - Hypochlorite functions
    func hypochlorite() -> some View {
        Text("ClO")
            .font(.title)
    } // hypochlorite without parentheses

    func hypochloritePar() -> some View {
        Text("(ClO)")
            .font(.title)
    } // hypochlorite with parentheses

    // MARK: - Hypoiodite functions
    func hypoiodite() -> some View {
        Text("IO")
            .font(.title)
    } // hypoiodite without parentheses

    func hypoioditePar() -> some View {
        Text("(IO)")
            .font(.title)
    } // hypoiodite with parentheses
}

struct IonicCompoundBuilderView_Previews: PreviewProvider {
    static var previews: some View {
        IonicCompoundBuilderView()
    }
    }

    func arsenate() -> some View {
        Text("AsO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
    }

    func arsenatePar() -> some View {
        Text("(AsO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    }

    func borate() -> some View {
        Text("BO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
    }

    func boratePar() -> some View {
        Text("(BO")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    }

    // MARK: - Oxalate functions
    func oxalate() -> some View {
        Text("C")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text("O")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
    } // oxalate without parentheses

    func oxalatePar() -> some View {
        Text("(C")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text("O")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // oxalate with parentheses

    // MARK: - Perbromate functions
    func perbromate() -> some View {
        Text("BrO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
    } // perbromate without parentheses

    func perbromatePar() -> some View {
        Text("(BrO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // perbromate with parentheses

    // MARK: - Thiosulfate functions
    func thiosulfate() -> some View {
        Text("S")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text("O")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
    } // thiosulfate without parentheses

    func thiosulfatePar() -> some View {
        Text("(S")
            .font(.title)
        +
        Text("2")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text("O")
            .font(.title)
        +
        Text("3")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // thiosulfate with parentheses

    // MARK: - Perchlorate functions
    func perchlorate() -> some View {
        Text("ClO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
    } // perchlorate without parentheses

    func perchloratePar() -> some View {
        Text("(ClO")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text(")")
            .font(.title)
    } // perchlorate with parentheses

    // MARK: - Tartrate functions
    func tartrate() -> some View {
        Text("C")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text("H")
            .font(.title)
        +
        Text("4")
            .font(.title2)
            .baselineOffset(-5)
        +
        Text("O")
            .font(.title)
        +
        Text("6")
            .font(.title2)
            .baselineOffset(-5)
    } // tartrate without parentheses

    func tartratePar() -> some View {
        let carbon = Text("(C").font(.title)
            + Text("4").font(.title2).baselineOffset(-5)
        let hydrogen = Text("H").font(.title)
            + Text("4").font(.title2).baselineOffset(-5)
        let oxygen = Text("O").font(.title)
            + Text("6").font(.title2).baselineOffset(-5)

        return carbon + hydrogen + oxygen + Text(")").font(.title)
    } // tartrate with parentheses
