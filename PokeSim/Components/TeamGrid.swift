import SwiftUI

struct TeamGrid<S1: ShapeStyle, S2: ShapeStyle, MenuItems: View>: View {
    private let db = PokemonDatabase.shared
    
    let team: PokemonTeam
    let pokemonCircleStyle: S1
    let emptyCircleStyle: S2
    let pokemonClickable: Bool
    let teamNameHidden: Bool
    let onPokemonTap: ((Int) -> Void)?
    let onReorder: ((Int, Int) -> Void)? // (fromIndex, toIndex)

    let pokemonContextMenu: ((Int) -> MenuItems)?

    init(
        team: PokemonTeam,
        pokemonCircleStyle: S1 = .background.secondary,
        emptyCircleStyle: S2 = .background.secondary.opacity(0),
        pokemonClickable: Bool = false,
        teamNameHidden: Bool = false,
        onPokemonTap: ((Int) -> Void)? = nil,
        onReorder: ((Int, Int) -> Void)? = nil,
        @ViewBuilder pokemonContextMenu: @escaping (Int) -> MenuItems = { _ in EmptyView() }
    ) {
        self.team = team
        self.pokemonCircleStyle = pokemonCircleStyle
        self.emptyCircleStyle = emptyCircleStyle
        self.pokemonClickable = pokemonClickable
        self.teamNameHidden = teamNameHidden
        self.onPokemonTap = onPokemonTap
        self.onReorder = onReorder
        self.pokemonContextMenu = pokemonContextMenu
    }

    var body: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        VStack {
            if !team.name.isEmpty && !teamNameHidden {
                Text(team.name)
                    .font(.title2.bold())
            }
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<6, id: \.self) { (index: Int) in
                    if let onPokemonTap {
                        Button { onPokemonTap(index) } label: {
                            if team.members.count > index, let pokemon = db.pokemon(byID: team.orderedMembers[index].pokemonID) {
                                PokemonCircle(pokemon: pokemon, pokemonClickable: true, style: pokemonCircleStyle)
                                    .contextMenu {
                                        pokemonContextMenu?(index)
                                    }
                                    .draggable(String(pokemon.id))
                                    .dropDestination(for: String.self) { droppedIDs, _ in
                                        guard let onReorder,
                                              let droppedID = droppedIDs.first,
                                              let droppedIntID = Int(droppedID),
                                              let sourceIndex = team.pokemonList.firstIndex(where: { $0.id == droppedIntID })
                                        else { return false }

                                        withAnimation {
                                            onReorder(sourceIndex, index)
                                        }
                                        return true
                                    }
                            } else {
                                Image(systemName: "plus")
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(.gray.opacity(0.5))
                                    .background(emptyCircleStyle)
                                    .glassEffect(.regular.interactive())
                            }
                        }
                    } else if team.pokemonList.count > index {
                        let pokemon = team.pokemonList[index]
                        if pokemonClickable {
                            if let species = db.species(byID: pokemon.pokemon_species_id) {
                                NavigationLink {
                                    PokemonDetailsView(species: species)
                                } label: {
                                    PokemonCircle(pokemon: pokemon, pokemonClickable: pokemonClickable, style: pokemonCircleStyle)
                                }
                            }
                        } else {
                            PokemonCircle(pokemon: pokemon, pokemonClickable: pokemonClickable, style: pokemonCircleStyle)
                        }
                    } else {
                        Circle()
                            .frame(width: 80)
                            .foregroundStyle(emptyCircleStyle)
                            .glassEffect()
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 36)
    }
}

struct PokemonCircle<S: ShapeStyle>: View {
    let pokemon: PokemonRecord
    let pokemonClickable: Bool
    let style: S
    
    private var primaryType: PokemonType? {
        PokemonDatabase.shared.types(forPokemonID: pokemon.id).first?.type
    }

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    primaryType?.colors.bg.opacity(0.3) ?? .clear,
                    .clear
                ],
                center: .center,
                startRadius: 10,
                endRadius: 30
            )
            
            PokemonImage(for: pokemon)
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .background(style)
                .clipShape(Circle())
                .glassEffect(pokemonClickable ? .regular.interactive() : .regular)
        }
    }
}


#Preview {
    NavigationStack {
        TeamGrid(
            team: PokemonTeam(
                name: "Team 1",
                members: [
                    TeamMember(pokemonID: 448, moveIDs: [], slot: 0),
                    TeamMember(pokemonID: 964, moveIDs: [], slot: 1),
                    TeamMember(pokemonID: 959, moveIDs: [], slot: 2),
                    TeamMember(pokemonID: 445, moveIDs: [], slot: 3),
                    TeamMember(pokemonID: 911, moveIDs: [], slot: 4)
                ]
            ),
            pokemonClickable: true
        )
        .padding(24)
    }
}
