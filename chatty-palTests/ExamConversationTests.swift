import XCTest
@testable import chatty_pal

private final class CapturingBot: BotServicing {
    private(set) var lastExam: ExamMode?
    private(set) var lastInstruction: String?
    private(set) var lastMessages: [BotMessage] = []
    private(set) var streamCalls = 0
    private(set) var examCalls: [ExamMode?] = []
    private(set) var messageCalls: [(message: String, messages: [BotMessage])] = []

    func sendMessage(instruction: String, message: String, messages: [BotMessage], exam: ExamMode?) async throws -> BotResponse {
        lastExam = exam
        lastInstruction = instruction
        lastMessages = messages
        examCalls.append(exam)
        messageCalls.append((message, messages))
        return BotResponse(message: "Guten Tag!")
    }

    func streamMessage(instruction: String, message: String, messages: [BotMessage], exam: ExamMode?) -> AsyncThrowingStream<String, Error> {
        lastExam = exam
        lastInstruction = instruction
        lastMessages = messages
        examCalls.append(exam)
        messageCalls.append((message, messages))
        streamCalls += 1
        return AsyncThrowingStream { continuation in
            continuation.yield("Guten Tag!")
            continuation.finish()
        }
    }
}

private final class StubTeacher: TeacherServicing {
    func fixText(message: String, language: String) async throws -> TeacherResponse {
        throw NSError(domain: "test", code: 1)
    }
}

private final class StubTranslate: TranslationServicing {
    func translate(message: String) async throws -> TranslationResponse {
        throw NSError(domain: "test", code: 1)
    }
}

private final class StubSynth: SpeechSynthesizing {
    func synthesizeSpeech(text: String, voiceId: String?) async throws -> Data {
        throw NSError(domain: "test", code: 1)
    }
}

private final class StubSpeech: SpeechRecognition {
    var onTranscription: ((String, Bool) -> Void)?
    var onError: ((Error) -> Void)?
    var onAudioLevel: ((Float) -> Void)?
    func requestPermissions() async -> Bool { true }
    func startRecording() throws {}
    func stopRecording() -> Data? { nil }
}

private final class StubPlayback: AudioPlayback {
    var onFinished: (() -> Void)?
    func play(_ data: Data) throws {}
    func stop() {}
}

private final class StubTranscriber: AudioTranscribing {
    func transcribe(wav: Data, language: String) async throws -> String { "" }
}

private final class StubMonitor: VoiceMonitoring {
    var onLevel: ((Float) -> Void)?
    func start() throws {}
    func stop() {}
    func feed(_ rms: Float) {}
}

private final class InMemoryStore: ChatStore {
    private var messages: [ChatMessage] = []
    func load() -> [ChatMessage] { messages }
    func save(_ messages: [ChatMessage]) { self.messages = messages }
    func flush() async throws {}
}

@MainActor
final class ExamConversationTests: XCTestCase {

    private func makeEngine(persona: ChatPersona, bot: CapturingBot) -> ChatEngine {
        let dependencies = ChatEngineDependencies(
            bot: bot,
            teacher: StubTeacher(),
            translate: StubTranslate(),
            synth: StubSynth(),
            makeSpeech: { _ in StubSpeech() },
            playback: StubPlayback(),
            transcriber: StubTranscriber(),
            makeMonitor: { StubMonitor() }
        )
        return ChatEngine(
            persona: persona,
            store: InMemoryStore(),
            dependencies: dependencies,
            silenceWindow: 0.05,
            sendSuppressionWindow: 0.05,
            resumeDelay: 0.05
        )
    }

    func testExamMissionSendsServerOwnedContract() async {
        let bot = CapturingBot()
        let persona = ChatPersona.examinerA1(lesson: "l3-speaking-introduce", stage: "Sich vorstellen")
        let engine = makeEngine(persona: persona, bot: bot)
        engine.isTTSEnabled = false
        await engine.sendText("Hallo, ich bin Mateusz.")
        try? await Task.sleep(for: .milliseconds(200))

        let exam = bot.examCalls.compactMap { $0 }.first { $0.mode == "speaking" }
        XCTAssertEqual(exam?.mode, "speaking")
        XCTAssertEqual(exam?.lessonId, "l3-speaking-introduce")
        XCTAssertEqual(exam?.stage, "Sich vorstellen")
        let chatStreamCalls = bot.examCalls.compactMap { $0 }.filter { $0 == exam }
        XCTAssertFalse(chatStreamCalls.isEmpty)
        let chatCall = bot.messageCalls.first { $0.message == "Hallo, ich bin Mateusz." }!
        XCTAssertEqual(chatCall.messages.filter { $0.role == "user" }.map(\.content), [])
    }

