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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var messageText: String = ""
    @State private var isLoginPresented: Bool = false
    @State private var isPulsing: Bool = false
    @State private var inputHeight: CGFloat = 44
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

    private let inputMaxHeight: CGFloat = 140

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

                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(engine.messages) { message in
                                    MessageView(
                                        message: message,
                                        onTeacherTap: {
                                            engine.speak(message.message)
                                        },
                                        onReplayTap: {
                                            engine.speak(message.message)
                                        },
                                        onTranslateTap: {
                                            Task {
                                                await engine.translate(message.message)
                                            }
                                        },
                                        onSuggestTap: {
                                            Task {
                                                await engine.suggest(for: message.message)
                                            }
                                        }
                                    )
                                    .id(message.id)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .onChange(of: engine.messages.count) { _ in
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if let lastID = engine.messages.last?.id {
                                    proxy.scrollTo(lastID, anchor: .bottom)
                                }
                            }
                        }
                        .onAppear {
                            if let lastID = engine.messages.last?.id {
                                proxy.scrollTo(lastID, anchor: .bottom)
                            }
                        }
                    }

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
        Group {
            if horizontalSizeClass == .compact {
                HStack {
                    Spacer()
                    Button(action: { engine.toggleRecording() }) {
                        Image(systemName: engine.isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(engine.isRecording ? Color.red : Color.accentColor)
                            .frame(width: 69, height: 69)
                            .background(.thinMaterial, in: Circle())
                            .overlay(
                                Circle()
                                    .stroke(ChattyTheme.softHairline, lineWidth: 1)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.red.opacity(0.35), lineWidth: 2)
                                    .scaleEffect(isPulsing ? 1.35 : 0.9)
                                    .opacity(isPulsing ? 0 : 0.35)
                            )
                    }
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
                    Spacer()
                }
                .padding(.vertical, 6)
                .modifier(GlassPanelModifier())
            } else {
                HStack(spacing: 8) {
                    ZStack(alignment: .leading) {
                        if messageText.isEmpty {
                            Text("Type a message...")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 8)
                        }

                        TextEditor(text: $messageText)
                            .font(.body)
                            .frame(minHeight: 44, maxHeight: min(inputHeight, inputMaxHeight))
                            .background(
                                InputHeightReader(text: messageText)
                            )
                            .onPreferenceChange(InputHeightKey.self) { height in
                                inputHeight = max(44, height + 16)
                            }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 6)

                    Button(action: { engine.toggleRecording() }) {
                        Image(systemName: engine.isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(engine.isRecording ? Color.red : Color.accentColor)
                    }

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(
                                messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? Color.secondary
                                    : Color.accentColor
                            )
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .modifier(GlassPanelModifier())
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

private struct GlassPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 4)
            .background(
                .thinMaterial,
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(ChattyTheme.softHairline, lineWidth: 1)
            )
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

private struct InputHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 44

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct InputHeightReader: View {
    let text: String

    var body: some View {
        Text(text.isEmpty ? " " : text)
            .font(.body)
            .lineLimit(nil)
            .padding(.vertical, 8)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(key: InputHeightKey.self, value: proxy.size.height)
                }
            )
            .opacity(0)
    }
}

// MARK: - Google OAuth via WKWebView (Strapi /connect/google flow, same as web)

private struct GoogleAuthWebView: UIViewRepresentable {
    let startURL: URL
    let onCallback: (String) -> Void   // receives query string e.g. "access_token=XXX"
    let onError: (Error) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: startURL))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        let parent: GoogleAuthWebView
        init(parent: GoogleAuthWebView) { self.parent = parent }

        func webView(_ wv: WKWebView, decidePolicyFor a: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = a.request.url,
               url.path.contains("/auth/") && url.path.contains("/redirect"),
               let q = url.query, !q.isEmpty {
                parent.onCallback(q)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        func webView(_ wv: WKWebView, didFail n: WKNavigation!, withError e: Error) {
            parent.onError(e)
        }
    }
}

