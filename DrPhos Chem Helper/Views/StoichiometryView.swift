//
//  StoichiometryView.swift
//  DrPhosChemRedsign
//
//  Created by Monte Helm on 7/25/25.
//


//  ContentView.swift
//  stoich_newtry_062324
//
//  Created by Monte Helm on 6/23/24.
//

import SwiftUI


struct StoichiometryView:View{
    @StateObject private var viewModel=CompoundsViewModel()
    @State private var compoundFormula: String = ""
    @State private var inputMode:InputMode = .grams
    @State private var calculationComplete = false
    @State private var showCompoundEntry = false
    @State private var isEditingAmount = false
    
    enum InputMode{
        case grams
        case moles
    }

    var body:some View{
        
        VStack{
            
            DrPhosSectionHeader(title: "Stoichiometry")
                .fontWeight(.bold)
            
            HStack{
                Spacer()
                CustomButton(title:"Reactant",backgroundColor:.black){
                    viewModel.addReactant(formula:compoundFormula)
                    compoundFormula=""
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.phostext, lineWidth: 1)
                )

                Button(action: {
                    showCompoundEntry = true
                }) {
                    Text(compoundFormula.isEmpty ? "compound" : compoundFormula)
                        .foregroundColor(compoundFormula.isEmpty ? .gray : .primary)
                        .frame(maxWidth: 175)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.phostext, lineWidth: 1)
                        )
                }

