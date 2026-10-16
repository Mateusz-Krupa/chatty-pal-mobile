# Tasks: german-lessons-json-and-expansion

## Phase 1 — JSON foundation (same 14 lessons, new carrier)

- [x] Task 1: `Codable` on lesson models with content-oriented JSON keys via CodingKeys; item UUID ids generated post-decode; `schemaVersion` validation
- [x] Task 2: Extract current 14 lessons verbatim to `chatty-pal/Resources/german-lessons.json` (ids stay `de-g-*` in this phase); add to pbxproj Resources phase (3 entries)
- [x] Task 3: Loader in `MobileLearningCatalog` (static let, Debug assert / Release log+empty); delete hard-coded prose
- [x] Task 4: `voiceA`/`voiceB` lesson fields; `LearningLessonDetailView.conversationVoice(for:)` reads them; German lessons carry Vicki/Daniel in JSON
- [x] Task 5: Phase-1 tests: decode the CURRENT 14-lesson JSON from the BUILT BUNDLE (resource present, decodes, schemaVersion enforced; wrong-version -> empty catalog); `completedLessonCount` filters to active-catalog ids (+ new test). Final-catalog invariants (ids de-s-01..de-s-36, 36 lessons, speaker alternation, voiceA/voiceB both-or-none) are asserted in Task 10's final content test, not before.
- [x] Task 6: Reviewer gate 1 — diff review (loader safety, CodingKeys, pbxproj, test honesty). Commit

## Phase 2-5 — Split 14 to 36 lessons (JSON content work, ~9 lessons per phase)

Every content-phase reviewer gate checks explicitly: (a) cumulative wall per design.md checklist (no numerals before #22; no plural noun morphology before #21 - plural pronouns allowed from #7; dative from #25; aber/oder/sondern/denn from #31, und free; adjective endings from #35; no imperatives); (b) dialogues natural, coherent, appropriate to learner level; (c) faithful English; (d) CEFR label per content, A1 before A2; (e) original-content posture (no book paraphrase); (f) speaker alternation + voiceA/voiceB both-or-none valid.

- [ ] Task 7: Lessons 1-9 (sounds x3, gender x3, pronouns, sein, dieser) + Reviewer gate 2 + commit
- [ ] Task 8: Lessons 10-18 (haben, ein/kein, mein/dein, present x2, vowel verbs x2, werden, accusative nouns) + Reviewer gate 3 + commit
- [ ] Task 9: Lessons 19-27 (accusative pronouns, für/ohne/gegen, plurals, numbers/age, -te past, ging/kam/sah, dative case, war/hatte/wurde, wissen/kennen) + Reviewer gate 4 + commit
- [ ] Task 10: Lessons 28-36 (dative verbs, dative prepositions, modals, conjunctions, haben-perfect, sein-perfect, separable verbs, adjective endings, dates/review) + FINAL content-catalog test (ids de-s-01..de-s-36, counts, alternation, voice pairs) + Reviewer gate 5 + commit

## Phase 6 — Close out

- [ ] Task 11: Final overall reviewer (>= 4.5/5.0) on full diff; full build + test suite
- [ ] Task 12: Archive OpenSpec change; push branch only after explicit user approval
