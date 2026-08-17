# exam-speaking-practice Specification

## Purpose
TBD - created by archiving change exam-prep-goethe-a1. Update Purpose after archive.
## Requirements
### Requirement: Speaking task entry point
A unit that has a speaking scenario SHALL show a "Practice speaking" card in its detail screen, opening the speaking practice screen.

#### Scenario: User starts a speaking task
- **WHEN** the user taps "Practice speaking" on a unit that has a speaking scenario
- **THEN** the app opens the speaking practice screen for that unit

#### Scenario: Unit without scenario
- **WHEN** a unit has no speaking scenario
- **THEN** the unit detail does not show a "Practice speaking" card

### Requirement: Examiner persona
The speaking practice SHALL use a bot configured as the Goethe A1 oral exam examiner. The persona SHALL drive the conversation using the unit's speaking scenario, speak at A1 level in German, and provide brief encouraging feedback on the user's answers.

#### Scenario: Examiner follows the scenario
- **WHEN** the user completes a part of the speaking scenario
- **THEN** the bot moves the conversation to the next part of the scenario

#### Scenario: User writes in English
- **WHEN** the user sends a message in English during practice
- **THEN** the bot responds in German and gently prompts the user to continue in German

### Requirement: Temporary conversation
Speaking practice conversations SHALL NOT be saved to the main chat history and SHALL start empty on every launch.

#### Scenario: Reloading a speaking task
- **WHEN** the user finishes a speaking task and later opens the same task again
- **THEN** the conversation starts fresh without previous messages

#### Scenario: Main chat unaffected
- **WHEN** the user returns to the main chat after a speaking task
- **THEN** the main chat history contains no messages from the speaking task

### Requirement: Automatic start
The speaking practice screen SHALL start the conversation automatically by sending an opening line to the bot when opened.

#### Scenario: Opening the practice screen
- **WHEN** the speaking practice screen appears
- **THEN** the app sends the opening line and the bot responds without user action

### Requirement: User input and finish
The speaking practice screen SHALL allow the user to respond by voice (microphone) or by text using the shared chat input, and SHALL provide a "Finish practice" action that ends the session and returns to the unit.

#### Scenario: Voice response
- **WHEN** the user records a voice message during practice
- **THEN** the transcript is sent to the bot and the bot's spoken answer is played

#### Scenario: Finishing practice
- **WHEN** the user taps "Finish practice"
- **THEN** any active speech or generation is interrupted and the app returns to the unit detail

#### Scenario: Leaving the screen
- **WHEN** the user navigates away from the speaking practice screen
- **THEN** active TTS playback and bot generation are stopped

