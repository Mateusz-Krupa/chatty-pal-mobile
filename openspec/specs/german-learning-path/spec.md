# german-learning-path Specification

## Purpose
TBD - created by archiving change rebuild-german-lesson-path. Update Purpose after archive.
## Requirements
### Requirement: Grammar-progression German lesson path

The German learning catalog SHALL present a sequential grammar-progression path of 14 lessons (`de-g-01`…`de-g-14`) from A1 pronunciation and gender to A2 present perfect and separable verbs, replacing the previous scenario-only lessons. Each lesson SHALL declare level, topic, a short intro, three can-do goals, target phrases with translations, 5-6 vocabulary items with usage notes, an original dialogue, and an AI practice prompt scoped to the lesson's structure.

#### Scenario: Learner opens the German lesson path

- **WHEN** the learner opens the German lesson path screen
- **THEN** 14 lessons are listed in grammar-progression order with A1 lessons before A2 lessons
- **AND** each lesson shows its title, description, level badge, and topic

#### Scenario: Lesson opens word review

- **WHEN** the learner starts practice on any lesson
- **THEN** that lesson's vocabulary and phrases are added to the word-review store under source `lesson:<de-g-NN>` with no code changes to the review pipeline

### Requirement: Independently authored content

All text in the German lesson path SHALL be newly authored original content. The copyrightable text of any third-party book (including "Easy German Step-by-Step") SHALL NOT be copied or paraphrased; only uncopyrightable grammar facts, conjugation paradigms, and the conventional A1→A2 topic sequence may inform the path.

#### Scenario: Dialogue uses only original sentences

- **WHEN** any lesson dialogue or example sentence is inspected
- **THEN** it is an original sentence written for this app, using vocabulary appropriate to the cumulative lessons up to that point

### Requirement: Two-voice conversation playback

The lesson detail view SHALL provide a control that plays the whole conversation example in one action: each line is synthesized through the speech service and played sequentially, with the currently playing line visually highlighted. For German lessons the two speakers SHALL use two distinct voice ids. Starting playback of a single item or leaving the view SHALL stop conversation playback.

#### Scenario: Play the whole dialogue

- **WHEN** the learner taps Play all on the Conversation Example section
- **THEN** every line plays in order, the active line shows the playing indicator, and playback stops at the end

#### Scenario: Alternate voice unavailable

- **WHEN** synthesis of a line with the alternate voice fails
- **THEN** that line is retried with the lesson's default voice and the sequence continues

### Requirement: Cumulative comprehensibility

Each lesson's dialogue SHALL only use vocabulary and grammar taught in that lesson or earlier lessons, so a learner who completes lesson N can understand dialogue N without unknown material.

#### Scenario: Late-lesson dialogue stays within taught material

- **WHEN** the learner reads the dialogue of lesson 12 (spoken perfect)
- **THEN** every grammar structure in it belongs to lessons 1–12, and every new word either appears in that lesson's vocabulary/phrases or carries a direct English translation on its dialogue line

