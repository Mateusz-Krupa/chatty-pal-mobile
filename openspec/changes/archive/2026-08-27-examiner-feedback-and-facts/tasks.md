## 1. Prompt changes (chatty-pal/src/pages/api/exam.ts)

- [x] 1.1 Add example-by-example rule to EXAM_BASE_RULES: under "Besser so", list each concrete learner mistake as `Du: „<quoted fragment>" → Besser: „<minimal alternative>"`, up to 4 entries, most important first, only real mistakes from the conversation
- [x] 1.2 Add facts-checklist rule to EXAM_BASE_RULES: examiner tracks facts already stated (name, origin, city, job/studies, family, hobbies, symptoms) and never re-asks clearly stated information — briefly acknowledge and move on; partial/unclear answers still get one simple follow-up

## 2. Tests (chatty-pal/src/pages/api/exam.test.ts)

- [x] 2.1 Assert the exam instruction contains the example-by-example format rule (quote → better alternative, max 4)
- [x] 2.2 Assert the exam instruction contains the no-reask facts rule
- [x] 2.3 Run full backend jest suite (54+ tests green)

## 3. Live validation (chatty-pal.com or staging)

- [x] 3.1 Verify a seeded conversation with learner mistakes produces example-by-example corrections (quote + alternative, no invented examples)
- [x] 3.2 Verify the examiner does not re-ask name/city/job already stated earlier in the conversation

## 4. Deploy & close

- [x] 4.1 Deploy backend to chatty-pal.com (requires explicit user approval)
- [x] 4.2 Archive change, update memory (decision/pitfall if any deviation found)
