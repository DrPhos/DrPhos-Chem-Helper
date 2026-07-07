//
//  KineticsNumbers.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 7/26/25.
//


import SwiftUI

struct KineticsNumbers: Identifiable {
    var id = UUID()
    var rateConstantEntered: String
    var rateConstantCalculated: String
    var initialConcEntered: String
    var initialConcCalculated: String
    var finalConcEntered: String
    var finalConcCalculated: String
    var timeEntered: String
    var timeCalculated: String
    var halfLifeEntered: String
    var halfLifeCalculated: String
    var calculatedkFromHalfLife: String
    var decimalPlaces: Int
}

class KineticsNumbersViewModel: ObservableObject {
    @Published var selectedOrder: String = "First Order"
    @Published var selectedTimeUnit: String = "Seconds"
    @Published var kineticsNumbers: [KineticsNumbers] = [
        KineticsNumbers(
            rateConstantEntered: "",
            rateConstantCalculated: "",
            initialConcEntered: "",
            initialConcCalculated: "",
            finalConcEntered: "",
            finalConcCalculated: "",
            timeEntered: "",
            timeCalculated: "",
            halfLifeEntered: "",
            halfLifeCalculated: "",
            calculatedkFromHalfLife: "",
            decimalPlaces: 2
        )
    ]
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published var calculationComplete: Bool = false
    @Published var calculatekComplete: Bool = false
    
    let orders = ["Zero Order", "First Order", "Second Order"]
    let timeUnits = ["Seconds", "Minutes", "Hours", "Days", "Years"]
    
    let timeUnitAbbreviations: [String: String] = [
        "Seconds": "s",
        "Minutes": "min",
        "Hours": "h",
        "Days": "days",
        "Years": "years"
    ]
    
    let rateConstantUnits: [String: String] = [
        "Zero Order": "[conc] · (timeUnits)⁻¹",
        "First Order": "(timeUnits)⁻¹",
        "Second Order": "[conc]⁻¹ · (timeUnits)⁻¹"
    ]
    
    func calculate() {
        for i in 0..<kineticsNumbers.count {
            var kineticsNumber = kineticsNumbers[i]
            
            if !kineticsNumber.calculatedkFromHalfLife.isEmpty {
                kineticsNumber.rateConstantEntered = kineticsNumber.calculatedkFromHalfLife
            }
            
            printNumbers()
            
            errorMessage = nil

            let enteredValuesCount = [
                            kineticsNumber.rateConstantEntered,
                            kineticsNumber.initialConcEntered,
                            kineticsNumber.finalConcEntered,
                            kineticsNumber.timeEntered
                        ].filter { !$0.isEmpty }.count
            
            if enteredValuesCount < 3 {
                            errorMessage = "you must enter at least three variables"
                            return
                        }

                        if let initialConc = Double(kineticsNumber.initialConcEntered), let finalConc = Double(kineticsNumber.finalConcEntered), finalConc > initialConc {
                            errorMessage = "the final concentration must be\nless than the initial concentration"
                            return
                        }

            let enteredValues = [
                kineticsNumber.rateConstantEntered.isEmpty ? nil : "rateConstant",
                kineticsNumber.initialConcEntered.isEmpty ? nil : "initialConc",
                kineticsNumber.finalConcEntered.isEmpty ? nil : "finalConc",
                kineticsNumber.timeEntered.isEmpty ? nil : "time"
            ].compactMap { $0 }
            
            guard enteredValues.count == 3 else {
                print("exactly 3 values must be entered")
                return
            }

            guard let input = engineInput(for: kineticsNumber, enteredValues: enteredValues) else {
                errorMessage = "Unsupported reaction order or time unit."
                return
            }

            switch KineticsEngine.solve(input) {
            case .success(let result):
                apply(result, to: &kineticsNumber)
            case .failure(let error):
                errorMessage = error.localizedDescription
                return
            }
            
            calculationComplete = true
            
            kineticsNumbers[i] = kineticsNumber
        
        }
        successMessage = "values calculated successfully"
    }

