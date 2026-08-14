import SwiftUI
import UIKit

struct ChattyTheme {
    static var appBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(UIColor { traits in
                    traits.userInterfaceStyle == .dark
                        ? UIColor(red: 0.055, green: 0.065, blue: 0.090, alpha: 1)
                        : UIColor(red: 0.970, green: 0.980, blue: 1.000, alpha: 1)
                }),
                Color(UIColor { traits in
                    traits.userInterfaceStyle == .dark
                        ? UIColor(red: 0.030, green: 0.040, blue: 0.060, alpha: 1)
                        : UIColor(red: 0.940, green: 0.960, blue: 0.990, alpha: 1)
                }),
                Color(UIColor { traits in
                    traits.userInterfaceStyle == .dark
                        ? UIColor(red: 0.020, green: 0.025, blue: 0.040, alpha: 1)
                        : UIColor(red: 0.980, green: 0.990, blue: 1.000, alpha: 1)
                })
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [Color.accentColor.opacity(0.20), elevatedFill.opacity(0.92)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardFill: Color { Color(.secondarySystemGroupedBackground) }
    static var elevatedFill: Color { Color(.tertiarySystemGroupedBackground) }
    static var hairline: Color { Color(.separator).opacity(0.65) }
    static var softHairline: Color { Color(.separator).opacity(0.35) }
    static var overlayScrim: Color {
        Color(UIColor { traits in
            UIColor.black.withAlphaComponent(traits.userInterfaceStyle == .dark ? 0.45 : 0.25)
        })
    }
    static var panelShadow: Color {
        Color(UIColor { traits in
            UIColor.black.withAlphaComponent(traits.userInterfaceStyle == .dark ? 0.30 : 0.15)
        })
    }
    static var assistantBubble: Color { Color(.secondarySystemGroupedBackground) }
    static var rowFill: Color { Color(.tertiarySystemGroupedBackground).opacity(0.85) }

    static var teacherBubble: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.42, green: 0.27, blue: 0.06, alpha: 1)
                : UIColor(red: 1.00, green: 0.91, blue: 0.55, alpha: 1)
        })
    }

    static var translationBubble: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.08, green: 0.31, blue: 0.18, alpha: 1)
                : UIColor(red: 0.78, green: 0.95, blue: 0.84, alpha: 1)
        })
    }

    static var suggestionBubble: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.23, green: 0.16, blue: 0.42, alpha: 1)
                : UIColor(red: 0.89, green: 0.84, blue: 1.00, alpha: 1)
        })
    }
}

struct MessageView: View {
    let message: ChatMessage
    let onTeacherTap: () -> Void
    let onReplayTap: () -> Void
    let onTranslateTap: () -> Void
    let onSuggestTap: () -> Void

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }

            if message.role != .user {
                AvatarView(role: message.role)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(message.message)
                    .foregroundColor(message.role == .user ? Color.white : Color.primary)

                if message.role == .teacher {
                    Text("Tap to hear")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if message.role == .assistant {
                    HStack(spacing: 8) {
                        Button("Replay") {
                            onReplayTap()
                        }
                        .font(.caption)

                        Button("Translate") {
                            onTranslateTap()
                        }
                        .font(.caption)

                        Button("Help") {
                            onSuggestTap()
                        }
                        .font(.caption)
                    }
                }
            }
            .padding(12)
            .background(
                bubbleColor(for: message.role),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(ChattyTheme.softHairline, lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                if message.role == .teacher {
                    onTeacherTap()
                }
            }

            if message.role == .user {
                AvatarView(role: message.role)
            } else {
                Spacer()
            }
        }
    }

    private func bubbleColor(for role: ChatMessage.Role) -> Color {
        switch role {
        case .user:
            return Color.accentColor.opacity(0.9)
        case .teacher:
            return ChattyTheme.teacherBubble
        case .translation:
            return ChattyTheme.translationBubble
        case .suggestion:
            return ChattyTheme.suggestionBubble
        default:
            return ChattyTheme.assistantBubble
        }
    }
}

private struct AvatarView: View {
    let role: ChatMessage.Role

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
            Image(systemName: symbolName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: 28, height: 28)
        .overlay(
            Circle()
                .stroke(ChattyTheme.softHairline, lineWidth: 1)
        )
        .accessibilityLabel(accessibilityLabel)
    }

    private var symbolName: String {
        switch role {
        case .user:
            return "person.fill"
        case .assistant:
            return "sparkles"
        case .teacher:
            return "graduationcap.fill"
        case .translation:
            return "globe"
        case .suggestion:
            return "lightbulb.fill"
        case .system:
            return "gearshape.fill"
        }
    }

    private var backgroundColor: Color {
        switch role {
        case .user:
            return Color.accentColor
        case .assistant:
            return Color.blue.opacity(0.8)
        case .teacher:
            return Color.orange.opacity(0.8)
        case .translation:
            return Color.green.opacity(0.7)
        case .suggestion:
            return Color.purple.opacity(0.7)
        case .system:
            return Color.gray.opacity(0.6)
        }
    }

    private var accessibilityLabel: String {
        switch role {
        case .user:
            return "User"
        case .assistant:
            return "Assistant"
        case .teacher:
            return "Teacher"
        case .translation:
            return "Translation"
        case .suggestion:
            return "Suggestions"
        case .system:
            return "System"
        }
    }
}
