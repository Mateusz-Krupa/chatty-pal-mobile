import Foundation

struct PhraseProgress: Codable, Equatable {
    let phraseId: String
    let bestScore: Int
    let latestScore: Int
    let transcript: String
    var passed: Bool { bestScore >= 80 }
}

struct LessonProgress: Codable, Equatable {
    let lessonId: String
    let catalogRevision: String
    let generation: Int
    let completedAt: String?
    let completionSource: String?
    let phrases: [PhraseProgress]
    var isCompleted: Bool { completedAt != nil }
    var passedCount: Int { phrases.filter(\.passed).count }
}

struct ShadowingAttempt: Codable, Equatable, Identifiable {
    let clientAttemptId: String
    let lessonId: String
    let catalogRevision: String
    let generation: Int
    let phraseId: String
    let transcript: String
    let score: Int
    let scoringVersion: String
    var id: String { clientAttemptId }
}

enum ProgressAPIError: Error, LocalizedError {
    case request(Int)
    var errorDescription: String? {
        switch self {
        case .request(401), .request(403): return "Sign in again to save your progress."
        case .request(409): return "Progress changed on another device. Reload before trying again."
        default: return "Progress could not be saved. Please retry."
        }
    }
    var isConflict: Bool { if case .request(409) = self { return true }; return false }
}

@MainActor
protocol LearningProgressAPI {
    func userID(jwt: String) async throws -> Int
    func fetch(jwt: String) async throws -> [LessonProgress]
    func save(_ attempt: ShadowingAttempt, jwt: String) async throws -> LessonProgress
    func command(lessonID: String, generation: Int, reset: Bool, jwt: String) async throws -> LessonProgress
}

struct LearningProgressService: LearningProgressAPI {
    let baseURL: URL = AuthService.backendURL
    private struct ListResponse: Decodable { let progress: [LessonProgress] }
    private struct Command: Encodable { let catalogRevision: String; let generation: Int }

    func userID(jwt: String) async throws -> Int {
        struct Identity: Decodable { let id: Int }
        let user: Identity = try await request(path: "users/me", jwt: jwt)
        return user.id
    }

    func fetch(jwt: String) async throws -> [LessonProgress] {
        let response: ListResponse = try await request(
            path: "learning-progress?catalogRevision=\(MobileLearningCatalog.progressRevision)", jwt: jwt)
        return response.progress
    }

    func save(_ attempt: ShadowingAttempt, jwt: String) async throws -> LessonProgress {
        try await request(path: "learning-progress/\(attempt.lessonId)/attempts", method: "POST",
                          body: JSONEncoder().encode(attempt), jwt: jwt)
    }

    func command(lessonID: String, generation: Int, reset: Bool, jwt: String) async throws -> LessonProgress {
        try await request(path: "learning-progress/\(lessonID)/\(reset ? "reset" : "completion")",
                          method: reset ? "POST" : "PUT",
                          body: JSONEncoder().encode(Command(catalogRevision: MobileLearningCatalog.progressRevision,
                                                             generation: generation)), jwt: jwt)
    }

    private func request<T: Decodable>(path: String, method: String = "GET", body: Data? = nil, jwt: String) async throws -> T {
        let base = baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(base)/\(path)") else { throw ProgressAPIError.request(400) }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.timeoutInterval = 30
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200..<300).contains(status) else { throw ProgressAPIError.request(status) }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
