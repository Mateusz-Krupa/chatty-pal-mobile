import Foundation

enum ExamCampaignContent {
    static let zones: [CampaignZone] = [zone1, zone2, zone3, zone4, zone5, zone6]

    // MARK: - Builders over the legacy catalog

    private static func vocab(_ unitID: String) -> [ExamVocabularyItem] {
        ExamA1Content.unit(id: unitID)?.vocabulary ?? []
    }

    private static func phrases(_ unitID: String) -> [ExamPhrase] {
        ExamA1Content.unit(id: unitID)?.phrases ?? []
    }

    private static func dialogue(_ unitID: String) -> [ExamDialogueLine] {
        ExamA1Content.unit(id: unitID)?.dialogue ?? []
    }

    private static func exercises(_ unitID: String) -> [ExamExercise] {
        ExamA1Content.unit(id: unitID)?.exercises ?? []
    }

    private static func passage(_ unitID: String, title: String? = nil) -> ReadingPassage? {
        guard let unit = ExamA1Content.unit(id: unitID), let text = unit.text, !unit.exercises.isEmpty else { return nil }
        return ReadingPassage(id: unitID, title: title ?? unit.title, text: text, questions: unit.exercises)
    }

    private static func passages(_ unitIDs: [String], titles: [String] = []) -> [ReadingPassage] {
        zip(unitIDs, titles).compactMap { unitID, title in
            if title.isEmpty { return passage(unitID) }
            return passage(unitID, title: title)
        }
    }

    private static func grammar(_ unitID: String) -> CampaignGrammarPoint {
        let unit = ExamA1Content.unit(id: unitID)
        return CampaignGrammarPoint(
            id: unitID,
            title: unit?.title ?? unitID,
            explanation: unit?.text,
            items: unit?.vocabulary ?? []
        )
    }

    private static func speaking(
        id: String,
        missionLabel: String,
        stages: [(String, String)],
        scenario: String
    ) -> CampaignSpeakingTask {
        CampaignSpeakingTask(
            id: id,
            missionLabel: missionLabel,
            stages: stages.map { CampaignSpeakingStage(id: $0.0, title: $0.0, instruction: $0.1) },
            scenario: scenario
        )
    }

    // MARK: - Zone 1: First Contact

