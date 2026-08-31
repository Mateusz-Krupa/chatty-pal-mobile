import Foundation
import Observation

struct ChatPersona: Equatable {
    let language: Language
    let level: String
    let systemInstruction: String
    var memory: String? = nil
    var examMode: ExamMode? = nil

    // System instruction plus the rolling learner summary, when available.
    var fullInstruction: String {
        guard let memory, !memory.isEmpty else { return systemInstruction }
        return systemInstruction + "\n\nABOUT YOUR FRIEND:\n\(memory)"
    }

    static func main(language: Language, level: String) -> ChatPersona {
        ChatPersona(
            language: language,
            level: level,
            systemInstruction: """
            As actor \(language.voice) a lively 25-year-old \(language.country) \(language.genderWord),
            engage in a friendly, natural chat with a friend who is learning your language. Always remain positive and funny.
            Keep \(level) CEFR level: short simple sentences, everyday vocabulary.
            Keep your replies SHORT: at most 2 short sentences — your friend is a language learner and must get enough speaking time.
            If you do not know the answer, say it simply and change the topic.
            Use natural conversation techniques: mirroring, light humour, follow-up questions. Let the learner talk more than you.
            Don't use emoticons or emoji.
            Embody \(language.voice) as if you're in a movie, respond only in \(language.language).
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

    static func examinerA1(scenario: String, lesson: String) -> ChatPersona {
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
            """,
            examMode: ExamMode(mode: "examiner", lessonId: lesson, stage: nil, briefing: scenario)
        )
    }

