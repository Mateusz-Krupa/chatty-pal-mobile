// Canonical exam-bank models — Codable mirror of
// chatty-pal/src/lib/exam/bank-schema.ts. The JSON files under the bundled
// `ExamBank` folder are snapshots synced from Next and hash-checked against
// `bank-lock.json` (see ExamBankTests); the app must never edit them.
// Versions are separate on purpose: blueprintVersion / contentVersion / rubric.version.
import Foundation

enum ExamBankError: Error, Equatable {
    case missingSnapshotFolder
    case missingBlueprint
    case undecodable(path: String, underlying: String)
}

enum ExamSkill: String, Codable, CaseIterable {
    case lesen, horen, schreiben, sprechen
}

enum TaskType: String, Codable, CaseIterable {
    case readingTrueFalse, readingSourceMatch, listeningChoice, listeningTrueFalse
    case formFill, message
    case speakingIntro, speakingInfoCard, speakingRequestCard
    case dailyPractice
}

enum AttemptMode: String, Codable {
    case training, check, mock
}

enum ReviewStatus: String, Codable {
    case draft, inReview, approved, rejected
}

enum TaskStatus: String, Codable {
    case active, retired
}

enum FormFieldRule: String, Codable {
    case text, number, date, choice
}

struct ReviewInfo: Codable, Equatable {
    var status: ReviewStatus
    var reviewer: String?
    var date: String?
    var note: String?
}

struct ChoiceOption: Codable, Equatable {
    var id: String
    var label: String
}

struct FormField: Codable, Equatable {
    var slot: String
    var label: String
    var rule: FormFieldRule
    var accepted: [String]
}

enum ExamTrueFalse: String, Codable {
    case richtig, falsch
}

enum AnswerKeyType: String {
    case trueFalse, singleChoice, formFields, productive
}

enum AnswerKey: Codable, Equatable {
    case trueFalse(expected: ExamTrueFalse)
    case singleChoice(options: [ChoiceOption], correctOptionId: String)
    case formFields(fields: [FormField])
    case productive(rubricId: String, contentPoints: [String]?, approxWords: Int?, requiredElements: [String]?)

    var keyType: AnswerKeyType {
        switch self {
        case .trueFalse: return .trueFalse
        case .singleChoice: return .singleChoice
        case .formFields: return .formFields
        case .productive: return .productive
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type, expected, options, correctOptionId, fields, rubricId, contentPoints, approxWords, requiredElements
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(String.self, forKey: .type) {
        case "trueFalse":
            self = .trueFalse(expected: try container.decode(ExamTrueFalse.self, forKey: .expected))
        case "singleChoice":
            self = .singleChoice(
                options: try container.decode([ChoiceOption].self, forKey: .options),
                correctOptionId: try container.decode(String.self, forKey: .correctOptionId)
            )
        case "formFields":
            self = .formFields(fields: try container.decode([FormField].self, forKey: .fields))
        case "productive":
            self = .productive(
                rubricId: try container.decode(String.self, forKey: .rubricId),
                contentPoints: try container.decodeIfPresent([String].self, forKey: .contentPoints),
                approxWords: try container.decodeIfPresent(Int.self, forKey: .approxWords),
                requiredElements: try container.decodeIfPresent([String].self, forKey: .requiredElements)
            )
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "unknown answer key type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .trueFalse(let expected):
            try container.encode("trueFalse", forKey: .type)
            try container.encode(expected, forKey: .expected)
        case .singleChoice(let options, let correctOptionId):
            try container.encode("singleChoice", forKey: .type)
            try container.encode(options, forKey: .options)
            try container.encode(correctOptionId, forKey: .correctOptionId)
        case .formFields(let fields):
            try container.encode("formFields", forKey: .type)
            try container.encode(fields, forKey: .fields)
        case .productive(let rubricId, let contentPoints, let approxWords, let requiredElements):
            try container.encode("productive", forKey: .type)
            try container.encode(rubricId, forKey: .rubricId)
            try container.encodeIfPresent(contentPoints, forKey: .contentPoints)
            try container.encodeIfPresent(approxWords, forKey: .approxWords)
            try container.encodeIfPresent(requiredElements, forKey: .requiredElements)
        }
    }
}

struct LocalizedText: Codable, Equatable {
    var en: String?
    var pl: String?
}

struct Hint: Codable, Equatable {
    enum Level: String, Codable {
        case word, grammar, translation
    }
    var level: Level
    var text: String
}

struct Rights: Codable, Equatable {
    enum Kind: String, Codable {
        case original, licensed
    }
    var kind: Kind
    var note: String
}

struct ExamTask: Codable, Equatable {
    var id: String
    var revision: Int
    var blueprintVersion: String
    var skill: ExamSkill
    var part: Int?
    var taskType: TaskType
    var topic: String
    var estimatedSeconds: Int
    var instructionDe: String
    var instructionTranslations: LocalizedText?
    var explanation: LocalizedText?
    var assetIds: [String]
    var answerKey: AnswerKey?
    var hints: [Hint]
    var modelAnswer: String?
    var errorTags: [String]
    var supportLevel: String
    var status: TaskStatus
    var retiredReason: String?
    var review: ReviewInfo

