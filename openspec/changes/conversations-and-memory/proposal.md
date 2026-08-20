# Conversations and bot memory (Phase 3)

## Why

Chat history is a single endless thread per language/level with no way to return to a previous topic, and the bot has no memory between sessions. Users asked for a better way to chat and revisit conversations.

## What Changes

- New `Conversation` model + `ConversationStore` (@Observable, per-account scoped): list of conversations (id, title, kind, language, level, messages, timestamps), active conversation, new/open/update operations.
- `ChatStore` adapter over `ConversationStore` — `ChatEngine` unchanged.
- UI: "My chats" menu row -> conversation list (title, language, date, last message); "New chat" button in chat header; main chat opens the most recent conversation for the active language.
- One-shot migration of legacy chat data (`chat.messages.{...}` keys, incl. scoped/guest from the previous change) into "Chatty Pal" conversations.
- Bot memory: rolling per-language summary of the learner (regenerated every 15 user messages, max ~200 words) injected into the persona system instruction as "ABOUT YOUR FRIEND".
- Per-conversation message cap (last 200).

## Capabilities

### New Capabilities
- `conversations`: conversation list, open/new, per-account scoping, legacy migration, cap.
- `bot-memory`: rolling learner summary per language injected into the bot persona.

### Modified Capabilities
(none)

## Impact

- New files: `ConversationStore.swift`, `ConversationViews.swift` (+ pbxproj entries 0x2E/0x2F file refs, 0x31/0x32 build files).
- `ChatView.swift` (list entry, new-chat button, store wiring), `ChatEngine.swift` (memory in persona prompt — via ChatPersona), `MenuOverlay.swift` (new destination).
- Tests: `ConversationStoreTests.swift` (CRUD, scoping, migration, cap, title), memory injection logic.
