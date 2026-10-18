// Parity tests for the bundled exam bank snapshot (tasks 3.2, 3.5-3.8).
// Consumes the SAME fixture files as the Next Jest tests:
//  - bank-lock.json    → the bundled copy must be byte-identical to canonical
//  - expectations.json → every invalid fixture must raise its pinned rule code
//  - scoring-vectors.json → normalization, selection order, rubric totals and
//                           lifecycle transitions must match the TS numbers
import CryptoKit
import XCTest
@testable import chatty_pal

final class ExamBankTests: XCTestCase {

    // MARK: - Bundle locations

    private func unbundled(_ name: String) -> NSError {
        NSError(domain: "ExamBankTests", code: 1, userInfo: [NSLocalizedDescriptionKey: "\(name) folder not bundled"])
    }

    private func appSnapshotFolder() throws -> URL {
        guard let url = Bundle.main.url(forResource: "ExamBank", withExtension: nil),
              FileManager.default.fileExists(atPath: url.path) else {
            throw unbundled("ExamBank")
        }
        return url
    }

    private func fixturesFolder() throws -> URL {
        guard let url = Bundle(for: Self.self).url(forResource: "ExamBankFixtures", withExtension: nil),
              FileManager.default.fileExists(atPath: url.path) else {
            throw unbundled("ExamBankFixtures")
        }
        return url
    }

