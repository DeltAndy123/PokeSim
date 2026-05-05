import SwiftUI
import Flow

enum PokemonTab {
    case about, stats, forms, moves
}

struct PokemonPage: View {
    @Environment(\.colorScheme) private var colorScheme

    private let db = PokemonDatabase.shared
    
    let species: PokemonSpeciesRecord
    private var speciesName: String {
        db.englishSpeciesName(forSpeciesID: species.id)?.name ?? "MISSINGNO"
    }
    private var variants: [PokemonRecord] {
        db.pokemon(forSpeciesID: species.id)
    }
    private var genus: String {
        db.englishSpeciesName(forSpeciesID: species.id)?.genus ?? "UNKNOWN"
    }
    
    @State private var activeTab: PokemonTab = .about
    @State private var selectedVariant: PokemonRecord?
    
    private var variantTypes: [PokemonTypeRecord] {
        guard let selectedVariant else { return [] }
        return db.types(forPokemonID: selectedVariant.id)
    }
    
    private var moves: [PokemonMoveDetail] {
        guard let selectedVariant else { return [] }
        return db.moveDetails(forPokemonID: selectedVariant.id, versionGroupID: 1)
    }
    
    private var selectedVariantName: String {
        guard let selectedVariant else { return speciesName }
        guard let form = db.forms(forPokemonID: selectedVariant.id).first else { return speciesName }
        return selectedVariant.id == variants.first?.id ? speciesName
        : db.englishFormName(forFormID: form.id)?.pokemon_name
        ?? speciesName
    }
    
    private func labelAccent(for pokemon: PokemonRecord) -> Color {
        db.types(forPokemonID: pokemon.id)
            .first?.type.colors.labelAccent(for: colorScheme) ?? .secondary
    }
    
    var body: some View {
        ScrollView {
            VStack {
                header
                
                Divider()
                
                Picker("Tab", selection: $activeTab) {
                    Text("About").tag(PokemonTab.about)
                    Text("Stats").tag(PokemonTab.stats)
                    Text("Forms").tag(PokemonTab.forms)
                    Text("Moves").tag(PokemonTab.moves)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 8)
                
                switch activeTab {
                case .about:
                    aboutTab
                case .stats:
                    statsTab
                case .forms:
                    formsTab
                case .moves:
                    movesTab
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .onAppear {
            selectedVariant = variants.first { $0.is_default } ?? variants.first
        }
    }
    
    // MARK: - Header
    var header: some View {
        VStack {
            Text(selectedVariantName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("\(species.formattedID) • \(genus)")
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
            if let variant = selectedVariant {
                HStack {
                    ForEach(variantTypes) { type in
                        TypeBadge(type: type.type)
                    }
                }
                .padding(.top, 4)
                ZStack {
                    RadialGradient(
                        colors: [
                            variantTypes.first?.type.colors.bg.opacity(0.3) ?? .clear,
                            .clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 150
                    )
                    PokemonImage(for: variant)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 250)
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - About Tab
    var aboutTab: some View {
        VStack(spacing: 16) {
            if let variant = selectedVariant {
                let accent = labelAccent(for: variant)
                let columns = [GridItem(.flexible()), GridItem(.flexible())]

                LazyVGrid(columns: columns, spacing: 12) {
                    InfoCard(label: "Height", labelStyle: accent, value: variant.formattedHeight)
                    InfoCard(label: "Weight", labelStyle: accent, value: variant.formattedWeight)
                    InfoCard(label: "Category", labelStyle: accent, value: genus)
                    if let exp = variant.base_experience {
                        InfoCard(label: "Base EXP", labelStyle: accent, value: "\(exp)")
                    }
                }
                
                abilitiesSection(variant: variant)
            }
        }
    }
    func abilitiesSection(variant: PokemonRecord) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Abilities")
                .font(.caption)
                .fontWeight(.bold)
                .textCase(.uppercase)
                .foregroundStyle(labelAccent(for: variant))
            
            HFlow {
                ForEach(db.normalAbilities(forPokemonID: variant.id)) { ability in
                    Text(db.englishAbilityName(forAbilityID: ability.ability_id)?.name ?? "Unknown Ability #\(ability.ability_id)")
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
                }
                
                ForEach(db.hiddenAbilities(forPokemonID: variant.id)) { hiddenAbility in
                    HStack {
                        Text(db.englishAbilityName(forAbilityID: hiddenAbility.ability_id)?.name ?? "Unknown Ability #\(hiddenAbility.ability_id)")
                        Text("HIDDEN")
                            .font(Font.caption)
                            .fontWeight(.heavy)
                            .foregroundStyle(labelAccent(for: variant).opacity(0.75))
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .background(db.types(forPokemonID: variant.id).first?.type.colors.dim ?? .secondary, in: Capsule())
                    }
                    .fixedSize()
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(labelAccent(for: variant), style: StrokeStyle(dash: [5]))
                    )
                }
            }
            .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Stats Tab
    var statsTab: some View {
        VStack {
            if let variant = selectedVariant {
                let accent = labelAccent(for: variant)
                let stats = db.stats(forPokemonID: variant.id)
                
                StatRow(stat: "HP", value: stats.hp, color: .green, accent: accent)
                StatRow(stat: "ATK", value: stats.attack, color: .yellow, accent: accent)
                StatRow(stat: "DEF", value: stats.defense, color: .orange, accent: accent)
                StatRow(stat: "SP. ATK", value: stats.spAtk, color: .cyan, accent: accent)
                StatRow(stat: "SP. DEF", value: stats.spDef, color: .blue, accent: accent)
                StatRow(stat: "SPD", value: stats.speed, color: .purple, accent: accent)
            }
        }
    }
    
    // MARK: - Forms Tab
    var formsTab: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(variants) { variant in
                    FormCard(variant: variant, speciesName: speciesName, isSelected: selectedVariant?.id == variant.id, accent: labelAccent(for: variant))
                        .onTapGesture {
                            withAnimation(.linear(duration: 0.1)) {
                                selectedVariant = variant
                            }
                        }
                }
            }
        }
        .contentMargins(2)
    }
    
    // MARK: - Moves Tab
    var movesTab: some View {
        ScrollView {
            LazyVStack {
                ForEach(moves, id: \.pokemonMove.id) { move in
                    Text(move.move.name)
                }
            }
        }
    }
}

// MARK: - Helper Views
struct InfoCard<S: ShapeStyle>: View {
    let label: String
    let labelStyle: S
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .textCase(.uppercase)
                .foregroundStyle(labelStyle)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct StatBar: View {
    let value: Int
    let color: Color

    private let max: Int = 255
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.secondary.opacity(0.2))
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: geometry.size.width * CGFloat(value) / CGFloat(max))
            }
        }
        .frame(height: 8)
    }
}

