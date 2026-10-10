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

enum VoiceTranscriptionMode: String, CaseIterable, Identifiable {
    case local
    case cloud

    var id: String { rawValue }

    var title: String {
        switch self {
        case .local: return "On-device (fast)"
        case .cloud: return "Cloud Whisper (accurate)"
        }
    }
}

struct AppEnvironment {
    static let productionWebBaseURL = URL(string: "https://chatty-pal.com")!
    static let productionCMSAPIBaseURL = URL(string: "https://cms.chatty-pal.com/api")!
    static let defaultLocalWebBaseURL = "http://localhost:3000"
    static let defaultLocalCMSAPIBaseURL = "http://localhost:1337/api"

    /// Server-origin selection is locked to Production in Release builds: process-environment
    /// overrides and persisted Local/custom preferences are development affordances that are
    /// only read by Debug builds.
    static var mode: AppEnvironmentMode {
        #if DEBUG
        let envValue = ProcessInfo.processInfo.environment["CHATTY_PAL_ENVIRONMENT"]
        let storedValue = UserDefaults.standard.string(forKey: "appEnvironment")
        return AppEnvironmentMode(rawValue: envValue ?? storedValue ?? AppEnvironmentMode.production.rawValue) ?? .production
        #else
        return .production
        #endif
    }

    private static func processOverrideURL(forKey key: String) -> URL? {
        #if DEBUG
        if let value = ProcessInfo.processInfo.environment[key], let url = URL(string: value) {
            return url
        }
        #endif
        return nil
    }

    static var webBaseURL: URL {
        #if DEBUG
        if let url = processOverrideURL(forKey: "BOT_BASE_URL") {
            return url
        }
        if mode == .local {
            let stored = UserDefaults.standard.string(forKey: "localWebBaseURL") ?? defaultLocalWebBaseURL
            return URL(string: stored) ?? URL(string: defaultLocalWebBaseURL)!
        }
        #endif
        return productionWebBaseURL
    }

    static var pollyBaseURL: URL {
        #if DEBUG
        if let url = processOverrideURL(forKey: "POLLY_BASE_URL") {
            return url
        }
        #endif
        return webBaseURL
    }

    static var voiceTranscriptionMode: VoiceTranscriptionMode {
        let stored = UserDefaults.standard.string(forKey: "voiceTranscriptionMode")
        return VoiceTranscriptionMode(rawValue: stored ?? "") ?? .local
    }

    static var cmsAPIBaseURL: URL {
        #if DEBUG
        if let url = processOverrideURL(forKey: "CMS_API_BASE_URL") {
            return url
        }
        if mode == .local {
            let stored = UserDefaults.standard.string(forKey: "localCMSAPIBaseURL") ?? defaultLocalCMSAPIBaseURL
            return URL(string: stored) ?? URL(string: defaultLocalCMSAPIBaseURL)!
        }
        #endif
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

    func sendMessage(instruction: String, message: String, messages: [BotMessage], exam: ExamMode?) async throws -> BotResponse {
        let payload = BotRequest(
            instruction: instruction,
            message: message,
            messages: messages,
            languageLevel: languageLevel,
            exam: exam
        )

        do {
            return try await send(request(for: baseURL, payload: payload))
        } catch BotServiceError.httpError(let statusCode, _) where statusCode == 404 && baseURL != Self.defaultBaseURL {
            return try await send(request(for: Self.defaultBaseURL, payload: payload))
        }
    }

    func streamMessage(instruction: String, message: String, messages: [BotMessage], exam: ExamMode?) -> AsyncThrowingStream<String, Error> {
        let payload = BotRequest(
            instruction: instruction,
            message: message,
            messages: messages,
            languageLevel: languageLevel,
            stream: true,
            exam: exam
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

struct ExamMode: Encodable, Equatable {
    let mode: String
    let lessonId: String
    let stage: String?
    let briefing: String?
    var learnerContext: String? = nil
}

struct BotRequest: Encodable {
    let instruction: String
    let message: String
    let messages: [BotMessage]
    let languageLevel: String?
    var stream: Bool = false
    var exam: ExamMode? = nil
    // Voice-first app: keep replies short (TTS latency + learner airtime).
    let maxTokens = 150
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
