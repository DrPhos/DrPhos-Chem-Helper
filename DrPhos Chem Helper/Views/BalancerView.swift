//
//  BalancerView.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 7/25/25.
//


import SwiftUI
import Combine

struct BalancerView: View {
    @StateObject private var viewModel = ReactionBalancerViewModel()
    @State private var showCompoundEntry = false
    
    var body: some View {
        VStack(alignment: .center) {
            
            DrPhosSectionHeader(title: "Reaction Balancer")
                .fontWeight(.bold)
            
            HStack {
                Button("Reactant") {
                    viewModel.isEnteringReactants = true
                    viewModel.processInput2()
                    viewModel.processEnteredText()
                    viewModel.enteredText = ""
                }
                .foregroundColor(.numbers)
                .font(.headline)
                .padding(5)
                .background(Color.numberstext)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.numbers, lineWidth: 1))
                
                ZStack {
                    TextField("", text: $viewModel.enteredText)
                        .disabled(true)
                        .frame(maxWidth: 200)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.phostext, lineWidth: 1)
                        )
                        .overlay(
                            HStack {
                                Spacer()
                                if !viewModel.enteredText.isEmpty {
                                    Button(action: {
                                        viewModel.enteredText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.trailing, 8)
                                }
                            }
                        )

                    Button(action: {
                        showCompoundEntry = true
                    }) {
                        Color.clear.frame(width: 200, height: 40)
                    }
                }
                
                Button("Product") {
                    viewModel.isEnteringReactants = false
                    viewModel.processInput2()
                    viewModel.processEnteredText()
                    viewModel.enteredText = ""
                }
                .foregroundColor(.numbers)
                .font(.headline)
                .padding(5)
                .background(Color.numberstext)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.numbers, lineWidth: 1))
            }
            .frame(maxWidth: 400) // Limit the width to match TextField width
            
            VStack(alignment: .center) {
                ScrollView(.horizontal) {
                    HStack {
                        if viewModel.isBalancing {
                            let reactants = viewModel.displayText.components(separatedBy: ", ")
                            
                            ForEach(Array(0..<viewModel.reactantCount), id: \.self) { index in
                                if index != 0 {
                                    Text("+ ")
                                        .font(.title3)
                                }
                                
                                FormattedTextView1(inputText: reactants[index], reactantCount: $viewModel.reactantCount)
                            }
                            
                            if !viewModel.isEnteringReactants {
                                Image(systemName: "arrowshape.right.fill")
                            }
                            
                            ForEach(Array(viewModel.reactantCount..<reactants.count), id: \.self) { index in
                                if index != viewModel.reactantCount {
                                    Text("+ ").font(.title3)
                                }
                                FormattedTextView1(inputText: reactants[index], reactantCount: $viewModel.reactantCount)
                            }
                        } else {
                            ForEach(viewModel.enteredReactants, id: \.self) { text in
                                CustomTextWithBaselineOffset1(text: text)
                            }
                            
                            if !viewModel.isEnteringReactants {
                                Image(systemName: "arrowshape.right.fill")
                            }
                            
                            ForEach(viewModel.enteredProducts, id: \.self) { text in
                                CustomTextWithBaselineOffset1(text: text)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                }
                .frame(maxWidth: 330) // Limit the width to match TextField width
                .padding(20)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.phostext, lineWidth: 1))
            .padding(.top, 10)
            
            HStack {
                Spacer()
                
                Button("Balance") {
                    viewModel.isBalancing.toggle()
                    
                    let lastArray = viewModel.solve(viewModel.finalString)
                    viewModel.integerArray = viewModel.convertToIntegerArray(lastArray)
                    
                    if !lastArray.isEmpty {
                        viewModel.coeff = "Coefficients: \(viewModel.integerArray.map { "\($0.value)" }.joined(separator: ", "))"
                    } else {
                        viewModel.coeff = "Invalid input or calculation error"
                    }
                    
                    viewModel.displayText = viewModel.combinedText()
                    print("displaytext \(viewModel.displayText)")
                }
                .padding(5)
                .font(.headline)
                .foregroundColor(.white)
                .background(Color.seven)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.phostext, lineWidth: 1))
                .padding(.trailing, 20)
                
                
                
                Button("Clear") {
                    viewModel.clearFields()
                }
                .font(.headline)
                .padding(5)
                .background(Color.one)
                .foregroundColor(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.phostext, lineWidth: 1))
                .padding(.leading, 20)
                
                Spacer()
            }
            .padding(.top, 10)
            .padding(.bottom, 5)
            
            NumbersView1(compoundFormula: $viewModel.enteredText)
                .padding(.top, 10)
            
            PeriodicTableView(compoundFormula: $viewModel.enteredText)
                .padding(.top, 10)
        }
