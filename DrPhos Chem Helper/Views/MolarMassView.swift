//
//  ContentView.swift
//  Molar Mass Calculator
//
//  Created by Monte Helm on 10/23/23.
//

import SwiftUI

struct MolarMassView: View {
    
    @State var compoundFormula = ""
    @State var molarMass = 0.0
    @State var currentGroup = 1
    @State var decimalPlaces = 2
    @State var elementalAnalysis = ""
    @State var parsedFormula: [(element: String, count: Int, insideParentheses: Bool)] = []
    @State var compoundString = ""
    @State var eaText = ""
    @State private var isCollapsed: Bool = true
    @State private var isValidFormula = true
    @State private var invalidElement = ""
    @State private var showEntrySheet = false
    
    
    var body: some View {
        VStack {
            headerView
            molarMassView
            VStack {
                HStack {
                    Spacer()
                    ZStack {
                        TextField("Enter Compound Formula", text: $compoundFormula)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 300, minHeight: 40)
                            .onChange(of: compoundFormula) {
                                handleCompoundFormulaChange()
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isValidFormula ? Color.numbers : Color.phosred1, lineWidth: 1)
                            )
                        // Tap area behind clear button
                        Color.white.opacity(0.001)
                            .contentShape(Rectangle())
                            .allowsHitTesting(true)
                            .onTapGesture {
                                showEntrySheet = true
                            }
                    }
                    .frame(height: 40)
                    
                    deleteButton
                    
                    Spacer().frame(width: 20)
                }

                if !isValidFormula {
                    Text("Invalid element: \(invalidElement)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }

                // Reintroduce NumbersView below the TextField and error message
                NumbersView(compoundFormula: $compoundFormula)
                    .padding(.vertical, 5)
            }
            elementalAnalysisView
            PeriodicTableView(compoundFormula: $compoundFormula)
        }
        .sheet(isPresented: $showEntrySheet) {
            CompoundEntry(compoundFormula: $compoundFormula, isPresented: $showEntrySheet)
                .presentationDetents([.fraction(0.75)])
        }
//        .environmentObject(favoritesManager)
//        .padding(.top, -50)
    }
    
    private func updateCompoundData() {
        // Favorites feature removed
    }
    
    private var headerView: some View {
        Text("Molar Mass Calculator")
            .font(.title)
            .fontWeight(.bold)
    }
    
