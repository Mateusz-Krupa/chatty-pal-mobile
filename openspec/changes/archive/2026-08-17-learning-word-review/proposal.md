# Learning word review (SRS)

## Why

The biggest learning gap in the app is retention: vocabulary lives inside lessons and exam units, but nothing brings it back. A spaced-repetition review queue turns one-off exposure into durable memory — the mechanism behind Anki/Duolingo retention.

## What Changes

- New `ReviewWord` model + `WordReviewStore` (UserDefaults, `@Observable` singleton): Leitner boxes 1–5, intervals 10 min / 1 day / 3 days / 7 days / 14 days; grades Again (back to box 1), Good (+1 box), Easy (+2 boxes).
- Words are collected automatically (no manual adding):
  - lesson vocabulary + phrases when the user opens a lesson,
  - exam unit vocabulary when the user marks an exam unit complete.
- New "Word Review" screen (Student section of the menu, with a due-count badge): flashcards (German + example + TTS, tap to reveal English, Again/Good/Easy), session of up to 20 due words, completion screen, empty state when nothing is due.
- Dedupe by normalized German string across all sources.

## Impact

- Affected specs: new capability `word-review`.
- Affected code: new `chatty-pal/WordReview.swift`, `chatty-pal/WordReviewView.swift`; touched `chatty-pal/MenuOverlay.swift`, `chatty-pal/ChatView.swift`, `chatty-pal/LearningViews.swift` (collection hook), `chatty-pal/ExamPrepViews.swift` (collection hook); new tests `chatty-palTests/WordReviewTests.swift`; pbxproj entries.
- No server changes, no new permissions.
