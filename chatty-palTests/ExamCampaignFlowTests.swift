import XCTest
@testable import chatty_pal

private final class FlowCapturingBot: BotServicing {
    private(set) var lastExam: ExamMode?
    private(set) var examCalls: [ExamMode?] = []
    private(set) var messageCalls: [(message: String, messages: [BotMessage])] = []

    func sendMessage(instruction: String, message: String, messages: [BotMessage], exam: ExamMode?) async throws -> BotResponse {
        lastExam = exam
        examCalls.append(exam)
        messageCalls.append((message, messages))
        return BotResponse(message: "Gut gemacht!")
    }

    func streamMessage(instruction: String, message: String, messages: [BotMessage], exam: ExamMode?) -> AsyncThrowingStream<String, Error> {
        lastExam = exam
        examCalls.append(exam)
        messageCalls.append((message, messages))
        return AsyncThrowingStream { continuation in
            continuation.yield("Gut gemacht!")
            continuation.finish()
        }
    }
}

private final class FlowStubTeacher: TeacherServicing {
    func fixText(message: String, language: String) async throws -> TeacherResponse {
        throw NSError(domain: "test", code: 1)
    }
}

private final class FlowStubTranslate: TranslationServicing {
    func translate(message: String) async throws -> TranslationResponse {
        throw NSError(domain: "test", code: 1)
    }
}

private final class FlowStubSynth: SpeechSynthesizing {
    func synthesizeSpeech(text: String, voiceId: String?) async throws -> Data {
        throw NSError(domain: "test", code: 1)
    }
}

private final class FlowStubSpeech: SpeechRecognition {
    var onTranscription: ((String, Bool) -> Void)?
    var onError: ((Error) -> Void)?
    var onAudioLevel: ((Float) -> Void)?
    func requestPermissions() async -> Bool { true }
    func startRecording() throws {}
    func stopRecording() -> Data? { nil }
}

private final class FlowStubPlayback: AudioPlayback {
    var onFinished: (() -> Void)?
    func play(_ data: Data) throws {}
    func stop() {}
}

private final class FlowStubTranscriber: AudioTranscribing {
    func transcribe(wav: Data, language: String) async throws -> String { "" }
}

private final class FlowStubMonitor: VoiceMonitoring {
    var onLevel: ((Float) -> Void)?
    func start() throws {}
    func stop() {}
    func feed(_ rms: Float) {}
}

private final class FlowStore: ChatStore {
    private var messages: [ChatMessage] = []
    func load() -> [ChatMessage] { messages }
    func save(_ messages: [ChatMessage]) { self.messages = messages }
}

@MainActor
final class ExamCampaignFlowTests: XCTestCase {

    private func freshProgress() -> ExamCampaignProgress {
        ExamCampaignProgress(defaults: UserDefaults(suiteName: "campaign-flow-\(UUID().uuidString)")!)
    }

    // MARK: - Campaign flow

    func testFullZoneJourneyUnlocksCheckpointAndBeyond() {
        let progress = freshProgress()
        let zone = ExamCampaignCatalog.zones[0]
        guard let checkpoint = zone.checkpoints.first else {
            return XCTFail("first zone must have a checkpoint")
        }

        for lesson in zone.lessons {
            progress.record(MissionResult(stars: 2, correctCount: 5, exerciseCount: 10), for: lesson.id)
        }
        XCTAssertTrue(progress.isCheckpointUnlocked(checkpoint))

        progress.recordCheckpointComplete(checkpoint.id)
        XCTAssertTrue(progress.isComplete(checkpoint.id))

        for zone in ExamCampaignCatalog.zones.dropFirst() {
            for lesson in zone.lessons {
                progress.record(MissionResult(stars: 2, correctCount: 5, exerciseCount: 10), for: lesson.id)
            }
            for checkpoint in zone.checkpoints {
                progress.recordCheckpointComplete(checkpoint.id)
            }
        }
        XCTAssertTrue(progress.isFinalExamUnlocked())
    }

    func testMissionOutcomeRecordsResultAndAdvancesCurrentNode() {
        let progress = freshProgress()
        let zone = ExamCampaignCatalog.zones[0]
        let first = zone.lessons[0]
        let second = zone.lessons[1]

        let initial = progress.currentNode()
        XCTAssertNotNil(initial)

        progress.record(MissionResult(stars: 3, correctCount: 8, exerciseCount: 8,
                                      completedSpeaking: true, completedWriting: true), for: first.id)
        let stored = progress.progress(for: first.id)!
        XCTAssertEqual(stored.stars, 3)
        XCTAssertTrue(stored.completedSpeaking)
        XCTAssertTrue(stored.completedWriting)

        let next = progress.currentNode()
        switch next?.node {
        case .lesson(let lesson):
            XCTAssertEqual(lesson.id, second.id)
        default:
            XCTFail("expected the second lesson to be the current node, got \(String(describing: next?.node))")
        }
    }

    // MARK: - Speaking lifecycle

