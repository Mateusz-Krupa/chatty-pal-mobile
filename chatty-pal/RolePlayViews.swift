import SwiftUI

// MARK: - Situations (CMS global catalog)

struct RoleSituation: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let prompt: String
}

enum RolePlayError: LocalizedError {
    case requestFailed(status: Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .requestFailed(let status):
            return "Could not load scenarios (\(status))"
        case .decodingFailed:
            return "Unexpected scenario data"
        }
    }
}

enum RolePlayService {
    private static let cacheKey = "rolesituations.cache"

    static func fetchGlobalSituations(jwt: String) async throws -> [RoleSituation] {
        guard !jwt.isEmpty else { throw RolePlayError.requestFailed(status: 401) }
        let url = URL(string: "\(AppEnvironment.cmsAPIBaseURL.absoluteString)/situations?populate=name,prompt&type=GLOBAL")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw RolePlayError.requestFailed(status: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let items = json?["data"] as? [[String: Any]] else {
            throw RolePlayError.decodingFailed
        }
        return items.compactMap { item in
            guard let id = item["id"] as? Int,
                  let attributes = item["attributes"] as? [String: Any],
                  let name = attributes["name"] as? String, !name.isEmpty else { return nil }
            let prompt = strippingHTML((attributes["prompt"] as? String) ?? "")
            return RoleSituation(id: id, name: name, prompt: prompt)
        }
    }

    static func strippingHTML(_ html: String) -> String {
        var text = html
        if let pattern = try? NSRegularExpression(pattern: "<[^>]*>") {
            let ns = html as NSString
            text = pattern.stringByReplacingMatches(
                in: html,
                options: [],
                range: NSRange(location: 0, length: ns.length),
                withTemplate: " "
            )
        }
        text = text
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
        return text.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    static func cachedSituations() -> [RoleSituation]? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        return (try? JSONDecoder().decode([RoleSituation].self, from: data))
    }

    static func cacheSituations(_ items: [RoleSituation]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey)
    }
}

// MARK: - Result

struct RolePlayResult: Identifiable, Hashable {
    let id = UUID()
    var userMessages: Int
    var corrections: Int
    var xpAwarded: Int
}

// MARK: - Home (scenario list)

struct RolePlayHomeView: View {
    let jwt: String

