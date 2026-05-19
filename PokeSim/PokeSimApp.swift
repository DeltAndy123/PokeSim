import SwiftUI
import SwiftData

@main
struct PokeSimApp: App {
    @Environment(\.modelContext) private var modelContext
    
    @State private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .task {
                    try? await authManager.restoreSession(into: modelContext)
                }
        }
        .modelContainer(for: [PokemonTeam.self, TeamMember.self])
    }
}
