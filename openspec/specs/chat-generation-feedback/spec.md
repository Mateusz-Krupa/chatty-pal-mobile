# chat-generation-feedback Specification

## Purpose
TBD - created by archiving change chat-generation-feedback. Update Purpose after archive.
## Requirements
### Requirement: Bot thinking indicator

The chat SHALL show the "Thinking..." indicator while the bot response is in flight (from send until the response is appended or the request fails).

#### Scenario: Waiting for the bot
- **WHEN** a user message was just sent and the bot has not responded yet
- **THEN** the message list shows the "Thinking..." indicator

#### Scenario: Indicator disappears after the reply
- **WHEN** the bot response is appended (or the request fails and the error message is appended)
- **THEN** the "Thinking..." indicator is gone

### Requirement: Transcribing indicator for voice turns

The chat SHALL show a "Transcribing..." indicator between the end of a recorded voice utterance and the moment the transcribed text is sent.

#### Scenario: Voice turn is being transcribed
- **WHEN** the learner stops speaking and the recording is being sent to the transcription endpoint
- **THEN** the chat shows the "Transcribing..." indicator

#### Scenario: Indicator disappears when sending
- **WHEN** the transcription returns (or falls back to the local transcript) and the text is sent
- **THEN** the "Transcribing..." indicator is replaced by the normal send flow

