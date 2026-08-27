# exam-prep Specification

## Purpose
TBD - created by archiving change exam-prep-goethe-a1. Update Purpose after archive.
## Requirements
### Requirement: Exam Prep entry point in menu
The app SHALL provide an "Exam Prep A1" entry in the Student section of the main menu, opening the Exam Prep home screen.

#### Scenario: User opens Exam Prep from menu
- **WHEN** the user taps "Exam Prep A1" in the menu
- **THEN** the app navigates to the Exam Prep home screen with sections listed

#### Scenario: Menu entry is always available
- **WHEN** the user opens the Student section of the menu
- **THEN** the "Exam Prep A1" row is enabled (not disabled by login state or language)

### Requirement: Exam Prep home lists exam sections
The Exam Prep home screen SHALL show the ordered Goethe A1 campaign route rather than a flat list of four section cards. The route SHALL make its zones, current mission, available missions, locked prerequisites, checkpoint missions, and final mock-exam node navigable or visibly explained.

#### Scenario: Home shows campaign route
- **WHEN** the user opens the Exam Prep home
- **THEN** the app shows campaign nodes in their defined sequence with their current availability and completion state

#### Scenario: User opens an available mission
- **WHEN** the user taps an available campaign lesson or checkpoint
- **THEN** the app opens that mission's briefing or resumable lesson flow

#### Scenario: User views a locked mission
- **WHEN** the user taps or inspects a locked campaign node
- **THEN** the app shows which prerequisite lesson or checkpoint must be completed before it can start

### Requirement: Catalog of exam units
The app SHALL contain a static, in-app catalog of ordered Goethe A1 campaign lessons. Each lesson SHALL have a unique ID, zone, order, title, learner-facing goal, and at least one of: preparation content, exercises, a speaking task, or a writing prompt. Content that practices an exam skill SHALL also identify one of Lesen, Hören, Sprechen, or Schreiben.

#### Scenario: Campaign catalog is complete and unique
- **WHEN** the app loads the campaign catalog
- **THEN** every lesson has a unique ID, a single order within its zone, and a valid campaign position

#### Scenario: Supporting content is truthfully classified
- **WHEN** the app loads vocabulary or grammar preparation content
- **THEN** it is associated with its lesson goal and is not labelled as a Lesen unit unless it contains a reading task

### Requirement: Unit detail shows unit content
The unit detail screen SHALL display the parts of the unit that are present: intro text, vocabulary (German/English with examples), phrases (with audio playback), and dialogue (with audio playback).

#### Scenario: Vocabulary card renders
- **WHEN** the user opens a unit that has vocabulary
- **THEN** each vocabulary item shows the German word, its English translation, and the example sentence

#### Scenario: Phrase and dialogue audio
- **WHEN** the user taps the play control on a phrase or dialogue line
- **THEN** the app synthesizes and plays the German text via TTS and stops any previously playing audio

#### Scenario: Optional parts are hidden
- **WHEN** a unit has no dialogue
- **THEN** the unit detail does not show a dialogue card

### Requirement: German A1 content scope
The campaign SHALL cover practical German A1 language goals and all Goethe A1 exam skills: Lesen, Hören, Sprechen, and Schreiben. It SHALL include at least 12 vocabulary themes and 10 grammar objectives as support for missions, at least one mission for each exam skill, recurring exam-style tasks, checkpoints, and a final mixed mock exam.

#### Scenario: Content volume and distribution
- **WHEN** the app loads the campaign catalog
- **THEN** the catalog contains at least 12 vocabulary themes, at least 10 grammar objectives, at least one mission for every exam skill, and at least one checkpoint after a group of lessons