    private static let zone1 = CampaignZone(
        id: "z1-first-contact",
        order: 1,
        title: "First Contact",
        goal: "Introduce yourself, ask simple questions, and read a short form.",
        nodes: [
            .lesson(CampaignLesson(
                id: "l1-identity",
                zoneID: "z1-first-contact",
                order: 1,
                title: "Ich stelle mich vor",
                goal: "You can introduce yourself and describe the people in your family.",
                vocabulary: vocab("a1-voc-familie") + vocab("a1-voc-koerper"),
                grammarPoints: [grammar("a1-gram-sein-haben")],
                phrases: phrases("a1-voc-familie"),
                dialogue: dialogue("a1-voc-familie"),
                exercises: exercises("a1-gram-sein-haben") + exercises("a1-voc-familie"),
                legacyUnitIDs: ["a1-voc-familie", "a1-voc-koerper", "a1-gram-sein-haben"]
            )),
            .lesson(CampaignLesson(
                id: "l2-numbers-questions",
                zoneID: "z1-first-contact",
                order: 2,
                title: "Zahlen und Fragen",
                goal: "You can ask questions with W-words and use numbers in everyday sentences.",
                vocabulary: vocab("a1-voc-zahlen"),
                grammarPoints: [grammar("a1-gram-fragen"), grammar("a1-gram-artikel"), grammar("a1-gram-possessiv")],
                phrases: phrases("a1-gram-fragen"),
                dialogue: dialogue("a1-gram-fragen"),
                exercises: exercises("a1-voc-zahlen") + exercises("a1-gram-fragen"),
                legacyUnitIDs: ["a1-voc-zahlen", "a1-gram-fragen", "a1-gram-artikel", "a1-gram-possessiv"]
            )),
            .lesson(CampaignLesson(
                id: "l3-speaking-introduce",
                zoneID: "z1-first-contact",
                order: 3,
                title: "Sprechen: Sich vorstellen",
                goal: "You can hold an exam-style conversation about yourself and your family.",
                vocabulary: vocab("a1-spr-vorstellung") + vocab("a1-spr-personen"),
                phrases: phrases("a1-spr-vorstellung") + phrases("a1-spr-personen"),
                dialogue: dialogue("a1-spr-vorstellung"),
                speaking: speaking(
                    id: "sp1-introduce",
                    missionLabel: "Oral exam — Teil 1",
                    stages: [
                        ("Sich vorstellen", "Run the Goethe A1 oral exam Teil 1 (Vorstellung): greet the candidate, ask for name, origin, city and job or studies, then hobbies. Keep questions one at a time and A1 simple."),
                        ("Über die Familie sprechen", "Run the Goethe A1 oral exam Teil 1 (Personen): ask the candidate about their family and one friend, with simple follow-up questions about age, job and city.")
                    ],
                    scenario: "You are the examiner for the Goethe-Zertifikat A1 oral exam, Teil 1 (Vorstellung). Greet the candidate, introduce yourself briefly, then ask one by one: (1) Wie heißen Sie? (2) Woher kommen Sie? (3) Wo wohnen Sie jetzt? (4) Was ist Ihr Beruf? / Was studieren Sie? (5) Was sind Ihre Hobbys? React briefly and encouragingly after each answer, then ask the next question. After all questions, give two or three sentences of short, friendly feedback on the candidate's German."
                ),
                legacyUnitIDs: ["a1-spr-vorstellung", "a1-spr-personen"]
            )),
            .lesson(CampaignLesson(
                id: "l4-reading-form",
                zoneID: "z1-first-contact",
                order: 4,
                title: "Lesen: Das Formular",
                goal: "You can read a short information text and answer questions about it.",
                vocabulary: vocab("a1-read-formular"),
                readingPassages: passages(["a1-read-formular"]),
                legacyUnitIDs: ["a1-read-formular"]
            )),
            .checkpoint(CampaignCheckpoint(
                id: "cp1-first-contact",
                zoneID: "z1-first-contact",
                order: 5,
                title: "Checkpoint: First Contact",
                description: "Show what you can do: family, numbers, questions and reading a form.",
                exerciseIDs: [
                    "a1-gram-sein-haben-e1",
                    "a1-gram-fragen-e2",
                    "a1-voc-zahlen-e2",
                    "a1-voc-familie-e3",
                    "a1-read-formular-e1",
                    "a1-read-formular-e4"
                ],
                speakingLessonIDs: ["l3-speaking-introduce"]
            ))
        ]
    )

    // MARK: - Zone 2: Everyday Life

