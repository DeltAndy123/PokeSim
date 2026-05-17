import SwiftUI

struct ValidationError: Decodable {
    let field: String
    let message: String
}

struct ValidationErrorResponse: Decodable {
    let errors: [ValidationError]
}

enum BackendError: LocalizedError {
    case httpError(Int, String)       // generic errors
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

struct BackendClient {
    let baseURL: URL
    
    struct AuthResponse: Decodable {
        let token: String?
        let message: String?
    }
    
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
//            print(body)
            throw BackendError.httpError(http.statusCode, body.message ?? "Unknown error")
        }
        
        return token
    }
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        token: String,
        expectedStatus: Int = 200
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw BackendError.decodingFailed
        }
        
        if http.statusCode == 400 {
            if let validationResponse = try? JSONDecoder().decode(ValidationErrorResponse.self, from: data) {
                throw BackendError.validation(validationResponse.errors)
            }
        }
        
        let body = try JSONDecoder().decode(T.self, from: data)

        guard http.statusCode == expectedStatus else {
            let message = (try? JSONDecoder().decode(AuthResponse.self, from: data))?.message
//            print(body)
            throw BackendError.httpError(http.statusCode, message ?? "Unknown error")
        }

        return body
    }
    
    func login(username: String, password: String) async throws -> String {
        try await authRequest(endpoint: "/auth/login", username: username, password: password, expectedStatus: 200)
    }
    
    func register(username: String, password: String) async throws -> String {
        try await authRequest(endpoint: "/auth/register", username: username, password: password, expectedStatus: 201)
    }
    
    func fetchCurrentUser(token: String) async throws -> UserProfile {
        try await request(endpoint: "/users/me", token: token)
    }
}
