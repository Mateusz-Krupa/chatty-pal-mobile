# menu-navigation — Spec Delta

## ADDED Requirements

### Requirement: No placeholder destinations in the menu

Every entry shown in the slide-over menu SHALL navigate to a functional screen. The destinations without implementations — `teacherHelp` (currently enabled for ALL users), `classroom`, `stories`, `lessonPlanner` (currently visible-but-locked for non-teachers), the user profile panel, and the unused `chat` case — SHALL be removed from `MenuDestination` together with their rows, and `PlaceholderView` SHALL be deleted. The routing switch SHALL have no `default:` branch, so the compiler enforces that every remaining case has a real destination.

#### Scenario: Student menu audit
- **WHEN** a signed-in student opens the menu
- **THEN** every visible row opens a screen with real content (homework, chats, materials, exam prep, role play, info, policy) and nothing displays "Placeholder page"

#### Scenario: Teacher-visible locked rows
- **WHEN** a teacher user opens the menu
- **THEN** previously-locked-but-unimplemented rows (Classroom, My Stories, Lesson Planner) are absent rather than locked, and only implemented destinations are listed

#### Scenario: Compile-time completeness
- **WHEN** the target builds after this change
- **THEN** no `PlaceholderView` symbol exists in sources and the `MenuDestination` switch is exhaustive without a default branch

### Requirement: About Us reaches real content

The menu SHALL keep an About entry presenting the existing information screen (feature description, contact), not a stub.

#### Scenario: Open About
- **WHEN** the user taps About in the menu
- **THEN** the information screen with feature description and contact email opens
