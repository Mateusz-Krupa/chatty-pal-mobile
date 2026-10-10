# Mobile store-ready

## Why

The app is a feature-complete learner client but cannot be submitted to the App Store: no app icon, no privacy manifest (the app uses the UserDefaults required-reason API, so a manifest with declarations is mandatory), no crash reporting, menu entries leading to placeholder pages, no onboarding (mic/speech permissions fire unprimed mid-chat), a user-facing server-environment switch that must not ship in Release, and no in-app account deletion (mandatory per Guideline 5.1.1(v) since the app offers registration). Google sign-in additionally violates Guideline 4.8 (third-party login without an equivalent privacy-preserving option) and runs in a plain WKWebView against a callback exchange that is broken in code (`appendingPathComponent` percent-encodes `?`, so the Strapi callback URL is malformed).

## What Changes

- App icon: generated 1024px single-size icon in `Assets.xcassets` (script-generated monogram; final art is a one-file swap).
- Privacy manifest `PrivacyInfo.xcprivacy` (bundled via resources build phase): no tracking, declared collected data types, required-reason APIs incl. `NSPrivacyAccessedAPICategoryUserDefaults` / `CA92.1`; re-audited after Sentry lands (SDK ships its own manifest entries).
- Onboarding flow shown once at first launch: product intro, primed microphone + speech-recognition permission requests, an explicit consent step naming the third-party processors ("I agree — Sign in" / "I agree — Start practicing" / "Not now — browse offline"), where acceptance gates EVERY outbound AI path (dialog, transcription, TTS, translation, exam/homework/role-play engines) at the service boundary — including when Sentry is allowed to start; decline keeps the app browsable offline.
- **BREAKING (mobile auth surface):** Google sign-in removed from the mobile v1.0 submission build — Guideline 4.8 compliance is reached by offering only first-party email/password auth (register, login, forgot-password request). The `WKWebView` OAuth code and the broken `exchangeOAuthCallback` are deleted. Social login (Sign in with Apple first, then Google via `ASWebAuthenticationSession` + `chattypal://` scheme, with the web handoff design) is tracked as a separate follow-up change `mobile-social-login`.
- In-app account deletion (Guideline 5.1.1(v) — a submission blocker, not optional): confirmation flow, then verified Strapi deletion + full scope-safe local wipe. The server contract (self-only enforcement, cascade behavior) is verified first; if unsafe, a CMS companion endpoint must deploy before submission. Release acceptance includes an end-to-end deletion proof on disposable staging accounts.
- Crash reporting via Sentry (SPM, `sentry-cocoa`): compiled out of Debug and tests, DSN via `SentryDSN` Info.plist key (no DSN = inert), consent-gated start, no PII, no user attribution.
- Remove placeholder menu destinations (Teacher Help, Classroom, My Stories, Lesson Planner, user panel) and the unused `.chat` case; About Us points at the existing Info screen; `PlaceholderView` deleted.
- Server-environment switcher (Production/Local/custom LAN URL) visible only in Debug builds; Release always Production.
- In-app policy text reconciled with reality (AI processors, transcription, crash reporting, retention, self-service deletion — removing the now-wrong "deletion by email" text), and the public privacy-policy URL verified to match before submission.

Explicitly out of scope (follow-up changes): `mobile-social-login` (SIWA/Google), push notifications, StoreKit subscriptions/paywall, in-app password-reset completion/email verification, i18n, CI/CD, conversation server sync.

## Capabilities

### New Capabilities
- `store-submission-assets`: app icon, privacy manifest with truthful required-reason declarations, and the non-code assets/config required for an App Store upload.
- `onboarding`: one-time first-run flow introducing the app and priming microphone/speech permissions.
- `privacy-consent`: recorded consent to third-party AI/data processing before personal data leaves the device, and an in-app policy that matches actual flows.
- `crash-reporting`: crash/error reporting compiled out of Debug and tests; inert without a configured DSN; no user attribution.
- `account-deletion`: in-app permanent account removal against a verified server contract, plus scope-safe local wipe.
- `menu-navigation`: menu exposes only implemented destinations; every visible row leads to a real screen.

### Modified Capabilities
- `auth-session`: v1.0 mobile authentication is email/password only (register, login, forgot-password request). The app SHALL NOT present third-party login or embed a web view for auth. Existing session/expiry/profile behavior unchanged.
- `environment`: live environment switching requirements now apply to Debug builds only; release builds SHALL target Production and SHALL NOT expose the switcher.

## Impact

- Mobile: `LoginPanel.swift` (Google button + WebView removal), `AuthService.swift` (drop `exchangeOAuthCallback`), `ChatView.swift` (onboarding gate, profile user id, deletion wiring), `MenuOverlay.swift` (destinations), `SettingsSheet.swift` (`PlaceholderView` removal — it is defined inside this file, Debug-only env section, delete-account row), `AuthSession.swift` (+`authUserId`), new `OnboardingView.swift` / `PrivacyConsent.swift`, `chatty_palApp.swift` (Sentry init), `PolicyView.swift`/`InfoView.swift` (text), `Info.plist` (`SentryDSN` placeholder key), `Assets.xcassets` (icon), new `PrivacyInfo.xcprivacy` (added to **PBXResourcesBuildPhase**, not sources). Each new Swift/plist file needs 4 manual `project.pbxproj` entries; highest ID currently in use is `AA000000000000000000008A` (next free `AA…8B`; re-scan before assigning). First-ever SPM dependency: package reference lives on `PBXProject`, product dependency on `PBXNativeTarget`.
- Server/CMS (verification + possible small companion, requires user approval before any change): confirm `users.destroy` permission scope and ownership enforcement for authenticated roles; verify delete cascade/relations behavior; document outcome. If over-permissive, mobile deletion stays blocked behind a CMS self-deletion endpoint (ID from `ctx.state.user`) shipped first.
- Dependency: `getsentry/sentry-cocoa` via SPM (verified: 1125 GitHub stars, MIT).
- Tests: onboarding/consent flags, callback-free auth flows, deletion service (stubbed HTTP incl. 403-vs-401 distinction, scope wipe with concurrent guest data preserved), menu routing exhaustiveness, environment Debug-only.
- Manual (documented, not code): App Store Connect record, App Privacy questionnaire mirroring the manifest, age rating, screenshots, TestFlight upload + on-device validation, dSYM upload via `sentry-cli` from local archives, review-contact credentials kept outside the repo.
