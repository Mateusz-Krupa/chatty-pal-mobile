import SwiftUI

// MARK: - Navigation values

struct CampaignLessonRoute: Hashable {
    let lesson: CampaignLesson
}

struct CampaignCheckpointRoute: Hashable {
    let checkpoint: CampaignCheckpoint
}

struct CampaignFinalExamRoute: Hashable {
    let exam: CampaignFinalExam
}

// MARK: - Campaign home (route)

struct ExamCampaignHomeView: View {
    @ObservedObject private var progress = ExamCampaignProgress.shared

    private var currentNode: (zone: CampaignZone, node: CampaignNode)? {
        progress.currentNode()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                continueCard
                ForEach(ExamCampaignCatalog.zones) { zone in
                    zoneCard(zone)
                }
            }
            .padding(16)
        }
        .background(ChattyTheme.appBackground.ignoresSafeArea())
        .navigationTitle("Exam Prep A1")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: CampaignLessonRoute.self) { route in
            ExamCampaignMissionView(lesson: route.lesson)
        }
        .navigationDestination(for: CampaignCheckpointRoute.self) { route in
            ExamCampaignCheckpointView(checkpoint: route.checkpoint)
        }
        .navigationDestination(for: CampaignFinalExamRoute.self) { route in
            ExamCampaignFinalExamView(exam: route.exam)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Goethe-Zertifikat A1")
                .font(.system(size: 28, weight: .semibold))
            Text("Follow the campaign: finish missions, pass checkpoints, and finish the mixed practice test.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var continueCard: some View {
        if let current = currentNode {
            continueLink(for: current.node) {
                HStack(spacing: 14) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 44, height: 44)
                        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Continue: \(title(for: current.node))")
                            .font(.headline)
                        Text(zoneName(for: current.node))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(ChattyTheme.softHairline, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Continue to \(title(for: current.node))")
        }
    }

    @ViewBuilder
    private func continueLink<C: View>(for node: CampaignNode, @ViewBuilder content: () -> C) -> some View {
        switch node {
        case .lesson(let lesson):
            NavigationLink(value: CampaignLessonRoute(lesson: lesson)) { content() }
        case .checkpoint(let checkpoint):
            NavigationLink(value: CampaignCheckpointRoute(checkpoint: checkpoint)) { content() }
        case .finalExam(let exam):
            NavigationLink(value: CampaignFinalExamRoute(exam: exam)) { content() }
        }
    }

    private func zoneCard(_ zone: CampaignZone) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text("Zone \(zone.order)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.accentColor.opacity(0.12), in: Capsule())
                Text(zone.title)
                    .font(.headline)
                Spacer()
                Text("\(progress.completedCount(in: zone)) / \(zone.lessons.count)")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text(zone.goal)
                .font(.footnote)
                .foregroundStyle(.secondary)

            ForEach(zone.nodes) { node in
                nodeRow(zone: zone, node: node)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(ChattyTheme.softHairline, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func nodeRow(zone: CampaignZone, node: CampaignNode) -> some View {
        let isCurrent = currentNode?.node.id == node.id
        let completed = isComplete(node)
        let unlocked = isUnlocked(node)
        let state: NodeState = completed ? .completed : (isCurrent && unlocked) ? .current : (unlocked ? .available : .locked)

        switch (state, node) {
        case (_, .lesson(let lesson)) where state != .locked:
            NavigationLink(value: CampaignLessonRoute(lesson: lesson)) {
                rowContent(node: node, state: state)
            }
            .buttonStyle(.plain)
        case (_, .checkpoint(let checkpoint)) where state != .locked:
            NavigationLink(value: CampaignCheckpointRoute(checkpoint: checkpoint)) {
                rowContent(node: node, state: state)
            }
            .buttonStyle(.plain)
        case (_, .finalExam(let exam)) where state != .locked:
            NavigationLink(value: CampaignFinalExamRoute(exam: exam)) {
                rowContent(node: node, state: state)
            }
            .buttonStyle(.plain)
        default:
            rowContent(node: node, state: .locked)
                .opacity(0.5)
                .accessibilityLabel("Locked. Finish earlier missions to unlock.")
        }
    }

    private func rowContent(node: CampaignNode, state: NodeState) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon(for: node, state: state))
                .font(.title3)
                .foregroundStyle(state.color)
                .frame(width: 34, height: 34)
                .background(state.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title(for: node))
                    .font(.subheadline.weight(.semibold))
                Text(subtitle(for: node, state: state))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if state == .completed, let stars = stars(for: node), stars > 0 {
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < stars ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundStyle(index < stars ? Color.orange : ChattyTheme.hairline)
                    }
                }
                .accessibilityLabel("\(stars) of 3 stars")
            }
        }
        .padding(10)
        .background(
            state == .current ? Color.accentColor.opacity(0.08) : Color.clear,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(state == .current ? Color.accentColor.opacity(0.5) : ChattyTheme.softHairline, lineWidth: 1)
        )
    }

    // MARK: - Node helpers

    private enum NodeState {
        case completed
        case current
        case available
        case locked

        var color: Color {
            switch self {
            case .completed: return .green
            case .current: return .accentColor
            case .available: return .secondary
            case .locked: return .gray
            }
        }
    }

    private func title(for node: CampaignNode) -> String {
        switch node {
        case .lesson(let lesson): return lesson.title
        case .checkpoint(let checkpoint): return checkpoint.title
        case .finalExam(let exam): return exam.title
        }
    }

    private func subtitle(for node: CampaignNode, state: NodeState) -> String {
        switch node {
        case .lesson(let lesson):
            if state == .locked { return "Locked" }
            return lesson.goal
        case .checkpoint(let checkpoint):
            if state == .locked { return "Locked" }
            return checkpoint.description
        case .finalExam(let exam):
            if state == .locked { return "Locked" }
            return exam.description
        }
    }

    private func zoneName(for node: CampaignNode) -> String {
        switch node {
        case .lesson(let lesson):
            return ExamCampaignCatalog.zone(id: lesson.zoneID)?.title ?? ""
        case .checkpoint(let checkpoint):
            return ExamCampaignCatalog.zone(id: checkpoint.zoneID)?.title ?? ""
        case .finalExam:
            return "Final Preparation"
        }
    }

    private func icon(for node: CampaignNode, state: NodeState) -> String {
        if state == .locked { return "lock.fill" }
        if state == .completed { return "checkmark.circle.fill" }
        if state == .current { return "play.circle.fill" }
        switch node {
        case .lesson: return "book.fill"
        case .checkpoint: return "flag.checkered"
        case .finalExam: return "trophy.fill"
        }
    }

    private func isComplete(_ node: CampaignNode) -> Bool {
        progress.isComplete(node.id)
    }

    private func isUnlocked(_ node: CampaignNode) -> Bool {
        switch node {
        case .lesson(let lesson): return progress.isLessonUnlocked(lesson)
        case .checkpoint(let checkpoint): return progress.isCheckpointUnlocked(checkpoint)
        case .finalExam: return progress.isFinalExamUnlocked()
        }
    }

    private func stars(for node: CampaignNode) -> Int? {
        switch node {
        case .lesson(let lesson): return progress.bestStars(lesson.id)
        default: return nil
        }
    }
}

