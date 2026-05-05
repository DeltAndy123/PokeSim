import SwiftUI

struct PokemonImage: View {
    let pixelated: Bool = false
    let spriteUrl: URL?
    
    init (for pokemon: PokemonRecord) {
        spriteUrl = pokemon.spriteArtworkUrl
    }
    
    init(forSpecies species: PokemonSpeciesRecord) {
        spriteUrl = species.spriteArtworkUrl
    }
    
    var body: some View {
        AsyncImage(url: spriteUrl) { image in
            if pixelated {
                image
                    .resizable()
                    .interpolation(.none)
            } else {
                image
                    .resizable()
            }
        } placeholder: {
            ProgressView()
        }
    }
}