    private static let zone2 = CampaignZone(
        id: "z2-everyday-life",
        order: 2,
        title: "Everyday Life",
        goal: "Talk about time, home, food and free time.",
        nodes: [
            .lesson(CampaignLesson(
                id: "l5-time-dates",
                zoneID: "z2-everyday-life",
                order: 1,
                title: "Zeit und Termine",
                goal: "You can tell the time, name days and plan simple appointments.",
                vocabulary: vocab("a1-voc-zeit"),
                grammarPoints: [grammar("a1-gram-zeiten")],
                phrases: phrases("a1-voc-zeit"),
                dialogue: dialogue("a1-voc-zeit"),
                exercises: exercises("a1-voc-zeit"),
                legacyUnitIDs: ["a1-voc-zeit", "a1-gram-zeiten"]
            )),
            .lesson(CampaignLesson(
                id: "l6-home-rooms",
                zoneID: "z2-everyday-life",
                order: 2,
                title: "Zuhause und Zimmer",
                goal: "You can describe your home and say where you live.",
                vocabulary: vocab("a1-voc-wohnen"),
                grammarPoints: [grammar("a1-gram-prapositionen")],
                phrases: phrases("a1-voc-wohnen"),
                dialogue: dialogue("a1-voc-wohnen"),
                exercises: exercises("a1-voc-wohnen"),
                legacyUnitIDs: ["a1-voc-wohnen", "a1-gram-prapositionen"]
            )),
            .lesson(CampaignLesson(
                id: "l7-food-ordering",
                zoneID: "z2-everyday-life",
                order: 3,
                title: "Essen und Bestellen",
                goal: "You can order food and drinks and listen to a short conversation.",
                vocabulary: vocab("a1-voc-essen"),
                grammarPoints: [grammar("a1-gram-modalverben")],
                phrases: phrases("a1-voc-essen"),
                dialogue: dialogue("a1-voc-essen"),
                exercises: exercises("a1-voc-essen") + exercises("a1-list-restaurant"),
                legacyUnitIDs: ["a1-voc-essen", "a1-gram-modalverben", "a1-list-restaurant"]
            )),
            .lesson(CampaignLesson(
                id: "l8-free-time",
                zoneID: "z2-everyday-life",
                order: 4,
                title: "Freizeit und Hobbys",
                goal: "You can talk about hobbies, plans and make simple suggestions.",
                vocabulary: vocab("a1-voc-freizeit"),
                phrases: phrases("a1-voc-freizeit"),
                dialogue: dialogue("a1-voc-freizeit"),
                exercises: exercises("a1-voc-freizeit"),
                legacyUnitIDs: ["a1-voc-freizeit"]
            )),
            .checkpoint(CampaignCheckpoint(
                id: "cp2-everyday-life",
                zoneID: "z2-everyday-life",
                order: 5,
                title: "Checkpoint: Everyday Life",
                description: "Show what you can do: time, home, food and free time.",
                exerciseIDs: [
                    "a1-voc-zeit-e1",
                    "a1-voc-wohnen-e1",
                    "a1-list-restaurant-e1",
                    "a1-voc-freizeit-e1",
                    "a1-gram-zeiten-e1"
                ],
                speakingLessonIDs: []
            ))
        ]
    )

    // MARK: - Zone 3: Shopping and Services

