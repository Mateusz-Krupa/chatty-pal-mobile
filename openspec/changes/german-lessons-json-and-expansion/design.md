# Design: bundled JSON + book-step lesson expansion

## JSON as the content source

- File: `chatty-pal/Resources/german-lessons.json`, added to the app target Resources phase (3 manual pbxproj entries: PBXFileReference, group child, PBXResourcesBuildPhase - project uses non-synchronized groups).
- Schema uses content-oriented keys, mapped to Swift via `CodingKeys`:
  `{ "schemaVersion": 1, "lessons": [ { id, title, description, languageCode, level, topic, intro, goals[], phrases[{text, translation}], vocabulary[{text, translation, usage}], conversation[{speaker, text, translation}], practicePrompt, voiceA?, voiceB? } ] }`
  The names are chosen for human editing of a content file; no future API contract is implied.
- Loader validates `schemaVersion == 1`; other values are treated as load failure. Models gain `Codable`; row-item UUID ids are generated after decoding.
- Failure policy: Debug `assertionFailure` + error log; Release logs and returns an empty catalog - no crash, existing empty-state UI applies. A unit test loads `german-lessons.json` from the **built app target bundle** (proving the resource phase entry) and asserts schema invariants; a second test feeds a wrong schemaVersion payload and expects the empty catalog.

## Catalog identity and persisted progress

- Shipped catalog uses ids `de-g-01..de-g-14`; the expanded catalog uses `de-s-01..de-s-36` so an id never means two different lessons.
- `LearningStatsStore.completedLessonCount` SHALL count only completed ids present in the active catalog (filter by current lesson ids); legacy `de-g-*` completions stop counting - honest, no fake migration of one old completion into several new ones. No UserDefaults purge (KISS).
- Word-review cards keep their `lesson:de-g-NN` provenance; verified harmless (the store does not filter by source).

## Voice contract

- Lesson fields `voiceA`/`voiceB` (either both present or both absent - enforced by the content test). Playback assigns voiceA to even-index lines and voiceB to odd-index lines; the schema REQUIRES strictly alternating speakers, validated by the shipping-JSON test (exactly two distinct speaker names per lesson, alternating, first line = speaker A). Absent voiceA/voiceB -> lesson voice for all lines.

## Split map: 14 -> 36 lessons (book-step granularity; A1 = 1-22, A2 = 23-36)

