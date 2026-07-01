import SwiftUI

struct CombinedReactionView: View {
    @StateObject private var compoundsModel = CompoundsViewModel()
    @State private var compoundFormula = ""
    @State private var entrySide: ReactionSide?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DrPhosSectionHeader(title: "Reaction Workflow")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Step 1")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("Enter the Reaction")
                        .font(.title2.weight(.semibold))
                    Text("Add every reactant and product before balancing.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    Button("Add Reactant") {
                        beginEntry(on: .reactant)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Add Product") {
                        beginEntry(on: .product)
                    }
                    .buttonStyle(.borderedProminent)
                }

                ReactionCompoundList(
                    compounds: compoundsModel.compounds,
                    removeCompound: compoundsModel.removeCompound
                )

                Button("Balance Reaction") {}
                    .buttonStyle(.borderedProminent)
                    .tint(.seven)
                    .disabled(!canBalance)
            }
            .frame(maxWidth: 680)
            .padding()
        }
        .sheet(item: $entrySide) { side in
            CompoundEntry(
                compoundFormula: $compoundFormula,
                isPresented: Binding(
                    get: { entrySide != nil },
                    set: { if !$0 { entrySide = nil } }
                ),
                onEnter: { addCompound(on: side) }
            )
        }
    }

    private var canBalance: Bool {
        compoundsModel.compounds.contains(where: \.isReactant)
            && compoundsModel.compounds.contains(where: { !$0.isReactant })
    }

    private func beginEntry(on side: ReactionSide) {
        compoundFormula = ""
        entrySide = side
    }

    private func addCompound(on side: ReactionSide) {
        switch side {
        case .reactant:
            compoundsModel.addReactant(formula: compoundFormula)
        case .product:
            compoundsModel.addProduct(formula: compoundFormula)
        }
        compoundFormula = ""
    }
}

private enum ReactionSide: String, Identifiable {
    case reactant
    case product

    var id: Self { self }
}

private struct ReactionCompoundList: View {
    let compounds: [Compound]
    let removeCompound: (UUID) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ReactionSideRow(
                title: "Reactants",
                compounds: compounds.filter(\.isReactant),
                removeCompound: removeCompound
            )

            Image(systemName: "arrow.down")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)

            ReactionSideRow(
                title: "Products",
                compounds: compounds.filter { !$0.isReactant },
                removeCompound: removeCompound
            )
        }
    }
}

private struct ReactionSideRow: View {
    let title: String
    let compounds: [Compound]
    let removeCompound: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            if compounds.isEmpty {
                Text("None added")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(compounds) { compound in
                            HStack(spacing: 8) {
                                Text(compound.formula)
                                    .font(.headline)
                                Button {
                                    removeCompound(compound.id)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(.red)
                                .accessibilityLabel("Remove \(compound.formula)")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.phostext.opacity(0.45))
        )
    }
}

#Preview {
    CombinedReactionView()
}
