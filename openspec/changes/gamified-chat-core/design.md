# Design — gamified-chat-core

## Decisions

### D1 — XP model in LearningStatsData

Extend `LearningStatsData` with `xp: Int = 0`, `xpByDay: [String: Int] = [:]`, `lastQuestRewardDay: String? = nil`, `messagesSent: Int = 0`. Codable with defaults => existing stored data decodes fine (missing keys -> defaults). Level: `level = 1 + xp / 200`; progress to next = `xp % 200 / 200`.

### D2 — Award events

`LearningStatsStore.award(xp: Int, event: XPEvent)` — pure append to xp + xpByDay[today] + event counters. Call sites:
- `ChatEngine.sendText` / `deliverUtterance` (user message): +5, messagesSent += 1
- `recordReviewGrade`: +25 (existing method, add award)
- `recordLessonPractice`: +50
- `recordShadowingAttempt`: +10

### D3 — Daily quest

Quest = 50 XP in one day. `questCompletedToday: Bool` computed from xpByDay[today] >= 50. When the award that crosses the threshold happens, add +25 bonus and set `lastQuestRewardDay = today` (guard: not already rewarded today).

### D4 — Persona prompt (ChatPersona.main)

Replace the "Invent a response" line with: "If you do not know the answer, say it simply and change the topic." Add: "Keep your replies SHORT: maximum 2 short sentences — your friend is a language learner and must get enough speaking time." Rewrite techniques sentence: "Use natural conversation techniques: mirroring, light humour, follow-up questions. Let the learner talk more than you."

### D5 — maxTokens

`BotRequest.maxTokens: Int? = nil` (omit when nil via `omitNilKeys` — JSONEncoder with `.encodeIfPresent` behavior: make it optional and use a conditional encoder, or encode manually). Voice chat path (ChatEngine) sends 150; exam/suggest do not set it.

## Non-Goals

- Weekly recap as a separate screen (row on today card for now).
- Badges/achievements (later phase).
