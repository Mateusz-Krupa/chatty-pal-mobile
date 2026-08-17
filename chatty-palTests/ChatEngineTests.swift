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
    private(set) var calls: [Call] = []
    private var pending: CheckedContinuation<BotResponse, Error>?

    func sendMessage(instruction: String, message: String, messages: [BotMessage]) async throws -> BotResponse {
        calls.append(Call(message: message, roles: messages.map(\.role)))
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

    func resolve(with reply: String) {
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
    private(set) var calls: [String] = []
    private var pending: CheckedContinuation<TeacherResponse, Error>?

    func fixText(message: String, language: String) async throws -> TeacherResponse {
        calls.append(message)
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

    func stopRecording() {
        stopCount += 1
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

@MainActor
private final class EngineHarness {
    let bot = FakeBot()
    let teacher = FakeTeacher()
    let translate = FakeTranslate()
    let synth = FakeSynth()
    let speech: FakeSpeech
    let playback = FakePlayback()
    let store: RecordingStore
    let engine: ChatEngine

    init(
        persona: ChatPersona = .main(language: LanguageConfig.default, level: "B1"),
        store: RecordingStore? = nil,
        silenceWindow: TimeInterval = 0.05
    ) {
        let speech = FakeSpeech()
        let resolvedStore = store ?? RecordingStore()
        self.speech = speech
        self.store = resolvedStore
        let dependencies = ChatEngineDependencies(
            bot: bot,
            teacher: teacher,
            translate: translate,
            synth: synth,
            makeSpeech: { _ in speech },
            playback: playback
        )
        self.engine = ChatEngine(
            persona: persona,
            store: resolvedStore,
            dependencies: dependencies,
            silenceWindow: silenceWindow,
            sendSuppressionWindow: 0.05
        )
    }
}

@MainActor
final class ChatEngineTests: XCTestCase {
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
        XCTAssertEqual(harness.bot.calls.first?.roles, ["system", "user"])
        XCTAssertEqual(harness.teacher.calls, ["Hello"])
        XCTAssertFalse(harness.store.saved.isEmpty)
        XCTAssertEqual(harness.store.saved.last?.map(\.role) ?? [], roles)
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

    func testVoiceFlowSendsTranscriptAndStaysClosed() async {
        let harness = makeHarness()
        harness.engine.startRecording()
        await settle()
        XCTAssertEqual(harness.engine.voiceState, .recording)

        harness.speech.emit("Hallo wie geht's", isFinal: true)
        await settle(250)

        XCTAssertEqual(userMessages(harness).map(\.message), ["Hallo wie geht's"])
        XCTAssertTrue(harness.engine.messages.contains { $0.role == .assistant && $0.message == "Bot reply" })
        XCTAssertEqual(harness.engine.voiceState, .idle)
        XCTAssertEqual(harness.speech.startCount, 1)
        XCTAssertEqual(harness.playback.playCount, 1)
        XCTAssertEqual(harness.synth.calls.first?.text, "Bot reply")
        XCTAssertEqual(harness.synth.calls.first?.voiceId, "Vicki")
    }

    func testVoiceFlowStaysClosedWhenTTSFails() async {
        let harness = makeHarness()
        harness.synth.mode = .fail
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("hello", isFinal: true)
        await settle(250)

        XCTAssertEqual(harness.engine.voiceState, .idle)
        XCTAssertEqual(harness.speech.startCount, 1)
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

    func testBotFailureAfterVoiceSendStaysClosed() async {
        let harness = makeHarness()
        harness.bot.mode = .fail
        harness.teacher.mode = .suspend
        harness.engine.startRecording()
        await settle()
        harness.speech.emit("help me", isFinal: true)
        await settle(250)

        XCTAssertEqual(harness.engine.voiceState, .idle)
        XCTAssertEqual(harness.speech.startCount, 1)
        let last = harness.engine.messages.last
        XCTAssertEqual(last?.role, .assistant)
        XCTAssertEqual(last?.message, "Error: Fake error: bot-fail")
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

    func testReplayWhileRecordingStopsMicAndStaysClosed() async {
        let harness = makeHarness()
        harness.engine.startRecording()
        await settle()

        harness.engine.speak("hello")
        await settle(250)

        XCTAssertEqual(harness.engine.voiceState, .idle)
        XCTAssertEqual(harness.speech.startCount, 1)
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
}
