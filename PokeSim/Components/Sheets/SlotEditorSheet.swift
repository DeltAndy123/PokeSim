import SwiftUI
import SwiftData

enum SlotEditorDestination: Hashable {
    case selectPokemon
    case pokemonDetail(Int)
    
    case selectMove(Int)
}

struct SlotEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthManager.self) private var authManager
    private let db = PokemonDatabase.shared
    
    @State private var path = NavigationPath()
    
    let team: PokemonTeam
    let memberIndex: Int
    
    private var isNewMember: Bool {
        memberIndex >= team.members.count
    }
    
    private var member: TeamMember? {
        memberIndex >= team.members.count ? nil : team.orderedMembers[memberIndex]
    }
    
    private var pokemon: PokemonRecord? {
        guard let member else { return nil }
        return db.pokemon(byID: member.pokemonID)
    }
    private var pokemonName: String? {
        guard let pokemon else { return nil }
        return db.speciesName(forSpeciesID: pokemon.pokemon_species_id, withLanguage: .en)?.name
    }
    
    private var types: [PokemonTypeRecord] {
        guard let pokemon else { return [] }
        return db.types(forPokemonID: pokemon.id)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if let pokemon {
                    Text(pokemonName ?? "Unknown Name")
                        .font(.largeTitle.bold())
                    HStack {
                        ForEach(types, id: \.slot) { type in
                            TypeBadge(type: type.type)
                        }
                    }
                    
                    NavigationLink(value: SlotEditorDestination.selectPokemon) {
                        HStack {
                            Text("Change Pokémon")
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding(.top)
                    
                    ZStack {
                        RadialGradient(
                            colors: [
                                types.first?.type.colors.bg.opacity(0.3) ?? .clear,
                                .clear
                            ],
                            center: .center,
                            startRadius: 12,
                            endRadius: 96
                        )
                        
                        PokemonImage(for: pokemon)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 160)
                    }
                    .frame(height: 200)
                    
                    Divider()
                        .padding()
                    
                    movesSection
                } else {
                    Text("(No Pokémon Selected)")
                        .font(.title.bold())
                        .foregroundStyle(.secondary)
                    NavigationLink(value: SlotEditorDestination.selectPokemon) {
                        HStack {
                            Text("Select Pokémon")
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding(.top)
                    
                    RadialGradient(
                        colors: [
                            .gray.opacity(0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 128
                    )
                    .frame(height: 250)
                }
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Slot")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: SlotEditorDestination.self) { dest in
                switch dest {
                case .selectPokemon:
                    SelectPokemonPage()
                case .pokemonDetail(let id):
                    if let species = db.species(byID: id) {
                        PokemonDetailsView(species: species)
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Select", systemImage: "checkmark") {
                                        Task { @MainActor in
                                            try await changePokemon(pokemonID: id)
                                            // There's a bug that breaks removeLast(2) if there's a search so we have to do this
                                            path.removeLast()
                                            try? await Task.sleep(for: .milliseconds(10))
                                            path.removeLast()
                                        }
                                    }
                                }
                            }
                    }
                    
                case .selectMove(let slot):
                    if let member {
                        SelectMovePage(
                            slot: slot,
                            member: member
                        ) { move in
                            Task {
                                if slot < member.moveIDs.count {
                                    member.moveIDs[slot] = move.id
                                } else {
                                    member.moveIDs.append(move.id)
                                }
                                path.removeLast()
                                try await authManager.pushTeam(team)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var movesSection: some View {
        ScrollView {
            if let moveIDs = member?.moveIDs {
                ForEach(0..<4, id: \.self) { slot in
                    if slot < moveIDs.count, let move = db.move(byID: moveIDs[slot]) {
                        // Filled slot
                        PokemonMoveCard(slot: slot, moveID: move.id, isDisabled: false)
                            .contextMenu {
                                Button("Remove", systemImage: "trash", role: .destructive) {
                                    Task {
                                        member?.moveIDs.remove(at: slot)
                                        try await authManager.pushTeam(team)
                                    }
                                }
                            }
                    } else if slot == moveIDs.count {
                        // Next empty slot
                        PokemonMoveCard(slot: slot, moveID: nil, isDisabled: false)
                    } else {
                        // Future slot
                        PokemonMoveCard(slot: slot, moveID: nil, isDisabled: true)
                    }
                }
            }
        }
    }
    
    private func changePokemon(pokemonID: Int) async throws {
        if isNewMember {
            let newMember = TeamMember(pokemonID: pokemonID, moveIDs: [], slot: team.members.count)
            modelContext.insert(newMember)
            team.members.append(newMember)
        } else {
            team.orderedMembers[memberIndex].pokemonID = pokemonID
            team.orderedMembers[memberIndex].moveIDs = []
        }
        try await authManager.pushTeam(team)
    }
}

struct SelectPokemonPage: View {
    private let db = PokemonDatabase.shared
    
    @State private var searchText = ""
    
    var body: some View {
        List(db.searchSpecies(for: searchText)) { species in
            SearchResult(
                species: species,
                value: SlotEditorDestination.pokemonDetail(species.id)
            )
        }
        .searchable(text: $searchText)
        .navigationTitle("Select Pokémon")
    }
}

struct SelectMovePage: View {
    private let db = PokemonDatabase.shared
    private var pokemon: PokemonRecord? {
        db.pokemon(byID: member.pokemonID)
    }
    private var learnableMoves: [MoveRecord] {
        return db.learnableMoves(forPokemonID: member.pokemonID)
    }
    
    let slot: Int
    let member: TeamMember
    let onSelect: (MoveRecord) -> Void
    
    @State private var searchText = ""
    
    private var filteredMoves: [MoveRecord] {
        guard !searchText.isEmpty else { return learnableMoves }
        return learnableMoves.filter { move in
            let name = db.moveName(forMoveID: move.id, withLanguage: .en)?.name ?? move.name
            return name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List(filteredMoves) { (move: MoveRecord) in
            Button {
                onSelect(move)
            } label: {
                if let moveName = db.moveName(forMoveID: move.id, withLanguage: .en) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(moveName.name)
                                .fontWeight(.semibold)
                            HStack(spacing: 4) {
                                Image(systemName: "burst.fill")
                                Text(move.power?.description ?? "—")
                                    .padding(.trailing, 12)
                                Image(systemName: "target")
                                Text(move.accuracy?.description ?? "—")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        Spacer()
                        TypeBadge(type: move.type)
                        if member.moveIDs.contains(move.id) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(move.type.colors.accent.opacity(0.5))
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(member.moveIDs.contains(move.id))
        }
        .searchable(text: $searchText)
        .navigationTitle("Select Move")
    }
}

struct PokemonMoveCard: View {
    private let db = PokemonDatabase.shared
    
    let slot: Int
    let moveID: Int?
    let isDisabled: Bool
    
    private var move: MoveRecord? {
        guard let moveID else { return nil }
        return db.move(byID: moveID)
    }
    private var moveName: String? {
        guard let moveID else { return nil }
        return db.moveName(forMoveID: moveID, withLanguage: .en)?.name
    }
    
    var body: some View {
        NavigationLink(value: SlotEditorDestination.selectMove(slot)) {
            HStack {
                if let move, let moveName {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(moveName)
                        HStack(spacing: 4) {
                            Image(systemName: "burst.fill")
                            Text(move.power?.description ?? "—")
                                .padding(.trailing, 12)
                            Image(systemName: "target")
                            Text(move.accuracy?.description ?? "—")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                    TypeBadge(type: move.type)
                } else {
                    Image(systemName: "plus")
                    Text("Add Move")
                    Spacer()
                }
            }
            .padding()
            .background(move?.type.colors.accent.opacity(0.25) ?? .gray.opacity(0.25), in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

#Preview {
    let team = PokemonTeam.previewTeam
    
    SlotEditorSheet(
        team: team,
        memberIndex: 0
    )
}
