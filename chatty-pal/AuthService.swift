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
        return try decodeAuth(try await send(request))
    }

    func register(username: String, email: String, password: String) async throws -> AuthResponse {
        var request = URLRequest(url: Self.backendURL.appendingPathComponent("auth/local/register"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["username": username, "email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(payload)
        return try decodeAuth(try await send(request))
    }

    func forgotPassword(email: String) async throws {
        var request = URLRequest(url: Self.backendURL.appendingPathComponent("auth/local/forgot-password"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["email": email]
        request.httpBody = try JSONEncoder().encode(payload)
        _ = try await send(request)
    }

    func exchangeOAuthCallback(queryString: String) async throws -> AuthResponse {
        var request = URLRequest(url: Self.backendURL
            .appendingPathComponent("auth/google/callback?\(queryString)"))
        request.httpMethod = "GET"
        return try decodeAuth(try await send(request))
    }

    /// GET /users/me?populate=... — same as web app's getMe()
    func getMe(jwt: String) async throws -> UserProfile {
        let url = URL(string: "\(Self.backendURL.absoluteString)/users/me/?populate=role,user_info,language,teaching,languages")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw AuthError.badRequest(status: (response as? HTTPURLResponse)?.statusCode ?? -1,
                                       body: String(data: data, encoding: .utf8) ?? "")
        }
        return try JSONDecoder().decode(UserProfile.self, from: data)
    }

    private func send(_ request: URLRequest) async throws -> Data {
        var request = request
        request.timeoutInterval = 30
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw AuthError.badRequest(status: (response as? HTTPURLResponse)?.statusCode ?? -1, body: body)
        }
        return data
    }

    private func decodeAuth(_ data: Data) throws -> AuthResponse {
        do {
            return try JSONDecoder().decode(AuthResponse.self, from: data)
        } catch {
            throw AuthError.decodingFailed(body: String(data: data, encoding: .utf8) ?? "")
        }
    }
}

// Extracts a human-readable message from a Strapi error body.
// Handles: {"message":"..."}, {"error":{"message":"..."}}, and the legacy
// array shape {"message":[{"messages":[{"message":"..."}]}]} (incl. nested).
enum StrapiErrorMessages {
    static func first(in body: String) -> String? {
        guard let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) else { return nil }
        return first(in: json)
    }

    private static func first(in json: Any) -> String? {
        if let object = json as? [String: Any] {
            // "message" may be a plain string or a legacy nested array.
            if let messageValue = object["message"] {
                if let message = messageValue as? String, !message.isEmpty {
                    return message
                }
                if let found = first(in: messageValue) { return found }
            }
            if let error = object["error"], let found = first(in: error) {
                return found
            }
            if let messages = object["messages"] as? [Any] {
                for item in messages {
                    if let found = first(in: item) { return found }
                }
            }
            return nil
        }
        if let array = json as? [Any] {
            for item in array {
                if let found = first(in: item) { return found }
            }
        }
        return nil
    }
}

enum AuthError: LocalizedError {
    case badRequest(status: Int, body: String)
    case decodingFailed(body: String)

    var errorDescription: String? {
        switch self {
        case .badRequest(let status, let body):
            return StrapiErrorMessages.first(in: body) ?? "Login failed (\(status))"
        case .decodingFailed:
            return "Unexpected response from server"
        }
    }
}

// MARK: - Homework (Strapi /homeworks — student flow)

