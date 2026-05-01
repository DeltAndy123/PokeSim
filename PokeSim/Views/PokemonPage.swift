import SwiftUI
import Flow

enum PokemonTab {
    case about, stats, forms, moves
}

struct PokemonPage: View {
    @Environment(\.colorScheme) private var colorScheme

    private let csvReader = PokemonCSVReader.shared
    
    let species: CSVPokemonSpecies
    private var speciesName: String {
        species.speciesEnglishName(from: csvReader.pokemonSpeciesNames) ?? "MISSINGNO"
    }
    private var variants: [CSVPokemon] { species.variants(from: csvReader.pokemonList) }
    private var genus: String {
        species.speciesEnglishGenus(from: csvReader.pokemonSpeciesNames) ?? "UNKNOWN"
    }
    
    @State private var activeTab: PokemonTab = .about
    @State private var selectedVariant: CSVPokemon?
    
    private var moves: [CSVPokemonMove] {
        selectedVariant?.moves(from: csvReader.pokemonMoves) ?? []
    }
    
    private var selectedVariantName: String {
        selectedVariant?.id == variants.first?.id
        ? speciesName
        : selectedVariant?.forms(from: csvReader.pokemonForms).first?
            .englishName(from: csvReader.pokemonFormNames)?.pokemon_name
        ?? speciesName
    }
    
    private func labelAccent(for form: CSVPokemon) -> Color {
        form.primaryType(from: csvReader.pokemonTypes)?
            .colors.labelAccent(for: colorScheme) ?? .secondary
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
            selectedVariant = species.variants(from: csvReader.pokemonList).first
            
        }
    }
    
    // MARK: - Header
    var header: some View {
        VStack {
            Text(selectedVariantName)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("\(species.formattedID) • \(genus)")
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
            if let form = selectedVariant {
                HStack {
                    ForEach(form.types(from: csvReader.pokemonTypes), id: \.slot) { type in
                        TypeBadge(type: type.type)
                    }
                }
                .padding(.top, 4)
                ZStack {
                    RadialGradient(
                        colors: [
                            form.primaryType(from: csvReader.pokemonTypes)?.colors.bg.opacity(0.3) ?? .clear,
                            .clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 150
                    )
                    if let form = selectedVariant ?? variants.first {
                        PokemonImage(for: form)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200)
                    }
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
            if let form = selectedVariant {
                let accent = labelAccent(for: form)
                let columns = [GridItem(.flexible()), GridItem(.flexible())]

                LazyVGrid(columns: columns, spacing: 12) {
                    InfoCard(label: "Height", labelStyle: accent, value: form.formattedHeight)
                    InfoCard(label: "Weight", labelStyle: accent, value: form.formattedWeight)
                    InfoCard(label: "Category", labelStyle: accent, value: genus)
                    if let exp = form.base_experience {
                        InfoCard(label: "Base EXP", labelStyle: accent, value: "\(exp)")
                    }
                }
                
                abilitiesSection(form: form)
            }
        }
    }
    func abilitiesSection(form: CSVPokemon) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Abilities")
                .font(.caption)
                .fontWeight(.bold)
                .textCase(.uppercase)
                .foregroundStyle(labelAccent(for: form))
            
            HFlow {
                ForEach(form.regularAbilities(from: csvReader.pokemonAbilities), id: \.ability_id) { (ability: CSVPokemonAbility) in
                    Text(ability.englishName(from: csvReader.abilityNames) ?? "Ability #\(ability.ability_id)")
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
                }
                
                if let hiddenAbility = form.hiddenAbility(from: csvReader.pokemonAbilities) {
                    HStack {
                        Text(hiddenAbility.englishName(from: csvReader.abilityNames) ?? "Ability #\(hiddenAbility.ability_id)")
                        Text("HIDDEN")
                            .font(Font.caption)
                            .fontWeight(.heavy)
                            .foregroundStyle(labelAccent(for: form).opacity(0.75))
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .background(form.primaryType(from: csvReader.pokemonTypes)?.colors.dim ?? Color.secondary, in: Capsule())
                    }
                    .fixedSize()
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(labelAccent(for: form), style: StrokeStyle(dash: [5]))
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
            if let form = selectedVariant {
                let accent = labelAccent(for: form)
                let stats = form.stats(from: csvReader.pokemonStats)
                
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
        VStack {
            Text("\(moves.first!.move(from: csvReader.moves)!.identifier)")
            HStack {
                Text("Level Name Type Cat Pow Acc PP")
                    .frame(width: .infinity)
                    .background(.gray)
            }
            ScrollView(.vertical) {
                
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
    private let csvReader = PokemonCSVReader.shared
    
    let variant: CSVPokemon
    let speciesName: String
    let isSelected: Bool
    let accent: Color
    
    var body: some View {
        VStack {
            PokemonImage(for: variant)
                .aspectRatio(contentMode: .fit)
                .frame(width: 96, height: 96)

            let name = variant.forms(from: csvReader.pokemonForms).first?
                .englishName(from: csvReader.pokemonFormNames)?.form_name ?? speciesName

            Text(name)
                .font(.headline)

            HStack {
                let types = variant.types(from: csvReader.pokemonTypes)
                ForEach(types, id: \.slot) { type in
                    TypeBadge(type: type.type)
                }
            }
        }
        .frame(alignment: .leading)
        .padding(12)
        .background(
            (isSelected ? variant.primaryType(from: csvReader.pokemonTypes)?.colors.dim : nil) ?? .clear,
            in: RoundedRectangle(cornerRadius: 16)
        )
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? variant.primaryType(from: csvReader.pokemonTypes)?.colors.bg ?? .clear : .clear, lineWidth: 2)
        )
    }
}

struct MoveCard: View {
    var body: some View {
        
    }
}


#Preview {
    NavigationStack {
        PokemonPage(species: PokemonCSVReader().species(byId: 6)!)
    }
}
