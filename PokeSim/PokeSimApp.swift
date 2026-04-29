import SwiftUI
import SwiftData

@main
struct PokeSimApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PokemonTeam.self)
    }
}
