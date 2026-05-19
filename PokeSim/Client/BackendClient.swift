import SwiftUI

struct ValidationError: Decodable {
    let field: String
    let message: String
}

struct ValidationErrorResponse: Decodable {
    let errors: [ValidationError]
}

enum BackendError: LocalizedError {
    case httpError(Int, String)        // generic errors
    case validation([ValidationError]) // Zod field errors
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .httpError(_, let message): return message
        case .validation(let errors): return errors.map(\.message).joined(separator: "\n")
        case .decodingFailed: return "Unexpected response from server"
        }
    }
}

struct UserProfile: Decodable {
    let id: Int
    let username: String
    let createdAt: String
}

struct RemotePokemon: Decodable {
    let id: Int
    let pokemonId: Int
    let moves: [Int]
}
struct RemoteTeam: Decodable {
    let id: Int
    let name: String
    let pokemon: [RemotePokemon]
}

struct RemoteTeamSummary: Decodable {
    let id: Int
    let name: String
    let pokemon: [Int]
}
struct CreateTeamResponse: Decodable { let teamId: Int }

struct TeamPokemonPayload: Encodable {
    let pokemonId: Int
    let moves: [Int]
}
struct TeamPayload: Encodable {
    let name: String
    let pokemon: [TeamPokemonPayload]
}

struct BackendClient {
    let baseURL: URL
    
    struct AuthResponse: Decodable {
        let token: String?
        let message: String?
    }
    
    
    // MARK: - Helpers
    private func authRequest(endpoint: String, username: String, password: String, expectedStatus: Int) async throws -> String {
        let url = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode([
            "username": username,
            "password": password
        ])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw BackendError.decodingFailed
        }
        
        if http.statusCode == 400 {
            if let validationResponse = try? JSONDecoder().decode(ValidationErrorResponse.self, from: data) {
                throw BackendError.validation(validationResponse.errors)
            }
        }
        
        let body = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        guard http.statusCode == expectedStatus, let token = body.token else {
            throw BackendError.httpError(http.statusCode, body.message ?? "Unknown error")
        }
        
        return token
    }
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        token: String,
        body: (any Encodable)? = nil,
        expectedStatus: Int = 200
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw BackendError.decodingFailed
        }
        
        if http.statusCode == 400 {
            if let validationResponse = try? JSONDecoder().decode(ValidationErrorResponse.self, from: data) {
                throw BackendError.validation(validationResponse.errors)
            }
        }

        guard http.statusCode == expectedStatus else {
            let message = (try? JSONDecoder().decode(AuthResponse.self, from: data))?.message
            throw BackendError.httpError(http.statusCode, message ?? "Unknown error")
        }
        
        let body = try JSONDecoder().decode(T.self, from: data)

        return body
    }
    
    private func requestNoContent(
        endpoint: String,
        method: String,
        token: String,
        body: (any Encodable)? = nil
    ) async throws {
        let url = baseURL.appendingPathComponent(endpoint)

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw BackendError.decodingFailed
        }
        guard http.statusCode == 204 else {
            throw BackendError.httpError(http.statusCode, "Unknown error")
        }
    }
    
    // MARK: - Authentication
    func login(username: String, password: String) async throws -> String {
        try await authRequest(endpoint: "/auth/login", username: username, password: password, expectedStatus: 200)
    }
    
    func register(username: String, password: String) async throws -> String {
        try await authRequest(endpoint: "/auth/register", username: username, password: password, expectedStatus: 201)
    }
    
    func fetchCurrentUser(token: String) async throws -> UserProfile {
        try await request(endpoint: "/users/me", token: token)
    }
    
    
    // MARK: - Teams
    func fetchTeams(token: String) async throws -> [RemoteTeamSummary] {
        try await request(endpoint: "/teams", token: token)
    }
    
    func fetchTeam(byID id: Int, token: String) async throws -> RemoteTeam {
        try await request(endpoint: "/teams/\(id)", token: token)
    }
    
    /// - Returns: Team ID of created team
    func createTeam(_ payload: TeamPayload, token: String) async throws -> Int {
        let response: CreateTeamResponse = try await request(
            endpoint: "/teams",
            method: "POST",
            token: token,
            body: payload,
            expectedStatus: 201
        )
        
        return response.teamId
    }
    
    func updateTeam(_ payload: TeamPayload, forID id: Int, token: String) async throws {
        try await requestNoContent(
            endpoint: "/teams/\(id)",
            method: "PUT",
            token: token,
            body: payload
        )
    }
    
    func deleteTeam(id: Int, token: String) async throws {
        try await requestNoContent(
            endpoint: "/teams/\(id)",
            method: "DELETE",
            token: token
        )
    }
}
