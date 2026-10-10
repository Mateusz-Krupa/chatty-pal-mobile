# privacy-consent — Spec Delta

## ADDED Requirements

### Requirement: Consent gates every third-party AI transmission

Before any request that sends personal data (chat text/voice, speech transcription, text-to-speech synthesis, translation, suggestions, exam/homework/role-play engine calls) to a third-party AI processor, the app SHALL require a recorded acceptance (timestamp persisted per install) of a plain-language disclosure that NAMES the processors actually used (dialog/transcription provider, TTS provider, translation provider, crash-reporting service) and links the policy. The gate SHALL live at the service boundary of each outbound path — not only at one UI button — covering the guest path and legacy installs whose onboarding predates this feature. After acceptance, the user's pending action can be retried without an app restart.

#### Scenario: First chat request without acceptance
- **WHEN** any AI-backed request is triggered while acceptance is absent
- **THEN** the consent sheet is presented and no request leaves the device until acceptance

#### Scenario: Non-chat AI paths gated too
- **WHEN** a guest with no acceptance triggers cloud transcription, TTS playback, or translation directly
- **THEN** the same gate applies and no network call to those endpoints occurs

#### Scenario: Acceptance recorded once
- **WHEN** the user accepts
- **THEN** the timestamp persists and the prompt does not reappear in normal use

### Requirement: Crash reporting respects consent

The crash-reporting SDK SHALL only run once consent is recorded (Release builds with a DSN); events queued or crashes occurring before acceptance SHALL NOT be captured or uploaded — an accepted privacy-first trade-off.

#### Scenario: Release launch before consent
- **WHEN** a configured Release build runs before the user accepts
- **THEN** the SDK is not started and no diagnostic traffic occurs
- **AND** starting happens automatically at consent time or next launch without reinstall

### Requirement: Declining leaves the app browsable

A user SHALL be able to complete/exit onboarding without consenting ("Not now — browse offline"). The app remains usable for local/offline content (catalog materials, saved lessons, settings); every AI-backed action stays behind the gate and re-presents the consent sheet on attempt.

#### Scenario: Decline then browse
- **WHEN** the user chooses "Not now — browse offline"
- **THEN** onboarding is completed (not replayed at next launch), no consent timestamp exists, and offline screens work

#### Scenario: Decline then attempt AI
- **WHEN** that user later sends a chat message or starts voice input
- **THEN** the consent sheet appears and nothing is transmitted until acceptance

### Requirement: In-app and public policy match actual data flows

The in-app Policy screen SHALL describe the shipped build's real processors, retention, and self-service deletion (replacing superseded "request deletion by email" and contradictory retention text), and the public privacy-policy URL referenced for the App Store SHALL be verified to present the same inventory before submission.

#### Scenario: Policy audit
- **WHEN** policy text (in-app and public) is compared to the network calls and storage of the shipped build
- **THEN** every data category leaving the device is named, deletion is self-service, and no contradictory statement remains
