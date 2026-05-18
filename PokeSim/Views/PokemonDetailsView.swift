import SwiftUI
import Flow

enum PokemonTab {
    case about, stats, forms, moves
}

enum MoveColumn {
    case level, name, type, category, power, accuracy
}

struct PokemonDetailsView: View {
    @Environment(\.colorScheme) private var colorScheme

    private let db = PokemonDatabase.shared
    
    let species: PokemonSpeciesRecord
    private var speciesName: String {
        db.speciesName(forSpeciesID: species.id, withLanguage: .en)?.name ?? "MISSINGNO"
    }
    private var variants: [PokemonRecord] {
        db.pokemon(forSpeciesID: species.id)
    }
    private var genus: String {
        db.speciesName(forSpeciesID: species.id, withLanguage: .en)?.genus ?? "UNKNOWN"
    }
    
    @State private var activeTab: PokemonTab = .about
    @State private var selectedVariant: PokemonRecord?
    @State private var selectedVersionGroupID: Int?

    @State private var levelSortColumn: MoveColumn = .level
    @State private var levelSortAscending: Bool = true
    @State private var machineSortColumn: MoveColumn = .name
    @State private var machineSortAscending: Bool = true
    
    private var selectedVersionGroup: VersionGroupDetail? {
        moveVersionGroups.first { $0.versionGroup.id == selectedVersionGroupID }
    }
    
    private var variantTypes: [PokemonTypeRecord] {
        guard let selectedVariant else { return [] }
        return db.types(forPokemonID: selectedVariant.id)
    }
    
    private var moves: [PokemonMoveDetail] {
        guard let selectedVariant else { return [] }
        guard let selectedVersionGroupID else { return [] }
        return db.moveDetails(forPokemonID: selectedVariant.id, versionGroupID: selectedVersionGroupID)
    }
    
    private var moveVersionGroups: [VersionGroupDetail] {
        guard let selectedVariant else { return [] }
        return db.pokemonVersionGroups(forPokemonID: selectedVariant.id)
            .compactMap { group in
                PokemonDatabase.shared
                    .versionGroupDetails(forID: group.id)
            }
    }
    
    private var selectedVariantName: String {
        guard let selectedVariant else { return speciesName }
        guard let form = db.forms(forPokemonID: selectedVariant.id).first else { return speciesName }
        return selectedVariant.id == variants.first?.id ? speciesName
        : db.formName(forFormID: form.id, withLanguage: .en)?.pokemon_name
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
            selectedVersionGroupID = moveVersionGroups.first?.versionGroup.id ?? 0
//            print(moveVersionGroups.map { $0.combinedNames(forLanguage: .en) })
//            print(moves.first!)
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
                    Text(db.abilityName(forAbilityID: ability.ability_id, withLanguage: .en)?.name ?? "Unknown Ability #\(ability.ability_id)")
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
                }
                
