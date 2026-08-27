## ADDED Requirements

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
