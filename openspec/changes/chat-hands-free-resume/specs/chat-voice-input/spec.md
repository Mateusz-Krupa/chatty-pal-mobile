## MODIFIED Requirements

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