    private var molarMassView: some View {
        Text("Molar Mass = \(String(format: "%.\(decimalPlaces)f", molarMass)) g/mol")
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(.phosblue1)
            .padding(.top, 5)
    }
    
    
    private var clearButtonOverlay: some View {
        HStack {
            Spacer()
            Button(action: clearInput) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.numbers)
            }
            .padding(.trailing, 10)
            .opacity(compoundFormula.isEmpty ? 0 : 1)
        }
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
        .accessibilityLabel("Clear formula")
        .padding(.leading, -24)
    }
    
    private var elementalAnalysisView: some View {
        VStack {
            Button(action: toggleElementalAnalysis) {
               
                HStack {

                    VStack(alignment: .leading){
                       
                        HStack {
                            Image(systemName: isCollapsed ? "chevron.right" : "chevron.up")
                                .rotationEffect(.degrees(isCollapsed ? 0 : 180))
                                .foregroundColor(.numbers)
                            Text("Elemental Analysis")
                                .font(.subheadline)
                                .foregroundColor(.numbers)
                            decimalAdjustmentButtons
                                .padding(.leading, 40)
                        }
                        
                        VStack {
                            if !isCollapsed {
                                FormattedTextView(eaText: elementalAnalysis)
                                    .padding(.top, 1)
                                    .foregroundColor(.numbers)
                            }
                        }
                        .padding(.bottom, 10)
                        .padding(.leading, 20)
                    }
                          
                }
            }
    
        }
    }
    
    private var decimalAdjustmentButtons: some View {
        HStack {
            Button(action: incrementDecimalPlaces) {
                Image(systemName: "plus.circle")
                    .foregroundColor(Color.numbers)
            }
            .buttonStyle(PlainButtonStyle())
            Text("Decimals")
                .foregroundColor(Color.numbers)
                .font(.caption)
            Button(action: decrementDecimalPlaces) {
                Image(systemName: "minus.circle")
                    .foregroundColor(Color.numbers)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func clearInput() {
        compoundFormula = ""
        molarMass = 0.0
        elementalAnalysis = ""
    }
    
    private func deleteLastCharacter() {
        
       
        
        if !compoundFormula.isEmpty {
            compoundFormula.removeLast()
        }
    }
    
    private func toggleElementalAnalysis() {
        withAnimation {
            isCollapsed.toggle()
        }
    }
    
    private func incrementDecimalPlaces() {
        if decimalPlaces < 6 {
            decimalPlaces += 1
            calculateElementalAnalysis()
            updateCompoundData()
        }
    }
    
    private func decrementDecimalPlaces() {
        if decimalPlaces > 0 {
            decimalPlaces -= 1
            calculateElementalAnalysis()
        }
    }
    
    private func handleCompoundFormulaChange() {
        if compoundFormula.isEmpty {
            isValidFormula = true
            invalidElement = ""
            molarMass = 0.0
            elementalAnalysis = ""
            return
        }
        
        let parseResult = FormulaParser.parse(compoundFormula)
        isValidFormula = parseResult.isValid
        invalidElement = parseResult.invalidElement ?? ""
        
        if parseResult.isValid {
            compoundString = parseResult.formattedString
            parsedFormula = parseResult.parsedElements.map { ($0.symbol, $0.count, $0.insideParentheses) }
            calculateMolarMass(compoundString)
            calculateElementalAnalysis()
        }
    }
    
    // MARK: - Parsing Functions

    
    // MARK: - Calculation Functions
    
    private func calculateMolarMass(_ compoundFormula: String) {
        molarMass = ChemistryCalculator.molarMass(for: compoundFormula) ?? 0
    }
    
    private func calculateElementalAnalysis() {
        var elementTotal = 0.0
        var currentIndex = compoundString.startIndex
        var massPercent = 0.0
        elementalAnalysis = ""
        
        while currentIndex < compoundString.endIndex {
            let char = compoundString[currentIndex]
            
            if char.isLetter {
                var elementSymbol = String(char)
                currentIndex = compoundString.index(after: currentIndex)
                while currentIndex < compoundString.endIndex && compoundString[currentIndex].isLowercase {
                    elementSymbol.append(compoundString[currentIndex])
                    currentIndex = compoundString.index(after: currentIndex)
                }
                
                var subscriptValue = ""
                while currentIndex < compoundString.endIndex && compoundString[currentIndex].isNumber {
                    subscriptValue.append(compoundString[currentIndex])
                    currentIndex = compoundString.index(after: currentIndex)
                }
                
                // Use the new getMass method
                let elementMass = PeriodicTableData.getMass(for: elementSymbol)
                let multiplier = Double(subscriptValue) ?? 1.0
                
                elementTotal += elementMass * multiplier
                massPercent = elementTotal / molarMass * 100
                
                elementalAnalysis.append("\(elementSymbol) = \(String(format: "%.\(decimalPlaces)f", massPercent))%, ")
                
                elementTotal = 0
            }
        }
    }
    
    // MARK: - Custom Views and Styles
    
    struct FormattedTextView: View {
        var eaText: String

        var body: some View {

                formatText(eaText)
        
        }

        func formatText(_ eaText: String) -> Text {
            let textWithoutCommas = eaText.replacingOccurrences(of: ",", with: "")
            do {
                let regex = try NSRegularExpression(pattern: #"\D+\s\d+\D\d+\D"#, options: [])
                let range = NSRange(location: 0, length: textWithoutCommas.utf16.count)
                var extractedNumbers = [String]()
                let matches = regex.matches(in: textWithoutCommas, options: [], range: range)
                
                for match in matches {
                    let matchRange = Range(match.range, in: textWithoutCommas)!
                    var number = String(textWithoutCommas[matchRange])
                    number = number.trimmingCharacters(in: .whitespacesAndNewlines)
                    extractedNumbers.append(number)
                }
                
                extractedNumbers.sort { (first, second) in
                    if let num1 = Double(first), let num2 = Double(second) {
                        return num1 < num2
                    }
                    return first < second
                }
                
                var formattedText = Text("")
                for (index, number) in extractedNumbers.enumerated() {
                    formattedText = formattedText + Text(number)
                        .font(.headline)
                    if index < extractedNumbers.count - 1 {
                        formattedText = formattedText + Text("\n")
                    }
                }
                return formattedText
            } catch {
                print("Error creating regex: \(error.localizedDescription)")
            }
            return Text(eaText)
        }
    }
    
    struct BorderButtonStyleO2: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.all, 5)
                .font(.headline)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green)
                        .stroke(Color.numbers, lineWidth: 3)
                )
                .cornerRadius(10)
        }
    }
}

#Preview {
    MolarMassView()
}
