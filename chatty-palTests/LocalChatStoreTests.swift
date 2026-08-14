import XCTest
@testable import chatty_pal

final class LocalChatStoreTests: XCTestCase {
    private let store = LocalChatStore(languageCode: "test", level: "A1")

    override func tearDown() {
        store.save([])
        super.tearDown()
    }

    func testLoadReturnsEmptyWhenNothingSaved() {
        store.save([])
        XCTAssertTrue(store.load().isEmpty)
    }

    func testSaveAndLoadRoundTrip() {
        let messages = [
            ChatMessage(role: .user, message: "Hallo"),
            ChatMessage(role: .assistant, message: "Guten Tag!"),
        ]
        store.save(messages)

        let loaded = store.load()
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].message, "Hallo")
        XCTAssertEqual(loaded[1].role, .assistant)
        XCTAssertEqual(loaded[0].id, messages[0].id)
    }

    func testSaveEmptyRemovesStoredMessages() {
        store.save([ChatMessage(role: .user, message: "temp")])
        XCTAssertEqual(store.load().count, 1)

        store.save([])
        XCTAssertTrue(store.load().isEmpty)
    }
}