    static func examinerA1(lesson: String, stage: String, learnerContext: String? = nil) -> ChatPersona {
        let german = LanguageConfig.all["de"] ?? LanguageConfig.default
        return ChatPersona(
            language: german,
            level: "A1",
            systemInstruction: "You are the examiner for the Goethe-Zertifikat A1 oral exam. Stay in your examiner role.",
            examMode: ExamMode(
                mode: "speaking",
                lessonId: lesson,
                stage: stage,
                briefing: nil,
                learnerContext: learnerContext
            )
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
    private(set) var replySuggestions: [String] = []
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
    private var suggestionsTask: Task<Void, Never>?
    private var ttsTask: Task<Void, Never>?
    private var suppressSendUntil: Date?
    private var autoResumeListening = false
    private var resumeTask: Task<Void, Never>?

    private let silenceWindow: TimeInterval
    private let sendSuppressionWindow: TimeInterval
    private let voiceThreshold: Float
    private let resumeDelay: TimeInterval

    private var streamBuffer = ""
    private var splitter = UtteranceSplitter()
    private var ttsQueue: [String] = []
    private var isTTSPumping = false
    private var streamFinished = false

    private var voiceTurnActive = false
    private var mergeTargetID: UUID?
    private var inFlightAssistantID: UUID?
    var bargeInDetector = BargeInDetector()
    private let monitor: any VoiceMonitoring

    init(
        persona: ChatPersona,
        store: any ChatStore,
        dependencies: ChatEngineDependencies,
        silenceWindow: TimeInterval = 2.5,
        sendSuppressionWindow: TimeInterval = 0.6,
        voiceThreshold: Float = 0.02,
        resumeDelay: TimeInterval = 0.6
    ) {
        self.persona = persona
        self.store = store
        self.dependencies = dependencies
        self.playback = dependencies.playback
        self.monitor = dependencies.makeMonitor()
        self.silenceWindow = silenceWindow
        self.sendSuppressionWindow = sendSuppressionWindow
        self.voiceThreshold = voiceThreshold
        self.resumeDelay = resumeDelay
        self.messages = store.load()
        self.speech = dependencies.makeSpeech(persona.language.speechLocale)
        self.playback.onFinished = { [weak self] in
            Task { @MainActor in
                self?.playbackFinished()
            }
        }
        self.monitor.onLevel = { [weak self] rms in
            Task { @MainActor in
                self?.handleMonitorLevel(rms)
            }
        }
    }

    var isRecording: Bool { voiceState == .recording }
    var examStage: String? { persona.examMode?.stage }

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
        suggestionsTask?.cancel()
        suggestionsTask = nil
        replySuggestions = []
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
        streamBuffer = ""
        splitter = UtteranceSplitter()
        ttsQueue.removeAll()
        isTTSPumping = false
        streamFinished = false
        inFlightAssistantID = nil
        voiceTurnActive = false
        disarmBargeIn()
        voiceState = .idle
    }

    func clearMessages() {
        messages.removeAll()
        store.save(messages)
    }

    func startExam(with greeting: String) {
        guard messages.isEmpty, persona.examMode != nil else { return }
        append(ChatMessage(role: .assistant, message: greeting))
        streamFinished = true
        enqueueTTS(greeting)
    }

    func sendText(_ rawText: String, credit: Bool = true) {
        let text = TranscriptTracker.trimmed(rawText)
        guard !text.isEmpty, isActive else { return }
        mergeTargetID = nil
        replySuggestions = []
        if voiceState == .recording {
            autoResumeListening = true
            stopSpeechWithoutSend()
        }
        append(ChatMessage(role: .user, message: text))
        if credit {
            LearningStatsStore.shared.recordUserMessage()
            scheduleMemoryRefreshIfNeeded()
        }
        teacherTask?.cancel()
        teacherTask = nil
        requestBotResponse(for: text)
        let correctionContext = correctionContext()
        teacherTask = Task { [weak self] in
            await self?.fetchTeacherFix(for: text, context: correctionContext)
        }
    }

    func requestExamFeedback() {
        guard persona.examMode != nil, !isGenerating, isActive else { return }
        requestBotResponse(for: "Bitte geben Sie mir jetzt die strukturierte Prüfungszusammenfassung.", speak: false)
    }

    // Voice-only path (used by finishUtterance). Unlike sendText it may merge the
    // utterance into the user message that a barge-in left pending, and it arms barge-in.
    private func deliverUtterance(_ text: String) {
        guard !text.isEmpty, isActive else { return }
        voiceTurnActive = true
        replySuggestions = []
        let sent: String
        if let targetID = mergeTargetID,
           let idx = messages.lastIndex(where: { $0.id == targetID && $0.role == .user }) {
            let merged = "\(messages[idx].message) \(text)"
            messages[idx].message = merged
            store.save(messages)
            sent = merged
        } else {
            append(ChatMessage(role: .user, message: text))
            sent = text
        }
        mergeTargetID = nil
        LearningStatsStore.shared.recordUserMessage()
        scheduleMemoryRefreshIfNeeded()
        teacherTask?.cancel()
        teacherTask = nil
        requestBotResponse(for: sent)
        let correctionContext = correctionContext()
        teacherTask = Task { [weak self] in
            await self?.fetchTeacherFix(for: sent, context: correctionContext)
        }
    }

    private func handleMonitorLevel(_ rms: Float) {
        guard bargeInDetector.feed(rms) else { return }
        handleBargeIn()
    }

    private func handleBargeIn() {
        reconcileInterruptedTurn()
        interrupt()
        startRecording()
    }

    private func reconcileInterruptedTurn() {
        if let id = inFlightAssistantID,
           let idx = messages.lastIndex(where: { $0.id == id }) {
            messages.remove(at: idx)
            store.save(messages)
        }
        inFlightAssistantID = nil
        if let uid = messages.lastIndex(where: { $0.role == .user }) {
            mergeTargetID = messages[uid].id
        }
    }

    private func armBargeIn() {
        try? monitor.start()
        bargeInDetector.arm()
    }

    private func disarmBargeIn() {
        bargeInDetector.disarm()
        monitor.stop()
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
        replySuggestions = []
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
            isTTSPumping = false
            ttsQueue.removeAll()
            playback.stop()
            autoResumeListening = false
            resumeTask?.cancel()
            resumeTask = nil
            pumpTTS()
        }
    }

