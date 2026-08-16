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

        let payload = TeacherRequest(message: "Fix to \(language): \(message)")
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

struct TeacherRequest: Encodable {
    let message: String
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
