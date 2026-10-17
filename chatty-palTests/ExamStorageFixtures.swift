import XCTest
@testable import chatty_pal

/// Small, non-secret snapshots of the storage formats that exist in the wild today.
///
/// These fixtures are the input for the honest migration required by the Goethe A1
/// preparation work (tasks 5.4/5.5): they pin what v1 actually looks like *before* the
/// new attempt store changes its meaning. Nothing here contains personal data — the
/// lesson texts are the shipped catalog strings.
enum ExamLegacyStorageFixtures {
    /// `ExamCampaignProgress` v1 payload stored under `exam.a1.campaign.v1`.
    /// `completedAt` uses `JSONEncoder`'s default reference-date Double encoding.
    static let campaignStateV1JSON = """
    {
      "version": 1,
      "lessons": {
        "l1-identity": {
          "stars": 3,
          "correctCount": 6,
          "exerciseCount": 6,
          "completedSpeaking": true,
          "completedWriting": true,
          "completedAt": 813725000
        },
        "l2-numbers-questions": {
          "stars": 2,
          "correctCount": 4,
          "exerciseCount": 6,
          "completedSpeaking": false,
          "completedWriting": false,
          "completedAt": 813726000
        }
      }
    }
    """

    /// Pre-campaign completion flags stored under `exam.a1.completed`.
    static let legacyCompletedUnitIDs = ["a1-voc-familie", "a1-read-formular"]

    /// A resumed `l3-speaking-introduce` stage conversation (guest scope), including the
    /// explicit `"correction": null` that the synthesized `Encodable` writes today.
    static let lessonChatJSON = """
    [
      {
        "id": "3F2504E0-4F89-41D3-9A0C-0305E82C3301",
        "role": "assistant",
        "message": "Guten Tag! Wie heißen Sie?"
      },
      {
        "id": "3F2504E0-4F89-41D3-9A0C-0305E82C3302",
        "role": "user",
        "message": "Ich heiße Anna Berger.",
        "correction": null
      },
      {
        "id": "3F2504E0-4F89-41D3-9A0C-0305E82C3303",
        "role": "assistant",
        "message": "Freut mich, Frau Berger. Woher kommen Sie?"
      },
      {
        "id": "3F2504E0-4F89-41D3-9A0C-0305E82C3304",
        "role": "user",
        "message": "Ich komme aus Polen.",
        "correction": "Ich komme aus Polen."
      }
    ]
    """

    /// Key format used by `LessonChatStore` today.
    static func lessonChatKey(scope: String, lessonID: String, stageID: String) -> String {
        "lessonchat.\(scope).\(lessonID).\(stageID)"
    }

    static let speakingLessonID = "l3-speaking-introduce"
    static let speakingStageID = "Sich vorstellen"
}

/// Mirrors the private `ExamCampaignProgress.State`, so the fixtures can be decoded and
/// asserted independently of how the production store evolves.
private struct CampaignStateV1: Decodable {
    struct LessonProgress: Decodable {
        let stars: Int
        let correctCount: Int
        let exerciseCount: Int
        let completedSpeaking: Bool
        let completedWriting: Bool
        let completedAt: Date
    }

    let version: Int
    let lessons: [String: LessonProgress]
}

final class ExamLegacyStorageFixtureTests: XCTestCase {

    // MARK: - Format evidence (task 0.4)

    func testCampaignV1FixtureIsSelfConsistent() throws {
        // Format evidence for the fixture JSON itself; the live-decoder proof is
        // testLiveProgressStoreReadsCampaignV1Fixture below.
        let state = try JSONDecoder().decode(
            CampaignStateV1.self,
            from: Data(ExamLegacyStorageFixtures.campaignStateV1JSON.utf8)
        )
        XCTAssertEqual(state.version, 1)
        XCTAssertEqual(state.lessons.count, 2)
        XCTAssertEqual(state.lessons["l1-identity"]?.stars, 3)
        XCTAssertEqual(state.lessons["l1-identity"]?.exerciseCount, 6)
        XCTAssertEqual(state.lessons["l1-identity"]?.completedWriting, true)
        XCTAssertNotEqual(state.lessons["l1-identity"]?.completedAt, .distantPast)
        // v1 records a lesson as completed merely by being present in this dictionary.
        XCTAssertNotNil(state.lessons["l2-numbers-questions"])
    }

