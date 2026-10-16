# Proposal: Rebuild the German lesson path as a grammar-progression course

## Why

The current German lesson path is 6 disconnected scenario lessons (greetings, shopping, restaurant, directions, phone, housing) with no grammar spine. A learner finishes it without ever being taught, in order, the structures that make German work: gender, cases, verb conjugation, past tenses, modals.

The user owns the PDF "Easy German Step-by-Step" (Ed Swick, McGraw-Hill) and wants materials inspired by its approach: a step-by-step high-frequency grammar path from zero to solid A2. Its **scope and sequence** (which grammar point follows which) is a standard CEFR A1→A2 syllabus and is not copyrightable. Its **text is copyright McGraw-Hill and MUST NOT be copied, paraphrased, or lightly rewritten** into this app — the app ships commercially and derivative text would be both plagiarism and infringement.

## What Changes

- Replace `MobileLearningCatalog.germanLessons` with a 14-lesson A1→A2 grammar-progression path covering the same standard territory the book covers (pronunciation, gender, sein/haben, present tense, accusative, past tense, dative, modals, perfect tense, adjective endings, separable verbs).
- Every piece of content — intros, goals, phrases, vocabulary, example sentences, dialogues, practice prompts — is authored **from scratch** for this app, with a practical communicative goal per lesson ("after this lesson you can…") and a practice prompt that makes the AI partner drill the target structure.
- Lesson IDs are new (`de-g-01`…`de-g-14`); the 6 old lessons are removed. Completed-lesson stats for old IDs are historical data in UserDefaults and simply stop matching a lesson — acceptable, no migration (KISS).
- Conversation audio in the lesson detail view (`LearningViews.swift`): a Play-all control synthesizes the dialogue line by line with two distinct Polly voices (Vicki/Daniel for German), plays sequentially with the active line highlighted, and is cancellable.
- No changes to `LearningLesson` model, word review, or stats code.

## Out of scope

- Backend/Strapi learning content, exam A1 content, other languages, UI changes beyond the conversation Play-all control.
