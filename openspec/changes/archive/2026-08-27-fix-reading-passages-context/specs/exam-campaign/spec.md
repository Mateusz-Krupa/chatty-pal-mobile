## MODIFIED Requirements

### Requirement: Reading task context
A campaign lesson that practices reading SHALL declare its reading content as an ordered list of passages, where each passage binds a titled text to the questions that reference that text. The lesson's exam task step SHALL display every passage's text immediately before its own questions, in the declared order, so the learner always sees the source text for each question. A lesson SHALL NOT present a reading question whose passage text is not displayed in the same step.

#### Scenario: Lesson with a single passage
- **WHEN** the learner opens the exam task step of a lesson with one reading passage
- **THEN** the passage text is shown followed by that passage's questions

#### Scenario: Lesson with multiple passages
- **WHEN** the learner opens the exam task step of a lesson that mixes questions from several source texts
- **THEN** each source text is shown with its own questions grouped directly underneath it, in the declared order

#### Scenario: Question always has visible context
- **WHEN** the learner reads any reading question in a campaign lesson or its mission outcome
- **THEN** the passage the question refers to is displayed in the same step
