import AVFoundation
import SwiftUI

struct LearningMaterialsHomeView: View {
    let onStartPractice: (LearningLesson) -> Void

    private let studySteps = [
        "Pick a language and level",
        "Read the goals",
        "Review phrases and vocabulary",
        "Practice the same topic in Chatty Pal"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Learning Materials", systemImage: "book.closed.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                    Text("Study useful phrases, then turn them into conversation.")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    Text("Use each lesson as a short guided path: learn the pattern, review examples, then continue with a focused Chatty Pal practice chat.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    ChattyTheme.heroGradient,
                    in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(ChattyTheme.softHairline, lineWidth: 1)
                )

                InfoSectionCard(title: "Study Flow", systemImage: "map") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(studySteps.enumerated()), id: \.offset) { index, step in
                            InfoNumberedRow(number: index + 1, text: step)
                        }
                    }
                }

                InfoSectionCard(title: "Available Path", systemImage: "globe.europe.africa") {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "flag.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 32, height: 32)
                                .background(Color.accentColor.opacity(0.12), in: Circle())
                            VStack(alignment: .leading, spacing: 5) {
                                Text("German")
                                    .font(.headline)
                                Text("A1 and A2 starter lessons for practical speaking practice.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        NavigationLink(value: LearningMaterialsDestination.germanList) {
                            Text("View German Lessons")
                                .font(.body.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: LearningMaterialsDestination.self) { destination in
            switch destination {
            case .germanList:
                GermanLearningLessonListView(onStartPractice: onStartPractice)
            case .lesson(let lesson):
                LearningLessonDetailView(lesson: lesson, onStartPractice: onStartPractice)
            }
        }
    }
}

private struct GermanLearningLessonListView: View {
    let onStartPractice: (LearningLesson) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        LearningBadge(text: "German")
                        LearningBadge(text: "A1-A2")
                        LearningBadge(text: "\(MobileLearningCatalog.germanLessons.count) lessons")
                    }
                    Text("German lesson path")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("Choose a topic, study the core phrases, then practice it in the main chat.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                ForEach(MobileLearningCatalog.germanLessons) { lesson in
                    NavigationLink(value: LearningMaterialsDestination.lesson(lesson)) {
                        LearningLessonCard(lesson: lesson)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("German Lessons")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LearningLessonCard: View {
    let lesson: LearningLesson

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        LearningBadge(text: lesson.level)
                        LearningBadge(text: lesson.topic)
                    }
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                }
                Spacer(minLength: 12)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }

            HStack(spacing: 8) {
                Image(systemName: "text.bubble")
                    .font(.caption)
                Text("Phrases, vocabulary, dialogue, and practice CTA")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(ChattyTheme.softHairline, lineWidth: 1)
        )
    }
}

private struct LearningLessonDetailView: View {
    let lesson: LearningLesson
    let onStartPractice: (LearningLesson) -> Void

    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioDelegate = AudioPlaybackDelegate()
    @State private var playingText: String?
    @State private var audioError: String?

    private let pollyService = PollySpeechService()

    private var lessonVoice: String {
        LanguageConfig.all[lesson.languageCode]?.voice ?? LanguageConfig.default.voice
    }

    private var lessonSpeechLocale: String {
        LanguageConfig.all[lesson.languageCode]?.speechLocale ?? "de-DE"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                lessonHero

                if let audioError {
                    Text(audioError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                InfoSectionCard(title: "Learning Goals", systemImage: "target") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(lesson.goals.enumerated()), id: \.offset) { index, goal in
                            InfoNumberedRow(number: index + 1, text: goal)
                        }
                    }
                }

                InfoSectionCard(title: "Before You Start", systemImage: "sparkles") {
                    Text(lesson.intro)
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "Phrase Practice", systemImage: "quote.bubble") {
                    VStack(spacing: 10) {
                        ForEach(lesson.phrases, id: \.self) { phrase in
                            LearningPhraseRow(
                                phrase: phrase,
                                isPlaying: playingText == phrase.mainContent,
                                onPlay: { playLessonText(phrase.mainContent) }
                            )
                        }
                    }
                }

