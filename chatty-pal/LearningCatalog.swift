import Foundation

// Lesson content lives in german-lessons.json (app bundle resource), not in code.
// JSON keys are content-oriented (text/translation); CodingKeys map them to these fields.

struct LearningPhrase: Hashable, Identifiable, Codable {
    let id: String
    let mainContent: String
    let supportContent: String?

    enum CodingKeys: String, CodingKey {
        case id
        case mainContent = "text"
        case supportContent = "translation"
    }
}

struct LearningVocabularyItem: Hashable, Identifiable, Codable {
    let id = UUID()
    let mainContent: String
    let supportContent: String?
    let usage: String?

    enum CodingKeys: String, CodingKey {
        case mainContent = "text"
        case supportContent = "translation"
        case usage
    }
}

struct LearningConversationLine: Hashable, Identifiable, Codable {
    let id = UUID()
    let speaker: String?
    let mainContent: String
    let supportContent: String?

    enum CodingKeys: String, CodingKey {
        case speaker
        case mainContent = "text"
        case supportContent = "translation"
    }
}

struct LearningLesson: Hashable, Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let languageCode: String
    let level: String
    let topic: String
    let intro: String
    let goals: [String]
    let phrases: [LearningPhrase]
    let vocabulary: [LearningVocabularyItem]
    let conversation: [LearningConversationLine]
    let practicePrompt: String
    // Two-voice conversation playback: either both set or both absent.
    var voiceA: String? = nil
    var voiceB: String? = nil

    var languageName: String {
        LanguageConfig.all[languageCode]?.language ?? languageCode.uppercased()
    }
}

struct GermanLessonFile: Codable {
    let schemaVersion: Int
    let lessons: [LearningLesson]
}

enum MobileLearningCatalog {
    static let progressRevision = "de-2026-10-v1"
    static let germanLessons: [LearningLesson] = loadGermanLessons()

    static let germanSchemaVersion = 1

    private static func loadGermanLessons() -> [LearningLesson] {
        guard let url = Bundle.main.url(forResource: "german-lessons", withExtension: "json") else {
            return failLoadingGermanLessons("german-lessons.json missing from bundle", shouldAssert: true)
        }
        do {
            let data = try Data(contentsOf: url)
            return germanLessons(from: data)
        } catch {
            return failLoadingGermanLessons("german-lessons.json unreadable: \(error)", shouldAssert: true)
        }
    }

    // Parses the shipping format; returns [] on any violation. Debug builds assert so
    // broken content can never go unnoticed; release builds log and show the empty state.
    static func germanLessons(from data: Data, shouldAssert: Bool = true) -> [LearningLesson] {
        do {
            let file = try JSONDecoder().decode(GermanLessonFile.self, from: data)
            guard file.schemaVersion == germanSchemaVersion else {
                return failLoadingGermanLessons("unsupported schemaVersion \(file.schemaVersion)", shouldAssert: shouldAssert)
            }
            return file.lessons
        } catch {
            return failLoadingGermanLessons("german-lessons.json decode failed: \(error)", shouldAssert: shouldAssert)
        }
    }

    private static func failLoadingGermanLessons(_ message: String, shouldAssert: Bool) -> [LearningLesson] {
        NSLog("MobileLearningCatalog: \(message)")
        if shouldAssert {
            assertionFailure(message)
        }
        return []
    }
}
