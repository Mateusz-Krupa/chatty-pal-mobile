# Harden auth session and user-scoped data

## Why

Users report that their session silently dies (expired Strapi JWT forces a quiet sign-out at app launch) and that their data "disappears": logging in swaps the chat thread to the profile language, chat/stats/word-review are stored per-device (not per-account), there is no in-app password reset, and login errors hide the server's explanation. A data race in the speech capture can also corrupt the uploaded WAV.

## What Changes

- On an expired/invalid session (401/403 from `getMe`), the app SHALL surface a "session expired, sign in again" banner with a login action instead of silently clearing the profile.
- Login/profile load SHALL NOT overwrite the user's active chat language/level (previously the profile's language switched the chat thread to an empty one).
- Profile fetch (`getMe`) SHALL happen once per app launch (plus once after login), not on every `onAppear`.
- Chat history, learning stats, and word-review storage SHALL be scoped per account (username; `guest` when logged out) with one-shot migration from legacy unscoped keys and from the guest scope.
- `LoginPanel` SHALL offer "Forgot password?" (Strapi `auth/local/forgot-password`) and SHALL display the server-provided error message from Strapi responses.
- Internal hardening: `SpeechController` captured-PCM buffer SHALL be protected by a lock (audio-tap thread appends while main thread reads/resets — data race).
- The Production/Local environment toggle in Settings stays as-is (explicit decision, out of scope).

## Capabilities

### New Capabilities
- `auth-session`: session lifecycle — expired-session handling, login side effects, password recovery, readable auth errors.
- `user-scoped-storage`: per-account persistence of chat history, learning stats, and word reviews, including legacy migration.

### Modified Capabilities
(none — `chat-voice-input` behavior is unchanged; the capture fix is internal thread-safety)

## Impact

- `chatty-pal/ChatView.swift` — session-expired banner, one-time profile check, no language overwrite on login, scope switching on login/logout.
- `chatty-pal/ChatStore.swift` — scoped `LocalChatStore` keys + migration.
- `chatty-pal/LearningStats.swift`, `chatty-pal/WordReview.swift` — scoped storage keys + migration + scope change hook.
- `chatty-pal/LoginPanel.swift`, `chatty-pal/AuthService.swift` — forgot-password flow, Strapi error message extraction.
- `chatty-pal/SpeechController.swift` — lock around captured PCM.
- Tests: `LocalChatStoreTests`, `LearningStatsTests`, `WordReviewTests` extended for scoping/migration; new tests for auth error parsing.
- No new dependencies. No API changes. No user-visible behavior change for the environment toggle.
