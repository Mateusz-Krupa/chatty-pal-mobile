import SwiftUI

struct HomeworkListView: View {
    let jwt: String
    @State private var homeworks: [HomeworkViewModel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView("Loading homework...")
                Spacer()
            } else if let errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button("Retry") { loadHomeworks() }
                        .buttonStyle(.borderedProminent)
                }
                Spacer()
            } else if homeworks.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "pencil.and.list.clipboard")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No homework yet")
                        .font(.headline)
                    Text("When your teacher assigns homework, it will appear here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(32)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(homeworks) { homework in
                            NavigationLink(value: HomeworkDestination.detail(homework.id)) {
                                HomeworkCard(homework: homework)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Homework")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: HomeworkDestination.self) { dest in
            switch dest {
            case .detail(let id):
                HomeworkDetailView(homeworkID: id, jwt: jwt)
            case .chat(let homework):
                HomeworkChatView(homework: homework, jwt: jwt)
            }
        }
        .onAppear { loadHomeworks() }
    }

    private func loadHomeworks() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let result = try await HomeworkService().getMyHomeworks(jwt: jwt)
                await MainActor.run {
                    homeworks = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

private enum HomeworkDestination: Hashable {
    case detail(Int)
    case chat(HomeworkViewModel)
}

private struct HomeworkCard: View {
    let homework: HomeworkViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(homework.title)
                    .font(.body.weight(.semibold))
                    .lineLimit(2)
                Spacer()
                HomeworkStatusBadge(status: homework.status)
            }
            if let lang = homework.languageCode, let level = homework.level {
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.caption)
                    Text("\(LanguageConfig.all[lang]?.language ?? lang) \(level)")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            if let date = homework.finishDate {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(formatDate(date))
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ChattyTheme.softHairline, lineWidth: 1)
        )
    }

    private func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        if let date = formatter.date(from: iso) {
            let display = DateFormatter()
            display.dateStyle = .medium
            return display.string(from: date)
        }
        return iso
    }
}

private struct HomeworkStatusBadge: View {
    let status: HomeworkStatus

    private var label: String {
        switch status {
        case .new: return "New"
        case .inProgress: return "In Progress"
        case .done: return "Completed"
        case .finished: return "Completed"
        }
    }

    private var color: Color {
        switch status {
        case .new: return .blue
        case .inProgress: return .orange
        case .done: return .green
        case .finished: return .green
        }
    }

    var body: some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color, in: Capsule())
    }
}