private struct GoogleAuthSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSuccess: (String, String) -> Void
    let onError: (String) -> Void

    @State private var isExchanging = false
    @State private var error: String?

    private var startURL: URL { AppEnvironment.cmsAPIBaseURL.appendingPathComponent("connect/google") }

    var body: some View {
        NavigationStack {
            ZStack {
                GoogleAuthWebView(
                    startURL: startURL,
                    onCallback: { qs in exchange(queryString: qs) },
                    onError: { error = $0.localizedDescription }
                )
                if isExchanging { ProgressView("Signing in...") }
            }
            .navigationTitle("Google Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            if let error {
                Text(error).font(.footnote).foregroundStyle(.red).padding()
            }
        }
    }

    private func exchange(queryString: String) {
        isExchanging = true
        Task {
            do {
                let r = try await AuthService().exchangeOAuthCallback(queryString: queryString)
                await MainActor.run {
                    isExchanging = false
                    dismiss()
                    onSuccess(r.jwt, r.user.username)
                }
            } catch {
                await MainActor.run {
                    isExchanging = false
                    self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                }
            }
        }
    }
}

private struct LoginPanel: View {
    let onCancel: () -> Void
    let onSuccess: (String, String) -> Void  // (jwt, username)

    @State private var identifier = ""
    @State private var password = ""
    @State private var email = ""
    @State private var isRegisterMode = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isGoogleAuthPresented = false

    private let authService = AuthService()

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 6) {
                Text(isRegisterMode ? "Create account" : "Welcome back")
                    .font(.system(size: 24, weight: .semibold))
                Text(isRegisterMode ? "Sign up to continue" : "Sign in to continue")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                if isRegisterMode {
                    TextField("Username", text: $identifier)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.username)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    TextField("Username or email", text: $identifier)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.username)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            HStack(spacing: 12) {
                Button("Cancel", action: onCancel)
                    .buttonStyle(.bordered)

                Button(isRegisterMode ? "Register" : "Login") {
                    performAuth()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || identifier.trimmingCharacters(in: .whitespaces).isEmpty || password.isEmpty)
            }

            Button(isRegisterMode ? "Already have an account? Sign in" : "Don't have an account? Register") {
                isRegisterMode.toggle()
                errorMessage = nil
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            Divider().padding(.vertical, 4)

            Button {
                isGoogleAuthPresented = true
            } label: {
                HStack(spacing: 8) {
                    Text("G")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Color(red: 0.26, green: 0.52, blue: 0.96), in: Circle())
                    Text("Sign in with Google")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(24)
        .modifier(GlassPanelModifier())
        .padding(.horizontal, 20)
        .sheet(isPresented: $isGoogleAuthPresented) {
            GoogleAuthSheet(
                onSuccess: { token, name in
                    isGoogleAuthPresented = false
                    onSuccess(token, name)
                },
                onError: { msg in
                    isGoogleAuthPresented = false
                    errorMessage = msg
                }
            )
        }
    }

    private func performAuth() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let response: AuthResponse
                if isRegisterMode {
                    response = try await authService.register(username: identifier, email: email, password: password)
                } else {
                    response = try await authService.login(identifier: identifier, password: password)
                }
                DispatchQueue.main.async {
                    isLoading = false
                    onSuccess(response.jwt, response.user.username)
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                }
            }
        }
    }
}

private enum MenuDestination: Hashable {
    case userPanel
    case chat
    case info
    case policy
    case homework
    case teacherHelp
    case learningMaterials
    case classroom
    case stories
    case lessonPlanner
    case aboutUs

    var title: String {
        switch self {
        case .userPanel:
            return "User Panel"
        case .chat:
            return "Chat"
        case .info:
            return "Info"
        case .policy:
            return "Policy"
        case .homework:
            return "Homework"
        case .teacherHelp:
            return "Teacher Help"
        case .learningMaterials:
            return "Learning Materials"
        case .classroom:
            return "Classroom"
        case .stories:
            return "My Stories List"
        case .lessonPlanner:
            return "Lesson Planner"
        case .aboutUs:
            return "About Us"
        }
    }

