# Tasks — harden-auth-session-and-user-data

## 1. User-scoped storage

- [x] 1.1 `ChatStore.swift`: `DataScope` helper (username or `guest`); `LocalChatStore(languageCode:level:scope:)` with scoped key `chat.messages.{scope}.{lang}.{level}`; lazy migration at `load()` (scoped → legacy unscoped → guest-scoped, move-once)
- [x] 1.2 `LearningStats.swift`: scoped key `learning.stats.{scope}` + legacy migration + `scopeDidChange()`
- [x] 1.3 `WordReview.swift`: scoped key `learning.wordReview.{scope}` + legacy migration + `scopeDidChange()`
- [x] 1.4 Tests: extend `LocalChatStoreTests`, `LearningStatsTests`, `WordReviewTests` (scoping, legacy migration once, guest→user chat continuity, isolation between scopes)

## 2. Auth session UX

- [x] 2.1 `ChatView.swift`: `sessionExpired` banner (sign-in action → LoginPanel), cleared on successful login
- [x] 2.2 `ChatView.swift`: `loadUserProfile` no longer overwrites `langCode`/`level` / no `applyCurrentPersona`
- [x] 2.3 `ChatView.swift`: profile fetch once per launch (`profileChecked` flag) + once after login
- [x] 2.4 `ChatView.swift`: engine built with scoped `LocalChatStore`; `scopeDidChange()` on both stores in login/logout handlers

## 3. Login panel

- [x] 3.1 `AuthService.swift`: `forgotPassword(email:)` → `POST auth/local/forgot-password`
- [x] 3.2 `AuthService.swift`: `StrapiErrorMessages.first(in:)` parser; `AuthError.errorDescription` uses it
- [x] 3.3 `LoginPanel.swift`: forgot-password mode (email field + confirm + success message)
- [x] 3.4 Tests: parser unit tests (strapi shape, strapi error shape, unparseable fallback)

## 4. Speech capture thread safety

- [x] 4.1 `SpeechController.swift`: `NSLock` around `capturedPCM`/`capturedSampleRate` (tap append, WAV read+reset)

## 5. Verify & close

- [x] 5.1 Build + full test suite green
- [ ] 5.2 Commit + archive (Task ID required)
