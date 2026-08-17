# chat-voice-input Specification

## Purpose
TBD - created by archiving change chat-vad-voice-activity. Update Purpose after archive.
## Requirements
### Requirement: Voice activity detection for end-of-speech
The chat voice input SHALL compute the RMS level of each microphone audio buffer and treat energy above a voice threshold as speech activity. The silence timer that triggers transcript sending SHALL be reset whenever voice activity is detected, not only when a new partial transcription arrives.

#### Scenario: User pauses briefly mid-sentence
- **WHEN** the user stops producing audible speech for a duration shorter than the silence window and then continues speaking
- **THEN** the silence timer restarts on the new voice activity and the full sentence is sent as one message

#### Scenario: User stops talking
- **WHEN** the user has been silent (audio energy below the voice threshold) for the full silence window while recording
- **THEN** the app sends the accumulated transcript to the bot

#### Scenario: Silent user with no speech at all
- **WHEN** recording is active but no voice activity above the threshold is ever detected
- **THEN** the silence timer is not reset by transcription noise and no empty message is sent

### Requirement: Silence window tuned to real audio
The silence window SHALL be 1.2 seconds, measured on audio energy.

#### Scenario: Timing of the end-of-speech decision
- **WHEN** the last voice-above-threshold buffer arrives during recording
- **THEN** the transcript is eligible to be sent no earlier than 1.2 seconds after that buffer

### Requirement: Voice activity feedback in the listening bar
While recording, the chat SHALL display a live level indicator in the listening bar that reflects the current microphone voice level.

#### Scenario: User is speaking
- **WHEN** recording is active and the microphone reports voice energy above the threshold
- **THEN** the level indicator in the listening bar is visibly proportional to the reported level

#### Scenario: User is silent
- **WHEN** recording is active and the microphone reports energy below the threshold
- **THEN** the level indicator shrinks toward zero

#### Scenario: Recording stops
- **WHEN** recording ends for any reason (send, manual stop, error, interrupt)
- **THEN** the reported level resets to zero and no stale level is shown

### Requirement: Pure testable RMS computation
`SpeechController` SHALL expose a static pure function that computes the RMS of an audio buffer's first channel, so threshold math is unit-testable without a microphone.

#### Scenario: RMS of a constant-amplitude buffer
- **WHEN** the buffer contains constant samples of amplitude a
- **THEN** the returned RMS equals a

#### Scenario: RMS of a silent buffer
- **WHEN** the buffer contains only zero samples
- **THEN** the returned RMS is 0

