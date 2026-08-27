import XCTest
@testable import chatty_pal

private struct FakeError: LocalizedError, Equatable {
    let code: String
    var errorDescription: String? { "Fake error: \(code)" }
}

private final class RecordingStore: ChatStore {
    private(set) var saved: [[ChatMessage]] = []
    private var stored: [ChatMessage] = []

    func preload(_ messages: [ChatMessage]) {
        stored = messages
    }

    func load() -> [ChatMessage] {
        stored
    }

    func save(_ messages: [ChatMessage]) {
        stored = messages
        saved.append(messages)
    }
}

private final class FakeBot: BotServicing {
    enum Mode: Equatable {
        case ok(String)
        case fail
        case suspend
    }

    struct Call: Equatable {
        let message: String
        let roles: [String]
    }

    var mode: Mode = .ok("Bot reply")
    var streamChunks: [String]?
    private(set) var calls: [Call] = []
    private(set) var exams: [ExamMode?] = []
    private var pending: CheckedContinuation<BotResponse, Error>?
    private var pendingStream: AsyncThrowingStream<String, Error>.Continuation?

    func sendMessage(instruction: String, message: String, messages: [BotMessage], exam: ExamMode?) async throws -> BotResponse {
        calls.append(Call(message: message, roles: messages.map(\.role)))
        exams.append(exam)
        switch mode {
        case .ok(let reply):
            return BotResponse(message: reply)
        case .fail:
            throw FakeError(code: "bot-fail")
        case .suspend:
            return try await withCheckedThrowingContinuation { continuation in
                self.pending = continuation
            }
        }
    }

    func streamMessage(instruction: String, message: String, messages: [BotMessage], exam: ExamMode?) -> AsyncThrowingStream<String, Error> {
        let mode = self.mode
        let chunks = self.streamChunks
        calls.append(Call(message: message, roles: messages.map(\.role)))
        exams.append(exam)
        return AsyncThrowingStream { continuation in
            switch mode {
            case .ok(let reply):
                for chunk in chunks ?? [reply] {
                    continuation.yield(chunk)
                }
                continuation.finish()
            case .fail:
                continuation.finish(throwing: FakeError(code: "stream-fail"))
            case .suspend:
                self.pendingStream = continuation
            }
        }
    }

    func resolve(with reply: String) {
        if let stream = pendingStream {
            stream.yield(reply)
            stream.finish()
            pendingStream = nil
            return
        }
        pending?.resume(returning: BotResponse(message: reply))
        pending = nil
    }
}

private final class FakeTeacher: TeacherServicing {
    enum Mode: Equatable {
        case ok
        case fail
        case suspend
    }

    var mode: Mode = .ok
    var exactReply: String? = nil
    private(set) var calls: [String] = []
    private(set) var contexts: [[(role: String, content: String)]] = []
    private var pending: CheckedContinuation<TeacherResponse, Error>?

    func fixText(message: String, language: String) async throws -> TeacherResponse {
        try await fixText(message: message, language: language, context: [])
    }

    func fixText(message: String, language: String, context: [TeacherContextMessage]) async throws -> TeacherResponse {
        calls.append(message)
        contexts.append(context.map { ($0.role, $0.content) })
        if let exactReply {
            return TeacherResponse(message: exactReply)
        }
        switch mode {
        case .ok:
            return TeacherResponse(message: "Fixed: \(message)")
        case .fail:
            throw FakeError(code: "teacher-fail")
        case .suspend:
            return try await withCheckedThrowingContinuation { continuation in
                self.pending = continuation
            }
        }
    }

    func resolve() {
        pending?.resume(returning: TeacherResponse(message: "Fixed"))
        pending = nil
    }
}

private final class FakeTranslate: TranslationServicing {
    enum Mode: Equatable {
        case ok
        case fail
    }

    var mode: Mode = .ok
    private(set) var calls: [String] = []

    func translate(message: String) async throws -> TranslationResponse {
        calls.append(message)
        switch mode {
        case .ok:
            return TranslationResponse(message: "Translation: \(message)")
        case .fail:
            throw FakeError(code: "translate-fail")
        }
    }
}

private final class FakeSynth: SpeechSynthesizing {
    enum Mode: Equatable {
        case ok
        case fail
    }

    var mode: Mode = .ok
    private(set) var calls: [(text: String, voiceId: String?)] = []

