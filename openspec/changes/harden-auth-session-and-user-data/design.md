# Design — harden auth session and user data

## Context

- JWT is persisted in Keychain (`AuthSession`), Strapi's default JWT lifetime is 1 day. Today `ChatView.loadUserProfile` catches 401/403 and calls `session.signOut()` silently (ChatView.swift:372-385).
- `loadUserProfile` also overwrites `langCode`/`level` from the profile (ChatView.swift:362-369); since chat history is keyed `chat.messages.{lang}.{level}`, the thread visibly "empties" after login.
- Storage is per-device: `chat.messages.{lang}.{level}`, `learning.stats`, `learning.wordReview` in UserDefaults, no account dimension.
- `SpeechController` audio tap (audio thread) appends to `capturedPCM`; `stopRecording()` (main thread) reads/resets it — unsynchronized.
- Login errors are rendered as `Login failed (401)` — the Strapi body (`{"message":[{"messages":[{"message":"..."}]}]}`) is dropped.

## Goals

1. Users never lose data or session silently.
2. Per-account isolation of practice data on shared devices, with zero data loss for existing users (migration).
3. Keep the change small: no new DI graph, no new dependencies, no network-stack rework.

## Non-Goals

- Token refresh / longer-lived tokens (needs CMS-side change; separate work).
- Removing the Production/Local dev toggle (kept on purpose).
- Sending the user JWT to the Next.js bot/translate APIs (backend ignores auth today; separate work).
- Server-side sync of learning progress (roadmap, not this change).

## Decisions

### D1 — Scope key = username (fallback `guest`)

A single source of truth: `DataScope.current` reads the already-persisted `authUsername` from UserDefaults (`""` → `guest`). No new storage key, no new singletons. Username is stable per account (Strapi usernames are unique).

### D2 — Migration happens at load, lazily, per key

Each store's `load()` checks, in order: scoped key → legacy unscoped key → (chat only) guest-scoped key. The first hit is **moved** to the scoped key (write + delete source) and returned. Effect:

- App upgrade: legacy `learning.stats` → `learning.stats.{user}` happens once, on first load after login.
- Guest → user login: pre-login chat under `...guest.{lang}.{level}` is moved to the user scope on first load — the user's thread follows the login instead of vanishing.
- Logout → guest: fresh guest scope (guest data from a previous guest period may have already been moved to the user scope; acceptable — it belongs to the logged-in user).

`save()` always writes only the scoped key.

### D3 — Scope switching of the shared stores

`LearningStatsStore`/`WordReviewStore` remain `static let shared` singletons. Add `scopeDidChange()` that re-reads `DataScope.current` and reloads `data`/`words` from disk. `ChatView` calls it in the login-success and logout handlers (the same place the auth fields are set). `ChatEngine` gets a scoped `LocalChatStore` from `ChatView` (which already rebuilds/reloads the engine on persona changes — add scope there).

### D4 — Session-expired UX

`ChatView` gains `@State sessionExpired: Bool`. On 401/403 from `getMe`: sign out + clear profile (as today) **and** set `sessionExpired = true`, which renders a compact banner ("Session expired — please sign in again" + "Sign in" button that opens the existing `LoginPanel` sheet). Login success resets the flag.

### D5 — Profile load once per launch

`@State profileChecked: Bool = false`; `onAppear` calls `loadUserProfile` only when `isAuthenticated && !profileChecked`; the flag is set after the first attempt (success or failure) and never reset except by a fresh login (which fetches directly). This removes the per-navigation `getMe` call and its repeated sign-out risk.

### D6 — Login does not change the active chat

`loadUserProfile` keeps populating `authUsername/authEmail/authRole/availableChatLanguages` but no longer assigns `langCode`/`level` or calls `applyCurrentPersona()`. The user's profile languages remain selectable in the menu (existing `onChatSelect` flow).

### D7 — Forgot password (KISS)

`AuthService.forgotPassword(email:)` → `POST {cmsAPIBaseURL}/auth/local/forgot-password`, body `{"email": ...}`. `LoginPanel` gets a third mode (`isForgotMode`) reached from login mode via a "Forgot password?" footnote button; on success shows "If an account exists for that email, a reset link has been sent." Strapi returns 200 regardless of account existence (by design, no enumeration).

### D8 — Strapi error extraction

`AuthError.badRequest` gains a parsed message: static helper `StrapiErrorMessages.first(in body: String) -> String?` (JSONSerialization: `[{"messages":[{"message":"..."}]}]` shape, with a tolerant fallback for `{"error":{"message":...}}`). `errorDescription` returns it when present. Unit-tested.

### D9 — SpeechController capture lock

`NSLock` guarding `capturedPCM` + `capturedSampleRate`: audio tap appends under lock; `makeUploadWAV()` reads+resets under lock. No actor — the tap closure must stay synchronous and cheap; `NSLock` sections are a few memcpy-ish appends.

## Risks / Trade-offs

- Username as scope key: if a user renames their username server-side, old scope is orphaned (acceptable; usernames are rarely changed).
- Guest→user move on login is a product assumption (the pre-login chat on this device belongs to the user who just logged in). Matches user expectation; no data is deleted.
- `scopeDidChange()` on singletons is an imperative call from `ChatView` — one extra coupling point, kept minimal.