| # | from | topic (book step) |
|---|------|------|
| 1 | old 1 | Consonants + reading rhythm (w, z, sch, ch, st/sp, ß) [U1.1] |
| 2 | old 1 | Vowels and combinations (ei/ie, eu, ä/ö/ü, long/short) [U1.2] |
| 3 | old 1 | Cognates: German you already know [U1.3] |
| 4 | old 2 | Masculine der + heißen [U2.1] |
| 5 | old 2 | Feminine die [U2.2] |
| 6 | old 2 | Neuter das, gender by ending [U2.3] |
| 7 | old 3 | Pronouns ich/du/er/sie/es/wir/ihr/sie [U3.1] |
| 8 | old 3 | sein fully + das ist [U3.3] |
| 9 | old 3 | dieser/diese/dieses pointing (der-words) [U3.2] |
| 10 | old 4 | haben [U4.2] |
| 11 | old 4 | ein / kein [U4.1] |
| 12 | old 4 | mein / dein possession [U4.1] |
| 13 | old 5 | Regular present endings [U4.3] |
| 14 | old 5 | Verb-second rule, inversions, w-questions first pass (was/wo/wer/wie) [U4.3, U7] |
| 15 | old 6 | a→ä verbs (fahren, schlafen, tragen) [U5.1] |
| 16 | old 6 | e→i/ie verbs (sprechen, helfen, lesen, essen, nehmen) [U5.2-3] |
| 17 | old 6 | werden + impersonal es [U5] |
| 18 | old 7 | Accusative nouns: den/einen [U6.1] |
| 19 | old 7 | Accusative pronouns mich/dich/ihn/sie [U6.2] |
| 20 | old 7 | für, ohne, gegen [U6.3] |
| 21 | old 9 | Plurals pack (-e, -er, -s, -e; umlaut patterns) [U6/U7/U8 plural steps] |
| 22 | old 9 | Numbers and age (6-20, tens, achtundzwanzig) [U8.2] |
| 23 | old 8 | Written past -te + time words (gestern, früher) [U7.1-2] |
| 24 | old 9 | Irregular past: ging / kam / sah [U8.1] |
| 25 | old 10 | Dative case: dem/der/den+n, mir/dir [U9.1] |
| 26 | old 9 | war / hatte / wurde [U9.2] |
| 27 | new | wissen & kennen - stative "know" pair, explicitly not modals [U9.3] |
| 28 | old 10 | Dative verbs: helfen, gefallen, gehören, danken, schmecken [U10.1] |
| 29 | old 10 | Dative prepositions: mit, zu/zum, nach, aus, von, bei [U10] |
| 30 | old 11 | können / müssen / wollen modal trio + infinitive at end [U10.2] |
| 31 | old 11 | Conjunctions und, aber, oder, sondern, denn [U10] |
| 32 | old 12 | Spoken past: haben + ge...t [U11.1, U13.1-2 strong participles folded in gently] |
| 33 | old 14 | sein-perfect: motion/change verbs (kommen, fahren, gehen, bleiben, laufen) [U11.2, U13.2] |
| 34 | old 13 | Separable prefix verbs [U12.2, U11.4 inseparable be-/ver- note] |
| 35 | old 13 | Adjective endings [U12.1] |
| 36 | old 14 | Dates + ordinals (am ersten Mai, halb neun) + life-story REVIEW lesson (no new grammar) [U11.3, review] |

## Cumulative-content rules (reviewer gate checklist)

- No numerals before #22. No productive plural NOUN morphology before #21 (fixed chunks only, as today); plural personal pronouns (wir/ihr/sie) and their sein/haben forms are allowed from lessons 7-8.
- w-questions from #14; dative articles + mir/dir from #25; aber/oder/sondern/denn from #31 (und is allowed freely as basic connective vocabulary; the old L10 dialogue line containing "aber" pre-dates the expansion and will be re-gated in its new home lesson).
- Attributive adjective endings only from #35 (previously: predicative adjectives + the reviewed exception "ein gutes/eine kleine" demo in the adjective lesson itself).
- Imperatives nowhere; pronouns mich/dich/ihn from #19.
- Content conventions adopted at gate 2: lessons 1-3 (sounds, cognates) use ONLY labeled
  sound samples and verbless chunks, never grammar-bearing sentences; high-frequency whole
  phrases (Wie heißt du?, Ich bin ...) may appear as memorized fixed phrases, marked as such
  in the phrase note, and are never drilled as productive constructions (productive
  w-questions arrive in #14); the pointer frame das ist belongs to #8, earlier lessons point
  with verbless chunks (Das Buch - neu.); #7 stays on the single X ist Y frame plus the
  memorized Ich bin chunk, full sein paradigm in #8; drill register uses noun chunks
  (Als Nächstes..., Hörbeispiel...), never imperative verbs.
- Every dialogue: speakers strictly alternating, ≤2 speakers, natural coherence, faithful English; grammar within lessons ≤N.

## Workflow + risks

- JSON edited directly; validated by `python3 -m json.tool` + the bundle unit test.
- Reviewer gates after foundation and after each 9-lesson content phase (4 phases); final gate >= 4.5 before merge; commit per phase on `feature/german-grammar-path`.
- Verified against tests: WordReviewTests asserts `lesson:<lesson.id>` dynamically (no literal ids) - unaffected. LearningStatsTests uses arbitrary literal ids as persistence fixtures - unaffected; gains one test for the completedLessonCount filter.
- Risk: pbxproj resource entry mistake → caught by the built-bundle test in CI, before shipping.
