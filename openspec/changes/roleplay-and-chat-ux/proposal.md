# Role play and chat UX (Phase 2)

## Why

Free chat wanders without a goal. The web app already role-plays CMS "situations" (only as homework); mobile should let students pick a scenario, play it, and get a result. Learners also freeze mid-conversation because they can't phrase the next sentence, and teacher corrections arrive as a separate opaque bubble.

## What Changes

- `SituationService`: fetch GLOBAL situations from CMS (`GET {cms}/situations?populate=name,prompt,type` with Bearer JWT), strip HTML from the richtext prompt, cache in UserDefaults (revalidate on open, stale-while-error).
- "Role Play" menu row (Student, login required) -> `RolePlayHomeView` (situation cards) -> role-play conversation (kind `.rolePlay`, persona `.homework` with the situation prompt, active language/level) inside the new conversation system.
- Finish role play -> result card (user messages, teacher corrections, +100 XP) and conversation kept in "My chats".
- Quick-reply chips: after a full bot reply, the engine fetches 3 short suggested follow-ups (same /api/bot, meta prompt, JSON array) shown as tappable chips under the last assistant message; tap sends.
- Inline correction diff: teacher bubbles render a word-level diff of the learner's original sentence (struck-through changed words + corrected text) via a pure `TextDiffer`.

## Capabilities

### New Capabilities
- `role-play`: scenario catalog from CMS, role-play conversation, completion result with XP.
- `chat-ux-assists`: quick-reply suggestion chips and inline word-diff corrections.

### Modified Capabilities
(none)

## Impact

- New file: `RolePlayViews.swift` (service + views + result card; pbxproj 0x30/0x33).
- `ChatEngine.swift` (suggestions fetch + state, role-play persona reuse), `MessageView.swift`/`ChatMessageList` (chips + diff), `MenuOverlay.swift` (destination), `LearningStats.swift` (+100 XP award).
- Tests: `TextDiffer` word diff; suggestion JSON parsing (fence stripping, invalid -> empty); situation HTML stripping; result stats computation.