    func speak(_ text: String, voiceId: String? = nil) {
        if isGenerating {
            interrupt()
        }
        ttsTask?.cancel()
        ttsTask = nil
        isTTSPumping = false
        ttsQueue.removeAll()
        streamFinished = true
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
        let instruction = persona.fullInstruction
        let payload = buildBotMessages()
        do {
            let response = try await dependencies.bot.sendMessage(instruction: instruction, message: prompt, messages: payload, exam: nil)
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
        let useCloud = AppEnvironment.voiceTranscriptionMode == .cloud
        guard useCloud, let wav else {
            voiceState = .idle
            guard !localTranscript.isEmpty else { return }
            deliverUtterance(localTranscript)
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
            self.deliverUtterance(finalText)
        }
    }

    private func requestBotResponse(for userMessage: String, speak: Bool = true) {
        botTask?.cancel()
        botTask = nil
        isGenerating = true
        voiceState = .waitingForBot
        streamBuffer = ""
        splitter = UtteranceSplitter()
        ttsQueue.removeAll()
        streamFinished = false
        inFlightAssistantID = nil
        if voiceTurnActive {
            armBargeIn()
        }
        let instruction = persona.fullInstruction
        let payload = buildBotMessages()
        let exam = persona.examMode
        var hasBubble = false
        botTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await delta in self.dependencies.bot.streamMessage(
                    instruction: instruction,
                    message: userMessage,
                    messages: payload,
                    exam: exam
                ) {
                    guard !Task.isCancelled else { return }
                    self.streamBuffer += delta
                    if hasBubble {
                        self.updateLastAssistantMessage(self.streamBuffer)
                    } else {
                        let bubble = ChatMessage(role: .assistant, message: self.streamBuffer)
                        self.inFlightAssistantID = bubble.id
                        self.append(bubble)
                        hasBubble = true
                    }
                    if speak {
                        for utterance in self.splitter.feed(delta) {
                            self.enqueueTTS(utterance)
                        }
                    }
                }
                guard !Task.isCancelled else { return }
                if !hasBubble {
                    // Empty stream — fall back to the one-shot endpoint.
                    self.requestOneShotBotResponse(instruction: instruction, message: userMessage, messages: payload, speak: speak)
                    return
                }
                if speak, let tail = self.splitter.finish() {
                    self.enqueueTTS(tail)
                }
                self.store.save(self.messages)
                self.isGenerating = false
                self.streamFinished = true
                self.pumpTTS()
                self.scheduleReplySuggestions()
            } catch {
                guard !Task.isCancelled else { return }
                self.isGenerating = false
                if !hasBubble {
                    // Streaming failed before anything arrived (e.g. old server) — retry one-shot.
                    self.requestOneShotBotResponse(instruction: instruction, message: userMessage, messages: payload, speak: speak)
                } else {
                    let description = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    self.append(ChatMessage(role: .assistant, message: "Error: \(description)"))
                    self.store.save(self.messages)
                    self.streamFinished = true
                    self.finishPlaybackPhase()
                }
            }
        }
    }

    private func requestOneShotBotResponse(instruction: String, message: String, messages: [BotMessage], speak: Bool) {
        botTask?.cancel()
        botTask = nil
        botTask = Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await self.dependencies.bot.sendMessage(
                    instruction: instruction,
                    message: message,
                    messages: messages,
                    exam: persona.examMode
                )
                guard !Task.isCancelled else { return }
                self.isGenerating = false
                let bubble = ChatMessage(role: .assistant, message: response.message)
                self.inFlightAssistantID = bubble.id
                self.append(bubble)
                self.streamFinished = true
                if speak {
                    self.enqueueTTS(response.message)
                } else {
                    self.finishPlaybackPhase()
                }
                self.scheduleReplySuggestions()
            } catch {
                guard !Task.isCancelled else { return }
                self.isGenerating = false
                let description = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                self.append(ChatMessage(role: .assistant, message: "Error: \(description)"))
                self.finishPlaybackPhase()
            }
        }
    }

    private func updateLastAssistantMessage(_ text: String) {
        guard let index = messages.lastIndex(where: { $0.role == .assistant }) else { return }
        messages[index].message = text
    }

    private func enqueueTTS(_ text: String) {
        let trimmed = TranscriptTracker.trimmed(text)
        guard !trimmed.isEmpty else { return }
        ttsQueue.append(trimmed)
        pumpTTS()
    }

    private func pumpTTS() {
        if !isTTSEnabled {
            ttsQueue.removeAll()
            if streamFinished {
                finishPlaybackPhase()
            }
            return
        }
        guard !isTTSPumping, let next = ttsQueue.first else {
            if streamFinished, !isTTSPumping {
                finishPlaybackPhase()
            }
            return
        }
        ttsQueue.removeFirst()
        isTTSPumping = true
        voiceState = .playingTTS
        ttsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let data = try await self.dependencies.synth.synthesizeSpeech(text: next, voiceId: self.persona.language.voice)
                guard !Task.isCancelled else { return }
                self.isTTSPumping = false
                try self.playback.play(data)
            } catch {
                self.isTTSPumping = false
                self.pumpTTS()
            }
        }
    }

    private func playbackFinished() {
        if !ttsQueue.isEmpty {
            pumpTTS()
        } else if streamFinished {
            finishPlaybackPhase()
        }
    }

    // Every 15th learner message (with enough context) refreshes the rolling
    // "ABOUT YOUR FRIEND" summary injected into the persona.
    private func scheduleMemoryRefreshIfNeeded() {
        let stats = LearningStatsStore.shared
        guard stats.data.messagesSent % 15 == 0,
              messages.filter({ $0.role == .user }).count >= 8 else { return }
        let langCode = persona.language.code
        let context = messages
            .suffix(30)
            .filter { $0.role == .user || $0.role == .assistant }
            .map { "\($0.role == .user ? "learner" : "partner"): \($0.message)" }
            .joined(separator: "\n")
        Task { [weak self] in
            guard let self else { return }
            let system = """
            You are a note-taking assistant. Reply in English with at most 3 short bullet lines \
            about the learner: interests, names mentioned, level observations. Under 120 words. No other text.
            """
            guard let response = try? await dependencies.bot.sendMessage(
                instruction: "",
                message: "Conversation so far:\n\(context)",
                messages: [BotMessage(role: "system", content: system)],
                exam: nil
            ) else { return }
            BotMemoryStore.shared.save(response.message, for: langCode)
        }
    }

    // After a complete bot reply, fetch 3 tappable follow-up suggestions so
    // the learner is never stuck for words. Failures are silent.
    private func scheduleReplySuggestions() {
        guard messages.last?.role == .assistant else { return }
        let lang = persona.language
        let lvl = persona.level
        let context = messages
            .suffix(6)
            .filter { $0.role == .user || $0.role == .assistant }
            .map { "\($0.role == .user ? "learner" : "partner"): \($0.message)" }
            .joined(separator: "\n")
        suggestionsTask?.cancel()
        suggestionsTask = Task { [weak self] in
            guard let self else { return }
            let system = """
            You are a helpful writing assistant. Suggest 3 short natural follow-up messages the \
            learner could send next, in \(lang.language) at \(lvl) CEFR level. \
            Reply with ONLY a JSON array of 3 short strings. No other text.
            """
            guard let response = try? await dependencies.bot.sendMessage(
                instruction: "",
                message: "Conversation so far:\n\(context)\n\nSuggest 3 follow-up messages for the learner.",
                messages: [BotMessage(role: "system", content: system)],
                exam: nil
            ) else { return }
            let suggestions = Self.parseSuggestionArray(response.message)
            guard !Task.isCancelled, !suggestions.isEmpty else { return }
            self.replySuggestions = suggestions
        }
    }

    static func parseSuggestionArray(_ raw: String) -> [String] {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("```") {
            if let firstNewline = text.firstIndex(of: "\n") {
                text = String(text[text.index(after: firstNewline)...])
            }
            if text.hasSuffix("```") {
                text = String(text.dropLast(3))
            }
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard let start = text.firstIndex(of: "["), let end = text.lastIndex(of: "]") else { return [] }
        let arrayText = String(text[start...end])
        guard let data = arrayText.data(using: .utf8),
              let array = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return Array(
            array
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .prefix(3)
        )
    }

    private func fetchTeacherFix(for userMessage: String, context: [TeacherContextMessage]) async {
        // The teacher fix is an optional enrichment: failures (offline, local env
        // without a running server) must never surface as chat messages.
        let response: TeacherResponse?
        if let exam = persona.examMode {
            response = try? await dependencies.teacher.examReadyAnswer(message: userMessage, stage: exam.stage ?? "", context: context)
        } else {
            response = try? await dependencies.teacher.fixText(message: userMessage, language: persona.language.language, context: context)
        }
        guard let response else {
            return
        }
        guard !Task.isCancelled else { return }
        let corrected = response.message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !corrected.isEmpty else { return }
        if persona.examMode != nil {
            attachCorrection(corrected, to: userMessage)
        } else {
            let segments = TextDiffer.diff(original: userMessage, corrected: corrected)
            guard segments.contains(where: { $0.kind != .same }) else { return }
            append(ChatMessage(role: .teacher, message: corrected))
        }
    }

    private func correctionContext() -> [TeacherContextMessage] {
        messages
            .filter { $0.role == .user || $0.role == .assistant }
            .suffix(4)
            .map { TeacherContextMessage(role: $0.role == .user ? "user" : "assistant", content: String($0.message.prefix(500))) }
    }

    private func attachCorrection(_ corrected: String, to userMessage: String) {
        guard let index = messages.lastIndex(where: { $0.role == .user && $0.message == userMessage }) else { return }
        messages[index].correction = corrected
        store.save(messages)
    }

    private func finishPlaybackPhase() {
        guard voiceState == .playingTTS || voiceState == .waitingForBot else { return }
        disarmBargeIn()
        voiceTurnActive = false
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
        var payload = [BotMessage(role: "system", content: persona.fullInstruction)]
        // The current learner turn arrives separately as `message` and is
        // appended once by the server, so it is excluded from the history.
        // The full session history is sent; the server owns the length cap.
        var items = Array(messages)
        if let last = items.last, last.role == .user {
            items = items.dropLast()
        }
        for item in items {
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
