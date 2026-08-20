# Design — conversations-and-memory

## Decisions

### D1 — Model

```swift
struct Conversation: Identifiable, Codable, Hashable {
    enum Kind: String, Codable { case free, rolePlay }
    let id: UUID
    var title: String
    var kind: Kind
    var languageCode: String
    var level: String
    var messages: [ChatMessage]
    var createdAt: Date
    var updatedAt: Date
    var situationName: String?   // for rolePlay
}
```

### D2 — ConversationStore

`@MainActor @Observable final class ConversationStore`: `conversations: [Conversation]` (sorted updatedAt desc), `activeID: UUID?`, `scope` (DataScope.current), `scopeDidChange()`. Persistence: single JSON blob in UserDefaults `conversations.{scope}`. Cap: keep last 200 messages per conversation on save.
- `startNew(languageCode:level:kind:situationName:) -> Conversation` (title = "New chat")
- `open(id:)`, `current(for languageCode:level:)` (most recent of that lang; nil if none)
- `append(message:to:)` — updates updatedAt; title becomes first user message (truncated 40 chars) on first user message.

### D3 — Engine wiring (no engine changes)

`ConversationChatStore: ChatStore` — thin adapter: `load()` = conversation.messages, `save(_:)` writes back via the store (with cap). `ChatView` builds the engine with the adapter for the active conversation (or starts a new one when opening an empty state).

### D4 — UI

- Menu: new `MenuDestination.chats` row "My chats" (Student section) -> `ConversationListView` (rows: title, lang badge, relative date, last message line). Tap -> set active conversation + pop to chat (navigationPath manipulation).
- Chat header: small "+" button -> startNew (current lang/level), interrupt engine.
- `ChatView.applyCurrentPersona()` now: store = adapter(active conversation ?? most recent for lang); no conversation yet -> startNew lazily on first message? KISS: always ensure a conversation exists when the chat screen is shown (startNew on first show if none for that language).

### D5 — Legacy migration

At store init (first load for scope, if `conversations.{scope}` absent): scan `chat.messages.{scope}.{lang}.{level}` and legacy `chat.messages.{lang}.{level}` keys for the current scope; each non-empty key becomes a conversation titled "Chatty Pal" (kind .free) with that language/level; delete source keys after import.

### D6 — Bot memory

`BotMemoryStore` (in ConversationStore.swift file): `summary(for languageCode:) -> String?`, keyed `botmemory.{scope}.{lang}`. After each user message, if `messagesSent % 15 == 0` (from LearningStats) and conversation has >= 8 messages: `Task` -> bot.sendMessage with meta prompt ("Summarize in max 3 short bullets what you know about this learner: interests, level observations, names mentioned. Under 150 words.") using the last 30 messages; store the result.
`ChatPersona.main/homework` gains `memory: String? = nil` -> appends "ABOUT YOUR FRIEND:\n{memory}" to the system instruction when present. `ChatView` passes memory when building personas.

## Risks

- UserDefaults blob grows; capped at 200 msgs/conversation and realistically <100 conversations (~1MB worst case) — acceptable for now; file-based storage is a future swap.
