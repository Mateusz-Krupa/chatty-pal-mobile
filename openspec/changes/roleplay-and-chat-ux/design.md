# Design — roleplay-and-chat-ux

## Decisions

### D1 — SituationService

`GET {AppEnvironment.cmsAPIBaseURL}/situations?populate=name,prompt&type="GLOBAL"` with `Authorization: Bearer {jwt}`, 30s timeout. Response: Strapi `{data:[{id, attributes:{name, prompt, type}}]}`. `prompt` is richtext HTML -> `strippingHTML()` (AttributeStringMLDecoder or regex `"<[^>]+>"` + trim). Model: `RoleSituation {id, name, prompt}`. Cache: UserDefaults `rolesituations.cache` (JSON) — use cache on fetch failure (stale-while-error); refetch each open.

### D2 — Role play flow

`RolePlayHomeView(jwt:)`: loads situations, cards (name + situation snippet). Tap -> `RolePlayChatView`: starts a `.rolePlay` conversation via ConversationStore (title = situation name, situationName set, current lang/level), persona `.homework(language:level:prompt: situation.prompt, memory:)`. Reuses ChatEngine + ChatMessageList + input bar (same pattern as HomeworkChatView, but store-backed and no status lifecycle). "Finish role play" button (in chat header toolbar) -> `RolePlayResultCard` sheet: `RolePlayResult(userMessages:corrections:)` stats + +100 XP (award once per conversation via a flag on the conversation? KISS: award in the store on finish, set conversation.title suffix? — no: add `var completed: Bool` to Conversation, guard award).

### D3 — Quick-reply chips

`ChatEngine.suggestReplies()`: after stream finishes (in `finishPlaybackPhase` when `streamFinished && messages.last?.role == .assistant`), fire a Task: bot.sendMessage with instruction = persona instruction, meta prompt: "Suggest 3 short natural follow-up messages the learner could send next. Reply with ONLY a JSON array of 3 short strings, no other text." Parse: strip code fences, JSONDecoder [String], filter empties, cap 3. State: `replySuggestions: [String]`, cleared on any new user message. UI: chips row above the input bar (in ChatView when `!engine.isRecording && !engine.isGenerating`); tap -> `engine.sendText(chip)`.

### D4 — Inline diff

`TextDiffer.wordDiff(original:corrected:) -> [DiffSegment]` where segment = (text, kind: .same/.removed/.added). Algorithm: common word prefix + common word suffix (case/punct-insensitive compare), middle is removed/added. Pure + tested. `MessageView` teacher role: accept optional `original: String?`; when present render the diff (removed words struck-through gray, added bold) instead of the plain correction. `ChatMessageList` passes the preceding user message text for teacher bubbles. Keep "Tap to hear" (reads the correction).

## Non-Goals

- Server-side structured suggestions response (client prompt on existing endpoint instead — no API change).
- Situations with per-situation language/level (situations are global text; current learner language/level applies).
