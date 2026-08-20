import Foundation
import Observation

struct Conversation: Identifiable, Codable {
    enum Kind: String, Codable {
        case free
        case rolePlay
    }

    let id: UUID
    var title: String
    var kind: Kind
    var languageCode: String
    var level: String
    var messages: [ChatMessage]
    var createdAt: Date
    var updatedAt: Date
    var situationName: String? = nil
    var completed: Bool = false
}

@MainActor
@Observable
final class ConversationStore {
    static let shared = ConversationStore()

    private(set) var conversations: [Conversation] = []
    var activeID: UUID?

    private let defaults: UserDefaults
    private var scope: String
    private let maxMessages = 200

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.scope = DataScope.current
        self.conversations = Self.load(from: defaults, scope: self.scope)
        self.migrateLegacyChatThreads()
    }

    // Reload after a login/logout switch so the store tracks the new account.
    func scopeDidChange() {
        scope = DataScope.current
        conversations = Self.load(from: defaults, scope: scope)
        activeID = nil
        migrateLegacyChatThreads()
    }

    private var storageKey: String { "conversations.\(scope)" }

    var sorted: [Conversation] {
        conversations.sorted { $0.updatedAt > $1.updatedAt }
    }

    func conversation(_ id: UUID) -> Conversation? {
        conversations.first { $0.id == id }
    }

    func mostRecent(languageCode: String, level: String) -> Conversation? {
        sorted.first { $0.languageCode == languageCode && $0.level == level }
    }

    @discardableResult
    func startNew(
        languageCode: String,
        level: String,
        kind: Conversation.Kind = .free,
        title: String = "New chat",
        situationName: String? = nil
    ) -> Conversation {
        let now = Date()
        let conversation = Conversation(
            id: UUID(),
            title: title,
            kind: kind,
            languageCode: languageCode,
            level: level,
            messages: [],
            createdAt: now,
            updatedAt: now,
            situationName: situationName
        )
        conversations.append(conversation)
        activeID = conversation.id
        save()
        return conversation
    }

    func setActive(_ id: UUID) {
        activeID = id
        save()
    }

    func appendMessage(_ message: ChatMessage, to id: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        var conversation = conversations[index]
        conversation.messages.append(message)
        conversation.messages = Array(conversation.messages.suffix(maxMessages))
        conversation.updatedAt = Date()
        if conversation.title == "New chat", message.role == .user {
            conversation.title = String(message.message.prefix(40))
        }
        conversations[index] = conversation
        save()
    }

    func replaceMessages(_ messages: [ChatMessage], for id: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        var conversation = conversations[index]
        conversation.messages = Array(messages.suffix(maxMessages))
        if conversation.title == "New chat",
           let first = messages.first(where: { $0.role == .user }) {
            conversation.title = String(first.message.prefix(40))
        }
        conversation.updatedAt = Date()
        conversations[index] = conversation
        save()
    }

    @discardableResult
    func markCompleted(_ id: UUID) -> Bool {
        guard let index = conversations.firstIndex(where: { $0.id == id }),
              !conversations[index].completed else { return false }
        conversations[index].completed = true
        save()
        return true
    }

    // MARK: - Persistence

    private func save() {
        if let encoded = try? JSONEncoder().encode(conversations) {
            defaults.set(encoded, forKey: storageKey)
        }
    }

    private static func load(from defaults: UserDefaults, scope: String) -> [Conversation] {
        guard let data = defaults.data(forKey: "conversations.\(scope)") else { return [] }
        return (try? JSONDecoder().decode([Conversation].self, from: data)) ?? []
    }

    // One-shot import of pre-conversation chat threads (from the two previous
    // storage schemes) into "Chatty Pal" conversations. Source keys are removed.
    private func migrateLegacyChatThreads() {
        var imported = 0
        for language in LanguageConfig.all.keys {
            for level in LanguageConfig.levels {
                let keys = [
                    "chat.messages.\(scope).\(language).\(level)",
                    "chat.messages.\(language).\(level)",
                ]
                for key in keys where defaults.data(forKey: key) != nil {
                    let data = defaults.data(forKey: key)!
                    guard let messages = try? JSONDecoder().decode([ChatMessage].self, from: data),
                          !messages.isEmpty else { continue }
                    let now = Date()
                    conversations.append(Conversation(
                        id: UUID(),
                        title: "Chatty Pal",
                        kind: .free,
                        languageCode: language,
                        level: level,
                        messages: Array(messages.suffix(maxMessages)),
                        createdAt: now,
                        updatedAt: now
                    ))
                    defaults.removeObject(forKey: key)
                    imported += 1
                }
            }
        }
        if imported > 0 {
            save()
        }
    }
}

// Adapts a single conversation to the ChatStore protocol so ChatEngine
// stays storage-agnostic.
@MainActor
struct ConversationChatStore: @preconcurrency ChatStore {
    private let store: ConversationStore
    private let conversationID: UUID

    init(store: ConversationStore, conversationID: UUID) {
        self.store = store
        self.conversationID = conversationID
    }

    func load() -> [ChatMessage] {
        store.conversation(conversationID)?.messages ?? []
    }

    func save(_ messages: [ChatMessage]) {
        store.replaceMessages(messages, for: conversationID)
    }
}

// Rolling per-language summary of the learner, injected into the bot persona.
@MainActor
@Observable
final class BotMemoryStore {
    static let shared = BotMemoryStore()

    private(set) var cache: [String: String] = [:]

    private let defaults: UserDefaults
    private var scope: String
    private let maxSummaryLength = 600

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.scope = DataScope.current
        self.cache = Self.load(from: defaults, scope: self.scope)
    }

    func scopeDidChange() {
        scope = DataScope.current
        cache = Self.load(from: defaults, scope: scope)
    }

    private var storageKey: String { "botmemory.\(scope)" }

    func summary(for languageCode: String) -> String? {
        cache[languageCode]
    }

    func save(_ summary: String, for languageCode: String) {
        let trimmed = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        cache[languageCode] = String(trimmed.prefix(maxSummaryLength))
        if let encoded = try? JSONEncoder().encode(cache) {
            defaults.set(encoded, forKey: storageKey)
        }
    }

    private static func load(from defaults: UserDefaults, scope: String) -> [String: String] {
        guard let data = defaults.data(forKey: "botmemory.\(scope)") else { return [:] }
        return (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
    }
}
