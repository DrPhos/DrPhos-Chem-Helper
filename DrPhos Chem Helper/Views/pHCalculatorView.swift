//
//  pHValues.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 7/26/25.
//

import SwiftUI

struct pHValues: Identifiable {
    var id = UUID()
    var pHEntered: String = ""
    var pHCalculated: String = ""
    var H3OEntered: String = ""
    var H3OCalculated: String = ""
    var OHEntered: String = ""
    var OHCalculated: String = ""
    var KaEntered: String = ""
    var KaCalculated: String = ""
    var KbEntered: String = ""
    var KbCalculated: String = ""
    var HAEntered: String = ""
    var HACalculated: String = ""
    var AEntered: String = ""
    var ACalculated: String = ""
    var decimalPlaces: Int
}

class pHViewModel: ObservableObject {
    @Published var pHValue: [pHValues] = [
        pHValues(
            pHEntered: "",
            pHCalculated: "",
            H3OEntered: "",
            H3OCalculated: "",
            OHEntered: "",
            OHCalculated: "",
            KaEntered: "",
            KaCalculated: "",
            KbEntered: "",
            KbCalculated: "",
            HAEntered: "",
            HACalculated: "",
            AEntered: "",
            ACalculated: "",
            decimalPlaces: 2
        )
    ]
    
    @Published var message: String = ""
    @Published var calculationComplete: Bool = false
    @Published var solutionType: String = ""
    @Published var isCollapsed: Bool = true
    @Published var weakCalculation: Bool = false
    
    
    func printValues() {
        for value in pHValue {
            print("Entered pH: \(value.pHEntered)")
            print("Calc pH: \(value.pHCalculated)")
            print("Entered H3O: \(value.H3OEntered)")
            print("Calc H3O: \(value.H3OCalculated)")
            print("Entered OH: \(value.OHEntered)")
            print("Calc. OH: \(value.OHCalculated)")
            print("Entered Ka: \(value.KaEntered)")
            print("Entered Kb: \(value.KbEntered)")
        }
    }
    
    func clearValues() {
        message = ""
        calculationComplete = false
        isCollapsed = true
        weakCalculation = false
        
        for index in pHValue.indices {
            pHValue[index] = pHValues(decimalPlaces: 2)
        }
        
    }
    
    func calculate() {
        let pHEntered = !pHValue[0].pHEntered.isEmpty
        let H3OEntered = !pHValue[0].H3OEntered.isEmpty
        let OHEntered = !pHValue[0].OHEntered.isEmpty
        
        calculationComplete = true
        
        let enteredCount = [pHEntered, H3OEntered, OHEntered].filter { $0 }.count
        
        if enteredCount > 1 {
            message = "enter only one variable"
        } else if enteredCount == 0 {
            message = "enter a variable"
        } else {
            if pHEntered {
                calculateFrompH()
            } else if H3OEntered {
                calculateFromH3O()
            } else if OHEntered {
                calculateFromOH()
            }
            solution()
            message = "values calculated successfully"
        }
    }
    
