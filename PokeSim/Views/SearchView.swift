import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List(PokemonCSVReader.shared.searchSpecies(for: searchText)) { pokemon in
                SearchResult(pokemon: pokemon) {
                    PokemonPage(species: pokemon)
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
