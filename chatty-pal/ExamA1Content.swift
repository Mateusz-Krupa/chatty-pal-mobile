import Foundation

enum ExamA1Content {
    static let units: [ExamUnit] = vocabularyUnits + grammarUnits + readingUnits + listeningUnits + speakingUnits + writingUnits
}

// MARK: - Vocabulary

private let vocabularyUnits: [ExamUnit] = [
    ExamUnit(
        id: "a1-voc-zahlen",
        section: .reading,
        title: "Zahlen und Preise",
        subtitle: "Numbers, prices and shopping basics",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-voc-zahlen-1", german: "eins (1)", english: "one", example: "Ich habe eine Katze.", exampleEnglish: "I have a cat."),
            ExamVocabularyItem(id: "a1-voc-zahlen-2", german: "zwei (2)", english: "two", example: "Wir haben zwei Kinder.", exampleEnglish: "We have two children."),
            ExamVocabularyItem(id: "a1-voc-zahlen-3", german: "drei (3)", english: "three", example: "Die Wohnung hat drei Zimmer.", exampleEnglish: "The apartment has three rooms."),
            ExamVocabularyItem(id: "a1-voc-zahlen-4", german: "fünf (5)", english: "five", example: "Die Jacke kostet fünf Euro.", exampleEnglish: "The jacket costs five euros."),
            ExamVocabularyItem(id: "a1-voc-zahlen-5", german: "zehn (10)", english: "ten", example: "Ich warte zehn Minuten.", exampleEnglish: "I wait ten minutes."),
            ExamVocabularyItem(id: "a1-voc-zahlen-6", german: "zwanzig (20)", english: "twenty", example: "Das Brot kostet zwei Euro zwanzig.", exampleEnglish: "The bread costs two euros twenty cents."),
            ExamVocabularyItem(id: "a1-voc-zahlen-7", german: "fünfzig (50)", english: "fifty", example: "Der Pullover kostet fünfzig Euro.", exampleEnglish: "The sweater costs fifty euros."),
            ExamVocabularyItem(id: "a1-voc-zahlen-8", german: "hundert (100)", english: "one hundred", example: "Das Handy kostet hundert Euro.", exampleEnglish: "The mobile phone costs one hundred euros."),
            ExamVocabularyItem(id: "a1-voc-zahlen-9", german: "teuer", english: "expensive", example: "Der Wagen ist zu teuer.", exampleEnglish: "The car is too expensive."),
            ExamVocabularyItem(id: "a1-voc-zahlen-10", german: "billig", english: "cheap", example: "Die Äpfel sind heute billig.", exampleEnglish: "The apples are cheap today."),
            ExamVocabularyItem(id: "a1-voc-zahlen-11", german: "kosten", english: "to cost", example: "Was kostet das?", exampleEnglish: "How much does that cost?"),
            ExamVocabularyItem(id: "a1-voc-zahlen-12", german: "der Preis", english: "the price", example: "Der Preis ist gut.", exampleEnglish: "The price is good.")
        ],
        phrases: [
            ExamPhrase(id: "a1-voc-zahlen-p1", german: "Wie viel kostet das?", english: "How much does that cost?"),
            ExamPhrase(id: "a1-voc-zahlen-p2", german: "Das ist zu teuer.", english: "That is too expensive."),
            ExamPhrase(id: "a1-voc-zahlen-p3", german: "Ich habe nur fünfzig Euro.", english: "I only have fifty euros.")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-voc-zahlen-d1", speaker: "Vicki", german: "Entschuldigung, wie viel kostet die Jacke?", english: "Excuse me, how much does the jacket cost?"),
            ExamDialogueLine(id: "a1-voc-zahlen-d2", speaker: "Daniel", german: "Die Jacke kostet zwanzig Euro.", english: "The jacket costs twenty euros."),
            ExamDialogueLine(id: "a1-voc-zahlen-d3", speaker: "Vicki", german: "Das ist zu teuer. Haben Sie eine billigere?", english: "That is too expensive. Do you have a cheaper one?")
        ],
        exercises: [
            ExamExercise(id: "a1-voc-zahlen-e1", kind: .gapFill, question: "Die Jacke ___ zwanzig Euro.", options: ["kostet", "ist", "hat", "bin"], correctIndex: 0, explanation: "Use \"kosten\" for prices: Die Jacke kostet zwanzig Euro."),
            ExamExercise(id: "a1-voc-zahlen-e2", kind: .multipleChoice, question: "Zehn plus zwanzig ist ...", options: ["drei", "dreißig", "fünfzig"], correctIndex: 1, explanation: "10 + 20 = 30 (dreißig)."),
            ExamExercise(id: "a1-voc-zahlen-e3", kind: .multipleChoice, question: "Which word means \"cheap\"?", options: ["teuer", "billig", "groß"], correctIndex: 1, explanation: "\"billig\" = cheap; \"teuer\" = expensive.")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    ),
    ExamUnit(
        id: "a1-voc-familie",
        section: .reading,
        title: "Die Familie",
        subtitle: "Family members and descriptions",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-voc-familie-1", german: "die Mutter", english: "mother", example: "Meine Mutter heißt Anna.", exampleEnglish: "My mother is called Anna."),
            ExamVocabularyItem(id: "a1-voc-familie-2", german: "der Vater", english: "father", example: "Mein Vater arbeitet in Berlin.", exampleEnglish: "My father works in Berlin."),
            ExamVocabularyItem(id: "a1-voc-familie-3", german: "die Schwester", english: "sister", example: "Meine Schwester ist Studentin.", exampleEnglish: "My sister is a student."),
            ExamVocabularyItem(id: "a1-voc-familie-4", german: "der Bruder", english: "brother", example: "Mein Bruder ist acht Jahre alt.", exampleEnglish: "My brother is eight years old."),
            ExamVocabularyItem(id: "a1-voc-familie-5", german: "die Eltern (Pl.)", english: "parents", example: "Meine Eltern wohnen in Köln.", exampleEnglish: "My parents live in Cologne."),
            ExamVocabularyItem(id: "a1-voc-familie-6", german: "die Großmutter", english: "grandmother", example: "Meine Großmutter kommt am Samstag.", exampleEnglish: "My grandmother is coming on Saturday."),
            ExamVocabularyItem(id: "a1-voc-familie-7", german: "der Onkel", english: "uncle", example: "Mein Onkel hat drei Autos.", exampleEnglish: "My uncle has three cars."),
            ExamVocabularyItem(id: "a1-voc-familie-8", german: "die Tante", english: "aunt", example: "Meine Tante ist Lehrerin.", exampleEnglish: "My aunt is a teacher."),
            ExamVocabularyItem(id: "a1-voc-familie-9", german: "das Kind (die Kinder)", english: "child (children)", example: "Das Kind spielt im Garten.", exampleEnglish: "The child is playing in the garden."),
            ExamVocabularyItem(id: "a1-voc-familie-10", german: "die Familie", english: "family", example: "Ich komme aus einer großen Familie.", exampleEnglish: "I come from a big family.")
        ],
        phrases: [
            ExamPhrase(id: "a1-voc-familie-p1", german: "Ich habe eine kleine Familie.", english: "I have a small family."),
            ExamPhrase(id: "a1-voc-familie-p2", german: "Wo wohnen Ihre Eltern?", english: "Where do your parents live?"),
            ExamPhrase(id: "a1-voc-familie-p3", german: "Meine Schwester ist verheiratet.", english: "My sister is married.")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-voc-familie-d1", speaker: "Vicki", german: "Haben Sie Geschwister?", english: "Do you have siblings?"),
            ExamDialogueLine(id: "a1-voc-familie-d2", speaker: "Daniel", german: "Ja, ich habe einen Bruder und eine Schwester.", english: "Yes, I have a brother and a sister."),
            ExamDialogueLine(id: "a1-voc-familie-d3", speaker: "Vicki", german: "Wo wohnen Ihre Eltern?", english: "Where do your parents live?"),
            ExamDialogueLine(id: "a1-voc-familie-d4", speaker: "Daniel", german: "Sie wohnen in einer kleinen Stadt in Polen.", english: "They live in a small town in Poland.")
        ],
        exercises: [
            ExamExercise(id: "a1-voc-familie-e1", kind: .gapFill, question: "Mein ___ ist Studentin.", options: ["Bruder", "Onkel", "Schwester", "Vater"], correctIndex: 2, explanation: "\"Studentin\" is feminine, so it is meine Schwester (sister)."),
            ExamExercise(id: "a1-voc-familie-e2", kind: .multipleChoice, question: "What is \"die Großmutter\"?", options: ["grandfather", "grandmother", "aunt"], correctIndex: 1, explanation: "die Großmutter = grandmother; der Großvater = grandfather."),
            ExamExercise(id: "a1-voc-familie-e3", kind: .multipleChoice, question: "What is the plural of \"das Kind\"?", options: ["die Kinder", "die Kinds", "die Kindes"], correctIndex: 0, explanation: "das Kind → die Kinder (irregular plural).")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    )
]

