import SwiftUI
import SwiftData

struct BattleView: View {
    @State private var session = BattleSession()
    @Environment(AuthManager.self) private var authManager
    @Query(sort: \PokemonTeam.sortIndex) var teams: [PokemonTeam]
    @State private var selectedTeam: PokemonTeam?

    var body: some View {
        NavigationStack {
            switch session.phase {
            case .idle:
                idleView.navigationTitle("Battle")
            case .waiting:
                waitingView
            case .inBattle(let you, let opponent):
                battleView(you: you, opponent: opponent)
            case .ended(let winner, let reason):
                endedView(winner: winner, reason: reason)
            }
        }
        .toolbar(hideTabBar ? .hidden : .visible, for: .tabBar)
        .onDisappear { session.disconnect() }
    }

    private var hideTabBar: Bool {
        switch session.phase {
        case .idle: false
        default: true
        }
    }

    // MARK: - Idle

    var idleView: some View {
        List {
            ForEach(teams.filter { $0.remoteID != nil }) { team in
                Button {
                    selectedTeam = team
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(team.name).font(.headline)
                            HStack(spacing: 0) {
                                ForEach(team.pokemonList, id: \.id) { pokemon in
                                    AsyncImage(url: pokemon.spriteArtworkUrl) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 40, height: 40)
                                }
                            }
                        }
                        Spacer()
                        if selectedTeam?.id == team.id {
                            Image(systemName: "checkmark").foregroundStyle(.accent)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                guard let token = authManager.token,
                      let teamId = selectedTeam?.remoteID else { return }
                session.connect(token: token, teamId: teamId)
            } label: {
                Text("Join Queue").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedTeam == nil)
            .padding()
            .background(.bar)
        }
    }

    // MARK: - Waiting

    var waitingView: some View {
        VStack(spacing: 20) {
            ProgressView()
            Text("Finding opponent…").foregroundStyle(.secondary)
            Button("Cancel") { session.disconnect() }
                .buttonStyle(.bordered)
        }
    }

    // MARK: - Battle

    func battleView(you: BattleSideState, opponent: BattleSideState) -> some View {
        let youActive = you.pokemon[you.activeSlot]
        let oppActive = opponent.pokemon[opponent.activeSlot]

        return VStack(spacing: 0) {
            HStack(alignment: .bottom) {
                pokemonCard(pokemonId: oppActive.pokemonId, hp: oppActive.hp)
                Spacer()
                AsyncImage(url: spriteURL(oppActive.pokemonId)) { img in
                    img.resizable().interpolation(.none).scaledToFit()
                } placeholder: { ProgressView() }
                .frame(width: 130, height: 130)
            }
            .padding()

            Spacer()

            HStack(alignment: .bottom) {
                AsyncImage(url: spriteURL(youActive.pokemonId)) { img in
                    img.resizable().interpolation(.none).scaledToFit()
                } placeholder: { ProgressView() }
                .frame(width: 130, height: 130)
                Spacer()
                pokemonCard(pokemonId: youActive.pokemonId, hp: youActive.hp)
            }
            .padding()

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(youActive.moves, id: \.self) { moveId in
                    Button {
                        session.selectMove(moveId)
                    } label: {
                        Text(moveName(moveId))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .disabled(session.movePending)
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Forfeit", role: .destructive) { session.forfeit() }
            }
        }
    }

    // MARK: - Ended

    func endedView(winner: BattleEndWinner, reason: BattleEndReason) -> some View {
        VStack(spacing: 16) {
            Text(winner == .you ? "You won!" : "You lost")
                .font(.largeTitle.bold())
            Text(reason.description(winner: winner)).foregroundStyle(.secondary)
            Button("Done") {
                session.disconnect()
            }
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Helpers

    private func spriteURL(_ id: Int) -> URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
    }

    private func maxHP(for pokemonId: Int) -> Int {
        let base = PokemonDatabase.shared.stats(forPokemonID: pokemonId).hp
        return (2 * base + 31) / 2 + 60
    }

    private func moveName(_ id: Int) -> String {
        PokemonDatabase.shared.moveName(forMoveID: id, withLanguage: .en)?.name ?? "Move"
    }

    private func pokemonCard(pokemonId: Int, hp: Int) -> some View {
        let max = maxHP(for: pokemonId)
        let fraction = max > 0 ? Double(hp) / Double(max) : 0
        let name = PokemonDatabase.shared.pokemon(byID: pokemonId)?.name.capitalized ?? "???"
        let color: Color = fraction > 0.5 ? .green : fraction > 0.25 ? .yellow : .red

        return VStack(alignment: .leading, spacing: 4) {
            Text(name).font(.headline)
            Text("\(hp) / \(max)").font(.caption).foregroundStyle(.secondary)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.secondary.opacity(0.25))
                    Capsule().fill(color)
                        .frame(width: geo.size.width * fraction)
                }
            }
            .frame(height: 8)
        }
        .frame(width: 160)
    }
}
