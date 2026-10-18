// Swift mirror of scoring.ts + selection.ts + attempt.ts (task 3.7/3.5/3.6).
// The committed scoring-vectors.json (shared with Next and CMS) pins identical
// behaviour: ExamBankTests runs every vector through these functions.
import Foundation

// MARK: - Form normalization

enum ExamNormalization {
    static func foldText(_ value: String) -> String {
        let lowered = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "ä", with: "ae")
            .replacingOccurrences(of: "ö", with: "oe")
            .replacingOccurrences(of: "ü", with: "ue")
            .replacingOccurrences(of: "ß", with: "ss")
        // Collapse ANY whitespace run to one space — JS parity is /\s+/g
        // (tabs and newlines included; review R3).
        var collapsed = ""
        var lastWasSpace = false
        for character in lowered {
            if character.isWhitespace {
                if !lastWasSpace { collapsed.append(" ") }
                lastWasSpace = true
            } else {
                collapsed.append(character)
                lastWasSpace = false
            }
        }
        while let last = collapsed.last, ".,;!?".contains(last) {
            collapsed.removeLast()
        }
        return collapsed
    }

    // Keys are POST-fold forms; must match GERMAN_NUMBERS in scoring.ts.
    static let germanNumbers: [String: String] = [
        "null": "0", "eins": "1", "zwei": "2", "drei": "3", "vier": "4", "fuenf": "5",
        "sechs": "6", "sieben": "7", "acht": "8", "neun": "9", "zehn": "10",
        "elf": "11", "zwoelf": "12", "dreizehn": "13", "vierzehn": "14", "fuenfzehn": "15",
        "sechzehn": "16", "siebzehn": "17", "achtzehn": "18", "neunzehn": "19", "zwanzig": "20",
    ]

    static func isASCIIDigit(_ character: Character) -> Bool {
        character.unicodeScalars.allSatisfy { (0x30...0x39).contains($0.value) }
    }

    static func foldNumber(_ value: String) -> String {
        let folded = String(foldText(value)
            .replacingOccurrences(of: ".", with: "")
            .filter { !$0.isWhitespace })
        if let digits = folded.firstMatch(#"^\d+"#) {
            return digits
        }
        return germanNumbers[folded] ?? folded
    }

    static func foldDate(_ value: String) -> String {
        let folded = foldText(value)
        let parts = folded.split(whereSeparator: { $0 == "." || $0 == "/" || $0 == " " })
            .map(String.init)
            .filter { !$0.isEmpty }
        guard parts.count >= 2 else { return folded }
        let day = parts[0]
        let month = parts[1]
        let year = parts.count > 2 ? parts[2] : ""
        // JS uses /^\d$/ and /^\d\d$/ — ASCII digits only, so "ab" must NOT
        // become "20ab" (review R3).
        func padded(_ part: String) -> String { part.count == 1 && part.allSatisfy(isASCIIDigit) ? "0\(part)" : part }
        let fullYear = year.count == 2 && year.allSatisfy(isASCIIDigit) ? "20\(year)" : year
        return [padded(day), padded(month), fullYear].filter { !$0.isEmpty }.joined(separator: ".")
    }

    static func normalize(rule: FormFieldRule, raw: String) -> String {
        switch rule {
        case .text: return foldText(raw)
        case .number: return foldNumber(raw)
        case .date: return foldDate(raw)
        case .choice: return foldText(raw)
        }
    }
}

private extension String {
    func firstMatch(_ pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(startIndex..<endIndex, in: self)
        guard let match = regex.firstMatch(in: self, range: range) else { return nil }
        return String(self[Range(match.range, in: self)!])
    }
}

// MARK: - Objective scoring

enum ExamScoringError: Error, Equatable {
    /// A plain string for a form task (or slot answers for a choice task) is a
    /// programming error, never a silent 0 — mirrors expectPlainAnswer/
    /// expectFormAnswer in scoring.ts (review R1).
    case wrongShape(String)
    case notFormTask(String)
    case noKey(String)
    case productive(String)
    case rubricValue(rubric: String, criterion: String)
}