// MARK: - Grammar

private let grammarUnits: [ExamUnit] = [
    ExamUnit(
        id: "a1-gram-sein-haben",
        section: .reading,
        title: "sein und haben",
        subtitle: "The two most important verbs: \"to be\" and \"to have\"",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-gram-sein-haben-1", german: "ich bin", english: "I am", example: "Ich bin Student.", exampleEnglish: "I am a student."),
            ExamVocabularyItem(id: "a1-gram-sein-haben-2", german: "du bist", english: "you are", example: "Du bist nett.", exampleEnglish: "You are nice."),
            ExamVocabularyItem(id: "a1-gram-sein-haben-3", german: "er/sie/es ist", english: "he/she/it is", example: "Sie ist Lehrerin.", exampleEnglish: "She is a teacher."),
            ExamVocabularyItem(id: "a1-gram-sein-haben-4", german: "ich habe", english: "I have", example: "Ich habe zwei Geschwister.", exampleEnglish: "I have two siblings."),
            ExamVocabularyItem(id: "a1-gram-sein-haben-5", german: "du hast", english: "you have", example: "Du hast ein Handy.", exampleEnglish: "You have a mobile phone."),
            ExamVocabularyItem(id: "a1-gram-sein-haben-6", german: "er/sie/es hat", english: "he/she/it has", example: "Er hat eine Katze.", exampleEnglish: "He has a cat.")
        ],
        phrases: [
            ExamPhrase(id: "a1-gram-sein-haben-p1", german: "Wie geht es dir?", english: "How are you?"),
            ExamPhrase(id: "a1-gram-sein-haben-p2", german: "Mir geht es gut.", english: "I am doing well.")
        ],
        dialogue: [],
        exercises: [
            ExamExercise(id: "a1-gram-sein-haben-e1", kind: .gapFill, question: "___ ich Student.", options: ["Bin", "Bist", "Ist", "Seid"], correctIndex: 0, explanation: "ich → bin. \"Ich bin Student.\""),
            ExamExercise(id: "a1-gram-sein-haben-e2", kind: .gapFill, question: "Meine Mutter ___ Lehrerin.", options: ["bin", "bist", "ist", "seid"], correctIndex: 2, explanation: "sie (Mutter) → ist."),
            ExamExercise(id: "a1-gram-sein-haben-e3", kind: .gapFill, question: "Ich ___ einen Bruder.", options: ["habe", "hast", "hat", "bist"], correctIndex: 0, explanation: "ich → habe."),
            ExamExercise(id: "a1-gram-sein-haben-e4", kind: .gapFill, question: "Wir ___ zwei Katzen.", options: ["haben", "hast", "hat", "habe"], correctIndex: 0, explanation: "wir → haben."),
            ExamExercise(id: "a1-gram-sein-haben-e5", kind: .gapFill, question: "Wie ___ du?", options: ["bist", "heiße", "hast", "bin"], correctIndex: 0, explanation: "How are you? → Wie bist du? (informal)")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    )
]

