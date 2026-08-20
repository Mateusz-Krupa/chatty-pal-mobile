# Tasks — conversations-and-memory

## 1. Store

- [x] 1.1 `ConversationStore.swift`: `Conversation` model, `ConversationStore` (scope, persistence, startNew/open/append, title rule, 200-msg cap), `ConversationChatStore` adapter, legacy migration, `BotMemoryStore`
- [x] 1.2 pbxproj: file refs 0x2E/0x2F + build files 0x31/0x32 (+ group children + sources phase)
- [x] 1.3 `ConversationStoreTests.swift` (pbxproj 0x4A/0x5A): CRUD, scoping isolation, title rule, cap, legacy migration, adapter round-trip

## 2. Engine wiring + memory

- [x] 2.1 `ChatEngine.swift`: `ChatPersona` gains `memory: String? = nil` (appends "ABOUT YOUR FRIEND"); memory refresh Task after user message (every 15th, >=8 msgs)
- [x] 2.2 `ChatView.swift`: ensure conversation on show, adapter store in init/applyCurrentPersona/rebuildEngine, "My chats" destination + "+" new-chat button, scopeDidChange on login/logout
- [x] 2.3 `MenuOverlay.swift`: `MenuDestination.chats` row (Student section)

## 3. UI

- [x] 3.1 `ConversationViews.swift` (pbxproj 0x2F/0x32): `ConversationListView` rows (title, lang, date, last message) + tap-to-open
- [x] 3.2 Render test: list renders conversations

## 4. Verify & close

- [x] 4.1 Build + full mobile test suite green
- [x] 4.2 Commit + archive (Task ID required)
