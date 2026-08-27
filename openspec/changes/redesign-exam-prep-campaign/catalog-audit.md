# Catalog audit — mapping of legacy Exam A1 units to the campaign

Source: `chatty-pal/ExamA1Content.swift` (49 units). Every legacy unit is mapped to
a campaign zone + lesson role. Legacy IDs are preserved as `legacyUnitID` references
so existing `exam.a1.completed` progress maps onto the new campaign.

## Zone 1 — First Contact (identity and basics)

| Legacy unit | Campaign role |
|---|---|
| a1-voc-familie | Lesson 1 (identity and family) — vocabulary support |
| a1-voc-koerper | Lesson 1 — vocabulary support (describing people) |
| a1-voc-zahlen | Lesson 1 — vocabulary support (numbers, personal data) |
| a1-gram-sein-haben | Lesson 1 — grammar support |
| a1-gram-fragen | Lesson 2 — grammar support |
| a1-gram-artikel | Lesson 2 — grammar support |
| a1-gram-possessiv | Lesson 2 — grammar support |
| a1-spr-vorstellung | Speaking mission — oral Teil 1 (introduce yourself) |
| a1-spr-personen | Speaking mission — oral Teil 1 (introduce people) |
| a1-read-formular | Reading task — form (personal data) |

## Zone 2 — Everyday Life (time, home, routine)

| Legacy unit | Campaign role |
|---|---|
| a1-voc-zeit | Lesson (time and dates) — vocabulary support |
| a1-voc-wohnen | Lesson (home) — vocabulary support |
| a1-voc-essen | Lesson (food and drink) — vocabulary support |
| a1-voc-freizeit | Lesson (free time) — vocabulary support |
| a1-gram-zeiten | Grammar support (present/perfect) |
| a1-gram-modalverben | Grammar support (möchten, müssen) |
| a1-gram-prapositionen | Grammar support (in, an, auf, mit, zu) |
| a1-list-telefon | Listening task — appointment call |
| a1-list-restaurant | Listening task — ordering |

## Zone 3 — Shopping and Services (buying, phone, appointments)

| Legacy unit | Campaign role |
|---|---|
| a1-voc-einkaufen | Lesson (shopping) — vocabulary support |
| a1-voc-kleidung | Lesson (clothes) — vocabulary support |
| a1-voc-telefon | Lesson (phone) — vocabulary support |
| a1-voc-gesundheit | Lesson (doctor) — vocabulary support |
| a1-voc-arbeit | Lesson (work) — vocabulary support |
| a1-gram-trennbar | Grammar support (anrufen, einkaufen) |
| a1-gram-negation | Grammar support (nicht/kein) |
| a1-spr-telefon | Speaking mission — Teil 3 (appointment) |
| a1-spr-restaurant | Speaking mission — Teil 3 (order) |
| a1-spr-arzt | Speaking mission — Teil 3 (doctor) |
| a1-spr-einkaufen | Speaking mission — Teil 3 (shop) |
| a1-list-einkauf | Listening task — market |
| a1-list-hotel | Listening task — check-in |
| a1-schreib-nachricht | Writing task — short message |
| a1-schreib-einladung | Writing task — invitation |

## Zone 4 — Travel and the City (directions, transport, city)

| Legacy unit | Campaign role |
|---|---|
| a1-voc-stadt | Lesson (city and directions) — vocabulary support |
| a1-voc-reisen | Lesson (travel) — vocabulary support |
| a1-read-reise | Reading task — travel offer |
| a1-read-anzeige | Reading task — flat ad |
| a1-list-bahnhof | Listening task — station announcements |
| a1-list-veranstaltung | Listening task — event announcement |

## Zone 5 — Exam Skills (task formats and exam technique)

| Legacy unit | Campaign role |
|---|---|
| a1-spr-bild | Speaking mission — Teil 2 (picture) |
| a1-spr-praesentation | Speaking mission — Teil 2/4 (short presentation) |
| a1-read-mail | Reading technique — private e-mail |
| a1-read-museum | Reading technique — information text |
| a1-read-stellenanzeige | Reading technique — job ad |
| a1-gram-komparativ | Grammar review for exam production |
| a1-gram-satzbau | Grammar review for exam production |
| a1-schreib-bewerbung | Writing task — formal short application |
| a1-schreib-beschwerde | Writing task — complaint |

## Zone 6 — Final preparation (checkpoint 3 + mock exam)

| Legacy unit | Campaign role |
|---|---|
| — (new content) | Final mock exam task set covering all four skills |

## Retirement

No legacy unit is retired in v1 of the campaign: all 49 units have a campaign home.
Units that were mislabelled as `.reading` (vocabulary/grammar) are re-classified to
their lesson role; their completion records keep working through `legacyUnitID`.
