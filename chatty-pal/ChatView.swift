//
//  ChatView.swift
//  chatty-pal
//
//  Created by Mateusz Krupa on 09/05/2023.
//

import AVFoundation
import SwiftUI
import WebKit

struct ChatView: View {
    @State private var messageText: String = ""
    @State private var isLoginPresented: Bool = false
    @State private var isPulsing: Bool = false
    @State private var isMenuPresented: Bool = false
    @State private var isSettingsPresented: Bool = false
    @State private var availableChatLanguages: [UserProfileLanguage] = []
    @State private var navigationPath = NavigationPath()
    @State private var engine: ChatEngine
    @State private var sessionExpired = false
    @State private var profileChecked = false

    @State private var session: AuthSession

    @AppStorage("langCode") private var langCode: String = "de"
    @AppStorage("level") private var level: String = "B1"
    @AppStorage("authUsername") private var authUsername: String = ""
    @AppStorage("authEmail") private var authEmail: String = ""
    @AppStorage("authRole") private var authRole: String = ""
    @AppStorage("appEnvironment") private var appEnvironment: String = AppEnvironmentMode.production.rawValue
    @AppStorage("localWebBaseURL") private var localWebBaseURL: String = AppEnvironment.defaultLocalWebBaseURL
    @AppStorage("localCMSAPIBaseURL") private var localCMSAPIBaseURL: String = AppEnvironment.defaultLocalCMSAPIBaseURL

    init() {
        let code = UserDefaults.standard.string(forKey: "langCode") ?? "de"
        let lvl = UserDefaults.standard.string(forKey: "level") ?? "B1"
        let store = ConversationStore.shared
        let conversationID = Self.conversationID(store: store, languageCode: code, level: lvl)
        _session = State(initialValue: AuthSession())
        _engine = State(initialValue: ChatEngine(
            persona: Self.makePersona(languageCode: code, level: lvl),
            store: ConversationChatStore(store: store, conversationID: conversationID),
            dependencies: .live
        ))
    }

    static func conversationID(store: ConversationStore, languageCode: String, level: String) -> UUID {
        if let active = store.activeID,
           let activeConversation = store.conversation(active),
           activeConversation.languageCode == languageCode,
           activeConversation.level == level {
            return active
        }
        return store.mostRecent(languageCode: languageCode, level: level)?.id
            ?? store.startNew(languageCode: languageCode, level: level).id
    }

    static func makePersona(languageCode: String, level: String) -> ChatPersona {
        var persona = ChatPersona.main(
            language: LanguageConfig.all[languageCode] ?? LanguageConfig.default,
            level: level
        )
        persona.memory = BotMemoryStore.shared.summary(for: languageCode)
        return persona
    }

    private var isLoggedIn: Bool { session.isAuthenticated }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                backgroundView

