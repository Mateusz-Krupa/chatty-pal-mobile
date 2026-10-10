# environment — Spec Delta

## MODIFIED Requirements

### Requirement: Live environment switching

Changing the environment or the local Web URL in Settings SHALL take effect without restarting the app: the chat engine and its services SHALL be rebuilt to point at the new origin. The environment switcher UI (Production/Local selector and custom URL field) SHALL exist only in Debug builds; Release builds SHALL always use the Production origin and SHALL ignore any persisted non-production value.

#### Scenario: Switch to Local applies immediately
- **WHEN** the learner switches the environment from Production to Local in Settings
- **THEN** subsequent bot, transcription, and TTS requests target the configured local Web URL without an app restart

#### Scenario: Conversation survives the switch
- **WHEN** the environment is switched
- **THEN** the existing conversation is preserved (reloaded from the local store)

#### Scenario: Release build hides the switcher
- **WHEN** a Release build opens Settings
- **THEN** no environment selector or custom server URL field is visible

#### Scenario: Stale non-production value in Release
- **WHEN** a Release build launches on a device that previously selected Local (e.g. from TestFlight)
- **THEN** all network requests go to Production regardless of the persisted value
