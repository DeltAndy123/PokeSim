import SwiftUI
import SwiftData

@main
struct PokeSimApp: App {
    @State private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .task { await authManager.restoreSession() }
        }
        .modelContainer(for: [PokemonTeam.self, TeamMember.self])
    }
}
