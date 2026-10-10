# Mobile store-ready — Design

## Context

Single-target iOS app (SwiftUI, iOS 17, iPhone+iPad, zero third-party deps until now, hand-maintained `project.pbxproj` — every new file needs 4 entries; highest object ID currently in use: `AA000000000000000000008A`, next free `AA…8B`; re-scan before assigning, sibling changes may consume IDs). No `packageReferences` block exists yet — Sentry will be the project's first SPM dependency. Auth is Strapi JWT in Keychain; account-scoped local storage keys derive from `authUsername` via `DataScope` (`ChatStore.swift:19-24`), which falls back to `"guest"` when the username is cleared. Login success callbacks currently propagate only `(jwt, username)` (`LoginPanel.swift:305`), though `AuthResponse.user.id` exists.

Google sign-in today: a `WKWebView` navigates `{CMS}/connect/google` and intercepts the Strapi redirect to `{WEB}/auth/google/redirect?...` (`LoginPanel.swift:21-35`), then "exchanges" the query at `{CMS}/auth/google/callback` — but `AuthService.exchangeOAuthCallback` builds that URL with `appendingPathComponent("auth/google/callback?\(queryString)")`, percent-encoding `?`/`=` (the flow is broken as written). The menu's `teacherHelp` row is enabled for all users; `classroom`/`stories`/`lessonPlanner` are visible-but-locked for non-teachers; `PlaceholderView` lives inside `SettingsSheet.swift:3-19`; `MenuDestination.chat`/`.userPanel` are unused. Outbound AI calls are spread across services: `ChatEngine` (message/stream, role-play, homework, exam engines), `WhisperTranscriber` (cloud STT), `PollySpeechService` (TTS via `/api/synthesize-speech`), `TranslationService` — a consent gate only at `ChatView`'s send button would not cover them all.

## Decisions

### D0. Guideline 4.8: drop social login from v1.0 instead of adding SIWA now

Apple requires an "equivalent privacy-preserving alternative" whenever an app offers third-party login. Compliant paths: (a) ship Sign in with Apple alongside Google — entitlement + Services ID/Key ops + Strapi Apple provider config (user-approval-gated server work, multi-day risk), or (b) v1.0 offers only first-party email/password auth — 4.8 has nothing to trigger.