                InfoSectionCard(title: "Shadowing: Listen & Repeat", systemImage: "waveform") {
                    VStack(spacing: 10) {
                        ForEach(lesson.phrases, id: \.self) { phrase in
                            ShadowingPhraseRow(
                                phrase: phrase,
                                localeIdentifier: lessonSpeechLocale,
                                onPlay: { playLessonText(phrase.mainContent) }
                            )
                        }
                    }
                }

                InfoSectionCard(title: "Vocabulary Review", systemImage: "rectangle.stack") {
                    LazyVStack(spacing: 10) {
                        ForEach(lesson.vocabulary) { item in
                            LearningVocabularyRow(
                                item: item,
                                isPlaying: playingText == item.mainContent,
                                onPlay: { playLessonText(item.mainContent) }
                            )
                        }
                    }
                }

                InfoSectionCard(title: "Conversation Example", systemImage: "person.2.wave.2") {
                    VStack(spacing: 10) {
                        ForEach(Array(lesson.conversation.enumerated()), id: \.element.id) { index, line in
                            LearningConversationBubble(
                                line: line,
                                isAlternate: index % 2 == 1,
                                isPlaying: playingText == line.mainContent,
                                onPlay: { playLessonText(line.mainContent) }
                            )
                        }
                    }
                }

                InfoSectionCard(title: "Practice with Chatty Pal", systemImage: "bubble.left.and.bubble.right.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Direct lesson prompt injection is not configured yet. Start practice to switch Chatty Pal to \(lesson.languageName) \(lesson.level), then use this prompt as your guide.")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundStyle(.secondary)

                        Text(lesson.practicePrompt)
                            .font(.callout)
                            .lineSpacing(3)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.accentColor.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                        Button {
                            onStartPractice(lesson)
                        } label: {
                            Text("Practice in Chatty Pal")
                                .font(.body.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(lesson.level)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            WordReviewStore.shared.addLesson(lesson)
        }
        .onDisappear {
            audioPlayer?.stop()
            playingText = nil
        }
    }

    private var lessonHero: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                LearningBadge(text: lesson.languageName)
                LearningBadge(text: lesson.level)
                LearningBadge(text: lesson.topic)
            }
            Text(lesson.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .lineSpacing(2)
            Text(lesson.description)
                .font(.body)
                .lineSpacing(4)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ChattyTheme.heroGradient,
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(ChattyTheme.softHairline, lineWidth: 1)
        )
    }

    private func playLessonText(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        audioPlayer?.stop()
        audioError = nil
        playingText = trimmed
        Task {
            do {
                let audioData = try await pollyService.synthesizeSpeech(text: trimmed, voiceId: lessonVoice)
                await MainActor.run {
                    do {
                        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                        audioPlayer = try AVAudioPlayer(data: audioData)
                        audioDelegate.onFinish = {
                            playingText = nil
                        }
                        audioPlayer?.delegate = audioDelegate
                        audioPlayer?.prepareToPlay()
                        audioPlayer?.play()
                    } catch {
                        playingText = nil
                        audioError = "Could not play this lesson audio."
                    }
                }
            } catch {
                await MainActor.run {
                    playingText = nil
                    audioError = "Could not load lesson audio. Make sure the speech service is available."
                }
            }
        }
    }
}

private struct ShadowingPhraseRow: View {
    let phrase: LearningPhrase
    let localeIdentifier: String
    let onPlay: () -> Void

