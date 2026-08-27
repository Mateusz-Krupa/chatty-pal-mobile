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
The exercises step of a campaign lesson SHALL present its required exercises in the lesson-defined sequence and provide a single check action for the current exercise group. Feedback SHALL persist until the learner changes an answer, and the step SHALL report its result to the mission outcome.

#### Scenario: Learner checks an exercise group
- **WHEN** the learner taps "Check answers" for the current required exercise group
- **THEN** the app evaluates every exercise in that group and shows success, error, or unanswered feedback with explanations

#### Scenario: Learner changes an answer after checking
- **WHEN** the learner changes a checked exercise answer
- **THEN** the prior feedback for that exercise clears and the learner can check the group again

#### Scenario: Mission records exercise outcome
- **WHEN** the learner finishes a lesson's required exercise groups
- **THEN** the mission outcome receives the completed exercise count and correct-answer count for star and review recommendations

### Requirement: Exam-style exercise progression
The campaign SHALL introduce task formats with guided examples before using them in a checkpoint or final mock exam.

#### Scenario: Learner encounters a new task format
- **WHEN** a lesson introduces a listening, reading, gap-fill, or multiple-choice format for the first time
- **THEN** the lesson provides a brief format explanation and a guided practice item before the exam-style item