//        .padding(.top, -50)
        .sheet(isPresented: $showCompoundEntry) {
            CompoundEntry(compoundFormula: $viewModel.enteredText, isPresented: $showCompoundEntry)
        }
    }
}

struct NumbersView1: View {
    let numberOfRows = 1
    let numberOfColumns = 11
    let buttonWidth: CGFloat = 30
    
    let buttonLabels: [[String]] = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "⌫"]]
    
    @Binding var compoundFormula: String
    
    func handleButtonTap(_ buttonLabel: String) {
        if buttonLabel == "⌫" {
            compoundFormula = String(compoundFormula.dropLast())
        } else {
            compoundFormula += buttonLabel
        }
    }
    
    var body: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(buttonWidth), spacing: 2), count: numberOfColumns), spacing: 1) {
                ForEach(0..<numberOfRows, id: \.self) { row in
                    ForEach(0..<numberOfColumns, id: \.self) { column in
                        let buttonLabel = buttonLabels[row][column]
                        
                        if buttonLabel.isEmpty {
                            Color.clear
                                .frame(width: buttonWidth, height: 40)
                                .hidden()
                        } else {
                            Button(action: {
                                handleButtonTap(buttonLabel)
                            }) {
                                Text(buttonLabel)
                                    .frame(width: buttonWidth, height: 30)
                                    .background(Color.numbers)
                                    .foregroundColor(.numberstext)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            }
        }
    }
}

class ReactionBalancerViewModel: ObservableObject {
    @Published var enteredText = ""
    @Published var isEnteringReactants = true
    @Published var compound: [(id: Int, text: String)] = []
    @Published var compoundIndex = 1
    @Published var parsedFormula: [(element: String, count: Int, insideParentheses: Bool)] = []
    @Published var formattedString: String = ""
    @Published var testString: String = ""
    @Published var entryIndex = 1
    @Published var entries: [(id: Int, text: String, isReactant: Bool)] = []
    @Published var enteredReactants: [String] = []
    @Published var enteredProducts: [String] = []
    @Published var enteredReaction: String = ""
    @Published var parsedReaction: (left: [String], right: [String], elems: Set<String>) = ([], [], [])
    @Published var allCompounds: [String] = []
    @Published var reactantCount: Int = 0
    @Published var productIndex: Int = 0
    @Published var finalString: String = ""
    @Published var coeff = ""
    @Published var isBalancing = false
    @Published var integerArray: [(id: Int, value: Int)] = []
    @Published var finalText: [(Int, String)] = []
    @Published var combinedTextResult: String = ""
    @Published var displayText: String = ""
    
    func clearFields() {
        enteredText.removeAll()
        enteredReactants.removeAll()
        enteredProducts.removeAll()
        isEnteringReactants = true
        allCompounds.removeAll()
        enteredReaction.removeAll()
        reactantCount = 0
        formattedString = ""
        entryIndex = 1
        entries = []
        compound = []
        compoundIndex = 1
        coeff.removeAll()
        isBalancing = false
    }
    
    func recordCompound(Text: String) {
        guard !enteredText.isEmpty else { return }
        let cmpd = (id: compoundIndex, text: enteredText)
        compound.append(cmpd)
        compoundIndex += 1
    }
    
    func parseChemicalCompound(_ compound: String) {
        if compound.contains("(") && compound.contains(")") {
            performAlternativeAction(compound)
        } else {
            var result = [(element: String, count: Int, insideParentheses: Bool)]()
            let pattern = #"([A-Z][a-z]*)(\d*)"#
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: compound, options: [], range: NSRange(location: 0, length: compound.utf16.count))
            for match in matches {
                let elementRange = Range(match.range(at: 1), in: compound)!
                let countRange = Range(match.range(at: 2), in: compound)!
                let element = String(compound[elementRange])
                let countString = String(compound[countRange])
                let count = Int(countString) ?? 1
                result.append((element, count, false))
            }
            parsedFormula = result
            formattedString = formatResult(result)
        }
    }
    
    func performAlternativeAction(_ compound: String) {
        var result = [(element: String, count: Int, insideParentheses: Bool)]()
        var currentElement = ""
        var currentCount = 1
        var insideParentheses = false
        var index = compound.startIndex
        while index < compound.endIndex {
            let char = compound[index]
            if char.isLetter {
                if char.isUppercase {
                    if !currentElement.isEmpty {
                        result.append((currentElement, currentCount, insideParentheses))
                        currentCount = 1
                    }
                    currentElement = String(char)
                } else {
                    currentElement += String(char)
                }
            } else if char.isNumber {
                currentCount = Int(String(char)) ?? 1
                result.append((currentElement, currentCount, insideParentheses))
                currentElement = ""
                currentCount = 1
            } else if char == "(" {
                if !currentElement.isEmpty {
                    result.append((currentElement, currentCount, insideParentheses))
                    currentElement = ""
                    currentCount = 1
                }
                insideParentheses = true
            } else if char == ")" {
                if !currentElement.isEmpty {
                    result.append((currentElement, currentCount, insideParentheses))
                    currentElement = ""
                    currentCount = 1
                }
                insideParentheses = false
                index = compound.index(after: index)
                while index < compound.endIndex, compound[index].isNumber {
                    let digit = Int(String(compound[index])) ?? 1
                    currentCount = digit
                    index = compound.index(after: index)
                    for i in 0..<result.count {
                        if result[i].insideParentheses {
                            result[i].count *= currentCount
                            result[i].insideParentheses = false
                        }
                    }
                }
                index = compound.index(before: index)
            }
            index = compound.index(after: index)
            currentCount = 1
        }
        if !currentElement.isEmpty {
            result.append((currentElement, currentCount, insideParentheses))
        }
        parsedFormula = result
        formattedString = formatResult(result)
    }
    
    func processEnteredTextforBalance(Text: String) {
        guard !formattedString.isEmpty else { return }
        let entry = (id: entryIndex, text: formattedString, isReactant: isEnteringReactants)
        entries.append(entry)
        entryIndex += 1
    }
    
    func processEnteredText() {
        let trimmedText = enteredText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            if isEnteringReactants {
                enteredReactants.append(enteredReactants.isEmpty ? "? \(trimmedText)" : "+ ? \(trimmedText)")
            } else {
                let separator = enteredProducts.isEmpty ? "? " : "+ ? "
                enteredProducts.append("\(separator)\(trimmedText)")
            }
            enteredReaction = enteredReactants.joined(separator: " ") + " = " + enteredProducts.joined(separator: " ")
            parsedReaction = parseInitialReaction(enteredReaction)
            allCompounds = parsedReaction.left + parsedReaction.right
        }
    }
    
    func parseInitialReaction(_ reaction: String) -> (left: [String], right: [String], elems: Set<String>) {
        let left = reaction.components(separatedBy: "=")[0].components(separatedBy: "+")
        let right = reaction.components(separatedBy: "=")[1].components(separatedBy: "+")
        var elems = Set<String>()
        let regex = try! NSRegularExpression(pattern: "([A-Z][a-z]*)")
        let matches = regex.matches(in: reaction, range: NSRange(reaction.startIndex..., in: reaction))
        for match in matches {
            let range = Range(match.range, in: reaction)!
            let matchedSubstring = reaction[range]
            elems.insert(String(matchedSubstring))
        }
        var reactants: [String] = [] {
            didSet {
                reactantCount = reactants.count
                productIndex = reactantCount + 1
            }
        }
        for entry in left {
            reactants.append(entry)
        }
        for index in 0..<reactantCount {
            _ = reactants[index]
        }
        elems.remove("")
        return (left, right, elems)
    }
    
    func formatResult(_ result: [(element: String, count: Int, insideParentheses: Bool)]) -> String {
        var elementCountMap = [String: Int]()
        for item in result {
            let key = item.element
            let count = item.count
            if let existingCount = elementCountMap[key] {
                elementCountMap[key] = existingCount + count
            } else {
                elementCountMap[key] = count
            }
        }
        let formattedString = elementCountMap.map { "\($0.key)\($0.value)" }.joined(separator: "")
        return formattedString
    }
    
    func processInput2() {
        recordCompound(Text: enteredText)
        parseChemicalCompound(enteredText)
        formattedString = formatResult(parsedFormula)
        processEnteredTextforBalance(Text: formattedString)
        let chemicalElements = entries.map { ChemicalElement1(id: $0.id, text: $0.text, isReactant: $0.isReactant) }
        finalString = createFinalString(entries: chemicalElements)
    }
    
    func createFinalString(entries: [ChemicalElement1]) -> String {
        var resultString = ""
        var hasReactant = false
        for element in entries {
            if element.isReactant {
                if hasReactant {
                    resultString += "+"
                }
                resultString += element.text
                hasReactant = true
            }
        }
        if hasReactant && resultString.isEmpty == false {
            resultString += "="
        }
        for element in entries {
            if !element.isReactant {
                resultString += element.text + "+"
            }
        }
        if !resultString.isEmpty {
            resultString.removeLast()
        }
        testString = resultString
        return resultString
    }
    
    func solve(_ x: String) -> [Double] {
        ReactionBalancingEngine().solve(x)
    }
    
    func convertToReducedEchelonForm(_ matrix: inout [[Double]]) {
        let rowCount = matrix.count
        let colCount = matrix[0].count
        var lead = 0
        for r in 0..<rowCount {
            if colCount <= lead {
                return
            }
            var i = r
            while matrix[i][lead] == 0 {
                i += 1
                if rowCount == i {
                    i = r
                    lead += 1
                    if colCount == lead {
                        return
                    }
                }
            }
            matrix.swapAt(i, r)
            let lv = matrix[r][lead]
            for j in 0..<colCount {
                matrix[r][j] /= lv
            }
            for i in 0..<rowCount {
                if i != r {
                    let multiplier = matrix[i][lead]
                    for j in 0..<colCount {
                        matrix[i][j] -= multiplier * matrix[r][j]
                    }
                }
            }
            lead += 1
        }
    }
    
    func multiplyArray(_ numbers: [Double]) -> [Double] {
        var lastArray: [Double] = []
        let tolerance = 0.0001
        var stopped = false
        for constant in 1...100 where !stopped {
            let multipliedArray = numbers.map { $0 * Double(constant) }
            let areAllCloseToIntegers = multipliedArray.allSatisfy { abs($0 - round($0)) < tolerance }
            if areAllCloseToIntegers {
                lastArray = multipliedArray.map { abs($0) }
                lastArray.append(Double(constant))
                stopped = true
            }
        }
        return lastArray
    }
    
    func convertToIntegerArray(_ numbers: [Double]) -> [(id: Int, value: Int)] {
        ReactionBalancingEngine().integerCoefficients(from: numbers)
    }
    
    func combinedText() -> String {
        let combinedStrings = zip(integerArray, compound).map { (integerElement, compoundElement) in
            return "\(integerElement.value) \(compoundElement.text)"
        }
        let result = combinedStrings.joined(separator: ", ")
        combinedTextResult = result
        return combinedTextResult
    }
    
    func finalReaction(tempResult: String, pattern: String = #"\b\d+\s\w+\b"#, separator: String = " ") -> String? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: tempResult, options: [], range: NSRange(location: 0, length: tempResult.utf16.count))
            let matchedStrings = matches.map { (result) -> String in
                let range = Range(result.range, in: tempResult)!
                _ = CustomStruct(finalResult: tempResult)
                return String(tempResult[range])
            }
            let finalResult = matchedStrings.joined(separator: " + ")
            return finalResult
        } catch {
            return nil
        }
    }
}

