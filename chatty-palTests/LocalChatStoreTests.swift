import XCTest
@testable import chatty_pal

final class LocalChatStoreTests: XCTestCase {
    private let defaults = UserDefaults.standard
    private let legacyKey = "chat.messages.de.B1"
    private let guestStore = LocalChatStore(languageCode: "de", level: "B1", scope: "guest")
    private let aliceStore = LocalChatStore(languageCode: "de", level: "B1", scope: "alice")
    private let bobStore = LocalChatStore(languageCode: "de", level: "B1", scope: "bob")

    override func setUp() {
        super.setUp()
        resetStores()
    }

    override func tearDown() {
        resetStores()
        super.tearDown()
    }

    private func resetStores() {
        guestStore.save([])
        aliceStore.save([])
        bobStore.save([])
        defaults.removeObject(forKey: legacyKey)
    }

    private func save(_ messages: [ChatMessage], to key: String) {
        let data = try! JSONEncoder().encode(messages)
        defaults.set(data, forKey: key)
    }

    func testLoadReturnsEmptyWhenNothingSaved() {
        aliceStore.save([])
        XCTAssertTrue(aliceStore.load().isEmpty)
    }

    func testSaveAndLoadRoundTrip() {
        let messages = [
            ChatMessage(role: .user, message: "Hallo"),
            ChatMessage(role: .assistant, message: "Guten Tag!"),
        ]
        aliceStore.save(messages)

        let loaded = aliceStore.load()
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].message, "Hallo")
        XCTAssertEqual(loaded[1].role, .assistant)
        XCTAssertEqual(loaded[0].id, messages[0].id)
    }

    func testSaveEmptyRemovesStoredMessages() {
        aliceStore.save([ChatMessage(role: .user, message: "temp")])
        XCTAssertEqual(aliceStore.load().count, 1)

        aliceStore.save([])
        XCTAssertTrue(aliceStore.load().isEmpty)
    }

    func testAccountsAreIsolated() {
        aliceStore.save([ChatMessage(role: .user, message: "Alice's chat")])
        XCTAssertTrue(bobStore.load().isEmpty)
        XCTAssertEqual(aliceStore.load().count, 1)
    }

    func testLegacyKeyMigratedToUserScopeOnce() {
        save([ChatMessage(role: .user, message: "Legacy chat")], to: legacyKey)

        let loaded = aliceStore.load()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].message, "Legacy chat")
        XCTAssertNil(defaults.data(forKey: legacyKey))
        XCTAssertNotNil(defaults.data(forKey: "chat.messages.alice.de.B1"))

        // The migrated thread belongs to alice, not bob.
        XCTAssertTrue(bobStore.load().isEmpty)
    }

    func testGuestThreadCarriedToUserOnFirstLoad() {
        let guestChat = [ChatMessage(role: .user, message: "Pre-login chat")]
        guestStore.save(guestChat)

        let loaded = aliceStore.load()
        XCTAssertEqual(loaded.map(\.message), ["Pre-login chat"])
        // Moved, not copied: the guest scope starts fresh afterwards.
        XCTAssertNil(defaults.data(forKey: "chat.messages.guest.de.B1"))
    }

    func testMigrationHappensOnlyOnce() {
        guestStore.save([ChatMessage(role: .user, message: "Old")])
        _ = aliceStore.load() // migrates "Old" into alice's scope

        guestStore.save([ChatMessage(role: .user, message: "New guest data")])

        let loaded = aliceStore.load()
        XCTAssertEqual(loaded.map(\.message), ["Old"])
    }
}