                CustomButton(title:"Product",backgroundColor:.black){
                    viewModel.addProduct(formula:compoundFormula)
                    compoundFormula=""
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.phostext, lineWidth: 1)
                )

                Spacer()
            }
            
            NumbersView1(compoundFormula: $compoundFormula)
                .padding(.top, 10)
            
            if viewModel.compounds.contains(where:{$0.formula.isEmpty==false}){
                Picker("Input Mode",selection:$inputMode){
                    Text("Enter Grams").tag(InputMode.grams)
                    Text("Enter Moles").tag(InputMode.moles)
                }
                .pickerStyle(SegmentedPickerStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.phostext, lineWidth: 1)
                )
                .frame(width:300)
                .padding()
                .onChange(of:inputMode){
                    calculationComplete = false
                }

                if isEditingAmount {
                    Button("Done") {
                        isEditingAmount = false
                        UIApplication.shared.endEditing()
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            VStack(alignment: .center, content: {
                
                ScrollView(.horizontal){
                    VStack{
                        HStack{
                            CompoundView(
                                viewModel:viewModel,
                                compounds:$viewModel.compounds,
                                inputMode:$inputMode,
                                areFieldsEditable:.constant(true),
                                calculationComplete:$calculationComplete,
                                isEditingAmount: $isEditingAmount,
                                conditionType:conditionType()
                            )
                        }
                    }
                }
            })
            .frame(maxWidth: 650)
            
            HStack{
                CustomButton(title:"Calculate",backgroundColor:.seven){
                    viewModel.recordEnteredAmounts(inputMode:inputMode)
                    stoichiometry()
                    calculationComplete=true
                }
                CustomButton(title:"Clear Numbers",backgroundColor: .phosyellow1){
                    viewModel.clearEnteredAndCalculatedValues()
                    calculationComplete=false
                }
                CustomButton(title:"Clear All",backgroundColor:.phosred1){
                    viewModel.clearCompounds()
                    compoundFormula = ""
                    calculationComplete=false
                    
                }
            }
            .padding(.top)
            
           Spacer()
            
           Divider()
               .padding()
           
            PeriodicTableView(compoundFormula: $compoundFormula)
        }
        .sheet(isPresented: $showCompoundEntry) {
            CompoundEntry(compoundFormula: $compoundFormula, isPresented: $showCompoundEntry)
        }
//        .padding(.top, -50)
    }

    private var clearButtonOverlay: some View {
        HStack {
            Spacer()
            Button(action: {
                compoundFormula = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 10)
            .opacity(compoundFormula.isEmpty ? 0 : 1)
        }
    }

    func stoichiometry(){
        let adjustedMoles=viewModel.compounds.compactMap{compound->(index:Int,value:Double)?in
            guard !compound.formula.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  compound.molarMass.isFinite,
                  compound.molarMass > 0,
                  compound.coefficient > 0,
                  let enteredMoles=Double(compound.enteredMoles),
                  enteredMoles.isFinite,
                  enteredMoles>0 else{
                return nil
            }
            let adjustedValue = enteredMoles / Double(compound.coefficient)
            guard adjustedValue.isFinite else { return nil }
            return(viewModel.compounds.firstIndex(where:{$0.id==compound.id})!,adjustedValue)
        }
        
        guard let minMolesData=adjustedMoles.min(by:{$0.value<$1.value})else{
            print("No valid moles found.")
            return
        }
        
        let minMoles=minMolesData.value
        let limitingIndex=minMolesData.index
        
        for i in viewModel.compounds.indices{
            guard !viewModel.compounds[i].formula.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  viewModel.compounds[i].molarMass.isFinite,
                  viewModel.compounds[i].molarMass > 0 else {
                viewModel.compounds[i].calculatedMoles = ""
                viewModel.compounds[i].calculatedGrams = ""
                continue
            }
            let calculatedMolesValue=minMoles*Double(viewModel.compounds[i].coefficient)
            guard calculatedMolesValue.isFinite else { continue }
            viewModel.compounds[i].calculatedMoles=String(format:"%.4f",calculatedMolesValue)
            
            let calculatedGramsValue=calculatedMolesValue*viewModel.compounds[i].molarMass
            guard calculatedGramsValue.isFinite else { continue }
            viewModel.compounds[i].calculatedGrams=String(format:"%.4f",calculatedGramsValue)
            
            viewModel.compounds[i].isLimiting=(i==limitingIndex)
            
            if let enteredGrams=Double(viewModel.compounds[i].enteredGrams),enteredGrams>calculatedGramsValue{
                viewModel.compounds[i].excessGrams=String(format:"%.4f",enteredGrams-calculatedGramsValue)
            }else{
                viewModel.compounds[i].excessGrams=""
            }
            
            if let enteredMoles=Double(viewModel.compounds[i].enteredMoles),enteredMoles>calculatedMolesValue{
                viewModel.compounds[i].excessMoles=String(format:"%.4f",enteredMoles-calculatedMolesValue)
            }else{
                viewModel.compounds[i].excessMoles=""
            }
        }
    }

    func conditionType()->Int{
        var reactants=0
        var products=0
        
        for compound in viewModel.compounds{
            if compound.isReactant&&(Double(compound.enteredGrams) ?? 0 > 0 || Double(compound.enteredMoles) ?? 0 > 0){
                reactants += 1
            }else if !compound.isReactant && (Double(compound.enteredGrams) ?? 0 > 0 || Double(compound.enteredMoles) ?? 0 > 0){
                products+=1
            }
        }
        
        if reactants==1&&products==0{
            return 1
        }else if reactants>1&&products==0{
            return 2
        }else if reactants==0&&products==1{
            return 3
        }else if reactants>0&&products>0{
            return 4
        }
        
        return 0
    }
}

struct CompoundView:View{
    var viewModel:CompoundsViewModel
    @State private var activeKeyboardField: Binding<String>?
    @Binding var compounds:[Compound]
    @Binding var inputMode: StoichiometryView.InputMode
    @Binding var areFieldsEditable:Bool
    @Binding var calculationComplete:Bool
    @Binding var isEditingAmount: Bool
    var conditionType:Int

