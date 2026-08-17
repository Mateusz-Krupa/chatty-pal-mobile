import SwiftUI

struct WordReviewView: View {
    @State private var store = WordReviewStore.shared
    @State private var session: [ReviewWord] = []
    @State private var revealed = false
    @State private var reviewedCount = 0
    @State private var finished = false

    var body: some View {
        Group {
            if finished {
                completion
            } else if session.isEmpty {
                emptyState
            } else {
                reviewCard
            }
        }
        .onAppear {
            if session.isEmpty {
                session = store.dueSession()
            }
        }
    }

    private var current: ReviewWord { session[0] }

    private var reviewCard: some View {
        VStack(spacing: 20) {
            HStack {
                Text("\(reviewedCount) of \(reviewedCount + session.count - 1)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    session = []
                    finished = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 4)

            VStack(spacing: 14) {
                HStack(spacing: 10) {
                    Text(current.german)
                        .font(.system(size: 30, weight: .semibold))
                        .multilineTextAlignment(.center)
                    Button {
                        ExamTTS.speak(current.german)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.accentColor)
                    }
                }

                if let example = current.example {
                    Text(example)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if revealed {
                    Text(current.english)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Color.accentColor)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                } else {
                    Text("Tap to reveal")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 220)
            .padding(24)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(ChattyTheme.softHairline, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.15)) {
                    revealed.toggle()
                }
            }
            .id(current.id)

            if revealed {
                HStack(spacing: 10) {
                    gradeButton("Again", systemImage: "arrow.uturn.backward", color: .red) {
                        grade(.again)
                    }
                    gradeButton("Good", systemImage: "checkmark", color: Color.accentColor) {
                        grade(.good)
                    }
                    gradeButton("Easy", systemImage: "checkmark.circle", color: .green) {
                        grade(.easy)
                    }
                }
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        revealed = true
                    }
                } label: {
                    Text("Show answer")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private func gradeButton(_ title: String, systemImage: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.bordered)
        .tint(color)
    }

    private func grade(_ grade: WordReviewGrade) {
        ExamTTS.stop()
        store.grade(wordID: current.id, grade: grade)
        LearningStatsStore.shared.recordReviewGrade()
        reviewedCount += 1
        session.removeFirst()
        revealed = false
        if session.isEmpty {
            finished = true
        }
    }

    private var completion: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 52))
                .foregroundStyle(.green)
            Text("Session complete")
                .font(.title2.weight(.semibold))
            Text("You reviewed \(reviewedCount) words.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if store.dueCount > 0 {
                Text("\(store.dueCount) more words are due — come back a bit later.")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
            Button {
                session = []
                reviewedCount = 0
                finished = false
            } label: {
                Text("Done")
                    .font(.body.weight(.semibold))
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("All caught up")
                .font(.title3.weight(.semibold))
            Text("Nothing due right now.\nNew words arrive from your lessons and exam prep.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
    }
}
