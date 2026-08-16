import SwiftUI

struct InfoView: View {
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

struct InfoSectionCard<Content: View>: View {
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

struct InfoBulletRow: View {
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

struct InfoNumberedRow: View {
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