// MARK: - Reading

private let readingUnits: [ExamUnit] = [
    ExamUnit(
        id: "a1-read-anzeige",
        section: .reading,
        title: "Eine Wohnungsanzeige",
        subtitle: "Read a flat rental ad and answer questions",
        text: """
        Miete: 2-Zimmer-Wohnung in Frankfurt
        Die Wohnung ist 65 m² groß und hat eine Küche, ein Bad und einen Balkon. Die Miete ist 750 Euro. Im Haus ist ein Aufzug. In der Nähe sind eine U-Bahn-Station und ein Supermarkt. Besichtigung: Samstag, 14 Uhr.
        """,
        vocabulary: [
            ExamVocabularyItem(id: "a1-read-anzeige-1", german: "die Anzeige", english: "advertisement", example: "Ich habe eine Anzeige gelesen.", exampleEnglish: "I read an advertisement."),
            ExamVocabularyItem(id: "a1-read-anzeige-2", german: "die Miete", english: "rent", example: "Die Miete ist hoch.", exampleEnglish: "The rent is high."),
            ExamVocabularyItem(id: "a1-read-anzeige-3", german: "in der Nähe", english: "nearby", example: "In der Nähe ist ein Supermarkt.", exampleEnglish: "There is a supermarket nearby.")
        ],
        phrases: [],
        dialogue: [],
        exercises: [
            ExamExercise(id: "a1-read-anzeige-e1", kind: .multipleChoice, question: "Wie viele Zimmer hat die Wohnung?", options: ["eins", "zwei", "drei"], correctIndex: 1, explanation: "\"2-Zimmer-Wohnung\" = a two-room apartment."),
            ExamExercise(id: "a1-read-anzeige-e2", kind: .multipleChoice, question: "Was hat die Wohnung NICHT?", options: ["einen Balkon", "ein Bad", "eine Garage"], correctIndex: 2, explanation: "The ad mentions a balcony and a bathroom, but no garage."),
            ExamExercise(id: "a1-read-anzeige-e3", kind: .multipleChoice, question: "Wie hoch ist die Miete?", options: ["650 Euro", "700 Euro", "750 Euro"], correctIndex: 2, explanation: "\"Die Miete ist 750 Euro.\""),
            ExamExercise(id: "a1-read-anzeige-e4", kind: .multipleChoice, question: "Wann ist die Besichtigung?", options: ["Samstag, 14 Uhr", "Sonntag, 10 Uhr", "Freitag, 12 Uhr"], correctIndex: 0, explanation: "The viewing is on Saturday at 14:00.")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    )
]

// MARK: - Listening

private let listeningUnits: [ExamUnit] = [
    ExamUnit(
        id: "a1-list-bahnhof",
        section: .listening,
        title: "Am Bahnhof",
        subtitle: "Listen to short announcements and choose the answer",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-list-bahnhof-1", german: "der Zug", english: "train", example: "Der Zug fährt um 9 Uhr.", exampleEnglish: "The train leaves at 9 o'clock."),
            ExamVocabularyItem(id: "a1-list-bahnhof-2", german: "das Gleis", english: "platform", example: "Gehen Sie zu Gleis 3.", exampleEnglish: "Go to platform 3."),
            ExamVocabularyItem(id: "a1-list-bahnhof-3", german: "ausfallen", english: "to be cancelled", example: "Der Zug fällt aus.", exampleEnglish: "The train is cancelled.")
        ],
        phrases: [
            ExamPhrase(id: "a1-list-bahnhof-p1", german: "Um wie viel Uhr fährt der Zug?", english: "What time does the train leave?"),
            ExamPhrase(id: "a1-list-bahnhof-p2", german: "Wo ist Gleis 3?", english: "Where is platform 3?")
        ],
        dialogue: [],
        exercises: [
            ExamExercise(id: "a1-list-bahnhof-e1", kind: .listening, question: "Wann fährt der Zug nach Berlin?", options: ["um 9 Uhr 00", "um 9 Uhr 30", "um 10 Uhr 30"], correctIndex: 1, explanation: "You hear: \"Der Zug nach Berlin ist um 9 Uhr 30.\"", spokenText: "Der Zug nach Berlin ist um 9 Uhr 30."),
            ExamExercise(id: "a1-list-bahnhof-e2", kind: .listening, question: "Was muss die Person machen?", options: ["rechts gehen", "zwei Gleise weiter gehen", "warten"], correctIndex: 1, explanation: "You hear: \"Geh bitte zwei Gleise weiter, dann links.\"", spokenText: "Geh bitte zwei Gleise weiter, dann links."),
            ExamExercise(id: "a1-list-bahnhof-e3", kind: .listening, question: "Was ist das Problem?", options: ["Der Zug ist spät.", "Der Zug ist voller.", "Der Zug ist abgesagt."], correctIndex: 2, explanation: "\"ausfallen\" means the train is cancelled (abgesagt).", spokenText: "Leider fällt der Zug heute aus.")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    )
]

// MARK: - Speaking

private let speakingUnits: [ExamUnit] = [
    ExamUnit(
        id: "a1-spr-vorstellung",
        section: .speaking,
        title: "Sich vorstellen",
        subtitle: "Examiner asks about you — Teil 1 of the oral exam",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-spr-vorstellung-1", german: "ich heiße ...", english: "my name is ...", example: "Ich heiße Anna.", exampleEnglish: "My name is Anna."),
            ExamVocabularyItem(id: "a1-spr-vorstellung-2", german: "ich komme aus ...", english: "I come from ...", example: "Ich komme aus Polen.", exampleEnglish: "I come from Poland."),
            ExamVocabularyItem(id: "a1-spr-vorstellung-3", german: "ich wohne in ...", english: "I live in ...", example: "Ich wohne in Berlin.", exampleEnglish: "I live in Berlin."),
            ExamVocabularyItem(id: "a1-spr-vorstellung-4", german: "ich arbeite als ...", english: "I work as ...", example: "Ich arbeite als Ingenieur.", exampleEnglish: "I work as an engineer.")
        ],
        phrases: [
            ExamPhrase(id: "a1-spr-vorstellung-p1", german: "Freut mich!", english: "Nice to meet you!"),
            ExamPhrase(id: "a1-spr-vorstellung-p2", german: "Ich spreche ein bisschen Deutsch.", english: "I speak a little German.")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-spr-vorstellung-d1", speaker: "Examiner", german: "Guten Tag! Wie heißen Sie?", english: "Hello! What is your name?"),
            ExamDialogueLine(id: "a1-spr-vorstellung-d2", speaker: "You", german: "Guten Tag! Ich heiße Anna.", english: "Hello! My name is Anna."),
            ExamDialogueLine(id: "a1-spr-vorstellung-d3", speaker: "Examiner", german: "Woher kommen Sie?", english: "Where do you come from?"),
            ExamDialogueLine(id: "a1-spr-vorstellung-d4", speaker: "You", german: "Ich komme aus Polen, aus Warschau.", english: "I come from Poland, from Warsaw.")
        ],
        exercises: [],
        speakingScenario: "You are the examiner for the Goethe-Zertifikat A1 oral exam, Teil 1 (Vorstellung). Greet the candidate, introduce yourself briefly, then ask one by one: (1) Wie heißen Sie? (2) Woher kommen Sie? (3) Wo wohnen Sie jetzt? (4) Was ist Ihr Beruf? / Was studieren Sie? (5) Was sind Ihre Hobbys? React briefly and encouragingly after each answer, then ask the next question. After all questions, give two or three sentences of short, friendly feedback on the candidate's German.",
        writingPrompt: nil
    )
]

