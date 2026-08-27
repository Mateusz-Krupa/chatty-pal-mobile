# exam-conversation-quality Specification

## Purpose
exam-conversation-quality requirements (synced from redesign-exam-prep-campaign).

## Requirements
### Requirement: Exam conversation contract
The exam conversation API SHALL accept an explicit exam mode, lesson identifier, task stage, learner message, and one non-duplicated conversation history. The server SHALL own the authoritative instruction for each exam mode.

#### Scenario: Learner sends one conversation turn
- **WHEN** the learner sends a message during an exam mission
- **THEN** the model receives that learner message exactly once in the constructed conversation history

#### Scenario: Client supplies an exam mode
- **WHEN** the client requests an exam-speaking turn for a known lesson and task stage
- **THEN** the server applies the matching exam instruction rather than accepting a client-provided persona as authoritative

### Requirement: Mission-appropriate bot response
For an exam mission, the bot SHALL respond in concise German at A1 level, remain in its assigned role, and continue the active task stage. It SHALL gently ask a learner who writes in English to try again in German. When the learner completes a task or requests feedback, the bot SHALL give a truthful practice assessment with a factual summary of what the learner said, one concrete strength, one or two minimal contextual improvements, a `PASS`, `BORDERLINE`, or `NOT YET PASS` verdict, and one concrete next improvement. The assessment SHALL not claim to be an official Goethe result or invent learner statements.

#### Scenario: Learner requests detailed assessment
- **WHEN** the learner requests feedback after a speaking stage
- **THEN** the bot identifies what the learner said and gives minimal improvements tied to those statements

### Requirement: Conversation quality scenarios
The project SHALL maintain curated conversation scenarios for each supported exam mode and evaluate role adherence, A1 language, task continuation, response length, and English handling before changing the exam conversation contract or prompt.

#### Scenario: Contract test runs
- **WHEN** a developer runs the exam conversation contract test suite
- **THEN** deterministic provider fixtures verify the request shape and expected state transitions without calling a live model

#### Scenario: Live-model evaluation runs
- **WHEN** a configured live-model evaluation is run against the scenario set
- **THEN** each response is recorded with the scenario identifier and pass/fail rubric results for human review
