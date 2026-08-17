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

    static func allExercises() -> [ExamExercise] {
        units.flatMap { $0.exercises }
    }

    static func buildMiniExamQuestions(targetCount: Int = 12) -> [ExamExercise] {
        let all = allExercises()
        var bySection: [ExamSection: [ExamExercise]] = [:]
        for unit in units {
            bySection[unit.section, default: []].append(contentsOf: unit.exercises)
        }
        var picked: [ExamExercise] = []
        for exercises in bySection.values where !exercises.isEmpty {
            if let random = exercises.randomElement() {
                picked.append(random)
            }
        }
        if picked.count < targetCount {
            let pickedIDs = Set(picked.map(\.id))
            let remaining = all.filter { !pickedIDs.contains($0.id) }
            picked.append(contentsOf: remaining.shuffled().prefix(targetCount - picked.count))
        }
        return picked.shuffled()
    }
}

final class ExamProgressModel: ObservableObject {
    static let shared = ExamProgressModel()

    private static let completedKey = "exam.a1.completed"

    @Published private(set) var completed: Set<String> = []

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.completed = Set(defaults.stringArray(forKey: Self.completedKey) ?? [])
    }

    func isCompleted(_ unitID: String) -> Bool {
        completed.contains(unitID)
    }

    func toggle(_ unitID: String) {
        if completed.contains(unitID) {
            completed.remove(unitID)
        } else {
            completed.insert(unitID)
        }
        defaults.set(Array(completed), forKey: Self.completedKey)
    }

    func completedCount(in section: ExamSection) -> Int {
        ExamA1Catalog.units(in: section).filter { completed.contains($0.id) }.count
    }
}