    private static let zone3 = CampaignZone(
        id: "z3-shopping-services",
        order: 3,
        title: "Shopping and Services",
        goal: "Buy things, use the phone, and arrange appointments.",
        nodes: [
            .lesson(CampaignLesson(
                id: "l9-shopping",
                zoneID: "z3-shopping-services",
                order: 1,
                title: "Einkaufen und Preise",
                goal: "You can shop, ask prices and listen to a market conversation.",
                vocabulary: vocab("a1-voc-einkaufen"),
                grammarPoints: [grammar("a1-gram-negation")],
                phrases: phrases("a1-voc-einkaufen"),
                dialogue: dialogue("a1-voc-einkaufen"),
                exercises: exercises("a1-voc-einkaufen") + exercises("a1-list-einkauf"),
                legacyUnitIDs: ["a1-voc-einkaufen", "a1-gram-negation", "a1-list-einkauf"]
            )),
            .lesson(CampaignLesson(
                id: "l10-clothes",
                zoneID: "z3-shopping-services",
                order: 2,
                title: "Kleidung und Größen",
                goal: "You can buy clothes, ask for sizes and try things on.",
                vocabulary: vocab("a1-voc-kleidung"),
                phrases: phrases("a1-voc-kleidung"),
                dialogue: dialogue("a1-voc-kleidung"),
                exercises: exercises("a1-voc-kleidung"),
                legacyUnitIDs: ["a1-voc-kleidung"]
            )),
            .lesson(CampaignLesson(
                id: "l11-phone-appointments",
                zoneID: "z3-shopping-services",
                order: 3,
                title: "Telefonieren und Termine",
                goal: "You can make a phone call and arrange an appointment.",
                vocabulary: vocab("a1-voc-telefon"),
                grammarPoints: [grammar("a1-gram-trennbar")],
                phrases: phrases("a1-voc-telefon"),
                dialogue: dialogue("a1-voc-telefon"),
                exercises: exercises("a1-voc-telefon") + exercises("a1-list-telefon"),
                legacyUnitIDs: ["a1-voc-telefon", "a1-gram-trennbar", "a1-list-telefon"]
            )),
            .lesson(CampaignLesson(
                id: "l12-doctor-health",
                zoneID: "z3-shopping-services",
                order: 4,
                title: "Beim Arzt",
                goal: "You can describe simple symptoms and call a doctor.",
                vocabulary: vocab("a1-voc-gesundheit"),
                phrases: phrases("a1-voc-gesundheit"),
                dialogue: dialogue("a1-voc-gesundheit"),
                exercises: exercises("a1-voc-gesundheit"),
                speaking: speaking(
                    id: "sp2-services",
                    missionLabel: "Oral exam — Teil 3",
                    stages: [
                        ("Telefon: Termin machen", "Run a Teil 3 style task: the candidate calls a doctor's office to make an appointment. You are the office. Ask for the reason, offer times, confirm the appointment."),
                        ("Beim Arzt", "Run a Teil 3 style task: the candidate is at the doctor. You ask about symptoms, how long, and what they did so far. Keep it simple and encouraging.")
                    ],
                    scenario: "You are the examiner for the Goethe-Zertifikat A1 oral exam, Teil 3 (Planung). Conduct a short appointment call with the candidate: a toothache, calling the doctor, choosing a day and time. Then a brief scene at the surgery. Keep all language at A1 level and give one or two sentences of feedback at the end."
                ),
                legacyUnitIDs: ["a1-voc-gesundheit", "a1-spr-arzt"]
            )),
            .lesson(CampaignLesson(
                id: "l13-shop-speaking",
                zoneID: "z3-shopping-services",
                order: 5,
                title: "Sprechen: Einkaufen",
                goal: "You can buy something in an exam-style shop conversation.",
                vocabulary: vocab("a1-spr-einkaufen"),
                phrases: phrases("a1-spr-einkaufen"),
                dialogue: dialogue("a1-spr-einkaufen"),
                speaking: speaking(
                    id: "sp3-shop",
                    missionLabel: "Oral exam — Teil 3",
                    stages: [
                        ("Im Shop", "Run a Teil 3 style task: the candidate wants to buy a jacket in a shop. You are the shop assistant. Ask what they want, offer a size and a price, ask how they pay. Then a short return or exchange question at the end.")
                    ],
                    scenario: "You are the examiner for the Goethe-Zertifikat A1 oral exam, Teil 3 (Planung). Conduct a shop conversation: the candidate wants to buy a jacket. Ask what they want, offer sizes and prices, ask how they pay, and finish with a return question. Keep language at A1 level."
                ),
                legacyUnitIDs: ["a1-spr-einkaufen"]
            )),
            .lesson(CampaignLesson(
                id: "l14-writing-messages",
                zoneID: "z3-shopping-services",
                order: 6,
                title: "Schreiben: Kurz Nachrichten",
                goal: "You can write a short informal message and an invitation.",
                vocabulary: vocab("a1-schreib-nachricht"),
                writingPrompt: ExamA1Content.unit(id: "a1-schreib-nachricht")?.writingPrompt,
                legacyUnitIDs: ["a1-schreib-nachricht", "a1-schreib-einladung"]
            )),
            .checkpoint(CampaignCheckpoint(
                id: "cp3-shopping-services",
                zoneID: "z3-shopping-services",
                order: 7,
                title: "Checkpoint: Shopping and Services",
                description: "Show what you can do: shop, phone, doctor and short messages.",
                exerciseIDs: [
                    "a1-voc-einkaufen-e1",
                    "a1-list-einkauf-e2",
                    "a1-voc-kleidung-e1",
                    "a1-list-telefon-e3",
                    "a1-voc-gesundheit-e1"
                ],
                speakingLessonIDs: ["l13-shop-speaking"]
            ))
        ]
    )

    // MARK: - Zone 4: Travel and the City

