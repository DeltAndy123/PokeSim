import SwiftUI
import SwiftData

private struct PokemonSlot: Identifiable {
    let id: Int
}

struct TeamPage: View {
    @State var team: PokemonTeam

    @State private var selectedSlot: PokemonSlot?

    var body: some View {
        ScrollView {
            VStack {
                TeamGrid(
                    team: team,
                    pokemonCircleStyle: .background,
                    teamNameHidden: true
                ) { index in
                    selectedSlot = PokemonSlot(id: index)
                } onReorder: { from, to in
                    team.pokemonIDs.move(
                        fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to
                    )
                } pokemonContextMenu: { index in
                    Button("Remove", systemImage: "trash", role: .destructive) {
                        team.pokemonIDs.remove(at: index)
                    }
                }
                .padding(.vertical, 24)
                .background(.background.secondary, in: RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(team.name)
        .sheet(item: $selectedSlot) { slot in
            SelectPokemonSheet(team: team, pokemonIndex: slot.id)
        }
    }
}

#Preview {
    let team = PokemonTeam(name: "Your Team", pokemonIDs: [448, 964, 959, 445])
    
    NavigationStack {
        TeamPage(team: team)
            .modelContainer(PokemonTeam.preview)
    }
}