    private enum CodingKeys: String, CodingKey {
        case id, revision, blueprintVersion, skill, part, taskType, topic, estimatedSeconds
        case instructionDe, instructionTranslations, explanation, assetIds, answerKey, hints
        case modelAnswer, errorTags, supportLevel, status, retiredReason, review
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        revision = try container.decode(Int.self, forKey: .revision)
        blueprintVersion = try container.decode(String.self, forKey: .blueprintVersion)
        skill = try container.decode(ExamSkill.self, forKey: .skill)
        part = try container.decodeIfPresent(Int.self, forKey: .part)
        taskType = try container.decode(TaskType.self, forKey: .taskType)
        topic = try container.decode(String.self, forKey: .topic)
        estimatedSeconds = try container.decode(Int.self, forKey: .estimatedSeconds)
        instructionDe = try container.decode(String.self, forKey: .instructionDe)
        instructionTranslations = try container.decodeIfPresent(LocalizedText.self, forKey: .instructionTranslations)
        explanation = try container.decodeIfPresent(LocalizedText.self, forKey: .explanation)
        assetIds = try container.decodeIfPresent([String].self, forKey: .assetIds) ?? []
        answerKey = try container.decodeIfPresent(AnswerKey.self, forKey: .answerKey)
        hints = try container.decodeIfPresent([Hint].self, forKey: .hints) ?? []
        modelAnswer = try container.decodeIfPresent(String.self, forKey: .modelAnswer)
        errorTags = try container.decodeIfPresent([String].self, forKey: .errorTags) ?? []
        supportLevel = try container.decodeIfPresent(String.self, forKey: .supportLevel) ?? "none"
        status = try container.decodeIfPresent(TaskStatus.self, forKey: .status) ?? .active
        retiredReason = try container.decodeIfPresent(String.self, forKey: .retiredReason)
        review = try container.decode(ReviewInfo.self, forKey: .review)
    }
}

// MARK: - Assets

enum ExamAsset: Codable, Equatable {
    case text(id: String, title: String, body: String, rights: Rights)
    case audio(id: String, title: String, file: String, durationMs: Int, transcript: String?, rights: Rights)
    case card(id: String, title: String, prompt: String, imageFile: String?, rights: Rights)

    var id: String {
        switch self {
        case .text(let id, _, _, _), .audio(let id, _, _, _, _, _), .card(let id, _, _, _, _): return id
        }
    }