**Chosen: (b).** Social login becomes the follow-up change `mobile-social-login` (SIWA first; Google re-added via `ASWebAuthenticationSession` with a `chattypal://` callback — Strapi's redirect target is fixed to `{WEB}/auth/{provider}/redirect`, so that page JS-redirects to the scheme when a mobile marker set within the same system-auth browser session is present; a future token exchange must build URLs with `URLComponents`, never `appendingPathComponent`). That handoff design lives in the follow-up, not this sprint. This sprint only deletes `GoogleAuthWebView`/`GoogleAuthSheet`, the Google button, and `exchangeOAuthCallback`.

Consequence accepted for v1.0: web users who registered via Google cannot sign in on mobile (no password exists); their server data is untouched. `STORE_SUBMISSION.md` flags `mobile-social-login` as the top post-launch priority.

### D1. Onboarding: full-screen flow with explicit consent actions and a real decline path

- `OnboardingView`: `TabView(.page)` — (1) what the app is, (2) microphone + speech recognition explainer; one button requests `SFSpeechRecognizer.requestAuthorization` and record-permission warm-up through existing `SpeechController` plumbing; denial still allows Continue (typed chat degrades as today), (3) data & consent: names the actual processors — OpenAI (dialog, suggestions, exam feedback, cloud transcription), Amazon Polly (TTS), DeepL (translation), Sentry (crash diagnostics) — plus retention/deletion facts, linking the in-app Policy view.
- Page 3 actions, all explicit: **"I agree — Sign in"** and **"I agree — Start practicing"** record `privacyConsentAcceptedAt` AND complete onboarding immediately; **"Not now — browse offline"** completes onboarding WITHOUT consent. There is no consent-less path that silently enables AI calls. Cancelling the login panel afterwards lands in the chat as a consented guest (onboarding is not replayed, consent stays recorded) — no return-to-page-3 state juggling.
- Flags live in one injectable `ConsentState`/`OnboardingModel` (`onboardingCompleted`, `privacyConsentAcceptedAt` in `UserDefaults.standard` — global by design, survives sign-out); `ContentView` reads it, no duplicate flag owners.
- **Consent is enforced at the service boundary, not the UI:** each outbound AI entry point — `ChatEngine` message/stream (free chat, role-play, homework, exam engines), `WhisperTranscriber.transcribe`, `PollySpeechService.synthesize`, `TranslationService.translate` — checks `ConsentState.accepted` before performing its network task; on missing consent it triggers the consent sheet presentation (shared notification/callback) and performs no request. After acceptance, pending user action can simply be retried. Declining keeps local/offline screens (catalog, saved lessons, settings) usable; on a declined install, the chat UI remains visible but every AI call route is blocked by the guard.
- **Sentry also respects consent:** the SDK is not started in `App.init`; it starts when the app is in Release, a `SentryDSN` is present, AND consent is recorded (checked at launch and on consent change — no restart needed). Crashes that happen before consent are intentionally not captured — privacy-first, documented trade-off.

### D2. Crash reporting: Sentry via SPM, compiled out of Debug/tests, consent-gated, no attribution

- Add `https://github.com/getsentry/sentry-cocoa` (pinned "up to next major" of the version resolved at implementation; exact version recorded in these notes). First SPM dependency: `XCRemoteSwiftPackageReference` + `XCSwiftPackageProductDependency`, `packageReferences` on **PBXProject**, `packageProductDependencies` on **PBXNativeTarget**, `PBXBuildFile` + frameworks entry. `xcodebuild -resolvePackageDependencies`; simulator build green with `CODE_SIGNING_ALLOWED=NO`.
- Start call site inside `#if !DEBUG` (tests run against a Debug `TEST_HOST` build — the code path cannot exist there), gated per D1 on `SentryDSN` non-empty + consent; `sendDefaultPii=false`; **no `SentryUser` ever set** (no attribution anywhere — single, simple policy).
- Verification semantics: empty DSN → SDK never starts; a build with a bogus DSN must stay healthy — only transport failures, which Sentry handles offline-style by queueing — no UI impact.
- Symbolication: `sentry-cli debug-files upload` from local archives as a documented checklist step (verify current CLI subcommand at implementation); no build-phase script, no CI.
- Post-integration re-audit: inspect the built bundle's merged app+SDK privacy manifests and the payload of one deliberately-triggered Release event for identity/chat leakage.

### D3. Account deletion: verified server contract (submission blocker), then scope-safe local wipe

- **Phase A (read-only, user-approved) verifies the live Strapi:** which role/permission allows `DELETE /users/:id` for authenticated callers; whether Strapi enforces self-only (the stock destroy controller does NOT check ownership — the web app proving a caller exists proves nothing about safety); and what happens to related rows (homework, chat persistence). Outcome recorded in these notes.
- If unsafe, a **CMS companion change** (authenticated self-deletion endpoint deriving the id from `ctx.state.user`, correct relation cleanup) MUST deploy before this app is submitted. There is no ship-without-deletion branch: the app offers registration, so Guideline 5.1.1(v) makes deletion a submission blocker. `AuthService.deleteAccount` targets one configurable endpoint constant (stock `users/{id}` route or the companion self-delete route, per Phase A verdict).
- **End-to-end acceptance order on disposable staging accounts (A and B), applied to the endpoint selected in Phase A:** 1) while A exists, attempt to delete A with B's credentials → rejected and A still authenticates (for an endpoint that derives identity solely from the session, the supplied foreign id may be ignored rather than rejected — what matters is that A stays intact and authenticates; the selected endpoint's expected response is documented in Phase A); 2) unauthenticated deletion attempt while A exists → rejected, A intact; 3) delete A with A's own credentials → success, related-data disposition observed, re-login fails cleanly, mobile local wipe verified.
- Local wipe mechanics (only after server success): capture the signed-in `DataScope` key **before** clearing profile fields (clearing `authUsername` retargets `DataScope.current` to `"guest"`), then delete Keychain JWT, `authUsername`/`authEmail`/`authRole`/`authUserId`, and every `DataScope`-keyed store for the captured scope (conversations, bot memory, homework cache, learning stats, word review, campaign progress, role-play cache); guest and other accounts' scopes must survive. Cancel/invalidate in-flight ChatEngine/profile tasks so late responses cannot rewrite removed state.
- Error mapping: **401** → existing session-expired flow (signs out, shows banner) but NO local wipe and NO deletion claim; any other non-2xx including **403** → readable error, stay signed in, nothing local changes.
- User id: persist `authUserId` at login and register (login/register success contract widened from `(jwt, username)` to carry the id) and via once-per-launch `getMe` (backfill for old sessions). If the id is unavailable at Settings open (fetch pending/failed), the delete row is disabled with a hint to retry — never guess a target.

