//
//  ContentView.swift
//  calculator_022425
//
//  Created by Monte Helm on 2/24/25.
//

import SwiftUI

struct CalculatorView: View {
    @State private var input = ScientificCalculatorInput()
    @State private var displayValueString = "0"
    @State private var currentNumber = 0.0
    @State private var currentNumberString = "0"
    @State private var previousNumber = 0.0
    @State private var previousNumberString = "0"
    @State private var resultString = "0"
    @State private var currentOperation: Operation? = nil
    @State private var significantFigures = 3
    @State private var selectedOperation: Operation? = nil
    
    enum Operation {
        case add, subtract, multiply, divide
        static let ee = CalculatorButton.scientificNotation
    }
    
    let buttons: [[CalculatorButton]] = [
        [.clear, .plusMinus, .ee, .divide],
        [.one, .two, .three, .multiply],
        [.four, .five, .six, .subtract],
        [.seven, .eight, .nine, .add],
        [.backspace, .zero, .decimal, .equals],
        
    ]
    
    var body: some View {
        
        VStack(spacing: 5) {
            
            DrPhosSectionHeader(title: "Science Calculator")
                .foregroundColor(.white)
               
            
            Spacer()
            
            HStack {
                Spacer()

                VStack(alignment: .center, spacing: 4) {
                    
                    VStack(alignment: .center){
                        Text(input.value)
                            .font(.system(size: 64))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .padding(.bottom, 5)
                        
                        
                        
                    }
                    
                    Divider()
                        .background(Color.gray)
                        .padding(.bottom,10)
                    
                    

                    VStack {
                        
                        
                        Text("Normal")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .underline()
                        Text(convertToNormalForm(input.value))
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.bottom, 8)
                    
                    VStack {
                        
                        Text("Scientific Notation")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .underline()
                        Text(formatToScientificNotation(input.value))
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.bottom, 8)

                   

                    HStack {
                        Button(action: {
                            if significantFigures < 10 {
                                significantFigures += 1
                            }
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Text("Sig Figs: \(significantFigures)")
                            .foregroundColor(.gray)
                            .font(.footnote)

                        Button(action: {
                            if significantFigures > 1 {
                                significantFigures -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 8)

                    Divider()
                        .background(Color.gray)

                }
                .padding()
            }
            
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { button in
                        CalculatorButtonView(button: button, action: {
                            self.tapped(button: button)
                        }, selectedOperation: selectedOperation)
                    }
                }
            }
            
            Spacer()
            
        }
        .padding()
        .padding(.top, 10)
        .background(Color.black)
        
      
        
    }
    
    private func roundToSignificantFigures(_ value: Double, sigFigs: Int) -> String {
        guard value != 0 else { return "0" }
        let log10 = floor(log10(abs(value)))
        let scale = pow(10, Double(sigFigs) - 1 - log10)
        let rounded = (value * scale).rounded() / scale

        // Format to show trailing zeros if needed
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesSignificantDigits = true
        formatter.maximumSignificantDigits = sigFigs
        formatter.minimumSignificantDigits = sigFigs
        return formatter.string(from: NSNumber(value: rounded)) ?? "\(rounded)"
    }

    private func convertToNormalForm(_ value: String) -> String {
        if let number = Double(value) {
            return roundToSignificantFigures(number, sigFigs: significantFigures)
        }
        return value
    }

    private func formatToScientificNotation(_ value: String) -> String {
        if let number = Double(value) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .scientific
            formatter.maximumSignificantDigits = significantFigures
            formatter.minimumSignificantDigits = significantFigures
            formatter.exponentSymbol = "e"
            return convertToDisplayString(formatter.string(from: NSNumber(value: number)) ?? "\(number)")
        }
        return value
    }
    
    private let superscriptDigits: [String] = ["⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹"]

    private func convertExponentToSuperscript(_ exponent: String) -> String {
        var result = exponent
        
        // Handle the sign first
        if result.hasPrefix("+") {
            result = String(result.dropFirst())
        } else if result.hasPrefix("-") {
            result = "⁻" + String(result.dropFirst())
        }
        
        // Convert each digit
        for (index, digit) in superscriptDigits.enumerated() {
            result = result.replacingOccurrences(of: String(index), with: digit)
        }
        
        return result
    }

    private func convertToDisplayString(_ value: String) -> String {
        if value.contains("e") {
            let parts = value.split(separator: "e")
            if parts.count == 2 {
                let base = String(parts[0])
                let exponent = convertExponentToSuperscript(String(parts[1]))
                return base + "×10" + exponent
            }
        }
        return value
    }
    
    private func tapped(button: CalculatorButton) {
        switch button {
            
        case .scientificNotation:
            input.beginExponent()
            displayValueString = convertToDisplayString(input.value)
            
        case .digit(let number):
            input.enterDigit(number)
            displayValueString = convertToDisplayString(input.value)
            
        case .clear:
            input.clear()
            displayValueString = "0"
            currentNumber = 0
            currentNumberString = "0"
            previousNumber = 0
            previousNumberString = "0"
            resultString = "0"
            currentOperation = nil
            
        case .decimal:
            input.enterDecimal()
            displayValueString = input.value
            
        case .plusMinus:
            input.toggleSign()
            displayValueString = convertToDisplayString(input.value)
            
        case .percent:
            if var number = Double(input.value) {
                number /= 100
                input.replaceValue(with: formatNumber(number))
                displayValueString = convertToDisplayString(input.value)
            }
            
        case .operation(let operation):
            if let number = (input.value.contains("e") || input.value.contains("E")) ?
                Double(input.value.replacingOccurrences(of: "e", with: "E")) :
                Double(input.value) {
                if currentOperation != nil && !input.startsNewNumber {
                    // Only calculate if we've started entering a new number
                    calculate()
                    previousNumber = Double(input.value.replacingOccurrences(of: "e", with: "E")) ?? 0
                    previousNumberString = input.value
                } else {
                    previousNumber = number
                    previousNumberString = input.value
                }
                currentOperation = operation
                selectedOperation = operation
                input.beginNewNumber()
            }
            
        case .equals:
            calculate()
            
        case .backspace:
            input.backspace()
            displayValueString = convertToDisplayString(input.value)
        }
    }
    
    private func calculate() {
        if let operation = currentOperation {
            let currentVal = (input.value.contains("e")) ?
                Double(input.value.replacingOccurrences(of: "e", with: "E")) ?? 0 :
                Double(input.value) ?? 0
            
            currentNumberString = input.value
                
            var result: Double = 0
            
            switch operation {
            case .add:
                result = previousNumber + currentVal
            case .subtract:
                result = previousNumber - currentVal
            case .multiply:
                result = previousNumber * currentVal
            case .divide:
                result = previousNumber / currentVal
            }
            
            if abs(result) > 1e10 || (abs(result) < 1e-10 && result != 0) {
                let scientificFormat = String(format: "%.2e", result)
                input.replaceValue(with: scientificFormat.replacingOccurrences(of: "e+", with: "e"), startsNewNumber: true)
            } else {
                input.replaceValue(with: formatNumber(result), startsNewNumber: true)
            }
            
            displayValueString = convertToDisplayString(input.value)
            resultString = input.value
            
            currentOperation = nil
            selectedOperation = nil
        }
    }
    
    private func formatNumber(_ number: Double) -> String {
        return String(number)
    }

    private func formatNumberWithCommas(_ value: String) -> String {
        // Handle numbers being typed
        let parts = value.split(separator: ".")
        if parts.count > 0 {
            let wholeNumber = String(parts[0])
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            
            if let number = Int(wholeNumber.replacingOccurrences(of: ",", with: "")) {
                let formattedWhole = formatter.string(from: NSNumber(value: number)) ?? wholeNumber
                
                if parts.count > 1 {
                    // Has decimal part
                    return formattedWhole + "." + String(parts[1])
                } else {
                    return formattedWhole
                }
            }
        }
        return value
    }
    
}

enum CalculatorButton: Hashable {
    case digit(Int)
    case operation(CalculatorView.Operation)
    case clear
    case plusMinus
    case percent
    case decimal
    case equals
    case scientificNotation
    case backspace
    
    static let zero = CalculatorButton.digit(0)
    static let one = CalculatorButton.digit(1)
    static let two = CalculatorButton.digit(2)
    static let three = CalculatorButton.digit(3)
    static let four = CalculatorButton.digit(4)
    static let five = CalculatorButton.digit(5)
    static let six = CalculatorButton.digit(6)
    static let seven = CalculatorButton.digit(7)
    static let eight = CalculatorButton.digit(8)
    static let nine = CalculatorButton.digit(9)
    
    static let divide = CalculatorButton.operation(.divide)
    static let multiply = CalculatorButton.operation(.multiply)
    static let subtract = CalculatorButton.operation(.subtract)
    static let add = CalculatorButton.operation(.add)
    static let ee = CalculatorButton.scientificNotation
    static let back = CalculatorButton.backspace
}

struct CalculatorButtonView: View {
    let button: CalculatorButton
    let action: () -> Void
    let selectedOperation: CalculatorView.Operation?
    
    var body: some View {
        Button(action: action) {
            Text(buttonText)
                .font(.system(size: 32))
                .frame(width: buttonWidth, height: buttonHeight)
                .background(buttonColor)
                .foregroundColor(button == .backspace ? .pink : .white)
                .cornerRadius(buttonHeight/2)
        }
    }
    
    private var buttonText: String {
        switch button {
        case .digit(let number): return "\(number)"
        case .operation(let operation):
            switch operation {
            case .add: return "+"
            case .subtract: return "−"
            case .multiply: return "×"
            case .divide: return "÷"
            }
        case .clear: return "AC"
        case .plusMinus: return "±"
        case .percent: return "%"
        case .decimal: return "."
        case .equals: return "="
        case .scientificNotation: return "×10˄"
        case .backspace: return "⌫"
        }
    }
    
    private var buttonColor: Color {
        switch button {
        case .operation(let operation):
            if selectedOperation == operation {
                return .orange.opacity(0.5)
            }
            return .orange
        case .clear: return .red
        case .plusMinus, .percent: return .gray
        default: return Color(.darkGray)
        }
    }
    
    private var buttonWidth: CGFloat {
        switch button {
        default: return 80
        }
    }
    
    private let buttonHeight: CGFloat = 67
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
    }
}
