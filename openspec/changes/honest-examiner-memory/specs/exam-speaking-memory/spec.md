## ADDED Requirements

### Requirement: Persistent speaking-stage history
The app SHALL persist a campaign speaking conversation by account scope, lesson, and task stage. Reopening the same stage SHALL restore its existing user and examiner messages.

#### Scenario: Learner resumes a stage
- **WHEN** the learner leaves and reopens the same campaign speaking stage
- **THEN** the prior conversation is visible and the examiner does not send a duplicate opening line

#### Scenario: Learner opens another stage
- **WHEN** the learner switches to another stage in the same speaking task
- **THEN** that stage has its own independent conversation history

### Requirement: Refresh active speaking chat
The speaking screen SHALL provide a visible Refresh chat action that clears only the active stage's stored conversation and starts a new conversation with the examiner.

#### Scenario: Learner refreshes chat
- **WHEN** the learner taps Refresh chat
- **THEN** the active stage history is cleared and the examiner sends a new opening line

### Requirement: Learner context for the examiner
The app SHALL pass the bounded learner summary for the exam language through the exam contract when available. The server SHALL include that summary as candidate reference context in its server-owned instruction without allowing it to override the examiner role or task.

#### Scenario: Learner has a stored summary
- **WHEN** a speaking-stage request is sent for a learner with stored memory
- **THEN** the server instruction includes the candidate reference context and retains the assigned examiner task
