# Tasks — exam-prep-goethe-a1

## 1. Faza A: Fundament (model, UI, persona)

- [x] 1.1 Model `ExamA1Catalog.swift`: ExamSection, ExamVocabularyItem, ExamPhrase, ExamDialogueLine, ExamExercise, ExamUnit, ExamA1Catalog
- [x] 1.2 `ExamA1Content.swift`: struktura katalogu + pierwsza partia treści (2 vocab, 1 grammar, 1 reading, 1 listening, 1 speaking, 1 writing)
- [x] 1.3 `ExamPrepViews.swift`: home (sekcje), sekcja (lista jednostek), detal jednostki (text/vocab/phrasen/dialog/exercises/speaking/writing), ExerciseCard, ExamTTS, ExamSpeakingView
- [x] 1.4 `ChatEngine`: persona `.examinerA1(scenario:)`; `ChatStore`: `TransientChatStore`
- [x] 1.5 Routing: `MenuDestination.examPrep` + wpis w menu + `ChatView` case `.examPrep`
- [x] 1.6 pbxproj: 3 nowe pliki (ID AA...2B–30); build ✅ testy ✅
- [x] 1.7 OpenSpec: init, change, proposal, design, 5 speców, tasks

## 2. Faza B: Słownictwo (12 jednostek tematycznych)

- [ ] 2.1 Zeit und Daten (godziny, dni, miesiące, daty) + ćwiczenia
- [ ] 2.2 Wohnen (mieszkanie, meble, kierunki) + ćwiczenia
- [ ] 2.3 Essen und Trinken (jedzenie, w restauracji) + ćwiczenia
- [ ] 2.4 Einkaufen (sklep, produkty, płatność, zwrot) + ćwiczenia
- [ ] 2.5 Stadt und Wege (miasto, pytania o drogę) + ćwiczenia
- [ ] 2.6 Gesundheit (części ciała, lekarz, apteka) + ćwiczenia
- [ ] 2.7 Arbeit und Beruf (zawody, biuro, rozmowa kwalifikacyjna A1) + ćwiczenia
- [ ] 2.8 Freizeit und Hobby (czas wolny, sport, zaproszenia) + ćwiczenia
- [ ] 2.9 Kleidung (ubrania, rozmiary, kolory) + ćwiczenia
- [ ] 2.10 Körper und Aussehen (opisywanie ludzi) + ćwiczenia
- [ ] 2.11 Reisen (podróże, lotnisko, hotel) + ćwiczenia
- [ ] 2.12 Telefonieren (rozmowy telefoniczne, umawianie się) + ćwiczenia
- [ ] 2.12b Każda jednostka: ~10–14 Vokabeln, ~5 Phrasen, dialog, 4–6 ćwiczeń (MC/gap/listening)
- [ ] 2.13 Build + testy + commit "Exam A1 phase B: vocabulary units"

## 3. Faza C: Gramatyka (10 jednostek)

- [ ] 3.1 sein und haben (rozszerzyć istniejącą), Fragen bilden, Negation (nicht/kein)
- [ ] 3.2 Artikel und Plural, Possessivartikel (mein/dein/sein)
- [ ] 3.3 Modalverben (können, müssen, möchten, dürfen, sollen, wollen)
- [ ] 3.4 Zeiten: Präsens, Perfekt, Futur
- [ ] 3.5 Präpositionen (in/an/auf/mit/zu + Akkusativ/Dativ), Trennbare Verben
- [ ] 3.6 Komparativ/Superlativ, Satzbau (W-Frage, Satzklammer)
- [ ] 3.7 Każda jednostka: reguła (text), tabela/przykłady (phrases), 5–8 ćwiczeń MC/gap
- [ ] 3.8 Build + testy + commit "Exam A1 phase C: grammar units"

## 4. Faza D: Lesen + Hören

- [ ] 4.1 Lesen: 4–6 tekstów egzaminacyjnych (Anzeige, Mail, Prospekt, Formular) z zadaniem per tekst
- [ ] 4.2 Hören: 4–6 dialogów/ogłoszeń ze `spokenText` (TTS) i zadaniami listening
- [ ] 4.3 Build + testy + commit "Exam A1 phase D: reading and listening units"

## 5. Faza E: Sprechen (scenariusze Teil 1–4)

- [ ] 5.1 Teil 1: Sich vorstellen (jest), Personen vorstellen
- [ ] 5.2 Teil 2: Bild beschreiben (scenariusz z opisem obrazu w text)
- [ ] 5.3 Teil 3: Situationen — telefon, Restaurant, Arzt, Einkaufen (4 scenariusze)
- [ ] 5.4 Teil 4: Vorstellen/Einladung (krótka prezentacja + pytania egzaminatora)
- [ ] 5.5 Każda jednostka speaking: speakingScenario (pełny prompt scenariusza) + Vokabeln do tematu
- [ ] 5.6 Build + testy + commit "Exam A1 phase E: speaking scenarios Teil 1-4"

## 6. Faza F: Schreiben + korekta

- [ ] 6.1 Writing units: Kurze Nachricht (jest), formelle Nachricht/Bewerbung, +2 kolejne (Einladung, Beschwerde)
- [ ] 6.2 UI Schreiben: prompt + edytor tekstu + "Check my writing" (teacher endpoint, prompt ramujący jako egzamin A1 — decyzja: istniejący teacher-fix z rozszerzonym promptem)
- [ ] 6.3 Obsługa błędów: pusty tekst, błąd sieci/auth (zapis tekstu, retry)
- [ ] 6.4 Build + testy + commit "Exam A1 phase F: writing with correction"

## 7. Faza G: Progres + Mini-Examen + testy spójności

- [ ] 7.1 Progres: "Mark as complete" (UserDefaults `exam.a1.completed`), wskaźnik per jednostka i "x / y" per sekcja na home
- [ ] 7.2 Mini-Examen: losowy zestaw MC/gap (≥1 na sekcję), podsumowanie z licznikiem i wyjaśnieniami, bez zapisu
- [ ] 7.3 Testy spójności katalogu: unikalne ID, każda jednostka ma sekcję, exercise ma poprawny correctIndex, ≥12 vocab / ≥10 grammar / ≥1 na sekcję egzaminacyjną
- [ ] 7.4 Build + testy + commit "Exam A1 phase G: progress, mini exam, catalog tests"
