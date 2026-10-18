// Swift mirror of chatty-pal/src/lib/exam/bank-validate.ts — SAME issue codes on
// the SAME rules. The shared fixtures (fixtures/expectations.json in the bundled
// bank) are run against this validator by ExamBankTests, so Next and iOS cannot
// drift apart on what "invalid bank" means. Structural rules (empty labels,
// single-option keys, revision >= 1) are Zod-level on Next; Codable is permissive
// by design, so they live HERE as the codes bad-revision/empty-field/too-few-options
// (expectations.json: invalidBanksStructural, review R2).
import Foundation

struct BankIssue: Equatable {
    var path: String
    var code: String
    var message: String
}

enum ExamBankValidation {
    static func validateSnapshot(blueprint: ExamBlueprint, bank: ExamBankFile, manifests: [ExamSetManifest]) -> [BankIssue] {
        validateBlueprint(blueprint)
            + validateBank(bank, blueprint: blueprint)
            + manifests.flatMap { validateManifest($0, bank: bank, blueprint: blueprint) }
    }

    static func validateBlueprint(_ blueprint: ExamBlueprint) -> [BankIssue] {
        var issues: [BankIssue] = []
        for skillEntry in blueprint.skills {
            var seen = Set<Int>()
            for partEntry in skillEntry.parts where !seen.insert(partEntry.part).inserted {
                issues.append(BankIssue(path: "skills(\(skillEntry.skill.rawValue)).parts[\(partEntry.part)].part",
                                        code: "duplicate-part",
                                        message: "part \(partEntry.part) declared twice for \(skillEntry.skill.rawValue)"))
            }
        }
        return issues
    }

    // MARK: Answer key ↔ task type + required source assets (mirrors KEY_BY_TYPE / REQUIRED_ASSET_KINDS)

    static func requiredKeyType(for taskType: TaskType) -> AnswerKeyType? {
        switch taskType {
        case .readingTrueFalse, .listeningTrueFalse: return .trueFalse
        case .readingSourceMatch, .listeningChoice: return .singleChoice
        case .formFill: return .formFields
        case .message, .speakingIntro, .speakingInfoCard, .speakingRequestCard: return .productive
        case .dailyPractice: return nil
        }
    }

    static func requiredAssets(for taskType: TaskType) -> [(kind: String, min: Int)] {
        switch taskType {
        case .readingTrueFalse: return [("text", 1)]
        case .readingSourceMatch: return [("text", 2)]
        case .listeningChoice, .listeningTrueFalse: return [("audio", 1)]
        case .speakingInfoCard, .speakingRequestCard: return [("card", 1)]
        default: return []
        }
    }

    // MARK: Bank