                ForEach(db.hiddenAbilities(forPokemonID: variant.id)) { hiddenAbility in
                    HStack {
                        Text(db.abilityName(forAbilityID: hiddenAbility.ability_id, withLanguage: .en)?.name ?? "Unknown Ability #\(hiddenAbility.ability_id)")
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
    private let lvCol: CGFloat = 36
    private let nameCol: CGFloat = 150
    private let typeCol: CGFloat = 110
    private let catCol: CGFloat = 52
    private let powCol: CGFloat = 48
    private let accCol: CGFloat = 44

    var movesTab: some View {
        let levelMoves = sortedMoves(
            moves.filter { $0.pokemonMove.move_learn_method_id == 1 },
            by: levelSortColumn, ascending: levelSortAscending
        )
        let machineMoves = sortedMoves(
            moves.filter { $0.pokemonMove.move_learn_method_id == 4 },
            by: machineSortColumn, ascending: machineSortAscending
        )

        return VStack(alignment: .leading, spacing: 16) {
            if !levelMoves.isEmpty {
                Text("By Level Up")
                    .font(.caption.weight(.heavy))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                moveTable(moves: levelMoves, showLevel: true,
                          sortColumn: $levelSortColumn, sortAscending: $levelSortAscending)
            }
            if !machineMoves.isEmpty {
                Text("TM / HM")
                    .font(.caption.weight(.heavy))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                moveTable(moves: machineMoves, showLevel: false,
                          sortColumn: $machineSortColumn, sortAscending: $machineSortAscending)
            }
        }
    }

    private func sortedMoves(
        _ moves: [PokemonMoveDetail],
        by column: MoveColumn,
        ascending: Bool
    ) -> [PokemonMoveDetail] {
        moves.sorted { a, b in
            let less: Bool
            switch column {
            case .level:    less = a.pokemonMove.level < b.pokemonMove.level
            case .name:     less = a.move.name < b.move.name
            case .type:     less = a.move.type.name < b.move.type.name
            case .category: less = a.move.move_damage_class_id < b.move.move_damage_class_id
            case .power:    less = (a.move.power ?? -1) < (b.move.power ?? -1)
            case .accuracy: less = (a.move.accuracy ?? -1) < (b.move.accuracy ?? -1)
            }
            return ascending ? less : !less
        }
    }

    private func moveTable(
        moves: [PokemonMoveDetail],
        showLevel: Bool,
        sortColumn: Binding<MoveColumn>,
        sortAscending: Binding<Bool>
    ) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    if showLevel {
                        sortHeader("Lv.", column: .level, width: lvCol, alignment: .center,
                                   sortColumn: sortColumn, sortAscending: sortAscending)
                    }
                    sortHeader("Move", column: .name, width: nameCol, alignment: .leading,
                               sortColumn: sortColumn, sortAscending: sortAscending)
                    sortHeader("Type", column: .type, width: typeCol, alignment: .center,
                               sortColumn: sortColumn, sortAscending: sortAscending)
                    sortHeader("Cat", column: .category, width: catCol, alignment: .center,
                               sortColumn: sortColumn, sortAscending: sortAscending)
                    sortHeader("Power", column: .power, width: powCol, alignment: .center,
                               sortColumn: sortColumn, sortAscending: sortAscending)
                    sortHeader("Acc", column: .accuracy, width: accCol, alignment: .center,
                               sortColumn: sortColumn, sortAscending: sortAscending)
                }
                .font(.caption)
                .fontWeight(.heavy)
                .textCase(.uppercase)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

                Divider()

                LazyVStack(spacing: 0) {
                    ForEach(moves, id: \.pokemonMove.id) { move in
                        HStack(spacing: 8) {
                            if showLevel {
                                Text("\(move.pokemonMove.level)")
                                    .frame(width: lvCol, alignment: .center)
                            }
                            Text(db.moveName(forMoveID: move.move.id, withLanguage: .en)?.name ?? move.move.name)
                                .frame(width: nameCol, alignment: .leading)
                            moveTypeBadge(move.move.type)
                            damageClassIcon(move.move.move_damage_class_id)
                            Text(move.move.power.map(\.description) ?? "—")
                                .frame(width: powCol, alignment: .center)
                            Text(move.move.accuracy.map(\.description) ?? "—")
                                .frame(width: accCol, alignment: .center)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)

                        Divider().padding(.leading, 12)
                    }
                }
            }
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func sortHeader(
        _ title: String,
        column: MoveColumn,
        width: CGFloat,
        alignment: Alignment,
        sortColumn: Binding<MoveColumn>,
        sortAscending: Binding<Bool>
    ) -> some View {
        let isActive = sortColumn.wrappedValue == column
        return Button {
            if isActive {
                sortAscending.wrappedValue.toggle()
            } else {
                sortColumn.wrappedValue = column
                sortAscending.wrappedValue = true
            }
        } label: {
            HStack(spacing: 2) {
                Text(title)
                if isActive {
                    Image(systemName: sortAscending.wrappedValue ? "chevron.up" : "chevron.down")
                        .font(.system(size: 8, weight: .heavy))
                }
            }
            .frame(width: width, alignment: alignment)
            .foregroundStyle(isActive ? .primary : .secondary)
        }
        .buttonStyle(.plain)
    }

    private func moveTypeBadge(_ type: PokemonType) -> some View {
        Text(type.name.uppercased())
            .font(.system(size: 11, weight: .heavy))
            .tracking(0.8)
            .lineLimit(1)
            .foregroundStyle(colorScheme == .dark ? type.colors.accent : .white)
            .frame(width: typeCol - 8, alignment: .center)
            .padding(.vertical, 3)
            .padding(.horizontal, 4)
            .background(colorScheme == .dark ? type.colors.dim : type.colors.bg, in: Capsule())
            .frame(width: typeCol)
    }

    @ViewBuilder
    private func damageClassIcon(_ id: Int) -> some View {
        let config: (image: String, color: Color)? = switch id {
        case 1: ("status",   .gray)
        case 2: ("physical", .orange)
        case 3: ("special",  .blue)
        default: nil
        }
        if let config {
            Image(config.image)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(config.color)
                .frame(width: 24, height: 24)
                .padding(3)
                .background(config.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 6))
                .frame(width: catCol)
        } else {
            Text("—")
                .foregroundStyle(.secondary)
                .frame(width: catCol, alignment: .center)
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
        return db.formName(forFormID: firstForm.id, withLanguage: .en)?.name ?? speciesName
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


#Preview {
    NavigationStack {
        PokemonDetailsView(species: PokemonDatabase.shared.species(byID: 6)!)
    }
}
