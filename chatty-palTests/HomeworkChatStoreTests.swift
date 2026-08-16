import XCTest
@testable import chatty_pal

final class HomeworkChatStoreTests: XCTestCase {
    func testLoadMapsRolesAndSkipsUnknownOrEmpty() {
        let store = HomeworkChatStore(homeworkMessages: [
            HomeworkMessage(role: "user", content: "hi", author: "Me"),
            HomeworkMessage(role: "system", content: "tip", author: "Teacher"),
            HomeworkMessage(role: "system", content: "noise", author: "SYSTEM"),
            HomeworkMessage(role: "unknown", content: "x", author: "x"),
            HomeworkMessage(role: "user", content: "", author: "Me"),
            HomeworkMessage(role: "assistant", content: nil, author: "Vicki"),
            HomeworkMessage(role: "suggestion", content: "say hi", author: "Help")
        ])
        let loaded = store.load()
        XCTAssertEqual(loaded.map(\.role), [.user, .teacher, .suggestion])
        XCTAssertEqual(loaded.map(\.message), ["hi", "tip", "say hi"])
    }

    func testSaveIsNoOpBecauseServerIsSourceOfTruth() {
        let store = HomeworkChatStore(homeworkMessages: [])
        store.save([ChatMessage(role: .user, message: "x")])
        XCTAssertTrue(store.load().isEmpty)
    }

    func testFinishMappingKeepsRolesAndAuthors() {
        let mapped = HomeworkMessageMapper.toHomeworkMessages(
            [
                ChatMessage(role: .user, message: "a"),
                ChatMessage(role: .assistant, message: "b"),
                ChatMessage(role: .teacher, message: "c")
            ],
            voice: "Vicki"
        )
        XCTAssertEqual(mapped.map(\.role), ["user", "assistant", "system"])
        XCTAssertEqual(mapped.map(\.author), ["Me", "Vicki", "Teacher"])
    }
}
