## MODIFIED Requirements

### Requirement: Automatic word collection
The review queue SHALL be filled automatically from learning and completed campaign content; the user SHALL NOT need to add words manually. A campaign lesson SHALL add its eligible vocabulary and phrases after the learner completes its mission, rather than merely opening preparation content.

#### Scenario: Opening a non-campaign lesson
- **WHEN** the user opens a non-campaign lesson's detail or starts its practice
- **THEN** the lesson's vocabulary and phrases are added to the review queue

#### Scenario: Completing a campaign lesson
- **WHEN** the user completes an Exam Prep campaign lesson
- **THEN** the lesson's eligible vocabulary and phrases are added to the review queue

#### Scenario: Replaying a completed campaign lesson
- **WHEN** the user completes a campaign lesson that has already added its vocabulary to the review queue
- **THEN** the existing cards and their schedules are preserved

#### Scenario: Duplicate word from two sources
- **WHEN** the same German word is added from two different sources
- **THEN** only one card exists and its existing schedule is preserved
