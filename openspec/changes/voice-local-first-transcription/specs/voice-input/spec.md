# voice-input — Spec Delta

## ADDED Requirements

### Requirement: On-device-first voice transcription

The app SHALL transcribe voice input on-device by default. A user-selectable setting SHALL switch voice transcription between on-device (default) and cloud Whisper.

#### Scenario: Default mode sends the on-device transcript
- **WHEN** the learner finishes a voice utterance and the setting is at its default
- **THEN** the on-device speech transcript is sent immediately without any cloud transcription request

#### Scenario: Cloud mode is opt-in
- **WHEN** the learner switches the setting to cloud Whisper
- **THEN** voice turns and shadowing attempts are transcribed by the cloud endpoint again, with the on-device transcript as fallback on failure

#### Scenario: Shadowing follows the setting
- **WHEN** the learner finishes a shadowing attempt in the default mode
- **THEN** the pronunciation score is computed from the on-device transcript without a cloud request
