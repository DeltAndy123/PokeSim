import SwiftUI

struct SearchView: View {
    private let db = PokemonDatabase.shared
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List(PokemonDatabase.shared.searchSpecies(for: searchText)) { species in
                SearchResult(species: species, value: species.id)
            }
            .navigationTitle(Text("Search"))
            .navigationDestination(for: Int.self) { id in
                if let species = db.species(byID: id) {
                    PokemonDetailsView(species: species)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search for a Pokémon")
    }
}

#Preview {
    SearchView()
}
