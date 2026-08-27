# exam-progress Specification

## Purpose
TBD - created by archiving change exam-prep-goethe-a1. Update Purpose after archive.
## Requirements
### Requirement: Marking units complete
The app SHALL record campaign lesson completion locally, including the lesson ID, earned stars, completed exercise outcome, and completed speaking state when applicable. Completion data SHALL update campaign and review displays without deleting existing mapped Exam Prep completion records.

#### Scenario: Completing a lesson
- **WHEN** the learner reaches a lesson's required final step
- **THEN** the app persists the lesson as completed with its earned-star state and the lesson outcome screen reflects that state

#### Scenario: Progress survives app restart
- **WHEN** the learner relaunches the app after completing a campaign lesson
- **THEN** the campaign route and the completed lesson still show the saved completion and star state

#### Scenario: Existing exam completion is migrated
- **WHEN** the app reads a legacy completed exam-unit ID that maps to a campaign lesson
- **THEN** the mapped campaign lesson is shown as completed without removing the stored legacy ID

### Requirement: Progress overview
The Exam Prep home screen SHALL show campaign progress by zone, the learner's current available mission, completion indicators for completed lessons, and visual state for checkpoints and the final mock exam.

#### Scenario: Campaign progress on home
- **WHEN** the user opens the Exam Prep home with completed campaign lessons
- **THEN** each zone shows completed lessons out of its total and the next available mission is identifiable

#### Scenario: Checkpoint state on home
- **WHEN** a checkpoint's prerequisites are incomplete or complete
- **THEN** the campaign route shows the checkpoint as locked with its requirement or available to start, respectively

### Requirement: Mini-Examen
The campaign SHALL offer a final mixed mock exam after its prerequisite zones are complete. The mock exam SHALL assemble a fresh set of original tasks across available exam skills and show an in-session result summary without presenting it as an official Goethe score.

#### Scenario: Starting the final mock exam
- **WHEN** the learner taps an unlocked final mock-exam node
- **THEN** the app generates a fresh mixed task set and shows the first task with its exam-skill context

#### Scenario: Finishing the final mock exam
- **WHEN** the learner completes the last task of the mock exam
- **THEN** the app shows a skill-by-skill result summary, missed-task explanations where applicable, and recommended missions to replay
