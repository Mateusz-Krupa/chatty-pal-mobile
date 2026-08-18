# listening-indicator — Spec Delta

## ADDED Requirements

### Requirement: Shared live listening indicator

Every voice-input surface (chat, shadowing) SHALL show the same live listening UI while recording: a "Listening..." label that is replaced by the live transcript text as the learner speaks, plus a red audio-level bar reflecting the input volume.

#### Scenario: Chat shows the live listening UI
- **WHEN** the learner is recording in the chat
- **THEN** the chat shows the live transcript text (or "Listening...") above a red level bar

#### Scenario: Shadowing shows the same live listening UI
- **WHEN** the learner is recording a shadowing phrase
- **THEN** the phrase row shows the live transcript text (or "Listening...") and a red level bar, styled identically to the chat
