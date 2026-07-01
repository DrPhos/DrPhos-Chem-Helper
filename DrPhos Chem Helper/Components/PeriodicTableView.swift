import SwiftUI
import Foundation

struct PeriodicTableView: View {
    
    let numberOfRows = 9
    let numberOfColumns = 18
    let buttonWidth: CGFloat = 35
    
    let hiddenButtons: [[Int]] = [
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
        [2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
        [2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
        [],
        [],
        [],
        [],
        [0, 1, 16, 17],
        [0, 1, 16, 17]
    ]

    let buttonLabels: [[String]] = [
        ["H", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "He"],
        ["Li", "Be", "", "", "", "", "", "", "", "", "", "", "B", "C", "N", "O", "F", "Ne"],
        ["Na", "Mg", "", "", "", "", "", "", "", "", "", "", "Al", "Si", "P", "S", "Cl", "Ar"],
        ["K", "Ca", "Sc", "Ti", "V", "Cr", "Mn", "Fe", "Co", "Ni", "Cu", "Zn", "Ga", "Ge", "As", "Se", "Br", "Kr"],
        ["Rb", "Sr", "Y", "Zr", "Nb", "Mo", "Tc", "Ru", "Rh", "Pd", "Ag", "Cd", "In", "Sn", "Sb", "Te", "I", "Xe"],
        ["Cs", "Ba", "Lu", "Hf", "Ta", "W", "Re", "Os", "Ir", "Pt", "Au", "Hg", "Tl", "Pb", "Bi", "Po", "At", "Rn"],
        ["Fr", "Ra", "Lr", "Rf", "Db", "Sg", "Bh", "Hs", "Mt", "Ds", "Rg", "Cn", "Nh", "Fl", "Mc", "Lv", "Ts", "Og"],
        ["", "", "La", "Ce", "Pr", "Nd", "Pm", "Sm", "Eu", "Gd", "Tb", "Dy", "Ho", "Er", "Tm", "Yb", ""],
        ["", "", "Ac", "Th", "Pa", "U", "Np", "Pu", "Am", "Cm", "Bk", "Cf", "Es", "Fm", "Md", "No", ""]
    ]

    @Binding var compoundFormula: String

    func handleButtonTap(_ buttonLabel: String) {
        if buttonLabel == "⌫" {
            compoundFormula = String(compoundFormula.dropLast())
        } else {
            compoundFormula += buttonLabel
        }
    }

    var body: some View {
        VStack(spacing: 5) {
            GeometryReader { geo in
                ScrollView(.vertical) {
                    HStack {
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            ZStack {
                                PolyatomicIonView(compoundFormula: $compoundFormula)
                                    .padding(.bottom, 270)
                                    .padding(.trailing, 170)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.fixed(buttonWidth), spacing: 1), count: numberOfColumns), spacing: 1) {
                                    ForEach(0..<numberOfRows, id: \.self) { row in
                                        ForEach(0..<numberOfColumns, id: \.self) { column in
                                            if hiddenButtons[row].contains(column) {
                                                Color.clear.frame(width: buttonWidth, height: 35)
                                            } else {
                                                let buttonLabel = buttonLabels[row][column]
                                                Button(action: { handleButtonTap(buttonLabel) }) {
                                                    Text(buttonLabel)
                                                        .frame(width: buttonWidth, height: 35)
                                                        .background(getButtonColor(row: row, column: column))
                                                        .foregroundColor(.white)
                                                        .cornerRadius(10)
                                                }
                                            }
                                        }
                                        .padding(.top, row == 7 ? 8 : 0)
                                        .padding(.leading, row == 7 || row == 8 ? -25 : 0)
                                    }
                                }
                                .padding()
                                .frame(minWidth: sanitizedWidth(geo.size.width))
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Spacer()
                    }
                }
            }
        }
        
    }

    private func sanitizedWidth(_ width: CGFloat) -> CGFloat {
        guard width.isFinite else { return 0 }
        return max(0, width)
    }
    