    func synthesizeSpeech(text: String, voiceId: String?) async throws -> Data {
        calls.append((text, voiceId))
        switch mode {
        case .ok:
            return Data([0x01])
        case .fail:
            throw FakeError(code: "synth-fail")
        }
    }
}

private final class FakeSpeech: SpeechRecognition {
    var onTranscription: ((String, Bool) -> Void)?
    var onError: ((Error) -> Void)?
    var onAudioLevel: ((Float) -> Void)?
    var permissionGranted = true
    var startError: Error?
    var recordedWAV: Data? = Data([0x52, 0x49, 0x46, 0x46])
    private(set) var startCount = 0
    private(set) var stopCount = 0

    func requestPermissions() async -> Bool {
        permissionGranted
    }

    func startRecording() throws {
        startCount += 1
        if let startError {
            throw startError
        }
    }

    func stopRecording() -> Data? {
        stopCount += 1
        return recordedWAV
    }

    func emit(_ text: String, isFinal: Bool) {
        onTranscription?(text, isFinal)
    }

    func emitLevel(_ rms: Float) {
        onAudioLevel?(rms)
    }

    func fail() {
        onError?(FakeError(code: "speech-fail"))
    }
}

private final class FakePlayback: AudioPlayback {
    var onFinished: (() -> Void)?
    var autoFinish = true
    private(set) var playCount = 0
    private(set) var stopCount = 0

    func play(_ data: Data) throws {
        playCount += 1
        if autoFinish {
            onFinished?()
        }
    }

    func stop() {
        stopCount += 1
    }

    func finish() {
        onFinished?()
    }
}

private final class FakeTranscriber: AudioTranscribing {
    enum Mode {
        case empty
        case text(String)
        case fail
    }
    var mode: Mode = .empty
    private(set) var calls: [(wav: Data, language: String)] = []

    func transcribe(wav: Data, language: String) async throws -> String {
        calls.append((wav, language))
        switch mode {
        case .empty:
            return ""
        case .text(let text):
            return text
        case .fail:
            throw FakeError(code: "transcribe-fail")
        }
    }
}

private final class FakeMonitor: VoiceMonitoring {
    var onLevel: ((Float) -> Void)?
    private(set) var startCount = 0
    private(set) var stopCount = 0
    private(set) var started = false

    func start() throws {
        startCount += 1
        started = true
    }

    func stop() {
        stopCount += 1
        started = false
    }

    func feed(_ rms: Float) {
        onLevel?(rms)
    }
}

@MainActor
private final class EngineHarness {
    let bot = FakeBot()
    let teacher = FakeTeacher()
    let translate = FakeTranslate()
    let synth = FakeSynth()
    let speech: FakeSpeech
    let playback = FakePlayback()
    let transcriber = FakeTranscriber()
    let monitor: FakeMonitor
    let store: RecordingStore
    let engine: ChatEngine

    init(
        persona: ChatPersona = .main(language: LanguageConfig.default, level: "B1"),
        store: RecordingStore? = nil,
        silenceWindow: TimeInterval = 0.05
    ) {
        let speech = FakeSpeech()
        let monitor = FakeMonitor()
        let resolvedStore = store ?? RecordingStore()
        self.speech = speech
        self.monitor = monitor
        self.store = resolvedStore
        let dependencies = ChatEngineDependencies(
            bot: bot,
            teacher: teacher,
            translate: translate,
            synth: synth,
            makeSpeech: { _ in speech },
            playback: playback,
            transcriber: transcriber,
            makeMonitor: { monitor }
        )
        self.engine = ChatEngine(
            persona: persona,
            store: resolvedStore,
            dependencies: dependencies,
            silenceWindow: silenceWindow,
            sendSuppressionWindow: 0.05,
            resumeDelay: 0.05
        )
    }
}

