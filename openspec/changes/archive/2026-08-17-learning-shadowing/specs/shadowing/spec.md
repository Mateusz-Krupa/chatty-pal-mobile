## ADDED Requirements

### Requirement: Shadowing practice in lessons
Each lesson detail SHALL provide a "Shadowing: Listen & Repeat" section where the user hears a phrase, records themselves, and receives per-word feedback.

#### Scenario: Hearing a phrase
- **WHEN** the user taps the speaker on a shadowing phrase
- **THEN** the app speaks the phrase via TTS

#### Scenario: Recording and getting feedback
- **WHEN** the user taps the mic, speaks, and taps the mic again
- **THEN** the app shows a percent score and the reference words colored by match (matched vs unmatched)

#### Scenario: Empty or failed recording
- **WHEN** the user stops recording with no recognized speech
- **THEN** no score is shown and nothing is added to the review queue

### Requirement: Weak phrases feed the review queue
Shadowing results below 60 percent SHALL automatically add the whole phrase to the word review queue.

#### Scenario: Low shadowing score
- **WHEN** the user's shadowing score for a phrase is below 60 percent
- **THEN** the phrase is added to the word review queue and the row shows a note that it was added

#### Scenario: Good shadowing score
- **WHEN** the user's shadowing score is 60 percent or higher
- **THEN** nothing is added to the review queue

### Requirement: Testable word matching
The shadowing scorer SHALL be a pure function that aligns reference words with spoken words, so it is unit-testable without a microphone.

#### Scenario: Word missing in speech
- **WHEN** the spoken transcript lacks one reference word
- **THEN** that word is reported unmatched and the percent score drops accordingly

#### Scenario: Extra filler words in speech
- **WHEN** the spoken transcript contains extra words not in the reference
- **THEN** all reference words that are present are still reported matched
