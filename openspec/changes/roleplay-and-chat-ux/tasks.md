# Tasks — roleplay-and-chat-ux

## 1. Role play

- [x] 1.1 `RolePlayViews.swift` (pbxproj 0x30/0x33): `RoleSituation` model + `strippingHTML`, `SituationService` (fetch + cache + stale-while-error), `RolePlayHomeView`, `RolePlayChatView`, `RolePlayResultCard`
- [x] 1.2 `Conversation` model: `var completed: Bool = false`; finish awards +100 XP once
- [x] 1.3 `MenuOverlay.swift`: "Role Play" row (Student, login-gated)
- [x] 1.4 Tests: HTML stripping, result stats, suggestion JSON parsing (fences/invalid), TextDiffer word diff

## 2. Quick replies + diff

- [x] 2.1 `ChatEngine.swift`: `suggestReplies()` after finished assistant turn, `replySuggestions` state, clear on new message/recording
- [x] 2.2 `ChatView.swift`: chips row above input bar, tap-to-send
- [x] 2.3 `MessageView.swift` + `ChatMessageList`: teacher bubble with `TextDiffer` diff (original from preceding user message)
- [x] 2.4 Tests: diff segments (same/removed/added, punctuation-insensitive), chips cleared after send

## 3. Verify & close

- [x] 3.1 Build + full mobile test suite green
- [x] 3.2 Commit + archive (Task ID required)
