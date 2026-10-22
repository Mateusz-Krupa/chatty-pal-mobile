## Why

Letter case has no spoken equivalent and must not affect shadowing scores. Existing lowercasing handles ordinary case but not Unicode case expansions such as German ß versus SS.

## What Changes

- Use Unicode case folding on both reference and recognized speech before matching.
- Add explicit regression coverage for uppercase, lowercase, mixed case and German sharp S while retaining accents and meaningful word differences.
- Keep raw transcripts and the existing persisted completion API unchanged; Mark as done already persists in CMS.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `shadowing`: Require case-independent scoring, including Unicode case expansions.

## Impact

Mobile ShadowingScorer and unit tests only. No dependencies, production actions, database changes or retroactive rescoring.