// MARK: - Mission (lesson)

struct ExamCampaignMissionView: View {
    let lesson: CampaignLesson
    @ObservedObject private var progress = ExamCampaignProgress.shared
    @State private var plan: MissionPlan
    @State private var stepIndex = 0
    @State private var selected: [String: Int] = [:]
    @State private var checked: Set<String> = []
    @State private var spoke = false
    @State private var wrote = false

    init(lesson: CampaignLesson) {
        self.lesson = lesson
        _plan = State(initialValue: MissionPlan(lesson: lesson))
    }

    private var allExercises: [ExamExercise] {
        lesson.exercises + lesson.readingExercises
    }

    private var correctCount: Int {
        allExercises.filter { checked.contains($0.id) && selected[$0.id] == $0.correctIndex }.count
    }

    private var checkedCount: Int {
        allExercises.filter { checked.contains($0.id) }.count
    }

    private var result: MissionResult {
        MissionResult(
            stars: MissionStars.stars(
                correct: correctCount,
                totalExercises: allExercises.count,
                spoke: spoke,
                hasSpeakingTask: lesson.speaking != nil,
                wrote: wrote,
                hasWritingTask: lesson.writingPrompt != nil
            ),
            correctCount: correctCount,
            exerciseCount: allExercises.count,
            completedSpeaking: spoke,
            completedWriting: wrote
        )
    }

    private var currentStep: MissionStep {
        plan.steps[min(stepIndex, plan.steps.count - 1)]
    }

