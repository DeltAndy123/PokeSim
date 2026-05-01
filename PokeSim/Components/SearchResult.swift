import SwiftUI

struct SearchResult<D: View>: View {
    let pokemon: CSVPokemonSpecies
    let destination: D
    private let csvReader = PokemonCSVReader.shared
    
    init(pokemon: CSVPokemonSpecies, @ViewBuilder destination: () -> D) {
        self.pokemon = pokemon
        self.destination = destination()
    }
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(pokemon.speciesEnglishName(from: csvReader.pokemonSpeciesNames) ?? "MISSINGNO")
                        .fontWeight(.medium)
                    HStack {
                        let variant = pokemon.variants(from: csvReader.pokemonList).first
                        let types = variant?.types(from: csvReader.pokemonTypes) ?? []
                        ForEach(types, id: \.slot) { type in
                            TypeBadge(type: type.type)
                        }
                    }
                    .padding(.top, -6)
                }
                Spacer()
                PokemonImage(forSpecies: pokemon)
                    .frame(width: 48, height: 48)
            }
        }
    }
}

#Preview {
    SearchView()
}
