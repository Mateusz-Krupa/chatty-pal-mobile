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

// Word-level diff (common prefix + suffix, case/punctuation insensitive).
enum TextDiffer {
    enum SegmentKind: Hashable {
        case same
        case removed
        case added
    }

    struct Segment: Hashable {
        let text: String
        let kind: SegmentKind
    }

    private static func normalize(_ word: String) -> String {
        word.lowercased().trimmingCharacters(in: CharacterSet.punctuationCharacters)
    }

    static func diff(original: String, corrected: String) -> [Segment] {
        let a = original.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        let b = corrected.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        var prefix = 0
        while prefix < a.count, prefix < b.count, normalize(a[prefix]) == normalize(b[prefix]) {
            prefix += 1
        }
        var suffix = 0
        while suffix < a.count - prefix, suffix < b.count - prefix,
              normalize(a[a.count - 1 - suffix]) == normalize(b[b.count - 1 - suffix]) {
            suffix += 1
        }
        var segments: [Segment] = []
        if prefix > 0 {
            segments.append(Segment(text: a[..<prefix].joined(separator: " "), kind: .same))
        }
        if prefix < a.count - suffix {
            segments.append(Segment(text: a[prefix..<(a.count - suffix)].joined(separator: " "), kind: .removed))
        }
        if prefix < b.count - suffix {
            segments.append(Segment(text: b[prefix..<(b.count - suffix)].joined(separator: " "), kind: .added))
        }
        if suffix > 0 {
            segments.append(Segment(text: b[(b.count - suffix)...].joined(separator: " "), kind: .same))
        }
        return segments
    }
}

struct MessageView: View {
    let message: ChatMessage
    var originalText: String? = nil
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

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 6) {
                bubble

                if message.role == .user, let correction = message.correction, !correction.isEmpty {
                    correctionRow(original: message.message, corrected: correction)
                }
            }

            if message.role == .user {
                AvatarView(role: message.role)
            } else {
                Spacer()
            }
        }
    }

    private var bubble: some View {
        VStack(alignment: .leading, spacing: 6) {
            messageText
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
    }

    private func correctionRow(original: String, corrected: String) -> some View {
        diffText(original: original, corrected: corrected)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(ChattyTheme.rowFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(ChattyTheme.softHairline, lineWidth: 1)
            )
            .accessibilityLabel("Correction: \(corrected)")
    }

    @ViewBuilder
    private var messageText: some View {
        if message.role == .teacher, let original = originalText, !original.isEmpty {
            diffText(original: original, corrected: message.message)
        } else {
            Text(message.message)
        }
    }

    private func diffText(original: String, corrected: String) -> Text {
        var text = Text(verbatim: "")
        for (index, segment) in TextDiffer.diff(original: original, corrected: corrected).enumerated() {
            if index > 0 {
                text = text + Text(verbatim: " ")
            }
            switch segment.kind {
            case .same:
                text = text + Text(verbatim: segment.text)
            case .removed:
                text = text + Text(verbatim: segment.text).strikethrough().foregroundColor(.secondary)
            case .added:
                text = text + Text(verbatim: segment.text).bold().foregroundColor(.orange)
            }
        }
        return text
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
