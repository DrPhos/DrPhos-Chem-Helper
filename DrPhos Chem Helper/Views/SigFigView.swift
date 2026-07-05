//
//  SigFigView.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 7/22/25.
//


//
//  ContentView.swift
//  Significant-Figures
//
//  Created by Monte Helm on 6/27/25.
//

import SwiftUI
import UIKit

struct SigFigView: View {
    @State private var inputText = ""
    @State private var coloredResult: AttributedString = AttributedString("")
    @State private var answerText: String = ""
    @State private var zeroRules: [String] = []  // Not significant zero rules
    @State private var significantZeroRules: [String] = [] // Significant zero rules
    @State private var inputError: String? = nil
    @State private var isKeypadActive = false
    
    var body: some View {
        
            VStack {
            DrPhosSectionHeader(title: "Significant Figures Counter")
                .padding()
            
            VStack {
                HStack {
                    Button {
                        isKeypadActive = true
                    } label: {
                        Text(inputText.isEmpty ? "Enter a number" : inputText)
                            .font(.body.monospacedDigit())
                            .foregroundStyle(inputText.isEmpty ? .secondary : .primary)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(.background, in: RoundedRectangle(cornerRadius: 7))
                            .overlay {
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(isKeypadActive ? Color.accentColor : Color.secondary.opacity(0.35), lineWidth: 1.5)
                            }
                            .contentShape(Rectangle())
                    }
                        .buttonStyle(.plain)
                        .frame(minWidth: 100)
                        .padding(.vertical, 4)
                        .onChange(of: inputText) {
                            if inputText.filter({ $0 == "." }).count > 1 {
                                inputError = "Invalid input: too many decimal points"
                                answerText = ""
                                coloredResult = AttributedString("")
                                zeroRules = []
                                significantZeroRules = []
                                return
                            }
                            if inputText.lowercased().filter({ $0 == "e" }).count > 1 {
                                inputError = "Invalid input: too many x10^ symbols"
                                answerText = ""
                                coloredResult = AttributedString("")
                                zeroRules = []
                                significantZeroRules = []
                                return
                            }
                            let parts = inputText.lowercased().split(separator: "e", maxSplits: 1, omittingEmptySubsequences: false)
                            let mantissaPart = parts.first ?? ""
                            let exponentPart = parts.count > 1 ? parts[1] : ""
                            if mantissaPart.filter({ $0 == "-" }).count > 1 {
                                inputError = "Invalid input: too many negative signs in the base"
                                answerText = ""
                                coloredResult = AttributedString("")
                                zeroRules = []
                                significantZeroRules = []
                                return
                            }
                            if exponentPart.filter({ $0 == "-" }).count > 1 {
                                inputError = "Invalid input: too many negative signs in the exponent"
                                answerText = ""
                                coloredResult = AttributedString("")
                                zeroRules = []
                                significantZeroRules = []
                                return
                            }
                            inputError = nil
                            let (answer, colored, notSigRules, sigZeroRules) = analyzeSignificantFigures(for: inputText)
                            answerText = answer
                            coloredResult = colored
                            zeroRules = notSigRules
                            significantZeroRules = sigZeroRules
                        }
                    
                    // Clear button on the right
                    DrPhosButton(title: "Clear", backgroundColor: .phosred1) {
                        inputText = ""
                        answerText = ""
                        coloredResult = AttributedString("")
                        zeroRules = []
                        significantZeroRules = []
                        inputError = nil
                    }
                }
                
                // Display error message below the text field if input is invalid
                if let error = inputError {
                    Text(error)
                        .foregroundColor(.phosred1)
                        .font(.footnote)
                }
                
            }
            
            Group {
                Text(answerText.isEmpty ? "Please enter a number" : answerText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary, lineWidth: 1))
                    .padding(.horizontal)
                    .padding(.top, 10)

                Text(coloredResult)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .frame(height: 36) // fixed height to eliminate vertical jitter
                    .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 20) {
                        // Significant box
                        VStack {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.phosgreen1)
                                    Text("Significant")
                                        .foregroundColor(.phosgreen1)
                                        .font(.title3)
                                        .underline()
                                }
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)