    private func engineInput(for kineticsNumber: KineticsNumbers, enteredValues: [String]) -> KineticsInput? {
        guard let order = ReactionOrder(rawValue: selectedOrder),
              let timeUnit = TimeUnit(rawValue: selectedTimeUnit),
              let unknown = unknown(from: enteredValues) else {
            return nil
        }

        return KineticsInput(
            order: order,
            timeUnit: timeUnit,
            unknown: unknown,
            rateConstant: Double(kineticsNumber.rateConstantEntered),
            initialConcentration: Double(kineticsNumber.initialConcEntered),
            finalConcentration: Double(kineticsNumber.finalConcEntered),
            time: Double(kineticsNumber.timeEntered),
            halfLife: Double(kineticsNumber.halfLifeEntered)
        )
    }

    private func unknown(from enteredValues: [String]) -> KineticsUnknown? {
        let values = Set(enteredValues)
        if !values.contains("time") { return .time }
        if !values.contains("finalConc") { return .finalConcentration }
        if !values.contains("initialConc") { return .initialConcentration }
        if !values.contains("rateConstant") { return .rateConstant }
        return nil
    }

    private func apply(_ result: KineticsResult, to kineticsNumber: inout KineticsNumbers) {
        let formattedValue = format(result.value, decimals: kineticsNumber.decimalPlaces)
        switch result.unknown {
        case .rateConstant:
            kineticsNumber.rateConstantCalculated = formattedValue
        case .time:
            kineticsNumber.timeCalculated = formattedValue
        case .initialConcentration:
            kineticsNumber.initialConcCalculated = formattedValue
        case .finalConcentration:
            kineticsNumber.finalConcCalculated = formattedValue
        case .halfLife:
            kineticsNumber.halfLifeCalculated = formattedValue
        }

        if let halfLife = result.halfLife {
            kineticsNumber.halfLifeCalculated = format(halfLife, decimals: kineticsNumber.decimalPlaces)
        }
    }

    private func format(_ value: Double, decimals: Int) -> String {
        String(format: "%.\(decimals)f", value)
    }
    
    private enum CalculationType {
        case time
        case finalConc
        case initialConc
        case rateConstant
    }
    
    private func performCalculation(for kineticsNumber: inout KineticsNumbers, calculationType: CalculationType) {
        let calculationFunction: (inout KineticsNumbers) -> Void
        
        switch (selectedOrder, calculationType) {
        case ("Zero Order", .time):
            calculationFunction = calculateTimeZeroOrder
        case ("Zero Order", .finalConc):
            calculationFunction = calculateFinalConcentrationZeroOrder
        case ("Zero Order", .initialConc):
            calculationFunction = calculateInitialConcentrationZeroOrder
        case ("Zero Order", .rateConstant):
            calculationFunction = calculateRateConstantZeroOrder
            
        case ("First Order", .time):
            calculationFunction = calculateTimeFirstOrder
        case ("First Order", .finalConc):
            calculationFunction = calculateFinalConcentrationFirstOrder
        case ("First Order", .initialConc):
            calculationFunction = calculateInitialConcentrationFirstOrder
        case ("First Order", .rateConstant):
            calculationFunction = calculateRateConstantFirstOrder
            
        case ("Second Order", .time):
            calculationFunction = calculateTimeSecondOrder
        case ("Second Order", .finalConc):
            calculationFunction = calculateFinalConcentrationSecondOrder
        case ("Second Order", .initialConc):
            calculationFunction = calculateInitialConcentrationSecondOrder
        case ("Second Order", .rateConstant):
            calculationFunction = calculateRateConstantSecondOrder
            
        default:
            return
        }
        
        calculationFunction(&kineticsNumber)
    }
    
    // Zero Order Calculations
    private func calculateTimeZeroOrder(for kineticsNumber: inout KineticsNumbers) {
        
        guard let k = Double(kineticsNumber.rateConstantEntered),
              let A0 = Double(kineticsNumber.initialConcEntered),
              let A = Double(kineticsNumber.finalConcEntered)
        else {
            print("Invalid input values")
            return
        }
        
        let t = (A0 - A) / k
        kineticsNumber.timeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", t)
        
        let tHalf = A0 / (2 * k)
        kineticsNumber.halfLifeCalculated = String(tHalf)
        kineticsNumber.halfLifeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", tHalf)
     
    }
    
