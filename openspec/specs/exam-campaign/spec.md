# exam-campaign Specification

## Purpose
exam-campaign requirements (synced from redesign-exam-prep-campaign).

## Requirements
### Requirement: Ordered Goethe A1 campaign
The app SHALL present Exam Prep A1 as a fixed-order campaign of named zones, lessons, checkpoints, and one final mock-exam node. Each campaign node SHALL have a unique identifier, order, title, short learner-facing goal, and state.

#### Scenario: Learner opens Exam Prep
- **WHEN** the learner opens Exam Prep A1 from the menu
- **THEN** the app shows the campaign route in its defined order with the learner's current and next available mission visible

#### Scenario: Learner completes a mission
- **WHEN** the learner completes a campaign lesson
- **THEN** the next campaign node becomes available when its prerequisites are satisfied

#### Scenario: Learner revisits material
- **WHEN** the learner opens an already available or completed campaign node
- **THEN** the app allows replay without removing its existing completion or star state

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

### Requirement: Checkpoint missions
The campaign SHALL include checkpoint missions after coherent groups of lessons and a final mock-exam node after all campaign zones.

#### Scenario: Checkpoint unlocks
- **WHEN** the learner has completed the lessons required by a checkpoint
- **THEN** the checkpoint is shown as available in the route

#### Scenario: Final mock exam remains locked
- **WHEN** the learner has not completed all required campaign zones
- **THEN** the final mock-exam node shows its requirements and cannot be started

### Requirement: Game-inspired progress is learning-focused
The campaign SHALL communicate progress with lesson states, stars, checkpoints, and clear next actions. It SHALL NOT require unrelated currencies or random rewards to continue learning.

#### Scenario: Learner views a completed lesson
- **WHEN** the learner returns to the campaign route after completing a lesson
- **THEN** the lesson shows its completion and earned-star state alongside the next recommended action
