import Foundation
import Observation

struct ReviewWord: Codable, Hashable, Identifiable {
    let id: String
    let german: String
    let english: String
    let example: String?
    let source: String
    var box: Int
    var due: Date
}

enum WordReviewGrade {
    case again
    case good
    case easy
}

enum WordReviewScheduler {
    static let boxIntervals: [Int: TimeInterval] = [
        1: 10 * 60,
        2: 24 * 60 * 60,
        3: 3 * 24 * 60 * 60,
        4: 7 * 24 * 60 * 60,
        5: 14 * 24 * 60 * 60
    ]

    static let minBox = 1
    static let maxBox = 5

    static func normalizedID(_ german: String) -> String {
        let lowered = german.lowercased()
        return lowered.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    static func schedule(for word: ReviewWord, grade: WordReviewGrade, now: Date) -> (box: Int, due: Date) {
        let nextBox: Int
        switch grade {
        case .again:
            nextBox = minBox
        case .good:
            nextBox = min(word.box + 1, maxBox)
        case .easy:
            nextBox = min(word.box + 2, maxBox)
        }
        let interval: TimeInterval
        switch grade {
        case .again:
            interval = boxIntervals[minBox]!
        case .good, .easy:
            interval = boxIntervals[nextBox]!
        }
        return (nextBox, now.addingTimeInterval(interval))
    }

    static func dueWords(_ words: [ReviewWord], now: Date) -> [ReviewWord] {
        words.filter { $0.due <= now }.sorted { $0.due < $1.due }
    }
}

@MainActor
@Observable
final class WordReviewStore {
    static let shared = WordReviewStore()

    private(set) var words: [ReviewWord] = []

    static let sessionLimit = 20
    private let defaults: UserDefaults
    private var scope: String

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.scope = DataScope.current
        self.words = Self.load(from: defaults, scope: self.scope)
    }

    // Reload after a login/logout switch so the store tracks the new account.
    func scopeDidChange() {
        scope = DataScope.current
        words = Self.load(from: defaults, scope: scope)
    }

    private var storageKey: String { "learning.wordReview.\(scope)" }

    var dueCount: Int {
        WordReviewScheduler.dueWords(words, now: Date()).count
    }

    func add(german: String, english: String, example: String? = nil, source: String) {
        let id = WordReviewScheduler.normalizedID(german)
        guard !id.isEmpty else { return }
        guard !words.contains(where: { $0.id == id }) else { return }
        let word = ReviewWord(id: id, german: german, english: english, example: example, source: source, box: WordReviewScheduler.minBox, due: Date())
        words.append(word)
        save()
    }

    func addLesson(_ lesson: LearningLesson) {
        let source = "lesson:\(lesson.id)"
        for item in lesson.vocabulary {
            add(german: item.mainContent, english: item.supportContent ?? "", example: item.usage, source: source)
        }
        for phrase in lesson.phrases {
            add(german: phrase.mainContent, english: phrase.supportContent ?? "", example: nil, source: source)
        }
    }

    func addExamUnit(_ unit: ExamUnit) {
        let source = "exam:\(unit.id)"
        for item in unit.vocabulary {
            add(german: item.german, english: item.english, example: item.example, source: source)
        }
    }

    func dueSession(limit: Int = WordReviewStore.sessionLimit, now: Date = Date()) -> [ReviewWord] {
        Array(WordReviewScheduler.dueWords(words, now: now).prefix(limit))
    }

    func grade(wordID: String, grade: WordReviewGrade, now: Date = Date()) {
        guard let index = words.firstIndex(where: { $0.id == wordID }) else { return }
        let updated = WordReviewScheduler.schedule(for: words[index], grade: grade, now: now)
        words[index].box = updated.box
        words[index].due = updated.due
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(words) {
            defaults.set(data, forKey: storageKey)
        }
    }

    private static func load(from defaults: UserDefaults, scope: String) -> [ReviewWord] {
        let scopedKey = "learning.wordReview.\(scope)"
        if let data = defaults.data(forKey: scopedKey) {
            return decode(data)
        }
        // One-shot migrations: legacy unscoped key (app upgrade), then the
        // guest scope (carries pre-login progress to the signed-in user).
        let fallbacks = ["learning.wordReview", "learning.wordReview.guest"]
        for fallback in fallbacks where scope != "guest" {
            if let data = defaults.data(forKey: fallback) {
                defaults.set(data, forKey: scopedKey)
                defaults.removeObject(forKey: fallback)
                return decode(data)
            }
        }
        return []
    }

    private static func decode(_ data: Data) -> [ReviewWord] {
        (try? JSONDecoder().decode([ReviewWord].self, from: data)) ?? []
    }
}
