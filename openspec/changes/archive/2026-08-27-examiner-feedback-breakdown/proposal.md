## Why

The examiner can provide a verdict but its feedback is not reliably requested before the learner exits practice, and it lacks a learner-facing breakdown of what the learner said and how they could say it better.

## What Changes

- Make the final Finish practice action request the examiner feedback before the learner can close the practice screen.
- Require structured German examiner feedback: summary of what the learner said, strengths, minimal better alternatives, honest verdict, and next step.
- Keep feedback as a practice assessment, not an official Goethe result.

## Capabilities

### New Capabilities

- `exam-feedback-breakdown`: Learner-requested structured speaking feedback.

### Modified Capabilities

- `exam-conversation-quality`: Examiner feedback includes a factual learner summary and minimal, contextual improvements.

## Impact

- iOS campaign speaking UI and chat engine.
- Web exam prompt and Jest contract tests.
