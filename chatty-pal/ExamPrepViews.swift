import AVFoundation
import SwiftUI

// MARK: - TTS helper for exam content

enum ExamTTS {
    private static var player: AVAudioPlayer?

    static func speak(_ text: String, voiceId: String? = nil) {
        guard !text.isEmpty else { return }
        Task {
            do {
                let data = try await PollySpeechService().synthesizeSpeech(text: text, voiceId: voiceId)
                await MainActor.run {
                    do {
                        player?.stop()
                        player = try AVAudioPlayer(data: data)
                        player?.prepareToPlay()
                        player?.play()
                    } catch {}
                }
            } catch {}
        }
    }

    static func stop() {
        player?.stop()
        player = nil
    }
}

// MARK: - Home

struct ExamPrepHomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Goethe-Zertifikat A1")
                            .font(.system(size: 28, weight: .semibold))
                        Text("Practice the four exam parts with lessons, listening and speaking drills.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(ExamSection.allCases) { section in
                        NavigationLink(value: section) {
                            sectionCard(section)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .background(ChattyTheme.appBackground.ignoresSafeArea())
            .navigationTitle("Exam Prep A1")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ExamSection.self) { section in
                ExamSectionView(section: section)
            }
            .navigationDestination(for: ExamUnit.self) { unit in
                ExamUnitDetailView(unit: unit)
            }
            .navigationDestination(for: ExamSpeakingTask.self) { task in
                ExamSpeakingView(task: task)
            }
        }
    }

    private func sectionCard(_ section: ExamSection) -> some View {
        HStack(spacing: 14) {
            Image(systemName: section.systemImage)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(section.rawValue)
                    .font(.headline)
                Text(section.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(ExamA1Catalog.units(in: section).count)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(ChattyTheme.softHairline, lineWidth: 1)
        )
    }
}

// MARK: - Section list

struct ExamSectionView: View {
    let section: ExamSection

