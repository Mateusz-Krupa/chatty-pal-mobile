## ADDED Requirements

### Requirement: Exam conversation contract
The exam conversation API SHALL accept an explicit exam mode, lesson identifier, task stage, learner message, and one non-duplicated conversation history. The server SHALL own the authoritative instruction for each exam mode.

#### Scenario: Learner sends one conversation turn
- **WHEN** the learner sends a message during an exam mission
- **THEN** the model receives that learner message exactly once in the constructed conversation history

#### Scenario: Client supplies an exam mode
- **WHEN** the client requests an exam-speaking turn for a known lesson and task stage
- **THEN** the server applies the matching exam instruction rather than accepting a client-provided persona as authoritative

### Requirement: Mission-appropriate bot response
For an exam mission, the bot SHALL respond in concise German at A1 level, remain in its assigned role, and continue the active task stage. It SHALL gently ask a learner who writes in English to try again in German.

#### Scenario: Learner responds in German
- **WHEN** the learner gives a relevant German response during an active stage
- **THEN** the bot acknowledges it briefly and advances or continues that stage according to the mission contract

#### Scenario: Learner responds in English
- **WHEN** the learner writes in English during an exam mission
- **THEN** the bot responds in simple German and invites the learner to answer in German without ending the mission

### Requirement: Conversation quality scenarios
The project SHALL maintain curated conversation scenarios for each supported exam mode and evaluate role adherence, A1 language, task continuation, response length, and English handling before changing the exam conversation contract or prompt.

#### Scenario: Contract test runs
- **WHEN** a developer runs the exam conversation contract test suite
- **THEN** deterministic provider fixtures verify the request shape and expected state transitions without calling a live model

#### Scenario: Live-model evaluation runs
- **WHEN** a configured live-model evaluation is run against the scenario set
- **THEN** each response is recorded with the scenario identifier and pass/fail rubric results for human review
