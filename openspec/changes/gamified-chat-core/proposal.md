# Gamified chat core (Phase 1)

## Why

Chatting with the bot has no reward loop: users practice but see no progress, and the persona prompt tells the bot to invent answers when unsure (a language-learning anti-pattern) with no length guidance (long replies => long TTS).

## What Changes

- Persona prompt (mobile): remove "Invent a response"; add "say it simply when you don't know + change topic"; require short replies (max 2 short sentences); smooth the techniques list.
- `BotService`: new optional `maxTokens` field; voice chat (ChatEngine) sends 150.
- XP system in `LearningStats`: `xp`, per-day XP, level from XP; award events (user message +5, review +25, lesson +50, shadowing +10, role-play/exam completion +100 — latter wired in later phases).
- Daily quest: earn 50 XP today; on completion +25 bonus XP once per day (`lastQuestRewardDay`).
- Today card: level + XP progress, daily-quest progress bar, weekly recap row (messages/reviews/XP this week).

## Capabilities

### New Capabilities
- `xp-gamification`: XP accrual, levels, daily quest, weekly recap display.
- `chat-persona-prompt`: content requirements for the main chat persona (length, honesty, techniques).

### Modified Capabilities
(none — today-stats display is extended by the new xp-gamification capability)

## Impact

- `chatty-pal/ChatEngine.swift` (persona text, maxTokens on request), `chatty-pal/BotService.swift` (maxTokens), `chatty-pal/LearningStats.swift` (XP model + events), `chatty-pal/ChatView.swift` (today card), `chatty-pal/WordReview.swift`/`LearningViews.swift` (award call sites).
- Tests: XP events, daily quest, level curve, migration of existing stats (new fields default), prompt content assertion.