private struct HomeworkDetailView: View {
    let homeworkID: Int
    let jwt: String
    @State private var homework: HomeworkViewModel?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView("Loading homework...")
                Spacer()
            } else if let errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button("Retry") { loadDetail() }
                        .buttonStyle(.borderedProminent)
                }
                Spacer()
            } else if let hw = homework {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Homework", systemImage: "pencil.and.list.clipboard")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accentColor)
                            Text(hw.title)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            HomeworkStatusBadge(status: hw.status)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(ChattyTheme.heroGradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(ChattyTheme.softHairline, lineWidth: 1)
                        )

                        if let lang = hw.languageCode, let level = hw.level {
                            InfoSectionCard(title: "Language", systemImage: "globe") {
                                Text("\(LanguageConfig.all[lang]?.language ?? lang) \(level)")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if let prompt = hw.prompt, !prompt.isEmpty {
                            InfoSectionCard(title: "Scenario", systemImage: "text.bubble") {
                                Text(prompt)
                                    .font(.body)
                                    .lineSpacing(4)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if let date = hw.finishDate {
                            InfoSectionCard(title: "Due Date", systemImage: "calendar") {
                                Text(date)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if hw.status == .new {
                            NavigationLink(value: HomeworkDestination.chat(hw)) {
                                Text("Start Homework")
                                    .font(.body.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            }
                            .buttonStyle(.borderedProminent)
                        } else if hw.status == .inProgress {
                            NavigationLink(value: HomeworkDestination.chat(hw)) {
                                Text("Continue Homework")
                                    .font(.body.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            NavigationLink(value: HomeworkDestination.chat(hw)) {
                                Text("Review Homework")
                                    .font(.body.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Homework Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadDetail() }
    }

    private func loadDetail() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let result = try await HomeworkService().getHomework(id: homeworkID, jwt: jwt)
                await MainActor.run {
                    homework = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

}

private struct HomeworkChatView: View {
    let homework: HomeworkViewModel
    let jwt: String
    @Environment(\.dismiss) private var dismiss

    @State private var currentStatus: HomeworkStatus
    @State private var engine: ChatEngine
    @State private var isStarting = false
    @State private var startError: String?
    @State private var isFinishing = false
    @State private var finishError: String?
    @State private var inputText = ""
    @State private var isPulsing = false

    init(homework: HomeworkViewModel, jwt: String) {
        self.homework = homework
        self.jwt = jwt
        _currentStatus = State(initialValue: homework.status)
        let language = homework.languageCode.flatMap { LanguageConfig.all[$0] } ?? LanguageConfig.default
        let lvl = homework.level ?? "B1"
        _engine = State(initialValue: ChatEngine(
            persona: .homework(language: language, level: lvl, prompt: homework.prompt ?? ""),
            store: HomeworkChatStore(homeworkMessages: homework.messages),
            dependencies: .live
        ))
    }

    private var isReadOnly: Bool { currentStatus == .finished || currentStatus == .done }
    private var isActive: Bool { currentStatus == .inProgress }

    private var practiceLanguage: Language {
        if let code = homework.languageCode, let lang = LanguageConfig.all[code] {
            return lang
        }
        return LanguageConfig.default
    }

    private var practiceLevel: String {
        homework.level ?? "B1"
    }

    var body: some View {
        ZStack {
            homeworkBackgroundView

            VStack(spacing: 16) {
                homeworkHeaderView

                if let startError { errorBanner(startError) }
                if let finishError { errorBanner(finishError) }

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
                        if currentStatus == .new {
                            startCard
                        } else if engine.messages.isEmpty {
                            emptyState
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
                }

                if isActive { activeControls }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .navigationTitle(homework.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { engine.toggleTTS() }) {
                    Image(systemName: engine.isTTSEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                }
            }
        }
        .onAppear {
            engine.isActive = isActive
        }
        .onDisappear {
            engine.interrupt()
        }
    }

    private var homeworkHeaderView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Homework")
                    .font(.system(size: 28, weight: .semibold))
                Text("\(practiceLanguage.language) - \(practiceLevel)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HomeworkStatusBadge(status: currentStatus)
                .padding(.top, 4)
        }
        .padding(.top, 12)
    }

    private var homeworkBackgroundView: some View {
        ZStack {
            ChattyTheme.appBackground

            Circle()
                .fill(Color.blue.opacity(0.08))
                .frame(width: 320, height: 320)
                .blur(radius: 40)
                .offset(x: -140, y: -240)

            Circle()
                .fill(Color.green.opacity(0.06))
                .frame(width: 260, height: 260)
                .blur(radius: 40)
                .offset(x: 170, y: 220)
        }
        .ignoresSafeArea()
    }

    private var startCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(Color.accentColor)

            VStack(spacing: 8) {
                Text("Start Homework")
                    .font(.title2.weight(.semibold))
                Text(homework.prompt?.isEmpty == false ? homework.prompt! : "Start the scenario conversation when you are ready.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
            }

            Button(action: startHomeworkChat) {
                HStack {
                    if isStarting { ProgressView().tint(.white) }
                    Text("Start")
                        .font(.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isStarting)
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(ChattyTheme.softHairline, lineWidth: 1)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: isReadOnly ? "checkmark.circle.fill" : "bubble.left.and.bubble.right")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(isReadOnly ? Color.green : Color.secondary)
            Text(isReadOnly ? "No saved messages" : "Ready when you are")
                .font(.headline)
            Text(isReadOnly ? "This homework is completed, but no conversation messages were saved." : "Send or dictate a message to continue the homework scenario.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var activeControls: some View {
        VStack(spacing: 10) {
            inputBar

            Button(action: finishHomework) {
                HStack {
                    if isFinishing { ProgressView().tint(.white) }
                    Text("Finish Homework")
                        .font(.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .disabled(isFinishing || engine.isGenerating || engine.messages.isEmpty)
        }
    }

    private var inputBar: some View {
        ChatInputBar(
            text: $inputText,
            isRecording: engine.isRecording,
            isPulsing: isPulsing,
            onToggleRecording: { engine.toggleRecording() },
            onSend: sendInput
        )
        .onAppear { if engine.isRecording { startPulse() } }
        .onChange(of: engine.isRecording) { recording in
            if recording { startPulse() } else { isPulsing = false }
        }
    }

    private func errorBanner(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func startHomeworkChat() {
        guard !isStarting else { return }
        isStarting = true
        startError = nil
        Task {
            do {
                try await HomeworkService().updateHomework(id: homework.id, jwt: jwt, status: .inProgress)
                currentStatus = .inProgress
                engine.isActive = true
                isStarting = false
                engine.sendText("lets start")
            } catch {
                isStarting = false
                startError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
        }
    }

    private func sendInput() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        inputText = ""
        engine.sendText(trimmed)
    }

    private func startPulse() {
        isPulsing = false
        withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
            isPulsing = true
        }
    }

    private func finishHomework() {
        guard isActive else { return }
        engine.interrupt()
        isFinishing = true
        finishError = nil
        let cleanedMessages = HomeworkMessageMapper.toHomeworkMessages(engine.messages, voice: practiceLanguage.voice)
        Task {
            do {
                try await HomeworkService().updateHomework(
                    id: homework.id, jwt: jwt, status: .finished, messages: cleanedMessages
                )
                currentStatus = .finished
                engine.isActive = false
                isFinishing = false
                dismiss()
            } catch {
                isFinishing = false
                finishError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
        }
    }
}

