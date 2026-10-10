# Mobile store-ready — Tasks

Order = risk-first: server-contract facts gate the feature that depends on them; pbxproj surgery is isolated per phase. Per AGENTS.md: build after every code change, run tests after each phase, commit per phase (Task ID supplied by user). Highest pbxproj object ID in use is `AA000000000000000000008A` (re-scan before assigning). Server/CMS tasks are read-only or use disposable staging accounts; any server write needs explicit user approval first.

## 1. Phase A — Server deletion-contract verification (read-only; gates Phase F and submission)

- [ ] With user approval, inspect live Strapi users-permissions settings: what `destroy` on `plugin::users-permissions.user` allows authenticated callers; whether `DELETE /users/{id}` enforces own-id-only (stock controller does not check ownership)
- [ ] Verify what cascades on user delete (homeworks, chat persistence): removed / orphaned / anonymized
- [ ] Record verdict in design notes; if unsafe, create the CMS companion OpenSpec change (self-deletion endpoint deriving id from `ctx.state.user`, relation cleanup) and mark deployment a hard prerequisite — submission cannot proceed without a working deletion path
- [ ] Provision two disposable staging accounts (with approval) for the Phase H end-to-end deletion proof

## 2. Phase B — Menu completeness + Debug-only environment switcher

- [x] Remove `MenuDestination` cases `userPanel`, `chat`, `teacherHelp`, `classroom`, `stories`, `lessonPlanner` + their `MenuOverlay` rows; route `aboutUs` to `InfoView`; drop the `default:` branch keeping the switch exhaustive; delete `PlaceholderView` from `SettingsSheet.swift` (keep the file)
- [x] Wrap the Settings "Server environment" section (selector + custom LAN URL) in `#if DEBUG`; `AppEnvironment` reads persisted overrides only under DEBUG, Release always Production
- [x] Routing test: every `MenuDestination` case resolves to a real content view (no placeholder type exists); menu smoke check that each visible row opens its screen (title/icon uniqueness is NOT the invariant); update `ChatUX` tests touching removed rows
- [x] Build + tests; commit Phase B (verified: 228 unit + 3 UI tests green on simulator, Release binary audited for env strings)

## 3. Phase C — App icon + privacy manifest

- [ ] Write `tools/appicon/main.swift` (CoreGraphics: CP monogram + speech bubble on accent gradient, opaque 1024×1024 PNG); generate into `AppIcon.appiconset`; switch to single-size universal format; verify on simulator Home Screen
- [ ] Audit required-reason API usage in sources (UserDefaults/`@AppStorage`, file-timestamp reads incl. `WAVFile`/temp cleanup); record findings
- [ ] Add `PrivacyInfo.xcprivacy` (tracking=false; collected: email, name, user content linked; crash diagnostics unlinked; APIs: `NSPrivacyAccessedAPICategoryUserDefaults`/`CA92.1` + audit findings) with 4 pbxproj entries in **PBXResourcesBuildPhase**
- [ ] Build; verify manifest lands in the built `.app`; commit Phase C

## 4. Phase D — Onboarding + consent enforced at every AI boundary

- [ ] Create `ConsentState`/`OnboardingModel` (injectable; owns `onboardingCompleted` + `privacyConsentAcceptedAt` in `UserDefaults.standard`; exposes `accepted` + consent-changed signal) with unit tests; `ContentView` consumes it only
- [ ] `OnboardingView`: page 1 intro; page 2 mic+speech explainer with one button (`SFSpeechRecognizer.requestAuthorization` + record warm-up via `SpeechController` plumbing, denial still continues); page 3 consent disclosure **naming the processors** (OpenAI dialog/transcription, Amazon Polly TTS, DeepL translation, Sentry crashes) + link to PolicyView, with three explicit actions: "I agree — Sign in", "I agree — Start practicing" (both record consent AND complete onboarding immediately), "Not now — browse offline" (completes WITHOUT consent). Login-panel cancel afterwards lands in chat as consented guest
- [ ] Service-boundary guards: check `ConsentState.accepted` before network at **all outbound AI request sites** (start: `ChatEngine` message/stream + suggestions/feedback + role-play/homework/exam engines, `WhisperTranscriber.transcribe`, `PollySpeechService.synthesize`, `TranslationService.translate`; audit for any others); on missing consent present the consent sheet and send nothing; retry after acceptance
- [ ] Update `PolicyView` to real processors/retention/self-service deletion (remove "deletion by email" + contradictions); public `/privacy` parity noted as Phase H checklist item
- [ ] Unit tests: flags; decline → offline-browsable, consent unset, later AI action → consent sheet and no request; legacy install (onboarding "completed", no consent) → first voice/translation/TTS call blocked until consent; **agree → cancel login → chat as consented guest (flags persisted, no re-prompt)**; acceptance recorded once
- [ ] Manual simulator pass: fresh install → onboarding; second launch skips (after agree AND after decline); permission denial keeps typed chat working
- [ ] Build + tests; commit Phase D