    func calculateWeak() {
        
        calculationComplete = true
        
        if !pHValue[0].KaEntered.isEmpty && !pHValue[0].HAEntered.isEmpty {
            let Ka = Double(pHValue[0].KaEntered)
            let H3O = Double(pHValue[0].HAEntered)
            
            let step1 = pow(Ka!, 2)
            let step2 = 4 * Ka! * H3O!
            let step3 = step1 + step2
            let step4 = sqrt(step3)
            let step5 = -Ka! + step4
            let step6 = step5 / 2
            
            let tempHA = step6
            let pHCalculated = -log10(tempHA)
            
            
            let decimals = pHValue[0].decimalPlaces
            
            pHValue[0].pHCalculated = pHCalculated < 0.01 ? pHCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", pHCalculated)
            
            let H3OCalculated = pow(10, -pHCalculated)
            let OHCalculated = 1e-14 / H3OCalculated
            
            pHValue[0].H3OCalculated = H3OCalculated < 0.01 ? H3OCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", H3OCalculated)
            pHValue[0].OHCalculated = OHCalculated < 0.01 ? OHCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", OHCalculated)
               
        } // Ka and [HA]
        if !pHValue[0].KbEntered.isEmpty && !pHValue[0].AEntered.isEmpty {
            let Kb = Double(pHValue[0].KbEntered)
            let OH = Double(pHValue[0].AEntered)
            
            let step1 = pow(Kb!, 2)
            let step2 = 4 * Kb! * OH!
            let step3 = step1 + step2
            let step4 = sqrt(step3)
            let step5 = -Kb! + step4
            let step6 = step5 / 2
            
            let tempOH = step6
            let tempHA = 1e-14 / tempOH
            let pHCalculated = -log10(tempHA)
            
            
            let decimals = pHValue[0].decimalPlaces
            
            pHValue[0].pHCalculated = pHCalculated < 0.01 ? pHCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", pHCalculated)
            
            let H3OCalculated = pow(10, -pHCalculated)
            let OHCalculated = 1e-14 / H3OCalculated
            
            pHValue[0].H3OCalculated = H3OCalculated < 0.01 ? H3OCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", H3OCalculated)
            pHValue[0].OHCalculated = OHCalculated < 0.01 ? OHCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", OHCalculated)
               
        } // Kb and [A-]
        if !pHValue[0].KaEntered.isEmpty && !pHValue[0].AEntered.isEmpty {
            let Ka = Double(pHValue[0].KaEntered)
            let Kb = 1e-14 / Ka!
            let OH = Double(pHValue[0].AEntered)
            
            let step1 = pow(Kb, 2)
            let step2 = 4 * Kb * OH!
            let step3 = step1 + step2
            let step4 = sqrt(step3)
            let step5 = -Kb + step4
            let step6 = step5 / 2
            
            let tempOH = step6
            let tempHA = 1e-14 / tempOH
            let pHCalculated = -log10(tempHA)
            
            let decimals = pHValue[0].decimalPlaces
            
            pHValue[0].pHCalculated = pHCalculated < 0.01 ? pHCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", pHCalculated)
            
            let H3OCalculated = pow(10, -pHCalculated)
            let OHCalculated = 1e-14 / H3OCalculated
            
            pHValue[0].H3OCalculated = H3OCalculated < 0.01 ? H3OCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", H3OCalculated)
            pHValue[0].OHCalculated = OHCalculated < 0.01 ? OHCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", OHCalculated)
               
        } // Ka and [A-]
        if !pHValue[0].KbEntered.isEmpty && !pHValue[0].HAEntered.isEmpty {
            let Kb = Double(pHValue[0].KbEntered)
            let Ka = 1e-14 / Kb!
            let HA = Double(pHValue[0].HAEntered)
            
            let step1 = pow(Ka, 2)
            let step2 = 4 * Ka * HA!
            let step3 = step1 + step2
            let step4 = sqrt(step3)
            let step5 = -Ka + step4
            let step6 = step5 / 2
            
            let tempH3O = step6
            let pHCalculated = -log10(tempH3O)
            
            
            let decimals = pHValue[0].decimalPlaces
            
            pHValue[0].pHCalculated = pHCalculated < 0.01 ? pHCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", pHCalculated)
            
            let H3OCalculated = pow(10, -pHCalculated)
            let OHCalculated = 1e-14 / H3OCalculated
            
            pHValue[0].H3OCalculated = H3OCalculated < 0.01 ? H3OCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", H3OCalculated)
            pHValue[0].OHCalculated = OHCalculated < 0.01 ? OHCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", OHCalculated)
               
        } // Kb and [A-]
        
        if !pHValue[0].pHEntered.isEmpty && !pHValue[0].HAEntered.isEmpty {
            let pH = Double(pHValue[0].pHEntered)
            let HA = Double(pHValue[0].HAEntered)
            
            let H3O = pow(10, -pH!)
            let Ka = pow(H3O, 2) / HA!
            
            let decimals = pHValue[0].decimalPlaces
            
            pHValue[0].KaCalculated = Ka < 0.01 ? Ka.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", Ka)
            
            let H3OCalculated = H3O
            let OHCalculated = 1e-14 / H3OCalculated
            
            pHValue[0].H3OCalculated = H3OCalculated < 0.01 ? H3OCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", H3OCalculated)
            pHValue[0].OHCalculated = OHCalculated < 0.01 ? OHCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", OHCalculated)
        } // pH and [HA] calculate Ka
        
        if !pHValue[0].pHEntered.isEmpty && !pHValue[0].AEntered.isEmpty {
            let pH = Double(pHValue[0].pHEntered)
            let A = Double(pHValue[0].AEntered)
            
            let H3O = pow(10, -pH!)
            let OH = 1e-14 / H3O
            let Kb = pow(OH, 2) / A!
            
            let decimals = pHValue[0].decimalPlaces
            
            pHValue[0].KbCalculated = Kb < 0.01 ? Kb.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", Kb)
            
            let H3OCalculated = H3O
            let OHCalculated = 1e-14 / H3OCalculated
            
            pHValue[0].H3OCalculated = H3OCalculated < 0.01 ? H3OCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", H3OCalculated)
            pHValue[0].OHCalculated = OHCalculated < 0.01 ? OHCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", OHCalculated)
        } // pH and [A] calculate Kb
        
        solution()
        message = "values calculated successfully"
        
    }
    
