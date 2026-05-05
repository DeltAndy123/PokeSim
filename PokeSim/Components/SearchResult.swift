import SwiftUI

struct SearchResult<D: View>: View {
    let species: PokemonSpeciesRecord
    let destination: D
    private let db = PokemonDatabase.shared
    
    init(species: PokemonSpeciesRecord, @ViewBuilder destination: () -> D) {
        self.species = species
        self.destination = destination()
    }
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(db.englishSpeciesName(forSpeciesID: species.id)?.name ?? "MISSINGNO")
                        .fontWeight(.medium)
                    HStack {
                        if let pokemon = db.pokemon(forSpeciesID: species.id).first {
                            let types = db.types(forPokemonID: pokemon.id)
                            ForEach(types, id: \.slot) { type in
                                TypeBadge(type: type.type)
                            }
                        }
                    }
                    .padding(.top, -6)
                }
                Spacer()
                PokemonImage(forSpecies: species)
                    .frame(width: 48, height: 48)
            }
        }
    }
}

#Preview {
    SearchView()
}
