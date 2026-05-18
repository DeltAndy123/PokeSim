import SwiftData

@Model
class TeamMember {
    var pokemonID: Int
    var moveIDs: [Int]
    
    var team: PokemonTeam?
    var slot: Int
    
    init(pokemonID: Int, moveIDs: [Int], slot: Int) {
        self.pokemonID = pokemonID
        self.moveIDs = moveIDs
        self.slot = slot
    }
}