    func calculateFrompH() {
        if let pH = Double(pHValue[0].pHEntered), let result = PHCalculator.from(pH: pH) {
            let H3OCalculated = result.hydronium
            let OHCalculated = result.hydroxide
            
            let decimals = pHValue[0].decimalPlaces
            
            pHValue[0].H3OCalculated = H3OCalculated < 0.01 ? H3OCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", H3OCalculated)
            pHValue[0].OHCalculated = OHCalculated < 0.01 ? OHCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", OHCalculated)
            
            print("Calculating from pH")
            print("H3OCalculated: \(H3OCalculated)")
            print("OHCalculated: \(OHCalculated)")
        } else {
            message = "Error: Invalid pH value entered."
        }
    }
    
    func calculateFromH3O() {
        if let H3O = Double(pHValue[0].H3OEntered), let result = PHCalculator.fromHydronium(H3O) {
            let pHCalculated = result.pH
            let OHCalculated = result.hydroxide
            
            let decimals = pHValue[0].decimalPlaces
            
            pHValue[0].pHCalculated = pHCalculated < 0.01 ? pHCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", pHCalculated)
            pHValue[0].OHCalculated = OHCalculated < 0.01 ? OHCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", OHCalculated)
            
            print("Calculating from H3O⁺")
            print("pHCalculated: \(pHCalculated)")
            print("OHCalculated: \(OHCalculated)")
        } else {
            message = "Error: Invalid H3O⁺ value entered."
        }
    }
    
    func calculateFromOH() {
        if let OH = Double(pHValue[0].OHEntered), let result = PHCalculator.fromHydroxide(OH) {
            let H3OCalculated = result.hydronium
            let pHCalculated = result.pH
            
            let decimals = pHValue[0].decimalPlaces
            
            pHValue[0].H3OCalculated = H3OCalculated < 0.01 ? H3OCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", H3OCalculated)
            pHValue[0].pHCalculated = pHCalculated < 0.01 ? pHCalculated.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", pHCalculated)
            
            print("Calculating from OH⁻")
            print("H3OCalculated: \(H3OCalculated)")
            print("pHCalculated: \(pHCalculated)")
        } else {
            message = "Error: Invalid OH⁻ value entered."
        }
    }
    
    func solution() {
        if let pHEntered = Double(pHValue[0].pHEntered), !pHValue[0].pHEntered.isEmpty {
            solutionType = determineSolutionType(pH: pHEntered)
        } else if let pHCalculated = Double(pHValue[0].pHCalculated), !pHValue[0].pHCalculated.isEmpty {
            solutionType = determineSolutionType(pH: pHCalculated)
        }
    }
    
    func determineSolutionType(pH: Double) -> String {
        PHCalculator.solutionType(for: pH)
    }

    func toggleWeakCalculation() {
        withAnimation {
            isCollapsed.toggle()
            weakCalculation = !isCollapsed
        }
    }
    
}

private struct LegacypHCalculatorView: View {
    @StateObject var viewModel = pHViewModel()
    @State private var activeField: Binding<String>?
    @State private var selectedVariable = 0
    @State private var selectedConstant = 0
    @State var calculationComplete: Bool = false
    
    let variables = ["pH", "[H₃O⁺]", "[OH⁻]"]
    let constants = ["Ka", "Kb"]
    
    var solutionColor: Color {
        switch viewModel.solutionType {
        case "acidic":
            return .red
        case "basic":
            return .blue
        case "neutral":
            return .green
        default:
            return .black
        }
    }
    
    enum pHFocusedField {
        case pH
        case h3o
        case oh
        case ka
        case kb
        case ha
        case a
    }

    @FocusState private var focusedField: pHFocusedField?
    
