import SwiftUI
import SwiftData

struct BattleView: View {
    @State private var session = BattleSession()
    @Environment(AuthManager.self) private var authManager
    @Query(sort: \PokemonTeam.sortIndex) var teams: [PokemonTeam]
    @State private var movePending = false
    
    var body: some View {
        NavigationStack {
            switch session.phase {
            case .idle:         idleView
            case .waiting:      waitingView
            case .inBattle(let you, let opponent): battleView(you: you, opponent: opponent)
            case .ended(let winner, let reason):   endedView(winner: winner, reason: reason)
            }
        }
        .navigationTitle("Battle")
        .onDisappear { session.disconnect() }
    }
    
    var idleView: some View {
        // picker over teams.filter { $0.remoteID != nil }
        // Button("Find Battle") { session.connect(token: authManager.token() ?? "", teamId: selectedTeam.remoteID!) }
        VStack {}
    }
    
    var waitingView: some View {
        VStack {}
    }
    
    func battleView(you: BattleSideState, opponent: BattleSideState) -> some View {
        VStack {}
    }
    
    func endedView(winner: BattleEndWinner, reason: BattleEndReason) -> some View {
        VStack {}
    }
}

#Preview {
    BattleView()
}
