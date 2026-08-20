import XCTest
@testable import chatty_pal

final class ConversationStoreTests: XCTestCase {
    private func withAuthUsername(_ username: String?, _ body: () -> Void) {
        let standard = UserDefaults.standard
        let original = standard.string(forKey: "authUsername")
        if let username {
            standard.set(username, forKey: "authUsername")
        } else {
            standard.removeObject(forKey: "authUsername")
        }
        defer {
            if let original {
                standard.set(original, forKey: "authUsername")
            } else {
                standard.removeObject(forKey: "authUsername")
            }
        }
        body()
    }

    private func freshDefaults() -> UserDefaults {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        return defaults
    }

    // MARK: - CRUD

    @MainActor
    func testStartNewAndAppendUpdatesTitle() {
        let store = ConversationStore(defaults: freshDefaults())
        let conversation = store.startNew(languageCode: "de", level: "B1")
        XCTAssertEqual(conversation.title, "New chat")
        XCTAssertEqual(conversation.kind, .free)
        XCTAssertEqual(conversation.messages.count, 0)

        store.appendMessage(ChatMessage(role: .user, message: "Hallo, wie geht es dir?"), to: conversation.id)
        let updated = store.conversation(conversation.id)!
        XCTAssertEqual(updated.title, "Hallo, wie geht es dir?")
        XCTAssertEqual(updated.messages.count, 1)
    }

    @MainActor
    func testExplicitTitleIsKept() {
        let store = ConversationStore(defaults: freshDefaults())
        let conversation = store.startNew(languageCode: "de", level: "B1", kind: .rolePlay, title: "At the bakery", situationName: "At the bakery")
        store.appendMessage(ChatMessage(role: .user, message: "Hi!"), to: conversation.id)
        XCTAssertEqual(store.conversation(conversation.id)?.title, "At the bakery")
    }

    @MainActor
    func testPersistenceRoundTrip() {
        let defaults = freshDefaults()
        let store = ConversationStore(defaults: defaults)
        let conversation = store.startNew(languageCode: "de", level: "B1")
        store.appendMessage(ChatMessage(role: .user, message: "a"), to: conversation.id)
        store.appendMessage(ChatMessage(role: .assistant, message: "b"), to: conversation.id)

        let reloaded = ConversationStore(defaults: defaults)
        let restored = reloaded.conversation(conversation.id)!
        XCTAssertEqual(restored.title, "a")
        XCTAssertEqual(restored.messages.map(\.message), ["a", "b"])
    }

    @MainActor
    func testMessageCap() {
        let store = ConversationStore(defaults: freshDefaults())
        let conversation = store.startNew(languageCode: "de", level: "A1")
        for i in 0..<220 {
            store.appendMessage(ChatMessage(role: .user, message: "msg \(i)"), to: conversation.id)
        }
        let messages = store.conversation(conversation.id)!.messages
        XCTAssertEqual(messages.count, 200)
        XCTAssertEqual(messages.first?.message, "msg 20")
        XCTAssertEqual(messages.last?.message, "msg 219")
    }

    @MainActor
    func testMarkCompletedReturnsTrueOnce() {
        let store = ConversationStore(defaults: freshDefaults())
        let conversation = store.startNew(languageCode: "de", level: "B1", kind: .rolePlay, title: "Bank")
        XCTAssertTrue(store.markCompleted(conversation.id))
        XCTAssertFalse(store.markCompleted(conversation.id))
        XCTAssertTrue(store.conversation(conversation.id)?.completed == true)
    }

    // MARK: - Scoping

    @MainActor
    func testAccountsAreIsolated() {
        let defaults = freshDefaults()
        withAuthUsername("alice") {
            let store = ConversationStore(defaults: defaults)
            let conversation = store.startNew(languageCode: "de", level: "B1")
            store.appendMessage(ChatMessage(role: .user, message: "hi"), to: conversation.id)
        }
        withAuthUsername("bob") {
            let store = ConversationStore(defaults: defaults)
            XCTAssertTrue(store.conversations.isEmpty)
        }
        withAuthUsername("alice") {
            let store = ConversationStore(defaults: defaults)
            XCTAssertEqual(store.conversations.count, 1)
        }
    }

    // MARK: - Legacy migration

    @MainActor
    func testLegacyChatThreadsMigratedAndRemoved() {
        let defaults = freshDefaults()
        let messages = [
            ChatMessage(role: .user, message: "old one"),
            ChatMessage(role: .assistant, message: "old two"),
        ]
        defaults.set(try! JSONEncoder().encode(messages), forKey: "chat.messages.guest.de.B1")

        withAuthUsername(nil) {
            let store = ConversationStore(defaults: defaults)
            XCTAssertEqual(store.conversations.count, 1)
            let migrated = store.conversations.first!
            XCTAssertEqual(migrated.title, "Chatty Pal")
            XCTAssertEqual(migrated.messages.map(\.message), ["old one", "old two"])
            XCTAssertNil(defaults.data(forKey: "chat.messages.guest.de.B1"))
        }
    }

    @MainActor
    func testNoLegacyDataMeansNoImport() {
        let defaults = freshDefaults()
        withAuthUsername(nil) {
            let store = ConversationStore(defaults: defaults)
            XCTAssertTrue(store.conversations.isEmpty)
        }
    }

    // MARK: - Adapter

    @MainActor
    func testAdapterRoundTrip() {
        let store = ConversationStore(defaults: freshDefaults())
        let conversation = store.startNew(languageCode: "de", level: "B1")
        let adapter = ConversationChatStore(store: store, conversationID: conversation.id)

        XCTAssertTrue(adapter.load().isEmpty)
        let messages = [
            ChatMessage(role: .user, message: "a"),
            ChatMessage(role: .assistant, message: "b"),
        ]
        adapter.save(messages)
        XCTAssertEqual(adapter.load().map(\.message), ["a", "b"])
        XCTAssertEqual(store.conversation(conversation.id)?.messages.map(\.message), ["a", "b"])
    }

    // MARK: - Bot memory

    @MainActor
    func testBotMemorySaveAndReload() {
        let defaults = freshDefaults()
        let memory = BotMemoryStore(defaults: defaults)
        XCTAssertNil(memory.summary(for: "de"))

        memory.save("Learner likes pizza and football.", for: "de")
        XCTAssertEqual(memory.summary(for: "de"), "Learner likes pizza and football.")

        let reloaded = BotMemoryStore(defaults: defaults)
        XCTAssertEqual(reloaded.summary(for: "de"), "Learner likes pizza and football.")
    }

    @MainActor
    func testBotMemoryTruncatesLongSummaries() {
        let defaults = freshDefaults()
        let memory = BotMemoryStore(defaults: defaults)
        let long = String(repeating: "a", count: 700)
        memory.save(long, for: "de")
        XCTAssertEqual(memory.summary(for: "de")?.count, 600)
    }

    @MainActor
    func testBotMemoryIgnoresBlank() {
        let defaults = freshDefaults()
        let memory = BotMemoryStore(defaults: defaults)
        memory.save("   ", for: "de")
        XCTAssertNil(memory.summary(for: "de"))
    }
}