    var body:some View{
        
        HStack{
            
            ForEach(compounds.indices,id:\.self){index in
                if compounds[index].isReactant{
                    HStack{
                        
                        if index>0{
                            Text("+")
                                .font(.title)
                        }
                        VStack{
                            VStack(alignment:.center){
                                Text(String(format:"%.2f g/mol",compounds[index].molarMass))
                                    .font(.subheadline)
                                HStack{
                                    Picker(
                                        "Coefficient",
                                        selection: coefficientBinding(for: compounds[index].id)
                                    ) {
                                        ForEach(1..<21){
                                            Text("\($0)").tag($0)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .accentColor(.phosred1)
                                    .padding(.leading,-10)
                                    
                                    Text(compounds[index].formula)
                                        .padding(.leading,-15)
                                }
                                if inputMode == .grams{
                                    let gramsBinding = amountBinding(for: compounds[index].id, kind: .grams)
                                    HStack{
                                        TextField(
                                            "grams",
                                            text: gramsBinding,
                                            onEditingChanged: { isEditing in
                                                activeKeyboardField = isEditing ? gramsBinding : nil
                                                isEditingAmount = isEditing
                                            }
                                        )
                                            .textFieldStyle(.roundedBorder)
                                            .keyboardType(.decimalPad)
                                            .disabled(calculationComplete)
                                        Text("g")
                                    }
                                }else{
                                    let molesBinding = amountBinding(for: compounds[index].id, kind: .moles)
                                    HStack{
                                        TextField(
                                            "moles",
                                            text: molesBinding,
                                            onEditingChanged: { isEditing in
                                                activeKeyboardField = isEditing ? molesBinding : nil
                                                isEditingAmount = isEditing
                                            }
                                        )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.phostext, lineWidth: 1)
                                            )
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .keyboardType(.decimalPad)
                                            .disabled(calculationComplete)
                                        Text("mol")
                                    }
                                }
                            }
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(RoundedRectangle(cornerRadius:10).stroke())
                            if calculationComplete{
                                if conditionType==1{
                                    VStack(alignment:.center){
                                        if !(compounds[index].enteredGrams.isEmpty || Double(compounds[index].enteredGrams) == 0) || !(compounds[index].enteredMoles.isEmpty || Double(compounds[index].enteredMoles) == 0){
                                            Text("Amount")
                                                .font(.callout)
                                                .underline()
                                                .padding(.bottom,1)
                                            GramsAndMolesTextView(
                                                calculatedGrams:.constant(Double(compounds[index].calculatedGrams) ?? 0.0),
                                                calculatedMoles:.constant(Double(compounds[index].calculatedMoles) ?? 0.0)
                                            )
                                        }
                                        if (compounds[index].enteredGrams.isEmpty||Double(compounds[index].enteredGrams)==0)||(compounds[index].enteredMoles.isEmpty||Double(compounds[index].enteredMoles)==0){
                                            Text("Needed")
                                                .font(.callout)
                                                .underline()
                                                .padding(.bottom,1)
                                            GramsAndMolesTextView(
                                                calculatedGrams:.constant(Double(compounds[index].calculatedGrams) ?? 0.0),
                                                calculatedMoles:.constant(Double(compounds[index].calculatedMoles) ?? 0.0)
                                            )
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius:10)
                                            .stroke(Color.gray)
                                    )
                                }
                                if conditionType==2{
                                    VStack(alignment:.center){
                                        if compounds[index].isLimiting{
                                            Text("Limiting")
                                                .font(.callout)
                                                .underline()
                                                .padding(.bottom,1)
                                            GramsAndMolesTextView(
                                                calculatedGrams:.constant(Double(compounds[index].calculatedGrams) ?? 0.0),
                                                calculatedMoles:.constant(Double(compounds[index].calculatedMoles) ?? 0.0)
                                            )
                                            Text("(completely reacted)")
                                                .font(.footnote)
                                                .foregroundColor(.phosred1)
                                        }
                                        if !compounds[index].isLimiting&&compounds[index].isReactant{
                                            VStack{
                                                HStack{
                                                    Text(String(format:"%.2f g or",Double(compounds[index].enteredGrams) ?? 0.0)) +
                                                    Text(String(format:" %.2f mol",Double(compounds[index].enteredMoles) ?? 0.0))
                                                }
                                                .font(.footnote)
                                                .foregroundColor(.phosblue1)
                                                HStack{
                                                    VStack{
                                                        Text("Needed")
                                                            .font(.callout)
                                                            .underline()
                                                            .padding(.bottom,1)
                                                        GramsAndMolesTextView(
                                                            calculatedGrams:.constant(Double(compounds[index].calculatedGrams) ?? 0.0),
                                                            calculatedMoles:.constant(Double(compounds[index].calculatedMoles) ?? 0.0)
                                                        )
                                                    }
                                                    Divider()
                                                        .frame(maxHeight:50)
                                                        .padding(.horizontal,2)
                                                    VStack{
                                                        Text("Excess")
                                                            .font(.callout)
                                                            .underline()
                                                            .padding(.bottom,1)
                                                        GramsAndMolesTextView(
                                                            calculatedGrams:.constant(Double(compounds[index].excessGrams) ?? 0.0),
                                                            calculatedMoles:.constant(Double(compounds[index].excessMoles) ?? 0.0)
                                                        )
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius:10)
                                            .stroke(Color.gray)
                                    )
                                }
                                if conditionType==3{
                                    VStack(alignment:.center){
                                        Text("Needed")
                                            .font(.callout)
                                            .underline()
                                            .padding(.bottom,1)
                                        GramsAndMolesTextView(
                                            calculatedGrams:.constant(Double(compounds[index].calculatedGrams) ?? 0.0),
                                            calculatedMoles:.constant(Double(compounds[index].calculatedMoles) ?? 0.0)
                                        )
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius:10)
                                            .stroke(Color.gray)
                                    )
                                }
                                if conditionType==4{
                                    Text("Can not calculate\nwhen amounts are\nentered for both a\nreactant and product")
                                        .padding()
                                        .multilineTextAlignment(.center)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius:10)
                                                .stroke(Color.gray)
                                        )
                                        .foregroundColor(.phosred1)
                                }
                            }
                        }
                    }
                }
                if index==compounds.filter({$0.isReactant}).count-1 {
                    Text("→")
                        .font(.largeTitle)
                }
            }
            ForEach(compounds.indices,id:\.self){index in
                if !compounds[index].isReactant{
                    HStack(alignment:.center){
                        if index>compounds.filter({$0.isReactant}).count {
                            Text("+")
                                .font(.title)
                        }
                        VStack{
                            VStack(alignment:.center){
                                Text(String(format:"%.2f g/mol",compounds[index].molarMass))
                                    .font(.subheadline)
                                HStack{
                                    Picker(
                                        "Coefficient",
                                        selection: coefficientBinding(for: compounds[index].id)
                                    ) {
                                        ForEach(1..<21){
                                            Text("\($0)").tag($0)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .accentColor(.phosred1)
                                    .padding(.leading,-10)
                                    Text(compounds[index].formula)
                                        .padding(.leading,-15)
                                }
                                if inputMode == .grams{
                                    let gramsBinding = amountBinding(for: compounds[index].id, kind: .grams)
                                    HStack{
                                        TextField(
                                            "grams",
                                            text: gramsBinding,
                                            onEditingChanged: { isEditing in
                                                activeKeyboardField = isEditing ? gramsBinding : nil
                                                isEditingAmount = isEditing
                                            }
                                        )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.phostext, lineWidth: 1)
                                            )
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .keyboardType(.decimalPad)
                                            .disabled(calculationComplete)
                                        Text("g")
                                    }
                                }else{
                                    let molesBinding = amountBinding(for: compounds[index].id, kind: .moles)
                                    HStack{
                                        TextField(
                                            "moles",
                                            text: molesBinding,
                                            onEditingChanged: { isEditing in
                                                activeKeyboardField = isEditing ? molesBinding : nil
                                                isEditingAmount = isEditing
                                            }
                                        )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.phostext, lineWidth: 1)
                                            )
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .keyboardType(.decimalPad)
                                            .disabled(calculationComplete)
                                        Text("mol")
                                    }
                                }
                            }
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(RoundedRectangle(cornerRadius:10).stroke())
                            if calculationComplete{
                                if conditionType==1{
                                    VStack(alignment:.center){
                                        Text("Formed")
                                            .font(.callout)
                                            .underline()
                                            .padding(.bottom,1)
                                        GramsAndMolesTextView(
                                            calculatedGrams:.constant(Double(compounds[index].calculatedGrams) ?? 0.0),
                                            calculatedMoles:.constant(Double(compounds[index].calculatedMoles) ?? 0.0)
                                        )
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius:10)
                                            .stroke(Color.gray)
                                    )
                                }
                                if conditionType==2{
                                    VStack(alignment:.center){
                                        Text("Formed")
                                            .font(.callout)
                                            .underline()
                                            .padding(.bottom,1)
                                        GramsAndMolesTextView(
                                            calculatedGrams:.constant(Double(compounds[index].calculatedGrams) ?? 0.0),
                                            calculatedMoles:.constant(Double(compounds[index].calculatedMoles) ?? 0.0)
                                        )
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius:10)
                                            .stroke(Color.gray)
                                    )
                                }
                                if conditionType==3{
                                    VStack(alignment:.center){
                                        if !(compounds[index].enteredGrams.isEmpty || Double(compounds[index].enteredGrams) == 0) || !(compounds[index].enteredMoles.isEmpty || Double(compounds[index].enteredMoles) == 0){
                                            Text("Amount")
                                                .font(.callout)
                                                .underline()
                                                .padding(.bottom,1)
                                            GramsAndMolesTextView(
                                                calculatedGrams:.constant(Double(compounds[index].calculatedGrams) ?? 0.0),
                                                calculatedMoles:.constant(Double(compounds[index].calculatedMoles) ?? 0.0)
                                            )
                                        }
                                        if (compounds[index].enteredGrams.isEmpty||Double(compounds[index].enteredGrams)==0)||(compounds[index].enteredMoles.isEmpty||Double(compounds[index].enteredMoles)==0){
                                            Text("Needed")
                                                .font(.callout)
                                                .underline()
                                                .padding(.bottom,1)
                                            GramsAndMolesTextView(
                                                calculatedGrams:.constant(Double(compounds[index].calculatedGrams) ?? 0.0),
                                                calculatedMoles:.constant(Double(compounds[index].calculatedMoles) ?? 0.0)
                                            )
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius:10)
                                            .stroke(Color.gray)
                                    )
                                }
                                if conditionType==4{
                                    Text("Can not calculate\nwhen amounts are\nentered for both a\nreactant and product")
                                        .padding()
                                        .multilineTextAlignment(.center)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius:10)
                                                .stroke(Color.gray)
                                        )
                                        .foregroundColor(.phosred1)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func amountBinding(for compoundID: UUID, kind: StoichiometryAmountKind) -> Binding<String> {
        Binding(
            get: {
                guard let compound = compounds.first(where: { $0.id == compoundID }) else { return "" }
                return kind == .grams ? compound.enteredGrams : compound.enteredMoles
            },
            set: { newValue in
                guard let index = compounds.firstIndex(where: { $0.id == compoundID }) else { return }
                guard isValidAmountInput(newValue) else { return }

                if kind == .grams {
                    guard compounds[index].enteredGrams != newValue else { return }
                    compounds[index].enteredGrams = newValue
                } else {
                    guard compounds[index].enteredMoles != newValue else { return }
                    compounds[index].enteredMoles = newValue
                }
            }
        )
    }

    private func isValidAmountInput(_ value: String) -> Bool {
        if value.isEmpty || value == "." { return true }
        if let number = Double(value) { return number.isFinite && number >= 0 }

        let parts = value.lowercased().split(separator: "e", omittingEmptySubsequences: false)
        guard parts.count == 2,
              let mantissa = Double(parts[0]),
              mantissa.isFinite,
              mantissa >= 0 else { return false }

        let exponent = String(parts[1])
        return exponent.isEmpty || exponent == "+" || exponent == "-"
    }

    private func coefficientBinding(for compoundID: UUID) -> Binding<Int> {
        Binding(
            get: {
                compounds.first(where: { $0.id == compoundID })?.coefficient ?? 1
            },
            set: { newCoefficient in
                viewModel.updateCoefficient(compoundID: compoundID, coefficient: newCoefficient)
                calculationComplete = false
            }
        )
    }
}

enum StoichiometryAmountKind: Hashable {
    case grams
    case moles
}

struct GramsAndMolesTextView:View{
    @Binding var calculatedGrams:Double
    @Binding var calculatedMoles:Double

    var body:some View{
        VStack{
            Text(String(format:"%.2f g",calculatedGrams))
                .font(.footnote)
                .foregroundColor(.phosblue1)
            Text("or")
                .font(.footnote)
                .foregroundColor(.phosblue1)
            Text(String(format:"%.2f mol",calculatedMoles))
                .font(.footnote)
                .foregroundColor(.phosblue1)
        }
    }
}

struct CustomButton:View{
    var title:String
    var backgroundColor:Color
    var action:()->Void

    var body:some View{
        Button(action:action){
            Text(title)
                .padding(6)
                .background(backgroundColor)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

#Preview{
    StoichiometryView()
}
