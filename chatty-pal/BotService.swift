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

    func streamMessage(instruction: String, message: String, messages: [BotMessage]) -> AsyncThrowingStream<String, Error> {
        let payload = BotRequest(
            instruction: instruction,
            message: message,
            messages: messages,
            languageLevel: languageLevel,
            stream: true
        )
        return AsyncThrowingStream { continuation in
            let task = Task {
                var current = try self.request(for: self.baseURL, payload: payload)
                while true {
                    do {
                        try await Self.pumpStream(for: current) { delta in
                            continuation.yield(delta)
                        }
                        continuation.finish()
                        return
                    } catch BotServiceError.httpError(let statusCode, _) where statusCode == 404 && self.baseURL != Self.defaultBaseURL {
                        current = try self.request(for: Self.defaultBaseURL, payload: payload)
                        continue
                    } catch {
                        continuation.finish(throwing: error)
                        return
                    }
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private static func pumpStream(for request: URLRequest, onDelta: @escaping (String) -> Void) async throws {
        let (bytes, response): (URLSession.AsyncBytes, URLResponse)
        do {
            (bytes, response) = try await URLSession.shared.bytes(for: request)
        } catch {
            let underlying = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            throw BotServiceError.connectionFailed(url: request.url?.absoluteString ?? "?", underlying: underlying)
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BotServiceError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw BotServiceError.httpError(statusCode: httpResponse.statusCode, body: "")
        }
        for try await line in bytes.lines {
            if Task.isCancelled { return }
            if BotStreamParser.isDone(line) { return }
            if let delta = BotStreamParser.delta(fromLine: line) {
                onDelta(delta)
            }
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
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            let underlying = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            throw BotServiceError.connectionFailed(url: request.url?.absoluteString ?? "?", underlying: underlying)
        }
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
    var stream: Bool = false
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
    case connectionFailed(url: String, underlying: String)
    case httpError(statusCode: Int, body: String)
    case decodingFailed(body: String)
}

extension BotServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .connectionFailed(let url, let underlying):
            return "Could not reach \(url): \(underlying)"
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
