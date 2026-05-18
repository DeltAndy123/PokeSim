import Foundation
import SwiftData

@Model
class PokemonTeam {
    var id: UUID = UUID()
    
    var name: String
    var sortIndex: Int
    
    @Relationship(deleteRule: .cascade) var members: [TeamMember] = []
    
    var orderedMembers: [TeamMember] {
        members.sorted { $0.slot < $1.slot }
    }
    
    var pokemonList: [PokemonRecord] {
        members.compactMap { PokemonDatabase.shared.pokemon(byID: $0.pokemonID) }
    }
    
    init(name: String, sortIndex: Int = 0, members: [TeamMember] = []) {
        self.name = name
        self.sortIndex = sortIndex
        self.members = members
    }
    
    func updateMemberOrders() {
        for (i, member) in orderedMembers.enumerated() {
            member.slot = i
        }
    }
}

extension PokemonTeam {
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(
            for: PokemonTeam.self, TeamMember.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        let team1 = PokemonTeam(name: "First Team", sortIndex: 0, members: [
            TeamMember(pokemonID: 448, moveIDs: [], slot: 0),
            TeamMember(pokemonID: 964, moveIDs: [], slot: 1),
            TeamMember(pokemonID: 959, moveIDs: [], slot: 2),
            TeamMember(pokemonID: 445, moveIDs: [], slot: 3),
            TeamMember(pokemonID: 911, moveIDs: [], slot: 4),
            TeamMember(pokemonID: 909, moveIDs: [], slot: 5)
        ])
        let team2 = PokemonTeam(name: "Second Team", sortIndex: 1, members: [
            TeamMember(pokemonID: 658, moveIDs: [], slot: 0),
            TeamMember(pokemonID: 282, moveIDs: [], slot: 1),
            TeamMember(pokemonID: 959, moveIDs: [], slot: 2),
            TeamMember(pokemonID: 445, moveIDs: [], slot: 3)
        ])
        let team3 = PokemonTeam(name: "Empty Team", sortIndex: 2, members: [])
        
        container.mainContext.insert(team1)
        container.mainContext.insert(team2)
        container.mainContext.insert(team3)
        
        UserDefaults.standard.set(team1.id.uuidString, forKey: "primaryTeamID")
        
        return container
    }
    
    static var previewTeam = PokemonTeam(name: "First Team", sortIndex: 0, members: [
        TeamMember(pokemonID: 448, moveIDs: [], slot: 0),
        TeamMember(pokemonID: 964, moveIDs: [], slot: 1),
        TeamMember(pokemonID: 959, moveIDs: [], slot: 2),
        TeamMember(pokemonID: 445, moveIDs: [], slot: 3),
        TeamMember(pokemonID: 911, moveIDs: [], slot: 4),
        TeamMember(pokemonID: 909, moveIDs: [], slot: 5)
    ])
}
