import AVFoundation
import Foundation

protocol BotServicing {
    func sendMessage(instruction: String, message: String, messages: [BotMessage], exam: ExamMode?) async throws -> BotResponse
    func streamMessage(instruction: String, message: String, messages: [BotMessage], exam: ExamMode?) -> AsyncThrowingStream<String, Error>
}

extension BotService: BotServicing {}

protocol TeacherServicing {
    func fixText(message: String, language: String) async throws -> TeacherResponse
    func fixText(message: String, language: String, context: [TeacherContextMessage]) async throws -> TeacherResponse
}

extension TeacherServicing {
    func fixText(message: String, language: String, context: [TeacherContextMessage]) async throws -> TeacherResponse {
        try await fixText(message: message, language: language)
    }
}

extension TeacherService: TeacherServicing {}

protocol TranslationServicing {
    func translate(message: String) async throws -> TranslationResponse
}

extension TranslationService: TranslationServicing {}

protocol SpeechSynthesizing {
    func synthesizeSpeech(text: String, voiceId: String?) async throws -> Data
}

extension PollySpeechService: SpeechSynthesizing {}

// Main-thread only. Callbacks may be delivered on arbitrary threads.
protocol SpeechRecognition: AnyObject {
    var onTranscription: ((String, Bool) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    var onAudioLevel: ((Float) -> Void)? { get set }
    func requestPermissions() async -> Bool
    func startRecording() throws
    func stopRecording() -> Data?
}

protocol AudioTranscribing {
    func transcribe(wav: Data, language: String) async throws -> String
}

extension SpeechController {
    func requestPermissions() async -> Bool {
        await withCheckedContinuation { continuation in
            requestPermissions { continuation.resume(returning: $0) }
        }
    }
}

extension SpeechController: SpeechRecognition {}

// Main-thread only. onFinished fires exactly once per play(), on natural end or failure.
// stop() never fires onFinished.
protocol AudioPlayback: AnyObject {
    var onFinished: (() -> Void)? { get set }
    func play(_ data: Data) throws
    func stop()
}

final class AVAudioPlayback: NSObject, AudioPlayback, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    private var finished = true
    var onFinished: (() -> Void)?

    func play(_ data: Data) throws {
        let current = player
        player = nil
        current?.stop()
        current?.delegate = nil

        let session = AVAudioSession.sharedInstance()
        // Preserve the play-and-record (AEC) session set up by the barge-in monitor.
        if session.category != .playAndRecord {
            try? session.setCategory(.playback, mode: .default, options: [])
        }
        try? session.setActive(true, options: .notifyOthersOnDeactivation)

        let newPlayer = try AVAudioPlayer(data: data)
        finished = false
        newPlayer.delegate = self
        newPlayer.prepareToPlay()
        player = newPlayer
        guard newPlayer.play() else {
            finish()
            return
        }
    }

    func stop() {
        let current = player
        player = nil
        finished = true
        current?.stop()
        current?.delegate = nil
    }

    private func finish() {
        guard !finished else { return }
        finished = true
        let current = player
        player = nil
        current?.delegate = nil
        onFinished?()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard !finished, player === self.player else { return }
        finish()
    }
}

struct ChatEngineDependencies {
    let bot: any BotServicing
    let teacher: any TeacherServicing
    let translate: any TranslationServicing
    let synth: any SpeechSynthesizing
    let makeSpeech: (String) -> any SpeechRecognition
    let playback: any AudioPlayback
    let transcriber: any AudioTranscribing
    let makeMonitor: () -> any VoiceMonitoring

    static var live: ChatEngineDependencies {
        ChatEngineDependencies(
            bot: BotService(),
            teacher: TeacherService(),
            translate: TranslationService(),
            synth: PollySpeechService(),
            makeSpeech: { locale in SpeechController(localeIdentifier: locale) },
            playback: AVAudioPlayback(),
            transcriber: WhisperTranscriber(baseURL: AppEnvironment.webBaseURL),
            makeMonitor: { VoiceMonitor() }
        )
    }
}
