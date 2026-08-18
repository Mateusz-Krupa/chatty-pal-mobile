import Foundation

enum BotStreamParser {
    /// Returns the text delta from an SSE line, or nil for non-data/role-only lines.
    static func delta(fromLine line: String) -> String? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("data:") else { return nil }
        let payload = trimmed.dropFirst(5).trimmingCharacters(in: .whitespaces)
        guard payload != "[DONE]", let data = payload.data(using: .utf8) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let delta = choices.first?["delta"] as? [String: Any],
              let content = delta["content"] as? String else {
            return nil
        }
        return content
    }

    static func isDone(_ line: String) -> Bool {
        line.trimmingCharacters(in: .whitespaces) == "data: [DONE]"
    }
}
