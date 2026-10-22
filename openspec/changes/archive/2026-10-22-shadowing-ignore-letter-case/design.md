## Context

ShadowingScorer.cleanWords lowercases both inputs before fuzzy matching; ordinary case is already ignored but ß/SS expansions are not equivalent. Spoken case is not meaningful.

## Goals / Non-Goals

**Goals:** deterministic case-insensitive word normalization, including German ß/SS, with regression tests.

**Non-Goals:** removing accents, changing thresholds or fuzzy matching, rewriting stored transcripts or scores, new API/database behavior.

## Decisions

Use Foundation caseInsensitive folding with a fixed de_DE locale instead of simple lowercasing. Both inputs already share cleanWords, so one change covers scoring and match highlights. Do not enable diacriticInsensitive folding. Existing scoring version remains word-match-v1: this corrects normalization within its word-match contract and does not rescore historical attempts.

## Risks / Trade-offs

- Unicode expansion changes normalized output (ß becomes ss) → cover exact normalized tokens and scoring with tests; raw saved transcript remains unchanged.
- Fuzzy matching can conceal normalization failures → assert cleanWords equality as well as 100% word matches.

## Migration Plan

No migration; ship in the next mobile build after validation. Revert this focused change for rollback. No deployment performed.
