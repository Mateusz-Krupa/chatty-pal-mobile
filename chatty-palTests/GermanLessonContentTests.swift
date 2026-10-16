import XCTest
@testable import chatty_pal

/// Decodes the shipping `german-lessons.json` from the **built app bundle**, which proves
/// both the file content and the pbxproj Resources-phase entry. If the resource is missing
/// from the bundle these tests fail before the content ever ships.
final class GermanLessonContentTests: XCTestCase {

    private func loadedFile() throws -> GermanLessonFile {
        let url = try XCTUnwrap(
            Bundle.main.url(forResource: "german-lessons", withExtension: "json"),
            "german-lessons.json not in the built app bundle (check Resources build phase)"
        )
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(GermanLessonFile.self, from: data)
    }

    func testShippingJSONIsInBundleAndDecodes() throws {
        let file = try loadedFile()
        XCTAssertEqual(file.schemaVersion, MobileLearningCatalog.germanSchemaVersion)
        XCTAssertEqual(file.lessons.count, 25)
    }

    func testCatalogMatchesShippingJSON() throws {
        let file = try loadedFile()
        XCTAssertEqual(MobileLearningCatalog.germanLessons.count, file.lessons.count)
        XCTAssertEqual(MobileLearningCatalog.germanLessons.map(\.id), file.lessons.map(\.id))
    }

    func testLessonStructureInvariants() throws {
        let lessons = try loadedFile().lessons
        let expectedIDs = (1...lessons.count).map { String(format: "de-s-%02d", $0) }
        XCTAssertEqual(lessons.count, 25)
        XCTAssertEqual(lessons.map(\.id), expectedIDs, "lesson ids must be sequential")

        for (index, lesson) in lessons.enumerated() {
            let context = "lesson \(lesson.id)"
            XCTAssertEqual(lesson.languageCode, "de", context)
            XCTAssertEqual(lesson.goals.count, 3, context)
            XCTAssertGreaterThanOrEqual(lesson.vocabulary.count, 5, context)
            XCTAssertLessThanOrEqual(lesson.vocabulary.count, 6, context)
            XCTAssertGreaterThanOrEqual(lesson.phrases.count, 7, context)
            // A2 lessons (currently the not-yet-split legacy material) may carry more phrases.
            let maxPhrases = lesson.level == "A2" ? 13 : 11
            XCTAssertLessThanOrEqual(lesson.phrases.count, maxPhrases, context)

            XCTAssertGreaterThanOrEqual(lesson.conversation.count, 5, context)
            XCTAssertLessThanOrEqual(lesson.conversation.count, 8, context)

            let speakers = lesson.conversation.map { $0.speaker ?? "" }
            XCTAssertEqual(Set(speakers).count, 2, "exactly two speakers: \(context)")
            for i in stride(from: 1, to: speakers.count, by: 2) {
                XCTAssertEqual(speakers[i], speakers[1], "speaker alternation: \(context)")
            }
            for i in stride(from: 2, to: speakers.count, by: 2) {
                XCTAssertEqual(speakers[i], speakers[0], "speaker alternation: \(context)")
            }

            // voiceA/voiceB are both present or both absent; when present, voiceA
            // belongs to the first speaker (even lines).
            XCTAssertEqual(lesson.voiceA == nil, lesson.voiceB == nil, "voice pair: \(context)")
            if lesson.languageCode == "de" {
                XCTAssertEqual(lesson.voiceA, "Vicki", context)
                XCTAssertEqual(lesson.voiceB, "Daniel", context)
            }

            XCTAssertFalse(lesson.intro.isEmpty, context)
            XCTAssertFalse(lesson.practicePrompt.isEmpty, context)
        }
    }

    func testUnsupportedSchemaVersionRejectsRealContent() throws {
        // Take the real shipping payload, bump its version: the schema gate must refuse
        // content that would otherwise decode fine.
        let url = try XCTUnwrap(Bundle.main.url(forResource: "german-lessons", withExtension: "json"))
        let data = try Data(contentsOf: url)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        object["schemaVersion"] = 2
        let bumped = try JSONSerialization.data(withJSONObject: object)
        let lessons = MobileLearningCatalog.germanLessons(from: bumped, shouldAssert: false)
        XCTAssertTrue(lessons.isEmpty, "loader must reject payloads with an unsupported schemaVersion")
    }

    func testCorruptJSONYieldsEmptyCatalog() {
        XCTAssertTrue(MobileLearningCatalog.germanLessons(from: Data("{ not json".utf8), shouldAssert: false).isEmpty)
    }
}
