import Foundation

struct PollySpeechService {
    private let baseURL: URL
    private let voiceId: String

    init() {
        let env = ProcessInfo.processInfo.environment
        let voiceId = env["POLLY_VOICE_ID"] ?? "Vicki"

        self.baseURL = AppEnvironment.pollyBaseURL
        self.voiceId = voiceId
    }

    func synthesizeSpeech(text: String) async throws -> Data {
        try await synthesizeSpeech(text: text, voiceId: nil)
    }

    func synthesizeSpeech(text: String, voiceId: String?) async throws -> Data {
        var request = URLRequest(url: baseURL.appendingNextAPIPath("synthesize-speech"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("audio/mp3", forHTTPHeaderField: "Accept")

        let payload = PollySpeechPayload(text: text, voiceId: voiceId ?? self.voiceId)
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw PollySpeechError.badResponse
        }
        return data
    }
}

struct PollySpeechPayload: Encodable {
    let text: String
    let voiceId: String
}

enum PollySpeechError: Error {
    case badResponse
}