extension String {
    func matchAll1(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else {
            return []
        }
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: count))
        return matches.map { match in
            (0..<match.numberOfRanges).map {
                let rangeBounds = match.range(at: $0)
                guard let range = Range(rangeBounds, in: self) else {
                    return ""
                }
                return String(self[range])
            }
        }
    }
    
    func matchFirst1(regex: String) -> String? {
        guard let match = self.matchAll1(regex: regex).first else {
            return nil
        }
        return match.last
    }
}

struct CustomStruct {
    let numbers: [Int]
    let letters: [Character]
    
    init(finalResult: String) {
        let components = finalResult.components(separatedBy: "\"")
        var parsedNumbers = [Int]()
        var parsedLetters = [Character]()
        for component in components {
            let trimmedComponent = component.trimmingCharacters(in: .whitespacesAndNewlines)
            if let number = Int(trimmedComponent) {
                parsedNumbers.append(number)
            } else if trimmedComponent.count == 3, let letter = trimmedComponent.first, trimmedComponent.first == trimmedComponent.last, letter == "'" {
                parsedLetters.append(trimmedComponent[trimmedComponent.index(after: trimmedComponent.startIndex)])
            }
        }
        numbers = parsedNumbers
        letters = parsedLetters
    }
    
    var string: String {
        let numbersString = numbers.map { String($0) }.joined(separator: ", ")
        let lettersString = letters.map { String($0) }.joined(separator: ", ")
        return "Numbers: [\(numbersString)], Letters: [\(lettersString)]"
    }
    
