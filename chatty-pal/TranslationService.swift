import Foundation

struct TranslationService {
    private let baseURL: URL
    private let jwtCookie: String?
    private let origin: String?
    private let referer: String?
    private let sourceLang: String
    private let targetLang: String

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
        self.sourceLang = env["TRANSLATE_SOURCE_LANG"] ?? "de"
        self.targetLang = env["TRANSLATE_TARGET_LANG"] ?? "en"
    }

    func translate(message: String) async throws -> TranslationResponse {
        var request = URLRequest(url: baseURL.appendingNextAPIPath("translate"))
        request.httpMethod = "POST"
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

        let payload = TranslationRequest(message: message, sourceLang: sourceLang, targetLang: targetLang)
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslationServiceError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw TranslationServiceError.httpError(statusCode: httpResponse.statusCode, body: body)
        }
        do {
            return try JSONDecoder().decode(TranslationResponse.self, from: data)
        } catch {
            if let deepl = try? JSONDecoder().decode(DeepLResponse.self, from: data),
               let first = deepl.translations.first?.text {
                return TranslationResponse(message: first)
            }
            let body = String(data: data, encoding: .utf8) ?? ""
            if let fallback = decodeFallbackMessage(from: body) {
                return TranslationResponse(message: fallback)
            }
            throw TranslationServiceError.decodingFailed(body: body)
        }
    }

    private func decodeFallbackMessage(from body: String) -> String? {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if trimmed.hasPrefix("\""), trimmed.hasSuffix("\""), trimmed.count >= 2 {
            let start = trimmed.index(after: trimmed.startIndex)
            let end = trimmed.index(before: trimmed.endIndex)
            return String(trimmed[start..<end])
        }
        return trimmed
    }
}

struct TranslationRequest: Encodable {
    let message: String
    let sourceLang: String
    let targetLang: String
}

struct TranslationResponse: Decodable {
    let message: String
}

struct DeepLResponse: Decodable {
    struct Translation: Decodable {
        let detected_source_language: String
        let text: String
    }

    let translations: [Translation]
}

enum TranslationServiceError: Error {
    case invalidResponse
    case httpError(statusCode: Int, body: String)
    case decodingFailed(body: String)
}

extension TranslationServiceError: LocalizedError {
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