    func testLessonChatFixtureDecodesWithCurrentChatMessageModel() throws {
        let messages = try JSONDecoder().decode(
            [ChatMessage].self,
            from: Data(ExamLegacyStorageFixtures.lessonChatJSON.utf8)
        )
        XCTAssertEqual(messages.count, 4)
        XCTAssertEqual(messages.map(\.role), [.assistant, .user, .assistant, .user])
        XCTAssertNil(messages[1].correction)
        XCTAssertNotNil(messages[3].correction)
    }

    // MARK: - The live v1 store reads these fixtures unchanged

    func testLiveProgressStoreReadsCampaignV1Fixture() {
        let suiteName = "fixture-campaign-v1-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.set(
            Data(ExamLegacyStorageFixtures.campaignStateV1JSON.utf8),
            forKey: "exam.a1.campaign.v1"
        )
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let progress = ExamCampaignProgress(defaults: defaults)
        XCTAssertTrue(progress.isComplete("l1-identity"))
        XCTAssertEqual(progress.bestStars("l1-identity"), 3)
        XCTAssertTrue(progress.isComplete("l2-numbers-questions"))
        XCTAssertEqual(progress.bestStars("l2-numbers-questions"), 2)
    }

    func testLiveProgressStoreMigratesLegacyFlagsToCompletionOnly() {
        let suiteName = "fixture-campaign-legacy-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.set(
            ExamLegacyStorageFixtures.legacyCompletedUnitIDs,
            forKey: ExamCampaignProgress.legacyCompletedKey
        )
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let progress = ExamCampaignProgress(defaults: defaults)
        // Evidence for the semantics change in task 5.4: a legacy flag becomes campaign
        // completion with one star and `.distantPast`, without any submitted answer.
        XCTAssertTrue(progress.isComplete("l1-identity"))
        XCTAssertTrue(progress.isComplete("l4-reading-form"))
        XCTAssertEqual(progress.bestStars("l4-reading-form"), 1)
        XCTAssertEqual(progress.progress(for: "l4-reading-form")?.completedAt, .distantPast)
        XCTAssertEqual(progress.progress(for: "l4-reading-form")?.exerciseCount, 0)
    }

    func testLiveLessonChatStoreReadsFixtureAtDocumentedKey() throws {
        let suiteName = "fixture-lesson-chat-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let key = ExamLegacyStorageFixtures.lessonChatKey(
            scope: "guest",
            lessonID: ExamLegacyStorageFixtures.speakingLessonID,
            stageID: ExamLegacyStorageFixtures.speakingStageID
        )
        defaults.set(Data(ExamLegacyStorageFixtures.lessonChatJSON.utf8), forKey: key)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = LessonChatStore(
            lessonID: ExamLegacyStorageFixtures.speakingLessonID,
            stageID: ExamLegacyStorageFixtures.speakingStageID,
            defaults: defaults,
            scope: "guest"
        )
        let loaded = store.load()
        XCTAssertEqual(loaded.count, 4)
        // The live store swallows decode failures via `try?`, so pin the content, not just the count.
        XCTAssertEqual(loaded.map(\.role), [.assistant, .user, .assistant, .user])
        XCTAssertNil(loaded[1].correction)
        XCTAssertNotNil(loaded[3].correction, "the migration promise is that corrections survive the read")
    }

    func testProductionStoreRecordStillDecodesAsV1Shape() throws {
        // Bridge test: what the PRODUCTION encoder writes must still be readable by the
        // documented v1 mirror format — the counterpart to the fixture→store direction.
        let suiteName = "campaign-v1-bridge-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let outcome = MissionResult(stars: 2, correctCount: 4, exerciseCount: 6,
                                    completedSpeaking: true, completedWriting: false)
        ExamCampaignProgress(defaults: defaults).record(outcome, for: "l1-identity")

        let data = try XCTUnwrap(defaults.data(forKey: "exam.a1.campaign.v1"))
        let state = try JSONDecoder().decode(CampaignStateV1.self, from: data)
        XCTAssertEqual(state.version, 1)
        XCTAssertEqual(state.lessons["l1-identity"]?.stars, 2)
        XCTAssertEqual(state.lessons["l1-identity"]?.correctCount, 4)
        XCTAssertEqual(state.lessons["l1-identity"]?.exerciseCount, 6)
        XCTAssertEqual(state.lessons["l1-identity"]?.completedSpeaking, true)
        XCTAssertEqual(state.lessons["l1-identity"]?.completedWriting, false)
    }
}
