import SwiftUI

struct PokemonImage: View {
    let pixelated: Bool = false
    let spriteUrl: URL?
    
    init(for pokemon: CSVPokemon) {
        spriteUrl = pokemon.spriteArtworkUrl
    }
    
    init(forSpecies species: CSVPokemonSpecies) {
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