    func getButtonColor(row: Int, column: Int) -> Color {
        switch column {
        case 0: return .one
        case 1: return .two
        case 2...15 where row == 7 || row == 8: return .five
        case 2...11 where (3...6).contains(row): return .three
        case 12 where (2...6).contains(row),
             13 where (3...6).contains(row),
             14 where (4...6).contains(row),
             15 where (5...6).contains(row),
             16 where row == 6: return .four
        case 17: return .seven
        default: return .six
        }
    }
}

struct PolyatomicIonView: View {
    let numberOfRows = 2
    let numberOfColumns = 6
    let buttonWidth: CGFloat = 45
    let hiddenButtonsInSecondRow = [1, 2, 3]
    
    let buttonLabels: [[String]] = [
        ["NH4", "OH", "NO3", "SO4", "CO3", "PO4"],
        ["CN", "", "", "", "(", ")"]
    ]
    
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
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(buttonWidth), spacing: 1), count: numberOfColumns), spacing: 4) {
                ForEach(0..<numberOfRows, id: \.self) { row in
                    ForEach(0..<numberOfColumns, id: \.self) { column in
                        if row == 1 && hiddenButtonsInSecondRow.contains(column) {
                            Color.clear.frame(width: buttonWidth, height: 35)
                        } else {
                            let buttonLabel = buttonLabels[row][column]
                            Button(action: { handleButtonTap(buttonLabel) }) {
                                if buttonLabel == "NH4" {
                                    NH4Button()
                                } else if buttonLabel == "OH" {
                                    OHButton()
                                } else if buttonLabel == "NO3" {
                                    NO3Button()
                                } else if buttonLabel == "SO4" {
                                    SO4Button()
                                } else if buttonLabel == "CO3" {
                                    CO3Button()
                                } else if buttonLabel == "PO4" {
                                    PO4Button()
                                } else if buttonLabel == "CN" {
                                    CNButton()
                                } else {
                                    Text(buttonLabel)
                                        .lineLimit(1)
                                        .frame(width: buttonWidth, height: 35)
                                        .background(Color.five)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct NH4Button: View {
    var body: some View {
        PolyatomicIonButtonContent(base: "NH", subscriptText: "4", charge: "+")
    }
}

struct OHButton: View {
    var body: some View {
        PolyatomicIonButtonContent(base: "OH", charge: "−")
    }
}

struct NO3Button: View {
    var body: some View {
        PolyatomicIonButtonContent(base: "NO", subscriptText: "3", charge: "−")
    }
}

struct SO4Button: View {
    var body: some View {
        PolyatomicIonButtonContent(base: "SO", subscriptText: "4", charge: "2−")
    }
}

struct CO3Button: View {
    var body: some View {
        PolyatomicIonButtonContent(base: "CO", subscriptText: "3", charge: "2−")
    }
}

struct PO4Button: View {
    var body: some View {
        PolyatomicIonButtonContent(base: "PO", subscriptText: "4", charge: "3−")
    }
}

struct CNButton: View {
    var body: some View {
        PolyatomicIonButtonContent(base: "CN", charge: "−")
    }
}

private struct PolyatomicIonButtonContent: View {
    let base: String
    var subscriptText: String? = nil
    let charge: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(base)
                .font(.caption)

            if let subscriptText {
                Text(subscriptText)
                    .font(.system(size: 8, weight: .regular))
                    .baselineOffset(-3)
            }

            Text(charge)
                .font(.system(size: 8, weight: .regular))
                .baselineOffset(6)
        }
        .lineLimit(1)
        .fixedSize(horizontal: true, vertical: false)
        .frame(width: 45, height: 35, alignment: .center)
        .foregroundColor(.white)
        .background(Color.five)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityName)
    }

    private var accessibilityName: String {
        [base, subscriptText, charge]
            .compactMap { $0 }
            .joined()
    }
}

#Preview {
    PeriodicTableView(compoundFormula: .constant(""))
}
