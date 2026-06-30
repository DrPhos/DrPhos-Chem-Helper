//
//  PeriodicTableData.swift
//  DrPhos Chem Helper
//
//  Created by Monte Helm on 2/15/25.
//

import Foundation

struct PeriodicTableData {
    
    static let atomicMasses: [String: Double] = [
        "H": 1.0080,
        "He": 4.002602,
        "Li": 6.94,
        "Be": 9.0121831,
        "B": 10.81,
        "C": 12.011,
        "N": 14.007,
        "O": 15.999,
        "F": 18.998403162,
        "Ne": 20.1797,
        "Na": 22.98976928,
        "Mg": 24.305,
        "Al": 26.9815384,
        "Si": 28.085,
        "P": 30.973761998,
        "S": 32.06,
        "Cl": 35.45,
        "Ar": 39.95,
        "K": 39.0983,
        "Ca": 40.078,
        "Sc": 44.955907,
        "Ti": 47.867,
        "V": 50.9415,
        "Cr": 51.9961,
        "Mn": 54.938043,
        "Fe": 55.845,
        "Co": 58.933194,
        "Ni": 58.6934,
        "Cu": 63.546,
        "Zn": 65.38,
        "Ga": 69.723,
        "Ge": 72.630,
        "As": 74.921595,
        "Se": 78.971,
        "Br": 79.904,
        "Kr": 83.798,
        "Rb": 85.4678,
        "Sr": 87.62,
        "Y": 88.905838,
        "Zr": 91.222,
        "Nb": 92.90637,
        "Mo": 95.95,
        "Tc": 97, // Note: This is a placeholder as Technetium has no stable isotopes
        "Ru": 101.07,
        "Rh": 102.90549,
        "Pd": 106.42,
        "Ag": 107.8682,
        "Cd": 112.414,
        "In": 114.818,
        "Sn": 118.710,
        "Sb": 121.760,
        "Te": 127.60,
        "I": 126.90447,
        "Xe": 131.293,
        "Cs": 132.90545196,
        "Ba": 137.327,
        "La": 138.90547,
        "Ce": 140.116,
        "Pr": 140.90766,
        "Nd": 144.242,
        "Pm": 145, // Note: This is a placeholder as Promethium has no stable isotopes
        "Sm": 150.36,
        "Eu": 151.964,
        "Gd": 157.249,
        "Tb": 158.925354,
        "Dy": 162.500,
        "Ho": 164.930329,
        "Er": 167.259,
        "Tm": 168.934219,
        "Yb": 173.045,
        "Lu": 174.96669,
        "Hf": 178.486,
        "Ta": 180.94788,
        "W": 183.84,
        "Re": 186.207,
        "Os": 190.23,
        "Ir": 192.217,
        "Pt": 195.084,
        "Au": 196.966570,
        "Hg": 200.592,
        "Tl": 204.38,
        "Pb": 207.2,
        "Bi": 208.98040,
        "Po": 209, // Note: This is a placeholder as Polonium has no stable isotopes
        "At": 210, // Note: This is a placeholder as Astatine has no stable isotopes
        "Rn": 222, // Note: This is a placeholder as Radon has no stable isotopes
        "Fr": 223, // Note: This is a placeholder as Francium has no stable isotopes
        "Ra": 226, // Note: This is a placeholder as Radium has no stable isotopes
        "Ac": 227, // Note: This is a placeholder as Actinium has no stable isotopes
        "Th": 232.0377,
        "Pa": 231.03588,
        "U": 238.02891,
        "Np": 237, // Note: This is a placeholder as Neptunium has no stable isotopes
        "Pu": 244, // Note: This is a placeholder as Plutonium has no stable isotopes
        "Am": 243, // Note: This is a placeholder as Americium has no stable isotopes
        "Cm": 247, // Note: This is a placeholder as Curium has no stable isotopes
        "Bk": 247, // Note: This is a placeholder as Berkelium has no stable isotopes
        "Cf": 251, // Note: This is a placeholder as Californium has no stable isotopes
        "Es": 252, // Note: This is a placeholder as Einsteinium has no stable isotopes
        "Fm": 257, // Note: This is a placeholder as Fermium has no stable isotopes
        "Md": 258, // Note: This is a placeholder as Mendelevium has no stable isotopes
        "No": 259, // Note: This is a placeholder as Nobelium has no stable isotopes
        "Lr": 262, // Note: This is a placeholder as Lawrencium has no stable isotopes
        "Rf": 267, // Note: This is a placeholder as Rutherfordium has no stable isotopes
        "Db": 270, // Note: This is a placeholder as Dubnium has no stable isotopes
        "Sg": 269, // Note: This is a placeholder as Seaborgium has no stable isotopes
        "Bh": 270, // Note: This is a placeholder as Bohrium has no stable isotopes
        "Hs": 270, // Note: This is a placeholder as Hassium has no stable isotopes
        "Mt": 278, // Note: This is a placeholder as Meitnerium has no stable isotopes
        "Ds": 281, // Note: This is a placeholder as Darmstadtium has no stable isotopes
        "Rg": 281, // Note: This is a placeholder as Roentgenium has no stable isotopes
        "Cn": 285, // Note: This is a placeholder as Copernicium has no stable isotopes
        "Nh": 286, // Note: This is a placeholder as Nihonium has no stable isotopes
        "Fl": 289, // Note: This is a placeholder as Flerovium has no stable isotopes
        "Mc": 289, // Note: This is a placeholder as Moscovium has no stable isotopes
        "Lv": 293, // Note: This is a placeholder as Livermorium has no stable isotopes
        "Ts": 294, // Note: This is a placeholder as Tennessine has no stable isotopes
        "Og": 294  // Note: This is a placeholder as Oganesson has no stable isotopes
    ]
    
