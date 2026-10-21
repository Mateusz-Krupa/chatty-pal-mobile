import Foundation
import Observation

@MainActor
@Observable
final class LearningProgressStore {
    static let shared = LearningProgressStore()

    private(set) var lessons: [String: LessonProgress] = [:]
    private(set) var pending: [ShadowingAttempt] = []
    private(set) var errors: [String: String] = [:]
    private(set) var message: String?
    private(set) var isBusy = false
    private(set) var isReady = false
    private(set) var isSignedIn = false
    private(set) var sessionID = UUID()

    @ObservationIgnored private var api: any LearningProgressAPI
    @ObservationIgnored private let usesLiveAPI: Bool
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var jwt = ""
    @ObservationIgnored private var ownerID: Int?
    @ObservationIgnored private var backendID = ""

    init(api: (any LearningProgressAPI)? = nil, defaults: UserDefaults = .standard) {
        self.api = api ?? LearningProgressService()
        self.usesLiveAPI = api == nil
        self.defaults = defaults
    }

    var completedLessonCount: Int {
        let known = Set(MobileLearningCatalog.germanLessons.map(\.id))
        return lessons.values.filter { known.contains($0.lessonId) && $0.isCompleted }.count
    }

    func configure(jwt: String, backendID: String = AuthService.backendURL.absoluteString) {
        guard self.jwt != jwt || self.backendID != backendID else { return }
        self.jwt = jwt
        self.backendID = backendID
        // Pin each live service to this environment; an in-flight request must
        // never resume against another backend after a settings change.
        if usesLiveAPI { self.api = LearningProgressService() }
        sessionID = UUID()
        ownerID = nil
        lessons = [:]
        pending = []
        errors = [:]
        message = nil
        isReady = false
        isBusy = false
        isSignedIn = !jwt.isEmpty
    }

    func phrase(lessonID: String, phraseID: String) -> PhraseProgress? {
        lessons[lessonID]?.phrases.first { $0.phraseId == phraseID }
    }

    func hasPending(lessonID: String, phraseID: String? = nil) -> Bool {
        pending.contains { $0.lessonId == lessonID && (phraseID == nil || $0.phraseId == phraseID) }
    }

    /// Called exactly once per newly scored attempt. Retrying sync never awards XP.
    func enqueue(lessonID: String, phraseID: String, transcript: String, score: Int) {
        guard isSignedIn, isReady, !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard transcript.utf16.count <= 5000, (0...100).contains(score) else {
            errors[lessonID] = "Attempt not saved: please record a shorter response and try again."
            return
        }
        pending.append(ShadowingAttempt(clientAttemptId: UUID().uuidString, lessonId: lessonID,
            catalogRevision: MobileLearningCatalog.progressRevision,
            generation: lessons[lessonID]?.generation ?? 0, phraseId: phraseID,
            transcript: transcript, score: score, scoringVersion: "word-match-v1"))
        persist()
    }

    func refresh() async {
        guard isSignedIn, !isBusy else { return }
        let session = sessionID, token = jwt
        isBusy = true
        defer { if sessionID == session { isBusy = false } }
        do {
            if ownerID == nil {
                let id = try await api.userID(jwt: token)
                guard sessionID == session else { return }
                ownerID = id
                restore()
            }
            let records = try await api.fetch(jwt: token)
            guard sessionID == session else { return }
            lessons = Dictionary(uniqueKeysWithValues: records.map { ($0.lessonId, $0) })
            isReady = true
            message = nil
            persist()
            await flush(session: session, token: token)
        } catch {
            guard sessionID == session else { return }
            message = "Could not sync progress. Check your connection and retry."
        }
    }

    private func flush(session: UUID, token: String) async {
        while sessionID == session, let attempt = pending.first {
            // A reset elsewhere makes the old attempt obsolete. Never retarget it to a new generation.
            if (lessons[attempt.lessonId]?.generation ?? 0) != attempt.generation {
                pending.removeFirst()
                errors[attempt.lessonId] = "An unsaved attempt belongs to progress that was reset. Please practice again."
                persist()
                continue
            }
            do {
                let updated = try await api.save(attempt, jwt: token)
                guard sessionID == session else { return }
                lessons[updated.lessonId] = updated
                pending.removeAll { $0.id == attempt.id }
                errors[updated.lessonId] = nil
                persist()
            } catch {
                guard sessionID == session else { return }
                errors[attempt.lessonId] = "Not saved — Retry"
                if let error = error as? ProgressAPIError, error.isConflict {
                    message = error.localizedDescription
                    // Keep the original pending payload; reload will reconcile generation safely.
                    if let records = try? await api.fetch(jwt: token), sessionID == session {
                        lessons = Dictionary(uniqueKeysWithValues: records.map { ($0.lessonId, $0) })
                        persist()
                    }
                }
                return
            }
        }
    }

    func setCompletion(lessonID: String, reset: Bool) async {
        guard isSignedIn, isReady, !isBusy, !hasPending(lessonID: lessonID) else { return }
        let session = sessionID, token = jwt
        let generation = lessons[lessonID]?.generation ?? 0
        isBusy = true
        defer { if sessionID == session { isBusy = false } }
        do {
            let updated = try await api.command(lessonID: lessonID, generation: generation, reset: reset, jwt: token)
            guard sessionID == session else { return }
            lessons[lessonID] = updated
            errors[lessonID] = nil
            message = nil
            persist()
        } catch {
            guard sessionID == session else { return }
            errors[lessonID] = "Change not confirmed. Reload progress before trying again."
            // Also reload on an ambiguous timeout: the reset may already have committed.
            do {
                let records = try await api.fetch(jwt: token)
                guard sessionID == session else { return }
                lessons = Dictionary(uniqueKeysWithValues: records.map { ($0.lessonId, $0) })
                persist()
            } catch { /* Keep the last confirmed state and explicit error. */ }
        }
    }

    private struct Cache: Codable {
        let lessons: [String: LessonProgress]
        let pending: [ShadowingAttempt]
    }

    private var storageKey: String? { ownerID.map { "learning.progress.v1.\(backendID).\($0)" } }

    private func persist() {
        guard let key = storageKey, let data = try? JSONEncoder().encode(Cache(lessons: lessons, pending: pending)) else { return }
        defaults.set(data, forKey: key)
    }

    private func restore() {
        guard let key = storageKey, let data = defaults.data(forKey: key),
              let cache = try? JSONDecoder().decode(Cache.self, from: data) else { return }
        lessons = cache.lessons.filter { $0.value.catalogRevision == MobileLearningCatalog.progressRevision }
        pending = cache.pending.filter { $0.catalogRevision == MobileLearningCatalog.progressRevision }
        // Cached data may be stale; a fresh server read is required before new commands.
    }
}
