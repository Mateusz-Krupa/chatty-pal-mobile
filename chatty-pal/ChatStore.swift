import Foundation

protocol ChatStore {
    func load() -> [ChatMessage]
    func save(_ messages: [ChatMessage])
    func flush() async throws
}

extension ChatStore {
    func flush() async throws {}
}

struct TransientChatStore: ChatStore {
    func load() -> [ChatMessage] { [] }
    func save(_ messages: [ChatMessage]) {}
}

// Scope key for per-account storage: the signed-in username, or "guest".
enum DataScope {
    static var current: String {
        let username = UserDefaults.standard.string(forKey: "authUsername")
        return (username?.isEmpty == false) ? username! : "guest"
    }
}

struct LocalChatStore: ChatStore {
    private let scope: String
    private let languageCode: String
    private let level: String

    init(languageCode: String, level: String, scope: String = DataScope.current) {
        self.scope = scope
        self.languageCode = languageCode
        self.level = level
    }

    private var scopedKey: String { "chat.messages.\(scope).\(languageCode).\(level)" }
    private var legacyKey: String { "chat.messages.\(languageCode).\(level)" }
    private var guestKey: String { "chat.messages.guest.\(languageCode).\(level)" }

    func load() -> [ChatMessage] {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: scopedKey) {
            return Self.decode(data)
        }
        // One-shot migrations: legacy unscoped key, then the guest scope
        // (carries a pre-login conversation to the freshly signed-in user).
        for fallback in [legacyKey, guestKey] where scope != "guest" {
            if let data = defaults.data(forKey: fallback) {
                defaults.set(data, forKey: scopedKey)
                defaults.removeObject(forKey: fallback)
                return Self.decode(data)
            }
        }
        return []
    }

    private static func decode(_ data: Data) -> [ChatMessage] {
        (try? JSONDecoder().decode([ChatMessage].self, from: data)) ?? []
    }

    func save(_ messages: [ChatMessage]) {
        let defaults = UserDefaults.standard
        if messages.isEmpty {
            defaults.removeObject(forKey: scopedKey)
            return
        }
        guard let data = try? JSONEncoder().encode(messages) else { return }
        defaults.set(data, forKey: scopedKey)
    }
}