enum ExamScoring {
    /// 1/0 per slot; empty answers score 0 and stay counted (spec task-practice).
    static func scoreFormTask(_ task: ExamTask, answers: [String: String]) throws -> [(slot: String, points: Int)] {
        guard case .formFields(let fields) = task.answerKey else { throw ExamScoringError.notFormTask(task.id) }
        return fields.map { field in
            guard let given = answers[field.slot], !given.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return (field.slot, 0)
            }
            let normalized = ExamNormalization.normalize(rule: field.rule, raw: given)
            let accepted = field.accepted.contains {
                ExamNormalization.normalize(rule: field.rule, raw: $0) == normalized
            }
            return (field.slot, accepted ? 1 : 0)
        }
    }

    static func scoreObjectiveAnswer(_ task: ExamTask, answer: String?) throws -> Int {
        guard let key = task.answerKey else { throw ExamScoringError.noKey(task.id) }
        switch key {
        case .productive:
            throw ExamScoringError.productive(task.id)
        case .formFields:
            return 0 // per-slot via scoreFormTask
        case .trueFalse(let expected):
            guard let answer, !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return 0 }
            return answer == expected.rawValue ? 1 : 0
        case .singleChoice(_, let correctOptionId):
            guard let answer, !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return 0 }
            return answer == correctOptionId ? 1 : 0
        }
    }

    enum TaskAnswer {
        case value(String)
        case form([String: String])
    }

    struct SectionScore: Equatable {
        var points: Int
        var maxPoints: Int
        var answered: Int
        var unansweredKeys: [String]
    }

    static func scoreObjectiveSection(_ tasks: [ExamTask], answers: [String: TaskAnswer]) throws -> SectionScore {
        var points = 0, maxPoints = 0, answered = 0
        var unanswered: [String] = []
        for task in tasks {
            guard let key = task.answerKey, key.keyType != .productive else { continue }
            if case .formFields(let fields) = key {
                let slotAnswers: [String: String]
                switch answers[task.id] {
                case .form(let slots): slotAnswers = slots
                case .value: throw ExamScoringError.wrongShape(task.id) // forms need per-slot answers
                case nil: slotAnswers = [:]
                }
                let results = try scoreFormTask(task, answers: slotAnswers)
                let bySlot = Dictionary(uniqueKeysWithValues: results.map { ($0.slot, $0.points) })
                for field in fields {
                    maxPoints += 1
                    let given = slotAnswers[field.slot]
                    if given == nil || given!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        unanswered.append("\(task.id).\(field.slot)")
                    } else {
                        answered += 1
                        points += bySlot[field.slot] ?? 0
                    }
                }
                continue
            }
            maxPoints += 1
            switch answers[task.id] {
            case nil:
                unanswered.append(task.id)
            case .form:
                throw ExamScoringError.wrongShape(task.id) // choice tasks take a single value
            case .value(let raw):
                if raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    unanswered.append(task.id)
                } else {
                    answered += 1
                    points += try scoreObjectiveAnswer(task, answer: raw)
                }
            }
        }
        return SectionScore(points: points, maxPoints: maxPoints, answered: answered, unansweredKeys: unanswered)
    }

    /// Totals only ever from permitted values (spec assessment).
    static func rubricTotal(_ rubric: Rubric, selections: [String: Double]) throws -> Double {
        var total = 0.0
        for criterion in rubric.criteria {
            guard let value = selections[criterion.id], criterion.permittedScores.contains(value) else {
                throw ExamScoringError.rubricValue(rubric: rubric.id, criterion: criterion.id)
            }
            total += value
        }
        return total
    }
}

// MARK: - Deterministic selection (mirrors selection.ts bit-for-bit)

