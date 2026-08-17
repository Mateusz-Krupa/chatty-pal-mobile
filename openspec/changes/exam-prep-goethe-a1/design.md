## Context

Chatty Pal (iOS, SwiftUI, Swift 6.2) ma działający czat z botem (`ChatEngine` + DI + persona), TTS (PollySpeechService), korektę zadań przez endpoint teacher i system nauki (`LearningCatalog` — szkielet). Użytkownik zdaje Goethe-Zertifikat A1 (niemiecki) i potrzebuje pełnego modłu egzaminacyjnego. Projekt używa klasycznego `project.pbxproj` z jawnym `PBXFileReference` (nie file-system-synchronized group) — każdy nowy plik wymaga ręcznych wpisów (4 miejsca, ID hex `AA0000...`).

Faza A jest już zaimplementowana (model, UI, persona, 7 jednostek startowych, wpis w menu) — dokument opisuje przyjęte decyzje i plan reszty.

## Goals / Non-Goals

**Goals:**
- Kompletny materiał Goethe A1: 4 sekcje egzaminu (Lesen/Hören/Sprechen/Schreiben) + materiały wspierające (słownictwo tematyczne, gramatyka).
- Zadania mówione prowadzone przez bota (scenariusz egzaminatora), bez ingerencji w główny czat.
- Ćwiczenia z natychmiastowym feedbackiem; audio przez istniejący TTS.
- Rozwijanie treści bez zmiany architektury (nowe jednostki = nowy entry w treści).

**Non-Goals:**
- Egzaminy B1/B2 i inne języki (model to pozwala, ale treści tylko A1 DE).
- Rejestracja wyników / rankingi / multi-user progres na serwerze.
- Nowy backend / CMS dla treści egzaminacyjnych.
- Autentyczne nagrania audio (tylko TTS).

## Decisions

1. **Treści wbudowane w Swift (`ExamA1Content.swift`), nie w Strapi/CMS.**
   Materiał A1 jest statyczny, zweryfikowany i wolumetrycznie umiarkowany (~kilka KB–MB tekstu). Wbudowanie daje: offline, wersjonowanie razem z apką, brak zależności od backendu przy użyciu. Alternatywa (Strapi) odrzucona: wymagałaby API, synchronizacji i nie dałaby korzyści (treści nie edytuje się dynamicznie).

2. **Model `ExamUnit` jako jeden typ jednostki dla wszystkich sekcji** (sekcja określona enumem, opcjonalne pola: `text`, `speakingScenario`, `writingPrompt`).
   Upraszcza nawigację (jeden `navigationDestination`) i katalog. Alternatywa (osobne typy per sekcja) odrzucona: nadmiarowy kod przy wspólnym UI.

3. **Mówienie = istniejący `ChatEngine` + nowa persona `.examinerA1(scenario:)` + `TransientChatStore`.**
   Zero nowej infrastruktury czatu (mikrofon, TTS odpowiedzi, interrupt). Scenariusz w promptach persona determinuje przebieg (np. Teil 1: przedstawić się, zapytać o rodzinę...). `TransientChatStore` = no-op, bo sesje egzaminacyjne nie zanieczyszczają historii głównego czatu (`LocalChatStore` per lang/level). Alternatywa (osobny lightweight chat view) odrzucona: duplikacja `ChatInputBar`/`ChatMessageList`.

4. **Listening przez `spokenText` + Polly TTS (`ExamTTS`), nie pliki audio.**
   Zero assetów w bundle; `hasAudio = spokenText != nil` steruje przyciskiem Play. Alternatywa (mp3 w bundle) odrzucona: waga apki, trudność edycji treści.

5. **Nawigacja przez wartościowe typy Hashable** (`ExamSection`, `ExamUnit`, `ExamSpeakingTask`) w `NavigationStack` — spójne z resztą apki (value-type routing w `ChatView`).

6. **Rozwój treści partiami (fazy B–G) z osobnym commitem per faza.**
   `ExamA1Content.swift` rośnie o sekcje (`vocabularyUnits`, `grammarUnits`, ...), każda faza = kompletne, zbudowalne, testowalne stanisko.

## Risks / Trade-offs

- [Jednostka `ExamA1Content.swift` rośnie do dużego pliku] → akceptowalne (czysty dane-struct); jeśli przekroczy ~3k linii, podzielić na pliki per sekcja (nowe wpisy pbxproj).
- [Ręczne wpisy `project.pbxproj` (4 miejsca/plik)] → schemat ID hex `AA0000...` (następne wolne od `AA0000000000000000000031`); każdy nowy plik = build po edycji.
- [Bot może wyjść z roli egzaminatora (długie sesje, user po angielsku)] → persona jawnie zakazuje angielskiego i nakazuje powrót do scenariusza; limit: zadanie kończy user (Finish).
- [TTS = koszt + latencja przy intensywnym użyciu listening] → istniejące timeouty (60s) i cache w `PollySpeechService`; audio odtwarzane na żądanie.
- [Swift 6.2: `@ViewBuilder` tylko przed nazwą parametru, brak domyślnych generyków w structach, `AVAudioPlayer(data:)` throws] → znane pułapki, testy + build po każdej fazie.
- [Treści egzaminacyjne muszą być merytorycznie poprawne (A1)] → user zwaliduje partiami; testy spójności katalogu (faza G) łapią błędy strukturalne (duplikaty ID, brak poprawnych odpowiedzi).

## Migration Plan

Brak migracji — sekcja jest czysto addytywne. Rollback = usunięcie commitów feature (pliki + 4 edycje). Progres (faza G) zapisany w UserDefaults → brak danych krytycznych do migracji.

## Open Questions

- Korekta writing przez endpoint teacher: czy wystarczy istniejący teacher-fix (bez dedykowanego promptu "writing exam"), czy trzeba rozszerzyć prompt? (decyzja w fazie F)
- Czy Mini-Examen ma liczyć wynik (punkty) czy tylko feedback kwalifikatywny? (decyzja w fazie G)