    private func calculateFinalConcentrationZeroOrder(for kineticsNumber: inout KineticsNumbers) {
        
        guard let k = Double(kineticsNumber.rateConstantEntered),
              let A0 = Double(kineticsNumber.initialConcEntered),
              let t = Double(kineticsNumber.timeEntered) else {
            print("Invalid input values")
            return
        }
        
        let A = A0 - k * t
        kineticsNumber.finalConcCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", A)
        
        let tHalf = A0 / (2 * k)
        kineticsNumber.halfLifeCalculated = String(tHalf)
        kineticsNumber.halfLifeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", tHalf)
    }
    
    private func calculateInitialConcentrationZeroOrder(for kineticsNumber: inout KineticsNumbers) {
        
        guard let k = Double(kineticsNumber.rateConstantEntered),
              let A = Double(kineticsNumber.finalConcEntered),
              let t = Double(kineticsNumber.timeEntered) else {
            print("Invalid input values")
            return
        }
        
        let A0 = A + k * t
        
        kineticsNumber.initialConcCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", A0)
        
        let tHalf = A0 / (2 * k)
        kineticsNumber.halfLifeCalculated = String(tHalf)
        kineticsNumber.halfLifeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", tHalf)
    }
    
    private func calculateRateConstantZeroOrder(for kineticsNumber: inout KineticsNumbers) {
       
        guard let A0 = Double(kineticsNumber.initialConcEntered),
               let A = Double(kineticsNumber.finalConcEntered),
               let t = Double(kineticsNumber.timeEntered) else {
             print("Invalid input values")
             return
         }
         
        let k = (A0 - A) / t
         kineticsNumber.rateConstantCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", k)
        
        let tHalf = A0 / (2 * k)
        kineticsNumber.halfLifeCalculated = String(tHalf)
        kineticsNumber.halfLifeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", tHalf)
    }
    
    // First Order Calculations
    private func calculateTimeFirstOrder(for kineticsNumber: inout KineticsNumbers) {
        
        guard let k = Double(kineticsNumber.rateConstantEntered),
              let A0 = Double(kineticsNumber.initialConcEntered),
              let A = Double(kineticsNumber.finalConcEntered) else {
            print("Invalid input values")
            return
        }
        
        let t = -log(A / A0) / k
        kineticsNumber.timeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", t)
        
        let tHalf = log(2) / k
        kineticsNumber.halfLifeCalculated = String(tHalf)
        kineticsNumber.halfLifeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", tHalf)
    }

    private func calculateFinalConcentrationFirstOrder(for kineticsNumber: inout KineticsNumbers) {
        
        guard let k = Double(kineticsNumber.rateConstantEntered),
              let A0 = Double(kineticsNumber.initialConcEntered),
              let t = Double(kineticsNumber.timeEntered) else {
            print("Invalid input values")
            return
        }
        
        let A = A0 * exp(-k * t)
        kineticsNumber.finalConcCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", A)
        
        let tHalf = log(2) / k
        kineticsNumber.halfLifeCalculated = String(tHalf)
        kineticsNumber.halfLifeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", tHalf)
    }
    
    private func calculateInitialConcentrationFirstOrder(for kineticsNumber: inout KineticsNumbers) {
        
        guard let k = Double(kineticsNumber.rateConstantEntered),
              let A = Double(kineticsNumber.finalConcEntered),
              let t = Double(kineticsNumber.timeEntered) else {
            print("Invalid input values")
            return
        }
        
        let A0 = A / exp(-k * t)
        kineticsNumber.initialConcCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", A0)
        
        let tHalf = log(2) / k
        kineticsNumber.halfLifeCalculated = String(tHalf)
        kineticsNumber.halfLifeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", tHalf)
    }
    