struct StatRow: View {
    let stat: String
    let value: Int
    let color: Color
    let accent: Color
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Text(stat)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(accent)
                    .frame(width: 48, alignment: .leading)
                
                StatBar(value: value, color: color)
                
                Text("\(value)")
                    .fontWeight(.medium)
                    .frame(width: 30, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .padding(.horizontal, 4)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct FormCard: View {
    private let db = PokemonDatabase.shared
    
    let variant: PokemonRecord
    let speciesName: String
    let isSelected: Bool
    let accent: Color
    
    private var firstForm: PokemonFormRecord? {
        db.forms(forPokemonID: variant.id).first
    }
    private var formName: String {
        guard let firstForm else { return speciesName }
        return db.englishFormName(forFormID: firstForm.id)?.name ?? speciesName
    }
    
    private var primaryType: PokemonType? {
        db.types(forPokemonID: variant.id).first?.type
    }
    
    private var selectedBackground: Color {
        guard isSelected else { return .clear }
        return primaryType?.colors.dim ?? .clear
    }
    private var selectedBorder: Color {
        guard isSelected else { return .clear }
        return primaryType?.colors.bg ?? .clear
    }
    
    var body: some View {
        VStack {
            PokemonImage(for: variant)
                .aspectRatio(contentMode: .fit)
                .frame(width: 96, height: 96)

            Text(formName)
                .font(.headline)

            HStack {
                let types = db.types(forPokemonID: variant.id)
                ForEach(types) { type in
                    TypeBadge(type: type.type)
                }
            }
        }
        .frame(alignment: .leading)
        .padding(12)
        .background(selectedBackground, in: RoundedRectangle(cornerRadius: 16))
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(selectedBorder, lineWidth: 2))
    }
}

struct MoveCard: View {
    var body: some View {
        
    }
}


#Preview {
    NavigationStack {
        PokemonPage(species: PokemonDatabase.shared.species(byID: 6)!)
    }
}