    private static let zone4 = CampaignZone(
        id: "z4-travel-city",
        order: 4,
        title: "Travel and the City",
        goal: "Find your way, travel, and understand announcements.",
        nodes: [
            .lesson(CampaignLesson(
                id: "l15-city-directions",
                zoneID: "z4-travel-city",
                order: 1,
                title: "Stadt und Wege",
                goal: "You can ask for directions and understand simple answers.",
                vocabulary: vocab("a1-voc-stadt"),
                phrases: phrases("a1-voc-stadt"),
                dialogue: dialogue("a1-voc-stadt"),
                exercises: exercises("a1-voc-stadt"),
                legacyUnitIDs: ["a1-voc-stadt"]
            )),
            .lesson(CampaignLesson(
                id: "l16-travel-hotel",
                zoneID: "z4-travel-city",
                order: 2,
                title: "Reisen und Hotel",
                goal: "You can understand a hotel check-in and a travel offer.",
                vocabulary: vocab("a1-voc-reisen"),
                phrases: phrases("a1-voc-reisen"),
                dialogue: dialogue("a1-voc-reisen"),
                exercises: exercises("a1-voc-reisen") + exercises("a1-list-hotel"),
                legacyUnitIDs: ["a1-voc-reisen", "a1-list-hotel"]
            )),
            .lesson(CampaignLesson(
                id: "l17-reading-offers",
                zoneID: "z4-travel-city",
                order: 3,
                title: "Lesen: Anzeigen und Angebote",
                goal: "You can read an ad and a travel offer and answer questions.",
                vocabulary: vocab("a1-read-anzeige"),
                readingPassages: passages(["a1-read-anzeige"]),
                legacyUnitIDs: ["a1-read-anzeige", "a1-read-reise"]
            )),
            .lesson(CampaignLesson(
                id: "l18-listening-station",
                zoneID: "z4-travel-city",
                order: 4,
                title: "Hören: Am Bahnhof",
                goal: "You can follow short announcements at a station and an event.",
                exercises: exercises("a1-list-bahnhof") + exercises("a1-list-veranstaltung"),
                legacyUnitIDs: ["a1-list-bahnhof", "a1-list-veranstaltung"]
            )),
            .checkpoint(CampaignCheckpoint(
                id: "cp4-travel-city",
                zoneID: "z4-travel-city",
                order: 5,
                title: "Checkpoint: Travel and the City",
                description: "Show what you can do: directions, travel, offers and announcements.",
                exerciseIDs: [
                    "a1-voc-stadt-e1",
                    "a1-list-hotel-e2",
                    "a1-read-anzeige-e1",
                    "a1-read-reise-e1",
                    "a1-list-bahnhof-e1"
                ],
                speakingLessonIDs: []
            ))
        ]
    )

    // MARK: - Zone 5: Exam Skills