    private func calculateRateConstantFirstOrder(for kineticsNumber: inout KineticsNumbers) {
        
        guard let A0 = Double(kineticsNumber.initialConcEntered),
               let A = Double(kineticsNumber.finalConcEntered),
               let t = Double(kineticsNumber.timeEntered) else {
             print("Invalid input values")
             return
         }
         
        let k = -log(A / A0) / t
         
        let decimals = kineticsNumber.decimalPlaces
    
        
        kineticsNumber.rateConstantCalculated = k < 0.01 ? k.formattedScientific(decimalPlaces: decimals) : String(format: "%.\(decimals)f", k)
        
        let tHalf = log(2) / k
        kineticsNumber.halfLifeCalculated = String(tHalf)
        kineticsNumber.halfLifeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", tHalf)
    }
    
    // Second Order Calculations
    private func calculateTimeSecondOrder(for kineticsNumber: inout KineticsNumbers) {
        
        guard let k = Double(kineticsNumber.rateConstantEntered),
              let A0 = Double(kineticsNumber.initialConcEntered),
              let A = Double(kineticsNumber.finalConcEntered) else {
            print("Invalid input values")
            return
        }
        
        let t = (1 / A - 1 / A0) / k
        kineticsNumber.timeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", t)
        
        let tHalf = 1 / (k * A0)
        kineticsNumber.halfLifeCalculated = String(tHalf)
        kineticsNumber.halfLifeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", tHalf)
    }
    
    private func calculateFinalConcentrationSecondOrder(for kineticsNumber: inout KineticsNumbers) {
        
        guard let k = Double(kineticsNumber.rateConstantEntered),
              let A0 = Double(kineticsNumber.initialConcEntered),
              let t = Double(kineticsNumber.timeEntered) else {
            print("Invalid input values")
            return
        }
        
        let A = 1 / ((1 / A0) + k * t)
        kineticsNumber.finalConcCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", A)
       
        let tHalf = 1 / (k * A0)
        kineticsNumber.halfLifeCalculated = String(tHalf)
        kineticsNumber.halfLifeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", tHalf)
    }
    
    private func calculateInitialConcentrationSecondOrder(for kineticsNumber: inout KineticsNumbers) {
        
        guard let k = Double(kineticsNumber.rateConstantEntered),
              let A = Double(kineticsNumber.finalConcEntered),
              let t = Double(kineticsNumber.timeEntered) else {
            print("Invalid input values")
            return
        }
        
        let A0 = 1 / ((1 / A) - k * t)
        kineticsNumber.initialConcCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", A0)
        
        let tHalf = 1 / (k * A0)
        kineticsNumber.halfLifeCalculated = String(tHalf)
        kineticsNumber.halfLifeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", tHalf)
    }
    
    private func calculateRateConstantSecondOrder(for kineticsNumber: inout KineticsNumbers) {
        
        guard let A0 = Double(kineticsNumber.initialConcEntered),
              let A = Double(kineticsNumber.finalConcEntered),
              let t = Double(kineticsNumber.timeEntered) else {
            print("Invalid input values")
            return
        }
        
        let k = (1 / A - 1 / A0) / t
        kineticsNumber.rateConstantCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", k)
        
        let tHalf = 1 / (k * A0)
        kineticsNumber.halfLifeCalculated = String(tHalf)
        kineticsNumber.halfLifeCalculated = String(format: "%.\(kineticsNumber.decimalPlaces)f", tHalf)
    }
    