                VStack(spacing: 16) {
                    headerView

                    if sessionExpired && !isLoginPresented {
                        sessionExpiredBanner
                    }

                    todayCard

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

                    if engine.isRecording {
                        ListeningIndicator(transcript: engine.transcriptText, level: engine.audioLevel)
                    } else if engine.isTranscribing {
                        ProgressView("Transcribing...")
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    } else if !engine.isGenerating, !engine.replySuggestions.isEmpty {
                        SuggestionChipsView(suggestions: engine.replySuggestions) { suggestion in
                            engine.sendText(suggestion)
                        }
                    }

                    inputBar
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

                if isMenuPresented {
                    MenuOverlay(
                        isPresented: $isMenuPresented,
                        isLoggedIn: isLoggedIn,
                        authUsername: authUsername,
                        authEmail: authEmail,
                        chatLanguages: availableChatLanguages,
                        currentLanguageCode: langCode,
                        currentLevel: level,
                        onChatSelect: { chat in
                            engine.interrupt()
                            let nextCode = chat.code.flatMap { LanguageConfig.all[$0] != nil ? $0 : nil } ?? langCode
                            let nextLevel = chat.level.flatMap { LanguageConfig.levels.contains($0) ? $0 : nil } ?? level
                            langCode = nextCode
                            level = nextLevel
                            applyCurrentPersona()
                        },
                        onNavigate: { engine.interrupt() },
                        onLogin: { isLoginPresented = true },
                        onLogout: {
                            LearningProgressStore.shared.configure(jwt: "")
                            session.signOut()
                            authUsername = ""
                            authEmail = ""
                            authRole = ""
                            availableChatLanguages = []
                            LearningStatsStore.shared.scopeDidChange()
                            WordReviewStore.shared.scopeDidChange()
                            ConversationStore.shared.scopeDidChange()
                            BotMemoryStore.shared.scopeDidChange()
                            applyCurrentPersona()
                        }
                    )
                }
            }
            .navigationDestination(for: MenuDestination.self) { destination in
                switch destination {
                case .info:
                    InfoView()
                case .policy:
                    PolicyView()
                case .homework:
                    HomeworkListView(jwt: session.jwt)
                case .learningMaterials:
                    LearningMaterialsHomeView { lesson in
                        startLearningPractice(lesson)
                    }
                case .examPrep:
                    ExamCampaignHomeView()
                case .wordReview:
                    WordReviewView()
                case .chats:
                    ConversationListView { conversation in
                        openConversation(conversation)
                    }
                case .rolePlay:
                    RolePlayHomeView(jwt: session.jwt)
                case .aboutUs:
                    InfoView()
                }
            }
        }
        .sheet(isPresented: $isLoginPresented) {
            LoginPanel(
                onCancel: { isLoginPresented = false },
                onSuccess: { token, name in
                    session.signIn(with: token)
                    authUsername = name
                    sessionExpired = false
                    profileChecked = true
                    LearningStatsStore.shared.scopeDidChange()
                    WordReviewStore.shared.scopeDidChange()
                    ConversationStore.shared.scopeDidChange()
                    BotMemoryStore.shared.scopeDidChange()
                    applyCurrentPersona()
                    isLoginPresented = false
                    Task { await loadUserProfile(jwt: token) }
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .task(id: "\(session.jwt)|\(appEnvironment)|\(localCMSAPIBaseURL)|\(AuthService.backendURL.absoluteString)") {
            LearningProgressStore.shared.configure(jwt: session.jwt)
            await LearningProgressStore.shared.refresh()
        }
        .onAppear {
            applyCurrentPersona()
            if session.isAuthenticated && !profileChecked {
                profileChecked = true
                Task { await loadUserProfile(jwt: session.jwt) }
            }
        }
        .onChange(of: langCode) { _ in
            applyCurrentPersona()
        }
        .onChange(of: level) { _ in
            applyCurrentPersona()
        }
        .onChange(of: appEnvironment) { _ in
            rebuildEngine()
        }
        .onChange(of: localWebBaseURL) { _ in
            rebuildEngine()
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Chatty Pal")
                    .font(.system(size: 28, weight: .semibold))
                Text("Ask anything")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: startNewChat) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(10)
                }
                .buttonStyle(.bordered)
                .modifier(GlassButtonModifier())

                Button(action: { isSettingsPresented = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(10)
                }
                .buttonStyle(.bordered)
                .modifier(GlassButtonModifier())
                .accessibilityIdentifier("settingsButton")

                Button(action: { engine.toggleTTS() }) {
                    Image(systemName: engine.isTTSEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(10)
                }
                .buttonStyle(.bordered)
                .modifier(GlassButtonModifier())

                Button(action: { isMenuPresented = true }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(10)
                }
                .buttonStyle(.bordered)
                .modifier(GlassButtonModifier())
                .accessibilityIdentifier("menuButton")
            }
        }
        .padding(.top, 12)
    }

    private var sessionExpiredBanner: some View {
        VStack(spacing: 8) {
            Text("Session expired. Sign in again to access your homework and profile.")
                .font(.footnote)
                .multilineTextAlignment(.center)
            Button("Sign in") {
                isLoginPresented = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var todayCard: some View {
        let stats = LearningStatsStore.shared
        let due = WordReviewStore.shared.dueCount
        let recap = stats.weeklyRecap()
        return Button {
            navigationPath.append(MenuDestination.wordReview)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                    Text(stats.streak > 0 ? "\(stats.streak)-day streak" : "Start your streak today")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("Level \(stats.level)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.accentColor.opacity(0.12), in: Capsule())
                    if due > 0 {
                        Text("\(due) due")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.accentColor.opacity(0.12), in: Capsule())
                    }
                }
                HStack(spacing: 8) {
                    ProgressView(value: stats.levelProgress)
                        .tint(Color.accentColor)
                    Text("\(stats.xp % LearningStatsStore.xpPerLevel)/\(LearningStatsStore.xpPerLevel) XP")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                HStack(spacing: 6) {
                    Image(systemName: stats.questCompletedToday ? "checkmark.seal.fill" : "target")
                        .font(.caption)
                        .foregroundStyle(stats.questCompletedToday ? Color.green : Color.secondary)
                    Text(stats.questCompletedToday
                         ? "Daily quest complete (+25 XP)"
                         : "Daily quest: earn \(LearningStatsStore.dailyQuestXP - stats.questProgress) more XP today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                HStack(spacing: 14) {
                    Label("\(LearningProgressStore.shared.completedLessonCount) lessons", systemImage: "book.fill")
                    Label("\(stats.totalReviews) reviews", systemImage: "checkmark.circle.fill")
                    Label("\(recap.messages) msgs · \(recap.reviews) rev · \(recap.xp) XP", systemImage: "calendar")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var inputBar: some View {
        ChatInputBar(
            text: $messageText,
            isRecording: engine.isRecording,
            isPulsing: isPulsing,
            isVoiceLocked: engine.voiceState == .waitingForBot || engine.voiceState == .playingTTS,
            onToggleRecording: { engine.toggleRecording() },
            onSend: sendMessage
        )
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
    }

    private var backgroundView: some View {
        ZStack {
            ChattyTheme.appBackground

            Circle()
                .fill(Color.blue.opacity(0.14))
                .frame(width: 320, height: 320)
                .blur(radius: 40)
                .offset(x: -140, y: -240)

            Circle()
                .fill(Color.green.opacity(0.10))
                .frame(width: 260, height: 260)
                .blur(radius: 40)
                .offset(x: 170, y: 220)
        }
        .ignoresSafeArea()
    }

    private func startLearningPractice(_ lesson: LearningLesson) {
        engine.interrupt()
        messageText = ""
        langCode = lesson.languageCode
        level = lesson.level
        applyCurrentPersona()
        navigationPath = NavigationPath()

        let prompt = """
        Start a new Chatty Pal speaking practice for this lesson.
        Lesson: \(lesson.title)
        Topic: \(lesson.topic)
        Level: \(lesson.level)
        Practice goal: \(lesson.practicePrompt)

        Speak first as the conversation partner. Keep it short, natural, friendly, and only in \(lesson.languageName). Ask one simple question that helps the student begin the role play.
        """
        engine.sendText(prompt, credit: false)
    }

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messageText = ""
        engine.sendText(text)
    }

    private func applyCurrentPersona() {
        let store = ConversationStore.shared
        let conversationID = Self.conversationID(store: store, languageCode: langCode, level: level)
        engine.reload(
            persona: Self.makePersona(languageCode: langCode, level: level),
            store: ConversationChatStore(store: store, conversationID: conversationID)
        )
    }

    // Rebuilds the engine so its services (bot, TTS, teacher, transcriber)
    // pick up the current AppEnvironment origin without an app restart.
    private func rebuildEngine() {
        let store = ConversationStore.shared
        let conversationID = Self.conversationID(store: store, languageCode: langCode, level: level)
        engine = ChatEngine(
            persona: Self.makePersona(languageCode: langCode, level: level),
            store: ConversationChatStore(store: store, conversationID: conversationID),
            dependencies: .live
        )
    }

    private func openConversation(_ conversation: Conversation) {
        navigationPath = NavigationPath()
        langCode = conversation.languageCode
        level = conversation.level
        let store = ConversationStore.shared
        store.setActive(conversation.id)
        engine.reload(
            persona: Self.makePersona(languageCode: conversation.languageCode, level: conversation.level),
            store: ConversationChatStore(store: store, conversationID: conversation.id)
        )
    }

    private func startNewChat() {
        engine.interrupt()
        let store = ConversationStore.shared
        let conversation = store.startNew(languageCode: langCode, level: level)
        engine.reload(
            persona: Self.makePersona(languageCode: langCode, level: level),
            store: ConversationChatStore(store: store, conversationID: conversation.id)
        )
    }

    private func startPulse() {
        isPulsing = false
        withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
            isPulsing = true
        }
    }

    // After login / at launch: fetch the user's Strapi profile.
    // Populates the menu (username, email, role, selectable languages) but
    // deliberately does NOT switch the active chat language/level — doing so
    // would move the user to a different (empty) chat thread.
    private func loadUserProfile(jwt: String) async {
        do {
            let profile = try await AuthService().getMe(jwt: jwt)
            await MainActor.run {
                authUsername = profile.username
                authEmail = profile.email
                authRole = profile.role?.name ?? ""
                let profileChats = (profile.languages?.isEmpty == false)
                    ? (profile.languages ?? [])
                    : [profile.language].compactMap { $0 }
                availableChatLanguages = profileChats
                    .filter { chat in
                        guard let code = chat.code else { return false }
                        return LanguageConfig.all[code] != nil
                    }
            }
        } catch {
            var isAuthFailure = false
            if case .badRequest(let status, _)? = error as? AuthError {
                isAuthFailure = status == 401 || status == 403
            }
            guard isAuthFailure else { return } // Other failures are non-fatal — keep local state
            await MainActor.run {
                session.signOut()
                authUsername = ""
                authEmail = ""
                authRole = ""
                availableChatLanguages = []
                LearningStatsStore.shared.scopeDidChange()
                WordReviewStore.shared.scopeDidChange()
                ConversationStore.shared.scopeDidChange()
                BotMemoryStore.shared.scopeDidChange()
                applyCurrentPersona()
                sessionExpired = true
            }
        }
    }

}

private struct GlassButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                .thinMaterial,
                in: Circle()
            )
            .overlay(
                Circle()
                    .stroke(ChattyTheme.softHairline, lineWidth: 1)
            )
    }
}



// MARK: - Google OAuth via WKWebView (Strapi /connect/google flow, same as web)


struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
