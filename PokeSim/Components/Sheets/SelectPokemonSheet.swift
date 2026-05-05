import SwiftUI
import SwiftData

struct SelectPokemonSheet: View {
    @Environment(\.dismiss) private var dismiss
    let team: PokemonTeam
    let pokemonIndex: Int

    private let db = PokemonDatabase.shared

    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List(db.searchSpecies(for: searchText)) { species in
                SearchResult(species: species) {
                    PokemonPage(species: species)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done", systemImage: "checkmark") {
                                    if pokemonIndex >= team.pokemonIDs.count {
                                        team.pokemonIDs.append(species.id)
                                    } else {
                                        team.pokemonIDs[pokemonIndex] = species.id
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