    var systemImage: String {
        switch self {
        case .userPanel:
            return "person.crop.circle"
        case .chat:
            return "bubble.left.and.bubble.right"
        case .info:
            return "info.circle"
        case .policy:
            return "doc.text"
        case .homework:
            return "pencil.and.list.clipboard"
        case .teacherHelp:
            return "questionmark.circle"
        case .learningMaterials:
            return "book.closed"
        case .classroom:
            return "person.3"
        case .stories:
            return "list.bullet.rectangle"
        case .lessonPlanner:
            return "calendar"
        case .aboutUs:
            return "building.2"
        }
    }
}

private struct MenuOverlay: View {
    @Binding var isPresented: Bool
    let isLoggedIn: Bool
    let authUsername: String
    let authEmail: String
    let isTeacher: Bool
    let chatLanguages: [UserProfileLanguage]
    let currentLanguageCode: String
    let currentLevel: String
    let onChatSelect: (UserProfileLanguage) -> Void
    let onNavigate: () -> Void
    let onLogin: () -> Void
    let onLogout: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .trailing) {
                ChattyTheme.overlayScrim
                    .ignoresSafeArea()
                    .onTapGesture { isPresented = false }

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Menu")
                            .font(.headline)
                        Spacer()
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 14) {
                            MenuSectionHeader(title: "User Panel")
                            MenuActionRow(title: "Chat", systemImage: "bubble.left.and.bubble.right") {
                                isPresented = false
                            }
                            if isLoggedIn {
                                ForEach(Array(chatLanguages.enumerated()), id: \.offset) { _, chat in
                                    MenuActionRow(
                                        title: chatTitle(chat),
                                        systemImage: "message",
                                        selected: chat.code == currentLanguageCode && chat.level == currentLevel
                                    ) {
                                        onChatSelect(chat)
                                        isPresented = false
                                    }
                                    .padding(.leading, 26)
                                }
                            }
                            MenuLinkRow(destination: .info, disabled: false) { selectDestination() }
                            MenuLinkRow(destination: .policy, disabled: false) { selectDestination() }

                            MenuSectionHeader(title: "Student")
                            MenuLinkRow(destination: .homework, disabled: !isLoggedIn) { selectDestination() }
                            MenuLinkRow(destination: .teacherHelp, disabled: false) { selectDestination() }
                            MenuLinkRow(destination: .learningMaterials, disabled: false) { selectDestination() }

                            MenuSectionHeader(title: "Teacher")
                            MenuLinkRow(destination: .classroom, disabled: !isTeacher) { selectDestination() }
                            MenuLinkRow(destination: .stories, disabled: !isTeacher) { selectDestination() }
                            MenuLinkRow(destination: .lessonPlanner, disabled: !isTeacher) { selectDestination() }

                            MenuSectionHeader(title: "Our Company")
                            MenuLinkRow(destination: .aboutUs, disabled: false) { selectDestination() }

                            Divider()
                                .padding(.vertical, 4)

                            if isLoggedIn {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accentColor.opacity(0.15))
                                            .frame(width: 36, height: 36)
                                        Text(String(authUsername.prefix(2)).uppercased())
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(Color.accentColor)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(authUsername)
                                            .font(.subheadline.weight(.semibold))
                                            .lineLimit(1)
                                        if !authEmail.isEmpty {
                                            Text(authEmail)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 4)

                                Button(action: {
                                    isPresented = false
                                    onLogout()
                                }) {
                                    MenuRowContent(title: "Logout", systemImage: "arrow.right.circle")
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(.red)
                            } else {
                                Button(action: {
                                    isPresented = false
                                    onLogin()
                                }) {
                                    MenuRowContent(title: "Login", systemImage: "arrow.right.circle")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
                .frame(width: min(320, proxy.size.width * 0.75), alignment: .leading)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: ChattyTheme.panelShadow, radius: 16, x: -4, y: 0)
                .padding(.vertical, 12)
                .padding(.trailing, 12)
            }
        }
        .transition(.move(edge: .trailing))
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }

    private func chatTitle(_ chat: UserProfileLanguage) -> String {
        guard let code = chat.code,
              let language = LanguageConfig.all[code] else {
            return "Chat"
        }
        if let level = chat.level, !level.isEmpty {
            return "\(language.language) \(level)"
        }
        return language.language
    }

    private func selectDestination() {
        onNavigate()
        isPresented = false
    }
}

