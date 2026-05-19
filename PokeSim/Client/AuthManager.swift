import SwiftUI
import SwiftData
import Security

@Observable
@MainActor
class AuthManager {
    private(set) var currentUser: UserProfile?
    var isLoggedIn: Bool { currentUser != nil }
    
    private let client: BackendClient
    
    init() {
        client = BackendClient(baseURL: URL(string: "http://pokesim.deltandy.me/")!)
    }
    
    static func preview(loggedIn: Bool = false) -> AuthManager {
        let manager = AuthManager()
        if loggedIn {
            manager.currentUser = UserProfile(
                id: 1,
                username: "ash",
                createdAt: "2024-01-01T00:00:00Z"
            )
        }
        return manager
    }
    
    // MARK: - Keychain
    private func saveToken(_ token: String) {
        let data = Data(token.utf8)
        
        deleteToken()
        
        let addQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "authToken",
            kSecValueData: data
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }
    
    private func loadToken() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "authToken",
            kSecReturnData: true
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    private func deleteToken() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "authToken"
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Authentication
    func login(into context: ModelContext, username: String, password: String) async throws {
        let token = try await client.login(username: username, password: password)
        saveToken(token)
        
        currentUser = try await client.fetchCurrentUser(token: token)
        let _ = try await pullTeams(into: context)
    }
    
    func register(username: String, password: String) async throws {
        let token = try await client.register(username: username, password: password)
        saveToken(token)
        
        currentUser = try await client.fetchCurrentUser(token: token)
    }
    
    func logout(from context: ModelContext) throws {
        let linked = try context.fetch(FetchDescriptor<PokemonTeam>())
            .filter { $0.remoteID != nil }
        linked.forEach { context.delete($0) }
        deleteToken()
        currentUser = nil
    }
    
    func restoreSession(into context: ModelContext) async throws {
        guard let token = loadToken() else { return }
        
        do {
            currentUser = try await client.fetchCurrentUser(token: token)
            let _ = try await pullTeams(into: context)
        } catch {
            try logout(from: context)
        }
    }
    
    // MARK: - Teams
    /// - Returns: Number of newly added teams
    func pullTeams(into context: ModelContext) async throws -> Int {
        guard let token = loadToken() else { return 0 }
        
        let teams = try await client.fetchTeams(token: token)
        
        let localTeams = try context.fetch(FetchDescriptor<PokemonTeam>())
        let localTeamRemoteIDs = Set(localTeams.compactMap(\.remoteID))
        let maxSort = localTeams.map(\.sortIndex).max() ?? -1
        
        let newTeams = teams.filter {
            !localTeamRemoteIDs.contains($0.id)
        }
        
        var synced = 0
        
        for (index, teamSummary) in newTeams.enumerated() {
            let teamDetails = try await client.fetchTeam(byID: teamSummary.id, token: token)
            let team = PokemonTeam(from: teamDetails, sortOrder: maxSort + 1 + index)
            context.insert(team)
            synced += 1
        }
        
        return synced
    }
    
    func pushTeam(_ team: PokemonTeam) async throws {
        guard 1...6 ~= team.members.count else { return }
        guard team.orderedMembers.allSatisfy({ !$0.moveIDs.isEmpty }) else { return }
        guard let token = loadToken() else { return }
        
        let payload = TeamPayload(
            name: team.name,
            pokemon: team.orderedMembers.map { member in
                TeamPokemonPayload(
                    pokemonId: member.pokemonID,
                    moves: member.moveIDs
                )
            }
        )
        
        if let remoteID = team.remoteID {
            try await client.updateTeam(payload, forID: remoteID, token: token)
        } else {
            let remoteID = try await client.createTeam(payload, token: token)
            team.remoteID = remoteID
        }
    }
    
    func removeTeam(_ team: PokemonTeam) async throws {
        guard let remoteID = team.remoteID else { return }
        guard let token = loadToken() else { return }
        
        try await client.deleteTeam(id: remoteID, token: token)
    }
}
