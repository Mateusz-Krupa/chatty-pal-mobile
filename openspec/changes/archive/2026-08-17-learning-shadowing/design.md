# Design — Learning shadowing mode

## Scorer (pure)

```swift
enum ShadowingScorer {
    struct WordMatch: Hashable { let word: String; let matched: Bool }
    struct Result: Hashable { let percent: Int; let words: [WordMatch] }
    static func score(reference: String, spoken: String) -> Result
    static func cleanWords(_ text: String) -> [String]
}
```

- `cleanWords`: lowercase, split on non-letter/non-number characters.
- Matching: greedy, monotonically advancing pointer over the spoken words — for each reference word, scan forward from the current spoken index for a word similar enough (`TranscriptTracker.isSimilar`, threshold 0.7). This tolerates extra filler words in the speech and mild misrecognitions; a word with no forward match is unmatched.
- Percent = matched / reference word count, rounded.
- Reusing `TranscriptTracker.isSimilar` keeps one Levenshtein implementation and one similarity threshold across the app.

## UI

`ShadowingPhraseRow` (private, in LearningViews):

- Row: phrase text + English + two buttons: speaker (plays via the existing `playLessonText`) and mic.
- Mic first tap: create `SpeechController` (lesson speech locale), request permissions, start; keep the latest partial transcript. Mic second tap: stop, score against the reference, show result.
- Result: percent badge (green ≥ 80, orange ≥ 60, red below) + the reference words rendered green (matched) / red (unmatched).
- Below 60%: `WordReviewStore.shared.add(german: phrase, english: translation, source: "shadowing")` + caption "Added to Word Review".

The new section goes in the lesson detail between "Phrase Practice" and "Vocabulary Review": `InfoSectionCard(title: "Shadowing: Listen & Repeat", systemImage: "waveform")`.

Only one row records at a time: starting a new recording stops any active one (rows share nothing, so each row simply stops its own on re-tap; starting another row while one records is a rare edge — acceptable, the stopped one scores, the other starts).

## Tests

- Exact match → 100%, all words matched.
- One word missing → percent reflects it, missing word unmatched.
- Extra filler word in speech → still 100% (pointer skips).
- Similar word (levenshtein within threshold) → matched.
- Empty spoken → 0%, none matched.
- Punctuation/case cleaned before matching.
