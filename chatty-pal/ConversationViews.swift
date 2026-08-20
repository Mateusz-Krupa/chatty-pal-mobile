import SwiftUI

struct ConversationListView: View {
    let onSelect: (Conversation) -> Void

    private var store: ConversationStore { .shared }

    var body: some View {
        Group {
            if store.sorted.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(store.sorted) { conversation in
                        Button {
                            onSelect(conversation)
                        } label: {
                            row(conversation)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .background(ChattyTheme.appBackground)
        .navigationTitle("My chats")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No conversations yet")
                .font(.headline)
            Text("Start chatting and your conversations will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }

    private func row(_ conversation: Conversation) -> some View {
        let language = LanguageConfig.all[conversation.languageCode]?.language ?? conversation.languageCode
        let lastMessage = conversation.messages.last?.message ?? "No messages yet"
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(conversation.title)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                if conversation.completed && conversation.kind == .rolePlay {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                Spacer()
                Text(conversation.updatedAt, format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 6) {
                Text("\(language) \(conversation.level)")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.12), in: Capsule())
                Text(lastMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 6)
    }
}