    @State private var situations: [RoleSituation] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading scenarios...")
            } else if let errorMessage, situations.isEmpty {
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button("Retry") { load() }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(situations) { situation in
                            NavigationLink(value: situation) {
                                situationCard(situation)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
                .navigationDestination(for: RoleSituation.self) { situation in
                    RolePlayChatView(jwt: jwt, situation: situation)
                }
            }
        }
        .background(ChattyTheme.appBackground)
        .navigationTitle("Role Play")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { load() }
    }

    private func situationCard(_ situation: RoleSituation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "theatermasks")
                    .foregroundStyle(Color.accentColor)
                Text(situation.name)
                    .font(.body.weight(.semibold))
                    .lineLimit(2)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if !situation.prompt.isEmpty {
                Text(situation.prompt)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ChattyTheme.softHairline, lineWidth: 1)
        )
    }

    private func load() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let items = try await RolePlayService.fetchGlobalSituations(jwt: jwt)
                RolePlayService.cacheSituations(items)
                await MainActor.run {
                    situations = items
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    // Stale-while-error: fall back to the cached list.
                    if let cached = RolePlayService.cachedSituations() {
                        situations = cached
                    } else {
                        errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    }
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Role-play chat

struct RolePlayChatView: View {
    let jwt: String
    let situation: RoleSituation

    @Environment(\.dismiss) private var dismiss
    @State private var engine: ChatEngine
    @State private var conversationID: UUID
    @State private var inputText = ""
    @State private var isFinishing = false
    @State private var result: RolePlayResult?
    @State private var isPulsing = false

    init(jwt: String, situation: RoleSituation) {
        self.jwt = jwt
        self.situation = situation
        let lang = UserDefaults.standard.string(forKey: "langCode") ?? "de"
        let lvl = UserDefaults.standard.string(forKey: "level") ?? "B1"
        let store = ConversationStore.shared
        let conversation = store.startNew(
            languageCode: lang,
            level: lvl,
            kind: .rolePlay,
            title: situation.name,
            situationName: situation.name
        )
        self.conversationID = conversation.id
        var persona = ChatPersona.homework(
            language: LanguageConfig.all[lang] ?? LanguageConfig.default,
            level: lvl,
            prompt: situation.prompt
        )
        persona.memory = BotMemoryStore.shared.summary(for: lang)
        _engine = State(initialValue: ChatEngine(
            persona: persona,
            store: ConversationChatStore(store: store, conversationID: conversation.id),
            dependencies: .live
        ))
    }

    private var practiceLanguage: Language {
        if let code = UserDefaults.standard.string(forKey: "langCode"), let lang = LanguageConfig.all[code] {
            return lang
        }
        return LanguageConfig.default
    }

    var body: some View {
        ZStack {
            ChattyTheme.appBackground
                .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(situation.name)
                            .font(.system(size: 24, weight: .semibold))
                        Text("\(practiceLanguage.language) role play")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(action: finishRolePlay) {
                        Text(isFinishing ? "..." : "Finish")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(isFinishing || engine.messages.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

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
                    topContent: { EmptyView() }
                )
                .padding(.horizontal, 16)

                if engine.isRecording {
                    ListeningIndicator(transcript: engine.transcriptText, level: engine.audioLevel)
                        .padding(.horizontal, 16)
                } else if engine.isTranscribing {
                    ProgressView("Transcribing...")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(.horizontal, 16)
                }

                replyChips

                ChatInputBar(
                    text: $inputText,
                    isRecording: engine.isRecording,
                    isPulsing: isPulsing,
                    onToggleRecording: { engine.toggleRecording() },
                    onSend: sendInput
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .onChange(of: engine.isRecording) { recording in
                    if recording { startPulse() } else { isPulsing = false }
                }
            }
        }
        .navigationTitle(situation.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $result) { value in
            RolePlayResultCard(result: value)
        }
        .onAppear {
            engine.isActive = true
            if engine.messages.isEmpty {
                engine.sendText("Let's start the scenario.", credit: false)
            }
        }
        .onDisappear {
            engine.interrupt()
        }
    }

    @ViewBuilder
    private var replyChips: some View {
        if !engine.isRecording, !engine.isGenerating, !engine.replySuggestions.isEmpty {
            SuggestionChipsView(suggestions: engine.replySuggestions) { suggestion in
                engine.sendText(suggestion)
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

    private func finishRolePlay() {
        guard !isFinishing else { return }
        isFinishing = true
        engine.interrupt()
        let messages = engine.messages
        let userMessages = messages.filter { $0.role == .user }.count
        let corrections = messages.filter { $0.role == .teacher }.count
        let awarded = ConversationStore.shared.markCompleted(conversationID)
        if awarded {
            LearningStatsStore.shared.award(.rolePlay)
        }
        result = RolePlayResult(
            userMessages: userMessages,
            corrections: corrections,
            xpAwarded: awarded ? XPEvent.rolePlay.amount : 0
        )
        isFinishing = false
    }
}

struct RolePlayResultCard: View {
    let result: RolePlayResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            Text("Nice work!")
                .font(.title2.weight(.bold))
            VStack(spacing: 8) {
                resultRow(icon: "bubble.left.and.bubble.right", text: "\(result.userMessages) messages")
                resultRow(icon: "graduationcap.fill", text: "\(result.corrections) corrections")
                if result.xpAwarded > 0 {
                    resultRow(icon: "star.fill", text: "+\(result.xpAwarded) XP")
                }
            }
            Button("Done") { dismiss() }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
        }
        .padding(24)
        .presentationDetents([.medium])
    }

    private func resultRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(Color.accentColor)
            Text(text)
                .font(.body)
        }
    }
}