// MARK: - Writing

private let writingUnits: [ExamUnit] = [
    ExamUnit(
        id: "a1-schreib-nachricht",
        section: .writing,
        title: "Eine kurze Nachricht",
        subtitle: "Write a short message to a friend",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-schreib-nachricht-1", german: "das Wochenende", english: "the weekend", example: "Am Wochenende bleibe ich zu Hause.", exampleEnglish: "On the weekend I stay at home."),
            ExamVocabularyItem(id: "a1-schreib-nachricht-2", german: "der Film", english: "the film", example: "Ich sehe einen Film.", exampleEnglish: "I watch a film.")
        ],
        phrases: [
            ExamPhrase(id: "a1-schreib-nachricht-p1", german: "Lieber Tom, liebe Anna,", english: "Dear Tom, dear Anna,"),
            ExamPhrase(id: "a1-schreib-nachricht-p2", german: "Wie geht es dir?", english: "How are you?"),
            ExamPhrase(id: "a1-schreib-nachricht-p3", german: "Bis bald! Viele Grüße", english: "See you soon! Best regards")
        ],
        dialogue: [],
        exercises: [],
        speakingScenario: nil,
        writingPrompt: "Write a short message (4-6 sentences) to a friend. Tell them: What did you do last weekend? What are you doing this Saturday? Invite your friend to join you. Use simple A1 sentences."
    )
]
