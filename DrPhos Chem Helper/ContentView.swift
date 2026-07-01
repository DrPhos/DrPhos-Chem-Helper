import SwiftUI

struct ContentView: View {
    let toolAccess: ToolAccess
    @State private var selectedTool: ToolID? = UIDevice.current.userInterfaceIdiom == .pad ? .calculator : nil

    init(toolAccess: ToolAccess = .developmentUnlocked) {
        self.toolAccess = toolAccess
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color("gradientBottom"), Color("gradientTop")]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea()

                NavigationSplitView {
                    VStack {
                        HStack {
                            Spacer()
                            Image("firephos")
                                .resizable()
                                .frame(width: 55, height: 65)
                                .clipShape(Circle())
                                .accessibilityHidden(true)

                            VStack(alignment: .leading) {
                                Text("Dr. Phos'\nChemistry Helper")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.leading, 5)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                
                                
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 20)
                   
                        Divider()
                            .frame(maxWidth: 350)
                            .padding(.horizontal)
                        
                        List(selection: $selectedTool) {
                            ForEach(ToolCategory.allCases) { category in
                                Section(category.rawValue) {
                                    ForEach(ToolID.allCases.filter { $0.category == category }) { tool in
                                        SidebarRow(tool: tool, status: toolAccess.status(for: tool))
                                            .tag(tool)
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color.clear)
                        .scrollContentBackground(.hidden)
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("gradientBottom"), Color("gradientTop")]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                } detail: {
                    detailView(for: selectedTool)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            
            }
            
        }
        
    }

    @ViewBuilder
    func detailView(for tool: ToolID?) -> some View {
        if let tool, !toolAccess.canUse(tool) {
            LockedToolView(tool: tool)
        } else {
            unlockedDetailView(for: tool)
        }
    }

    @ViewBuilder
    private func unlockedDetailView(for tool: ToolID?) -> some View {
        switch tool {
        case .calculator: CalculatorView()
        case .sigFigs: SigFigView()
        case .kinetics: KineticsView()
        case .ph: pHCalculatorView()
        case .combinedReaction: CombinedReactionView()
        case .stoichiometry: StoichiometryView()
        case .molarMass: MolarMassView()
        case .ionic: IonicCompoundBuilderView()
        case .naming: GenChemNamingView()
        case .solutions: SolutionsView()
        case .balancer: BalancerView()
        case .quadratic: QuadradicEquationSolverView()
       
        case .none: ContentUnavailableView("Choose a chemistry tool", systemImage: "atom")
        }
    }
}

struct SidebarRow: View {
    let tool: ToolID
    let status: ToolAccessStatus

    var body: some View {
        HStack {
            Label(tool.rawValue, systemImage: icon(for: tool))
                .foregroundColor(Color("phostext"))
            Spacer()
            Image(systemName: status.isUnlocked ? "chevron.right" : "lock.fill")
                .foregroundColor(.gray)
                .accessibilityHidden(true)
        }
        .frame(minHeight: 44)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(tool.rawValue)
        .accessibilityValue(status.isUnlocked ? "Available" : "Locked")
    }

    func icon(for tool: ToolID) -> String {
        switch tool {
        case .calculator: return "function"
        case .sigFigs: return "number"
        case .kinetics: return "flag.checkered"
        case .ph: return "testtube.2"
        case .combinedReaction: return "arrow.down.circle"
        case .stoichiometry: return "flask"
        case .molarMass: return "atom"
        case .solutions: return "water.waves"
        case .naming: return "pencil"
        case .ionic: return "bolt.circle"
        case .balancer: return "swirl.circle.righthalf.filled"
        case .quadratic: return "x.squareroot"
        
        }
    }
}

private struct LockedToolView: View {
    let tool: ToolID

    var body: some View {
        ContentUnavailableView(
            "\(tool.rawValue) is locked",
            systemImage: "lock.fill",
            description: Text("Purchase access or the full suite to use this tool.")
        )
    }
}

#Preview {
    ContentView()
}

#Preview("Locked tools") {
    ContentView(toolAccess: ToolAccess(includedTools: [.calculator]))
}
