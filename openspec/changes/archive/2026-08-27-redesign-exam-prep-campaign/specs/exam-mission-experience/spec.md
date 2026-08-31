## MODIFIED Requirements

### Requirement: Outcome and recommended review
At the end of a mission, the app SHALL show completion state, earned stars, one or more strengths, and a bounded list of words or skills recommended for review. The mission outcome screen SHALL always be reachable from the last mission step through the footer action. When the learner reached at least 80% correct answers, the outcome SHALL show a prominent "Complete" action inside the result box and "Close" + "Complete" actions in the footer. Completing the mission SHALL be the only way to record it as completed. When the learner reached less than 80%, the outcome SHALL show "Close" + "Replay" in the footer and the result box SHALL explain the 80% requirement without a Complete action.

#### Scenario: Learner finishes a mission
- **WHEN** the learner reaches the final required lesson step
- **THEN** the app shows an outcome screen with a replay action and a clear next campaign action

#### Scenario: Learner needs more practice
- **WHEN** the learner completes a mission with unanswered or incorrect exercise items
- **THEN** the outcome identifies the relevant review area without blocking campaign progress

#### Scenario: Learner finishes with 80% or more
- **WHEN** the learner reaches the mission outcome with at least 80% correct answers
- **THEN** the result box shows a "Complete" action and the footer shows "Close" and "Complete"

#### Scenario: Learner completes the mission
- **WHEN** the learner taps "Complete" on the outcome screen
- **THEN** the mission is recorded as completed, words are collected for review, and the campaign home shows the next mission available

#### Scenario: Learner finishes below 80%
- **WHEN** the learner reaches the mission outcome with less than 80% correct answers
- **THEN** the footer shows "Close" and "Replay" and the result box explains that 80% correct is required to complete the mission

## ADDED Requirements

### Requirement: Complete mission flow
Each campaign lesson SHALL present a bounded sequence of mission briefing, focused preparation, guided exercises, an exam-style task, and a completion outcome. The lesson SHALL expose a learner-facing can-do goal before the first activity.

#### Scenario: Learner starts a lesson
- **WHEN** the learner opens an available campaign lesson
- **THEN** the app shows the lesson goal, expected mission steps, and an action to begin

#### Scenario: Learner advances through a lesson
- **WHEN** the learner completes the current mission step
- **THEN** the app advances to the next required step without requiring the learner to locate unrelated content in a long detail screen

### Requirement: Contextual conversation step
A lesson whose learning goal requires spoken interaction SHALL include a contextual conversation step after its preparation activities. The step SHALL identify the active mission goal and task stage to the learner.

#### Scenario: Learner reaches speaking practice
- **WHEN** the learner completes the preparation steps of a speaking lesson
- **THEN** the app opens a conversation that visibly states the current goal and task stage

#### Scenario: Lesson without spoken production
- **WHEN** the lesson's learning goal does not require spoken production
- **THEN** the lesson completes through its relevant exam-style task without showing an unrelated speaking step

### Requirement: Mobile-friendly mission interface
The mission flow SHALL use the existing Chatty visual language and remain understandable on a phone without relying solely on color to communicate state.

#### Scenario: Learner uses accessibility settings
- **WHEN** the learner uses Dynamic Type or VoiceOver
- **THEN** mission order, controls, progress state, and exercise feedback remain readable and operable
