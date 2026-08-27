# Design: Examiner Feedback Breakdown

## Flow

Tapping Finish practice sends a hidden, explicit feedback request through the existing exam conversation contract instead of immediately dismissing the screen. It does not add a synthetic learner bubble to the transcript; the examiner response appears as the final assistant message. Once that response completes, the action becomes Close practice.

The finish action is disabled while a response is generating. Sending another learner message after feedback restores Finish practice so the learner can continue the conversation and request a fresh final assessment.

## Feedback Format

When the candidate finishes a task or requests feedback, the examiner responds in simple German with these headings:

1. `Du hast gesagt` — factual one or two bullet summary of the learner's actual statements.
2. `Gut` — one concrete strength.
3. `Besser so` — one or two minimal corrections or better alternatives, preserving the learner's intended meaning.
4. `Urteil` — `PASS`, `BORDERLINE`, or `NOT YET PASS` for this practice task.
5. `Nächster Schritt` — one actionable improvement.

The prompt explicitly forbids inventing learner statements and rewriting the entire answer when a small correction suffices.

## Compatibility

The request is sent through the existing bot endpoint and exam contract. No API shape changes or new storage are required.