    func calculateKFromHalfLife(for kineticsNumber: inout KineticsNumbers) {

        calculatekComplete = true

        guard let order = ReactionOrder(rawValue: selectedOrder),
              let timeUnit = TimeUnit(rawValue: selectedTimeUnit) else {
            errorMessage = "Unsupported reaction order or time unit."
            return
        }

        let input = KineticsInput(
            order: order,
            timeUnit: timeUnit,
            unknown: .halfLife,
            rateConstant: nil,
            initialConcentration: Double(kineticsNumber.initialConcEntered),
            finalConcentration: nil,
            time: nil,
            halfLife: Double(kineticsNumber.halfLifeEntered)
        )

        do {
            let k = try KineticsEngine.rateConstantFromHalfLife(input)
            kineticsNumber.calculatedkFromHalfLife = format(k, decimals: kineticsNumber.decimalPlaces)
            kineticsNumber.rateConstantCalculated = kineticsNumber.calculatedkFromHalfLife
            errorMessage = nil
        } catch let error as KineticsCalculationError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Unable to calculate rate constant from half-life."
        }
    }

    func clearAllNumbers() {
        kineticsNumbers.removeAll()
        calculationComplete = false
        calculatekComplete = false
        errorMessage = nil
        successMessage = nil
        kineticsNumbers.append(KineticsNumbers(
            rateConstantEntered: "",
            rateConstantCalculated: "",
            initialConcEntered: "",
            initialConcCalculated: "",
            finalConcEntered: "",
            finalConcCalculated: "",
            timeEntered: "",
            timeCalculated: "",
            halfLifeEntered: "",
            halfLifeCalculated: "",
            calculatedkFromHalfLife: "",
            decimalPlaces: 2
        ))
        print("All numbers cleared")
        
    }

    private func printNumbers() {
        for kineticsNumber in kineticsNumbers {
            print("Entered Rate Constant: \(kineticsNumber.rateConstantEntered), Calculated Rate Constant: \(kineticsNumber.rateConstantCalculated), Entered Initial Conc.: \(kineticsNumber.initialConcEntered), Calculated Initial Conc.: \(kineticsNumber.initialConcCalculated), Entered Final Conc.: \(kineticsNumber.finalConcEntered), Calculated Final Conc.: \(kineticsNumber.finalConcCalculated), Entered Time: \(kineticsNumber.timeEntered), Calculated Time: \(kineticsNumber.timeCalculated), Entered Half-Life: \(kineticsNumber.halfLifeEntered), Calculated Half-Life: \(kineticsNumber.halfLifeCalculated), Decimal Places: \(kineticsNumber.decimalPlaces), Selected Order: \(selectedOrder)")
        }
    }
}

private struct LegacyKineticsView: View {
    @StateObject private var viewModel = KineticsNumbersViewModel()
    @State var calculationComplete: Bool?
    @State var calculatekComplete: Bool?
    @State private var numberValue: String = ""
    @State private var activeField: Binding<String>? {
        didSet {
            if activeField != nil {
                print("Active field changed: \(String(describing: activeField))")
            } else {
                print("No active field")
            }
        }
    }
    
