import SwiftUI
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
    func login(username: String, password: String) async throws {
        let token = try await client.login(username: username, password: password)
        saveToken(token)
        
        currentUser = try await client.fetchCurrentUser(token: token)
    }
    
    func register(username: String, password: String) async throws {
        let token = try await client.register(username: username, password: password)
        saveToken(token)
        
        currentUser = try await client.fetchCurrentUser(token: token)
    }
    
    func logout() {
        deleteToken()
        currentUser = nil
    }
    
    func restoreSession() async {
        guard let token = loadToken() else { return }
        
        do {
            currentUser = try await client.fetchCurrentUser(token: token)
        } catch {
            logout()
        }
    }
}