                                VStack(alignment: .leading, spacing: 6) {
                                    let allSignificantRules = [
                                        "Non-zero numbers are always significant",
                                        "Zeros between two non-zero numbers are always significant",
                                        "When a decimal is present, trailing zeros are significant"
                                    ]
                                    ForEach(allSignificantRules, id: \.self) { rule in
                                        HStack(alignment: .top, spacing: 6) {
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 6))
                                                .padding(.top, 5)
                                            Text(rule)
                                                .foregroundColor(significantZeroRules.contains(rule) ? .phosgreen1 : .secondary)
                                                .font(.callout)
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: 420)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.phosgreen1, lineWidth: 1))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)

                        // Not Significant box
                        VStack {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "xmark.seal.fill")
                                        .foregroundColor(.phosred1)
                                    Text("Not Significant")
                                        .foregroundColor(.phosred1)
                                        .font(.title3)
                                        .underline()
                                }
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)

                                VStack(alignment: .leading, spacing: 6) {
                                    let allZeroRules = [
                                        "Trailing zeros in a number without a decimal point are not significant",
                                        "Leading zeros (including after a decimal) are never significant"
                                    ]
                                    ForEach(allZeroRules, id: \.self) { rule in
                                        HStack(alignment: .top, spacing: 6) {
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 6))
                                                .padding(.top, 5)
                                            Text(rule)
                                                .foregroundColor(zeroRules.contains(rule) ? .phosred1 : .secondary)
                                                .font(.callout)
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: 420)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.phosred1, lineWidth: 1))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                }
            }
            
      Spacer()
            
        }
        .padding([.leading, .trailing, .bottom])
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if isKeypadActive {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter number")
                        .font(.headline)
                    CustomNumericKeypad(value: $inputText, isActive: $isKeypadActive)
                }
                .frame(maxWidth: 680)
                .padding()
                .background(.regularMaterial)
                .overlay(alignment: .top) { Divider() }
                .shadow(color: .black.opacity(0.12), radius: 8, y: -2)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.18), value: isKeypadActive)
    }

    /// Returns a tuple with answer text, colored AttributedString, not significant zero rules, and significant zero rules
    private func analyzeSignificantFigures(for number: String) -> (String, AttributedString, [String], [String]) {
        let trimmed = number.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ("Please enter a number", AttributedString(""), [], [])
        }
        // Prevent all further logic unless a non-zero digit is present
        let mantissaCheck = trimmed.lowercased().split(separator: "e", maxSplits: 1, omittingEmptySubsequences: false).first ?? ""
        let mantissaDigits = mantissaCheck.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "")
        if !mantissaDigits.contains(where: { $0 != "0" }) {
            var result = AttributedString("")
            for ch in trimmed {
                var chAttr = AttributedString(String(ch))
                chAttr.foregroundColor = ch == "." || ch == "-" ? .primary : .phosred1
                result.append(chAttr)
            }
            return ("0 significant figures", result, ["Leading zeros (including after a decimal) are never significant"], [])
        }
        
        // Split exponent if present
        let parts = trimmed.lowercased().split(separator: "e", maxSplits: 1, omittingEmptySubsequences: false)
        let mantissa = String(parts[0])
        let exponentPart = parts.count > 1 ? "e" + parts[1] : ""
        
        // Check and remove sign if present
        let signChar: Character? = mantissa.first == "-" ? mantissa.first : nil
        let positiveMantissa = mantissa.hasPrefix("-") ? String(mantissa.dropFirst()) : mantissa
        let hasDecimal = positiveMantissa.contains(".")
        let digitsOnly = positiveMantissa.replacingOccurrences(of: ".", with: "")
        // (Redundant special case for all-zero mantissas removed)
        
        let digitsArray = Array(digitsOnly)
        
        var zeroRules: [String] = []
        var significantZeroRules: [String] = []
        
        // Find first non-zero digit index (corrected logic)
        _ = digitsArray.contains { $0 != "0" }
        let firstSigFigIndex: Int
        if let index = digitsArray.firstIndex(where: { $0 != "0" }) {
            firstSigFigIndex = index
        } else {
            firstSigFigIndex = digitsArray.count
        }
        
        // Rule: Leading zeros never count as significant
        if firstSigFigIndex > 0 {
            zeroRules.append("Leading zeros (including after a decimal) are never significant")
        }
        
        // Handle special zero case (all zeros)
        if firstSigFigIndex == digitsArray.count {
            // Number is zero or all zeros
            let sigFigCount = 1
            let answerStr = "\(sigFigCount) significant figure"
            
            // Build colored text
            var result = AttributedString("")
            if let s = signChar {
                var signAttr = AttributedString(String(s))
                signAttr.foregroundColor = .primary
                result.append(signAttr)
            }
            var sawOneZero = false
            for ch in positiveMantissa {
                var chAttr = AttributedString(String(ch))
                if ch == "0" && !sawOneZero {
                    chAttr.foregroundColor = .phosgreen1
                    sawOneZero = true
                } else if ch == "0" {
                    chAttr.foregroundColor = .phosred1
                } else if ch == "." {
                    chAttr.foregroundColor = .primary
                } else {
                    chAttr.foregroundColor = .primary
                }
                
                result.append(chAttr)
                
            }
            if !exponentPart.isEmpty {
                var expAttr = AttributedString(exponentPart)
                expAttr.foregroundColor = .primary
                result.append(expAttr)
            }
            return (answerStr, result, zeroRules, significantZeroRules)
        }
        
        // Find last significant digit
        var lastSigFigIndex = digitsArray.count - 1
        if !hasDecimal {
            while lastSigFigIndex >= firstSigFigIndex && digitsArray[lastSigFigIndex] == "0" {
                lastSigFigIndex -= 1
            }
            if lastSigFigIndex < digitsArray.count - 1 {
                zeroRules.append("Trailing zeros in a number without a decimal point are not significant")
            }
        }
        
        let sigFigCount = lastSigFigIndex - firstSigFigIndex + 1
        let plural = sigFigCount > 1 ? "s" : ""
        let answerStr = "\(sigFigCount) significant figure\(plural)"

        // Only show the non-zero rule after a non-zero digit has been entered
        if sigFigCount > 0 {
            significantZeroRules.insert("Non-zero numbers are always significant", at: 0)
        }
        
        // Determine significant and not-significant zero rules for the sig-fig region
        // (Between firstSigFigIndex and lastSigFigIndex, inclusive)
        if sigFigCount > 1 {
            for i in firstSigFigIndex...lastSigFigIndex {
                if digitsArray[i] == "0" {
                    // Improved: Zeros within the significant digit range are always significant
                    let hasNonZeroBefore = i > firstSigFigIndex ? digitsArray[firstSigFigIndex..<i].contains { $0 != "0" } : false
                    let hasNonZeroAfter = i < lastSigFigIndex ? digitsArray[(i+1)...lastSigFigIndex].contains { $0 != "0" } : false
                    let isSandwichedZero = hasNonZeroBefore && hasNonZeroAfter

                    if isSandwichedZero {
                        let rule = "Zeros between two non-zero numbers are always significant"
                        if !significantZeroRules.contains(rule) {
                            significantZeroRules.append(rule)
                        }
                    }

                    // Trailing zeros in decimal number are significant
                    let isTrailingDecimalZero =
                        hasDecimal &&
                        (i == lastSigFigIndex) &&
                        (i == digitsArray.count - 1)
                    if isTrailingDecimalZero {
                        let rule = "When a decimal is present, trailing zeros are significant"
                        if !significantZeroRules.contains(rule) {
                            significantZeroRules.append(rule)
                        }
                    }

                    // Zeros before the first non-zero digit (after decimal point) are not significant
                    let isLeadingDecimalZero =
                        hasDecimal &&
                        (i < firstSigFigIndex)
                    if isLeadingDecimalZero {
                        let rule = "Leading zeros (including after a decimal) are never significant"
                        if !zeroRules.contains(rule) {
                            zeroRules.append(rule)
                        }
                    }
                }
            }
        }
        
        // Build colored attributed string for the input, mantissa first
        var result = AttributedString("")
        if let s = signChar {
            var signAttr = AttributedString(String(s))
            signAttr.foregroundColor = .primary
            result.append(signAttr)
        }
        
        // To keep track of digit index inside digitsOnly, skip non-digits for correct alignment
        var sawNonZeroDigit = false
        var digitIndex = 0
        for ch in positiveMantissa {
            var chAttr = AttributedString(String(ch))
            
            if ch == "." {
                chAttr.foregroundColor = .primary
            } else if let digit = ch.wholeNumberValue {
                if !sawNonZeroDigit && digit != 0 {
                    sawNonZeroDigit = true
                }
                
                if sawNonZeroDigit {
                    if digitIndex >= firstSigFigIndex && digitIndex <= lastSigFigIndex {
                        chAttr.foregroundColor = .phosgreen1
                    } else {
                        chAttr.foregroundColor = .phosred1
                    }
                } else {
                    chAttr.foregroundColor = .phosred1
                }
                
                digitIndex += 1
            } else {
                chAttr.foregroundColor = .primary
            }
            
            result.append(chAttr)
        }
        
        if !exponentPart.isEmpty {
            let formattedExponent = exponentPart.replacingOccurrences(of: "e", with: " ×10")
            var prefix = AttributedString("×10")
            prefix.foregroundColor = .phosred1
            result.append(prefix)

            let exponentDigits = formattedExponent.dropFirst(4) // drop " ×10"
            for ch in exponentDigits {
                var charAttr = AttributedString(String(ch))
                charAttr.foregroundColor = .phosred1
                charAttr.baselineOffset = 8
                charAttr.font = .system(size: 16, weight: .bold)
                result.append(charAttr)
            }
        }
        
        return (answerStr, result, zeroRules, significantZeroRules)
    }
}


#Preview {
    SigFigView()
}
