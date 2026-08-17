# exam-progress Specification

## Purpose
TBD - created by archiving change exam-prep-goethe-a1. Update Purpose after archive.
## Requirements
### Requirement: Marking units complete
The unit detail screen SHALL provide a "Mark as complete" action that records the unit as completed locally (UserDefaults) and updates all progress displays.

#### Scenario: Completing a unit
- **WHEN** the user taps "Mark as complete" on a unit
- **THEN** the app persists the unit ID as completed and the action state changes to "Completed"

#### Scenario: Progress survives app restart
- **WHEN** the user relaunches the app and opens a previously completed unit
- **THEN** the unit is still shown as completed

### Requirement: Progress overview
The Exam Prep home screen SHALL show, per section, how many units are completed out of the total, and a completion indicator on each unit row in section views.

#### Scenario: Section progress on home
- **WHEN** the user opens the Exam Prep home with some units completed
- **THEN** each section card shows "x / y" completed units

#### Scenario: Unit completion indicator
- **WHEN** the user opens a section view
- **THEN** completed units show a completion indicator (e.g., checkmark) next to their title

### Requirement: Mini-Examen
The Exam Prep home SHALL offer a "Mini-Examen" that assembles a random mixed set of exercises from the catalog (multiple choice and gap fill, at least one per exam section where available) and presents them one by one.

#### Scenario: Starting a mini exam
- **WHEN** the user taps "Mini-Examen"
- **THEN** the app generates a fresh random exercise set each time and shows the first exercise

#### Scenario: Finishing a mini exam
- **WHEN** the user answers the last exercise of the set
- **THEN** the app shows a result summary with the number of correct answers and the explanation for each missed exercise

#### Scenario: No results stored
- **WHEN** the user finishes a mini exam
- **THEN** the result is shown only in-session and is not persisted