    private static let zone5 = CampaignZone(
        id: "z5-exam-skills",
        order: 5,
        title: "Exam Skills",
        goal: "Master the task formats of the Goethe A1 exam.",
        nodes: [
            .lesson(CampaignLesson(
                id: "l19-speaking-picture",
                zoneID: "z5-exam-skills",
                order: 1,
                title: "Sprechen: Bild und Präsentation",
                goal: "You can describe a picture and give a short presentation with questions.",
                vocabulary: vocab("a1-spr-bild"),
                phrases: phrases("a1-spr-bild"),
                dialogue: dialogue("a1-spr-bild"),
                speaking: speaking(
                    id: "sp4-picture",
                    missionLabel: "Oral exam — Teil 2",
                    stages: [
                        ("Ein Bild beschreiben", "Run a Teil 2 style task: describe a simple picture (two people in a city) and answer follow-up questions about it. Then the candidate asks one or two questions and you answer."),
                        ("Kurz vorstellen", "Run a Teil 2/4 style task: the candidate gives a short one-minute presentation about a hobby. You listen, then ask one or two follow-up questions.")
                    ],
                    scenario: "You are the examiner for the Goethe-Zertifikat A1 oral exam, Teil 2. First: the candidate describes a picture (two people, a city street, a shop) and you ask two follow-up questions; then the candidate asks you two questions about the picture. Second: the candidate gives a very short presentation about a hobby and you ask two simple follow-up questions. Keep language at A1 level and give brief friendly feedback."
                ),
                legacyUnitIDs: ["a1-spr-bild", "a1-spr-praesentation"]
            )),
            .lesson(CampaignLesson(
                id: "l20-reading-technique",
                zoneID: "z5-exam-skills",
                order: 2,
                title: "Lesen: E-Mail, Museum, Stellenanzeige",
                goal: "You can handle the main reading text types of the exam.",
                readingPassages: passages(
                    ["a1-read-mail", "a1-read-museum", "a1-read-stellenanzeige"],
                    titles: ["E-Mail", "Museum", "Stellenanzeige"]
                ),
                legacyUnitIDs: ["a1-read-mail", "a1-read-museum", "a1-read-stellenanzeige"]
            )),
            .lesson(CampaignLesson(
                id: "l21-grammar-review",
                zoneID: "z5-exam-skills",
                order: 3,
                title: "Grammatik-Check",
                goal: "You can use comparison and word order in your answers.",
                grammarPoints: [grammar("a1-gram-komparativ"), grammar("a1-gram-satzbau")],
                exercises: exercises("a1-gram-komparativ") + exercises("a1-gram-satzbau"),
                legacyUnitIDs: ["a1-gram-komparativ", "a1-gram-satzbau"]
            )),
            .lesson(CampaignLesson(
                id: "l22-writing-formal",
                zoneID: "z5-exam-skills",
                order: 4,
                title: "Schreiben: Formell",
                goal: "You can write a short formal application and a complaint.",
                writingPrompt: ExamA1Content.unit(id: "a1-schreib-bewerbung")?.writingPrompt,
                legacyUnitIDs: ["a1-schreib-bewerbung", "a1-schreib-beschwerde"]
            )),
            .checkpoint(CampaignCheckpoint(
                id: "cp5-exam-skills",
                zoneID: "z5-exam-skills",
                order: 5,
                title: "Checkpoint: Exam Skills",
                description: "Show that you can handle every exam task format.",
                exerciseIDs: [
                    "a1-read-mail-e1",
                    "a1-read-museum-e1",
                    "a1-read-stellenanzeige-e1",
                    "a1-gram-komparativ-e1",
                    "a1-gram-satzbau-e1"
                ],
                speakingLessonIDs: ["l19-speaking-picture"]
            ))
        ]
    )

    // MARK: - Zone 6: Final Preparation

    private static let zone6 = CampaignZone(
        id: "z6-final-prep",
        order: 6,
        title: "Final Preparation",
        goal: "Put everything together and take the full mock exam.",
        nodes: [
            .finalExam(CampaignFinalExam(
                id: "final-mock-exam",
                title: "Full Goethe A1 Mock Exam",
                description: "A mixed, exam-style test of reading, listening, writing and speaking. This is practice, not an official Goethe score.",
                requiredZoneIDs: ["z1-first-contact", "z2-everyday-life", "z3-shopping-services", "z4-travel-city", "z5-exam-skills"],
                exerciseIDs: [
                    "a1-read-formular-e2",
                    "a1-read-reise-e4",
                    "a1-read-stellenanzeige-e3",
                    "a1-list-bahnhof-e1",
                    "a1-list-einkauf-e2",
                    "a1-list-restaurant-e4",
                    "a1-list-hotel-e3",
                    "a1-gram-sein-haben-e2",
                    "a1-gram-fragen-e7",
                    "a1-gram-trennbar-e1",
                    "a1-voc-zahlen-e3",
                    "a1-voc-zeit-e3"
                ],
                writingLessonIDs: ["l14-writing-messages", "l22-writing-formal"],
                speakingLessonIDs: ["l3-speaking-introduce", "l13-shop-speaking", "l19-speaking-picture"]
            ))
        ]
    )
}
