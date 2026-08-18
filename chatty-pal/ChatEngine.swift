import Foundation
import Observation

struct ChatPersona: Equatable {
    let language: Language
    let level: String
    let systemInstruction: String

    static func main(language: Language, level: String) -> ChatPersona {
        ChatPersona(
            language: language,
            level: level,
            systemInstruction: """
            As actor \(language.voice) a lively 25-year-old \(language.country) \(language.genderWord),
            engage in supportive chat with a friend. Always remain positive and funny. Respond as \(language.voice) would, you are expert in active listening.
            Unsure how to answer? Invent a response; it'll help us shape the script later.
            It is very important - to keep the level at \(level) level as the readers are learning the language.
            Use some humor in your conversations and try to be as natural as possible.

            NEXT use techniques like:
            Mirroring, Using humour, Ask Follow-Up Questions, Avoid Monopolizing the Conversation, Balance Sharing and Receiving, but the most important.
            Don't use emoticons.

            Embody \(language.voice) as if you're in a movie, respond only in \(language.language) with \(level) CEFR level.
            """
        )
    }

    static func examinerA1(scenario: String) -> ChatPersona {
        let german = LanguageConfig.all["de"] ?? LanguageConfig.default
        return ChatPersona(
            language: german,
            level: "A1",
            systemInstruction: """
            You are the examiner for the Goethe-Zertifikat A1 oral exam. You are calm, friendly and patient, and you always stay in your examiner role.
            Conduct the practice exactly as the scenario below describes.
            Always speak only simple German at A1 level: short sentences, basic vocabulary.
            After each part, give one or two sentences of short, encouraging feedback on the candidate's German, then continue.
            If the candidate answers in English, gently ask them to try again in German.

            YOUR ROLE IS =>
            \(scenario)
            """
        )
    }

    static func homework(language: Language, level: String, prompt: String) -> ChatPersona {
        ChatPersona(
            language: language,
            level: level,
            systemInstruction: """
            As actor \(language.voice) a lively 25-year-old \(language.country) \(language.genderWord),
            engage in supportive chat with user. Always remain positive. Respond as \(language.voice) would, apply active listening in conversation.
            Unsure how to answer? Invent a response.
            It is very important - to keep the level at \(level) level as the readers are learning the language.
            Embody \(language.voice) as if you're in a movie, respond only in \(language.language) and \(level) language level.
            You will be provided with context how you need to behave in this role.

            YOUR ROLE IS =>
            \(prompt)
            """
        )
    }
}

enum ChatVoiceState: Equatable {
    case idle
    case recording
    case waitingForBot
    case playingTTS
}

@MainActor
@Observable
final class ChatEngine {
    private(set) var messages: [ChatMessage] = []
    private(set) var voiceState: ChatVoiceState = .idle
    private(set) var isGenerating = false
    private(set) var transcriptText = ""
    private(set) var audioLevel: Float = 0
    private(set) var isTranscribing = false
    var isTTSEnabled = true
    var isActive = true

    private var persona: ChatPersona
    private var store: any ChatStore
    private let dependencies: ChatEngineDependencies
    private let playback: any AudioPlayback
    private var speech: (any SpeechRecognition)?
    private var silenceTask: Task<Void, Never>?
    private var botTask: Task<Void, Never>?
    private var teacherTask: Task<Void, Never>?
    private var ttsTask: Task<Void, Never>?
    private var suppressSendUntil: Date?
    private var autoResumeListening = false
    private var resumeTask: Task<Void, Never>?

    private let silenceWindow: TimeInterval
    private let sendSuppressionWindow: TimeInterval
    private let voiceThreshold: Float
    private let resumeDelay: TimeInterval

    init(
        persona: ChatPersona,
        store: any ChatStore,
        dependencies: ChatEngineDependencies,
        silenceWindow: TimeInterval = 1.8,
        sendSuppressionWindow: TimeInterval = 0.6,
        voiceThreshold: Float = 0.02,
        resumeDelay: TimeInterval = 0.6
    ) {
        self.persona = persona
        self.store = store
        self.dependencies = dependencies
        self.playback = dependencies.playback
        self.silenceWindow = silenceWindow
        self.sendSuppressionWindow = sendSuppressionWindow
        self.voiceThreshold = voiceThreshold
        self.resumeDelay = resumeDelay
        self.messages = store.load()
        self.speech = dependencies.makeSpeech(persona.language.speechLocale)
        self.playback.onFinished = { [weak self] in
            Task { @MainActor in
                self?.finishPlaybackPhase()
            }
        }
    }

    var isRecording: Bool { voiceState == .recording }

