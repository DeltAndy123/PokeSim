import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List(PokemonModel.shared.root.data.search(searchText)) { pokemon in
                SearchResult(pokemon: pokemon) {
                    PokemonPage(pokemon: pokemon)
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
