# Tasks — gamified-chat-core

## 1. XP core

- [x] 1.1 `LearningStats.swift`: extend `LearningStatsData` (xp, xpByDay, lastQuestRewardDay, messagesSent) with defaults; `award(xp:event:)`, `level`, `levelProgress`, `questProgress`, `weeklyRecap`
- [x] 1.2 Award call sites: `ChatEngine.sendText`/`deliverUtterance` (+5), `recordReviewGrade` (+25), `recordLessonPractice` (+50), `recordShadowingAttempt` (+10); daily-quest bonus +25 on threshold cross
- [x] 1.3 Tests: XP events, level curve, daily quest one-time bonus, weekly recap window, old-data decode (no crash)

## 2. Persona prompt + maxTokens

- [x] 2.1 `ChatEngine.swift` `ChatPersona.main`: remove "Invent a response", add honesty + max-2-sentences rule, smooth techniques
- [x] 2.2 `BotService.swift` `BotRequest.maxTokens: Int?`; ChatEngine voice path sends 150
- [x] 2.3 Test: persona prompt contains the new rules and does NOT contain "invent"

## 3. UI

- [x] 3.1 `ChatView.swift` today card: level + XP bar, daily quest progress, weekly recap row
- [x] 3.2 Tests for card inputs (pure: quest progress values)

## 4. Verify & close

- [x] 4.1 Build + full mobile test suite green
- [x] 4.2 Commit + archive (Task ID required)
