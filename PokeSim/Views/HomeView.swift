import SwiftUI
import SwiftData

struct HomeView: View {
    private let pokemonModel = PokemonModel.shared
    
    @Query var teams: [PokemonTeam]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    @AppStorage("primaryTeamID") var primaryTeamID: String?
    
    private var team: PokemonTeam? {
        teams.first { team in
            team.id.uuidString == primaryTeamID
        }
    }
    
    private var otherTeams: [PokemonTeam] {
        teams.filter { $0.id.uuidString != primaryTeamID ?? "" }
    }
    
    private var dominantType: PokemonType? {
        guard let team else { return nil }
        let types = team.pokemonList.compactMap { $0.defaultForm?.primaryType }
        return Dictionary(grouping: types, by: \.name)
            .max(by: { $0.value.count < $1.value.count })?.value.first
    }
    private var textAccent: Color {
        dominantType?.colors.labelAccent(for: colorScheme) ?? .secondary
    }
    private var bgAccent: Color {
        dominantType?.colors.bg ?? .secondary
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    primaryTeamCard
                    if !otherTeams.isEmpty {
                        otherTeamsSection
                    }
                }
            }
            .contentMargins(2)
            .navigationTitle("Home")
            .padding()
            .background(Color(.systemGroupedBackground))
        }
    }
    
    var primaryTeamCard: some View {
        VStack {
            if let team {
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("PRIMARY TEAM")
                                .font(.caption)
                                .fontWeight(.heavy)
                                .tracking(1.05)
                                .foregroundStyle(textAccent)
                            
                            Text(team.name)
                                .font(.title2.bold())
                        }
                        Spacer()
                        Image(systemName: "star.fill")
                            .foregroundStyle(textAccent)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    
                    Rectangle()
                        .fill(textAccent.opacity(0.2))
                        .frame(height: 1)
                    
                    ZStack {
                        RadialGradient(
                            colors: [bgAccent.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 180
                        )
                        
                        TeamGrid(
                            team: team,
                            pokemonCircleStyle: .background,
                            pokemonClickable: true,
                            teamNameHidden: true
                        )
                        .padding(.vertical, 8)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(bgAccent.opacity(0.3), lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
            } else {
                noPrimary
            }
        }
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 24))
    }
    
    var noPrimary: some View {
        VStack(spacing: 8) {
            Image(systemName: "star.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 6) {
                Text("No Primary Team")
                    .font(.headline)
                Text("Long press a team in the Teams tab and select \"Set as Primary\"")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(36)
    }
    
    
    var otherTeamsSection: some View {
        VStack(alignment: .leading) {
            Text("OTHER TEAMS")
                .font(.caption)
                .fontWeight(.heavy)
                .tracking(1.05)
                .foregroundStyle(.secondary)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(otherTeams) { team in
                        miniTeamCard(team)
                    }
                }
            }
            .contentMargins(2)
        }
        .frame(maxWidth: .infinity)
    }
    
    func miniTeamCard(_ team: PokemonTeam) -> some View {
        let teamAccent = team.pokemonList.compactMap { $0.defaultForm?.primaryType }
            .first?.colors.bg ?? .secondary
        
        return VStack(alignment: .leading, spacing: 4) {
            Text(team.name)
                .font(.subheadline.bold())
                .lineLimit(1)
            
            HStack(spacing: -16) {
                ForEach(team.pokemonList.prefix(3)) { pokemon in
                    Image("\(pokemon.id)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                        .background(teamAccent.opacity(0.15), in: Circle())
                }
                if team.pokemonList.count > 3 {
                    Text("+\(team.pokemonList.count - 3)")
                        .font(.footnote.bold())
                        .frame(width: 36, height: 36)
                        .background(.background.tertiary.opacity(0.85), in: Circle())
                }
                if team.pokemonList.isEmpty {
                    Text("No Pokémon")
                        .font(.footnote.bold())
                        .foregroundStyle(.secondary)
                        .italic()
                        .frame(minHeight: 36)
                }
            }
        }
        .padding()
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(teamAccent.opacity(0.2), lineWidth: 1)
        }
    }
}

#Preview {
    HomeView()
}
