## Why

Użytkownik przygotowuje się do egzaminu Goethe-Zertifikat A1 (niemiecki). Aplikacja Chatty Pal ma chat z botem, ale brak jest systematycznego materiału egzaminacyjnego — user potrzebuje kompletnego (100% materiału A1) modłu: słownictwo, gramatyka, czytanie, słuchanie, pisanie i mówienie, z zadaniem mówionym prowadzonym przez bota (scenariusz egzaminatora Goethe A1).

## What Changes

- Nowa sekcja "Exam Prep A1" w menu (Student section) prowadząca do katalogu jednostek egzaminacyjnych.
- Katalog treści Goethe A1: sekcje Lesen, Hören, Sprechen, Schreiben + materiały wspierające (słownictwo tematyczne, gramatyka) jako jednostki z treścią, ćwiczeniami i scenariuszami.
- Widok jednostki: tekst, słownictwo (DE/EN + przykłady), zwroty, dialog, ćwiczenia (multiple choice, gap fill, listening z TTS), sekcja mówienia, prompt pisania — z odtwarzaniem audio przez Polly TTS.
- Zadania mówione: chat z botem w personie egzaminatora Goethe A1, sterowany scenariuszem jednostki (np. Teil 1–4 egzaminu ustnego); czat tymczasowy (bez zapisu), auto-start rozmowy, przycisk Finish.
- Pisanie: prompt egzaminacyjny + korekta odpowiedzi przez istniejący endpoint teacher (później).
- Progres + Mini-Examen (później): śledzenie ukończonych jednostek, losowy zestaw zadań na mini-egzamin.
- **Uwaga**: faza A (model, pierwsza partia treści, UI, persona, wpis w menu) jest już zaimplementowana — zmieni ona tylko statusy w tasks.md.

## Capabilities

### New Capabilities
- `exam-prep`: nawigacja sekcji Exam Prep A1, katalog jednostek (sekcje Lesen/Hören/Sprechen/Schreiben + słownictwo + gramatyka), widok szczegółu jednostki z treścią (tekst, Vokabeln, Phrasen, Dialog) i TTS.
- `exam-exercises`: ćwiczenia w jednostkach — multiple choice, gap fill, listening (audio przez TTS); sprawdzanie odpowiedzi, podpowiedzi, feedback z wyjaśnieniem.
- `exam-speaking-practice`: zadania mówione z botem — persona egzaminatora Goethe A1, scenariusz z jednostki, tymczasowy czat, auto-start, zakończenie zadania.
- `exam-writing`: zadania pisemne — prompt egzaminacyjny, edytor tekstu, korekta odpowiedzi przez endpoint teacher.
- `exam-progress`: postęp użytkownika — oznaczanie ukończonych jednostek, podsumowanie progresu per sekcja, Mini-Examen (losowy zestaw z ukończonych jednostek).

### Modified Capabilities

(brak — `openspec/specs/` jest pusty; istniejące zachowania apki nie zmieniają wymagań)

## Impact

- Nowe pliki: `chatty-pal/ExamA1Catalog.swift` (model), `chatty-pal/ExamA1Content.swift` (treści — rosnąca), `chatty-pal/ExamPrepViews.swift` (UI).
- Zmienione: `ChatEngine.swift` (nowa persona `.examinerA1(scenario:)`), `ChatStore.swift` (nowy `TransientChatStore`), `ChatView.swift` (routing `.examPrep`), `MenuOverlay.swift` (case + wpis menu), `project.pbxproj`.
- Reużyte bez zmian: `ChatInputBar`/`ChatMessageList`, `PollySpeechService`, endpointy teacher (do korekty writing).
- Treści: rozbudowa `ExamA1Content.swift` do pełnego katalogu A1 (słownictwo ~12 tematów, gramatyka ~10 jednostek, reading, listening, speaking Teil 1–4, writing).
