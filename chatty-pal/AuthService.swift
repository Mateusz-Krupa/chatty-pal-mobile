import Foundation

struct AuthUser: Codable, Hashable {
    let id: Int
    let username: String
    let email: String
}

struct AuthResponse: Codable {
    let jwt: String
    let user: AuthUser
}

struct UserProfileRole: Codable {
    let name: String?
}

// Mirrors the web app's getMe() -> /users/me/?populate=role,user_info,language,teaching,languages
struct UserProfile: Codable {
    let id: Int
    let username: String
    let email: String
    let nativeLanguage: String?
    let language: UserProfileLanguage?
    let languages: [UserProfileLanguage]?
    let role: UserProfileRole?
}

struct UserProfileLanguage: Codable, Hashable, Identifiable {
    let id: Int?
    let code: String?
    let level: String?
}

struct AuthService {
    static var backendURL: URL { AppEnvironment.cmsAPIBaseURL }

    func login(identifier: String, password: String) async throws -> AuthResponse {
        var request = URLRequest(url: Self.backendURL.appendingPathComponent("auth/local"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["identifier": identifier, "password": password]
        request.httpBody = try JSONEncoder().encode(payload)
        return try await send(request)
    }

    func register(username: String, email: String, password: String) async throws -> AuthResponse {
        var request = URLRequest(url: Self.backendURL.appendingPathComponent("auth/local/register"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["username": username, "email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(payload)
        return try await send(request)
    }

    func exchangeOAuthCallback(queryString: String) async throws -> AuthResponse {
        var request = URLRequest(url: Self.backendURL
            .appendingPathComponent("auth/google/callback?\(queryString)"))
        request.httpMethod = "GET"
        return try await send(request)
    }

    /// GET /users/me?populate=... — same as web app's getMe()
    func getMe(jwt: String) async throws -> UserProfile {
        let url = URL(string: "\(Self.backendURL.absoluteString)/users/me/?populate=role,user_info,language,teaching,languages")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw AuthError.badRequest(status: (response as? HTTPURLResponse)?.statusCode ?? -1,
                                       body: String(data: data, encoding: .utf8) ?? "")
        }
        return try JSONDecoder().decode(UserProfile.self, from: data)
    }

    private func send(_ request: URLRequest) async throws -> AuthResponse {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw AuthError.badRequest(status: (response as? HTTPURLResponse)?.statusCode ?? -1, body: body)
        }
        do {
            return try JSONDecoder().decode(AuthResponse.self, from: data)
        } catch {
            throw AuthError.decodingFailed(body: String(data: data, encoding: .utf8) ?? "")
        }
    }
}

enum AuthError: LocalizedError {
    case badRequest(status: Int, body: String)
    case decodingFailed(body: String)

    var errorDescription: String? {
        switch self {
        case .badRequest(let status, let body):
            // Strapi errors look like {"message":[{"messages":[{"message":"..."}]}]}
            return "Login failed (\(status))"
        case .decodingFailed(let body):
            return "Unexpected response from server"
        }
    }
}

// MARK: - Homework (Strapi /homeworks — student flow)

