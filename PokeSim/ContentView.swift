import SwiftUI
import SwiftData

struct ContentView: View {
    let pokemonModel = PokemonModel.shared
    
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
    }
}

#Preview {
    ContentView()
        .modelContainer(PokemonTeam.preview)
}