private struct MenuSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 8)
    }
}

private struct MenuActionRow: View {
    let title: String
    let systemImage: String
    var selected: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            MenuRowContent(title: title, systemImage: systemImage, selected: selected)
        }
        .buttonStyle(.plain)
    }
}

private struct MenuLinkRow: View {
    let destination: MenuDestination
    let disabled: Bool
    let onSelect: () -> Void

    var body: some View {
        if disabled {
            MenuRowContent(title: destination.title, systemImage: destination.systemImage, locked: true)
        } else {
            NavigationLink(value: destination) {
                MenuRowContent(title: destination.title, systemImage: destination.systemImage, locked: false)
            }
            .simultaneousGesture(TapGesture().onEnded { onSelect() })
        }
    }
}

private struct MenuRowContent: View {
    let title: String
    let systemImage: String
    var locked: Bool = false
    var selected: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 20)
            Text(title)
                .font(.subheadline)
            Spacer()
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.accentColor)
            }
            if locked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11))
            }
        }
        .foregroundStyle(locked ? AnyShapeStyle(.secondary) : AnyShapeStyle(.primary))
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}

private struct InfoView: View {
    private let contactEmail = "info@chatty-pal.com"

    private let features = [
        "Engage in realistic, dynamic conversations with an AI bot to practice speaking, listening, and comprehension.",
        "Receive real-time feedback and error correction from the teacher bot to improve accuracy.",
        "Teachers can assign speaking exercises as homework for students.",
        "Students can record spoken responses and submit them for teacher review.",
        "Teachers can provide personalized feedback and guidance for further improvement.",
        "Track progress and monitor language learning achievements over time."
    ]

    private let studentSteps = [
        "Sign up for a student account and select the target language you want to practice.",
        "Start interactive conversations with the AI bot to build language confidence.",
        "Use teacher feedback and error correction to improve accuracy.",
        "Complete speaking exercises assigned by your teacher and submit recordings for evaluation.",
        "Track your progress and monitor your language learning journey."
    ]

    private let teacherSteps = [
        "Create a teacher account and set up your profile with the language or languages you teach.",
        "Assign speaking exercises with prompts or questions for students to practice.",
        "Review homework submissions and give feedback on pronunciation, fluency, and language usage.",
        "Monitor student progress over time and adapt your teaching approach accordingly."
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Chatty Pal", systemImage: "bubble.left.and.bubble.right.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                    Text("Practice languages through natural AI conversations")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text("Chatty Pal is an innovative language learning app for students and teachers. Practice real conversations, get feedback, and build confidence in your selected language.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ChattyTheme.heroGradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(ChattyTheme.softHairline, lineWidth: 1)
                )

                InfoSectionCard(title: "Key Features", systemImage: "sparkles") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(features, id: \.self) { item in
                            InfoBulletRow(text: item)
                        }
                    }
                }

                InfoSectionCard(title: "How To Use Chatty Pal", systemImage: "map") {
                    Text("Chatty Pal offers a user-friendly experience for both students and teachers.")
                        .font(.body)
                        .lineSpacing(3)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "For Students", systemImage: "person.text.rectangle") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(studentSteps.enumerated()), id: \.offset) { index, item in
                            InfoNumberedRow(number: index + 1, text: item)
                        }
                    }
                }

                InfoSectionCard(title: "For Teachers", systemImage: "graduationcap") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(teacherSteps.enumerated()), id: \.offset) { index, item in
                            InfoNumberedRow(number: index + 1, text: item)
                        }
                    }
                }

                InfoSectionCard(title: "Questions?", systemImage: "envelope") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Join Chatty Pal today and unlock your full language learning potential.")
                            .font(.body)
                            .lineSpacing(3)
                            .foregroundStyle(.secondary)
                        Link(destination: URL(string: "mailto:\(contactEmail)")!) {
                            HStack(spacing: 10) {
                                Image(systemName: "paperplane.fill")
                                Text(contactEmail)
                                    .font(.body.weight(.semibold))
                                Spacer()
                            }
                            .padding(14)
                            .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct InfoSectionCard<Content: View>: View {
    let title: String
    let systemImage: String
    let content: Content

    init(title: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: systemImage)
                .font(.headline.weight(.semibold))
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(ChattyTheme.softHairline, lineWidth: 1)
        )
    }
}

