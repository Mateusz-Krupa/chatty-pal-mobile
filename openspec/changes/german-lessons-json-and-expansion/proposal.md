# Proposal: German lessons as bundled JSON + expand path to book-step granularity (36 lessons)

## Why

The 14-lesson grammar path covers the full scope of the reference book but compresses 2-4 book "steps" into one lesson. Learners get fewer completion moments and each lesson carries more new grammar than a single-sitting session should. Book-step granularity (small, winnable lessons) fits a mobile habit app better. At 36 lessons, hard-coded Swift content also becomes painful to maintain and review; content should become data.

## What Changes

- Convert lesson content to a bundled JSON resource (`german-lessons.json` in the app bundle); `MobileLearningCatalog.germanLessons` decodes it at load time so UI, word review, and stats code do not otherwise change.
- Expand the path from 14 to 36 lessons at approximately reference-book-step granularity, following the split map in design.md (some map rows deliberately merge closely-related book steps), reusing the already-original sentences and authoring new glue content for the split.
- New lesson ID namespace `de-s-01`..`de-s-36` (no collision with shipped `de-g-*` IDs), and `completedLessonCount` is filtered to IDs in the active catalog so stale `de-g-*` entries cannot inflate progress. Existing word-review cards are kept (provenance strings are display-only, already verified).
- Failure policy: malformed/missing JSON asserts in Debug and, in release, logs and yields an empty lesson list - never a crash. A unit test decodes the file from the **built app bundle**, proving the pbxproj resource entry works.
- Keep every existing lesson-internal format: intro, 3 goals, 7-11 phrases, 5-6 vocabulary items, 5-8 line strictly-alternating two-speaker dialogue, scoped practice prompt, cumulative comprehensibility, two-voice Play-all (voice contract: lesson fields voiceA/voiceB - either both present or both absent - assigned to alternating speakers, validated by test).

## Out of scope

- Server/Strapi delivery of the JSON (a later change will decide transport/auth/update behavior; this proposal makes no schema promises toward it).
- Other languages, UI redesign, exam content, generic migration framework.
