import SwiftUI
import SwiftData

struct SelectPokemonSheet: View {
    @Environment(\.dismiss) private var dismiss
    let team: PokemonTeam
    let pokemonIndex: Int

    private let csvReader = PokemonCSVReader.shared

    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List(csvReader.searchSpecies(for: searchText)) { pokemon in
                SearchResult(pokemon: pokemon) {
                    PokemonPage(species: pokemon)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done", systemImage: "checkmark") {
                                    if pokemonIndex >= team.pokemonIDs.count {
                                        team.pokemonIDs.append(pokemon.id)
                                    } else {
                                        team.pokemonIDs[pokemonIndex] = pokemon.id
                                    }
                                    dismiss()
                                }
                            }
                        }
                }
            }
            .navigationTitle("Select a Pokémon")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.top, -24)
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TeamsView()
        .modelContainer(PokemonTeam.preview)
}
