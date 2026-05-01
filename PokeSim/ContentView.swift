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
            
            Tab(role: .search) {
                SearchView()
            }
        }
        .task {
//            PokemonCSVReader()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PokemonTeam.preview)
}
