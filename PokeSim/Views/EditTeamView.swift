import SwiftUI
import SwiftData

struct EditTeamView: View {
    @Environment(AuthManager.self) private var authManager
    
    @State var team: PokemonTeam
    
    private struct MemberSlot: Identifiable {
        let id: Int
    }
    
    @State private var selectedMemberIndex: MemberSlot?

    var body: some View {
        ScrollView {
            VStack {
                TeamGrid(
                    team: team,
                    pokemonCircleStyle: .background,
                    teamNameHidden: true
                ) { index in
                    selectedMemberIndex = MemberSlot(id: index)
                } onReorder: { from, to in
                    Task {
                        var ordered = team.orderedMembers
                        ordered.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
                        for (i, member) in ordered.enumerated() {
                            member.slot = i
                        }
                        try await authManager.pushTeam(team)
                    }
                } pokemonContextMenu: { index in
                    Button("Remove", systemImage: "trash", role: .destructive) {
                        Task {
                            let memberToRemove = team.orderedMembers[index]
                            team.members.removeAll { $0 === memberToRemove }
                            team.updateMemberOrders()
                            try await authManager.pushTeam(team)
                        }
                    }
                }
                .padding(.vertical, 24)
                .background(.background.secondary, in: RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(team.name)
        .sheet(item: $selectedMemberIndex) { slot in
            SlotEditorSheet(team: team, memberIndex: slot.id)
        }
    }
}

struct pokemonRow {

    var body: some View {
        HStack {
            VStack {
                
            }
            HStack {
                
            }
            HStack {
                
            }
        }
        .frame(width: .infinity)
//        .background(.)
    }
}

#Preview {
    let team = PokemonTeam(name: "Your Team", members: [
        TeamMember(pokemonID: 448, moveIDs: [], slot: 0),
        TeamMember(pokemonID: 964, moveIDs: [], slot: 1),
        TeamMember(pokemonID: 959, moveIDs: [], slot: 2),
        TeamMember(pokemonID: 445, moveIDs: [], slot: 3)
    ])
    
    NavigationStack {
        EditTeamView(team: team)
            .environment(AuthManager.preview())
            .modelContainer(PokemonTeam.preview)
    }
}
