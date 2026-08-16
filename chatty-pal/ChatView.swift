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

    @AppStorage("langCode") private var langCode: String = "de"
    @AppStorage("level") private var level: String = "B1"
    @AppStorage("jwt") private var jwt: String = ""
    @AppStorage("authUsername") private var authUsername: String = ""
    @AppStorage("authEmail") private var authEmail: String = ""
    @AppStorage("authRole") private var authRole: String = ""

    init() {
        let code = UserDefaults.standard.string(forKey: "langCode") ?? "de"
        let lvl = UserDefaults.standard.string(forKey: "level") ?? "B1"
        _engine = State(initialValue: ChatEngine(
            persona: .main(language: LanguageConfig.all[code] ?? LanguageConfig.default, level: lvl),
            store: LocalChatStore(languageCode: code, level: lvl),
            dependencies: .live
        ))
    }

    private var isLoggedIn: Bool { !jwt.isEmpty }
    private var isTeacher: Bool { authRole == "Teacher" }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                backgroundView

                VStack(spacing: 16) {
                    headerView

                    ChatMessageList(
                        messages: engine.messages,
                        isGenerating: false,
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
                        Text(engine.transcriptText.isEmpty ? "Listening..." : engine.transcriptText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
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
                        isTeacher: isTeacher,
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
                            jwt = ""
                            authUsername = ""
                            authEmail = ""
                            authRole = ""
                            availableChatLanguages = []
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
                    HomeworkListView(jwt: jwt)
                case .learningMaterials:
                    LearningMaterialsHomeView { lesson in
                        startLearningPractice(lesson)
                    }
                default:
                    PlaceholderView(title: destination.title)
                }
            }
        }
        .sheet(isPresented: $isLoginPresented) {
            LoginPanel(
                onCancel: { isLoginPresented = false },
                onSuccess: { token, name in
                    jwt = token
                    authUsername = name
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
        .onAppear {
            applyCurrentPersona()
            if !jwt.isEmpty {
                Task { await loadUserProfile(jwt: jwt) }
            }
        }
        .onChange(of: langCode) { _ in
            applyCurrentPersona()
        }
        .onChange(of: level) { _ in
            applyCurrentPersona()
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
                Button(action: { isSettingsPresented = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(10)
                }
                .buttonStyle(.bordered)
                .modifier(GlassButtonModifier())

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
            }
        }
        .padding(.top, 12)
    }

    private var inputBar: some View {
        ChatInputBar(
            text: $messageText,
            isRecording: engine.isRecording,
            isPulsing: isPulsing,
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
        engine.sendText(prompt)
    }

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messageText = ""
        engine.sendText(text)
    }

    private func applyCurrentPersona() {
        engine.reload(
            persona: .main(language: LanguageConfig.all[langCode] ?? LanguageConfig.default, level: level),
            store: LocalChatStore(languageCode: langCode, level: level)
        )
    }

    private func startPulse() {
        isPulsing = false
        withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
            isPulsing = true
        }
    }

    // After login: fetch the user's Strapi profile and apply their saved language + level
    // (mirrors the web app's updateUser() -> getMe() flow in _app.tsx)
    private func loadUserProfile(jwt: String) async {
        do {
            let profile = try await AuthService().getMe(jwt: jwt)
            await MainActor.run {
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
                if let code = profile.language?.code, !code.isEmpty,
                   LanguageConfig.all[code] != nil {
                    langCode = code
                }
                if let lvl = profile.language?.level, !lvl.isEmpty,
                    LanguageConfig.levels.contains(lvl) {
                    level = lvl
                }
                applyCurrentPersona()
            }
        } catch {
            // Non-fatal — keep local defaults if profile fetch fails
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
