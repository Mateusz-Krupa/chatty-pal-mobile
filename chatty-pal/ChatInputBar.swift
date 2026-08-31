import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    let isRecording: Bool
    let isPulsing: Bool
    var isVoiceLocked: Bool = false
    let onToggleRecording: () -> Void
    let onSend: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var inputHeight: CGFloat = 44
    private let inputMaxHeight: CGFloat = 140

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                HStack {
                    Spacer()
                    compactMicButton
                    Spacer()
                }
                .padding(.vertical, 6)
                .modifier(GlassPanelModifier())
            } else {
                HStack(spacing: 8) {
                    ZStack(alignment: .leading) {
                        if text.isEmpty {
                            Text("Type a message...")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 8)
                        }

                        TextEditor(text: $text)
                            .font(.body)
                            .frame(minHeight: 44, maxHeight: min(inputHeight, inputMaxHeight))
                            .background(InputHeightReader(text: text))
                            .onPreferenceChange(InputHeightKey.self) { height in
                                inputHeight = max(44, height + 16)
                            }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 6)

                    wideMicButton

                    sendButton
                }
                .modifier(GlassPanelModifier())
            }
        }
    }

    private var compactMicButton: some View {
        Button(action: onToggleRecording) {
            Image(systemName: isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(isRecording ? Color.red : Color.accentColor)
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
                    .opacity(isVoiceLocked ? 0.4 : 1)
                    .disabled(isVoiceLocked)
        }
    }

    private var wideMicButton: some View {
        Button(action: onToggleRecording) {
            Image(systemName: isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(isRecording ? Color.red : Color.accentColor)
        }
        .opacity(isVoiceLocked ? 0.4 : 1)
        .disabled(isVoiceLocked)
    }

    private var sendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(
                    text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color.secondary
                        : Color.accentColor
                )
        }
        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
}

struct ChatMessageList<TopContent: View>: View {
    let messages: [ChatMessage]
    let isGenerating: Bool
    let onSpeak: (ChatMessage) -> Void
    let onTranslate: (ChatMessage) -> Void
    let onSuggest: (ChatMessage) -> Void
    let topContent: TopContent

    init(
        messages: [ChatMessage],
        isGenerating: Bool,
        onSpeak: @escaping (ChatMessage) -> Void,
        onTranslate: @escaping (ChatMessage) -> Void,
        onSuggest: @escaping (ChatMessage) -> Void,
        @ViewBuilder topContent: () -> TopContent
    ) {
        self.messages = messages
        self.isGenerating = isGenerating
        self.onSpeak = onSpeak
        self.onTranslate = onTranslate
        self.onSuggest = onSuggest
        self.topContent = topContent()
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    topContent

                    ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                        MessageView(
                            message: message,
                            originalText: message.role == .teacher ? precedingUserText(before: index) : nil,
                            onTeacherTap: { onSpeak(message) },
                            onReplayTap: { onSpeak(message) },
                            onTranslateTap: { onTranslate(message) },
                            onSuggestTap: { onSuggest(message) }
                        )
                        .id(message.id)
                    }

                    if isGenerating {
                        ProgressView("Thinking...")
                            .font(.footnote)
                            .padding(.vertical, 8)
                    }

                    Color.clear.frame(height: 1).id("chat-bottom")
                }
                .padding(.vertical, 8)
            }
            .onChange(of: messages.count) { _ in
                scrollToBottom(proxy)
            }
            .onChange(of: messages.last?.message) { _ in
                scrollToBottom(proxy)
            }
            .onChange(of: isGenerating) { _ in
                scrollToBottom(proxy)
            }
            .onAppear {
                if !messages.isEmpty {
                    proxy.scrollTo("chat-bottom", anchor: .bottom)
                }
            }
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeInOut(duration: 0.25)) {
            proxy.scrollTo("chat-bottom", anchor: .bottom)
        }
    }

    private func precedingUserText(before index: Int) -> String? {
        messages[..<index].last(where: { $0.role == .user })?.message
    }
}

struct SuggestionChipsView: View {
    let suggestions: [String]
    let onSend: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        onSend(suggestion)
                    } label: {
                        Text(suggestion)
                            .font(.footnote)
                            .lineLimit(1)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.thinMaterial, in: Capsule())
                            .overlay(Capsule().stroke(ChattyTheme.softHairline, lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct GlassPanelModifier: ViewModifier {
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

struct InputHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 44

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct InputHeightReader: View {
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
