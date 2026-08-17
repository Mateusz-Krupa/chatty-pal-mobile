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

struct LocalChatStore: ChatStore {
    private let key: String

    init(languageCode: String, level: String) {
        key = "chat.messages.\(languageCode).\(level)"
    }

    func load() -> [ChatMessage] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([ChatMessage].self, from: data)) ?? []
    }

    func save(_ messages: [ChatMessage]) {
        if messages.isEmpty {
            UserDefaults.standard.removeObject(forKey: key)
            return
        }
        guard let data = try? JSONEncoder().encode(messages) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
