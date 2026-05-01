import Foundation
import SwiftData

@Model
class PokemonTeam {
    var id: UUID = UUID()
    
    var name: String
    var sortIndex: Int
    var pokemonIDs: [Int]
    
    var pokemonList: [CSVPokemon] {
        pokemonIDs.compactMap { id in
            PokemonCSVReader.shared.pokemon(byId: id)
        }
    }
    
    init(name: String, sortIndex: Int = 0, pokemonIDs: [Int] = []) {
        self.name = name
        self.sortIndex = sortIndex
        self.pokemonIDs = pokemonIDs
    }
}

extension PokemonTeam {
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(
            for: PokemonTeam.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        let team1 = PokemonTeam(name: "First Team", sortIndex: 0, pokemonIDs: [448, 964, 959, 445, 911, 909])
        let team2 = PokemonTeam(name: "Second Team", sortIndex: 1, pokemonIDs: [658, 282, 959, 445])
        let team3 = PokemonTeam(name: "Empty Team", sortIndex: 2, pokemonIDs: [])
        
        container.mainContext.insert(team1)
        container.mainContext.insert(team2)
        container.mainContext.insert(team3)
        
        UserDefaults.standard.set(team1.id.uuidString, forKey: "primaryTeamID")
        
        return container
    }
}