    func testCampaignSpeakingContractAndAutoOpening() async {
        let lesson = ExamCampaignCatalog.lesson(id: "l3-speaking-introduce")!
        let task = lesson.speaking!
        let bot = FlowCapturingBot()
        let dependencies = ChatEngineDependencies(
            bot: bot,
            teacher: FlowStubTeacher(),
            translate: FlowStubTranslate(),
            synth: FlowStubSynth(),
            makeSpeech: { _ in FlowStubSpeech() },
            playback: FlowStubPlayback(),
            transcriber: FlowStubTranscriber(),
            makeMonitor: { FlowStubMonitor() }
        )
        let engine = ChatEngine(
            persona: .examinerA1(lesson: lesson.id, stage: task.stages[0].id),
            store: FlowStore(),
            dependencies: dependencies,
            silenceWindow: 0.05,
            sendSuppressionWindow: 0.05,
            resumeDelay: 0.05
        )
        engine.isTTSEnabled = false
        let opening = CampaignSpeakingView.opening(lessonID: "l3-speaking-introduce", stageID: "Sich vorstellen")
        await engine.startExam(with: opening)

        XCTAssertFalse(opening.isEmpty)
        XCTAssertEqual(engine.messages.last?.role, .assistant)
        XCTAssertEqual(engine.messages.last?.message, opening)
        XCTAssertTrue(bot.messageCalls.isEmpty, "the static greeting must not be sent to the bot")
    }

    func testCampaignSpeakingUsesSelectedStage() {
        let lesson = ExamCampaignCatalog.lesson(id: "l3-speaking-introduce")!
        let task = lesson.speaking!
        let dependencies = ChatEngineDependencies(
            bot: FlowCapturingBot(),
            teacher: FlowStubTeacher(),
            translate: FlowStubTranslate(),
            synth: FlowStubSynth(),
            makeSpeech: { _ in FlowStubSpeech() },
            playback: FlowStubPlayback(),
            transcriber: FlowStubTranscriber(),
            makeMonitor: { FlowStubMonitor() }
        )

        // The card's selected tab drives the stage the view opens (not the hard-coded first).
        let second = CampaignSpeakingView(task: task, lessonID: lesson.id, initialStageIndex: 1, dependencies: dependencies)
        XCTAssertEqual(second.initialStageID, "Über die Familie sprechen")
        let first = CampaignSpeakingView(task: task, lessonID: lesson.id, dependencies: dependencies)
        XCTAssertEqual(first.initialStageID, "Sich vorstellen")
        let clamped = CampaignSpeakingView(task: task, lessonID: lesson.id, initialStageIndex: 99, dependencies: dependencies)
        XCTAssertEqual(clamped.initialStageID, task.stages[task.stages.count - 1].id)

        // The selected stage drives the greeting shown to the learner.
        XCTAssertEqual(
            CampaignSpeakingView.opening(lessonID: lesson.id, stageID: second.initialStageID),
            "Guten Tag. Ich heiße Frau Müller und bin Ihre Prüferin. Erzählen Sie bitte etwas über Ihre Familie."
        )
    }

    // MARK: - Word-review collection

    func testMissionWordsAreCollectedIntoWordReview() {
        let suiteName = "campaign-words-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = WordReviewStore(defaults: defaults)
        let lesson = ExamCampaignCatalog.allLessons.first { !$0.vocabulary.isEmpty && !$0.phrases.isEmpty }!

        let source = "campaign:\(lesson.id)"
        for item in lesson.vocabulary {
            store.add(german: item.german, english: item.english, example: item.example, source: source)
        }
        for phrase in lesson.phrases {
            store.add(german: phrase.german, english: phrase.english, example: nil, source: source)
        }

        let expected = lesson.vocabulary.count + lesson.phrases.count
        XCTAssertGreaterThanOrEqual(expected, 1, "lesson must have reviewable content")
        XCTAssertEqual(store.words.filter { $0.source == source }.count, expected)

        // Adding the same lesson again must not duplicate words.
        for item in lesson.vocabulary {
            store.add(german: item.german, english: item.english, example: item.example, source: source)
        }
        XCTAssertEqual(store.words.filter { $0.source == source }.count, expected)
    }

    // MARK: - Existing-chat regression

    func testNonExamChatStillSendsFullHistoryAndNoExamContract() async {
        let bot = FlowCapturingBot()
        let dependencies = ChatEngineDependencies(
            bot: bot,
            teacher: FlowStubTeacher(),
            translate: FlowStubTranslate(),
            synth: FlowStubSynth(),
            makeSpeech: { _ in FlowStubSpeech() },
            playback: FlowStubPlayback(),
            transcriber: FlowStubTranscriber(),
            makeMonitor: { FlowStubMonitor() }
        )
        let engine = ChatEngine(
            persona: .main(language: LanguageConfig.default, level: "B1"),
            store: FlowStore(),
            dependencies: dependencies,
            silenceWindow: 0.05,
            sendSuppressionWindow: 0.05,
            resumeDelay: 0.05
        )
        engine.isTTSEnabled = false
        await engine.sendText("Hi!")
        try? await Task.sleep(for: .milliseconds(200))
        await engine.sendText("How are you?")
        try? await Task.sleep(for: .milliseconds(200))

        XCTAssertNil(bot.lastExam)
        let call = bot.messageCalls.first { $0.message == "How are you?" }!
        let userContents = call.messages.filter { $0.role == "user" }.map(\.content)
        XCTAssertEqual(userContents, ["Hi!"], "non-exam chat keeps the previous learner turn in history")
    }
}
