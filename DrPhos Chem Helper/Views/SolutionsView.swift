// Reusable control bar for decimal adjustment and clearing
struct DecimalControlBar: View {
    @Binding var decimalPlaces: Int
    let clearAction: () -> Void
    
    var body: some View {
        HStack {
            Button(action: { if decimalPlaces < 6 { decimalPlaces += 1 } }) {
                Image(systemName: "plus.circle")
                    .foregroundColor(Color.numbers)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("Decimals")
                .foregroundColor(Color.numbers)
                .font(.footnote)
            
            Button(action: { if decimalPlaces > 0 { decimalPlaces -= 1 } }) {
                Image(systemName: "minus.circle")
                    .foregroundColor(Color.numbers)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: clearAction) {
                Text("Clear")
                    .padding(5)
                    .font(.headline)
                    .background(Color.phosred1)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.numbers, lineWidth: 1))
            }
            .padding(.leading, 20)
        }
    }
}
//
//  SolutionsView.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 7/26/25.
//



import SwiftUI

struct AnswerOverlay: View {
    let answer: String
    var body: some View {
        Group {
            if !answer.isEmpty {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green.opacity(0.5))
                Text(answer)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

private struct LegacySolutionsView: View {
    enum Field: Hashable {
        case concentration, top, bottom, c1, v1, c2, v2
    }
    @FocusState private var focusedField: Field?
    
    let concentrations = ["", "M", "%(m/m)","%(m/v)", "%(v/v)"]
    @State var selectedConcentration = 0
    @State var userConcentration: String = ""
    @State var unitConcentration: String = "?"
    @State var unitTop: String = "?"
    @State var unitBottom: String = "?"
    @State var userTop: String = ""
    @State var userBottom: String = ""
    
    @State var calcConcentration: String = ""
    @State var calcTop: String = ""
    @State var calcBottom: String = ""
    
    @State var userC1: String = ""
    @State var userV1: String = ""
    @State var userC2: String = ""
    @State var userV2: String = ""
    
    @State var calcC1: String = ""
    @State var calcV1: String = ""
    @State var calcC2: String = ""
    @State var calcV2: String = ""
    
    @State var decimalPlaces = 2
    
    var body: some View {
        
        ScrollView(.vertical) {
            VStack {
                
                Text("Solution Calculator")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("1) select concentration type\n and enter any two values")
                    .padding(.bottom, 5)
                    .multilineTextAlignment(.center)
                Text("2) unknown value is auto-calculated\nand highlighted green")
                    .multilineTextAlignment(.center)
               
                VStack {
                    
                    HStack {
                        
                        TextField(calcConcentration.isEmpty ? "value" : "", text: $userConcentration)
                            .keyboardType(.decimalPad)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 80)
                            .overlay(AnswerOverlay(answer: calcConcentration))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.numbers, lineWidth: 1))
                            .multilineTextAlignment(.center)
                            .focused($focusedField, equals: .concentration)
                        
                        Picker("Concentration", selection: $selectedConcentration) {
                            ForEach(0 ..< concentrations.count, id: \.self) {
                                Text(self.concentrations[$0])
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 100)
                        .frame(maxHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.numbers, lineWidth: 1))
                        .onChange(of: selectedConcentration) {
                            resetCalculation()
                            updateUnits()
                        }
                        .onChange(of: userConcentration) {
                            resetCalculation()
                            userInput()
                        }
                        .onChange(of: userTop) {
                            resetCalculation()
                            userInput()
                        }
                        .onChange(of: userBottom) {
                            resetCalculation()
                            userInput()
                        }
                        
                        Text("=")
                           
                        VStack {
                            Text("\(unitTop)")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                TextField(calcTop.isEmpty ? "value" : "", text: $userTop)
                                    .keyboardType(.decimalPad)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .overlay(AnswerOverlay(answer: calcTop))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.numbers, lineWidth: 1))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: 80)
                                    .multilineTextAlignment(.center)
                                    .focused($focusedField, equals: .top)
                            }  // top of fraction
                            
                            Divider()
                                .frame(width: 120, height: 1)
                                .overlay(Color.numbers)
                                .padding(.bottom, 4)
                            
                            HStack {
                                TextField(calcBottom.isEmpty ? "value" : "", text: $userBottom)
                                    .keyboardType(.decimalPad)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .overlay(AnswerOverlay(answer: calcBottom))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.numbers, lineWidth: 1))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: 80)
                                    .multilineTextAlignment(.center)
                                    .focused($focusedField, equals: .bottom)
                            }  // bottom of fraction
                            Text("\(unitBottom)")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                        }  // fractional amounts
                    }  // solution picker and text fields for calculation
                } // solution picker and text fields for calculation
                .padding(.top, 20)
                
                DecimalControlBar(decimalPlaces: $decimalPlaces, clearAction: clearAll)
                    .onChange(of: decimalPlaces) {
                        userInput()
                        dilution()
                    }
                    .padding(.top, 20)
                
                Divider()
                    .overlay(Color.gray)
                    .padding(20)
                
                Text("Dilution Calculator")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                
                Text("1) enter any three of four values")
                     .padding(.bottom, 10)
                
                Text("2) unknown value is auto-calculated\nand highlighted green")
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)
                
                HStack {
                    TextField(calcC1.isEmpty ? "C1" : "", text: $userC1)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .overlay(AnswerOverlay(answer: calcC1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.numbers, lineWidth: 1))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 75)
                        .multilineTextAlignment(.center)
                        .focused($focusedField, equals: .c1)
                        .onChange(of: userC1) {
                            dilution()
                        }
                    
                    Text("×")
                    
                    TextField(calcV1.isEmpty ? "V1" : "", text: $userV1)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .overlay(AnswerOverlay(answer: calcV1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.numbers, lineWidth: 1))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 75)
                        .multilineTextAlignment(.center)
                        .focused($focusedField, equals: .v1)
                        .onChange(of: userV1) {
                            dilution()
                        }
                    
                    Text("=")
                    
                    TextField(calcC2.isEmpty ? "C2" : "", text: $userC2)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .overlay(AnswerOverlay(answer: calcC2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.numbers, lineWidth: 1))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 75)
                        .multilineTextAlignment(.center)
                        .focused($focusedField, equals: .c2)
                        .onChange(of: userC2) {
                            dilution()
                        }
                    
                    Text("×")
                    
                    TextField(calcV2.isEmpty ? "V2" : "", text: $userV2)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(AnswerOverlay(answer: calcV2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.numbers, lineWidth: 1))
                        .frame(maxWidth: 75)
                        .multilineTextAlignment(.center)
                        .focused($focusedField, equals: .v2)
                        .onChange(of: userV2) {
                            dilution()
                        }
                } // dilution equation
                
                DecimalControlBar(decimalPlaces: $decimalPlaces, clearAction: clearAll)
                    .onChange(of: decimalPlaces) {
                        userInput()
                        dilution()
                    }
                    .padding(.top, 20)
            }  // primary vertical stack
            //            .padding(.top, -50)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    CustomKeyboardToolbar(activeField: .constant(
                        Binding(
                            get: {
                                switch focusedField {
                                case .concentration: return userConcentration
                                case .top: return userTop
                                case .bottom: return userBottom
                                case .c1: return userC1
                                case .v1: return userV1
                                case .c2: return userC2
                                case .v2: return userV2
                                case .none: return ""
                                }
                            },
                            set: { newValue in
                                switch focusedField {
                                case .concentration: userConcentration = newValue
                                case .top: userTop = newValue
                                case .bottom: userBottom = newValue
                                case .c1: userC1 = newValue
                                case .v1: userV1 = newValue
                                case .c2: userC2 = newValue
                                case .v2: userV2 = newValue
                                case .none: break
                                }
                            }
                        )
                    ))
                }
            }
        } // scroll view
    }
    
    func clearAll() {
        selectedConcentration = 0
        unitTop = "?"
        unitBottom = "?"
        userTop = ""
        userBottom = ""
        userConcentration = ""
        calcTop = ""
        calcBottom = ""
        calcConcentration = ""
        userC1 = ""
        userV1 = ""
        userC2 = ""
        userV2 = ""
        calcC1 = ""
        calcV1 = ""
        calcC2 = ""
        calcV2 = ""
    }
   
    func userInput() {
        switch selectedConcentration {
        case 1:
            calculateMolarity()
        case 2:
            calculateMassPercent()
        case 3:
            calculateVolumePercent()
        case 4:
            calculateVolumeVolumePercent()
        default:
            clearAll()
        }
    }
    
    func calculateMolarity() {
        if let molarity = Double(userConcentration), let moles = Double(userTop) {
            let liters = moles / molarity
            calcBottom = String(format: "%.\(decimalPlaces)f", liters)
        } else if let molarity = Double(userConcentration), let liters = Double(userBottom) {
            let moles = liters * molarity
            calcTop = String(format: "%.\(decimalPlaces)f", moles)
        } else if let moles = Double(userTop), let liters = Double(userBottom) {
            let molarity = moles / liters
            calcConcentration = String(format: "%.\(decimalPlaces)f", molarity)
        }
    }
    
    func calculateMassPercent() {
        if let mm = Double(userConcentration), let gsolute = Double(userTop) {
            let gsolution = gsolute / mm
            calcBottom = String(format: "%.\(decimalPlaces)f", gsolution)
        } else if let mm = Double(userConcentration), let gsolution = Double(userBottom) {
            let gsolute = gsolution * mm
            calcTop = String(format: "%.\(decimalPlaces)f", gsolute)
        } else if let gsolute = Double(userTop), let gsolution = Double(userBottom) {
            let mm = gsolute / gsolution * 100
            calcConcentration = String(format: "%.\(decimalPlaces)f", mm)
        }
    }
    
    func calculateVolumePercent() {
        if let mv = Double(userConcentration), let gsolute = Double(userTop) {
            let mLsolution = gsolute / mv
            calcBottom = String(format: "%.\(decimalPlaces)f", mLsolution)
        } else if let mv = Double(userConcentration), let mLsolution = Double(userBottom) {
            let gsolute = mLsolution * mv
            calcTop = String(format: "%.\(decimalPlaces)f", gsolute)
        } else if let gsolute = Double(userTop), let mLsolution = Double(userBottom) {
            let mv = gsolute / mLsolution * 100
            calcConcentration = String(format: "%.\(decimalPlaces)f", mv)
        }
    }
    
    func calculateVolumeVolumePercent() {
        if let vv = Double(userConcentration), let mLsolute = Double(userTop) {
            let mLsolution = mLsolute / vv
            calcBottom = String(format: "%.\(decimalPlaces)f", mLsolution)
        } else if let vv = Double(userConcentration), let mLsolution = Double(userBottom) {
            let mLsolute = mLsolution * vv
            calcTop = String(format: "%.\(decimalPlaces)f", mLsolute)
        } else if let mLsolute = Double(userTop), let mLsolution = Double(userBottom) {
            let vv = mLsolute / mLsolution * 100
            calcConcentration = String(format: "%.\(decimalPlaces)f", vv)
        }
    }
    
    func dilution() {
        if let c1 = Double(userC1), let v1 = Double(userV1), let c2 = Double(userC2) {
            let v2 = c1 * v1 / c2
            calcV2 = String(format: "%.\(decimalPlaces)f", v2)
        } else if let c1 = Double(userC1), let v1 = Double(userV1), let v2 = Double(userV2) {
            let c2 = c1 * v1 / v2
            calcC2 = String(format: "%.\(decimalPlaces)f", c2)
        } else if let c1 = Double(userC1), let c2 = Double(userC2), let v2 = Double(userV2) {
            let v1 = c2 * v2 / c1
            calcV1 = String(format: "%.\(decimalPlaces)f", v1)
        } else if let v1 = Double(userV1), let c2 = Double(userC2), let v2 = Double(userV2) {
            let c1 = c2 * v2 / v1
            calcC1 = String(format: "%.\(decimalPlaces)f", c1)
        }
    }
    
    func resetCalculation() {
        calcTop = ""
        calcBottom = ""
        calcConcentration = ""
    }
    
    func updateUnits() {
        switch selectedConcentration {
        case 1:
            unitTop = "moles solute"
            unitBottom = "L solution"
        case 2:
            unitTop = "g solute"
            unitBottom = "g solution"
        case 3:
            unitTop = "g solute"
            unitBottom = "mL solution"
        case 4:
            unitTop = "mL solute"
            unitBottom = "mL solution"
        default:
            unitTop = "?"
            unitBottom = "?"
        }
    }
}

#Preview {
    SolutionsView()
}