    var attributedDescription: NSAttributedString {
        let result = NSMutableAttributedString(string: "Numbers: [")
        for (index, number) in numbers.enumerated() {
            let numberString = NSAttributedString(string: "\(number)", attributes: [.foregroundColor: UIColor.green])
            result.append(numberString)
            if index != numbers.count - 1 {
                result.append(NSAttributedString(string: ", "))
            }
        }
        result.append(NSAttributedString(string: "], Letters: [\(letters.map { String($0) }.joined(separator: ", "))]"))
        return result
    }
}

struct ChemicalElement1: Identifiable {
    var id: Int
    var text: String
    var isReactant: Bool
}

struct CustomTextWithBaselineOffset1: View {
    let text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        let regex = try! NSRegularExpression(pattern: "[0-9]+")
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        var currentIndex = text.startIndex
        var views: [Text] = []
        for match in matches {
            let range = Range(match.range, in: text)!
            let prefix = text[currentIndex..<range.lowerBound]
            let matchedSubstring = text[range]
            currentIndex = range.upperBound
            if !prefix.isEmpty {
                views.append(Text(prefix))
            }
            views.append(Text(matchedSubstring).baselineOffset(-10).foregroundColor(.phostext).font(.subheadline))
        }
        if currentIndex < text.endIndex {
            let remainingSuffix = text[currentIndex..<text.endIndex]
            views.append(Text(remainingSuffix))
        }
        return HStack(spacing: 0) {
            ForEach(views.indices, id: \.self) { index in
                views[index].font(.headline).foregroundColor(.phostext)
            }
        }
    }
}

