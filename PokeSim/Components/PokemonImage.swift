import SwiftUI

struct PokemonImage: View {
    let pokemon: Pokemon?
    var spriteUrl: URL? {
        URL(string: pokemon?.sprites?.official_front ?? "")
    }
    
    init(forSpecies species: PokemonSpecies) {
        self.pokemon = species.defaultForm
    }
    
    init(for pokemon: Pokemon) {
        self.pokemon = pokemon
    }
    
    var body: some View {
        AsyncImage(url: spriteUrl) { image in
            image
                .resizable()
                .interpolation(.none)
        } placeholder: {
            ProgressView()
        }
    }
}
