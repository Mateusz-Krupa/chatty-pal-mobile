# environment Specification

## Purpose
TBD - created by archiving change environment-switch-live. Update Purpose after archive.
## Requirements
### Requirement: Live environment switching

Changing the environment or the local Web URL in Settings SHALL take effect without restarting the app: the chat engine and its services SHALL be rebuilt to point at the new origin.

#### Scenario: Switch to Local applies immediately
- **WHEN** the learner switches the environment from Production to Local in Settings
- **THEN** subsequent bot, transcription, and TTS requests target the configured local Web URL without an app restart

#### Scenario: Conversation survives the switch
- **WHEN** the environment is switched
- **THEN** the existing conversation is preserved (reloaded from the local store)

