## MODIFIED Requirements

### Requirement: Mission-appropriate bot response
For an exam mission, the bot SHALL respond in concise German at A1 level, remain in its assigned role, and continue the active task stage. It SHALL gently ask a learner who writes in English to try again in German. When the learner completes a task or asks for feedback, the bot SHALL give a truthful practice assessment: one strength, one specific weakness or missing requirement, a `PASS`, `BORDERLINE`, or `NOT YET PASS` verdict for that task, and one concrete next improvement. The assessment SHALL not claim to be an official Goethe result.

#### Scenario: Learner asks for assessment
- **WHEN** the learner asks how they performed after an exam task
- **THEN** the bot gives concise, evidence-based feedback and an honest task-level verdict instead of unconditional praise

#### Scenario: Learner performs below the task standard
- **WHEN** the learner misses key task requirements or cannot provide a relevant response
- **THEN** the bot identifies the gap and may return a `NOT YET PASS` verdict while remaining respectful and constructive
