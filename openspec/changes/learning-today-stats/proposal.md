# Proposal — learning-today-stats

## Why

The app has no memory of the learner's progress. Coming back to the app gives no signal of what to do next, no streak, no totals. A "Today" card on the home screen + lightweight activity stats closes the loop: lesson practice, word review, and shadowing all feed one visible progress trail, which is the "features flow into each other" glue.

## What changes

- New `LearningStatsStore` (UserDefaults, mirrors `WordReviewStore` style): records lesson completions, review grades, shadowing attempts; tracks daily activity dates and a streak.
- Pure, testable `streak(for:today:)` function.
- "Today" card on the chat home screen (above the message list): streak, due-word count, completed-lesson count, and one tap-through to Word Review.
- Collection hooks: lesson "Practice in Chatty Pal" button, word-review grading, shadowing finish.

## Impact

- New files: `LearningStats.swift`, `LearningStatsTests.swift` (pbxproj IDs 47/48, 49/50).
- Touched: `ChatView.swift` (card + tap-through), `LearningViews.swift` (practice button hook + shadowing hook), `WordReviewView.swift` (grade hook).
- No network, no new dependencies, no schema migration.
