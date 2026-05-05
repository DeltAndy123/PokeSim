import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List(PokemonDatabase.shared.searchSpecies(for: searchText)) { species in
                SearchResult(species: species) {
                    PokemonPage(species: species)
                }
            }
            .navigationTitle(Text("Search"))
        }
        .searchable(text: $searchText, prompt: "Search for a Pokémon")
    }
}

#Preview {
    SearchView()
}