private struct InfoBulletRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .padding(.top, 2)
            Text(text)
                .font(.body)
                .lineSpacing(3)
                .foregroundStyle(.secondary)
        }
    }
}

private struct InfoNumberedRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Color.accentColor, in: Circle())
            Text(text)
                .font(.body)
                .lineSpacing(3)
                .foregroundStyle(.secondary)
        }
    }
}

private struct PolicyView: View {
    private let contactEmail = "info@chatty-pal.com"
    private let microsoftPrivacyURL = URL(string: "https://privacy.microsoft.com/en-GB/privacystatement")!

    private let collectionInfo = [
        "Personal Information: data you voluntarily provide when signing up, such as your name and email address.",
        "Non-personal Information: statistical data such as how you use the website, browsing habits, IP address, operating system, and browser type."
    ]

    private let collectionMethods = [
        "Direct Interactions: you may provide personal data when completing online forms, requesting services, or corresponding with us.",
        "Automated technologies or Interactions: we may automatically collect technical data using cookies, server logs, and other similar technologies."
    ]

    private let infoUse = [
        "Provide, maintain, and improve our services.",
        "Respond to your comments, questions, and requests and provide customer service.",
        "Communicate with you about products, services, offers, promotions, and events.",
        "Monitor and analyze trends, usage, and activities in connection with our services.",
        "Personalize and improve our services and provide advertisements, content or features that match user profiles or interests."
    ]

