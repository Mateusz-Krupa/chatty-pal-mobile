import SwiftUI
import WebKit

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

struct LoginPanel: View {
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


