# crash-reporting — Spec Delta

## ADDED Requirements

### Requirement: Release-only, consent-gated crash reporting

The app SHALL report crashes and unhandled errors to Sentry using the `SentryDSN` value from the app bundle's Info.plist, starting the SDK only after privacy consent is recorded (per `privacy-consent`). The SDK start call site SHALL be compiled out of Debug builds (and therefore of the test host, which builds with the app's Debug configuration). When no DSN is configured, no reporting SDK SHALL be active in any configuration and no reporting network traffic SHALL occur. Crashes occurring before consent are intentionally not captured.

#### Scenario: Missing DSN is a no-op
- **WHEN** a Release build starts without a `SentryDSN` Info.plist value
- **THEN** the SDK is never initialized and the app behaves exactly as before this change

#### Scenario: Pre-consent period captures nothing
- **WHEN** a Release build with DSN runs from install until the user accepts the disclosure
- **THEN** the SDK is not started during that period and starts no later than consent or the next launch, without requiring an app restart

#### Scenario: Debug and tests never contain the call site
- **WHEN** a Debug build or the unit-test host runs
- **THEN** the Sentry start code is excluded at compile time and no Sentry traffic can occur regardless of DSN presence

#### Scenario: Release crash is delivered
- **WHEN** a Release build on a device crashes **after consent was recorded** and is relaunched with a DSN configured
- **THEN** the crash event appears in the configured Sentry project (verified once during TestFlight validation)

### Requirement: Minimal data footprint and no user attribution

Crash events SHALL NOT include `sendDefaultPii` data, chat content, transcripts, email, username, or any app-assigned user identifier. App code SHALL NOT attach a `SentryUser` on sign-in and SHALL NOT clear one on sign-out because none is ever set.

#### Scenario: Event inspection
- **WHEN** a deliberately-triggered Release test event is inspected in Sentry
- **THEN** it contains stack/state diagnostics only and no identity or conversation fields added by app code

### Requirement: Symbolicated release crashes

Release crash reports SHALL be symbolicated by uploading dSYMs from the locally archived build with `sentry-cli` as a documented step of the submission checklist; no build-phase upload script is added.

#### Scenario: dSYM flow documented and proven
- **WHEN** the first TestFlight build's validation crash is triaged
- **THEN** the stack frames are symbolicated using the checklist's `sentry-cli debug-files upload` procedure