@MainActor
final class ChatEngineTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.set(VoiceTranscriptionMode.cloud.rawValue, forKey: "voiceTranscriptionMode")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "voiceTranscriptionMode")
        super.tearDown()
    }

    private func makeHarness() -> EngineHarness {
        EngineHarness()
    }

    private func settle(_ milliseconds: Int = 100) async {
        try? await Task.sleep(for: .milliseconds(milliseconds))
    }

    private func userMessages(_ harness: EngineHarness) -> [ChatMessage] {
        harness.engine.messages.filter { $0.role == .user }
    }

    func testLoadFromStoreOnInit() {
        let store = RecordingStore()
        store.preload([ChatMessage(role: .user, message: "hi")])
        let harness = EngineHarness(store: store)
        XCTAssertEqual(harness.engine.messages.map(\.message), ["hi"])
    }

    func testSendTextAppendsUserAssistantTeacherAndPersists() async {
        let harness = makeHarness()
        harness.engine.sendText("Hello")
        await settle()

        let roles = harness.engine.messages.map(\.role)
        XCTAssertEqual(roles.first, .user)
        XCTAssertEqual(roles.dropFirst().count, 2)
        XCTAssertTrue(Set(roles.dropFirst()) == Set([.assistant, .teacher]))
        XCTAssertEqual(harness.engine.messages.first?.message, "Hello")
        XCTAssertEqual(harness.engine.voiceState, .idle)
        XCTAssertEqual(harness.engine.isGenerating, false)
        XCTAssertEqual(harness.bot.calls.first?.message, "Hello")
        // The learner turn travels as `message`; history holds only prior turns.
        XCTAssertEqual(harness.bot.calls.first?.roles, ["system"])
        XCTAssertEqual(harness.teacher.calls, ["Hello"])
        XCTAssertFalse(harness.store.saved.isEmpty)
        XCTAssertEqual(harness.store.saved.last?.map(\.role) ?? [], roles)
    }

    func testExamSpeakingAttachesInlineCorrectionWithoutTeacherBubble() async {
        let harness = EngineHarness(persona: .examinerA1(lesson: "a1-small-talk", stage: "greeting"))
        harness.engine.sendText("Ich habe 25 jahre")
        await settle()

        let roles = harness.engine.messages.map(\.role)
        XCTAssertFalse(roles.contains(.teacher))
        XCTAssertEqual(harness.engine.messages.first { $0.role == .user }?.correction, "Fixed: Ich habe 25 jahre")
        XCTAssertEqual(harness.store.saved.last?.first { $0.role == .user }?.correction, "Fixed: Ich habe 25 jahre")
    }

    func testFreeChatSkipsTeacherBubbleWhenTextUnchanged() async {
        let harness = makeHarness()
        harness.teacher.exactReply = "Ich wohne in Berlin."
        harness.engine.sendText("Ich wohne in Berlin.")
        await settle()

        XCTAssertFalse(harness.engine.messages.contains { $0.role == .teacher })
    }

    func testExamSpeakingSkipsCorrectionWhenTextUnchanged() async {
        let harness = EngineHarness(persona: .examinerA1(lesson: "a1-small-talk", stage: "greeting"))
        harness.teacher.exactReply = "Ich wohne in Berlin."
        harness.engine.sendText("Ich wohne in Berlin.")
        await settle()

        XCTAssertFalse(harness.engine.messages.contains { $0.role == .teacher })
        XCTAssertNil(harness.engine.messages.first { $0.role == .user }?.correction)
    }

    func testCorrectionContextIsBoundedToRecentLearnerAndExaminerTurns() async {
        let harness = EngineHarness(persona: .examinerA1(lesson: "a1-small-talk", stage: "greeting"))
        for text in ["one", "two", "three", "four", "five"] {
            harness.engine.sendText(text)
            await settle()
        }

        XCTAssertEqual(
            (harness.teacher.contexts.last ?? []).map { "\($0.role): \($0.content)" },
            ["assistant: Bot reply", "user: four", "assistant: Bot reply", "user: five"]
        )
    }

    func testCorrectionContextExcludesTeacherTranslationAndSuggestionMessages() async {
        let store = RecordingStore()
        store.preload([
            ChatMessage(role: .user, message: "one"),
            ChatMessage(role: .assistant, message: "r1"),
            ChatMessage(role: .teacher, message: "t1"),
            ChatMessage(role: .translation, message: "tr1"),
            ChatMessage(role: .suggestion, message: "s1"),
            ChatMessage(role: .user, message: "two"),
            ChatMessage(role: .assistant, message: "r2"),
        ])
        let harness = EngineHarness(persona: .examinerA1(lesson: "a1-small-talk", stage: "greeting"), store: store)
        harness.engine.sendText("three")
        await settle()

        XCTAssertEqual(
            (harness.teacher.contexts.last ?? []).map { "\($0.role): \($0.content)" },
            ["assistant: r1", "user: two", "assistant: r2", "user: three"]
        )
    }

    func testReloadKeepsInlineCorrectionVisible() {
        let store = RecordingStore()
        let corrected = ChatMessage(role: .user, message: "Ich habe 25 jahre", correction: "Ich habe 25 Jahre.")
        store.preload([corrected])
        let harness = EngineHarness(persona: .examinerA1(lesson: "a1-small-talk", stage: "greeting"), store: store)

        XCTAssertEqual(harness.engine.messages.first?.correction, "Ich habe 25 Jahre.")
    }

    func testCorrectionContextTrimsLongMessages() async {
        let store = RecordingStore()
        let long = String(repeating: "a", count: 700)
        store.preload([ChatMessage(role: .user, message: long)])
        let harness = EngineHarness(persona: .examinerA1(lesson: "a1-small-talk", stage: "greeting"), store: store)
        harness.engine.sendText("next")
        await settle()

        let context = harness.teacher.contexts.last ?? []
        XCTAssertEqual(context.first?.content.count, 500)
        XCTAssertEqual(context.last?.content, "next")
    }

    func testFixTextPayloadUsesProofreaderModelAndSystemInstruction() throws {
        let payload = TeacherService.fixTextPayload(
            message: "hallo",
            language: "German",
            context: [TeacherContextMessage(role: "user", content: "vorher")]
        )
        let data = try JSONEncoder().encode(payload)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["message"] as? String, "hallo")
        XCTAssertEqual(json["model"] as? String, TeacherService.fixTextModel)
        let messages = json["messages"] as! [[String: String]]
        XCTAssertEqual(messages.first?["role"], "system")
        XCTAssertTrue(messages.first?["content"]?.contains("Return ONLY") == true)
        XCTAssertEqual(messages.last, ["role": "user", "content": "vorher"])
    }

    func testTeacherRequestOmitsNilModelSoServerKeepsFineTunedDefault() throws {
        let payload = TeacherRequest(message: "framed", messages: [], model: nil)
        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(payload)) as! [String: Any]

        XCTAssertNil(json["model"])
        XCTAssertEqual(json["message"] as? String, "framed")
    }

    func testChatMessageDecodesLegacyJSONWithoutCorrection() throws {
        let id = UUID()
        let json = #"{"id":"\#(id.uuidString)","role":"user","message":"hallo"}"#
        let decoded = try JSONDecoder().decode(ChatMessage.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(decoded.id, id)
        XCTAssertEqual(decoded.message, "hallo")
        XCTAssertNil(decoded.correction)
    }

    func testSendTextBotFailureAppendsErrorMessage() async {
        let harness = makeHarness()
        harness.bot.mode = .fail
        harness.engine.sendText("Hello")
        await settle()

        let errorMessage = harness.engine.messages.first { $0.role == .assistant }
        XCTAssertEqual(errorMessage?.message, "Error: Fake error: bot-fail")
        XCTAssertEqual(harness.engine.voiceState, .idle)
        XCTAssertEqual(harness.engine.isGenerating, false)
    }

    func testVoiceFlowSendsTranscriptAndAutoResumesMic() async {
        let harness = makeHarness()
        harness.engine.startRecording()
        await settle()
        XCTAssertEqual(harness.engine.voiceState, .recording)

        harness.speech.emit("Hallo wie geht's", isFinal: true)
        await settle(250)

        XCTAssertEqual(userMessages(harness).map(\.message), ["Hallo wie geht's"])
        XCTAssertTrue(harness.engine.messages.contains { $0.role == .assistant && $0.message == "Bot reply" })
        XCTAssertEqual(harness.engine.voiceState, .recording)
        XCTAssertEqual(harness.speech.startCount, 2)
        XCTAssertEqual(harness.playback.playCount, 1)
        XCTAssertEqual(harness.synth.calls.first?.text, "Bot reply")
        XCTAssertEqual(harness.synth.calls.first?.voiceId, "Vicki")
    }

    func testVoiceFlowAutoResumesMicWhenTTSFails() async {
        let harness = makeHarness()
        harness.synth.mode = .fail
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("hello", isFinal: true)
        await settle(250)

        XCTAssertEqual(harness.engine.voiceState, .recording)
        XCTAssertEqual(harness.speech.startCount, 2)
        XCTAssertEqual(harness.playback.playCount, 0)
    }

    func testManualStopSendsTranscriptAndDoesNotResume() async {
        let harness = makeHarness()
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("good morning", isFinal: false)
        await settle(1)
        harness.engine.stopSpeechAndSend()
        await settle(250)

        XCTAssertEqual(userMessages(harness).map(\.message), ["good morning"])
        XCTAssertEqual(harness.engine.voiceState, .idle)
        XCTAssertEqual(harness.speech.startCount, 1)
        XCTAssertEqual(harness.speech.stopCount, 1)
    }

    func testDedupPartialAndFinalDoNotDoubleSend() async {
        let harness = makeHarness()
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("Hallo", isFinal: false)
        harness.speech.emit("Hallo", isFinal: true)
        await settle(250)

        XCTAssertEqual(userMessages(harness).map(\.message), ["Hallo"])
    }

    func testBotFailureAfterVoiceSendAutoResumesMic() async {
        let harness = makeHarness()
        harness.bot.mode = .fail
        harness.teacher.mode = .suspend
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("help me", isFinal: true)
        await settle(250)

        XCTAssertEqual(harness.engine.voiceState, .recording)
        XCTAssertEqual(harness.speech.startCount, 2)
        let last = harness.engine.messages.last
        XCTAssertEqual(last?.role, .assistant)
        XCTAssertEqual(last?.message, "Error: Fake error: bot-fail")
    }

    func testVoiceFlowSendsWhisperTextWhenAvailable() async {
        let harness = makeHarness()
        harness.transcriber.mode = .text("Ich möchte ein Wasser")
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("partial", isFinal: false)
        await settle(250)

        XCTAssertEqual(userMessages(harness).map(\.message), ["Ich möchte ein Wasser"])
        XCTAssertEqual(harness.transcriber.calls.first?.language, "de")
    }

    func testVoiceFlowFallsBackToLocalTranscriptWhenWhisperFails() async {
        let harness = makeHarness()
        harness.transcriber.mode = .fail
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("Hallo wie geht's", isFinal: true)
        await settle(250)

        XCTAssertEqual(userMessages(harness).map(\.message), ["Hallo wie geht's"])
    }

    func testVoiceFlowFallsBackToLocalTranscriptWhenWhisperEmpty() async {
        let harness = makeHarness()
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("guten tag", isFinal: true)
        await settle(250)

        XCTAssertEqual(userMessages(harness).map(\.message), ["guten tag"])
    }

    func testLocalModeSendsOnDeviceTranscriptWithoutCloudCall() async {
        UserDefaults.standard.removeObject(forKey: "voiceTranscriptionMode")
        let harness = makeHarness()
        harness.transcriber.mode = .text("should not be used")
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("guten tag", isFinal: true)
        await settle(250)

        XCTAssertEqual(userMessages(harness).map(\.message), ["guten tag"])
        XCTAssertEqual(harness.transcriber.calls.count, 0)
        XCTAssertEqual(harness.engine.isTranscribing, false)
    }

    func testVoiceModeDefaultsToLocalAndFallsBackOnUnknown() {
        UserDefaults.standard.removeObject(forKey: "voiceTranscriptionMode")
        XCTAssertEqual(AppEnvironment.voiceTranscriptionMode, .local)
        UserDefaults.standard.set("cloud", forKey: "voiceTranscriptionMode")
        XCTAssertEqual(AppEnvironment.voiceTranscriptionMode, .cloud)
        UserDefaults.standard.set("bogus", forKey: "voiceTranscriptionMode")
        XCTAssertEqual(AppEnvironment.voiceTranscriptionMode, .local)
    }

    func testManualStopUsesWhisperTextAndDoesNotResume() async {
        let harness = makeHarness()
        harness.transcriber.mode = .text("Danke, auf Wiedersehen")
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("danke", isFinal: false)
        await settle(1)
        harness.engine.stopSpeechAndSend()
        await settle(250)

        XCTAssertEqual(userMessages(harness).map(\.message), ["Danke, auf Wiedersehen"])
        XCTAssertEqual(harness.engine.voiceState, .idle)
        XCTAssertEqual(harness.speech.startCount, 1)
    }

    func testBotReplyStreamsIntoBubbleAndSpeaksPerSentence() async {
        let harness = makeHarness()
        harness.bot.streamChunks = ["Ich bin ", "Anna. ", "Und du? "]
        harness.engine.sendText("Hallo")
        await settle(300)

        let assistant = harness.engine.messages.first { $0.role == .assistant }
        XCTAssertEqual(assistant?.message, "Ich bin Anna. Und du? ")
        XCTAssertEqual(harness.synth.calls.map(\.text), ["Ich bin Anna.", "Und du?"])
        XCTAssertEqual(harness.engine.voiceState, .idle)
        XCTAssertEqual(harness.engine.isGenerating, false)
    }

    func testBotStreamFailureFallsBackToOneShot() async {
        let harness = makeHarness()
        harness.bot.mode = .fail
        harness.engine.sendText("Hallo")
        await settle(300)

        XCTAssertEqual(harness.engine.messages.first { $0.role == .assistant }?.message, "Error: Fake error: bot-fail")
        XCTAssertEqual(harness.engine.voiceState, .idle)
    }

    func testHandsFreeResumesOnlyAfterStreamDrains() async {
        let harness = makeHarness()
        harness.bot.streamChunks = ["Erste. ", "Zweite. "]
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("hallo", isFinal: true)
        await settle(300)

        XCTAssertEqual(userMessages(harness).map(\.message), ["hallo"])
        XCTAssertEqual(harness.synth.calls.map(\.text), ["Erste.", "Zweite."])
        XCTAssertEqual(harness.engine.voiceState, .recording)
        XCTAssertEqual(harness.speech.startCount, 2)
    }

    func testInterruptMidStreamCancelsGeneration() async {
        let harness = makeHarness()
        harness.bot.mode = .suspend
        harness.teacher.mode = .suspend
        harness.engine.sendText("question")
        await settle()
        XCTAssertEqual(harness.engine.voiceState, .waitingForBot)

        harness.engine.interrupt()

        XCTAssertEqual(harness.engine.voiceState, .idle)
        XCTAssertEqual(harness.engine.messages.map(\.role), [.user])
        XCTAssertEqual(harness.synth.calls.count, 0)
    }

    func testInterruptStopsEverything() async {
        let harness = makeHarness()
        harness.engine.startRecording()
        await settle()

        harness.engine.interrupt()

        XCTAssertEqual(harness.engine.voiceState, .idle)
        XCTAssertEqual(harness.engine.isGenerating, false)
        XCTAssertEqual(harness.speech.stopCount, 1)
        // 1x from beginRecording (stops any playback), 1x from interrupt.
        XCTAssertEqual(harness.playback.stopCount, 2)
    }

    func testInterruptCancelsInFlightBot() async {
        let harness = makeHarness()
        harness.bot.mode = .suspend
        harness.teacher.mode = .suspend
        harness.engine.sendText("question")
        await settle()
        XCTAssertEqual(harness.engine.voiceState, .waitingForBot)

        harness.engine.interrupt()
        harness.bot.resolve(with: "late reply")
        await settle()

        XCTAssertEqual(harness.engine.messages.map(\.role), [.user])
        XCTAssertEqual(harness.engine.voiceState, .idle)
    }

    func testTranslateAppendsMessageAndError() async {
        let harness = makeHarness()
        await harness.engine.translate("hello")
        XCTAssertEqual(harness.engine.messages.map(\.role), [.translation])
        XCTAssertEqual(harness.engine.messages.map(\.message), ["Translation: hello"])

        harness.translate.mode = .fail
        await harness.engine.translate("world")
        XCTAssertEqual(harness.engine.messages.last?.message, "Translation error: Fake error: translate-fail")
    }

    func testSuggestAppendsMessageAndError() async {
        let harness = makeHarness()
        await harness.engine.suggest(for: "bot line")
        XCTAssertEqual(harness.engine.messages.map(\.role), [.suggestion])
        XCTAssertEqual(harness.engine.messages.first?.message, "Bot reply")

        harness.bot.mode = .fail
        await harness.engine.suggest(for: "bot line")
        XCTAssertEqual(harness.engine.messages.last?.message, "Could not get suggestions: Fake error: bot-fail")
    }

    func testTTSDisabledSkipsSynthesisAndFinishes() async {
        let harness = makeHarness()
        harness.engine.isTTSEnabled = false
        harness.engine.sendText("hello")
        await settle(50)
        XCTAssertEqual(harness.synth.calls.count, 0)
        XCTAssertEqual(harness.engine.voiceState, .idle)

        harness.engine.isTTSEnabled = true
        harness.engine.speak("hello")
        await settle(50)
        XCTAssertEqual(harness.synth.calls.count, 1)
        XCTAssertEqual(harness.playback.playCount, 1)
        XCTAssertEqual(harness.engine.voiceState, .idle)
    }

    func testReplayWhileRecordingStopsMicAndAutoResumesAfterTTS() async {
        let harness = makeHarness()
        harness.engine.startRecording()
        await settle()

        harness.engine.speak("hello")
        await settle(250)

        XCTAssertEqual(harness.engine.voiceState, .recording)
        XCTAssertEqual(harness.speech.startCount, 2)
        XCTAssertEqual(harness.playback.playCount, 1)
    }

    func testSilenceTimerSendsTranscript() async {
        let harness = makeHarness()
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("still here", isFinal: false)
        await settle(250)

        XCTAssertEqual(userMessages(harness).map(\.message), ["still here"])
    }

    func testVoiceActivityResetsSilenceTimer() async {
        let harness = EngineHarness(silenceWindow: 0.3)
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("still here", isFinal: false)
        await settle(200)
        harness.speech.emitLevel(0.1)
        await settle(200)

        // 400ms after the partial: without the voice reset it would have sent at 300ms.
        XCTAssertEqual(userMessages(harness).map(\.message), [])

        await settle(250)
        XCTAssertEqual(userMessages(harness).map(\.message), ["still here"])
    }

    func testSilentLevelDoesNotResetTimer() async {
        let harness = EngineHarness(silenceWindow: 0.3)
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("still here", isFinal: false)
        await settle(200)
        harness.speech.emitLevel(0.001)
        await settle(250)

        // Below-threshold energy must not extend the silence window.
        XCTAssertEqual(userMessages(harness).map(\.message), ["still here"])
    }

    func testVoiceActivitySetsAudioLevel() async {
        let harness = makeHarness()
        harness.engine.startRecording()
        await settle()

        harness.speech.emitLevel(0.1)
        await settle(20)
        XCTAssertEqual(harness.engine.audioLevel, 1, accuracy: 0.001)

        harness.speech.emitLevel(0.03)
        await settle(20)
        XCTAssertEqual(harness.engine.audioLevel, 0.375, accuracy: 0.001)

        harness.speech.emitLevel(0.001)
        await settle(20)
        XCTAssertEqual(harness.engine.audioLevel, 0, accuracy: 0.001)
    }

    func testAudioLevelResetsOnStop() async {
        let harness = makeHarness()
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("hi", isFinal: false)
        harness.speech.emitLevel(0.1)
        await settle(20)
        XCTAssertGreaterThan(harness.engine.audioLevel, 0)

        harness.engine.stopSpeechAndSend()
        XCTAssertEqual(harness.engine.audioLevel, 0)
        await settle(250)
        XCTAssertEqual(harness.engine.voiceState, .idle)

        harness.engine.startRecording()
        await settle()
        XCTAssertEqual(harness.engine.voiceState, .recording)
        harness.speech.emitLevel(0.1)
        await settle(20)
        XCTAssertGreaterThan(harness.engine.audioLevel, 0)
        harness.engine.interrupt()
        XCTAssertEqual(harness.engine.audioLevel, 0)
    }

    func testIsFinalMidSentenceDoesNotSendUntilSilence() async {
        let harness = EngineHarness(silenceWindow: 0.3)
        harness.engine.startRecording()
        await settle()

        harness.speech.emit("Hallo", isFinal: true)
        await settle(200)
        XCTAssertEqual(userMessages(harness).map(\.message), [])

        harness.speech.emit("Hallo und wie geht dir", isFinal: false)
        await settle(200)
        XCTAssertEqual(userMessages(harness).map(\.message), [])

        await settle(250)
        XCTAssertEqual(userMessages(harness).map(\.message), ["Hallo und wie geht dir"])
    }

    func testMicLockedDuringBotTurn() async {
        let harness = makeHarness()
        harness.playback.autoFinish = false
        harness.bot.mode = .suspend
        harness.teacher.mode = .suspend
        harness.engine.sendText("question")
        await settle()
        XCTAssertEqual(harness.engine.voiceState, .waitingForBot)

        harness.engine.startRecording()
        await settle()
        XCTAssertEqual(harness.engine.voiceState, .waitingForBot)
        XCTAssertEqual(harness.speech.startCount, 0)

        harness.bot.resolve(with: "answer")
        await settle(150)
        XCTAssertEqual(harness.engine.voiceState, .playingTTS)

        harness.engine.startRecording()
        await settle()
        XCTAssertEqual(harness.engine.voiceState, .playingTTS)
        XCTAssertEqual(harness.speech.startCount, 0)

        harness.playback.finish()
        await settle()
        XCTAssertEqual(harness.engine.voiceState, .idle)

        harness.engine.startRecording()
        await settle()
        XCTAssertEqual(harness.engine.voiceState, .recording)
        XCTAssertEqual(harness.speech.startCount, 1)
    }

    func testTypedTextTurnDoesNotResumeMic() async {
        let harness = makeHarness()
        harness.engine.sendText("hello")
        await settle(250)

        XCTAssertEqual(harness.engine.voiceState, .idle)
        XCTAssertEqual(harness.speech.startCount, 0)
    }

    func testTTSOffMidPlaybackClearsPendingResume() async {
        let harness = EngineHarness(silenceWindow: 0.3)
        harness.playback.autoFinish = false
        harness.engine.startRecording()
        await settle()

        harness.speech.emit("hello", isFinal: false)
        await settle(450)
        XCTAssertEqual(harness.engine.voiceState, .playingTTS)

        harness.engine.toggleTTS()
        await settle()
        XCTAssertEqual(harness.engine.voiceState, .idle)
        XCTAssertEqual(harness.speech.startCount, 1)

        harness.engine.sendText("again")
        await settle(250)
        XCTAssertEqual(harness.engine.voiceState, .idle)
        XCTAssertEqual(harness.speech.startCount, 1)
    }

    // Barge-in detector with a real clock but zeroed settle/sustain so a single
    // above-threshold feed fires deterministically as soon as the monitor is armed.
    private func armedDetector() -> BargeInDetector {
        var detector = BargeInDetector()
        detector.settle = 0
        detector.sustain = 0
        detector.cooldown = 1
        return detector
    }

    func testBargeInReopensMicAndStopsBot() async {
        let harness = makeHarness()
        harness.engine.bargeInDetector = armedDetector()
        harness.playback.autoFinish = false
        harness.bot.mode = .suspend
        harness.teacher.mode = .suspend

        harness.engine.startRecording()
        await settle()
        harness.speech.emit("hallo", isFinal: true)
        await settle(250)
        XCTAssertEqual(harness.engine.voiceState, .waitingForBot)
        XCTAssertTrue(harness.monitor.started)

        harness.monitor.feed(0.5)
        await settle(50)

        XCTAssertEqual(harness.engine.voiceState, .recording)
        XCTAssertEqual(harness.speech.startCount, 2)
        XCTAssertFalse(harness.monitor.started)
        XCTAssertEqual(harness.bot.calls.count, 1)
    }

    func testBargeInContinuationMergesIntoPreviousUtterance() async {
        let harness = makeHarness()
        harness.engine.bargeInDetector = armedDetector()
        harness.playback.autoFinish = false
        harness.bot.mode = .suspend
        harness.teacher.mode = .suspend

        harness.engine.startRecording()
        await settle()
        harness.speech.emit("hallo", isFinal: true)
        await settle(250)

        harness.monitor.feed(0.5)
        await settle(50)
        XCTAssertEqual(harness.engine.voiceState, .recording)

        harness.speech.emit("wie geht dir", isFinal: true)
        await settle(250)

        XCTAssertEqual(userMessages(harness).map(\.message), ["hallo wie geht dir"])
        XCTAssertEqual(harness.bot.calls.last?.message, "hallo wie geht dir")
    }

    func testBargeInRemovesInterruptedReply() async {
        let harness = makeHarness()
        harness.engine.bargeInDetector = armedDetector()
        harness.playback.autoFinish = false
        harness.bot.mode = .suspend
        harness.teacher.mode = .suspend

        harness.engine.startRecording()
        await settle()
        harness.speech.emit("hallo", isFinal: true)
        await settle(250)

        harness.bot.resolve(with: "Gern, sag mal ")
        await settle(100)
        XCTAssertEqual(harness.engine.messages.map(\.role), [.user, .assistant])

        harness.monitor.feed(0.5)
        await settle(50)

        XCTAssertEqual(harness.engine.messages.map(\.role), [.user])
        XCTAssertEqual(harness.engine.voiceState, .recording)
    }

    func testTypedMessageCancelsPendingMerge() async {
        let harness = makeHarness()
        harness.engine.bargeInDetector = armedDetector()
        harness.playback.autoFinish = false
        harness.bot.mode = .suspend
        harness.teacher.mode = .suspend

        harness.engine.startRecording()
        await settle()
        harness.speech.emit("hallo", isFinal: true)
        await settle(250)

        harness.monitor.feed(0.5)
        await settle(50)
        XCTAssertEqual(harness.engine.voiceState, .recording)

        harness.engine.sendText("tastatur")
        await settle(250)

        XCTAssertEqual(userMessages(harness).map(\.message), ["hallo", "tastatur"])
    }
}
