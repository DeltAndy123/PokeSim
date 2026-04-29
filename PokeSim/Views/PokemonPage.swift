import SwiftUI
import Flow

enum PokemonTab {
    case about, stats, forms, moves
}

struct PokemonPage: View {
    let pokemon: PokemonSpecies
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var activeTab: PokemonTab = .about
    @State private var selectedForm: Pokemon?
    
    private var selectedFormName: String {
        return selectedForm?.id == pokemon.defaultForm?.id
        ? pokemon.primaryName
        : selectedForm?.formName(fallback: pokemon.primaryName) ?? pokemon.primaryName
    }
    
    private func labelAccent(for form: Pokemon) -> Color {
        form.primaryType?.colors.labelAccent(for: colorScheme) ?? .secondary
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
            selectedForm = pokemon.defaultForm
        }
    }
    
    // MARK: - Header
    var header: some View {
        VStack {
            Text(selectedFormName)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("\(pokemon.idFormatted) • \(pokemon.primaryGenus)")
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
            if let form = selectedForm {
                HStack {
                    ForEach(form.pokemontypes, id: \.type.id) { type in
                        TypeBadge(type: type.type)
                    }
                }
                .padding(.top, 4)
                ZStack {
                    RadialGradient(
                        colors: [
                            form.primaryType?.colors.bg.opacity(0.3) ?? .clear,
                            .clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 150
                    )
                    if let form = selectedForm ?? pokemon.defaultForm {
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
            if let form = selectedForm {
                let accent = labelAccent(for: form)
                let columns = [GridItem(.flexible()), GridItem(.flexible())]

                LazyVGrid(columns: columns, spacing: 12) {
                    InfoCard(label: "Height", labelStyle: accent, value: form.heightFormatted)
                    InfoCard(label: "Weight", labelStyle: accent, value: form.weightFormatted)
                    InfoCard(label: "Category", labelStyle: accent, value: pokemon.primaryGenus)
                    if let exp = form.base_experience {
                        InfoCard(label: "Base EXP", labelStyle: accent, value: "\(exp)")
                    }
                }
                
                abilitiesSection(form: form)
            }
        }
    }
    func abilitiesSection(form: Pokemon) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Abilities")
                .font(.caption)
                .fontWeight(.bold)
                .textCase(.uppercase)
                .foregroundStyle(labelAccent(for: form))
            
            HFlow {
                ForEach(form.commonAbilities, id: \.id) { ability in
                    Text(ability.abilitynames.first?.name ?? ability.name)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
                }
                
                if let hidden = form.hiddenAbility {
                    HStack {
                        Text(hidden.abilitynames.first?.name ?? hidden.name)
                        Text("HIDDEN")
                            .font(Font.caption)
                            .fontWeight(.heavy)
                            .foregroundStyle(labelAccent(for: form).opacity(0.75))
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .background(form.primaryType?.colors.dim ?? Color.secondary, in: Capsule())
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
            if let form = selectedForm {
                let accent = labelAccent(for: form)
                
                StatRow(stat: "HP", value: form.stats.hp, color: .green, accent: accent)
                StatRow(stat: "ATK", value: form.stats.attack, color: .yellow, accent: accent)
                StatRow(stat: "DEF", value: form.stats.defense, color: .orange, accent: accent)
                StatRow(stat: "SP. ATK", value: form.stats.spAtk, color: .cyan, accent: accent)
                StatRow(stat: "SP. DEF", value: form.stats.spDef, color: .blue, accent: accent)
                StatRow(stat: "SPD", value: form.stats.speed, color: .purple, accent: accent)
            }
        }
    }
    
    // MARK: - Forms Tab
    var formsTab: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(pokemon.pokemons) { form in
                    FormCard(form: form, speciesName: pokemon.primaryName, isSelected: selectedForm?.id == form.id, accent: labelAccent(for: form))
                        .onTapGesture {
                            selectedForm = form
                        }
                }
            }
        }
        .contentMargins(2)
    }
    
    // MARK: - Moves Tab
    
    func movesSection(form: Pokemon) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Moves")
                .font(.caption)
                .fontWeight(.bold)
                .textCase(.uppercase)
                .foregroundStyle(labelAccent(for: form))
        }
    }
    
    var movesTab: some View {
        VStack {
            HStack {
                Text("Name Type Cat Pow Acc PP")
                    
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
    let form: Pokemon
    let speciesName: String
    let isSelected: Bool
    let accent: Color
    
    var body: some View {
        VStack {
//            Image("\(form.id)")
            PokemonImage(for: form)
                .aspectRatio(contentMode: .fit)
                .frame(width: 96, height: 96)

            Text(form.formName(fallback: speciesName))
                .font(.headline)

            HStack {
                ForEach(form.pokemontypes, id: \.type.id) { type in
                    TypeBadge(type: type.type)
                }
            }
        }
        .frame(alignment: .leading)
        .padding(12)
        .background(
            (isSelected ? form.primaryType?.colors.dim : nil) ?? .clear,
            in: RoundedRectangle(cornerRadius: 16)
        )
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? form.primaryType?.colors.bg ?? .clear : .clear, lineWidth: 2)
        )
    }
}



#Preview {
    NavigationStack {
        PokemonPage(pokemon: PokemonModel("pokemon.json").getSpecies(id: 6)!)
    }
}
