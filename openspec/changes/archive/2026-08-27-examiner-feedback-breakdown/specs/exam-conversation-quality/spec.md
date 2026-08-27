## MODIFIED Requirements

### Requirement: Mission-appropriate bot response
For an exam mission, the bot SHALL respond in concise German at A1 level, remain in its assigned role, and continue the active task stage. It SHALL gently ask a learner who writes in English to try again in German. When the learner completes a task or requests feedback, the bot SHALL give a truthful practice assessment with a factual summary of what the learner said, one concrete strength, one or two minimal contextual improvements, a `PASS`, `BORDERLINE`, or `NOT YET PASS` verdict, and one concrete next improvement. The assessment SHALL not claim to be an official Goethe result or invent learner statements.

#### Scenario: Learner requests detailed assessment
- **WHEN** the learner requests feedback after a speaking stage
- **THEN** the bot identifies what the learner said and gives minimal improvements tied to those statements
