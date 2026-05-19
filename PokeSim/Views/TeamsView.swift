import SwiftUI
import SwiftData

struct TeamsView: View {
    @Query(sort: \PokemonTeam.sortIndex) var teams: [PokemonTeam]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AuthManager.self) private var authManager
    
    @AppStorage("primaryTeamID") var primaryTeamID: String?
    
    @State private var showCreateTeamSheet = false
    
    @State private var showRenameAlert: Bool = false
    @State private var renameTeamName: String = ""
    @State private var selectedTeam: PokemonTeam?
    
    @State private var syncing: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if teams.isEmpty {
                    noTeams
                } else {
                    List {
                        ForEach(teams) { team in
                            teamCard(team: team)
                        }
                        .onMove { indices, newOffset in
                            var reordered = teams
                            reordered.move(fromOffsets: indices, toOffset: newOffset)
                            for (index, team) in reordered.enumerated() {
                                team.sortIndex = index
                            }
                        }
                        .onDelete { indices in
                            var reordered = teams
                            reordered.remove(atOffsets: indices)
                            for (index, team) in reordered.enumerated() {
                                team.sortIndex = index
                            }
                            
                            for index in indices {
                                Task {
                                    try await authManager.removeTeam(teams[index])
                                    modelContext.delete(teams[index])
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Your Teams")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create Team", systemImage: "plus") {
                        showCreateTeamSheet = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if syncing {
                        ProgressView()
                    } else {
                        Button("Sync", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                            Task {
                                syncing = true
                                let synced = try await authManager.pullTeams(into: modelContext)
                                syncing = false
//                                print("synced \(synced) teams")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateTeamSheet) {
                CreateTeamSheet()
                    .presentationDetents([.height(200)])
            }
            .alert("Rename Team", isPresented: $showRenameAlert) {
                TextField("Team Name", text: $renameTeamName)
                    .textInputAutocapitalization(.words)
                Button("Cancel", role: .cancel) { }
                Button("Save", role: .confirm) {
                    Task {
                        if let team = selectedTeam {
                            team.name = renameTeamName.trimmingCharacters(in: .whitespaces)
                            try await authManager.pushTeam(team)
                        }
                    }
                }
                .disabled(renameTeamName.trimmingCharacters(in: .whitespaces).isEmpty)
            } message: {
                Text("Enter a new name for the team")
            }
            .task {
                syncing = true
                let synced = try? await authManager.pullTeams(into: modelContext)
                syncing = false
//                print("synced \(synced ?? 0) teams")
            }
        }
    }
    
    // MARK: - Team Card
    func teamCard(team: PokemonTeam) -> some View {
        let dominantType = dominantType(for: team)
        let bgAccent = dominantType?.colors.bg ?? Color(.secondarySystemBackground)
        let textAccent = dominantType?.colors.labelAccent(for: colorScheme) ?? .secondary
        let isPrimary = team.id.uuidString == primaryTeamID
        
        return NavigationLink {
            EditTeamView(team: team)
        } label: {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        if isPrimary {
                            Text("PRIMARY TEAM")
                                .font(.caption)
                                .fontWeight(.heavy)
                                .tracking(1.05)
                                .foregroundStyle(textAccent)
                        }
                            
                        
                        Text(team.name)
                            .font(.title3.bold())
                    }
                    Spacer()
                    if isPrimary {
                        Image(systemName: "star.fill")
                            .foregroundStyle(textAccent)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 12)
                
                // Divider
                Rectangle()
                    .fill(textAccent.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                
                // Grid
                ZStack {
                    RadialGradient(
                        colors: [bgAccent.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 140
                    )
                    
                    TeamGrid(team: team, teamNameHidden: true)
                }
                .padding(.bottom, 16)
            }
            .background {
                ZStack {
                    Color(.secondarySystemBackground)
                    
                    LinearGradient(
                        colors: [bgAccent.opacity(0.10), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        isPrimary ? textAccent.opacity(0.5) : textAccent.opacity(0.2),
                        lineWidth: isPrimary ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            if team.id.uuidString == primaryTeamID {
                Button("Unset as Primary", systemImage: "star.fill") {
                    primaryTeamID = nil
                }
                .tint(.yellow)
            } else {
                Button("Set as Primary", systemImage: "star") {
                    primaryTeamID = team.id.uuidString
                }
            }
            
            Divider()
            
            Button("Rename", systemImage: "pencil") {
                selectedTeam = team
                renameTeamName = team.name
                showRenameAlert = true
            }
            
            Button("Delete", systemImage: "trash", role: .destructive) {
                Task {
                    try await deleteTeam(team)
                }
            }
        }
    }
    
    // MARK: - No Teams Card
    var noTeams: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.rectangle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 6) {
                Text("No Teams")
                    .font(.headline)
                Text("Create a new team by pressing the + button at the top right corner")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(36)
        .padding(.bottom, 64)
    }
    
    
    // MARK: - Helper Functions
    func deleteTeam(_ team: PokemonTeam) async throws {
        if let index = teams.firstIndex(of: team) {
            var reordered = teams
            reordered.remove(at: index)
            for (index, team) in reordered.enumerated() {
                team.sortIndex = index
            }
        }
        try await authManager.removeTeam(team)
        modelContext.delete(team)
    }
    
    func dominantType(for team: PokemonTeam) -> PokemonType? {
        let types = team.pokemonList.flatMap {
            PokemonDatabase.shared.types(forPokemonID: $0.id)
        }
        return Dictionary(grouping: types, by: \.type.id)
            .max { $0.value.count < $1.value.count }?
            .value.first?.type
    }
}

#Preview {
    TeamsView()
        .modelContainer(PokemonTeam.preview)
}
