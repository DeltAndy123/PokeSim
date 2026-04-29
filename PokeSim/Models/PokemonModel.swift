import Foundation

// https://medium.com/@desilio/loading-a-json-file-with-swiftui-18f0486f8de9

class PokemonModel {
    static let shared = PokemonModel("pokemon.json")
    
    let root: PokemonRoot
    
    init(_ file: String) {
        guard let url = Bundle.main.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to locate file from \(file) from bundle")
        }
        
        let decoder = JSONDecoder()
        
        guard let loadedFile = try? decoder.decode(PokemonRoot.self, from: data) else {
            fatalError("Failed to decode \(file) from bundle")
        }
        
        self.root = loadedFile
    }
    
    func getSpecies(id: Int) -> PokemonSpecies? {
        root.data.pokemonspecies.first { $0.id == id }
    }
}
