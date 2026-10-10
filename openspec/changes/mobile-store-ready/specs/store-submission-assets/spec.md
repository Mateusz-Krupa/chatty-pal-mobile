# store-submission-assets — Spec Delta

## ADDED Requirements

### Requirement: App icon asset

The app bundle SHALL contain an App Store-compliant icon (opaque 1024×1024 universal source in `AppIcon.appiconset`, single-size format) so no build ships with the default blank Xcode icon.

#### Scenario: Archived build carries the icon
- **WHEN** the app is archived in Release and inspected (or run on a device)
- **THEN** the Home Screen shows the app icon and App Store Connect image validation raises no blank/alpha warnings

#### Scenario: Final art swap without project edits
- **WHEN** designed artwork replaces the single 1024 PNG in `AppIcon.appiconset`
- **THEN** a rebuild produces the new icon with zero `project.pbxproj` changes

### Requirement: Privacy manifest with truthful required-reason declarations

The bundle SHALL include `PrivacyInfo.xcprivacy` (added via the resources build phase) declaring: no tracking (`NSPrivacyTracking=false`, empty tracking domains); every data category the shipped build actually transmits (account email/username, learner chat/voice content, crash diagnostics) with matching purpose and linkage; and every required-reason API in use — at minimum `NSPrivacyAccessedAPICategoryUserDefaults` with reason `CA92.1`, plus any findings of a post-Sentry re-audit (SDK-bundled manifests are verified in the built bundle, not assumed).

#### Scenario: UserDefaults declaration present
- **WHEN** the built app's manifest is inspected
- **THEN** the UserDefaults API category is declared with an approved reason code

#### Scenario: Binary scan returns no missing-declaration warnings
- **WHEN** the archived build is uploaded to App Store Connect (or validated)
- **THEN** no "missing required-reason API declaration" ITMS warning is received

#### Scenario: Audit re-run after SDK additions
- **WHEN** Sentry is integrated
- **THEN** the manifest and the merged SDK declarations are re-checked against actual data flows before submission

### Requirement: On-device release acceptance gate

Submission readiness SHALL be proven by an on-device Release run, not only a simulator build: archive + distribution validation, a TestFlight install, and a smoke pass over sign-up, onboarding permissions, chat round trip, and Settings on production configuration. Deletion behavior is validated separately through the disposable staging accounts A/B proof (see `account-deletion`), never by destroying production data during smoke.

#### Scenario: Release archive validates
- **WHEN** the Release archive is validated for distribution
- **THEN** icon, manifest, URL scheme-free Info.plist, and privacy keys pass without errors

#### Scenario: TestFlight smoke
- **WHEN** a TestFlight build is run on an iPhone (and checked on iPad, since both are targeted), using production configuration (no environment override ships)
- **THEN** the listed smoke flows work — account deletion is exercised via the disposable staging accounts A/B proof, not against production data — and a deliberate crash appears symbolicated in the crash dashboard with its payload inspected for identity or chat content

### Requirement: Submission checklist without secrets

Store-submission setup (DSN value, App Store Connect records, questionnaire answers, age rating, screenshots, review-contact credentials) SHALL be driven by a checked-in checklist document with values supplied outside the repository; no credential, DSN, or account identifier is committed.

#### Scenario: Clean clone builds Release
- **WHEN** Release is built on a fresh clone with no extra configuration
- **THEN** the build succeeds and crash reporting is inert until a `SentryDSN` is provided