    func reload(persona: ChatPersona, store: any ChatStore) {
        interrupt()
        self.persona = persona
        self.store = store
        self.speech = dependencies.makeSpeech(persona.language.speechLocale)
        self.messages = store.load()
    }

    func interrupt() {
        botTask?.cancel()
        botTask = nil
        teacherTask?.cancel()
        teacherTask = nil
        ttsTask?.cancel()
        ttsTask = nil
        silenceTask?.cancel()
        silenceTask = nil
        resumeTask?.cancel()
        resumeTask = nil
        speech?.stopRecording()
        playback.stop()
        suppressSendUntil = nil
        autoResumeListening = false
        transcriptText = ""
        audioLevel = 0
        isGenerating = false
        isTranscribing = false
        voiceState = .idle
    }

    func clearMessages() {
        messages.removeAll()
        store.save(messages)
    }

    func sendText(_ rawText: String) {
        let text = TranscriptTracker.trimmed(rawText)
        guard !text.isEmpty, isActive else { return }
        if voiceState == .recording {
            autoResumeListening = true
            stopSpeechWithoutSend()
        }
        append(ChatMessage(role: .user, message: text))
        requestBotResponse(for: text)
        teacherTask?.cancel()
        teacherTask = Task { [weak self] in
            await self?.fetchTeacherFix(for: text)
        }
    }

    func toggleRecording() {
        if voiceState == .recording {
            stopSpeechAndSend()
        } else {
            startRecording()
        }
    }

    func startRecording() {
        guard voiceState == .idle, isActive else { return }
        guard let speech else { return }
        Task { [weak self] in
            guard let self else { return }
            guard await speech.requestPermissions() else { return }
            guard self.voiceState == .idle else { return }
            self.beginRecording()
        }
    }

    func stopSpeechAndSend() {
        cancelSilenceTimer()
        let wav = speech?.stopRecording()
        suppressSendUntil = Date().addingTimeInterval(sendSuppressionWindow)
        finishUtterance(wav: wav, resume: false, force: true)
    }

    func toggleTTS() {
        isTTSEnabled.toggle()
        if !isTTSEnabled {
            ttsTask?.cancel()
            ttsTask = nil
            playback.stop()
            autoResumeListening = false
            resumeTask?.cancel()
            resumeTask = nil
            if voiceState == .playingTTS {
                voiceState = .idle
            }
        }
    }

