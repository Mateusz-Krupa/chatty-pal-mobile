# Learnings

## Outcome

- [project] Final A1 feedback can remain concise while being actionable when `Besser so` quotes each actual learner error and gives its minimal replacement. Production validation returned three exact learner fragments with appropriate corrections.
- [project] The existing bounded exam history is sufficient as a facts checklist for short A1 stages. A prompt rule made the examiner skip already provided name, city, and job and ask the next missing item (origin).
- [procedural] A deployed prompt change can be live-validated through `POST /api/bot` with the required `Referer`, a seeded `messages` history, and an `exam` payload; this exercises the real prompt and model without reading production secrets.

## Intent vs outcome

The change stayed prompt-only as designed: `EXAM_BASE_RULES` and instruction assertions changed, without API or mobile changes. The first SSH deploy attempt timed out because port 22 was temporarily unreachable; after access returned, rsync and `docker compose up -d --build web` completed successfully. Docker Compose also rebuilt/recreated the CMS container due to its compose configuration, although only the web service was targeted.

## Validation evidence

- Backend commit: `chatty-pal` `a0ee07c`.
- Tests: `npx jest src/pages/api/exam.test.ts` (44/44) and `npx jest` (86/86).
- Deployment: production web source synced to `/opt/chatty-pal/web`; `docker compose up -d --build web` completed and the web container was up.
- Live feedback request: a seeded conversation returned `Du: „Ich wohnt in Warschau“ → Besser: „Ich wohne in Warschau.“`, `Du: „ich arbeiten als Koch“ → Besser: „ich arbeite als Koch.“`, and `Du: „Mein Hobbys ist Fußball spielen“ → Besser: „Mein Hobby ist Fußball spielen.“`, with `Urteil: BORDERLINE`.
- Live facts request: after `Ich heiße Marek, ich wohne in Warschau und ich arbeite als Koch.`, the examiner replied `Woher kommen Sie?` and did not repeat name, city, or job.

## Memory impact

- D-001 helped: retaining feedback as the final guided-chat message made the existing heading contract the correct place for the richer correction list.
