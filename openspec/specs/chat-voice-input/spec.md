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
The silence window SHALL be 3.0 seconds, measured on audio energy, to absorb the thinking pauses typical of language learners composing a sentence.

#### Scenario: Timing of the end-of-speech decision
- **WHEN** the last voice-above-threshold buffer arrives during recording
- **THEN** the transcript is eligible to be sent no earlier than 3.0 seconds after that buffer

#### Scenario: Learner pauses to think mid-sentence
- **WHEN** the user stops producing audible speech for less than 3.0 seconds and then continues speaking
- **THEN** the silence timer restarts on the new voice activity and the full sentence is sent as one message

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

### Requirement: Push-to-talk flow
The chat voice input SHALL follow a hands-free turn model: the microphone opens when the user taps the mic button while idle, stays closed while the bot is waiting for a response, generating it, or playing it back, and reopens automatically after the bot's response finishes playing when the user's turn was started by voice.

#### Scenario: User starts listening
- **WHEN** the user taps the mic button while the chat is idle
- **THEN** recording starts and the listening bar with the live level indicator is shown

#### Scenario: User taps the mic while it is recording
- **WHEN** the user taps the mic button while recording
- **THEN** recording stops, the accumulated transcript is sent, and the bot flow starts

#### Scenario: User taps the mic during the bot turn
- **WHEN** the user taps the mic button while the bot is waiting for a response, thinking, or playing its answer
- **THEN** nothing happens, recording does not start, and the mic button appears disabled

#### Scenario: Voice turn finishes
- **WHEN** the bot's response to a voice-started turn finishes playing (or TTS is disabled and the reply is appended)
- **THEN** the chat returns to idle and the microphone reopens automatically after a short settle delay, so the user can speak again without tapping

#### Scenario: Typed text turn finishes
- **WHEN** the bot's response to a typed message finishes playing
- **THEN** the chat returns to idle and the microphone stays closed until the user taps the mic

#### Scenario: User manually stops recording
- **WHEN** the user taps the mic button to stop recording manually and the bot responds
- **THEN** after the bot's response the microphone stays closed until the user taps the mic

### Requirement: One utterance per turn
A single recorded turn SHALL be sent as one user message. A recognition `isFinal` event SHALL refresh the shown transcript but SHALL NOT end the turn; the turn ends only when the VAD silence window expires or the user taps the mic manually.

#### Scenario: Recognizer emits a final mid-sentence
- **WHEN** an `isFinal` result arrives while the user is still speaking (a pause longer than the recognizer's internal gap)
- **THEN** no message is sent, the microphone keeps recording, and the transcript continues to accumulate

#### Scenario: User finishes the sentence
- **WHEN** the user stops speaking and audio energy stays below the voice threshold for the silence window
- **THEN** the complete accumulated transcript is sent as a single user message