    var body: some View {
        List {
            ForEach(ExamA1Catalog.units(in: section)) { unit in
                NavigationLink(value: unit) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(unit.title)
                            .font(.subheadline.weight(.semibold))
                        Text(unit.subtitle)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(section.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Unit detail

struct ExamUnitDetailView: View {
    let unit: ExamUnit
    @State private var selected: [String: Int] = [:]
    @State private var checked: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let text = unit.text, !text.isEmpty {
                    Text(text)
                        .font(.body)
                        .lineSpacing(4)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                if !unit.vocabulary.isEmpty {
                    card(title: "Vokabeln") {
                        VStack(spacing: 10) {
                            ForEach(unit.vocabulary) { item in
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(item.german)
                                            .font(.subheadline.weight(.semibold))
                                        Spacer()
                                        Text(item.english)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(item.example)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                    Text(item.exampleEnglish)
                                        .font(.footnote)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                    }
                }

                if !unit.phrases.isEmpty {
                    card(title: "Phrasen") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(unit.phrases) { phrase in
                                HStack(alignment: .top, spacing: 8) {
                                    Button {
                                        ExamTTS.speak(phrase.german)
                                    } label: {
                                        Image(systemName: "speaker.wave.2.fill")
                                            .font(.footnote)
                                            .foregroundStyle(Color.accentColor)
                                    }
                                    .buttonStyle(.plain)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(phrase.german)
                                            .font(.subheadline.weight(.medium))
                                        Text(phrase.english)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }

                if !unit.dialogue.isEmpty {
                    card(title: "Dialog") {
                        VStack(spacing: 10) {
                            ForEach(unit.dialogue) { line in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(line.speaker)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.accentColor)
                                    Text(line.german)
                                        .font(.subheadline)
                                    Text(line.english)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }

                if !unit.exercises.isEmpty {
                    card(title: "Übungen") {
                        VStack(spacing: 14) {
                            ForEach(Array(unit.exercises.enumerated()), id: \.element.id) { index, exercise in
                                ExerciseCard(
                                    exercise: exercise,
                                    number: index + 1,
                                    selection: selected[exercise.id],
                                    isChecked: checked.contains(exercise.id),
                                    onSelect: { optionIndex in
                                        selected[exercise.id] = optionIndex
                                    }
                                )
                            }

                            Button {
                                for exercise in unit.exercises {
                                    if selected[exercise.id] != nil {
                                        checked.insert(exercise.id)
                                    }
                                }
                            } label: {
                                Text("Check answers")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(unit.exercises.allSatisfy { checked.contains($0.id) })
                        }
                    }
                }

                if let scenario = unit.speakingScenario {
                    NavigationLink(value: ExamSpeakingTask(unit: unit, scenario: scenario)) {
                        HStack(spacing: 12) {
                            Image(systemName: "waveform")
                                .font(.title3)
                                .foregroundStyle(Color.accentColor)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Practice speaking")
                                    .font(.subheadline.weight(.semibold))
                                Text("Your partner conducts the exam part in German.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color.accentColor.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                if let prompt = unit.writingPrompt {
                    card(title: "Schreiben") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(prompt)
                                .font(.subheadline)
                            Text("Write your text in the chat, then ask your partner to correct it.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(ChattyTheme.appBackground.ignoresSafeArea())
        .navigationTitle(unit.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func card<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Exercise

private struct ExerciseCard: View {
    let exercise: ExamExercise
    let number: Int
    let selection: Int?
    let isChecked: Bool
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("\(number).")
                    .font(.subheadline.weight(.semibold))
                Text(exercise.kind.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.10), in: Capsule())
            }

            if exercise.hasAudio {
                Button {
                    ExamTTS.speak(exercise.spokenText ?? "")
                } label: {
                    Label("Play audio", systemImage: "speaker.wave.2.fill")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.plain)
            }

            Text(exercise.question)
                .font(.subheadline)

            VStack(spacing: 6) {
                ForEach(Array(exercise.options.enumerated()), id: \.offset) { index, option in
                    optionRow(index: index, option: option)
                }
            }

            if isChecked {
                let isCorrect = selection == exercise.correctIndex
                Text(isCorrect ? "Richtig! \(exercise.explanation)" : "Leider falsch. \(exercise.explanation)")
                    .font(.footnote)
                    .foregroundStyle(isCorrect ? Color.green : Color.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.accentColor.opacity(0.04), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func optionRow(index: Int, option: String) -> some View {
        let isSelected = selection == index
        let isCorrect = isChecked && index == exercise.correctIndex
        let isWrongPick = isChecked && isSelected && !isCorrect

        return Button {
            guard !isChecked else { return }
            onSelect(index)
        } label: {
            HStack {
                Text("\(index + 1). \(option)")
                    .font(.subheadline)
                Spacer()
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                } else if isWrongPick {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                }
            }
            .padding(10)
            .background(
                isCorrect ? Color.green.opacity(0.12)
                    : isWrongPick ? Color.red.opacity(0.10)
                    : isSelected ? Color.accentColor.opacity(0.10)
                    : Color.clear,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected || isCorrect ? Color.accentColor.opacity(0.4) : ChattyTheme.softHairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Speaking task

struct ExamSpeakingTask: Hashable {
    let unit: ExamUnit
    let scenario: String
}

struct ExamSpeakingView: View {
    let task: ExamSpeakingTask
    @Environment(\.dismiss) private var dismiss
    @State private var engine: ChatEngine
    @State private var inputText = ""
    @State private var isPulsing = false

    init(task: ExamSpeakingTask) {
        self.task = task
        _engine = State(initialValue: ChatEngine(
            persona: .examinerA1(scenario: task.scenario),
            store: TransientChatStore(),
            dependencies: .live
        ))
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Examiner: \(task.unit.title)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)

            ChatMessageList(
                messages: engine.messages,
                isGenerating: engine.isGenerating,
                onSpeak: { engine.speak($0.message) },
                onTranslate: { message in
                    Task { await engine.translate(message.message) }
                },
                onSuggest: { message in
                    Task { await engine.suggest(for: message.message) }
                },
                topContent: {
                    if engine.messages.isEmpty {
                        Text("Answer in German, even if it is simple. Your partner stays in the examiner role.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            )

            if engine.isRecording {
                Text(engine.transcriptText.isEmpty ? "Listening..." : engine.transcriptText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.horizontal, 16)
            }

            ChatInputBar(
                text: $inputText,
                isRecording: engine.isRecording,
                isPulsing: isPulsing,
                onToggleRecording: { engine.toggleRecording() },
                onSend: sendMessage
            )
            .padding(.horizontal, 16)
            .onAppear {
                if engine.isRecording {
                    startPulse()
                }
            }
            .onChange(of: engine.isRecording) { recording in
                if recording {
                    startPulse()
                } else {
                    isPulsing = false
                }
            }

            Button("Finish practice") {
                engine.interrupt()
                dismiss()
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.bottom, 8)
        }
        .navigationTitle("Sprechen")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            engine.sendText("Guten Tag! Ich bin bereit. Wir können anfangen.")
        }
        .onDisappear {
            engine.interrupt()
        }
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        engine.sendText(text)
    }

    private func startPulse() {
        isPulsing = false
        withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
            isPulsing = true
        }
    }
}