    enum FocusedField {
        case rateConstant
        case initialConc
        case finalConc
        case time
        case halfLife
    }

    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        
        ScrollView(.vertical){
            VStack {
                Text("Kinetics")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("select reaction order and units of time")
                    .font(.headline)
                    .padding(.top, 1)
                
                HStack {
                    Picker("Select Order", selection: $viewModel.selectedOrder) {
                        ForEach(viewModel.orders, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: 150)
                    .frame(height: 100)
                    .padding()
                    .border(Color.gray)
                    
                    Picker("Select Time Unit", selection: $viewModel.selectedTimeUnit) {
                        ForEach(viewModel.timeUnits, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: 150)
                    .frame(height: 100)
                    .padding()
                    .border(Color.gray)
                    
                } // picker wheels
                
                HStack {
                    Spacer()
                    
                    Text("enter any 3 variables")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    Spacer()
                    
                } // enter variables text
                
            
                    VStack(alignment: .trailing, content: {
                        
                        HStack {
                            
                            Text("Rate Constant: ")
                            
                            TextField("enter rate constant", text: Binding(
                                get: {
                                    let unit = viewModel.rateConstantUnits[viewModel.selectedOrder]?.replacingOccurrences(of: "(timeUnits)", with: viewModel.timeUnitAbbreviations[viewModel.selectedTimeUnit] ?? "") ?? ""
                                    if viewModel.calculationComplete || viewModel.calculatekComplete {
                                        let rateConstant = viewModel.kineticsNumbers[0].rateConstantEntered.isEmpty ? viewModel.kineticsNumbers[0].rateConstantCalculated : viewModel.kineticsNumbers[0].rateConstantEntered
                                        return rateConstant.contains(unit) ? rateConstant : "\(rateConstant) \(unit)"
                                    } else {
                                        return viewModel.kineticsNumbers[0].rateConstantEntered
                                    }
                                },
                                set: {
                                    if let range = $0.range(of: " ") {
                                        viewModel.kineticsNumbers[0].rateConstantEntered = String($0[..<range.lowerBound])
                                    } else {
                                        viewModel.kineticsNumbers[0].rateConstantEntered = $0
                                    }
                                }
                            ))
                            .foregroundColor(
                                viewModel.calculationComplete  && !viewModel.calculatekComplete && !viewModel.kineticsNumbers[0].rateConstantEntered.isEmpty ? .phosblue1 :
                                    viewModel.calculationComplete  && !viewModel.kineticsNumbers[0].rateConstantCalculated.isEmpty || !viewModel.kineticsNumbers[0].calculatedkFromHalfLife.isEmpty ? .phosgreen1 :
                                        .primary
                            )
                            .keyboardType(.decimalPad)
                            .padding(5)
                            .frame(maxWidth: 220)
                            .frame(minWidth: 220)
                            .accessibilityLabel("rate constant input field")
                            .multilineTextAlignment(.center)
                            .autocorrectionDisabled(true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.phostext, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .rateConstant)
                            .onChange(of: focusedField) { oldValue, newValue in
                                if newValue == .rateConstant {
                                    print("Rate Constant text field is now active")
                                    activeField = Binding(
                                        get: { viewModel.kineticsNumbers[0].rateConstantEntered },
                                        set: { viewModel.kineticsNumbers[0].rateConstantEntered = $0 }
                                    )
                                }
                            }
                            
                        } // rate constant text field
                        
                        HStack {
                            
                            Text("Intial Conc.:")
                            
                            TextField("enter initial concentration", text: Binding(
                                get: {
                                    let unit = "[conc.]"
                                    if viewModel.calculationComplete {
                                        let initialConc = viewModel.kineticsNumbers[0].initialConcEntered.isEmpty ? viewModel.kineticsNumbers[0].initialConcCalculated : viewModel.kineticsNumbers[0].initialConcEntered
                                        return initialConc.contains(unit) ? initialConc : "\(initialConc) \(unit)"
                                    } else {
                                        return viewModel.kineticsNumbers[0].initialConcEntered
                                    }
                                },
                                set: {
                                    if let range = $0.range(of: " ") {
                                        viewModel.kineticsNumbers[0].initialConcEntered = String($0[..<range.lowerBound])
                                    } else {
                                        viewModel.kineticsNumbers[0].initialConcEntered = $0
                                    }
                                }
                            ))
                            .foregroundColor(
                                viewModel.calculationComplete && !viewModel.kineticsNumbers[0].initialConcEntered.isEmpty ? .phosblue1 :
                                    viewModel.calculationComplete && !viewModel.kineticsNumbers[0].initialConcCalculated.isEmpty ? .phosgreen1 :
                                        .primary
                            )
                            .keyboardType(.decimalPad)
                            .padding(5)
                            .frame(maxWidth: 220)
                            .frame(minWidth: 220)
                            .accessibilityLabel("initial concentration input field")
                            .multilineTextAlignment(.center)
                            .autocorrectionDisabled(true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.phostext, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .initialConc)
                            .onChange(of: focusedField) { oldValue, newValue in
                                if newValue == .initialConc {
                                    print("Initial Concentration text field is now active")
                                    activeField = Binding(
                                        get: { viewModel.kineticsNumbers[0].initialConcEntered },
                                        set: { viewModel.kineticsNumbers[0].initialConcEntered = $0 }
                                    )
                                }
                            }
                            
                        } // initial concentration text field
                        
                        HStack {
                            Text("Final Conc.:")
                            TextField("enter final concentration", text: Binding(
                                get: {
                                    let unit = "[conc.]"
                                    if viewModel.calculationComplete {
                                        let finalConc = viewModel.kineticsNumbers[0].finalConcEntered.isEmpty ? viewModel.kineticsNumbers[0].finalConcCalculated : viewModel.kineticsNumbers[0].finalConcEntered
                                        return finalConc.contains(unit) ? finalConc : "\(finalConc) \(unit)"
                                    } else {
                                        return viewModel.kineticsNumbers[0].finalConcEntered
                                    }
                                },
                                set: {
                                    if let range = $0.range(of: " ") {
                                        viewModel.kineticsNumbers[0].finalConcEntered = String($0[..<range.lowerBound])
                                    } else {
                                        viewModel.kineticsNumbers[0].finalConcEntered = $0
                                    }
                                }
                            ))
                            .foregroundColor(
                                viewModel.calculationComplete && !viewModel.kineticsNumbers[0].finalConcEntered.isEmpty ? .phosblue1 :
                                    viewModel.calculationComplete && !viewModel.kineticsNumbers[0].finalConcCalculated.isEmpty ? .phosgreen1 :
                                        .primary
                            )
                            .keyboardType(.decimalPad)
                            .padding(5)
                            .frame(maxWidth: 220)
                            .frame(minWidth: 220)
                            .accessibilityLabel("final concentration input field")
                            .multilineTextAlignment(.center)
                            .autocorrectionDisabled(true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.phostext, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .finalConc)
                            .onChange(of: focusedField) { oldValue, newValue in
                                if newValue == .finalConc {
                                    print("Final Concentration text field is now active")
                                    activeField = Binding(
                                        get: { viewModel.kineticsNumbers[0].finalConcEntered },
                                        set: { viewModel.kineticsNumbers[0].finalConcEntered = $0 }
                                    )
                                }
                            }
                            
                        } // final concentration text field
                        
                        HStack {
                            Text("Time:")
                            TextField("enter time", text: Binding(
                                get: {
                                    let unit = viewModel.timeUnitAbbreviations[viewModel.selectedTimeUnit] ?? ""
                                    if viewModel.calculationComplete {
                                        let time = viewModel.kineticsNumbers[0].timeEntered.isEmpty ? viewModel.kineticsNumbers[0].timeCalculated : viewModel.kineticsNumbers[0].timeEntered
                                        return time.contains(unit) ? time : "\(time) \(unit)"
                                    } else {
                                        return viewModel.kineticsNumbers[0].timeEntered
                                    }
                                },
                                set: {
                                    if let range = $0.range(of: " ") {
                                        viewModel.kineticsNumbers[0].timeEntered = String($0[..<range.lowerBound])
                                    } else {
                                        viewModel.kineticsNumbers[0].timeEntered = $0
                                    }
                                }
                            ))
                            .foregroundColor(
                                viewModel.calculationComplete && !viewModel.kineticsNumbers[0].timeEntered.isEmpty ? .phosblue1 :
                                    viewModel.calculationComplete && !viewModel.kineticsNumbers[0].timeCalculated.isEmpty ? .phosgreen1 :
                                        .primary
                            )
                            .keyboardType(.decimalPad)
                            .padding(5)
                            .frame(maxWidth: 220)
                            .frame(minWidth: 220)
                            .accessibilityLabel("time input field")
                            .multilineTextAlignment(.center)
                            .autocorrectionDisabled(true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.phostext, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .time)
                            .onChange(of: focusedField) { oldValue, newValue in
                                if newValue == .time {
                                    print("Time text field is now active")
                                    activeField = Binding(
                                        get: { viewModel.kineticsNumbers[0].timeEntered },
                                        set: { viewModel.kineticsNumbers[0].timeEntered = $0 }
                                    )
                                }
                            }
                            
                        } // time text field
                        
                        HStack {

                            Button(action: {
                                if viewModel.kineticsNumbers[0].decimalPlaces < 6 {
                                    viewModel.kineticsNumbers[0].decimalPlaces += 1
                                    viewModel.calculate()
                                }
                            }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(Color.phostext)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text("Decimals")
                                .foregroundColor(Color.phostext)
                                .font(.footnote)
                            
                            Button(action: {
                                if viewModel.kineticsNumbers[0].decimalPlaces > 0 {
                                    viewModel.kineticsNumbers[0].decimalPlaces -= 1
                                    viewModel.calculate()
                                }
                            }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(Color.phostext)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.trailing, 10)
                            
                         
                        
                            Button(action: viewModel.calculate) {
                                Text("Calculate")
                                    .padding(8)
                                    .background(Color.phosblue1)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            
                            Button(action: viewModel.clearAllNumbers) {
                                Text("Clear")
                                    .padding(8)
                                    .background(Color.phosred1)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                         
                        } // calculate and clear buttons
 
                    })
                
                
                Divider()
                    .padding(.vertical, 10)
                
                HStack {
                
                    
                    Text("use half-life to calculate k if needed")
                        .font(.headline)
                        .padding(.bottom, 10)
                        
                } // half-life text
                
                HStack {
                    VStack{
                        
                        HStack {
                            
                            Text("Half-Life:")
                            TextField("enter half-life", text: Binding(
                                get: {
                                    let unit = viewModel.timeUnitAbbreviations[viewModel.selectedTimeUnit] ?? ""
                                    if viewModel.calculatekComplete || viewModel.calculationComplete {
                                        let halfLife = viewModel.kineticsNumbers[0].halfLifeEntered.isEmpty ? viewModel.kineticsNumbers[0].halfLifeCalculated : viewModel.kineticsNumbers[0].halfLifeEntered
                                        return halfLife.contains(unit) ? halfLife : "\(halfLife) \(unit)"
                                    } else {
                                        return viewModel.kineticsNumbers[0].halfLifeEntered
                                    }
                                },
                                set: {
                                    if let range = $0.range(of: " ") {
                                        viewModel.kineticsNumbers[0].halfLifeEntered = String($0[..<range.lowerBound])
                                    } else {
                                        viewModel.kineticsNumbers[0].halfLifeEntered = $0
                                    }
                                }
                            ))
                            .foregroundColor(
                                !viewModel.calculationComplete || viewModel.calculatekComplete  && !viewModel.kineticsNumbers[0].calculatedkFromHalfLife.isEmpty ? .phosblue1 :
                                    viewModel.calculationComplete &&  viewModel.kineticsNumbers[0].calculatedkFromHalfLife.isEmpty ? .phosgreen1 :
                                        .primary
                            )
                            .keyboardType(.decimalPad)
                            .padding(5)
                            .frame(maxWidth: 220)
                            .frame(minWidth: 220)
                            .accessibilityLabel("half-life input field")
                            .multilineTextAlignment(.center)
                            .autocorrectionDisabled(true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.phostext, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .halfLife)
                            .onChange(of: focusedField) { oldValue, newValue in
                                if newValue == .halfLife {
                                    print("Half-Life text field is now active")
                                    activeField = Binding(
                                        get: { viewModel.kineticsNumbers[0].halfLifeEntered },
                                        set: { viewModel.kineticsNumbers[0].halfLifeEntered = $0 }
                                    )
                                }
                            }
                        } // half-life text field
                        
                        HStack {
                            
                            Button(action: {
                                var kineticsNumber = viewModel.kineticsNumbers[0]
                                viewModel.calculateKFromHalfLife(for: &kineticsNumber)
                                viewModel.kineticsNumbers[0] = kineticsNumber
                                
                            }) {
                                Text("Calculate k")
                                    .padding(8)
                                    .background(Color.phosblue1)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        } // calculate k button
                        
                    }
                        
                    
                    
                }
                .padding(.leading, 30)
                    if let successMessage = viewModel.successMessage {
                        Text(successMessage)
                            .foregroundColor(.phosgreen1)
                            .padding()
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.phosred1)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                
           
            }
            Spacer()

        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                CustomKeyboardToolbar(activeField: $activeField)
            }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
            focusedField = nil
            activeField = nil
            print("All fields deactivated")
        }
        
//          .padding(.top, -50)
        
        
        
    }
}


#Preview {
    KineticsView()
}