    func testExamMissionPassesLearnerContext() async {
        let bot = CapturingBot()
        let persona = ChatPersona.examinerA1(
            lesson: "l3-speaking-introduce",
            stage: "Sich vorstellen",
            learnerContext: "Mateusz lives in Warsaw and enjoys football."
        )
        let engine = makeEngine(persona: persona, bot: bot)
        engine.isTTSEnabled = false
        await engine.sendText("Guten Tag!")
        try? await Task.sleep(for: .milliseconds(200))

        XCTAssertEqual(
            bot.examCalls.compactMap { $0 }.first(where: { $0.mode == "speaking" })?.learnerContext,
            "Mateusz lives in Warsaw and enjoys football."
        )
    }

    func testExamFeedbackRequestDoesNotAddSyntheticLearnerBubble() async {
        let bot = CapturingBot()
        let persona = ChatPersona.examinerA1(lesson: "l3-speaking-introduce", stage: "Sich vorstellen")
        let engine = makeEngine(persona: persona, bot: bot)
        engine.isTTSEnabled = false

        engine.requestExamFeedback()
        try? await Task.sleep(for: .milliseconds(200))

        let request = "Bitte geben Sie mir jetzt die strukturierte Prüfungszusammenfassung."
        XCTAssertNotNil(bot.messageCalls.first { $0.message == request })
        XCTAssertFalse(engine.messages.contains { $0.role == .user && $0.message == request })
        XCTAssertTrue(engine.messages.contains { $0.role == .assistant })
    }

    func testRefreshingStageClearsOnlyThatStageHistory() {
        let suiteName = "lesson-chat-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let firstStage = LessonChatStore(
            lessonID: "l3-speaking-introduce",
            stageID: "Sich vorstellen",
            defaults: defaults,
            scope: "test"
        )
        let secondStage = LessonChatStore(
            lessonID: "l3-speaking-introduce",
            stageID: "Über die Familie sprechen",
            defaults: defaults,
            scope: "test"
        )
        let messages = [
            ChatMessage(role: .user, message: "Ich heiße Mateusz."),
            ChatMessage(role: .assistant, message: "Wo wohnen Sie?")
        ]

        firstStage.save(messages)

        XCTAssertEqual(firstStage.load().map(\.message), messages.map(\.message))
        XCTAssertTrue(secondStage.load().isEmpty)

        firstStage.clear()
        XCTAssertTrue(firstStage.load().isEmpty)
    }

    func testLegacyExaminerPersonaSendsExaminerModeWithBriefing() async {
        let bot = CapturingBot()
        let scenario = "You are the examiner. Ask for name and city."
        let persona = ChatPersona.examinerA1(scenario: scenario, lesson: "a1-spr-vorstellung")
        let engine = makeEngine(persona: persona, bot: bot)
        engine.isTTSEnabled = false
        await engine.sendText("Ich bin Mateusz.")
        try? await Task.sleep(for: .milliseconds(200))

        let exam = bot.examCalls.compactMap { $0 }.first { $0.mode == "examiner" }
        XCTAssertEqual(exam?.mode, "examiner")
        XCTAssertEqual(exam?.lessonId, "a1-spr-vorstellung")
        XCTAssertEqual(exam?.briefing, scenario)
    }

    func testNonExamChatSendsNoExamContract() async {
        let bot = CapturingBot()
        let persona = ChatPersona.main(language: LanguageConfig.default, level: "B1")
        let engine = makeEngine(persona: persona, bot: bot)
        engine.isTTSEnabled = false
        await engine.sendText("Hey!")
        try? await Task.sleep(for: .milliseconds(200))

        XCTAssertNil(bot.lastExam)
    }

    func testExamPayloadSendsFullMissionHistoryWithRoles() async {
        let bot = CapturingBot()
        let persona = ChatPersona.examinerA1(lesson: "l3-speaking-introduce", stage: "Sich vorstellen")
        let engine = makeEngine(persona: persona, bot: bot)
        engine.isTTSEnabled = false
        let turns = ["Hallo!", "Ich heiße Mateusz.", "Ich wohne in Warschau.",
                     "Ich bin Lehrer.", "Ich habe zwei Schwestern.",
                     "Mein Hobby ist Fußball.", "Danke, auf Wiedersehen!"]
        for turn in turns {
            await engine.sendText(turn)
            try? await Task.sleep(for: .milliseconds(150))
        }

        let lastCall = bot.messageCalls.first { $0.message == turns.last }!
        let userContents = lastCall.messages.filter { $0.role == "user" }.map(\.content)
        XCTAssertEqual(userContents, Array(turns.dropLast()),
                       "every earlier learner turn must reach the bot, not just the last few")
        XCTAssertEqual(lastCall.messages.filter { $0.role == "assistant" }.count, turns.count - 1)
        XCTAssertEqual(lastCall.messages.first?.role, "system")
        XCTAssertNotNil(bot.examCalls.compactMap { $0 }.first(where: { $0.mode == "speaking" }))
    }
}