struct FormattedTextView1: View {
    var inputText: String
    @Binding var reactantCount: Int
    
    var body: some View {
        ZStack {
            Text(inputText)
                .foregroundColor(.clear)
                .onTapGesture {
                    if let number = inputText.extractNumber1() {
                        reactantCount = number
                    }
                }
            
            Spacer()
            
            formatText(inputText)
                .font(.title)
        }
    }
    
    func formatText(_ inputText: String) -> Text {
        let regexPattern = #"(\d+)"#
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: [])
            let range = NSRange(location: 0, length: inputText.utf16.count)
            var formattedText = Text("")
            var currentIndex = inputText.startIndex
            for (index, match) in regex.matches(in: inputText, options: [], range: range).enumerated() {
                let matchRange = Range(match.range, in: inputText)!
                formattedText = formattedText + Text(inputText[currentIndex..<matchRange.lowerBound])
                    .font(.headline)
                let number = String(inputText[matchRange])
                if index == 0 {
                    formattedText = formattedText + Text(number).foregroundColor(.green).bold()
                        .font(.headline)
                } else {
                    formattedText = formattedText.baselineOffset(-1) + Text(number).baselineOffset(-5)
                        .font(.subheadline)
                }
                currentIndex = matchRange.upperBound
            }
            formattedText = formattedText + Text(inputText[currentIndex..<inputText.endIndex])
                .font(.headline)
            return formattedText
        } catch {
            print("Error creating regex: \(error.localizedDescription)")
        }
        return Text(inputText)
    }
}

extension String {
    func extractNumber1() -> Int? {
        let components = self.components(separatedBy: CharacterSet.decimalDigits.inverted)
        return components.compactMap { Int($0) }.first
    }
}

#Preview {
    BalancerView()
}