    static func validateBank(_ bank: ExamBankFile, blueprint: ExamBlueprint) -> [BankIssue] {
        var issues: [BankIssue] = []

        if bank.blueprintVersion != blueprint.id {
            issues.append(BankIssue(path: "blueprintVersion", code: "blueprint-mismatch",
                                    message: "bank cites '\(bank.blueprintVersion)', expected '\(blueprint.id)'"))
        }

        var assetIds = Set<String>()
        var assetsById: [String: ExamAsset] = [:]
        bank.assets.enumerated().forEach { index, asset in
            if !assetIds.insert(asset.id).inserted {
                issues.append(BankIssue(path: "assets[\(index)].id", code: "duplicate-id", message: "asset '\(asset.id)' declared twice"))
            }
            assetsById[asset.id] = asset
        }

        var rubricIds = Set<String>()
        var rubricsById: [String: Rubric] = [:]
        bank.rubrics.enumerated().forEach { index, rubric in
            if !rubricIds.insert(rubric.id).inserted {
                issues.append(BankIssue(path: "rubrics[\(index)].id", code: "duplicate-id", message: "rubric '\(rubric.id)' declared twice"))
            }
            rubricsById[rubric.id] = rubric
            rubric.criteria.forEach { criterion in
                if Set(criterion.permittedScores).count != criterion.permittedScores.count {
                    issues.append(BankIssue(path: "rubrics(\(rubric.id)).criteria(\(criterion.id)).permittedScores",
                                            code: "duplicate-score",
                                            message: "permittedScores must not repeat values"))
                }
                // Strictly increasing is checked on the ORIGINAL order (review R2):
                // [1.5, 1.5, 3] is ascending but still an invalid ladder.
                let scores = criterion.permittedScores
                let notIncreasing = scores.dropFirst().enumerated().contains { offset, value in value <= scores[offset] }
                if notIncreasing {
                    issues.append(BankIssue(path: "rubrics(\(rubric.id)).criteria(\(criterion.id)).permittedScores",
                                            code: "unsorted-scores",
                                            message: "permittedScores must be strictly increasing"))
                }
            }
        }

        var taskIds = Set<String>()
        for (index, task) in bank.tasks.enumerated() {
            let path = "tasks[\(index)](\(task.id))"
            if !taskIds.insert(task.id).inserted {
                issues.append(BankIssue(path: "\(path).id", code: "duplicate-id", message: "task '\(task.id)' declared twice"))
            }
            if !task.id.hasPrefix("task-") {
                issues.append(BankIssue(path: "\(path).id", code: "bad-id-prefix",
                                        message: "new bank task ids must live in the 'task-' namespace (blueprint §8)"))
            }
            if task.revision < 1 {
                issues.append(BankIssue(path: "\(path).revision", code: "bad-revision",
                                        message: "revisions start at 1"))
            }
            if task.instructionDe.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(BankIssue(path: "\(path).instructionDe", code: "empty-field",
                                        message: "instructions must not be empty"))
            }
            if task.blueprintVersion != blueprint.id {
                issues.append(BankIssue(path: "\(path).blueprintVersion", code: "blueprint-mismatch",
                                        message: "task cites '\(task.blueprintVersion)', expected '\(blueprint.id)'"))
            }
            let hasEvidence = (task.review.reviewer ?? "").isEmpty == false && (task.review.date ?? "").isEmpty == false
            if task.review.status == .approved && !hasEvidence {
                issues.append(BankIssue(path: "\(path).review", code: "approval-without-evidence",
                                        message: "approved tasks must record reviewer and date"))
            }

            // part / skill matrix
            if task.taskType == .dailyPractice {
                if task.part != nil {
                    issues.append(BankIssue(path: "\(path).part", code: "daily-practice-part",
                                            message: "dailyPractice must not claim an exam part"))
                }
            } else if let part = task.part {
                if let partEntry = blueprint.part(skill: task.skill, part: part) {
                    if !partEntry.taskTypes.contains(task.taskType) {
                        issues.append(BankIssue(path: "\(path).taskType", code: "task-type-mismatch",
                                                message: "\(task.skill.rawValue) Teil \(part) accepts \(partEntry.taskTypes.map(\.rawValue)), got '\(task.taskType.rawValue)'"))
                    }
                } else {
                    issues.append(BankIssue(path: "\(path).part", code: "unknown-part",
                                            message: "blueprint has no part \(part) for \(task.skill.rawValue)"))
                }
            } else {
                issues.append(BankIssue(path: "\(path).part", code: "missing-part",
                                        message: "\(task.taskType.rawValue) requires an exam part"))
            }
            // Review R2: unknown/missing part no longer `continue`s — key and
            // asset rules below must still run like they do in Next/JS.

            // key ↔ type
            let expectedKey = requiredKeyType(for: task.taskType)
            if expectedKey == nil {
                if task.answerKey != nil {
                    issues.append(BankIssue(path: "\(path).answerKey", code: "unexpected-key",
                                            message: "dailyPractice must stay unassessed in the bank"))
                }
            } else if let key = task.answerKey {
                if key.keyType != expectedKey {
                    issues.append(BankIssue(path: "\(path).answerKey.type", code: "key-type-mismatch",
                                            message: "\(task.taskType.rawValue) requires key type '\(expectedKey!.rawValue)', got '\(key.keyType.rawValue)'"))
                }
                switch key {
                case .singleChoice(let options, let correctOptionId):
                    if options.count < 2 {
                        issues.append(BankIssue(path: "\(path).answerKey.options", code: "too-few-options",
                                                message: "choice keys need at least two options"))
                    }
                    if options.contains { $0.label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } {
                        issues.append(BankIssue(path: "\(path).answerKey.options", code: "empty-field",
                                                message: "option labels must not be empty"))
                    }
                    let ids = options.map(\.id)
                    if Set(ids).count != ids.count {
                        issues.append(BankIssue(path: "\(path).answerKey.options", code: "duplicate-option-id",
                                                message: "option ids must be unique within a task"))
                    }
                    if !ids.contains(correctOptionId) {
                        issues.append(BankIssue(path: "\(path).answerKey.correctOptionId", code: "unknown-option",
                                                message: "correctOptionId '\(correctOptionId)' is not among the options"))
                    }
                case .formFields(let fields):
                    if fields.contains { $0.label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } {
                        issues.append(BankIssue(path: "\(path).answerKey.fields", code: "empty-field",
                                                message: "field labels must not be empty"))
                    }
                    let slots = fields.map(\.slot)
                    if Set(slots).count != slots.count {
                        issues.append(BankIssue(path: "\(path).answerKey.fields", code: "duplicate-slot",
                                                message: "form field slots must be unique"))
                    }
                case .productive(let rubricId, _, _, _):
                    // Review round-2: NO `continue` after unknown-rubric — the
                    // asset rules below must still run like in Next/JS.
                    if let rubric = rubricsById[rubricId] {
                        if rubric.skill != task.skill || rubric.part != task.part {
                            issues.append(BankIssue(path: "\(path).answerKey.rubricId", code: "rubric-skill-mismatch",
                                                    message: "rubric '\(rubricId)' targets \(rubric.skill.rawValue) Teil \(rubric.part), task is \(task.skill.rawValue) Teil \(String(describing: task.part))"))
                        }
                    } else {
                        issues.append(BankIssue(path: "\(path).answerKey.rubricId", code: "unknown-rubric",
                                                message: "rubric '\(rubricId)' is not defined"))
                    }
                case .trueFalse:
                    break
                }
            } else {
                issues.append(BankIssue(path: "\(path).answerKey", code: "missing-key",
                                        message: "\(task.taskType.rawValue) requires a '\(expectedKey!.rawValue)' key"))
            }

            // assets
            var seenAsset = Set<String>()
            for assetId in task.assetIds {
                if !seenAsset.insert(assetId).inserted {
                    issues.append(BankIssue(path: "\(path).assetIds", code: "duplicate-asset", message: "asset '\(assetId)' referenced twice"))
                }
                if !assetIds.contains(assetId) {
                    issues.append(BankIssue(path: "\(path).assetIds", code: "unknown-asset", message: "asset '\(assetId)' is not defined"))
                }
            }
            for requirement in requiredAssets(for: task.taskType) {
                let count = task.assetIds.filter { assetsById[$0]?.kind == requirement.kind }.count
                if count < requirement.min {
                    issues.append(BankIssue(path: "\(path).assetIds", code: "missing-source",
                                            message: "\(task.taskType.rawValue) needs at least \(requirement.min) '\(requirement.kind)' asset(s)"))
                }
            }
        }

