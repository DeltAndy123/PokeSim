import SwiftUI

struct SearchResult<D: View>: View {
    let pokemon: PokemonSpecies
    let destination: D
    
    init(pokemon: PokemonSpecies, @ViewBuilder destination: () -> D) {
        self.pokemon = pokemon
        self.destination = destination()
    }
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(pokemon.primaryName)
                        .fontWeight(.medium)
                    HStack {
                        ForEach(pokemon.defaultForm?.pokemontypes ?? [], id: \.type.id) { type in
                            TypeBadge(type: type.type)
                        }
                    }
                    .padding(.top, -6)
                }
                Spacer()
                Image("\(pokemon.id)")
                    .resizable()
                    .frame(width: 48, height: 48)
            }
        }
    }
}

#Preview {
    SearchView()
}
