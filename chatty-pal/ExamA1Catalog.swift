import Foundation

enum ExamSection: String, CaseIterable, Identifiable {
    case reading = "Lesen"
    case listening = "Hören"
    case speaking = "Sprechen"
    case writing = "Schreiben"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .reading:
            return "Read short texts and answer questions"
        case .listening:
            return "Listen and choose the right answer"
        case .speaking:
            return "Practice the oral exam with your partner"
        case .writing:
            return "Write short texts and get corrections"
        }
    }

    var systemImage: String {
        switch self {
        case .reading:
            return "book.fill"
        case .listening:
            return "ear.fill"
        case .speaking:
            return "bubble.left.and.bubble.right.fill"
        case .writing:
            return "pencil.and.outline"
        }
    }
}

struct ExamVocabularyItem: Identifiable, Hashable {
    let id: String
    let german: String
    let english: String
    let example: String
    let exampleEnglish: String
}

struct ExamPhrase: Identifiable, Hashable {
    let id: String
    let german: String
    let english: String
}

struct ExamDialogueLine: Identifiable, Hashable {
    let id: String
    let speaker: String
    let german: String
    let english: String
}

struct ExamExercise: Identifiable, Hashable {
    enum Kind: String, Hashable {
        case multipleChoice = "Question"
        case gapFill = "Fill in the gap"
        case listening = "Listen and choose"
    }

    let id: String
    let kind: Kind
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    var spokenText: String? = nil

    var hasAudio: Bool { spokenText != nil }
}

struct ExamUnit: Identifiable, Hashable {
    let id: String
    let section: ExamSection
    let title: String
    let subtitle: String
    let text: String?
    let vocabulary: [ExamVocabularyItem]
    let phrases: [ExamPhrase]
    let dialogue: [ExamDialogueLine]
    let exercises: [ExamExercise]
    let speakingScenario: String?
    let writingPrompt: String?
}

enum ExamA1Catalog {
    static let units: [ExamUnit] = ExamA1Content.units

    static func units(in section: ExamSection) -> [ExamUnit] {
        units.filter { $0.section == section }
    }
}
