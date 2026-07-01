import Foundation

enum ToolID: String, CaseIterable, Identifiable, Codable {
    case calculator = "Science Calculator"
    case sigFigs = "Sig Fig Counter"
    case molarMass = "Molar Mass Calculator"
    case ionic = "Ionic Compound Builder"
    case naming = "Naming Compounds"
    case combinedReaction = "Reaction Workflow"
    case balancer = "Reaction Balancer"
    case stoichiometry = "Stoichiometry"
    case solutions = "Solution Concentrations"
    case ph = "pH Calculator"
    case kinetics = "Kinetics Calculator"
    case quadratic = "Quadratic Solver"

    var id: String { rawValue }

    var category: ToolCategory {
        switch self {
        case .calculator, .sigFigs, .quadratic: .calculators
        case .molarMass, .ionic, .naming: .compounds
        case .combinedReaction, .balancer, .stoichiometry, .kinetics: .reactions
        case .solutions, .ph: .solutions
        }
    }
}

enum ToolCategory: String, CaseIterable, Identifiable {
    case calculators = "Calculators"
    case compounds = "Compounds"
    case reactions = "Reactions"
    case solutions = "Solutions"
    var id: Self { self }
}

enum ToolAccessStatus: Equatable {
    case included
    case purchased
    case fullSuite
    case development
    case locked

    var isUnlocked: Bool { self != .locked }
}

struct ToolAccess: Equatable {
    var includedTools: Set<ToolID>
    var purchasedTools: Set<ToolID>
    var hasFullSuite: Bool
    var grantsDevelopmentAccess: Bool

    init(
        includedTools: Set<ToolID> = [],
        purchasedTools: Set<ToolID> = [],
        hasFullSuite: Bool = false,
        grantsDevelopmentAccess: Bool = false
    ) {
        self.includedTools = includedTools
        self.purchasedTools = purchasedTools
        self.hasFullSuite = hasFullSuite
        self.grantsDevelopmentAccess = grantsDevelopmentAccess
    }

    func status(for tool: ToolID) -> ToolAccessStatus {
        if grantsDevelopmentAccess { return .development }
        if hasFullSuite { return .fullSuite }
        if includedTools.contains(tool) { return .included }
        if purchasedTools.contains(tool) { return .purchased }
        return .locked
    }

    func canUse(_ tool: ToolID) -> Bool {
        status(for: tool).isUnlocked
    }

    static let developmentUnlocked = ToolAccess(grantsDevelopmentAccess: true)
}