    var kind: String {
        switch self {
        case .text: return "text"
        case .audio: return "audio"
        case .card: return "card"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, kind, title, body, file, durationMs, transcript, prompt, imageFile, rights
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let rights = try container.decode(Rights.self, forKey: .rights)
        switch try container.decode(String.self, forKey: .kind) {
        case "text":
            self = .text(id: id, title: title,
                         body: try container.decode(String.self, forKey: .body), rights: rights)
        case "audio":
            self = .audio(id: id, title: title,
                          file: try container.decode(String.self, forKey: .file),
                          durationMs: try container.decode(Int.self, forKey: .durationMs),
                          transcript: try container.decodeIfPresent(String.self, forKey: .transcript),
                          rights: rights)
        case "card":
            self = .card(id: id, title: title,
                         prompt: try container.decode(String.self, forKey: .prompt),
                         imageFile: try container.decodeIfPresent(String.self, forKey: .imageFile),
                         rights: rights)
        default:
            throw DecodingError.dataCorruptedError(forKey: .kind, in: container, debugDescription: "unknown asset kind")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let id, let title, let body, let rights):
            try container.encode(id, forKey: .id); try container.encode("text", forKey: .kind)
            try container.encode(title, forKey: .title); try container.encode(body, forKey: .body)
            try container.encode(rights, forKey: .rights)
        case .audio(let id, let title, let file, let durationMs, let transcript, let rights):
            try container.encode(id, forKey: .id); try container.encode("audio", forKey: .kind)
            try container.encode(title, forKey: .title); try container.encode(file, forKey: .file)
            try container.encode(durationMs, forKey: .durationMs)
            try container.encodeIfPresent(transcript, forKey: .transcript)
            try container.encode(rights, forKey: .rights)
        case .card(let id, let title, let prompt, let imageFile, let rights):
            try container.encode(id, forKey: .id); try container.encode("card", forKey: .kind)
            try container.encode(title, forKey: .title); try container.encode(prompt, forKey: .prompt)
            try container.encodeIfPresent(imageFile, forKey: .imageFile)
            try container.encode(rights, forKey: .rights)
        }
    }
}

// MARK: - Rubrics

struct RubricCriterion: Codable, Equatable {
    var id: String
    var label: String
    var permittedScores: [Double]
    /// Human-readable anchors (0/1/2…); preserved so round-trips never drop
    /// canonical content (review round-1 suggestion).
    var scaleDescriptions: [String: String]?
}

struct Rubric: Codable, Equatable {
    var id: String
    var version: Int
    var skill: ExamSkill
    var part: Int
    var criteria: [RubricCriterion]
}

// MARK: - Bank, manifests, blueprint

struct TaskRevisionPin: Codable, Equatable {
    var taskId: String
    var revision: Int
}

struct LegacyAlias: Codable, Equatable {
    enum Status: String, Codable {
        case mapped, retired
    }
    var legacyId: String
    var taskId: String
    var status: Status
    var reason: String?
}

struct ExamBankFile: Codable, Equatable {
    var contentVersion: Int
    var blueprintVersion: String
    var tasks: [ExamTask]
    var assets: [ExamAsset]
    var rubrics: [Rubric]
    var legacyAliases: [LegacyAlias]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        contentVersion = try container.decode(Int.self, forKey: .contentVersion)
        blueprintVersion = try container.decode(String.self, forKey: .blueprintVersion)
        tasks = try container.decode([ExamTask].self, forKey: .tasks)
        assets = try container.decode([ExamAsset].self, forKey: .assets)
        rubrics = try container.decode([Rubric].self, forKey: .rubrics)
        legacyAliases = try container.decodeIfPresent([LegacyAlias].self, forKey: .legacyAliases) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case contentVersion, blueprintVersion, tasks, assets, rubrics, legacyAliases
    }
}

struct ManifestEntry: Codable, Equatable {
    var taskId: String
    var revision: Int
    var skill: ExamSkill
    var part: Int?
    var order: Int
}

struct ExamSetManifest: Codable, Equatable {
    enum Purpose: String, Codable {
        case mock, diagnostic, training
    }
    var id: String
    var version: Int
    var purpose: Purpose
    var blueprintVersion: String
    var title: String
    var description: String
    var entries: [ManifestEntry]
}

struct BlueprintPart: Codable, Equatable {
    var part: Int
    var name: String
    var taskTypes: [TaskType]
    var itemCount: Int
    var maxPoints: Int
    var pointsPerItem: Double?
    var playbacks: Int?
    var rubricRequired: Bool
    var requiredSlots: Int?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        part = try container.decode(Int.self, forKey: .part)
        name = try container.decode(String.self, forKey: .name)
        taskTypes = try container.decode([TaskType].self, forKey: .taskTypes)
        itemCount = try container.decode(Int.self, forKey: .itemCount)
        maxPoints = try container.decode(Int.self, forKey: .maxPoints)
        pointsPerItem = try container.decodeIfPresent(Double.self, forKey: .pointsPerItem)
        playbacks = try container.decodeIfPresent(Int.self, forKey: .playbacks)
        rubricRequired = try container.decodeIfPresent(Bool.self, forKey: .rubricRequired) ?? false
        requiredSlots = try container.decodeIfPresent(Int.self, forKey: .requiredSlots)
    }

    private enum CodingKeys: String, CodingKey {
        case part, name, taskTypes, itemCount, maxPoints, pointsPerItem, playbacks, rubricRequired, requiredSlots
    }
}