enum ExamSelection {
    /// FNV-1a over UTF-16 code units — identical to JS charCodeAt iteration.
    static func fnv1a32(_ input: String) -> UInt32 {
        var hash: UInt32 = 0x811c_9dc5
        for unit in input.utf16 {
            hash ^= UInt32(unit)
            hash = hash &* 0x0100_0193
        }
        return hash
    }

    static func mulberry32(seed: UInt32) -> () -> Double {
        var state = seed
        return {
            state = state &+ 0x6d2b_79f5
            var t = state
            t = (t ^ (t >> 15)) &* (t | 1)
            t ^= t &+ ((t ^ (t >> 7)) &* (t | 61))
            return Double((t ^ (t >> 14)) >> 0) / 4_294_967_296
        }
    }

    static func deterministicShuffle<T>(_ items: [T], seed: UInt32) -> [T] {
        var copy = items
        let random = mulberry32(seed: seed)
        var i = copy.count - 1
        while i > 0 {
            let j = Int(random() * Double(i + 1))
            copy.swapAt(i, j)
            i -= 1
        }
        return copy
    }

    struct Request {
        var candidates: [TaskRevisionPin]
        var count: Int
        var seed: String
        var seen: [TaskRevisionPin] = []
    }

    struct Result: Equatable {
        struct Entry: Equatable { var taskId: String; var revision: Int; var order: Int }
        var entries: [Entry]
        var reusedSeen: Bool
        var reusedCount: Int
    }

    enum SelectionError: Error { case impossible(requested: Int, available: Int) }

    private static func key(_ pin: TaskRevisionPin) -> String { "\(pin.taskId)@\(pin.revision)" }

    static func selectVariants(_ request: Request) throws -> Result {
        let seenKeys = Set(request.seen.map(key))
        let fresh = request.candidates.filter { !seenKeys.contains(key($0)) }
        let reused = request.candidates.filter { seenKeys.contains(key($0)) }
        guard request.count <= request.candidates.count else {
            throw SelectionError.impossible(requested: request.count, available: request.candidates.count)
        }
        let drawn = deterministicShuffle(fresh, seed: fnv1a32("fresh:\(request.seed)")).prefix(request.count)
        let remaining = request.count - drawn.count
        var reusedDrawn: [TaskRevisionPin] = []
        if remaining > 0 {
            reusedDrawn = Array(deterministicShuffle(reused, seed: fnv1a32("reused:\(request.seed)")).prefix(remaining))
        }
        let all = Array(drawn) + reusedDrawn
        return Result(
            entries: all.enumerated().map { (offset, pin) in Result.Entry(taskId: pin.taskId, revision: pin.revision, order: offset + 1) },
            reusedSeen: !reusedDrawn.isEmpty,
            reusedCount: reusedDrawn.count
        )
    }
}

// MARK: - Attempt lifecycle (mirrors attempt.ts)

enum AttemptStatus: String, Codable {
    case draft, inProgress, submitted, awaitingAssessment, assessed, abandoned, invalidated
}

enum AttemptLifecycle {
    static let transitions: [AttemptStatus: [AttemptStatus]] = [
        .draft: [.inProgress, .abandoned, .invalidated],
        .inProgress: [.submitted, .abandoned, .invalidated],
        .submitted: [.awaitingAssessment, .assessed, .invalidated],
        .awaitingAssessment: [.assessed, .invalidated],
        .assessed: [],
        .abandoned: [],
        .invalidated: [],
    ]

    static func canTransition(from: AttemptStatus, to: AttemptStatus) -> Bool {
        transitions[from]?.contains(to) ?? false
    }

    static func isFrozen(_ status: AttemptStatus) -> Bool {
        status != .draft && status != .inProgress
    }

    /// Standard evidence: unassisted check/mock, no accommodation, submitted or beyond.
    static func isStandardEvidence(mode: AttemptMode, assisted: Bool, accommodation: String?, status: AttemptStatus) -> Bool {
        if mode == .training { return false }
        if assisted || accommodation != nil { return false }
        return [.submitted, .awaitingAssessment, .assessed].contains(status)
    }
}