    private func decode<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
        try JSONDecoder().decode(type, from: try Data(contentsOf: url))
    }

    private func object(_ url: URL) throws -> [String: Any] {
        guard let json = try JSONSerialization.jsonObject(with: try Data(contentsOf: url)) as? [String: Any] else {
            throw NSError(domain: "ExamBankTests", code: 2, userInfo: [NSLocalizedDescriptionKey: "not a JSON object: \(url)"])
        }
        return json
    }

    // MARK: - Snapshot sanity

    func testBundledSnapshotDecodesAndValidatesClean() throws {
        let snapshot = try ExamBankLoader.load(folder: try appSnapshotFolder())
        XCTAssertEqual(snapshot.bank.contentVersion, 1)
        XCTAssertEqual(snapshot.bank.blueprintVersion, snapshot.blueprint.id)
        XCTAssertFalse(snapshot.bank.tasks.isEmpty)
        XCTAssertFalse(snapshot.manifests.isEmpty)
        XCTAssertEqual(ExamBankValidation.validateSnapshot(blueprint: snapshot.blueprint,
                                                           bank: snapshot.bank,
                                                           manifests: snapshot.manifests), [],
                       "bundled snapshot must pass every validation rule")
    }

    func testSeedBankCoversEveryBlueprintTaskType() throws {
        let snapshot = try ExamBankLoader.load(folder: try appSnapshotFolder())
        let blueprintTypes = Set(snapshot.blueprint.skills.flatMap { $0.parts.flatMap { $0.taskTypes } })
        let bankTypes = Set(snapshot.bank.tasks.map { $0.taskType })
        for type in blueprintTypes {
            XCTAssertTrue(bankTypes.contains(type), "seed bank must demonstrate \(type.rawValue)")
        }
    }

    func testUnreviewedSeedContentIsNeverApproved() throws {
        let snapshot = try ExamBankLoader.load(folder: try appSnapshotFolder())
        for task in snapshot.bank.tasks {
            XCTAssertNotEqual(task.review.status, .approved,
                              "agent-side seed content must stay draft until a human reviews it: \(task.id)")
        }
    }

    // MARK: - Shared decode contract (expectations.json)

    func testBaseFixturesValidateClean() throws {
        let fixtures = try fixturesFolder()
        let blueprint = try decode(ExamBlueprint.self, from: fixtures.appendingPathComponent("base-blueprint.json"))
        let bank = try decode(ExamBankFile.self, from: fixtures.appendingPathComponent("base-bank.json"))
        let manifest = try decode(ExamSetManifest.self, from: fixtures.appendingPathComponent("base-manifest.json"))
        XCTAssertEqual(ExamBankValidation.validateSnapshot(blueprint: blueprint, bank: bank, manifests: [manifest]), [])
    }

    func testInvalidBanksRaiseTheirPinnedCodes() throws {
        let fixtures = try fixturesFolder()
        let expectations = try object(fixtures.appendingPathComponent("expectations.json"))
        let blueprint = try decode(ExamBlueprint.self, from: fixtures.appendingPathComponent("base-blueprint.json"))
        guard let cases = expectations["invalidBanks"] as? [[String: Any]] else { return XCTFail("expectations invalidBanks missing") }
        for entry in cases {
            guard let file = entry["file"] as? String, let code = entry["code"] as? String else {
                return XCTFail("expectations invalidBanks entry malformed")
            }
            let bank = try decode(ExamBankFile.self, from: fixtures.appendingPathComponent(file))
            let codes = ExamBankValidation.validateBank(bank, blueprint: blueprint).map(\.code)
            XCTAssertTrue(codes.contains(code), "\(file) must raise \(code), got \(codes)")
            // allCodes pins the COMPLETE set: mirrors that early-exit from a task
            // (as the Swift unknown-rubric bug did) cannot hide (review round-2).
            if let allCodes = entry["allCodes"] as? [String] {
                XCTAssertEqual(Set(codes), Set(allCodes), "\(file) must raise exactly \(allCodes)")
            }
        }
    }

    func testWrongAnswerShapeThrowsOnSwiftToo() throws {
        // Direct mirror of the Next "answer-shape guards" describe (review R1).
        let (_, baseBank) = try vectors()
        let form = baseBank.tasks.first { $0.id == "task-write-form-1" }!
        let choice = baseBank.tasks.first { $0.id == "task-read-rtf-1" }!
        XCTAssertThrowsError(try ExamScoring.scoreObjectiveSection([form], answers: [form.id: .value("18.06.2026")]))
        XCTAssertThrowsError(try ExamScoring.scoreObjectiveSection([choice], answers: [choice.id: .form(["whatever": "richtig"])]))
        XCTAssertThrowsError(try ExamScoring.scoreFormTask(choice, answers: [:]))
    }

    func testStructuralFixturesRaiseValidatorCodesHere() throws {
        // Zod rejects these files outright on Next (tested there). iOS Codable is
        // permissive by design, so the validator mirror must raise the pinned
        // structural code instead (review R2).
        let fixtures = try fixturesFolder()
        let expectations = try object(fixtures.appendingPathComponent("expectations.json"))
        let blueprint = try decode(ExamBlueprint.self, from: fixtures.appendingPathComponent("base-blueprint.json"))
        guard let cases = expectations["invalidBanksStructural"] as? [[String: String]] else { return XCTFail("expectations invalidBanksStructural missing") }
        XCTAssertFalse(cases.isEmpty)
        for entry in cases {
            let bank = try decode(ExamBankFile.self, from: fixtures.appendingPathComponent(entry["file"]!))
            let codes = ExamBankValidation.validateBank(bank, blueprint: blueprint).map(\.code)
            XCTAssertTrue(codes.contains(entry["code"]!),
                          "\(entry["file"]!) must raise \(entry["code"]!), got \(codes)")
        }
    }

    func testInvalidManifestsRaiseTheirPinnedCodes() throws {
        let fixtures = try fixturesFolder()
        let expectations = try object(fixtures.appendingPathComponent("expectations.json"))
        let blueprint = try decode(ExamBlueprint.self, from: fixtures.appendingPathComponent("base-blueprint.json"))
        guard let cases = expectations["invalidManifests"] as? [[String: String]] else { return XCTFail("expectations invalidManifests missing") }
        for entry in cases {
            let manifest = try decode(ExamSetManifest.self, from: fixtures.appendingPathComponent(entry["file"]!))
            let bank = try decode(ExamBankFile.self, from: fixtures.appendingPathComponent(entry["pairBank"]!))
            let codes = ExamBankValidation.validateManifest(manifest, bank: bank, blueprint: blueprint).map(\.code)
            XCTAssertTrue(codes.contains(entry["code"]!),
                          "\(entry["file"]!) must raise \(entry["code"]!), got \(codes)")
        }
    }

    // MARK: - Parity vectors (scoring-vectors.json)

    private struct Vectors: Decodable {
        struct SeedCase: Decodable { let seed: String; let count: Int; let expectedOrder: [String] }
        struct ShuffleCase: Decodable { let seed: String; let expected: [Int] }
        struct FormCase: Decodable { let rule: String; let raw: String; let accepted: String; let expectedMatch: Bool }
        struct SectionCase: Decodable {
            /// Vectors mix plain answers (strings) with per-slot form answers
            /// (objects) — mirrors `Record<string, string | FormAnswers>` in TS.
            enum AnswerValue: Decodable {
                case value(String)
                case form([String: String])
                init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let plain = try? container.decode(String.self) { self = .value(plain); return }
                    self = .form(try container.decode([String: String].self))
                }
                var taskAnswer: ExamScoring.TaskAnswer {
                    switch self {
                    case .value(let string): return .value(string)
                    case .form(let slots): return .form(slots)
                    }
                }
            }
            let taskIds: [String]
            let answers: [String: AnswerValue]
            let expected: Expected
            struct Expected: Decodable, Equatable {
                let points: Int
                let maxPoints: Int
                let answered: Int
                let unansweredTaskIds: [String]
            }
        }
        struct RubricCase: Decodable { let rubricId: String; let selections: [String: Double]; let expectedTotal: Double? }
        struct TransitionCase: Decodable { let from: String; let to: String; let allowed: Bool }

        let seedVectors: [SeedCase]
        let shuffleVectors: [ShuffleCase]
        let formCases: [FormCase]
        let sectionCases: [SectionCase]
        let rubricCases: [RubricCase]
        let transitionCases: [TransitionCase]
    }

    private func vectors() throws -> (Vectors, ExamBankFile) {
        let fixtures = try fixturesFolder()
        let vectors = try decode(Vectors.self, from: fixtures.appendingPathComponent("scoring-vectors.json"))
        let baseBank = try decode(ExamBankFile.self, from: fixtures.appendingPathComponent("base-bank.json"))
        return (vectors, baseBank)
    }

    func testFormNormalizationVectors() throws {
        let (vectors, _) = try vectors()
        for entry in vectors.formCases {
            let rule = FormFieldRule(rawValue: entry.rule)!
            let matches = ExamNormalization.normalize(rule: rule, raw: entry.raw)
                == ExamNormalization.normalize(rule: rule, raw: entry.accepted)
            XCTAssertEqual(matches, entry.expectedMatch,
                           "\(entry.rule): '\(entry.raw)' vs '\(entry.accepted)'")
        }
    }

    func testShuffleAndSeedVectorsMatchTypeScript() throws {
        let (vectors, _) = try vectors()
        for entry in vectors.shuffleVectors {
            let seed = UInt32(entry.seed)!
            XCTAssertEqual(ExamSelection.deterministicShuffle([0, 1, 2, 3, 4, 5, 6, 7], seed: seed), entry.expected,
                           "shuffle seed \(entry.seed) must match TS mulberry32")
        }
        for entry in vectors.seedVectors {
            let candidates = (1...8).map { TaskRevisionPin(taskId: "task-candidate-\($0)", revision: 1) }
            let result = try ExamSelection.selectVariants(.init(candidates: candidates, count: entry.count, seed: entry.seed))
            XCTAssertEqual(result.entries.map(\.taskId), entry.expectedOrder, "seed \(entry.seed)")
            XCTAssertFalse(result.reusedSeen)
        }
    }

    func testSectionScoringVectors() throws {
        let (vectors, baseBank) = try vectors()
        let tasksById = Dictionary(uniqueKeysWithValues: baseBank.tasks.map { ($0.id, $0) })
        for entry in vectors.sectionCases {
            let tasks = entry.taskIds.map { tasksById[$0]! }
            let answers = entry.answers.mapValues { $0.taskAnswer }
            let score = try ExamScoring.scoreObjectiveSection(tasks, answers: answers)
            XCTAssertEqual(
                ExamScoring.SectionScore(points: score.points, maxPoints: score.maxPoints,
                                         answered: score.answered, unansweredKeys: score.unansweredKeys),
                ExamScoring.SectionScore(points: entry.expected.points, maxPoints: entry.expected.maxPoints,
                                         answered: entry.expected.answered,
                                         unansweredKeys: entry.expected.unansweredTaskIds)
            )
        }
    }

    func testRubricTotalVectors() throws {
        let (vectors, baseBank) = try vectors()
        var rubricsById: [String: Rubric] = [:]
        for rubric in baseBank.rubrics { rubricsById[rubric.id] = rubric }
        for entry in vectors.rubricCases {
            let rubric = rubricsById[entry.rubricId]!
            if let expected = entry.expectedTotal {
                XCTAssertEqual(try ExamScoring.rubricTotal(rubric, selections: entry.selections), expected)
            } else {
                XCTAssertThrowsError(try ExamScoring.rubricTotal(rubric, selections: entry.selections),
                                     "\(entry.rubricId) \(entry.selections) must be rejected")
            }
        }
    }

    func testTransitionVectors() throws {
        let (vectors, _) = try vectors()
        for entry in vectors.transitionCases {
            let from = AttemptStatus(rawValue: entry.from)!
            let to = AttemptStatus(rawValue: entry.to)!
            XCTAssertEqual(AttemptLifecycle.canTransition(from: from, to: to), entry.allowed, "\(entry.from) → \(entry.to)")
        }
    }

    // MARK: - Three-copy integrity (bank-lock.json)

    func testBundledFilesMatchBankLock() throws {
        let snapshotFolder = try appSnapshotFolder()
        let fixtures = try fixturesFolder()
        let lock = try object(fixtures.appendingPathComponent("bank-lock.json"))
        guard let files = lock["files"] as? [String: String] else { return XCTFail("lock.files missing") }
        XCTAssertFalse(files.isEmpty)
        for (rel, expected) in files {
            let inApp = snapshotFolder.appendingPathComponent(rel)
            XCTAssertTrue(FileManager.default.fileExists(atPath: inApp.path), "app bundle missing \(rel)")
            let hash = sha256(try Data(contentsOf: inApp))
            XCTAssertEqual(hash, expected, "hash drift for \(rel)")
        }
        // Exact inventory BOTH ways: an unlisted file (e.g. a sneaky bank/x.v99.json)
        // would win the vN-highest loader despite intact hashes (review R5).
        let managed = ["blueprints", "bank", "manifests", "fixtures"]
        var actual: [String] = []
        for sub in managed {
            let dir = snapshotFolder.appendingPathComponent(sub)
            actual += try regularFiles(under: dir, prefix: "\(sub)/")
        }
        XCTAssertEqual(actual.sorted(), files.keys.sorted(), "bundled snapshot must contain exactly the locked files")

        let fxExpected = files.keys.filter { $0.hasPrefix("fixtures/") }
            .map { String($0.dropFirst("fixtures/".count)) }.sorted()
        let fxActual = try regularFiles(under: fixtures, prefix: "")
            .filter { $0 != "bank-lock.json" }
            .sorted()
        XCTAssertEqual(fxActual, fxExpected, "test fixtures must contain exactly the locked fixture files")
    }

    /// Relative paths of every real file under `dir` (directories excluded —
    /// `subpathsOfDirectory` also lists them and they would masquerade as files).
    private func regularFiles(under dir: URL, prefix: String) throws -> [String] {
        try FileManager.default.subpathsOfDirectory(atPath: dir.path)
            .filter { !$0.hasPrefix(".") }
            .filter { sub in
                var isDir: ObjCBool = false
                return FileManager.default.fileExists(atPath: dir.appendingPathComponent(sub).path, isDirectory: &isDir) && !isDir.boolValue
            }
            .map { "\(prefix)\($0)" }
    }

    private func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