    private let userChoices = [
        "Cookies: you can set your browser to refuse all or some browser cookies, or to alert you when cookies are being sent.",
        "Opting Out of Google Analytics: you can opt out of tracking by visiting the Google Ads Settings page or by installing their opt-out browser add-on."
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Chatty Pal", systemImage: "lock.shield.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                    Text("Privacy Policy")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("Effective Date: June 13, 2023")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("This Privacy Policy explains how information about you is collected, used, and disclosed by your use of our Service. We respect your privacy and are committed to protecting it through our compliance with this policy.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ChattyTheme.heroGradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(ChattyTheme.softHairline, lineWidth: 1)
                )

                InfoSectionCard(title: "Information We Collect", systemImage: "tray.full") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(collectionInfo, id: \.self) { item in
                            InfoBulletRow(text: item)
                        }
                    }
                }

                InfoSectionCard(title: "Purpose of Collection", systemImage: "target") {
                    Text("We collect and store your name and email address solely to facilitate your access to our application. We also collect and store information related to your homework and exercises performed within the app. This data is used to fine-tune our conversational models, improving the user experience and the app's performance over time.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "Information Sharing and Disclosure", systemImage: "arrowshape.turn.up.right") {
                    Text("We may share information pertaining to your homework and exercises with third parties for analytical and development purposes. Your personal information, including your name and email address, will not be shared with third parties. Within the app, your name and email address will only be visible to the teacher or school when you are added to a class.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "Data Retention", systemImage: "clock") {
                    Text("We retain information related to your homework and exercises for a period of one year from the date of creation. This retention policy helps us maintain a relevant and efficient service, ensuring our conversational models remain up-to-date and effective.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "How We Collect Information", systemImage: "magnifyingglass") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(collectionMethods, id: \.self) { item in
                            InfoBulletRow(text: item)
                        }
                    }
                }

                InfoSectionCard(title: "Use of Google Analytics", systemImage: "chart.bar") {
                    Text("Our website uses Google Analytics, a web analytics service provided by Google. Google Analytics uses cookies to help analyze how users use the site. The information generated by the cookie about your use of the website (including your IP address) will be transmitted to and stored by Google on servers in the United States.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "Use of AI Technologies", systemImage: "cpu") {
                    Text("Our service utilizes advanced AI technologies including OpenAI's GPT, Google AI Tools and Fixi AI to provide some of its core functionalities. These AI technologies help us understand and interpret your queries and requests, provide responses, and offer personalized experiences.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "Gathering Homework Information for Teachers", systemImage: "person.text.rectangle") {
                    Text("If you are a student of a school, we may gather information from your homework interactions with our chat. This information is solely for the purpose of providing the teacher with the necessary data to review your progress and performance. This information is securely stored and only accessible to authorized personnel for educational purposes.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "How We Use Your Information", systemImage: "list.bullet.rectangle") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(infoUse, id: \.self) { item in
                            InfoBulletRow(text: item)
                        }
                        Text("We partner with Microsoft Clarity and Microsoft Advertising to capture how you use and interact with our website through behavioral metrics, heatmaps, and session replay to improve and market our products/services. Website usage data is captured using first and third-party cookies and other tracking technologies. For more information about how Microsoft collects and uses your data, visit the")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundStyle(.secondary)
                        Link(destination: microsoftPrivacyURL) {
                            HStack(spacing: 8) {
                                Image(systemName: "link")
                                Text("Microsoft Privacy Statement")
                                    .font(.body.weight(.semibold))
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                }

                InfoSectionCard(title: "Your Choices", systemImage: "slider.horizontal.3") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(userChoices, id: \.self) { item in
                            InfoBulletRow(text: item)
                        }
                    }
                }

                InfoSectionCard(title: "User Rights", systemImage: "person.crop.circle.badge.checkmark") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("You have the right to delete your profile from our platform at any time. Upon deletion, your identity will be disassociated from the homework and exercise data; however, the data itself will not be deleted. On special request, we can also remove all the data you have created.")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundStyle(.secondary)
                        Text("Note: data used to fine-tune our model will not be removed, although we will delete all your conversation records from our database. To process this, you will need to send us an email from the email address associated with your account, detailing your request.")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundStyle(.secondary)
                        Link(destination: URL(string: "mailto:\(contactEmail)")!) {
                            HStack(spacing: 10) {
                                Image(systemName: "paperplane.fill")
                                Text(contactEmail)
                                    .font(.body.weight(.semibold))
                                Spacer()
                            }
                            .padding(14)
                            .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                }

                InfoSectionCard(title: "Changes to this Policy", systemImage: "clock.arrow.circlepath") {
                    Text("We may update our privacy policy from time to time. You are advised to review this page periodically for any changes. We will notify you by email of any changes by posting the new privacy policy on this page. These changes are effective immediately after they are posted.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                }

                InfoSectionCard(title: "Contact Us", systemImage: "envelope") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us.")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundStyle(.secondary)
                        Link(destination: URL(string: "mailto:\(contactEmail)")!) {
                            HStack(spacing: 10) {
                                Image(systemName: "paperplane.fill")
                                Text(contactEmail)
                                    .font(.body.weight(.semibold))
                                Spacer()
                            }
                            .padding(14)
                            .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Learning Materials

private enum LearningMaterialsDestination: Hashable {
    case germanList
    case lesson(LearningLesson)
}

private struct LearningMaterialsHomeView: View {
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

private struct HomeworkListView: View {
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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dismiss) private var dismiss

    @State private var currentStatus: HomeworkStatus
    @State private var engine: ChatEngine
    @State private var isStarting = false
    @State private var startError: String?
    @State private var isFinishing = false
    @State private var finishError: String?
    @State private var inputText = ""
    @State private var inputHeight: CGFloat = 44
    @State private var isPulsing = false

    private let inputMaxHeight: CGFloat = 140

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

                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            if currentStatus == .new {
                                startCard
                            } else if engine.messages.isEmpty {
                                emptyState
                            }

                            ForEach(engine.messages) { message in
                                MessageView(
                                    message: message,
                                    onTeacherTap: { engine.speak(message.message) },
                                    onReplayTap: { engine.speak(message.message) },
                                    onTranslateTap: { Task { await engine.translate(message.message) } },
                                    onSuggestTap: { Task { await engine.suggest(for: message.message) } }
                                )
                                .id(message.id)
                            }

                            if engine.isGenerating {
                                ProgressView("Thinking...")
                                    .font(.footnote)
                                    .padding(.vertical, 8)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .onChange(of: engine.messages.count) { _ in
                        withAnimation(.easeInOut(duration: 0.25)) {
                            if let lastID = engine.messages.last?.id {
                                proxy.scrollTo(lastID, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        if let lastID = engine.messages.last?.id {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }

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
        Group {
            if horizontalSizeClass == .compact {
                HStack {
                    Spacer()
                    Button(action: { engine.toggleRecording() }) {
                        Image(systemName: engine.isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(engine.isRecording ? Color.red : Color.accentColor)
                            .frame(width: 69, height: 69)
                            .background(.thinMaterial, in: Circle())
                            .overlay(Circle().stroke(ChattyTheme.softHairline, lineWidth: 1))
                            .overlay(
                                Circle()
                                    .stroke(Color.red.opacity(0.35), lineWidth: 2)
                                    .scaleEffect(isPulsing ? 1.35 : 0.9)
                                    .opacity(isPulsing ? 0 : 0.35)
                            )
                    }
                    .onAppear { if engine.isRecording { startPulse() } }
                    .onChange(of: engine.isRecording) { recording in
                        if recording { startPulse() } else { isPulsing = false }
                    }
                    Spacer()
                }
                .padding(.vertical, 6)
                .modifier(GlassPanelModifier())
            } else {
                HStack(spacing: 8) {
                    ZStack(alignment: .leading) {
                        if inputText.isEmpty {
                            Text("Type a message...")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 8)
                        }

                        TextEditor(text: $inputText)
                            .font(.body)
                            .frame(minHeight: 44, maxHeight: min(inputHeight, inputMaxHeight))
                            .background(InputHeightReader(text: inputText))
                            .onPreferenceChange(InputHeightKey.self) { height in
                                inputHeight = max(44, height + 16)
                            }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 6)

                    Button(action: { engine.toggleRecording() }) {
                        Image(systemName: engine.isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(engine.isRecording ? Color.red : Color.accentColor)
                    }

                    Button(action: sendInput) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.secondary : Color.accentColor)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .modifier(GlassPanelModifier())
            }
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

private struct PlaceholderView: View {
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title2.weight(.semibold))
            Text("Placeholder page")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ChattyTheme.appBackground)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SettingsSheet: View {
    @AppStorage("langCode") private var langCode: String = "de"
    @AppStorage("level") private var level: String = "B1"
    @AppStorage("appEnvironment") private var appEnvironment: String = AppEnvironmentMode.production.rawValue
    @AppStorage("localWebBaseURL") private var localWebBaseURL: String = AppEnvironment.defaultLocalWebBaseURL
    @AppStorage("localCMSAPIBaseURL") private var localCMSAPIBaseURL: String = AppEnvironment.defaultLocalCMSAPIBaseURL

    var body: some View {
        NavigationStack {
            Form {
                Section("Server") {
                    Picker("Environment", selection: $appEnvironment) {
                        ForEach(AppEnvironmentMode.allCases) { mode in
                            Text(mode.title).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)

                    if appEnvironment == AppEnvironmentMode.local.rawValue {
                        TextField("Web URL", text: $localWebBaseURL)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                        TextField("CMS API URL", text: $localCMSAPIBaseURL)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                        Text("On a real iPhone, use your Mac's LAN IP, for example http://192.168.1.20:3000 and http://192.168.1.20:1337/api.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        LabeledContent("Web", value: AppEnvironment.productionWebBaseURL.absoluteString)
                        LabeledContent("CMS", value: AppEnvironment.productionCMSAPIBaseURL.absoluteString)
                    }
                }

                Section("Practice") {
                    Picker("Language", selection: $langCode) {
                        ForEach(LanguageConfig.sorted) { language in
                            Text(language.language).tag(language.code)
                        }
                    }

                    Picker("Level", selection: $level) {
                        ForEach(LanguageConfig.levels, id: \.self) { lvl in
                            Text(lvl).tag(lvl)
                        }
                    }
                }

                Section("Current persona") {
                    let l = LanguageConfig.all[langCode] ?? LanguageConfig.default
                    LabeledContent("Voice", value: l.voice)
                    LabeledContent("Country", value: l.country)
                    LabeledContent("Speech locale", value: l.speechLocale)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