struct BlueprintSkill: Codable, Equatable {
    var skill: ExamSkill
    var estimatedSeconds: Int
    var parts: [BlueprintPart]
}

struct ExamBlueprint: Codable, Equatable {
    struct OfficialSource: Codable, Equatable {
        var url: String
        var documentDate: String
        var verifiedAt: String
        var note: String?
    }
    struct Grade: Codable, Equatable {
        var from: Int
        var to: Int
        var label: String
    }
    struct Conversion: Codable, Equatable {
        var multiplier: Double
        var maxPoints: Int
        var passPoints: Int
        var requireAllParts: Bool
        var grades: [Grade]

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            multiplier = try container.decode(Double.self, forKey: .multiplier)
            maxPoints = try container.decode(Int.self, forKey: .maxPoints)
            passPoints = try container.decode(Int.self, forKey: .passPoints)
            requireAllParts = try container.decode(Bool.self, forKey: .requireAllParts)
            grades = try container.decodeIfPresent([Grade].self, forKey: .grades) ?? []
        }

        private enum CodingKeys: String, CodingKey {
            case multiplier, maxPoints, passPoints, requireAllParts, grades
        }
    }

    var id: String
    var version: Int
    var name: String
    var officialSource: OfficialSource
    var conversion: Conversion
    var skills: [BlueprintSkill]

    func part(skill: ExamSkill, part: Int) -> BlueprintPart? {
        skills.first(where: { $0.skill == skill })?.parts.first(where: { $0.part == part })
    }
}

// MARK: - Snapshot loading

struct ExamBankSnapshot: Equatable {
    var blueprint: ExamBlueprint
    var bank: ExamBankFile
    var manifests: [ExamSetManifest]
}

enum ExamBankLoader {
    /// Loads `ExamBank/` (blueprints/, bank/, manifests/) from a folder URL.
    /// Newest `.vN` file wins per directory, matching scripts/exam-bank-sync.cjs.
    static func load(folder: URL, decoder: JSONDecoder = JSONDecoder()) throws -> ExamBankSnapshot {
        guard FileManager.default.fileExists(atPath: folder.path) else { throw ExamBankError.missingSnapshotFolder }
        func newest(in sub: String) throws -> [URL] {
            let dir = folder.appendingPathComponent(sub)
            let files = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil))?
                .filter { $0.pathExtension == "json" } ?? []
            return files.sorted { lhs, rhs in version(of: lhs) > version(of: rhs) }
        }
        guard let blueprintURL = try newest(in: "blueprints").first else { throw ExamBankError.missingBlueprint }
        let bankURLs = try newest(in: "bank")
        guard let bankURL = bankURLs.first else { throw ExamBankError.missingBlueprint }
        let manifestURLs = try newest(in: "manifests")

        func decodeFile<T: Decodable>(_ type: T.Type, url: URL) throws -> T {
            let data = try Data(contentsOf: url)
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw ExamBankError.undecodable(path: url.lastPathComponent, underlying: String(describing: error))
            }
        }

        let blueprint = try decodeFile(ExamBlueprint.self, url: blueprintURL)
        let bank = try decodeFile(ExamBankFile.self, url: bankURL)
        let manifests = try manifestURLs.map { try decodeFile(ExamSetManifest.self, url: $0) }
        return ExamBankSnapshot(blueprint: blueprint, bank: bank, manifests: manifests)
    }

    static func version(of url: URL) -> Int {
        let stem = url.deletingPathExtension().lastPathComponent
        guard let range = stem.range(of: #"\.v(\d+)$"#, options: .regularExpression) else { return 0 }
        return Int(stem[range].dropFirst(2)) ?? 0
    }
}
