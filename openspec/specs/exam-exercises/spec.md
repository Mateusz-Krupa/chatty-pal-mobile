# exam-exercises Specification

## Purpose
TBD - created by archiving change exam-prep-goethe-a1. Update Purpose after archive.
## Requirements
### Requirement: Multiple choice exercises
Units SHALL support multiple-choice exercises. Each exercise SHALL present a question, a list of options, exactly one correct option index, and an explanation.

#### Scenario: User answers a multiple choice question
- **WHEN** the user selects an option in a multiple-choice exercise
- **THEN** the selection is highlighted until the user checks their answers

#### Scenario: Checking a correct answer
- **WHEN** the user taps "Check answers" and their selection matches the correct option
- **THEN** the exercise shows a success indicator and the explanation text

#### Scenario: Checking a wrong answer
- **WHEN** the user taps "Check answers" and their selection does not match
- **THEN** the exercise shows an error indicator, reveals the correct option, and shows the explanation text

### Requirement: Gap fill exercises
Units SHALL support gap-fill exercises where the user chooses the missing word or phrase for a sentence from the provided options.

#### Scenario: User fills a gap
- **WHEN** the user selects an option for a gap-fill exercise and checks answers
- **THEN** the app applies the same feedback behavior as multiple choice (success/error indicator + explanation)

### Requirement: Listening exercises
Listening exercises SHALL contain a `spokenText` that the app synthesizes via TTS instead of a bundled audio file.

#### Scenario: Playing listening audio
- **WHEN** the user taps the play control on a listening exercise
- **THEN** the app plays the exercise's `spokenText` through TTS and the user answers the associated question

#### Scenario: Exercise without audio
- **WHEN** an exercise has no `spokenText`
- **THEN** the app does not show a play control for that exercise

### Requirement: Answer checking state
The exercises section of a unit SHALL have a single "Check answers" action that evaluates all answered exercises at once, and feedback SHALL persist until the user changes an answer.

#### Scenario: Unanswered exercise after check
- **WHEN** the user taps "Check answers" while an exercise has no selection
- **THEN** that exercise is marked as unanswered and reveals the correct option with its explanation

