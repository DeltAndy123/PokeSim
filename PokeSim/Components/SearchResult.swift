import SwiftUI

struct SearchResult<V: Hashable>: View {
    let species: PokemonSpeciesRecord
    let value: V
    private let db = PokemonDatabase.shared
    
    init(species: PokemonSpeciesRecord, value: V) {
        self.species = species
        self.value = value
    }
    
    var body: some View {
        NavigationLink(value: value) {
            HStack {
                VStack(alignment: .leading) {
                    Text(db.speciesName(forSpeciesID: species.id, withLanguage: .en)?.name ?? "MISSINGNO")
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
