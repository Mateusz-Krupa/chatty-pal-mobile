## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: Exam-style exercise progression
The campaign SHALL introduce task formats with guided examples before using them in a checkpoint or final mock exam.

#### Scenario: Learner encounters a new task format
- **WHEN** a lesson introduces a listening, reading, gap-fill, or multiple-choice format for the first time
- **THEN** the lesson provides a brief format explanation and a guided practice item before the exam-style item
