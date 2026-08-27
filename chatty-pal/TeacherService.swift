import Foundation

struct TeacherService {
    private let baseURL: URL
    private let jwtCookie: String?
    private let origin: String?
    private let referer: String?

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
    }

    func fixText(message: String, language: String) async throws -> TeacherResponse {
        try await fixText(message: message, language: language, context: [])
    }

    static let fixTextModel = "gpt-4o-mini"

    static func fixTextPayload(message: String, language: String, context: [TeacherContextMessage]) -> TeacherRequest {
        var messages = [TeacherContextMessage(role: "system", content: fixInstruction(language: language))]
        messages.append(contentsOf: context)
        return TeacherRequest(message: message, messages: messages, model: fixTextModel)
    }

    func fixText(message: String, language: String, context: [TeacherContextMessage]) async throws -> TeacherResponse {
        try await send(Self.fixTextPayload(message: message, language: language, context: context))
    }

    func examFix(text: String) async throws -> TeacherResponse {
        let framed = """
        You are a friendly examiner for the Goethe-Zertifikat A1 writing exam. \
        The student wrote a short German text for the A1 exam. \
        First give the corrected version of the text (keep it simple, A1 level). \
        Then give 2-3 very short improvement tips. \
        Student text: \(text)
        """
        return try await send(TeacherRequest(message: framed, messages: [], model: nil))
    }

    static func fixInstruction(language: String) -> String {
        """
        You are a \(language) language proofreader for A1-level learners. Return ONLY the corrected version of the final learner message in the conversation.
        Make minimal changes: fix grammar, spelling, capitalization, word choice.
        If a pronoun in the final message refers to a person or thing mentioned earlier in the conversation, use the gender and number that noun requires (der->ihn, die->sie, das->es).
        Never answer questions, never add comments, never translate. If the message is already correct, return it unchanged.
        """
    }

    private func send(_ payload: TeacherRequest) async throws -> TeacherResponse {
        var request = URLRequest(url: baseURL.appendingNextAPIPath("fix-text"))
        request.httpMethod = "POST"
        request.timeoutInterval = 30
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

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TeacherServiceError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw TeacherServiceError.httpError(statusCode: httpResponse.statusCode, body: body)
        }
        do {
            return try JSONDecoder().decode(TeacherResponse.self, from: data)
        } catch {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw TeacherServiceError.decodingFailed(body: body)
        }
    }
}

struct TeacherContextMessage: Encodable {
    let role: String
    let content: String
}

struct TeacherRequest: Encodable {
    let message: String
    let messages: [TeacherContextMessage]
    let model: String?

    private enum CodingKeys: String, CodingKey {
        case message, messages, model
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
        try container.encode(messages, forKey: .messages)
        try container.encodeIfPresent(model, forKey: .model)
    }
}

struct TeacherResponse: Decodable {
    let message: String
}

enum TeacherServiceError: Error {
    case invalidResponse
    case httpError(statusCode: Int, body: String)
    case decodingFailed(body: String)
}

extension TeacherServiceError: LocalizedError {
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
