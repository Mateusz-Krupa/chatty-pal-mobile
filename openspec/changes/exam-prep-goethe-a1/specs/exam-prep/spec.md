## ADDED Requirements

### Requirement: Exam Prep entry point in menu
The app SHALL provide an "Exam Prep A1" entry in the Student section of the main menu, opening the Exam Prep home screen.

#### Scenario: User opens Exam Prep from menu
- **WHEN** the user taps "Exam Prep A1" in the menu
- **THEN** the app navigates to the Exam Prep home screen with sections listed

#### Scenario: Menu entry is always available
- **WHEN** the user opens the Student section of the menu
- **THEN** the "Exam Prep A1" row is enabled (not disabled by login state or language)

### Requirement: Exam Prep home lists exam sections
The Exam Prep home screen SHALL list the exam sections (Lesen, Hören, Sprechen, Schreiben) as navigable cards, each showing the number of units in that section.

#### Scenario: Home shows all four sections
- **WHEN** the user opens the Exam Prep home
- **THEN** cards for Lesen, Hören, Sprechen and Schreiben are visible, each with a unit count taken from the catalog

#### Scenario: User navigates into a section
- **WHEN** the user taps a section card
- **THEN** the app shows the list of units belonging to that section

### Requirement: Catalog of exam units
The app SHALL contain a static, in-app catalog of Goethe A1 exam units. Each unit SHALL have a unique ID, a section, a title, a subtitle, and at least one of: text, vocabulary, phrases, dialogue, exercises, a speaking scenario, or a writing prompt.

#### Scenario: Catalog is complete and unique
- **WHEN** the app loads the exam catalog
- **THEN** every unit has a unique ID and belongs to exactly one section

#### Scenario: Section view lists its units
- **WHEN** the user opens a section
- **THEN** the app shows all units of that section from the catalog, each tappable

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
The exam catalog SHALL cover the Goethe A1 scope: exam sections (Lesen, Hören, Sprechen, Schreiben) plus supporting units for vocabulary (at least 12 topic units) and grammar (at least 10 units), all in German at A1 level with English support text.

#### Scenario: Content volume
- **WHEN** the app loads the exam catalog
- **THEN** the catalog contains at least 12 vocabulary units, at least 10 grammar units, and at least one unit in each of the four exam sections
