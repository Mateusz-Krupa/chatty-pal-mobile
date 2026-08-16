import Foundation

enum AppEnvironmentMode: String, CaseIterable, Identifiable {
    case production
    case local

    var id: String { rawValue }

    var title: String {
        switch self {
        case .production: return "Production"
        case .local: return "Local"
        }
    }
}

struct AppEnvironment {
    static let productionWebBaseURL = URL(string: "https://chatty-pal.com")!
    static let productionCMSAPIBaseURL = URL(string: "https://cms.chatty-pal.com/api")!
    static let defaultLocalWebBaseURL = "http://localhost:3000"
    static let defaultLocalCMSAPIBaseURL = "http://localhost:1337/api"

    static var mode: AppEnvironmentMode {
        let envValue = ProcessInfo.processInfo.environment["CHATTY_PAL_ENVIRONMENT"]
        let storedValue = UserDefaults.standard.string(forKey: "appEnvironment")
        return AppEnvironmentMode(rawValue: envValue ?? storedValue ?? AppEnvironmentMode.production.rawValue) ?? .production
    }

    static var webBaseURL: URL {
        if let override = ProcessInfo.processInfo.environment["BOT_BASE_URL"], let url = URL(string: override) {
            return url
        }
        if mode == .local {
            let stored = UserDefaults.standard.string(forKey: "localWebBaseURL") ?? defaultLocalWebBaseURL
            return URL(string: stored) ?? URL(string: defaultLocalWebBaseURL)!
        }
        return productionWebBaseURL
    }

    static var pollyBaseURL: URL {
        if let override = ProcessInfo.processInfo.environment["POLLY_BASE_URL"], let url = URL(string: override) {
            return url
        }
        return webBaseURL
    }

    static var cmsAPIBaseURL: URL {
        if let override = ProcessInfo.processInfo.environment["CMS_API_BASE_URL"], let url = URL(string: override) {
            return url
        }
        if mode == .local {
            let stored = UserDefaults.standard.string(forKey: "localCMSAPIBaseURL") ?? defaultLocalCMSAPIBaseURL
            return URL(string: stored) ?? URL(string: defaultLocalCMSAPIBaseURL)!
        }
        return productionCMSAPIBaseURL
    }
}

struct BotService {
    private static let defaultBaseURL = AppEnvironment.productionWebBaseURL

    private let baseURL: URL
    private let jwtCookie: String?
    private let origin: String?
    private let referer: String?
    private let languageLevel: String?

    init() {
        let env = ProcessInfo.processInfo.environment
        self.baseURL = AppEnvironment.webBaseURL
        let baseURLString = self.baseURL.absoluteString
        self.jwtCookie = env["BOT_JWT"]
        self.origin = env["BOT_ORIGIN"] ?? baseURLString
        if let referer = env["BOT_REFERER"] {
            self.referer = referer
        } else {
            self.referer = baseURLString.hasSuffix("/") ? baseURLString : "\(baseURLString)/"
        }
        self.languageLevel = env["BOT_LANGUAGE_LEVEL"]
    }

    func sendMessage(instruction: String, message: String, messages: [BotMessage]) async throws -> BotResponse {
        let payload = BotRequest(
            instruction: instruction,
            message: message,
            messages: messages,
            languageLevel: languageLevel
        )

        do {
            return try await send(request(for: baseURL, payload: payload))
        } catch BotServiceError.httpError(let statusCode, _) where statusCode == 404 && baseURL != Self.defaultBaseURL {
            return try await send(request(for: Self.defaultBaseURL, payload: payload))
        }
    }

    private func request(for baseURL: URL, payload: BotRequest) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingNextAPIPath("bot"))
        request.httpMethod = "POST"
        request.timeoutInterval = 90
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        if let jwtCookie, !jwtCookie.isEmpty {
            request.setValue("jwt=\(jwtCookie)", forHTTPHeaderField: "Cookie")
        }
        if let origin, !origin.isEmpty {
            request.setValue(origin, forHTTPHeaderField: "Origin")
        }
        if let referer, !referer.isEmpty {
            request.setValue(referer, forHTTPHeaderField: "Referer")
        }
        request.httpBody = try JSONEncoder().encode(payload)
        return request
    }

    private func send(_ request: URLRequest) async throws -> BotResponse {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BotServiceError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw BotServiceError.httpError(statusCode: httpResponse.statusCode, body: body)
        }
        do {
            return try JSONDecoder().decode(BotResponse.self, from: data)
        } catch {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw BotServiceError.decodingFailed(body: body)
        }
    }
}

extension URL {
    func appendingNextAPIPath(_ endpoint: String) -> URL {
        var base = self
        if base.path.split(separator: "/").last == "api" {
            base.deleteLastPathComponent()
        }
        return base.appendingPathComponent("api").appendingPathComponent(endpoint)
    }
}

struct BotRequest: Encodable {
    let instruction: String
    let message: String
    let messages: [BotMessage]
    let languageLevel: String?
}

struct BotMessage: Encodable {
    let role: String
    let content: String
}

struct BotResponse: Decodable {
    let message: String
}

enum BotServiceError: Error {
    case invalidResponse
    case httpError(statusCode: Int, body: String)
    case decodingFailed(body: String)
}

extension BotServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let body):
            if body.isEmpty {
                return "Server error (\(statusCode))"
            }
            return "Server error (\(statusCode)): \(body)"
        case .decodingFailed(let body):
            if body.isEmpty {
                return "Failed to decode response"
            }
            return "Failed to decode response: \(body)"
        }
    }
}
