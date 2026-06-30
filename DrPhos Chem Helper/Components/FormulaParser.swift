//
//  FormulaParser.swift
//  DrPhos Chem Helper
//
//  Created by Monte Helm on 2/15/25.
//

import Foundation

struct FormulaParser {
    struct ParsedElement {
        let symbol: String
        let count: Int
        let insideParentheses: Bool
    }
    
    struct ParseResult {
        let isValid: Bool
        let invalidElement: String?
        let parsedElements: [ParsedElement]
        let formattedString: String
    }
    
    static func parse(_ compound: String) -> ParseResult {
        if compound.isEmpty {
            return ParseResult(isValid: true, invalidElement: nil, parsedElements: [], formattedString: "")
        }
        
        // Early validation
        let validation = PeriodicTableData.validateFormula(compound)
        if !validation.isValid {
            return ParseResult(
                isValid: false,
                invalidElement: validation.invalidElement,
                parsedElements: [],
                formattedString: "Invalid Compound Format"
            )
        }
        
        let parsedElements: [ParsedElement]
        if compound.contains("(") && compound.contains(")") {
            parsedElements = parseComplexCompound(compound)
        } else if compound.contains("(") && !compound.contains(")") {
            return ParseResult(
                isValid: false,
                invalidElement: "Unmatched parentheses",
                parsedElements: [],
                formattedString: "Invalid Compound Format"
            )
        } else {
            parsedElements = parseSimpleCompound(compound)
        }
        
        return ParseResult(
            isValid: true,
            invalidElement: nil,
            parsedElements: parsedElements,
            formattedString: formatParsedElements(parsedElements)
        )
    }
    
    private static func parseSimpleCompound(_ compound: String) -> [ParsedElement] {
        var elements: [ParsedElement] = []
        var currentElement = ""
        var currentCount = ""
        
        for char in compound {
            if char.isLetter {
                if char.isUppercase && !currentElement.isEmpty {
                    elements.append(createParsedElement(currentElement, count: currentCount))
                    currentElement = String(char)
                    currentCount = ""
                } else {
                    currentElement.append(char)
                }
            } else if char.isNumber {
                currentCount.append(char)
            }
        }
        
        if !currentElement.isEmpty {
            elements.append(createParsedElement(currentElement, count: currentCount))
        }
        
        return elements
    }
    
    private static func parseComplexCompound(_ compound: String) -> [ParsedElement] {
        var elements: [ParsedElement] = []
        var currentElement = ""
        var currentCount = ""
        var parenthesesLevel = 0
        var parenthesesBuffer: [ParsedElement] = []
        
        var index = compound.startIndex
        while index < compound.endIndex {
            let char = compound[index]
            
            switch char {
            case "(":
                if !currentElement.isEmpty {
                    elements.append(createParsedElement(currentElement, count: currentCount))
                    currentElement = ""
                    currentCount = ""
                }
                parenthesesLevel += 1
                
            case ")":
                if !currentElement.isEmpty {
                    parenthesesBuffer.append(createParsedElement(currentElement, count: currentCount, inParentheses: true))
                    currentElement = ""
                    currentCount = ""
                }
                
                // Look ahead for multiplier
                var multiplier = ""
                var nextIndex = compound.index(after: index)
                while nextIndex < compound.endIndex && compound[nextIndex].isNumber {
                    multiplier.append(compound[nextIndex])
                    nextIndex = compound.index(after: nextIndex)
                }
                
                let multiplierValue = Int(multiplier) ?? 1
                
                // Apply multiplier to all elements in parentheses buffer
                for element in parenthesesBuffer {
                    elements.append(ParsedElement(
                        symbol: element.symbol,
                        count: element.count * multiplierValue,
                        insideParentheses: false
                    ))
                }
                
                parenthesesBuffer.removeAll()
                parenthesesLevel -= 1
                index = compound.index(before: nextIndex)
                
            case _ where char.isLetter:
                if char.isUppercase && !currentElement.isEmpty {
                    if parenthesesLevel > 0 {
                        parenthesesBuffer.append(createParsedElement(currentElement, count: currentCount, inParentheses: true))
                    } else {
                        elements.append(createParsedElement(currentElement, count: currentCount))
                    }
                    currentElement = String(char)
                    currentCount = ""
                } else {
                    currentElement.append(char)
                }
                
            case _ where char.isNumber:
                currentCount.append(char)
                
            default:
                break
            }
            
            index = compound.index(after: index)
        }
        
        // Handle any remaining element
        if !currentElement.isEmpty {
            if parenthesesLevel > 0 {
                parenthesesBuffer.append(createParsedElement(currentElement, count: currentCount, inParentheses: true))
            } else {
                elements.append(createParsedElement(currentElement, count: currentCount))
            }
        }
        
        return elements
    }
    
    private static func createParsedElement(_ element: String, count: String, inParentheses: Bool = false) -> ParsedElement {
        ParsedElement(
            symbol: element,
            count: max(Int(count) ?? 1, 1),
            insideParentheses: inParentheses
        )
    }
    
    private static func formatParsedElements(_ elements: [ParsedElement]) -> String {
        var elementCountMap: [String: Int] = [:]
        
        for element in elements {
            elementCountMap[element.symbol, default: 0] += element.count
        }
        
        return elementCountMap
            .sorted { $0.key < $1.key }
            .map { element, count in
                count == 1 ? element : "\(element)\(count)"
            }
            .joined()
    }
}

struct ChemistryCalculator {
    static func molarMass(for elements: [FormulaParser.ParsedElement]) -> Double {
        elements.reduce(0) { total, element in
            total + PeriodicTableData.getMass(for: element.symbol) * Double(element.count)
        }
    }

    static func molarMass(for formula: String) -> Double? {
        let result = FormulaParser.parse(formula)
        guard result.isValid else { return nil }
        return molarMass(for: result.parsedElements)
    }
}
