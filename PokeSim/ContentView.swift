import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            
            Tab("Teams", systemImage: "rectangle.on.rectangle.angled") {
                TeamsView()
            }
            Tab("Battle", systemImage: "shield.lefthalf.filled"){
                BattleView()
            }
            Tab(role: .search) {
                SearchView()
            }
        }
        .task {
//            print(PokemonDatabase.shared.versionGroupDetails(forID: 35)?.combinedNames(forLanguage: .en) ?? "unknown")
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthManager.preview())
        .modelContainer(PokemonTeam.preview)
}
