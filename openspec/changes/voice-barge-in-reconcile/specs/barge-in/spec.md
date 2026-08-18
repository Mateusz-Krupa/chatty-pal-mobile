# barge-in — Spec Delta

## ADDED Requirements

### Requirement: Learner can interrupt the bot

While the bot is waiting for its response or playing its response to a **voice-started** turn, the app SHALL continuously monitor the microphone with automatic echo cancellation and detect when the learner is speaking. Detection SHALL require voice energy above a threshold to be sustained for a minimum duration, so the bot's own speech and brief noises do not trigger an interruption. Barge-in SHALL be armed only for voice-started turns, not for typed turns.

#### Scenario: Learner speaks over the bot
- **WHEN** the bot is playing its response to a voice-started turn and the learner produces sustained voice energy above the threshold
- **THEN** the app detects the learner's speech as a barge-in

#### Scenario: Bot playing, learner silent
- **WHEN** the bot is speaking and the microphone reports no learner voice energy above the threshold
- **THEN** the bot continues and no interruption is triggered

#### Scenario: Brief noise does not interrupt
- **WHEN** a voice-energy blip above the threshold lasts shorter than the required sustain duration
- **THEN** no barge-in is triggered

#### Scenario: Typed turn never arms barge-in
- **WHEN** the bot responds to a typed (not spoken) message
- **THEN** the microphone is not monitored for barge-in and the bot plays its full response

### Requirement: Barge-in stops the bot and resumes listening

When barge-in is detected, the app SHALL stop the bot's in-progress response (text generation and speech playback) and immediately reopen the microphone so the learner can continue speaking.

#### Scenario: Learner interrupts a speaking bot
- **WHEN** barge-in is detected while the bot is playing its response
- **THEN** the bot stops speaking and generating, and the microphone reopens for the learner's next segment

#### Scenario: Learner interrupts before the bot starts speaking
- **WHEN** barge-in is detected while the bot is still generating (before speech begins)
- **THEN** generation is stopped and the microphone reopens

### Requirement: Interrupted turn is reconciled

When the learner interrupts the bot's turn, the app SHALL reconcile the transcript: the bot's interrupted response SHALL be removed from the conversation, and the learner's continuing utterance SHALL be merged with the interrupted utterance into a single user message before being sent to the bot.

#### Scenario: Interrupted bot reply is removed
- **WHEN** barge-in fires while the bot has an in-progress reply
- **THEN** that reply is removed from the transcript so it does not count as a delivered turn

#### Scenario: Continuation is merged with the interrupted utterance
- **WHEN** the learner finishes the segment that followed a barge-in
- **THEN** it is appended to the interrupted user message (one bubble) and the combined text is sent to the bot once

#### Scenario: A typed message cancels a pending merge
- **WHEN** the learner types a message instead of continuing to speak after a barge-in
- **THEN** the pending merge is discarded and the typed message is sent as its own user message

### Requirement: Echo cancellation during conversation turns

Voice conversation turns SHALL run the audio session in the play-and-record category with the voice-chat mode (automatic echo cancellation) so the bot's own speech is cancelled from the microphone signal, while playback still routes to the device speaker.

#### Scenario: Bot speech does not self-trigger
- **WHEN** the bot is speaking to the speaker during a voice turn
- **THEN** the bot's own audio is cancelled from the microphone signal and does not trigger a barge-in

#### Scenario: Playback still uses the speaker
- **WHEN** the bot plays a response during a barge-in turn
- **THEN** the audio is routed to the device speaker, not the earpiece