        var legacyIds = Set<String>()
        for alias in bank.legacyAliases {
            if !legacyIds.insert(alias.legacyId).inserted {
                issues.append(BankIssue(path: "legacyAliases(\(alias.legacyId)).legacyId", code: "duplicate-alias",
                                        message: "alias for '\(alias.legacyId)' declared twice"))
            }
            if !taskIds.contains(alias.taskId) {
                issues.append(BankIssue(path: "legacyAliases(\(alias.legacyId)).taskId", code: "unknown-task",
                                        message: "alias targets '\(alias.taskId)' which does not exist"))
            }
        }
        return issues
    }

    // MARK: Manifest

    static func validateManifest(_ manifest: ExamSetManifest, bank: ExamBankFile, blueprint: ExamBlueprint) -> [BankIssue] {
        var issues: [BankIssue] = []
        let path = "manifest(\(manifest.id))"
        if manifest.blueprintVersion != blueprint.id {
            issues.append(BankIssue(path: "\(path).blueprintVersion", code: "blueprint-mismatch",
                                    message: "manifest cites '\(manifest.blueprintVersion)'"))
        }

        // Manual build: `Dictionary(uniqueKeysWithValues:)` would CRASH on the
        // very duplicate-id case validation exists to report (review R2).
        var tasksById: [String: ExamTask] = [:]
        for task in bank.tasks { tasksById[task.id] = task }
        var pinned = Set<String>()
        var orders = Set<Int>()

        for entry in manifest.entries {
            let entryPath = "\(path).entries(\(entry.taskId)@\(entry.revision))"
            guard let task = tasksById[entry.taskId] else {
                issues.append(BankIssue(path: entryPath, code: "unknown-task", message: "task '\(entry.taskId)' is not in the bank"))
                continue
            }
            if task.status == .retired {
                issues.append(BankIssue(path: entryPath, code: "retired-task",
                                        message: "'\(task.id)' is retired and must not appear in manifests (blueprint §8)"))
            }
            if task.revision != entry.revision {
                issues.append(BankIssue(path: "\(entryPath).revision", code: "revision-drift",
                                        message: "manifest pins revision \(entry.revision) but the bank has revision \(task.revision)"))
            }
            if !pinned.insert(entry.taskId).inserted {
                issues.append(BankIssue(path: entryPath, code: "duplicate-pin", message: "\(entry.taskId) pinned twice"))
            }
            if entry.skill != task.skill || entry.part != task.part {
                issues.append(BankIssue(path: entryPath, code: "entry-skill-drift",
                                        message: "entry says \(entry.skill.rawValue) Teil \(String(describing: entry.part)) but the task is \(task.skill.rawValue) Teil \(String(describing: task.part))"))
            }
            if !orders.insert(entry.order).inserted {
                issues.append(BankIssue(path: "\(entryPath).order", code: "duplicate-order", message: "order \(entry.order) used twice"))
            }
            if manifest.purpose != .training && task.review.status != .approved {
                issues.append(BankIssue(path: entryPath, code: "unapproved-task",
                                        message: "\(task.id) has review status '\(task.review.status.rawValue)'; \(manifest.purpose.rawValue) manifests require 'approved'"))
            }
        }

        if manifest.purpose != .training {
            for skillEntry in blueprint.skills {
                for partEntry in skillEntry.parts {
                    let count = manifest.entries.filter { $0.skill == skillEntry.skill && $0.part == partEntry.part }.count
                    if count != partEntry.itemCount {
                        issues.append(BankIssue(path: "\(path).entries(\(skillEntry.skill.rawValue).\(partEntry.part))",
                                                code: "coverage-gap",
                                                message: "\(skillEntry.skill.rawValue) Teil \(partEntry.part) needs \(partEntry.itemCount) entries, manifest pins \(count)"))
                    }
                    if let requiredSlots = partEntry.requiredSlots {
                        for entry in manifest.entries where entry.skill == skillEntry.skill && entry.part == partEntry.part {
                            if case .formFields(let fields)? = tasksById[entry.taskId]?.answerKey, fields.count != requiredSlots {
                                issues.append(BankIssue(path: "\(path).entries(\(entry.taskId)).answerKey.fields",
                                                        code: "slot-count",
                                                        message: "this form needs exactly \(requiredSlots) fields, has \(fields.count)"))
                            }
                        }
                    }
                }
            }
        }
        return issues
    }
}