    var body: some View {
        ScrollView {
            VStack {
                Text("pH Calculator")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                HStack {
                    Text("Solution Type:")
                    Text("\(viewModel.solutionType)")
                        .foregroundColor(solutionColor)
                }
                .padding(.bottom, 20)
                
                VStack(alignment: .leading) {
                    
                    HStack {
                        Text("pH:")
                            .fontWeight(.bold)
                            .padding(.bottom, 4)
                        
                        if calculationComplete && !viewModel.pHValue[0].pHCalculated.isEmpty {
                            
                            if viewModel.pHValue[0].pHCalculated.contains("x10^") {
                                ScientificNotationView(number: viewModel.pHValue[0].pHCalculated)
                                    .baselineOffset(3)
                                    .foregroundColor(
                                        viewModel.calculationComplete  && !viewModel.pHValue[0].pHEntered.isEmpty ? .phosblue1 : .phosgreen1
                                    )
                            } else {
                                Text(viewModel.pHValue[0].pHCalculated)
                                    .baselineOffset(3)
                                    .foregroundColor(
                                        viewModel.calculationComplete  && !viewModel.pHValue[0].pHEntered.isEmpty ? .phosblue1 : .phosgreen1
                                    )
                            }
                        } else if calculationComplete && !viewModel.pHValue[0].pHEntered.isEmpty {
                            Text(viewModel.pHValue[0].pHEntered)
                                .baselineOffset(3)
                                .foregroundColor(
                                    viewModel.calculationComplete  && !viewModel.pHValue[0].pHEntered.isEmpty ? .phosblue1 : .phosgreen1
                                )
                        }
                        
                        else {Text("")}
                        
                    } // pH display
                    
                    HStack {
                        Text("[H₃O⁺]:")
                            .fontWeight(.bold)
                            .padding(.bottom, 4)
                        
                        if calculationComplete && !viewModel.pHValue[0].H3OCalculated.isEmpty {
                            if viewModel.pHValue[0].H3OCalculated.contains("x10^") {
                                ScientificNotationView(number: viewModel.pHValue[0].H3OCalculated)
                                    .baselineOffset(1)
                                    .foregroundColor(
                                        viewModel.calculationComplete  && !viewModel.pHValue[0].H3OEntered.isEmpty ? .phosblue1 : .phosgreen1
                                    )
                            } else {
                                Text(viewModel.pHValue[0].H3OCalculated)
                                    .baselineOffset(1)
                                    .foregroundColor(
                                        viewModel.calculationComplete  && !viewModel.pHValue[0].H3OEntered.isEmpty ? .phosblue1 : .phosgreen1
                                    )
                            }
                        } else if calculationComplete && !viewModel.pHValue[0].H3OEntered.isEmpty {
                            let decimals = viewModel.pHValue[0].decimalPlaces
                            if let H3OEntered = Double(viewModel.pHValue[0].H3OEntered) {
                                let formattedH3OEntered = H3OEntered < 0.01 ? H3OEntered.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", H3OEntered)
                                if formattedH3OEntered.contains("x10^") {
                                    ScientificNotationView(number: formattedH3OEntered)
                                        .baselineOffset(1)
                                        .foregroundColor(
                                            viewModel.calculationComplete  && !viewModel.pHValue[0].H3OEntered.isEmpty ? .phosblue1 : .phosgreen1
                                        )
                                } else {
                                    Text(formattedH3OEntered)
                                        .baselineOffset(1)
                                        .foregroundColor(
                                            viewModel.calculationComplete  && !viewModel.pHValue[0].H3OEntered.isEmpty ? .phosblue1 : .phosgreen1
                                        )
                                }
                            } else {
                                Text(viewModel.pHValue[0].H3OEntered)
                                    .baselineOffset(1)
                                    .foregroundColor(
                                        viewModel.calculationComplete  && !viewModel.pHValue[0].H3OEntered.isEmpty ? .phosblue1 : .phosgreen1
                                    )
                            }
                        } else {
                            Text("")
                        }
                    } // H3O display
                    
                    HStack {
                        Text("[OH⁻]:")
                            .fontWeight(.bold)
                            .padding(.bottom, 4)
                        
                        if calculationComplete && !viewModel.pHValue[0].OHCalculated.isEmpty {
                            if viewModel.pHValue[0].OHCalculated.contains("x10^") {
                                ScientificNotationView(number: viewModel.pHValue[0].OHCalculated)
                                    .foregroundColor(
                                        viewModel.calculationComplete  && !viewModel.pHValue[0].OHEntered.isEmpty ? .phosblue1 : .phosgreen1
                                    )
                            } else {
                                Text(viewModel.pHValue[0].OHCalculated)
                                    .foregroundColor(
                                        viewModel.calculationComplete  && !viewModel.pHValue[0].OHEntered.isEmpty ? .phosblue1 : .phosgreen1
                                    )
                            }
                        } else if calculationComplete && !viewModel.pHValue[0].OHEntered.isEmpty {
                            let decimals = viewModel.pHValue[0].decimalPlaces
                            if let OHEntered = Double(viewModel.pHValue[0].OHEntered) {
                                let formattedOHEntered = OHEntered < 0.01 ? OHEntered.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", OHEntered)
                                if formattedOHEntered.contains("x10^") {
                                    ScientificNotationView(number: formattedOHEntered)
                                        .foregroundColor(
                                            viewModel.calculationComplete  && !viewModel.pHValue[0].OHEntered.isEmpty ? .phosblue1 : .phosgreen1
                                        )
                                } else {
                                    Text(formattedOHEntered)
                                        .foregroundColor(
                                            viewModel.calculationComplete  && !viewModel.pHValue[0].OHEntered.isEmpty ? .phosblue1 : .phosgreen1
                                        )
                                }
                            } else {
                                Text(viewModel.pHValue[0].OHEntered)
                                    .foregroundColor(
                                        viewModel.calculationComplete  && !viewModel.pHValue[0].OHEntered.isEmpty ? .phosblue1 : .phosgreen1
                                    )
                            }
                        } else {
                            Text("")
                        }
                    } // OH display
                    
                    if calculationComplete && !viewModel.pHValue[0].KaCalculated.isEmpty {
                        
                        HStack {
                            Text("Kₐ:")
                                .fontWeight(.bold)
                            
                            if calculationComplete && !viewModel.pHValue[0].KaCalculated.isEmpty {
                                if viewModel.pHValue[0].KaCalculated.contains("x10^") {
                                    ScientificNotationView(number: viewModel.pHValue[0].KaCalculated)
                                        .foregroundColor(
                                            viewModel.calculationComplete  && !viewModel.pHValue[0].KaEntered.isEmpty ? .phosblue1 : .phosgreen1
                                        )
                                } else {
                                    Text(viewModel.pHValue[0].KaCalculated)
                                        .foregroundColor(
                                            viewModel.calculationComplete  && !viewModel.pHValue[0].KaEntered.isEmpty ? .phosblue1 : .phosgreen1
                                        )
                                }
                            } else if calculationComplete && !viewModel.pHValue[0].KaEntered.isEmpty {
                                let decimals = viewModel.pHValue[0].decimalPlaces
                                if let OHEntered = Double(viewModel.pHValue[0].KaEntered) {
                                    let formattedOHEntered = OHEntered < 0.01 ? OHEntered.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", OHEntered)
                                    if formattedOHEntered.contains("x10^") {
                                        ScientificNotationView(number: formattedOHEntered)
                                            .foregroundColor(
                                                viewModel.calculationComplete  && !viewModel.pHValue[0].KaEntered.isEmpty ? .phosblue1 : .phosgreen1
                                            )
                                    } else {
                                        Text(formattedOHEntered)
                                            .foregroundColor(
                                                viewModel.calculationComplete  && !viewModel.pHValue[0].KaEntered.isEmpty ? .phosblue1 : .phosgreen1
                                            )
                                    }
                                } else {
                                    Text(viewModel.pHValue[0].KaEntered)
                                        .foregroundColor(
                                            viewModel.calculationComplete  && !viewModel.pHValue[0].KaEntered.isEmpty ? .phosblue1 : .phosgreen1
                                        )
                                }
                            } else {
                                Text("")
                            }
                        } // Ka display
                        
                    }
                    
                    if calculationComplete && !viewModel.pHValue[0].KbCalculated.isEmpty {
                        
                        HStack {
                            HStack(spacing: 1) {
                                Text("K")
                                Text("b").font(.system(size: 10)).baselineOffset(-6)
                                Text(":")
                            }
                                .fontWeight(.bold)
                            
                            if calculationComplete && !viewModel.pHValue[0].KbCalculated.isEmpty {
                                if viewModel.pHValue[0].KbCalculated.contains("x10^") {
                                    ScientificNotationView(number: viewModel.pHValue[0].KbCalculated)
                                        .foregroundColor(
                                            viewModel.calculationComplete  && !viewModel.pHValue[0].KbEntered.isEmpty ? .phosblue1 : .phosgreen1
                                        )
                                } else {
                                    Text(viewModel.pHValue[0].KbCalculated)
                                        .foregroundColor(
                                            viewModel.calculationComplete  && !viewModel.pHValue[0].KbEntered.isEmpty ? .phosblue1 : .phosgreen1
                                        )
                                }
                            } else if calculationComplete && !viewModel.pHValue[0].KbEntered.isEmpty {
                                let decimals = viewModel.pHValue[0].decimalPlaces
                                if let OHEntered = Double(viewModel.pHValue[0].KbEntered) {
                                    let formattedOHEntered = OHEntered < 0.01 ? OHEntered.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", OHEntered)
                                    if formattedOHEntered.contains("x10^") {
                                        ScientificNotationView(number: formattedOHEntered)
                                            .foregroundColor(
                                                viewModel.calculationComplete  && !viewModel.pHValue[0].KbEntered.isEmpty ? .phosblue1 : .phosgreen1
                                            )
                                    } else {
                                        Text(formattedOHEntered)
                                            .foregroundColor(
                                                viewModel.calculationComplete  && !viewModel.pHValue[0].KbEntered.isEmpty ? .phosblue1 : .phosgreen1
                                            )
                                    }
                                } else {
                                    Text(viewModel.pHValue[0].KbEntered)
                                        .foregroundColor(
                                            viewModel.calculationComplete  && !viewModel.pHValue[0].KbEntered.isEmpty ? .phosblue1 : .phosgreen1
                                        )
                                }
                            } else {
                                Text("")
                            }
                        } // Ka display
                        
                    }
                    
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.clear)
                        .shadow(radius: 2)
                        .frame(width: 200, height: 120)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: 200, height: 120)
                )
                
                Text("select and enter the known variable")
                    .padding(.top, 40)
                
                Picker("Select Variable", selection: $selectedVariable) {
                    ForEach(0..<3) { index in
                        Text(self.variables[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                VStack(alignment: .trailing, content: {
                    
                    if selectedVariable == 0 {
                        HStack {
                            Text("pH:")
                            TextField("enter pH", text: Binding(
                                get: {
                                    if viewModel.calculationComplete {
                                        let pHValue = viewModel.pHValue[0].pHEntered.isEmpty ? viewModel.pHValue[0].pHCalculated : viewModel.pHValue[0].pHEntered
                                        return pHValue
                                    } else {
                                        return viewModel.pHValue[0].pHEntered
                                    }
                                },
                                set: {
                                    if let range = $0.range(of: " ") {
                                        viewModel.pHValue[0].pHEntered = String($0[..<range.lowerBound])
                                    } else {
                                        viewModel.pHValue[0].pHEntered = $0
                                    }
                                }
                            ))
                            .keyboardType(.decimalPad)
                            .padding(5)
                            .frame(maxWidth: 220)
                            .frame(minWidth: 220)
                            .accessibilityLabel("pH input field")
                            .multilineTextAlignment(.center)
                            .autocorrectionDisabled(true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.phostext, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .pH)
                            .onChange(of: focusedField) { oldValue, newValue in
                                if newValue == .pH {
                                    print("pH text field is now active")
                                    activeField = Binding(
                                        get: { viewModel.pHValue[0].pHEntered },
                                        set: { viewModel.pHValue[0].pHEntered = $0 }
                                    )
                                }
                            }
                        }
                    } else if selectedVariable == 1 {
                        HStack {
                            Text("[H₃O⁺]:")
                            TextField("enter [H₃O⁺]", text: Binding(
                                get: {
                                    if viewModel.calculationComplete {
                                        let H3OValue = viewModel.pHValue[0].H3OEntered.isEmpty ? viewModel.pHValue[0].H3OCalculated : viewModel.pHValue[0].H3OEntered
                                        return H3OValue
                                    } else {
                                        return viewModel.pHValue[0].H3OEntered
                                    }
                                },
                                set: {
                                    if let range = $0.range(of: " ") {
                                        viewModel.pHValue[0].H3OEntered = String($0[..<range.lowerBound])
                                    } else {
                                        viewModel.pHValue[0].H3OEntered = $0
                                    }
                                }
                            ))
                            .keyboardType(.decimalPad)
                            .padding(5)
                            .frame(maxWidth: 220)
                            .frame(minWidth: 220)
                            .accessibilityLabel("H3O+ input field")
                            .multilineTextAlignment(.center)
                            .autocorrectionDisabled(true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.phostext, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .h3o)
                            .onChange(of: focusedField) { oldValue, newValue in
                                if newValue == .h3o {
                                    print("H3O+ text field is now active")
                                    activeField = Binding(
                                        get: { viewModel.pHValue[0].H3OEntered },
                                        set: { viewModel.pHValue[0].H3OEntered = $0 }
                                    )
                                }
                            }
                        }
                    } else if selectedVariable == 2 {
                        HStack {
                            Text("[OH⁻]:")
                            TextField("enter [OH⁻]", text: Binding(
                                get: {
                                    if viewModel.calculationComplete {
                                        let OHValue = viewModel.pHValue[0].OHEntered.isEmpty ? viewModel.pHValue[0].OHCalculated : viewModel.pHValue[0].OHEntered
                                        return OHValue
                                    } else {
                                        return viewModel.pHValue[0].OHEntered
                                    }
                                },
                                set: {
                                    if let range = $0.range(of: " ") {
                                        viewModel.pHValue[0].OHEntered = String($0[..<range.lowerBound])
                                    } else {
                                        viewModel.pHValue[0].OHEntered = $0
                                    }
                                }
                            ))
                            .keyboardType(.decimalPad)
                            .padding(5)
                            .frame(maxWidth: 220)
                            .frame(minWidth: 220)
                            .accessibilityLabel("OH- input field")
                            .multilineTextAlignment(.center)
                            .autocorrectionDisabled(true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.phostext, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .oh)
                            .onChange(of: focusedField) { oldValue, newValue in
                                if newValue == .oh {
                                    print("OH- text field is now active")
                                    activeField = Binding(
                                        get: { viewModel.pHValue[0].OHEntered },
                                        set: { viewModel.pHValue[0].OHEntered = $0 }
                                    )
                                }
                            
                            }
                        }
                    }
                    
                    HStack {
                        DrPhosDecimalControl(
                            value: Binding(
                                get: { viewModel.pHValue[0].decimalPlaces },
                                set: { viewModel.pHValue[0].decimalPlaces = $0 }
                            ),
                            range: 0...8
                        )
                        .onChange(of: viewModel.pHValue[0].decimalPlaces) { _, _ in
                            viewModel.calculate()
                        }
                        .padding(.trailing, 10)
                        
                        Button(action: {
                            calculationComplete = true
                            if viewModel.isCollapsed  {
                                viewModel.calculate()
                                viewModel.solution()
                                
                            } else if !viewModel.isCollapsed && !viewModel.pHValue[0].pHEntered.isEmpty && !viewModel.pHValue[0].HAEntered.isEmpty || !viewModel.pHValue[0].AEntered.isEmpty {
                                viewModel.calculateWeak()
                                viewModel.solution()
                                
                            } else if !viewModel.isCollapsed && viewModel.pHValue[0].KaEntered.isEmpty && viewModel.pHValue[0].KbEntered.isEmpty {
                                viewModel.calculate()
                                viewModel.solution()
                                
                            } else if !viewModel.isCollapsed {
                                viewModel.calculateWeak()
                                viewModel.solution()
                            }
                            
                            
                        }) {
                            Text("Calculate")
                                .padding(8)
                                .background(Color.phosblue1)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        } // calculate button
                        
                        Button(action: {
                            calculationComplete = false
                            selectedVariable = 0
                            selectedConstant = 0
                            viewModel.clearValues()
                            viewModel.solutionType = ""
                            
                        }) {
                            Text("Clear")
                                .padding(8)
                                .background(Color.phosred1)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    } // decimals, calculate, and clear button
                    
                    if viewModel.calculationComplete || viewModel.weakCalculation && viewModel.calculationComplete {
                        
                        Text(viewModel.message)
                            .foregroundColor(viewModel.message.contains("enter") ? .phosred1 : .phosgreen1)
                            .padding(.top, 5)
                        
                    }
                })
                
                Rectangle()
                    .frame(height: 1)  // Set the height of the divider
                    .foregroundColor(.phostext)  // Set the color of the divider
                    .opacity(0.3)
                    .padding()
                
                VStack {
                    Button(action: viewModel.toggleWeakCalculation) {
                        HStack {
                            Image(systemName: viewModel.isCollapsed ? "chevron.right" : "chevron.up")
                                .rotationEffect(.degrees(viewModel.isCollapsed ? 0 : 180))
                                .foregroundColor(.numbers)
                            Text("Advanced (weak acids or bases)")
                                .font(.title3)
                                .foregroundColor(.numbers)
                            Spacer()
                        }
                    }
                }
                .padding([.leading, .bottom])

                if viewModel.weakCalculation {
                    
                    Text("select constant and enter any variables")
                    
                    Picker("Select Constant", selection: $selectedConstant) {
                        ForEach(0..<2) { index in
                            Text(self.constants[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    // TextField for Ka or Kb based on the selected constant
                    if selectedConstant == 0 {
                        
                        VStack(alignment: .trailing) {
                            HStack {
                                
                                
                                HStack(spacing: 1) {
                                    Text("K")
                                    Text("a").font(.system(size: 10)).baselineOffset(-6)
                                    Text(":")
                                }
                                TextField("enter weak acid constant", text: $viewModel.pHValue[0].KaEntered)
                                    .keyboardType(.decimalPad)
                                    .padding(5)
                                    .frame(maxWidth: 220)
                                    .frame(minWidth: 220)
                                    .accessibilityLabel("pH input field")
                                    .multilineTextAlignment(.center)
                                    .autocorrectionDisabled(true)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.phostext, lineWidth: 1)
                                    )
                                    .focused($focusedField, equals: .ka)
                                    .onChange(of: focusedField) { oldValue, newValue in
                                        if newValue == .ka {
                                            print("Ka text field is now active")
                                            activeField = Binding(
                                                get: { viewModel.pHValue[0].KaEntered },
                                                set: { viewModel.pHValue[0].KaEntered = $0 }
                                            )
                                        }
                                    }
                                
                            }
                            
                            HStack {
                                Text("[HA]: ")
                                
                                TextField("enter weak acid conc.", text: $viewModel.pHValue[0].HAEntered)
                                    .keyboardType(.decimalPad)
                                    .padding(5)
                                    .frame(maxWidth: 220)
                                    .frame(minWidth: 220)
                                    .accessibilityLabel("[HA] input field")
                                    .multilineTextAlignment(.center)
                                    .autocorrectionDisabled(true)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.phostext, lineWidth: 1)
                                    )
                                    .focused($focusedField, equals: .ha)
                                    .onChange(of: focusedField) { oldValue, newValue in
                                        if newValue == .ha {
                                            print("[HA] text field is now active")
                                            activeField = Binding(
                                                get: { viewModel.pHValue[0].HAEntered },
                                                set: { viewModel.pHValue[0].HAEntered = $0 }
                                            )
                                        }
                                    }
                            }
                            HStack {
                                Text("[A⁻]: ")
                                
                                TextField("enter weak acid conc.", text: $viewModel.pHValue[0].AEntered)
                                    .keyboardType(.decimalPad)
                                    .padding(5)
                                    .frame(maxWidth: 220)
                                    .frame(minWidth: 220)
                                    .accessibilityLabel("[A-] input field")
                                    .multilineTextAlignment(.center)
                                    .autocorrectionDisabled(true)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.phostext, lineWidth: 1)
                                    )
                                    .focused($focusedField, equals: .a)
                                    .onChange(of: focusedField) { oldValue, newValue in
                                        if newValue == .a {
                                            print("[A-] text field is now active")
                                            activeField = Binding(
                                                get: { viewModel.pHValue[0].AEntered },
                                                set: { viewModel.pHValue[0].AEntered = $0 }
                                            )
                                        }
                                    }
                            }
                        }
                    }
                    
                    if selectedConstant == 1 {
                        VStack(alignment: .trailing) {
                           
                            HStack {
                                HStack(spacing: 1) {
                                    Text("K")
                                    Text("b").font(.system(size: 10)).baselineOffset(-6)
                                    Text(":")
                                }
                                TextField("enter weak base constant", text: Binding(
                                    get: {
                                        if viewModel.calculationComplete {
                                            let Ka = viewModel.pHValue[0].KbEntered.isEmpty ? viewModel.pHValue[0].KbCalculated : viewModel.pHValue[0].OHEntered
                                            return Ka
                                        } else {
                                            return viewModel.pHValue[0].KbEntered
                                        }
                                    },
                                    set: {
                                        if let range = $0.range(of: " ") {
                                            viewModel.pHValue[0].KbEntered = String($0[..<range.lowerBound])
                                        } else {
                                            viewModel.pHValue[0].KbEntered = $0
                                        }
                                    }
                                ))
                                    .keyboardType(.decimalPad)
                                    .padding(5)
                                    .frame(maxWidth: 220)
                                    .frame(minWidth: 220)
                                    .accessibilityLabel("pH input field")
                                    .multilineTextAlignment(.center)
                                    .autocorrectionDisabled(true)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.phostext, lineWidth: 1)
                                    )
                                    .focused($focusedField, equals: .kb)
                                    .onChange(of: focusedField) { oldValue, newValue in
                                        if newValue == .kb {
                                            print("Kb text field is now active")
                                            activeField = Binding(
                                                get: { viewModel.pHValue[0].KbEntered },
                                                set: { viewModel.pHValue[0].KbEntered = $0 }
                                            )
                                        }
                                    }
                            }
                            HStack {
                                Text("[HA]: ")
                                
                                TextField("enter weak acid conc.", text: $viewModel.pHValue[0].HAEntered)
                                    .keyboardType(.decimalPad)
                                    .padding(5)
                                    .frame(maxWidth: 220)
                                    .frame(minWidth: 220)
                                    .accessibilityLabel("[HA] input field")
                                    .multilineTextAlignment(.center)
                                    .autocorrectionDisabled(true)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.phostext, lineWidth: 1)
                                    )
                            }
                            HStack {
                                Text("[A⁻]: ")
                                
                                TextField("enter weak acid conc.", text: $viewModel.pHValue[0].AEntered)
                                    .keyboardType(.decimalPad)
                                    .padding(5)
                                    .frame(maxWidth: 220)
                                    .frame(minWidth: 220)
                                    .accessibilityLabel("[A-] input field")
                                    .multilineTextAlignment(.center)
                                    .autocorrectionDisabled(true)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.phostext, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                CustomKeyboardToolbar(activeField: $activeField)
            }
        }
    }
}

struct TextFieldWithSubscript: View {
    let placeholder: String
    let subscriptText: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                HStack(spacing: 0) {
                    Text(placeholder)
                    Text(subscriptText).font(.system(size: 12)).baselineOffset(-6)
                }
                .foregroundColor(.gray)
                .padding(.leading, 4)
            }
            TextField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

#Preview {
    pHCalculatorView()
}
