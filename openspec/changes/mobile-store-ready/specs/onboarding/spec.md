# onboarding — Spec Delta

## ADDED Requirements

### Requirement: One-time first-run onboarding

On first launch after install (and only then) the app SHALL show a full-screen onboarding flow explaining the product before the main chat is reachable, independent of sign-in state. Completion SHALL persist per device install and survive sign-out.

#### Scenario: Fresh install opens onboarding
- **WHEN** the app launches for the first time on a device
- **THEN** onboarding is shown and the chat is not interactive behind it

#### Scenario: Returning users skip onboarding
- **WHEN** the app launches again after onboarding was completed
- **THEN** the chat opens directly with no onboarding flash

#### Scenario: Sign-out does not replay onboarding
- **WHEN** a user who completed onboarding signs out and returns
- **THEN** onboarding is not shown again

### Requirement: Primed microphone and speech permissions

The onboarding flow SHALL contain a dedicated step that explains why the microphone and speech recognition are needed and requests both permissions from an explicit user action on that step.

#### Scenario: User grants from the permission step
- **WHEN** the user taps the permission button on the microphone step and accepts both system dialogs
- **THEN** voice chat is ready and no unexpected system permission dialog appears later during chatting

#### Scenario: User declines permissions
- **WHEN** the user declines either system dialog
- **THEN** onboarding still allows continuing and typed chat works, with voice features degrading exactly as they do today after a later denial

### Requirement: Sign-in choice after consent

The onboarding flow's final step SHALL present the data/consent disclosure (see `privacy-consent`) with three explicit actions: "I agree — Sign in" (opens the existing login panel), "I agree — Start practicing" (guest), and "Not now — browse offline" (completes onboarding WITHOUT recording consent). The two agreeing actions record the consent timestamp and complete onboarding immediately; the decline action records none. No path may be hidden or penalized.

#### Scenario: Consent step not skippable
- **WHEN** the user pages through onboarding
- **THEN** consent is only ever recorded via an explicit "I agree — …" action on the disclosure step

#### Scenario: Guest path
- **WHEN** the user chooses "I agree — Start practicing"
- **THEN** consent is recorded, onboarding completes, and the chat is usable immediately without any account

#### Scenario: Offline decline path
- **WHEN** the user chooses "Not now — browse offline"
- **THEN** onboarding completes without a consent record and is not replayed on next launch; AI actions remain gated per `privacy-consent`

#### Scenario: Login path from onboarding
- **WHEN** the user completes sign-in via "I agree — Sign in"
- **THEN** the panel closes and the user lands in the chat as a signed-in user

#### Scenario: Login cancelled after agreeing
- **WHEN** the user tapped "I agree — Sign in" but cancels the login panel
- **THEN** the user lands in the chat as a consented guest: consent remains recorded, onboarding is not replayed, and AI actions work without re-prompting