    func speak(_ text: String, voiceId: String? = nil) {
        ttsTask?.cancel()
        ttsTask = nil
        guard isTTSEnabled, !text.isEmpty else {
            finishPlaybackPhase()
            return
        }
        if voiceState == .recording {
            autoResumeListening = true
            stopSpeechWithoutSend()
        }
        voiceState = .playingTTS
        let resolvedVoice = voiceId ?? persona.language.voice
        ttsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let audioData = try await self.dependencies.synth.synthesizeSpeech(text: text, voiceId: resolvedVoice)
                guard !Task.isCancelled else { return }
                try self.playback.play(audioData)
            } catch {
                guard !Task.isCancelled else { return }
                self.finishPlaybackPhase()
            }
        }
    }

    func translate(_ text: String) async {
        do {
            let response = try await dependencies.translate.translate(message: text)
            append(ChatMessage(role: .translation, message: response.message))
        } catch {
            let description = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            append(ChatMessage(role: .translation, message: "Translation error: \(description)"))
        }
    }

    func suggest(for botMessage: String) async {
        let prompt = """
        The conversation partner just said: "\(botMessage)"
        Suggest one short natural way to reply in \(persona.language.language) at \(persona.level) CEFR level.
        Only the reply, nothing else.
        """
        let instruction = persona.systemInstruction
        let payload = buildBotMessages()
        do {
            let response = try await dependencies.bot.sendMessage(instruction: instruction, message: prompt, messages: payload)
            append(ChatMessage(role: .suggestion, message: response.message))
        } catch {
            let description = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            append(ChatMessage(role: .suggestion, message: "Could not get suggestions: \(description)"))
        }
    }

    private func beginRecording() {
        guard let speech else { return }
        playback.stop()
        resumeTask?.cancel()
        resumeTask = nil
        transcriptText = ""
        cancelSilenceTimer()
        speech.onTranscription = { [weak self] text, isFinal in
            Task { @MainActor in
                self?.handleTranscription(text: text, isFinal: isFinal)
            }
        }
        speech.onError = { [weak self] _ in
            Task { @MainActor in
                self?.handleSpeechError()
            }
        }
        speech.onAudioLevel = { [weak self] rms in
            Task { @MainActor in
                self?.handleAudioLevel(rms)
            }
        }
        do {
            try speech.startRecording()
            voiceState = .recording
        } catch {
            // Mic unavailable - stay idle.
        }
    }

    private func handleTranscription(text: String, isFinal: Bool) {
        guard voiceState == .recording else { return }
        transcriptText = text
        scheduleSilenceTimer()
    }

    private func handleAudioLevel(_ rms: Float) {
        guard voiceState == .recording else { return }
        if rms > voiceThreshold {
            scheduleSilenceTimer()
            audioLevel = min(1, rms / (voiceThreshold * 4))
        } else {
            audioLevel = 0
        }
    }

    private func handleSpeechError() {
        guard voiceState == .recording else { return }
        stopSpeechAndSend()
    }

    private func stopSpeechWithoutSend() {
        cancelSilenceTimer()
        speech?.stopRecording()
        voiceState = .idle
        transcriptText = ""
        audioLevel = 0
    }

    private func cancelSilenceTimer() {
        silenceTask?.cancel()
        silenceTask = nil
    }

    private func scheduleSilenceTimer() {
        cancelSilenceTimer()
        let window = silenceWindow
        silenceTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(window))
            guard let self, !Task.isCancelled, self.voiceState == .recording else { return }
            self.sendTranscript()
        }
    }

    private func sendTranscript(force: Bool = false) {
        guard voiceState == .recording else { return }
        let wav = speech?.stopRecording()
        finishUtterance(wav: wav, resume: true, force: force)
    }

    private func finishUtterance(wav: Data?, resume: Bool, force: Bool) {
        if !force, let suppressSendUntil, Date() < suppressSendUntil { return }
        let localTranscript = TranscriptTracker.trimmed(transcriptText)
        let language = persona.language.code
        transcriptText = ""
        audioLevel = 0
        if resume {
            autoResumeListening = true
        }
        guard let wav else {
            voiceState = .idle
            guard !localTranscript.isEmpty else { return }
            sendText(localTranscript)
            return
        }
        voiceState = .waitingForBot
        isTranscribing = true
        Task { [weak self] in
            guard let self else { return }
            var whisper = ""
            do {
                whisper = try await self.dependencies.transcriber.transcribe(wav: wav, language: language)
            } catch {
                // Fall back to the local transcript.
            }
            self.isTranscribing = false
            guard !Task.isCancelled else { return }
            let text = TranscriptTracker.trimmed(whisper)
            let finalText = text.isEmpty ? localTranscript : text
            guard !finalText.isEmpty else {
                self.voiceState = .idle
                return
            }
            self.sendText(finalText)
        }
    }

    private func requestBotResponse(for userMessage: String) {
        botTask?.cancel()
        botTask = nil
        isGenerating = true
        voiceState = .waitingForBot
        let instruction = persona.systemInstruction
        let payload = buildBotMessages()
        botTask = Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await self.dependencies.bot.sendMessage(
                    instruction: instruction,
                    message: userMessage,
                    messages: payload
                )
                guard !Task.isCancelled else { return }
                self.isGenerating = false
                self.append(ChatMessage(role: .assistant, message: response.message))
                self.speak(response.message)
            } catch {
                guard !Task.isCancelled else { return }
                self.isGenerating = false
                let description = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                self.append(ChatMessage(role: .assistant, message: "Error: \(description)"))
                self.finishPlaybackPhase()
            }
        }
    }

    private func fetchTeacherFix(for userMessage: String) async {
        // The teacher fix is an optional enrichment: failures (offline, local env
        // without a running server) must never surface as chat messages.
        guard let response = try? await dependencies.teacher.fixText(message: userMessage, language: persona.language.language) else {
            return
        }
        guard !Task.isCancelled else { return }
        append(ChatMessage(role: .teacher, message: response.message))
    }

    private func finishPlaybackPhase() {
        guard voiceState == .playingTTS || voiceState == .waitingForBot else { return }
        voiceState = .idle
        if autoResumeListening {
            autoResumeListening = false
            scheduleResumeListening()
        }
    }

    private func scheduleResumeListening() {
        resumeTask?.cancel()
        resumeTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(resumeDelay))
            guard let self, !Task.isCancelled, self.voiceState == .idle else { return }
            self.startRecording()
        }
    }

    private func append(_ message: ChatMessage) {
        messages.append(message)
        store.save(messages)
    }

    private func buildBotMessages() -> [BotMessage] {
        var payload = [BotMessage(role: "system", content: persona.systemInstruction)]
        for item in messages.suffix(6) {
            if item.role == .teacher || item.role == .translation || item.role == .suggestion {
                continue
            }
            let role: String
            switch item.role {
            case .system:
                role = "system"
            case .user:
                role = "user"
            default:
                role = "assistant"
            }
            payload.append(BotMessage(role: role, content: item.message))
        }
        return payload
    }
}