### D4. Menu completeness: delete dead destinations, switch stays exhaustive

- Remove cases `userPanel`, `chat`, `teacherHelp`, `classroom`, `stories`, `lessonPlanner` from `MenuDestination` + their `MenuOverlay` rows (`teacherHelp` goes away for everyone; the locked teacher rows disappear too). `aboutUs` keeps its row, routing to the existing `InfoView` (same as `.info` — intentional shared screen, not a placeholder).
- `PlaceholderView` is deleted from `SettingsSheet.swift` (the file itself stays); the `switch` in `ChatView` loses its `default:` — exhaustiveness is compile-enforced. Routing test: for every `MenuDestination` case, assert the resolved destination renders a real content view (no placeholder type), plus a menu smoke check that each visible row is tappable to its screen. Uniqueness of titles/icons is NOT the invariant.

### D5. Environment switcher: Debug-only

- Wrap the "Server environment" `Section` (selector + custom LAN URL) in `#if DEBUG`; `AppEnvironment` reads persisted overrides only under DEBUG; Release always resolves to Production (TestFlight devices that previously selected Local self-heal). Spec modified accordingly; dev workflow unchanged.

### D6. App icon: script-generated single-size 1024 PNG

- `tools/appicon/main.swift` (macOS Swift + CoreGraphics): "CP" monogram + speech-bubble on the app's accent gradient → opaque 1024×1024 PNG, committed as the app's intentional initial icon; final art swap = one file, zero project edits.
- `AppIcon.appiconset` moves to the single-size universal format (Xcode 14+); the catalog is already referenced — no pbxproj change.

### D7. Privacy manifest + policy truthfulness (in-app AND public)

- New `PrivacyInfo.xcprivacy` via **PBXResourcesBuildPhase** (4 pbxproj entries): `NSPrivacyTracking=false`, `NSPrivacyTrackingDomains=[]`, `NSPrivacyCollectedDataTypes` = email + name (linked; auth/product), chat text/voice content (linked; app functionality), crash diagnostics (unlinked; app functionality — Sentry, consent-gated); `NSPrivacyAccessedAPITypes` at minimum `NSPrivacyAccessedAPICategoryUserDefaults`/`CA92.1` (UserDefaults/`@AppStorage` used pervasively, e.g. `AuthSession.swift:31-34`, `ChatStore.swift:21`), plus any audit findings (e.g. `C6171.1` only if file-timestamp reads exist — check `WAVFile`/temp cleanup); SFSpeechRecognizer/AVAudioEngine are not required-reason categories.
- `PolicyView` updated to the real flows (processors named as in D1, Sentry, retention, self-service deletion) — removing contradictory text ("request deletion by email", post-deletion retention claims). The **public policy URL** (website `/privacy`) must match the same inventory: a checklist item verifies/updates it before submission; App Store Connect App Privacy answers derive from that verified service-wide inventory, not a mechanical manifest copy.

### D8. pbxproj discipline

One commit per logical file addition; pbxproj `git diff` hand-reviewed every time; build green after each entry set. No XcodeGen migration this sprint.

## Risks

- **Server deletion contract** (D3): if Phase A finds the endpoint unsafe, the CMS companion must ship first and the mobile submission waits — no noncompliant fallback exists. Staging integration test proves the full loop.
- **pbxproj surgery + first SPM**: isolated commits, build-after-each-entry, `git revert` per phase as rollback.
- **Consent guards spread over services**: mitigated by one shared `ConsentState` check at every outbound boundary — starting points: `ChatEngine` (incl. suggestions/feedback paths), `WhisperTranscriber`, `PollySpeechService`, `TranslationService`, teacher/bot service calls; the Phase D task audits ALL outbound request sites rather than trusting this list; each guard gets a unit test; no new framework.
- **Guideline 4.8**: satisfied by absence of third-party login; accepted cost = Google-only web users wait for `mobile-social-login`.
- **Review surface beyond code** (questionnaire, age rating, screenshots, review notes, public policy URL): owned by `STORE_SUBMISSION.md`, with on-device TestFlight validation as the acceptance gate.
