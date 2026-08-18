import Foundation

struct WhisperTranscriber: AudioTranscribing {
    let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    static let model = "gpt-4o-mini-transcribe"

    func transcribe(wav: Data, language: String) async throws -> String {
        let (body, contentType) = Self.multipartBody(wav: wav, model: Self.model, language: language)
        var request = URLRequest(url: baseURL.appendingNextAPIPath("transcriptions"))
        request.httpMethod = "POST"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(Self.referer(for: baseURL), forHTTPHeaderField: "Referer")
        request.httpBody = body
        let (data, response) = try await session.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200..<300).contains(status) else {
            throw TranscriberError.httpStatus(status)
        }
        return try Self.text(from: data)
    }

    static func multipartBody(wav: Data, model: String, language: String) -> (Data, String) {
        let boundary = "chatty-pal-" + UUID().uuidString
        var body = Data()
        for (name, value) in [("model", model), ("language", language)] {
            body.append("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"\r\n\r\n\(value)\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"audio.wav\"\r\nContent-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        body.append(wav)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return (body, "multipart/form-data; boundary=\(boundary)")
    }

    static func text(from json: Data) throws -> String {
        let decoded = try JSONSerialization.jsonObject(with: json) as? [String: Any]
        guard let raw = decoded?["text"] as? String else {
            throw TranscriberError.emptyTranscript
        }
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            throw TranscriberError.emptyTranscript
        }
        return text
    }

    static func referer(for baseURL: URL) -> String {
        let string = baseURL.absoluteString
        return string.hasSuffix("/") ? string : string + "/"
    }

    enum TranscriberError: LocalizedError {
        case httpStatus(Int)
        case emptyTranscript

        var errorDescription: String? {
            switch self {
            case .httpStatus(let status):
                return "Transcription failed (HTTP \(status))"
            case .emptyTranscript:
                return "Transcription returned no text"
            }
        }
    }
}
