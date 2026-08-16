import Foundation

struct HomeworkChatStore: ChatStore {
    private let seed: [ChatMessage]

    init(homeworkMessages: [HomeworkMessage]) {
        seed = HomeworkMessageMapper.toChatMessages(homeworkMessages)
    }

    func load() -> [ChatMessage] {
        seed
    }

    func save(_ messages: [ChatMessage]) {}
}

enum HomeworkMessageMapper {
    static func toChatMessages(_ messages: [HomeworkMessage]) -> [ChatMessage] {
        var result: [ChatMessage] = []
        for msg in messages {
            let role: ChatMessage.Role
            switch msg.role {
            case "user":
                role = .user
            case "assistant":
                role = .assistant
            case "system":
                if msg.author == "Teacher" {
                    role = .teacher
                } else {
                    continue
                }
            case "teacher":
                role = .teacher
            case "translation":
                role = .translation
            case "suggestion":
                role = .suggestion
            default:
                continue
            }
            let content = msg.content ?? ""
            if content.isEmpty { continue }
            result.append(ChatMessage(role: role, message: content))
        }
        return result
    }

    static func toHomeworkMessages(_ messages: [ChatMessage], voice: String) -> [HomeworkMessage] {
        messages.map { msg in
            let role: String
            let author: String
            switch msg.role {
            case .user:
                role = "user"
                author = "Me"
            case .assistant:
                role = "assistant"
                author = voice
            case .teacher:
                role = "system"
                author = "Teacher"
            case .system:
                role = "system"
                author = "SYSTEM"
            case .translation:
                role = "translation"
                author = "Translation"
            case .suggestion:
                role = "suggestion"
                author = "Help"
            }
            return HomeworkMessage(role: role, content: msg.message, author: author)
        }
    }
}
