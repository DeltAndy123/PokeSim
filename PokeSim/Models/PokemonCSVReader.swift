import Foundation
import CodableCSV

class PokemonCSVReader {
    static let shared = PokemonCSVReader()
    
    let pokemonList = decodeCSV(CSVPokemon.self, fromPath: "pokemon")
    let pokemonSpecies = decodeCSV(CSVPokemonSpecies.self, fromPath: "pokemon_species")
    let pokemonSpeciesNames = decodeCSV(CSVPokemonSpeciesName.self, fromPath: "pokemon_species_names")
    let pokemonForms = decodeCSV(CSVPokemonForm.self, fromPath: "pokemon_forms")
    let pokemonFormNames = decodeCSV(CSVPokemonFormName.self, fromPath: "pokemon_form_names")
    let pokemonTypes = decodeCSV(CSVPokemonType.self, fromPath: "pokemon_types")
    let pokemonAbilities = decodeCSV(CSVPokemonAbility.self, fromPath: "pokemon_abilities")
    let abilityNames = decodeCSV(CSVAbilityNames.self, fromPath: "ability_names")
    let pokemonStats = decodeCSV(CSVPokemonStat.self, fromPath: "pokemon_stats")
    
    private let pokemonByID: [Int: CSVPokemon]
    private let speciesByID: [Int: CSVPokemonSpecies]
    
    init() {
        self.pokemonByID = Dictionary(uniqueKeysWithValues: pokemonList.map { ($0.id, $0) })
        self.speciesByID = Dictionary(uniqueKeysWithValues: pokemonSpecies.map { ($0.id, $0) })
    }
    
    private static func decodeCSV<T>(_ type: T.Type, fromPath urlStr: String) -> [T] where T: Decodable {
        guard let url = Bundle.main.url(forResource: urlStr, withExtension: "csv") else {
            fatalError("Failed to locate \(urlStr) in bundle")
        }
        
        let pokemonDecoder = CSVDecoder {
            $0.headerStrategy = .firstLine
            $0.boolStrategy = .numeric
            $0.bufferingStrategy = .keepAll
        }
        
        do {
            let pokemon = try pokemonDecoder.decode([T].self, from: url)
            return pokemon
        } catch {
            print("Failed to decode \(urlStr).csv: \(error)")
            return []
        }
    }
    
    func pokemon(byId id: Int) -> CSVPokemon? {
        pokemonByID[id]
    }
    func species(byId id: Int) -> CSVPokemonSpecies? {
        speciesByID[id]
    }
    
    func searchSpecies(for query: String) -> [CSVPokemonSpecies] {
        if (query.isEmpty) { return pokemonSpecies }

        return pokemonSpecies.filter { species in
            species.identifier.localizedCaseInsensitiveContains(query) ||
            species.speciesAllNames(from: pokemonSpeciesNames).contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
}