## 5. Phase E — Remove Google sign-in (Guideline 4.8 by absence)

- [ ] Delete `GoogleAuthWebView`, `GoogleAuthSheet`, Google button + presentation state from `LoginPanel.swift`; delete `AuthService.exchangeOAuthCallback` (incl. its `appendingPathComponent` bug); no URL scheme added in this change
- [ ] Widen login/register success contract from `(jwt, username)` to carry the user id (used by Phase F)
- [ ] Grep + compile proof: no `WKWebView` remains in target sources; email flows untouched
- [ ] Open follow-up change `mobile-social-login` (SIWA first, then Google via `ASWebAuthenticationSession` per design D0, incl. Strapi Apple-provider feasibility) so the deferral is on record
- [ ] Update auth tests; build + tests; commit Phase E

## 6. Phase F — Account deletion (requires Phase A verdict)

- [ ] Persist `authUserId` on login/register and once-per-launch `getMe`; Settings delete row disabled (with retry hint) while the id is unavailable
- [ ] `AuthService.deleteAccount` targeting the endpoint chosen by Phase A (stock `users/{id}` or companion self-delete route) as one configurable constant; proper `URLComponents`; bearer header
- [ ] Destructive "Delete account" row + confirmation naming lost progress; on server success: capture `DataScope` key first, cancel in-flight engine/profile tasks, clear Keychain + profile fields + all captured-scope stores, sign out to guest
- [ ] Error-mapping tests (stub HTTP): 401 → session-expired path with NO local wipe and NO data loss; 403/5xx → readable error, everything preserved; success → only the captured scope removed, guest + other accounts intact; late in-flight response discarded
- [ ] If Phase A demanded the CMS companion: confirm deployed to production before proceeding; otherwise record the submission blocker
- [ ] Build + tests; commit Phase F

## 7. Phase G — Sentry crash reporting (consent-gated start)

- [ ] Add `getsentry/sentry-cocoa` via manual pbxproj SPM edits (`packageReferences` on PBXProject, product dependency on PBXNativeTarget, build file + frameworks entry); `xcodebuild -resolvePackageDependencies`; hand-review the pbxproj diff; record resolved SDK version here
- [ ] Start logic (inside `#if !DEBUG`): only when `SentryDSN` non-empty AND `ConsentState.accepted` — evaluated at launch and on consent change; `sendDefaultPii=false`; no `SentryUser` anywhere; commented `SentryDSN` placeholder key in `Info.plist`; pre-consent crashes intentionally uncaptured (documented trade-off)
- [ ] Verify: Debug/test host contains no Sentry call site; Release without DSN never starts; **Release with DSN but no consent → SDK not started until consent is recorded (no restart), then starts**; bogus DSN keeps app healthy (silent transport failures, no UI impact)
- [ ] Re-audit privacy with Sentry merged: built bundle's combined app+SDK manifests; adjust declarations if needed
- [ ] Build + tests; commit Phase G

## 8. Phase H — Validation + submission readiness

Approval boundaries: staging server tests, TestFlight/distribution uploads, and any public-policy deployment each need their own explicit user approval at execution time — plan approval is not deployment authorization.

- [ ] Full `chatty-palTests` run green; Release simulator build green
- [ ] **End-to-end deletion proof on staging accounts A/B** (approved; server-level, runs against staging data, NOT the device smoke which keeps production config): 1) delete A with B's credentials → rejected, A still authenticates (key assertion: A intact + authenticates, whether the foreign id is rejected or ignored is documented in Phase A); 2) unauthenticated attempt while A exists → rejected, A intact; 3) delete A with A's credentials → success, related-data disposition observed, re-login fails cleanly; then on-device local-wipe assertions for A's scope
- [ ] Device Release smoke on **production configuration** (no env override ships): onboarding agree AND decline branches; register/login email-only with a reviewer/demo account; chat round trip; voice/translation blocked pre-consent on a legacy-style install; exam campaign; Settings without env switcher; iPhone **and** iPad. No destructive deletion on production data here — deletion proof is the staging test above
- [ ] Archive → distribution validation → zero ITMS privacy/icon warnings; deliberate crash symbolicated in Sentry (`sentry-cli debug-files upload`, verify current subcommand) and event payload inspected for identity/chat leakage
- [ ] Write `STORE_SUBMISSION.md`: ASC record, App Privacy questionnaire from the verified data inventory, age rating, screenshots, review contacts + demo credentials location (outside repo), dSYM procedure, **public privacy-policy URL parity check**, v1.0 social-login absence note with `mobile-social-login` as top post-launch follow-up
- [ ] `openspec validate mobile-store-ready` passes; boxes checked; residual manual submission steps reported; archive after user sign-off
