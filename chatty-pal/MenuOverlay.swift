import SwiftUI

struct MenuOverlay: View {
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
                            MenuLinkRow(destination: .examPrep, disabled: false) { selectDestination() }

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

enum MenuDestination: Hashable {
    case userPanel
    case chat
    case info
    case policy
    case homework
    case teacherHelp
    case learningMaterials
    case examPrep
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
        case .examPrep:
            return "Exam Prep A1"
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
        case .examPrep:
            return "checkmark.seal"
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