    private var isLastStep: Bool {
        stepIndex >= plan.steps.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            ProgressView(value: Double(stepIndex), total: Double(max(plan.steps.count - 1, 1)))
                .tint(Color.accentColor)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch currentStep {
                    case .briefing:
                        briefing
                    case .vocabulary, .grammar, .phrases, .dialogue:
                        preparation
                    case .exercises, .examTask:
                        exercises
                    case .writing:
                        writing
                    case .speaking:
                        speaking
                    case .outcome:
                        outcome
                    }
                }
                .padding(16)
            }

            HStack(spacing: 10) {
                if stepIndex > 0 && currentStep != .outcome {
                    Button("Back") {
                        withAnimation { stepIndex -= 1 }
                    }
                    .font(.subheadline.weight(.semibold))
                }
                Spacer()
                if currentStep == .outcome {
                    if isCompleteCandidate {
                        if let next = nextMissionTitle {
                            Text(next)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Button("Close") { dismiss() }
                            .font(.subheadline.weight(.semibold))
                        Button("Complete") { completeMission() }
                            .font(.subheadline.weight(.semibold))
                            .buttonStyle(.borderedProminent)
                    } else {
                        Button("Close") { dismiss() }
                            .font(.subheadline.weight(.semibold))
                        Button("Replay") {
                            resetMission()
                        }
                        .font(.subheadline.weight(.semibold))
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    Button(action: advance) {
                        Text(currentStep == .exercises || currentStep == .examTask
                             ? (isLastStep ? "Finish mission" : "Next")
                             : (isLastStep ? "Finish mission" : "Continue"))
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(12)
            .background(.bar)
        }
        .background(ChattyTheme.appBackground.ignoresSafeArea())
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @Environment(\.dismiss) private var dismiss

    private var nextMissionTitle: String? {
        guard let current = progress.currentNode() else { return "Campaign complete — great work!" }
        switch current.node {
        case .lesson(let next): return "Next: \(next.title)"
        case .checkpoint(let cp): return "Next: \(cp.title)"
        case .finalExam(let exam): return "Next: \(exam.title)"
        }
    }

    private func resetMission() {
        stepIndex = 0
        selected = [:]
        checked = []
        spoke = false
        wrote = false
    }

    private var isCompleteCandidate: Bool {
        MissionCompletion.canCompleteLesson(lesson: lesson, correct: correctCount,
                                            checkedCount: checkedCount, spoke: spoke, wrote: wrote)
    }

    /// What still blocks completion, phrased as evidence expectations (not screen visits).
    private var completionHint: String {
        var missing: [String] = []
        let total = allExercises.count
        if total > 0 {
            if checkedCount < total {
                missing.append("Answer and check all \(total) exercises (\(checkedCount) checked)")
            } else if correctCount * 10 < total * 8 {
                missing.append("Reach 80% correct (now \(correctCount)/\(total))")
            }
        }
        if lesson.speaking != nil && !spoke {
            missing.append("Finish the speaking task with at least one spoken or typed answer")
        }
        if lesson.writingPrompt != nil && !wrote {
            missing.append("Submit your writing and get feedback")
        }
        return missing.joined(separator: " · ")
    }

    private func advance() {
        if currentStep == .exercises || currentStep == .examTask {
            for exercise in allExercises where selected[exercise.id] != nil {
                checked.insert(exercise.id)
            }
        }
        // Outcome renders `result` live, so the stars shown before saving are always the
        // same values `completeMission()` records — no stale intermediate state.
        withAnimation { stepIndex = min(stepIndex + 1, plan.steps.count - 1) }
    }

    private func completeMission() {
        guard isCompleteCandidate else { return }
        let outcome = result
        progress.record(outcome, for: lesson.id)
        addWordsToReview()
        dismiss()
    }

    private func addWordsToReview() {
        let store = WordReviewStore.shared
        let source = "campaign:\(lesson.id)"
        for item in lesson.vocabulary {
            store.add(german: item.german, english: item.english, example: item.example, source: source)
        }
        for phrase in lesson.phrases {
            store.add(german: phrase.german, english: phrase.english, example: nil, source: source)
        }
    }

    // MARK: - Steps

    private var briefing: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "target")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mission goal")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                    Text(lesson.goal)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            card(title: "Mission plan") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(plan.steps.enumerated()), id: \.offset) { index, step in
                        Label(stepTitle(step), systemImage: stepIcon(step))
                            .font(.subheadline)
                    }
                }
            }
        }
    }

    private var preparation: some View {
        Group {
            switch currentStep {
            case .vocabulary:
                card(title: "Vokabeln") {
                    VStack(spacing: 10) {
                        ForEach(lesson.vocabulary) { item in
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(item.german)
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text(item.english)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Text(item.example)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            case .grammar:
                card(title: "Grammatik") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(lesson.grammarPoints) { point in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(point.title)
                                    .font(.subheadline.weight(.semibold))
                                if let explanation = point.explanation {
                                    Text(explanation)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                        .lineSpacing(3)
                                }
                            }
                        }
                    }
                }
            case .phrases:
                card(title: "Phrasen") {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(lesson.phrases) { phrase in
                            HStack(alignment: .top, spacing: 8) {
                                Button {
                                    ExamTTS.speak(phrase.german)
                                } label: {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.footnote)
                                        .foregroundStyle(Color.accentColor)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Play \(phrase.german)")
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(phrase.german)
                                        .font(.subheadline.weight(.medium))
                                    Text(phrase.english)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            case .dialogue:
                card(title: "Dialog") {
                    VStack(spacing: 10) {
                        ForEach(lesson.dialogue) { line in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(line.speaker)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.accentColor)
                                Text(line.german)
                                    .font(.subheadline)
                                Text(line.english)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            default:
                EmptyView()
            }
        }
    }

    private var exerciseNumbers: [String: Int] {
        var numbers: [String: Int] = [:]
        for (index, exercise) in allExercises.enumerated() {
            numbers[exercise.id] = index + 1
        }
        return numbers
    }

    private var exercises: some View {
        VStack(alignment: .leading, spacing: 14) {
            card(title: "Übungen — \(correctCount) / \(allExercises.count) correct") {
                VStack(spacing: 14) {
                    ForEach(ExerciseGrouping.groups(for: allExercises)) { group in
                        if let passage = group.passage {
                            CampaignPassageHeader(passage: passage)
                        }
                        ForEach(group.exercises) { exercise in
                            CampaignExerciseCard(
                                exercise: exercise,
                                number: exerciseNumbers[exercise.id] ?? 0,
                                selection: selected[exercise.id],
                                isChecked: checked.contains(exercise.id),
                                onSelect: { optionIndex in
                                    selected[exercise.id] = optionIndex
                                }
                            )
                        }
                    }

                    Button {
                        for exercise in allExercises where selected[exercise.id] != nil {
                            checked.insert(exercise.id)
                        }
                    } label: {
                        Text("Check answers")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)

                    if !checked.isEmpty {
                        Button {
                            let wrong = allExercises.filter { checked.contains($0.id) && selected[$0.id] != $0.correctIndex }.map(\.id)
                            checked = checked.subtracting(wrong)
                            for id in wrong { selected[id] = nil }
                        } label: {
                            Label("Retry wrong answers", systemImage: "arrow.clockwise")
                                .font(.footnote.weight(.semibold))
                        }
                        .disabled(allExercises.allSatisfy { !checked.contains($0.id) || selected[$0.id] == $0.correctIndex })
                    }
                }
            }
        }
    }

    private var writing: some View {
        Group {
            if let prompt = lesson.writingPrompt {
                CampaignWritingCard(prompt: prompt) {
                    wrote = true
                }
            }
        }
    }

    private var speaking: some View {
        Group {
            if let task = lesson.speaking {
                CampaignSpeakingCard(task: task, lesson: lesson, onFinished: {
                    spoke = true
                })
            }
        }
    }

    private var outcome: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 10) {
                Text(isCompleteCandidate ? "Mission complete" : "Almost there")
                    .font(.title3.weight(.semibold))
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < result.stars ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundStyle(index < result.stars ? Color.orange : ChattyTheme.hairline)
                    }
                }
                .accessibilityLabel("\(result.stars) of 3 stars")
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)

            card(title: "Result") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(correctCount) / \(allExercises.count) exercises correct")
                        .font(.subheadline)
                    if lesson.speaking != nil {
                        Text(spoke ? "Speaking done" : "Speaking not done")
                            .font(.subheadline)
                            .foregroundStyle(spoke ? Color.green : Color.orange)
                    }
                    if lesson.writingPrompt != nil {
                        Text(wrote ? "Writing checked" : "Writing not checked")
                            .font(.subheadline)
                            .foregroundStyle(wrote ? Color.green : Color.orange)
                    }
                    if isCompleteCandidate {
                        Button("Complete") { completeMission() }
                            .font(.subheadline.weight(.semibold))
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 6)
                    } else {
                        Text(completionHint)
                            .font(.footnote)
                            .foregroundStyle(Color.orange)
                            .padding(.top, 6)
                    }
                }
            }

            if isCompleteCandidate, correctCount < allExercises.count {
                card(title: "Review suggestion") {
                    Text("Retry the wrong answers and replay the mission to earn more stars.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func stepTitle(_ step: MissionStep) -> String {
        switch step {
        case .briefing: return "Briefing"
        case .vocabulary: return "Vocabulary"
        case .grammar: return "Grammar"
        case .phrases: return "Phrases"
        case .dialogue: return "Dialogue"
        case .exercises: return "Exercises"
        case .examTask: return "Exam task"
        case .writing: return "Writing"
        case .speaking: return "Speaking"
        case .outcome: return "Outcome"
        }
    }

    private func stepIcon(_ step: MissionStep) -> String {
        switch step {
        case .briefing: return "flag"
        case .vocabulary: return "book"
        case .grammar: return "textformat.abc"
        case .phrases: return "quote.bubble"
        case .dialogue: return "bubble.left.and.bubble.right"
        case .exercises, .examTask: return "pencil.and.list.clipboard"
        case .writing: return "pencil.and.outline"
        case .speaking: return "waveform"
        case .outcome: return "star"
        }
    }

    private func card<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Checkpoint

struct ExamCampaignCheckpointView: View {
    let checkpoint: CampaignCheckpoint
    @ObservedObject private var progress = ExamCampaignProgress.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selected: [String: Int] = [:]
    @State private var checked: Set<String> = []

    private var resolution: ExamCampaignCatalog.ExerciseResolution {
        ExamCampaignCatalog.checkpointResolution(checkpoint)
    }

    private var exercises: [ExamExercise] {
        resolution.exercises
    }

    private var exerciseNumbers: [String: Int] {
        var numbers: [String: Int] = [:]
        for (index, exercise) in exercises.enumerated() {
            numbers[exercise.id] = index + 1
        }
        return numbers
    }

    private var correctCount: Int {
        exercises.filter { checked.contains($0.id) && selected[$0.id] == $0.correctIndex }.count
    }

    private var checkedCount: Int {
        exercises.filter { checked.contains($0.id) }.count
    }

    private var canPass: Bool {
        MissionCompletion.canCompleteCheckpoint(checkpoint, correct: correctCount, checkedCount: checkedCount)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(checkpoint.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if !resolution.isComplete {
                    Label("Content error: \(resolution.unresolvedIDs.joined(separator: ", ")) cannot be loaded. This checkpoint cannot be passed until the content is fixed.", systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                if exercises.isEmpty {
                    Text("No checkpoint questions available yet.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(spacing: 14) {
                        ForEach(ExerciseGrouping.groups(for: exercises)) { group in
                            if let passage = group.passage {
                                CampaignPassageHeader(passage: passage)
                            }
                            ForEach(group.exercises) { exercise in
                                CampaignExerciseCard(
                                    exercise: exercise,
                                    number: exerciseNumbers[exercise.id] ?? 0,
                                    selection: selected[exercise.id],
                                    isChecked: checked.contains(exercise.id),
                                    onSelect: { optionIndex in
                                        selected[exercise.id] = optionIndex
                                    }
                                )
                            }
                        }

                        Button {
                            for exercise in exercises where selected[exercise.id] != nil {
                                checked.insert(exercise.id)
                            }
                        } label: {
                            Text("Check answers")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)

                        if !checked.isEmpty {
                            Text("\(correctCount) / \(exercises.count) correct")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(correctCount == exercises.count ? Color.green : Color.orange)

                            if correctCount < exercises.count {
                                Button {
                                    let wrong = exercises.filter { checked.contains($0.id) && selected[$0.id] != $0.correctIndex }.map(\.id)
                                    checked = checked.subtracting(wrong)
                                    for id in wrong { selected[id] = nil }
                                } label: {
                                    Label("Retry wrong answers", systemImage: "arrow.clockwise")
                                        .font(.footnote.weight(.semibold))
                                }
                            }
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                HStack(spacing: 10) {
                    if progress.isComplete(checkpoint.id) {
                        Button("Back to map") { dismiss() }
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .buttonStyle(.bordered)
                    } else {
                        Button {
                            progress.recordCheckpointComplete(checkpoint.id)
                            dismiss()
                        } label: {
                            Label("Pass checkpoint", systemImage: "flag.checkered")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canPass)
                        .accessibilityHint("Requires answering and checking every question with at least 60 percent correct.")
                    }
                }

                if !progress.isComplete(checkpoint.id) && !canPass {
                    Text("Answer and check all \(checkpoint.exerciseIDs.count) questions, then score at least 60% to pass. Checked: \(checkedCount)/\(checkpoint.exerciseIDs.count).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
        }
        .background(ChattyTheme.appBackground.ignoresSafeArea())
        .navigationTitle(checkpoint.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}



// MARK: - Final practice test

struct ExamCampaignFinalExamView: View {
    let exam: CampaignFinalExam
    @ObservedObject private var progress = ExamCampaignProgress.shared
    @State private var selected: [String: Int] = [:]
    @State private var checked: Set<String> = []

    private var resolution: ExamCampaignCatalog.ExerciseResolution {
        ExamCampaignCatalog.finalExamResolution(exam)
    }

    private var exercises: [ExamExercise] {
        resolution.exercises
    }

    private var exerciseNumbers: [String: Int] {
        var numbers: [String: Int] = [:]
        for (index, exercise) in exercises.enumerated() {
            numbers[exercise.id] = index + 1
        }
        return numbers
    }

    private var correctCount: Int {
        exercises.filter { checked.contains($0.id) && selected[$0.id] == $0.correctIndex }.count
    }

    private var checkedCount: Int {
        exercises.filter { checked.contains($0.id) }.count
    }

    private var canFinish: Bool {
        MissionCompletion.canCompleteFinalExam(exam, correct: correctCount, checkedCount: checkedCount,
                                               isLessonComplete: { progress.isComplete($0) })
    }

    private struct SkillScore {
        let skill: String
        let correct: Int
        let total: Int
    }

    private var skillBreakdown: [SkillScore] {
        let checkedOnly = exercises.filter { checked.contains($0.id) }
        guard !checkedOnly.isEmpty else { return [] }
        var bySkill: [String: (correct: Int, total: Int)] = [:]
        for exercise in checkedOnly {
            let skill = skillName(for: exercise)
            bySkill[skill, default: (0, 0)].total += 1
            if selected[exercise.id] == exercise.correctIndex {
                bySkill[skill]?.correct += 1
            }
        }
        return bySkill
            .map { SkillScore(skill: $0.key, correct: $0.value.correct, total: $0.value.total) }
            .sorted { $0.skill < $1.skill }
    }

    private func skillName(for exercise: ExamExercise) -> String {
        if exercise.id.hasPrefix("a1-read-") { return "Lesen" }
        if exercise.id.hasPrefix("a1-list-") { return "Hören" }
        if exercise.id.hasPrefix("a1-gram-") { return "Grammar" }
        return "Vocabulary"
    }

    private var replayLessons: [CampaignLesson] {
        let wrongExercises = exercises.filter {
            checked.contains($0.id) && selected[$0.id] != $0.correctIndex
        }
        var ids = Set<String>()
        for lesson in ExamCampaignCatalog.allLessons {
            let lessonExerciseIDs = Set(lesson.exercises.map(\.id) + lesson.readingExercises.map(\.id))
            if wrongExercises.contains(where: { lessonExerciseIDs.contains($0.id) }) {
                ids.insert(lesson.id)
            }
        }
        return ExamCampaignCatalog.allLessons.filter { ids.contains($0.id) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(exam.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !resolution.isComplete {
                    Label("Content error: \(resolution.unresolvedIDs.joined(separator: ", ")) cannot be loaded. This practice test cannot be finished until the content is fixed.", systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                VStack(spacing: 14) {
                    ForEach(ExerciseGrouping.groups(for: exercises)) { group in
                        if let passage = group.passage {
                            CampaignPassageHeader(passage: passage)
                        }
                        ForEach(group.exercises) { exercise in
                            CampaignExerciseCard(
                                exercise: exercise,
                                number: exerciseNumbers[exercise.id] ?? 0,
                                selection: selected[exercise.id],
                                isChecked: checked.contains(exercise.id),
                                onSelect: { optionIndex in
                                    selected[exercise.id] = optionIndex
                                }
                            )
                        }
                    }

                    Button {
                        for exercise in exercises where selected[exercise.id] != nil {
                            checked.insert(exercise.id)
                        }
                    } label: {
                        Text("Check answers")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)

                    if !checked.isEmpty {
                        Text("\(correctCount) / \(exercises.count) correct — practice result, not an official score.")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(correctCount * 10 >= exercises.count * 6 ? Color.green : Color.orange)

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(skillBreakdown, id: \.skill) { entry in
                                HStack {
                                    Text(entry.skill)
                                        .font(.footnote.weight(.medium))
                                    Spacer()
                                    Text("\(entry.correct) / \(entry.total)")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(entry.correct == entry.total ? Color.green : Color.orange)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                if !replayLessons.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recommended replay")
                            .font(.headline)
                        ForEach(replayLessons) { lesson in
                            NavigationLink(value: CampaignLessonRoute(lesson: lesson)) {
                                Label(lesson.title, systemImage: "arrow.clockwise")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(10)
                                    .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                ForEach(exam.writingLessonIDs, id: \.self) { lessonID in
                    if let lesson = ExamCampaignCatalog.lesson(id: lessonID) {
                        NavigationLink(value: CampaignLessonRoute(lesson: lesson)) {
                            Label("\(lesson.title) (writing)", systemImage: "pencil.and.outline")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(Color.accentColor.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                ForEach(exam.speakingLessonIDs, id: \.self) { lessonID in
                    if let lesson = ExamCampaignCatalog.lesson(id: lessonID) {
                        NavigationLink(value: CampaignLessonRoute(lesson: lesson)) {
                            Label("\(lesson.title) (speaking)", systemImage: "waveform")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(Color.accentColor.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    progress.recordCheckpointComplete(exam.id)
                } label: {
                    Label(progress.isComplete(exam.id) ? "Practice test done (replay)" : "Finish practice test", systemImage: "trophy.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canFinish)

                if !progress.isComplete(exam.id) && !canFinish {
                    Text("To finish: answer and check all \(exam.exerciseIDs.count) quiz questions (min. 60% correct) and complete the linked writing and speaking lessons with real answers. Checked: \(checkedCount)/\(exam.exerciseIDs.count).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
        }
        .background(ChattyTheme.appBackground.ignoresSafeArea())
        .navigationTitle(exam.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Shared exam components

/// The reading source a question block belongs to. Rendered directly above its
/// questions and kept on screen while answers and explanations are reviewed.
struct CampaignPassageHeader: View {
    let passage: ReadingPassage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lesen — \(passage.title)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.accentColor)
            Text(passage.text)
                .font(.body)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.accentColor.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct CampaignExerciseCard: View {
    let exercise: ExamExercise
    let number: Int
    let selection: Int?
    let isChecked: Bool
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("\(number).")
                    .font(.subheadline.weight(.semibold))
                Text(exercise.kind.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.10), in: Capsule())
            }

            if exercise.hasAudio {
                Button {
                    ExamTTS.speak(exercise.spokenText ?? "")
                } label: {
                    Label("Play audio", systemImage: "speaker.wave.2.fill")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.plain)
            }

            Text(exercise.question)
                .font(.subheadline)

            VStack(spacing: 6) {
                ForEach(Array(exercise.options.enumerated()), id: \.offset) { index, option in
                    optionRow(index: index, option: option)
                }
            }

            if isChecked {
                let isCorrect = selection == exercise.correctIndex
                Text(isCorrect ? "Richtig! \(exercise.explanation)" : "Leider falsch. \(exercise.explanation)")
                    .font(.footnote)
                    .foregroundStyle(isCorrect ? Color.green : Color.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.accentColor.opacity(0.04), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func optionRow(index: Int, option: String) -> some View {
        let isSelected = selection == index
        let isCorrect = isChecked && index == exercise.correctIndex
        let isWrongPick = isChecked && isSelected && !isCorrect

        return Button {
            guard !isChecked else { return }
            onSelect(index)
        } label: {
            HStack {
                Text("\(index + 1). \(option)")
                    .font(.subheadline)
                Spacer()
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                } else if isWrongPick {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                }
            }
            .padding(10)
            .background(
                isCorrect ? Color.green.opacity(0.12)
                    : isWrongPick ? Color.red.opacity(0.10)
                    : isSelected ? Color.accentColor.opacity(0.10)
                    : Color.clear,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected || isCorrect ? Color.accentColor.opacity(0.4) : ChattyTheme.softHairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CampaignWritingCard: View {
    let prompt: String
    let onFinished: () -> Void
    @State private var text = ""
    @State private var isChecking = false
    @State private var feedback: String?
    @State private var errorMessage: String?

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Schreiben")
                .font(.headline)
            Text(prompt)
                .font(.subheadline)

            ZStack(alignment: .topLeading) {
                if trimmedText.isEmpty {
                    Text("Schreib deinen Text hier ...")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 10)
                        .padding(.leading, 8)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $text)
                    .font(.subheadline)
                    .frame(minHeight: 140)
                    .padding(6)
                    .scrollContentBackground(.hidden)
            }
            .background(Color.clear, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(ChattyTheme.softHairline, lineWidth: 1)
            )

            Button {
                checkWriting()
            } label: {
                Group {
                    if isChecking {
                        ProgressView()
                    } else {
                        Text("Check my writing")
                            .font(.subheadline.weight(.semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .disabled(trimmedText.isEmpty || isChecking)

            if let feedback {
                Text(feedback)
                    .font(.footnote)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func checkWriting() {
        guard !trimmedText.isEmpty, !isChecking else { return }
        isChecking = true
        feedback = nil
        errorMessage = nil
        let submitted = trimmedText
        Task {
            do {
                let service = TeacherService()
                let response = try await service.examFix(text: submitted)
                errorMessage = nil
                feedback = response.message
                onFinished()
            } catch {
                errorMessage = "Could not check your text (\(error.localizedDescription)). Your text is saved — try again."
            }
            isChecking = false
        }
    }
}

struct CampaignSpeakingCard: View {
    let task: CampaignSpeakingTask
    let lesson: CampaignLesson
    let onFinished: () -> Void
    @State private var activeStageIndex = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(task.missionLabel)
                .font(.headline)
            Text(task.scenario)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineSpacing(3)

            if task.stages.count > 1 {
                Picker("Stage", selection: $activeStageIndex) {
                    ForEach(Array(task.stages.enumerated()), id: \.offset) { index, stage in
                        Text(stage.title).tag(index)
                    }
                }
                .pickerStyle(.segmented)
            }

            NavigationLink {
                CampaignSpeakingView(task: task, lessonID: lesson.id, initialStageIndex: activeStageIndex) {
                    onFinished()
                }
            } label: {
                Label("Start speaking practice", systemImage: "waveform")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)

            Text("The examiner speaks German; answer out loud or by text.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}


// MARK: - Speaking mission view

struct CampaignSpeakingView: View {
    static func opening(lessonID: String, stageID: String) -> String {
        switch (lessonID, stageID) {
        case ("l3-speaking-introduce", "Sich vorstellen"):
            "Guten Tag. Ich heiße Frau Müller und bin Ihre Prüferin. Wie heißen Sie?"
        case ("l3-speaking-introduce", "Über die Familie sprechen"):
            "Guten Tag. Ich heiße Frau Müller und bin Ihre Prüferin. Erzählen Sie bitte etwas über Ihre Familie."
        case ("l13-shop-speaking", _):
            "Guten Tag. Ich heiße Frau Müller. Kann ich Ihnen helfen?"
        case ("l12-doctor-health", "Telefon: Termin machen"):
            "Guten Tag. Praxis Dr. Müller, mein Name ist Frau Müller. Was kann ich für Sie tun?"
        case ("l12-doctor-health", _):
            "Guten Tag. Ich bin Frau Müller, Ihre Ärztin. Was haben Sie?"
        case ("l19-speaking-picture", "Ein Bild beschreiben"):
            "Guten Tag. Ich heiße Frau Müller und bin Ihre Prüferin. Was sehen Sie auf dem Bild?"
        default:
            "Guten Tag. Ich heiße Frau Müller und bin Ihre Prüferin. Bitte beginnen Sie."
        }
    }

    let task: CampaignSpeakingTask
    let lessonID: String
    let onFinished: () -> Void
    let initialStageID: String

    @State private var engine: ChatEngine
    @State private var inputText = ""
    @State private var isPulsing = false
    @State private var stageIndex = 0
    @State private var feedbackRequested = false
    @Environment(\.dismiss) private var dismiss

    init(
        task: CampaignSpeakingTask,
        lessonID: String,
        initialStageIndex: Int = 0,
        dependencies: ChatEngineDependencies = .live,
        onFinished: @escaping () -> Void = {}
    ) {
        self.task = task
        self.lessonID = lessonID
        self.onFinished = onFinished
        let stageIndex = Self.resolvedStageIndex(initialStageIndex, stageCount: task.stages.count)
        self.initialStageID = task.stages[stageIndex].id
        _stageIndex = State(initialValue: stageIndex)
        _engine = State(initialValue: Self.makeEngine(lessonID: lessonID, stageID: self.initialStageID, dependencies: dependencies))
    }

    static func resolvedStageIndex(_ requestedIndex: Int, stageCount: Int) -> Int {
        guard stageCount > 0 else { return 0 }
        return min(max(requestedIndex, 0), stageCount - 1)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "flag.checkered")
                    .font(.footnote)
                    .foregroundStyle(Color.accentColor)
                Text("\(task.missionLabel) — \(task.stages[stageIndex].title)")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .accessibilityElement(children: .combine)

            if task.stages.count > 1 {
                Picker("Stage", selection: $stageIndex) {
                    ForEach(Array(task.stages.enumerated()), id: \.offset) { index, stage in
                        Text(stage.title).tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
            }

            ChatMessageList(
                messages: engine.messages,
                isGenerating: engine.isGenerating,
                onSpeak: { engine.speak($0.message) },
                onTranslate: { message in
                    Task { await engine.translate(message.message) }
                },
                onSuggest: { message in
                    Task { await engine.suggest(for: message.message) }
                },
                topContent: {
                    if engine.messages.isEmpty {
                        Text("Answer in German, even if it is simple. The examiner stays in role.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            )

            if engine.isRecording {
                Text(engine.transcriptText.isEmpty ? "Listening..." : engine.transcriptText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.horizontal, 16)
            }

            ChatInputBar(
                text: $inputText,
                isRecording: engine.isRecording,
                isPulsing: isPulsing,
                onToggleRecording: { engine.toggleRecording() },
                onSend: sendMessage
            )
            .padding(.horizontal, 16)
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

            if feedbackRequested {
                Button("Close practice") {
                    engine.interrupt()
                    // Only real learner turns count as speaking evidence (task 2.4).
                    if engine.messages.contains(where: { $0.role == .user }) {
                        onFinished()
                    }
                    dismiss()
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .disabled(engine.isGenerating)
                .padding(.bottom, 8)
            } else {
                Button("Finish & get feedback", systemImage: "list.clipboard") {
                    feedbackRequested = true
                    engine.requestExamFeedback()
                }
                .font(.footnote.weight(.semibold))
                .disabled(engine.isGenerating)
                .padding(.bottom, 8)
            }
        }
        .navigationTitle("Sprechen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Refresh chat", systemImage: "arrow.clockwise") {
                    refreshChat()
                }
            }
        }
        .onAppear {
            if engine.messages.isEmpty {
                engine.startExam(with: CampaignSpeakingView.opening(lessonID: lessonID, stageID: task.stages[stageIndex].id))
            }
        }
        .onChange(of: stageIndex) { _ in
            engine.interrupt()
            engine = Self.makeEngine(lessonID: lessonID, stageID: task.stages[stageIndex].id)
            feedbackRequested = false
            if engine.messages.isEmpty {
                engine.startExam(with: CampaignSpeakingView.opening(lessonID: lessonID, stageID: task.stages[stageIndex].id))
            }
        }
        .onDisappear {
            engine.interrupt()
        }
    }

    static func makeEngine(
        lessonID: String,
        stageID: String,
        store: (any ChatStore)? = nil,
        dependencies: ChatEngineDependencies = .live
    ) -> ChatEngine {
        let german = LanguageConfig.all["de"] ?? LanguageConfig.default
        let learnerContext = BotMemoryStore.shared.summary(for: german.code)
        return ChatEngine(
            persona: .examinerA1(lesson: lessonID, stage: stageID, learnerContext: learnerContext),
            store: store ?? LessonChatStore(lessonID: lessonID, stageID: stageID),
            dependencies: dependencies
        )
    }

    private func refreshChat() {
        let stageID = task.stages[stageIndex].id
        engine.interrupt()
        LessonChatStore(lessonID: lessonID, stageID: stageID).clear()
        engine = Self.makeEngine(lessonID: lessonID, stageID: stageID)
        feedbackRequested = false
        engine.startExam(with: CampaignSpeakingView.opening(lessonID: lessonID, stageID: stageID))
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        inputText = ""
        feedbackRequested = false
        engine.sendText(text)
    }

    private func startPulse() {
        isPulsing = false
        withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
            isPulsing = true
        }
    }
}