    @State private var isRecording = false
    @State private var result: ShadowingScorer.Result?
    @State private var addedToReview = false
    @State private var speech: SpeechController?
    @State private var lastSpoken = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Button(action: onPlay) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.accentColor)
                }
                Text(phrase.mainContent)
                    .font(.body.weight(.medium))
                Spacer()
                Button {
                    toggleRecording()
                } label: {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(isRecording ? Color.red : Color.accentColor)
                }
            }
            if let support = phrase.supportContent, !support.isEmpty {
                Text(support)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if isRecording {
                Text("Listening... say it now")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            if let result {
                HStack(spacing: 6) {
                    ForEach(Array(result.words.enumerated()), id: \.offset) { _, match in
                        Text(match.word)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(match.matched ? Color.green : Color.red)
                    }
                    Spacer()
                    Text("\(result.percent)%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(scoreColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(scoreColor.opacity(0.15), in: Capsule())
                }
            }
            if addedToReview {
                Label("Added to Word Review", systemImage: "plus.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var scoreColor: Color {
        guard let result else { return .secondary }
        switch result.percent {
        case 80...:
            return .green
        case 60..<80:
            return .orange
        default:
            return .red
        }
    }

    private func toggleRecording() {
        if isRecording {
            speech?.stopRecording()
            isRecording = false
            finishRecording()
            return
        }
        let controller = speech ?? SpeechController(localeIdentifier: localeIdentifier)
        speech = controller
        Task {
            guard await controller.requestPermissions() else { return }
            controller.onTranscription = { text, _ in
                Task { @MainActor in
                    lastSpoken = text
                }
            }
            controller.onError = { _ in
                Task { @MainActor in
                    isRecording = false
                }
            }
            do {
                try controller.startRecording()
                lastSpoken = ""
                isRecording = true
            } catch {
                // Mic unavailable - stay idle.
            }
        }
    }

    private func finishRecording() {
        let spoken = lastSpoken
        lastSpoken = ""
        guard !spoken.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        let scored = ShadowingScorer.score(reference: phrase.mainContent, spoken: spoken)
        result = scored
        if scored.percent < 60, let english = phrase.supportContent, !english.isEmpty {
            WordReviewStore.shared.add(german: phrase.mainContent, english: english, source: "shadowing")
            addedToReview = true
        }
    }
}

private struct LearningPhraseRow: View {
    let phrase: LearningPhrase
    let isPlaying: Bool
    let onPlay: () -> Void

    var body: some View {
        Button(action: onPlay) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(phrase.mainContent)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                    if let support = phrase.supportContent, !support.isEmpty {
                        Text(support)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 12)
                LessonAudioIndicator(isPlaying: isPlaying)
            }
        }
        .buttonStyle(.plain)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ChattyTheme.rowFill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ChattyTheme.softHairline, lineWidth: 1)
        )
    }
}

private struct LearningVocabularyRow: View {
    let item: LearningVocabularyItem
    let isPlaying: Bool
    let onPlay: () -> Void

    var body: some View {
        Button(action: onPlay) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.mainContent)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                    if let support = item.supportContent, !support.isEmpty {
                        Text(support)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    if let usage = item.usage, !usage.isEmpty {
                        Text(usage)
                            .font(.caption)
                            .lineSpacing(2)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 12)
                LessonAudioIndicator(isPlaying: isPlaying)
            }
        }
        .buttonStyle(.plain)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ChattyTheme.rowFill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ChattyTheme.softHairline, lineWidth: 1)
        )
    }
}

private struct LearningConversationBubble: View {
    let line: LearningConversationLine
    let isAlternate: Bool
    let isPlaying: Bool
    let onPlay: () -> Void

    var body: some View {
        HStack {
            if isAlternate { Spacer(minLength: 32) }
            Button(action: onPlay) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 5) {
                        if let speaker = line.speaker, !speaker.isEmpty {
                            Text(speaker)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accentColor)
                        }
                        Text(line.mainContent)
                            .font(.body)
                            .foregroundStyle(.primary)
                        if let support = line.supportContent, !support.isEmpty {
                            Text(support)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer(minLength: 12)
                    LessonAudioIndicator(isPlaying: isPlaying)
                }
            }
            .buttonStyle(.plain)
            .padding(14)
            .background(
                isAlternate ? Color.accentColor.opacity(0.16) : ChattyTheme.rowFill,
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(ChattyTheme.softHairline, lineWidth: 1)
            )
            if !isAlternate { Spacer(minLength: 32) }
        }
    }
}

private struct LessonAudioIndicator: View {
    let isPlaying: Bool

    var body: some View {
        Group {
            if isPlaying {
                ProgressView()
                    .controlSize(.small)
            } else {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
        }
        .frame(width: 32, height: 32)
        .background(Color.accentColor.opacity(0.10), in: Circle())
        .accessibilityLabel(isPlaying ? "Loading audio" : "Play pronunciation")
    }
}

private struct LearningBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.accentColor.opacity(0.12), in: Capsule())
            .foregroundStyle(Color.accentColor)
    }
}

// MARK: - Student Homework


enum LearningMaterialsDestination: Hashable {
    case germanList
    case lesson(LearningLesson)
}