    static let atomicNumbers: [String: Int] = [
        "H": 1,
        "He": 2,
        "Li": 3,
        "Be": 4,
        "B": 5,
        "C": 6,
        "N": 7,
        "O": 8,
        "F": 9,
        "Ne": 10,
        "Na": 11,
        "Mg": 12,
        "Al": 13,
        "Si": 14,
        "P": 15,
        "S": 16,
        "Cl": 17,
        "Ar": 18,
        "K": 19,
        "Ca": 20,
        "Sc": 21,
        "Ti": 22,
        "V": 23,
        "Cr": 24,
        "Mn": 25,
        "Fe": 26,
        "Co": 27,
        "Ni": 28,
        "Cu": 29,
        "Zn": 30,
        "Ga": 31,
        "Ge": 32,
        "As": 33,
        "Se": 34,
        "Br": 35,
        "Kr": 36,
        "Rb": 37,
        "Sr": 38,
        "Y": 39,
        "Zr": 40,
        "Nb": 41,
        "Mo": 42,
        "Tc": 43,
        "Ru": 44,
        "Rh": 45,
        "Pd": 46,
        "Ag": 47,
        "Cd": 48,
        "In": 49,
        "Sn": 50,
        "Sb": 51,
        "Te": 52,
        "I": 53,
        "Xe": 54,
        "Cs": 55,
        "Ba": 56,
        "La": 57,
        "Ce": 58,
        "Pr": 59,
        "Nd": 60,
        "Pm": 61,
        "Sm": 62,
        "Eu": 63,
        "Gd": 64,
        "Tb": 65,
        "Dy": 66,
        "Ho": 67,
        "Er": 68,
        "Tm": 69,
        "Yb": 70,
        "Lu": 71,
        "Hf": 72,
        "Ta": 73,
        "W": 74,
        "Re": 75,
        "Os": 76,
        "Ir": 77,
        "Pt": 78,
        "Au": 79,
        "Hg": 80,
        "Tl": 81,
        "Pb": 82,
        "Bi": 83,
        "Po": 84,
        "At": 85,
        "Rn": 86,
        "Fr": 87,
        "Ra": 88,
        "Ac": 89,
        "Th": 90,
        "Pa": 91,
        "U": 92,
        "Np": 93,
        "Pu": 94,
        "Am": 95,
        "Cm": 96,
        "Bk": 97,
        "Cf": 98,
        "Es": 99,
        "Fm": 100,
        "Md": 101,
        "No": 102,
        "Lr": 103,
        "Rf": 104,
        "Db": 105,
        "Sg": 106,
        "Bh": 107,
        "Hs": 108,
        "Mt": 109,
        "Ds": 110,
        "Rg": 111,
        "Cn": 112,
        "Nh": 113,
        "Fl": 114,
        "Mc": 115,
        "Lv": 116,
        "Ts": 117,
        "Og": 118
    ]
        
    // Basic element validation
    static func isValidElement(_ element: String) -> Bool {
        return atomicMasses[element] != nil
    }

    // Comprehensive formula validation
    static func validateFormula(_ formula: String) -> (isValid: Bool, invalidElement: String?) {
        // Check for empty formula
        if formula.isEmpty { return (true, nil) }
        
        // Check for lowercase first character
        if let firstChar = formula.first, firstChar.isLowercase {
            return (false, String(firstChar))
        }
        
        // Check for valid elements
        var currentElement = ""
        var index = formula.startIndex
        
        while index < formula.endIndex {
            let char = formula[index]
            
            if char.isLetter {
                if char.isUppercase {
                    if !currentElement.isEmpty {
                        if !isValidElement(currentElement) {
                            return (false, currentElement)
                        }
                        currentElement = ""
                    }
                    currentElement = String(char)
                } else {
                    currentElement += String(char)
                }
            } else if char.isNumber {
                if !currentElement.isEmpty {
                    if !isValidElement(currentElement) {
                        return (false, currentElement)
                    }
                    currentElement = ""
                }
            }
            index = formula.index(after: index)
        }
        
        // Check final element
        if !currentElement.isEmpty {
            if !isValidElement(currentElement) {
                return (false, currentElement)
            }
        }
        
        return (true, nil)
    }

    // Get atomic mass for element
    static func getMass(for element: String) -> Double {
        return atomicMasses[element] ?? 0.0
    }

    // Get atomic number for element
    static func getAtomicNumber(for element: String) -> Int {
        return atomicNumbers[element] ?? 0
    }
    
}
