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
    ),
    ExamUnit(
        id: "a1-voc-zeit",
        section: .reading,
        title: "Zeit und Daten",
        subtitle: "Clock times, parts of the day and dates",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-voc-zeit-1", german: "die Uhr", english: "clock, time", example: "Es ist drei Uhr.", exampleEnglish: "It is three o'clock."),
            ExamVocabularyItem(id: "a1-voc-zeit-2", german: "die Minute", english: "minute", example: "Ich warte fünf Minuten.", exampleEnglish: "I wait five minutes."),
            ExamVocabularyItem(id: "a1-voc-zeit-3", german: "der Morgen", english: "morning", example: "Am Morgen trinke ich Kaffee.", exampleEnglish: "In the morning I drink coffee."),
            ExamVocabularyItem(id: "a1-voc-zeit-4", german: "der Mittag", english: "midday", example: "Um zwölf Uhr mittags esse ich.", exampleEnglish: "At noon I eat."),
            ExamVocabularyItem(id: "a1-voc-zeit-5", german: "der Nachmittag", english: "afternoon", example: "Am Nachmittag lerne ich Deutsch.", exampleEnglish: "In the afternoon I study German."),
            ExamVocabularyItem(id: "a1-voc-zeit-6", german: "der Abend", english: "evening", example: "Am Abend koche ich.", exampleEnglish: "In the evening I cook."),
            ExamVocabularyItem(id: "a1-voc-zeit-7", german: "die Nacht", english: "night", example: "In der Nacht schlafe ich.", exampleEnglish: "At night I sleep."),
            ExamVocabularyItem(id: "a1-voc-zeit-8", german: "heute", english: "today", example: "Heute lerne ich Deutsch.", exampleEnglish: "Today I study German."),
            ExamVocabularyItem(id: "a1-voc-zeit-9", german: "morgen", english: "tomorrow", example: "Morgen fahre ich nach Berlin.", exampleEnglish: "Tomorrow I go to Berlin."),
            ExamVocabularyItem(id: "a1-voc-zeit-10", german: "übermorgen", english: "the day after tomorrow", example: "Übermorgen ist mein Geburtstag.", exampleEnglish: "The day after tomorrow is my birthday."),
            ExamVocabularyItem(id: "a1-voc-zeit-11", german: "der Tag (die Tage)", english: "day, days", example: "Ich habe drei Tage Urlaub.", exampleEnglish: "I have three days of vacation."),
            ExamVocabularyItem(id: "a1-voc-zeit-12", german: "der Monat (die Monate)", english: "month, months", example: "Januar ist mein Lieblingsmonat.", exampleEnglish: "January is my favorite month.")
        ],
        phrases: [
            ExamPhrase(id: "a1-voc-zeit-p1", german: "Wie spät ist es?", english: "What time is it?"),
            ExamPhrase(id: "a1-voc-zeit-p2", german: "Es ist halb sechs.", english: "It is half past five."),
            ExamPhrase(id: "a1-voc-zeit-p3", german: "Wann hast du Zeit?", english: "When do you have time?"),
            ExamPhrase(id: "a1-voc-zeit-p4", german: "Ich habe keine Zeit.", english: "I have no time.")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-voc-zeit-d1", speaker: "Vicki", german: "Wie spät ist es?", english: "What time is it?"),
            ExamDialogueLine(id: "a1-voc-zeit-d2", speaker: "Daniel", german: "Es ist halb acht. Wir müssen los.", english: "It is half past seven. We have to go."),
            ExamDialogueLine(id: "a1-voc-zeit-d3", speaker: "Vicki", german: "Morgen habe ich um zehn Uhr einen Termin.", english: "Tomorrow I have an appointment at ten o'clock."),
            ExamDialogueLine(id: "a1-voc-zeit-d4", speaker: "Daniel", german: "Gut, dann sehen wir uns übermorgen.", english: "Okay, then we will see each other the day after tomorrow.")
        ],
        exercises: [
            ExamExercise(id: "a1-voc-zeit-e1", kind: .gapFill, question: "Es ist ___ acht Uhr — that means 7:30.", options: ["halb", "hundert", "zwei", "viertel"], correctIndex: 0, explanation: "\"halb acht\" = half past seven (7:30)."),
            ExamExercise(id: "a1-voc-zeit-e2", kind: .multipleChoice, question: "What does \"übermorgen\" mean?", options: ["yesterday", "tomorrow", "the day after tomorrow"], correctIndex: 2, explanation: "morgen = tomorrow, übermorgen = the day after tomorrow."),
            ExamExercise(id: "a1-voc-zeit-e3", kind: .multipleChoice, question: "It is 14:15. How do you say it in German?", options: ["es ist Viertel nach zwei", "es ist Viertel vor zwei", "es ist halb zwei"], correctIndex: 0, explanation: "15 minutes past = Viertel NACH (Viertel VOR = 15 minutes to)."),
            ExamExercise(id: "a1-voc-zeit-e4", kind: .gapFill, question: "___ fahre ich nach Berlin.", options: ["Morgen", "Nachmittag", "Minute", "Uhr"], correctIndex: 0, explanation: "morgen = tomorrow. \"Morgen fahre ich nach Berlin.\""),
            ExamExercise(id: "a1-voc-zeit-e5", kind: .listening, question: "Wie spät ist es?", options: ["um 6:20", "um 12:20", "um 6:05"], correctIndex: 0, explanation: "You hear: \"Guten Morgen! Es ist jetzt sechs Uhr zwanzig.\"", spokenText: "Guten Morgen! Es ist jetzt sechs Uhr zwanzig.")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    ),
    ExamUnit(
        id: "a1-voc-wohnen",
        section: .reading,
        title: "Wohnen",
        subtitle: "Homes, rooms and where you live",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-voc-wohnen-1", german: "die Wohnung", english: "apartment, flat", example: "Meine Wohnung hat zwei Zimmer.", exampleEnglish: "My apartment has two rooms."),
            ExamVocabularyItem(id: "a1-voc-wohnen-2", german: "das Haus (die Häuser)", english: "house", example: "Unser Haus ist groß.", exampleEnglish: "Our house is big."),
            ExamVocabularyItem(id: "a1-voc-wohnen-3", german: "das Zimmer (die Zimmer)", english: "room", example: "Das Schlafzimmer ist klein.", exampleEnglish: "The bedroom is small."),
            ExamVocabularyItem(id: "a1-voc-wohnen-4", german: "die Küche", english: "kitchen", example: "Die Küche ist modern.", exampleEnglish: "The kitchen is modern."),
            ExamVocabularyItem(id: "a1-voc-wohnen-5", german: "das Bad", english: "bathroom", example: "Im Bad ist eine Dusche.", exampleEnglish: "The bathroom has a shower."),
            ExamVocabularyItem(id: "a1-voc-wohnen-6", german: "der Balkon", english: "balcony", example: "Wir sitzen gern auf dem Balkon.", exampleEnglish: "We like sitting on the balcony."),
            ExamVocabularyItem(id: "a1-voc-wohnen-7", german: "der Garten", english: "garden", example: "Im Garten sind Blumen.", exampleEnglish: "There are flowers in the garden."),
            ExamVocabularyItem(id: "a1-voc-wohnen-8", german: "wohnen", english: "to live", example: "Ich wohne in einer kleinen Wohnung.", exampleEnglish: "I live in a small apartment."),
            ExamVocabularyItem(id: "a1-voc-wohnen-9", german: "die Straße (die Straßen)", english: "street", example: "Unsere Straße ist ruhig.", exampleEnglish: "Our street is quiet."),
            ExamVocabularyItem(id: "a1-voc-wohnen-10", german: "die Miete", english: "rent", example: "Die Miete ist zu hoch.", exampleEnglish: "The rent is too high."),
            ExamVocabularyItem(id: "a1-voc-wohnen-11", german: "im Erdgeschoss", english: "on the ground floor", example: "Ich wohne im Erdgeschoss.", exampleEnglish: "I live on the ground floor."),
            ExamVocabularyItem(id: "a1-voc-wohnen-12", german: "im ersten Stock", english: "on the first floor", example: "Sie wohnt im ersten Stock.", exampleEnglish: "She lives on the first floor.")
        ],
        phrases: [
            ExamPhrase(id: "a1-voc-wohnen-p1", german: "Wo wohnst du?", english: "Where do you live?"),
            ExamPhrase(id: "a1-voc-wohnen-p2", german: "Ich wohne in einer Wohnung.", english: "I live in an apartment."),
            ExamPhrase(id: "a1-voc-wohnen-p3", german: "Meine Wohnung hat einen Balkon.", english: "My apartment has a balcony."),
            ExamPhrase(id: "a1-voc-wohnen-p4", german: "Die Miete ist zu teuer.", english: "The rent is too expensive.")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-voc-wohnen-d1", speaker: "Vicki", german: "Wo wohnst du?", english: "Where do you live?"),
            ExamDialogueLine(id: "a1-voc-wohnen-d2", speaker: "Daniel", german: "Ich wohne in Hamburg, in einer kleinen Wohnung.", english: "I live in Hamburg, in a small apartment."),
            ExamDialogueLine(id: "a1-voc-wohnen-d3", speaker: "Vicki", german: "Wie ist die Wohnung?", english: "What is the apartment like?"),
            ExamDialogueLine(id: "a1-voc-wohnen-d4", speaker: "Daniel", german: "Sie hat zwei Zimmer, eine Küche, ein Bad und einen Balkon. Die Miete ist 800 Euro.", english: "It has two rooms, a kitchen, a bathroom and a balcony. The rent is 800 euros.")
        ],
        exercises: [
            ExamExercise(id: "a1-voc-wohnen-e1", kind: .gapFill, question: "Ich ___ in Berlin.", options: ["wohne", "wohnen", "wohnt", "wohntest"], correctIndex: 0, explanation: "ich → wohne. \"Ich wohne in Berlin.\""),
            ExamExercise(id: "a1-voc-wohnen-e2", kind: .gapFill, question: "Im ___ ist eine Dusche.", options: ["Bad", "Garten", "Balkon", "Erdgeschoss"], correctIndex: 0, explanation: "A shower is in the bathroom (das Bad)."),
            ExamExercise(id: "a1-voc-wohnen-e3", kind: .multipleChoice, question: "What is \"der Balkon\"?", options: ["the garden", "the balcony", "the basement"], correctIndex: 1, explanation: "der Balkon = balcony; the garden = der Garten; the basement = der Keller."),
            ExamExercise(id: "a1-voc-wohnen-e4", kind: .multipleChoice, question: "\"Ich wohne im Erdgeschoss\" means:", options: ["I live in the basement", "I live on the ground floor", "I live on the top floor"], correctIndex: 1, explanation: "Erdgeschoss = ground floor."),
            ExamExercise(id: "a1-voc-wohnen-e5", kind: .gapFill, question: "Die ___ ist zu hoch.", options: ["Miete", "Küche", "Dusche", "Straße"], correctIndex: 0, explanation: "Only rent (die Miete) can be \"hoch\" (high).")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    ),
    ExamUnit(
        id: "a1-voc-essen",
        section: .reading,
        title: "Essen und Trinken",
        subtitle: "Food, drinks and ordering in a restaurant",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-voc-essen-1", german: "das Brot (die Brote)", english: "bread", example: "Ich esse Brot mit Butter.", exampleEnglish: "I eat bread with butter."),
            ExamVocabularyItem(id: "a1-voc-essen-2", german: "der Käse", english: "cheese", example: "Der Käse ist gut.", exampleEnglish: "The cheese is good."),
            ExamVocabularyItem(id: "a1-voc-essen-3", german: "das Wasser", english: "water", example: "Ich trinke ein Glas Wasser.", exampleEnglish: "I drink a glass of water."),
            ExamVocabularyItem(id: "a1-voc-essen-4", german: "der Kaffee", english: "coffee", example: "Ich trinke morgens Kaffee.", exampleEnglish: "In the morning I drink coffee."),
            ExamVocabularyItem(id: "a1-voc-essen-5", german: "der Tee", english: "tea", example: "Sie trinkt nur Tee.", exampleEnglish: "She only drinks tea."),
            ExamVocabularyItem(id: "a1-voc-essen-6", german: "das Frühstück", english: "breakfast", example: "Zum Frühstück esse ich ein Brötchen.", exampleEnglish: "For breakfast I eat a roll."),
            ExamVocabularyItem(id: "a1-voc-essen-7", german: "das Mittagessen", english: "lunch", example: "Das Mittagessen ist um zwölf Uhr.", exampleEnglish: "Lunch is at noon."),
            ExamVocabularyItem(id: "a1-voc-essen-8", german: "das Abendessen", english: "dinner", example: "Wir essen um 19 Uhr Abendessen.", exampleEnglish: "We have dinner at 7 p.m."),
            ExamVocabularyItem(id: "a1-voc-essen-9", german: "der Appetit", english: "appetite, hunger", example: "Ich habe großen Appetit.", exampleEnglish: "I am very hungry."),
            ExamVocabularyItem(id: "a1-voc-essen-10", german: "lecker", english: "tasty", example: "Die Suppe ist lecker.", exampleEnglish: "The soup is tasty."),
            ExamVocabularyItem(id: "a1-voc-essen-11", german: "bestellen", english: "to order", example: "Ich bestelle einen Tee.", exampleEnglish: "I order a tea."),
            ExamVocabularyItem(id: "a1-voc-essen-12", german: "die Speisekarte (die Speisekarten)", english: "menu (restaurant)", example: "Können Sie mir die Speisekarte geben?", exampleEnglish: "Can you give me the menu?")
        ],
        phrases: [
            ExamPhrase(id: "a1-voc-essen-p1", german: "Was möchtest du essen?", english: "What would you like to eat?"),
            ExamPhrase(id: "a1-voc-essen-p2", german: "Ich hätte gern einen Kaffee.", english: "I would like a coffee."),
            ExamPhrase(id: "a1-voc-essen-p3", german: "Die Speisekarte, bitte.", english: "The menu, please."),
            ExamPhrase(id: "a1-voc-essen-p4", german: "Das Essen ist lecker.", english: "The food is tasty.")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-voc-essen-d1", speaker: "Vicki", german: "Die Speisekarte, bitte.", english: "The menu, please."),
            ExamDialogueLine(id: "a1-voc-essen-d2", speaker: "Kellner", german: "Gerne. Was möchten Sie trinken?", english: "Of course. What would you like to drink?"),
            ExamDialogueLine(id: "a1-voc-essen-d3", speaker: "Vicki", german: "Ich hätte gern einen Kaffee und eine Suppe.", english: "I would like a coffee and a soup."),
            ExamDialogueLine(id: "a1-voc-essen-d4", speaker: "Kellner", german: "Sehr gut. Das Essen ist heute besonders lecker.", english: "Very good. The food is especially tasty today.")
        ],
        exercises: [
            ExamExercise(id: "a1-voc-essen-e1", kind: .gapFill, question: "Ich trinke morgens ___.", options: ["Kaffee", "Suppe", "Käse", "Brot"], correctIndex: 0, explanation: "You drink coffee (Kaffee); the others are food."),
            ExamExercise(id: "a1-voc-essen-e2", kind: .multipleChoice, question: "Which meal is \"das Frühstück\"?", options: ["lunch", "breakfast", "dinner"], correctIndex: 1, explanation: "Frühstück = breakfast; Mittagessen = lunch; Abendessen = dinner."),
            ExamExercise(id: "a1-voc-essen-e3", kind: .gapFill, question: "Können Sie mir die ___ geben?", options: ["Speisekarte", "Miete", "Straße", "Uhr"], correctIndex: 0, explanation: "In a restaurant you ask for the menu (die Speisekarte)."),
            ExamExercise(id: "a1-voc-essen-e4", kind: .multipleChoice, question: "What does \"lecker\" mean?", options: ["tasty", "expensive", "cold"], correctIndex: 0, explanation: "lecker = tasty, delicious."),
            ExamExercise(id: "a1-voc-essen-e5", kind: .listening, question: "Was gibt es heute?", options: ["Suppe und Schnitzel", "Käse und Brot", "Kaffee und Tee"], correctIndex: 0, explanation: "You hear: \"Guten Abend! Wir haben heute Suppe und Schnitzel. Was möchten Sie bestellen?\"", spokenText: "Guten Abend! Wir haben heute Suppe und Schnitzel. Was möchten Sie bestellen?")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    ),
    ExamUnit(
        id: "a1-voc-einkaufen",
        section: .reading,
        title: "Einkaufen",
        subtitle: "Shopping in stores and supermarkets",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-voc-einkaufen-1", german: "einkaufen", english: "to shop", example: "Ich kaufe einmal pro Woche ein.", exampleEnglish: "I shop once a week."),
            ExamVocabularyItem(id: "a1-voc-einkaufen-2", german: "der Supermarkt (die Supermärkte)", english: "supermarket", example: "Der Supermarkt ist in der Nähe.", exampleEnglish: "The supermarket is nearby."),
            ExamVocabularyItem(id: "a1-voc-einkaufen-3", german: "der Laden (die Läden)", english: "shop, store", example: "Der Laden ist am Samstag zu.", exampleEnglish: "The shop is closed on Saturday."),
            ExamVocabularyItem(id: "a1-voc-einkaufen-4", german: "das Obst", english: "fruit", example: "Das Obst ist frisch.", exampleEnglish: "The fruit is fresh."),
            ExamVocabularyItem(id: "a1-voc-einkaufen-5", german: "das Gemüse", english: "vegetables", example: "Ich kaufe frisches Gemüse.", exampleEnglish: "I buy fresh vegetables."),
            ExamVocabularyItem(id: "a1-voc-einkaufen-6", german: "das Fleisch", english: "meat", example: "Das Fleisch kostet zwölf Euro.", exampleEnglish: "The meat costs twelve euros."),
            ExamVocabularyItem(id: "a1-voc-einkaufen-7", german: "das Geld", english: "money", example: "Ich habe genug Geld.", exampleEnglish: "I have enough money."),
            ExamVocabularyItem(id: "a1-voc-einkaufen-8", german: "die Kasse", english: "cash register", example: "Wo ist die Kasse?", exampleEnglish: "Where is the cash register?"),
            ExamVocabularyItem(id: "a1-voc-einkaufen-9", german: "bezahlen", english: "to pay", example: "Ich bezahle mit Karte.", exampleEnglish: "I pay by card."),
            ExamVocabularyItem(id: "a1-voc-einkaufen-10", german: "der Einkaufswagen (die Einkaufswagen)", english: "shopping cart", example: "Ich nehme einen Einkaufswagen.", exampleEnglish: "I take a shopping cart."),
            ExamVocabularyItem(id: "a1-voc-einkaufen-11", german: "die Tasche (die Taschen)", english: "bag", example: "Ich brauche eine Tasche.", exampleEnglish: "I need a bag."),
            ExamVocabularyItem(id: "a1-voc-einkaufen-12", german: "der Rabatt (die Rabatte)", english: "discount", example: "Der Rabatt ist zehn Prozent.", exampleEnglish: "The discount is ten percent.")
        ],
        phrases: [
            ExamPhrase(id: "a1-voc-einkaufen-p1", german: "Können Sie mir helfen?", english: "Can you help me?"),
            ExamPhrase(id: "a1-voc-einkaufen-p2", german: "Ich suche ...", english: "I am looking for ..."),
            ExamPhrase(id: "a1-voc-einkaufen-p3", german: "Wie viel ist das?", english: "How much is that?"),
            ExamPhrase(id: "a1-voc-einkaufen-p4", german: "Ich bezahle mit Karte.", english: "I pay by card.")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-voc-einkaufen-d1", speaker: "Daniel", german: "Kann ich Ihnen helfen? Was suchen Sie?", english: "Can I help you? What are you looking for?"),
            ExamDialogueLine(id: "a1-voc-einkaufen-d2", speaker: "Vicki", german: "Ich suche frisches Obst. Wo ist die Kasse?", english: "I am looking for fresh fruit. Where is the cash register?"),
            ExamDialogueLine(id: "a1-voc-einkaufen-d3", speaker: "Daniel", german: "Die Kasse ist dort. Das Obst kostet zusammen fünf Euro.", english: "The register is over there. The fruit costs five euros in total."),
            ExamDialogueLine(id: "a1-voc-einkaufen-d4", speaker: "Vicki", german: "Danke. Ich bezahle mit Karte.", english: "Thank you. I pay by card.")
        ],
        exercises: [
            ExamExercise(id: "a1-voc-einkaufen-e1", kind: .gapFill, question: "Ich ___ mit Karte.", options: ["bezahle", "bezahlst", "bezahl", "bezahlen"], correctIndex: 0, explanation: "ich → bezahle. \"Ich bezahle mit Karte.\""),
            ExamExercise(id: "a1-voc-einkaufen-e2", kind: .multipleChoice, question: "Which of these is a vegetable?", options: ["der Rabatt", "das Gemüse", "das Geld"], correctIndex: 1, explanation: "das Gemüse = vegetables."),
            ExamExercise(id: "a1-voc-einkaufen-e3", kind: .gapFill, question: "Der Laden ist am Samstag ___.", options: ["zu", "teuer", "frisch", "lecker"], correctIndex: 0, explanation: "zu = closed (auf = open). \"Der Laden ist zu.\""),
            ExamExercise(id: "a1-voc-einkaufen-e4", kind: .multipleChoice, question: "\"Ich suche Äpfel\" means:", options: ["I buy apples every day", "I am looking for apples", "I eat apples"], correctIndex: 1, explanation: "suchen = to look for."),
            ExamExercise(id: "a1-voc-einkaufen-e5", kind: .listening, question: "Wie viel kostet alles zusammen?", options: ["5,50 Euro", "4,50 Euro", "6,50 Euro"], correctIndex: 0, explanation: "You hear: \"Der Kaffee kostet drei Euro, und die Tasche kostet zwei Euro fünfzig. Zusammen: fünf Euro fünfzig.\"", spokenText: "Der Kaffee kostet drei Euro, und die Tasche kostet zwei Euro fünfzig. Zusammen: fünf Euro fünfzig.")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    ),
    ExamUnit(
        id: "a1-voc-stadt",
        section: .reading,
        title: "Stadt und Wege",
        subtitle: "Cities, buildings and asking for directions",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-voc-stadt-1", german: "die Stadt (die Städte)", english: "city", example: "Berlin ist eine große Stadt.", exampleEnglish: "Berlin is a big city."),
            ExamVocabularyItem(id: "a1-voc-stadt-2", german: "die Straße (die Straßen)", english: "street", example: "Die Straße ist lang.", exampleEnglish: "The street is long."),
            ExamVocabularyItem(id: "a1-voc-stadt-3", german: "links", english: "left", example: "Gehen Sie links.", exampleEnglish: "Go left."),
            ExamVocabularyItem(id: "a1-voc-stadt-4", german: "rechts", english: "right", example: "Gehen Sie rechts.", exampleEnglish: "Go right."),
            ExamVocabularyItem(id: "a1-voc-stadt-5", german: "geradeaus", english: "straight ahead", example: "Gehen Sie geradeaus.", exampleEnglish: "Go straight ahead."),
            ExamVocabularyItem(id: "a1-voc-stadt-6", german: "die Ecke (die Ecken)", english: "corner", example: "Das ist an der Ecke.", exampleEnglish: "That is around the corner."),
            ExamVocabularyItem(id: "a1-voc-stadt-7", german: "die Fußgängerzone (die Fußgängerzonen)", english: "pedestrian zone", example: "Die Fußgängerzone ist voll.", exampleEnglish: "The pedestrian zone is crowded."),
            ExamVocabularyItem(id: "a1-voc-stadt-8", german: "das Krankenhaus (die Krankenhäuser)", english: "hospital", example: "Das Krankenhaus ist in der Mitte.", exampleEnglish: "The hospital is in the middle."),
            ExamVocabularyItem(id: "a1-voc-stadt-9", german: "die Kirche (die Kirchen)", english: "church", example: "Die Kirche ist alt.", exampleEnglish: "The church is old."),
            ExamVocabularyItem(id: "a1-voc-stadt-10", german: "die Bank", english: "bank", example: "Die Bank ist am Montag zu.", exampleEnglish: "The bank is closed on Monday."),
            ExamVocabularyItem(id: "a1-voc-stadt-11", german: "das Museum (die Museen)", english: "museum", example: "Ich besuche ein Museum.", exampleEnglish: "I visit a museum."),
            ExamVocabularyItem(id: "a1-voc-stadt-12", german: "die Post", english: "post office", example: "Die Post ist neben dem Park.", exampleEnglish: "The post office is next to the park.")
        ],
        phrases: [
            ExamPhrase(id: "a1-voc-stadt-p1", german: "Entschuldigung, wie komme ich zum Bahnhof?", english: "Excuse me, how do I get to the station?"),
            ExamPhrase(id: "a1-voc-stadt-p2", german: "Gehen Sie geradeaus und dann links.", english: "Go straight ahead and then left."),
            ExamPhrase(id: "a1-voc-stadt-p3", german: "Ist es weit?", english: "Is it far?"),
            ExamPhrase(id: "a1-voc-stadt-p4", german: "Nein, es ist nicht weit. Es ist an der Ecke.", english: "No, it is not far. It is around the corner.")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-voc-stadt-d1", speaker: "Vicki", german: "Entschuldigung, wie komme ich zur Post?", english: "Excuse me, how do I get to the post office?"),
            ExamDialogueLine(id: "a1-voc-stadt-d2", speaker: "Daniel", german: "Gehen Sie geradeaus und an der Ecke links.", english: "Go straight ahead and left at the corner."),
            ExamDialogueLine(id: "a1-voc-stadt-d3", speaker: "Vicki", german: "Ist es weit?", english: "Is it far?"),
            ExamDialogueLine(id: "a1-voc-stadt-d4", speaker: "Daniel", german: "Nein, nicht weit. Die Post ist neben dem Krankenhaus.", english: "No, not far. The post office is next to the hospital.")
        ],
        exercises: [
            ExamExercise(id: "a1-voc-stadt-e1", kind: .multipleChoice, question: "What does \"links\" mean?", options: ["right", "left", "straight ahead"], correctIndex: 1, explanation: "links = left; rechts = right."),
            ExamExercise(id: "a1-voc-stadt-e2", kind: .multipleChoice, question: "\"an der Ecke\" means:", options: ["in the middle", "around the corner", "on the bridge"], correctIndex: 1, explanation: "die Ecke = corner."),
            ExamExercise(id: "a1-voc-stadt-e3", kind: .gapFill, question: "Die Post ist ___ dem Park.", options: ["neben", "unter", "über", "hinter"], correctIndex: 0, explanation: "neben = next to. \"Die Post ist neben dem Park.\""),
            ExamExercise(id: "a1-voc-stadt-e4", kind: .gapFill, question: "Gehen Sie geradeaus, dann ___.", options: ["lang", "links", "weit", "alt"], correctIndex: 1, explanation: "Only \"links\" (left) is a direction you can follow after going straight."),
            ExamExercise(id: "a1-voc-stadt-e5", kind: .multipleChoice, question: "Which building is \"die Bank\"?", options: ["the bench", "the bank", "the boat"], correctIndex: 1, explanation: "die Bank = bank (money); the bench = die Bank is a trick — in German a bench is often \"der Stuhl\" or \"die Parkbank\".")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    ),
    ExamUnit(
        id: "a1-voc-gesundheit",
        section: .reading,
        title: "Gesundheit",
        subtitle: "Body parts, being sick and visiting the doctor",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-voc-gesundheit-1", german: "der Kopf", english: "head", example: "Mein Kopf tut weh.", exampleEnglish: "My head hurts."),
            ExamVocabularyItem(id: "a1-voc-gesundheit-2", german: "die Erkältung (die Erkältungen)", english: "cold", example: "Ich habe eine Erkältung.", exampleEnglish: "I have a cold."),
            ExamVocabularyItem(id: "a1-voc-gesundheit-3", german: "das Fieber", english: "fever", example: "Er hat Fieber.", exampleEnglish: "He has a fever."),
            ExamVocabularyItem(id: "a1-voc-gesundheit-4", german: "der Zahn (die Zähne)", english: "tooth, teeth", example: "Mein Zahn tut weh.", exampleEnglish: "My tooth hurts."),
            ExamVocabularyItem(id: "a1-voc-gesundheit-5", german: "der Arzt (die Ärzte)", english: "doctor", example: "Ich gehe zum Arzt.", exampleEnglish: "I am going to the doctor."),
            ExamVocabularyItem(id: "a1-voc-gesundheit-6", german: "die Apotheke (die Apotheken)", english: "pharmacy", example: "Die Apotheke ist um die Ecke.", exampleEnglish: "The pharmacy is around the corner."),
            ExamVocabularyItem(id: "a1-voc-gesundheit-7", german: "das Medikament (die Medikamente)", english: "medicine", example: "Nehmen Sie das Medikament dreimal am Tag.", exampleEnglish: "Take the medicine three times a day."),
            ExamVocabularyItem(id: "a1-voc-gesundheit-8", german: "der Termin (die Termine)", english: "appointment", example: "Ich habe um drei Uhr einen Termin.", exampleEnglish: "I have an appointment at three o'clock."),
            ExamVocabularyItem(id: "a1-voc-gesundheit-9", german: "krank", english: "sick", example: "Sie ist krank und bleibt zu Hause.", exampleEnglish: "She is sick and stays at home."),
            ExamVocabularyItem(id: "a1-voc-gesundheit-10", german: "gesund", english: "healthy", example: "Obst ist gesund.", exampleEnglish: "Fruit is healthy."),
            ExamVocabularyItem(id: "a1-voc-gesundheit-11", german: "die Tablette (die Tabletten)", english: "pill, tablet", example: "Ich nehme zwei Tabletten.", exampleEnglish: "I take two pills."),
            ExamVocabularyItem(id: "a1-voc-gesundheit-12", german: "sich ausruhen", english: "to rest", example: "Sie muss sich ausruhen.", exampleEnglish: "She needs to rest.")
        ],
        phrases: [
            ExamPhrase(id: "a1-voc-gesundheit-p1", german: "Mir geht es nicht gut.", english: "I am not feeling well."),
            ExamPhrase(id: "a1-voc-gesundheit-p2", german: "Mein Kopf tut weh.", english: "My head hurts."),
            ExamPhrase(id: "a1-voc-gesundheit-p3", german: "Ich muss zum Arzt.", english: "I need to see a doctor."),
            ExamPhrase(id: "a1-voc-gesundheit-p4", german: "Gute Besserung!", english: "Get well soon!")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-voc-gesundheit-d1", speaker: "Vicki", german: "Hallo, mir geht es nicht gut. Mein Kopf tut weh und ich habe Fieber.", english: "Hello, I am not feeling well. My head hurts and I have a fever."),
            ExamDialogueLine(id: "a1-voc-gesundheit-d2", speaker: "Dr. Weber", german: "Seit wann sind Sie krank?", english: "Since when have you been sick?"),
            ExamDialogueLine(id: "a1-voc-gesundheit-d3", speaker: "Vicki", german: "Seit zwei Tagen. Ich muss mich ausruhen, oder?", english: "For two days. I need to rest, right?"),
            ExamDialogueLine(id: "a1-voc-gesundheit-d4", speaker: "Dr. Weber", german: "Ja, nehmen Sie die Tabletten und ruhen Sie sich aus. Gute Besserung!", english: "Yes, take the pills and rest. Get well soon!")
        ],
        exercises: [
            ExamExercise(id: "a1-voc-gesundheit-e1", kind: .gapFill, question: "Mein Zahn ___ weh.", options: ["tut", "ist", "hat", "geht"], correctIndex: 0, explanation: "The fixed phrase is \"tut weh\" (hurts)."),
            ExamExercise(id: "a1-voc-gesundheit-e2", kind: .multipleChoice, question: "\"die Apotheke\" is:", options: ["a hospital", "a pharmacy", "a clinic"], correctIndex: 1, explanation: "Apotheke = pharmacy; hospital = Krankenhaus."),
            ExamExercise(id: "a1-voc-gesundheit-e3", kind: .gapFill, question: "Nehmen Sie die Tablette ___ am Tag.", options: ["dreimal", "links", "gerade", "teuer"], correctIndex: 0, explanation: "dreimal = three times. \"dreimal am Tag\" = three times a day."),
            ExamExercise(id: "a1-voc-gesundheit-e4", kind: .multipleChoice, question: "What do you say to a sick person?", options: ["Gute Besserung!", "Freut mich!", "Bis bald!"], correctIndex: 0, explanation: "Gute Besserung = get well soon."),
            ExamExercise(id: "a1-voc-gesundheit-e5", kind: .multipleChoice, question: "What is the plural of \"der Zahn\"?", options: ["die Zähn", "die Zähne", "der Zähnen"], correctIndex: 1, explanation: "der Zahn → die Zähne (irregular umlaut plural).")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    ),
    ExamUnit(
        id: "a1-voc-arbeit",
        section: .reading,
        title: "Arbeit und Beruf",
        subtitle: "Jobs, professions and work life",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-voc-arbeit-1", german: "die Arbeit (die Arbeiten)", english: "work, job", example: "Ich beginne um acht Uhr die Arbeit.", exampleEnglish: "I start work at eight o'clock."),
            ExamVocabularyItem(id: "a1-voc-arbeit-2", german: "der Beruf (die Berufe)", english: "profession", example: "Was ist Ihr Beruf?", exampleEnglish: "What is your profession?"),
            ExamVocabularyItem(id: "a1-voc-arbeit-3", german: "der Ingenieur (die Ingenieure)", english: "engineer", example: "Mein Bruder ist Ingenieur.", exampleEnglish: "My brother is an engineer."),
            ExamVocabularyItem(id: "a1-voc-arbeit-4", german: "die Lehrerin (die Lehrerinnen)", english: "female teacher", example: "Sie ist Lehrerin.", exampleEnglish: "She is a teacher."),
            ExamVocabularyItem(id: "a1-voc-arbeit-5", german: "der Arzt (die Ärzte)", english: "male doctor", example: "Er ist Arzt in Köln.", exampleEnglish: "He is a doctor in Cologne."),
            ExamVocabularyItem(id: "a1-voc-arbeit-6", german: "der Student (die Studenten)", english: "male student", example: "Ich bin Student.", exampleEnglish: "I am a student."),
            ExamVocabularyItem(id: "a1-voc-arbeit-7", german: "das Büro (die Büros)", english: "office", example: "Ich arbeite im Büro.", exampleEnglish: "I work in the office."),
            ExamVocabularyItem(id: "a1-voc-arbeit-8", german: "die Firma (die Firmen)", english: "company", example: "Meine Firma hat 50 Mitarbeiter.", exampleEnglish: "My company has 50 employees."),
            ExamVocabularyItem(id: "a1-voc-arbeit-9", german: "der Chef (die Chefs)", english: "boss", example: "Mein Chef ist nett.", exampleEnglish: "My boss is nice."),
            ExamVocabularyItem(id: "a1-voc-arbeit-10", german: "der Urlaub (die Urlaube)", english: "vacation", example: "Ich habe zwei Wochen Urlaub.", exampleEnglish: "I have two weeks of vacation."),
            ExamVocabularyItem(id: "a1-voc-arbeit-11", german: "arbeiten", english: "to work", example: "Ich arbeite von Montag bis Freitag.", exampleEnglish: "I work Monday to Friday."),
            ExamVocabularyItem(id: "a1-voc-arbeit-12", german: "die Bewerbung (die Bewerbungen)", english: "job application", example: "Ich schreibe eine Bewerbung.", exampleEnglish: "I am writing a job application.")
        ],
        phrases: [
            ExamPhrase(id: "a1-voc-arbeit-p1", german: "Was machen Sie beruflich?", english: "What do you do for a living?"),
            ExamPhrase(id: "a1-voc-arbeit-p2", german: "Ich arbeite in einer Firma in Berlin.", english: "I work at a company in Berlin."),
            ExamPhrase(id: "a1-voc-arbeit-p3", german: "Ich habe am Wochenende frei.", english: "I am off on the weekend."),
            ExamPhrase(id: "a1-voc-arbeit-p4", german: "Wo arbeiten Sie?", english: "Where do you work?")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-voc-arbeit-d1", speaker: "Vicki", german: "Was machen Sie beruflich?", english: "What do you do for a living?"),
            ExamDialogueLine(id: "a1-voc-arbeit-d2", speaker: "Daniel", german: "Ich bin Ingenieur. Ich arbeite in einer großen Firma.", english: "I am an engineer. I work at a big company."),
            ExamDialogueLine(id: "a1-voc-arbeit-d3", speaker: "Vicki", german: "Wo ist Ihr Büro?", english: "Where is your office?"),
            ExamDialogueLine(id: "a1-voc-arbeit-d4", speaker: "Daniel", german: "Mein Büro ist in der Mitte. Am Wochenende habe ich frei.", english: "My office is in the center. On the weekend I am off.")
        ],
        exercises: [
            ExamExercise(id: "a1-voc-arbeit-e1", kind: .gapFill, question: "Was ist Ihr ___?", options: ["Beruf", "Kopf", "Zahn", "Film"], correctIndex: 0, explanation: "beruflich = professional; der Beruf = profession."),
            ExamExercise(id: "a1-voc-arbeit-e2", kind: .multipleChoice, question: "Which profession is \"die Lehrerin\"?", options: ["male teacher", "female teacher", "female doctor"], correctIndex: 1, explanation: "Lehrerin is the feminine form of Lehrer."),
            ExamExercise(id: "a1-voc-arbeit-e3", kind: .gapFill, question: "Ich ___ von Montag bis Freitag.", options: ["arbeite", "wohne", "esse", "trinke"], correctIndex: 0, explanation: "\"Ich arbeite von Montag bis Freitag\" = I work Monday to Friday."),
            ExamExercise(id: "a1-voc-arbeit-e4", kind: .multipleChoice, question: "What does \"der Urlaub\" mean?", options: ["the office", "the vacation", "the boss"], correctIndex: 1, explanation: "der Urlaub = vacation; office = das Büro; boss = der Chef."),
            ExamExercise(id: "a1-voc-arbeit-e5", kind: .listening, question: "Was ist die Frau?", options: ["Lehrerin", "Ingenieurin", "Ärztin"], correctIndex: 1, explanation: "You hear: \"Guten Tag! Ich heiße Anna Weber. Ich bin Ingenieurin und arbeite seit drei Jahren in dieser Firma.\"", spokenText: "Guten Tag! Ich heiße Anna Weber. Ich bin Ingenieurin und arbeite seit drei Jahren in dieser Firma.")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    ),
    ExamUnit(
        id: "a1-voc-freizeit",
        section: .reading,
        title: "Freizeit und Hobby",
        subtitle: "Free time, hobbies and making plans",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-voc-freizeit-1", german: "die Freizeit", english: "free time", example: "In meiner Freizeit lese ich.", exampleEnglish: "In my free time I read."),
            ExamVocabularyItem(id: "a1-voc-freizeit-2", german: "das Hobby (die Hobbys)", english: "hobby", example: "Mein Hobby ist Kochen.", exampleEnglish: "My hobby is cooking."),
            ExamVocabularyItem(id: "a1-voc-freizeit-3", german: "der Sport (die Sportarten)", english: "sport", example: "Ich mache jeden Tag Sport.", exampleEnglish: "I do sport every day."),
            ExamVocabularyItem(id: "a1-voc-freizeit-4", german: "das Buch (die Bücher)", english: "book", example: "Ich lese ein interessantes Buch.", exampleEnglish: "I am reading an interesting book."),
            ExamVocabularyItem(id: "a1-voc-freizeit-5", german: "die Musik", english: "music", example: "Ich höre gern Musik.", exampleEnglish: "I like listening to music."),
            ExamVocabularyItem(id: "a1-voc-freizeit-6", german: "der Film (die Filme)", english: "film", example: "Am Samstag sehe ich einen Film.", exampleEnglish: "On Saturday I see a film."),
            ExamVocabularyItem(id: "a1-voc-freizeit-7", german: "die Freunde (Pl.)", english: "friends", example: "Ich treffe meine Freunde.", exampleEnglish: "I meet my friends."),
            ExamVocabularyItem(id: "a1-voc-freizeit-8", german: "sich unterhalten", english: "to chat, to talk", example: "Wir unterhalten uns über den Film.", exampleEnglish: "We chat about the film."),
            ExamVocabularyItem(id: "a1-voc-freizeit-9", german: "einladen", english: "to invite", example: "Ich lade dich am Samstag ein.", exampleEnglish: "I invite you on Saturday."),
            ExamVocabularyItem(id: "a1-voc-freizeit-10", german: "gern", english: "to like (to ...)", example: "Ich spiele gern Fußball.", exampleEnglish: "I like playing football."),
            ExamVocabularyItem(id: "a1-voc-freizeit-11", german: "der Fußball", english: "football (soccer)", example: "Der Fußball ist mein Lieblingssport.", exampleEnglish: "Football is my favorite sport."),
            ExamVocabularyItem(id: "a1-voc-freizeit-12", german: "die Party (die Parties)", english: "party", example: "Am Freitag ist Party.", exampleEnglish: "On Friday there is a party.")
        ],
        phrases: [
            ExamPhrase(id: "a1-voc-freizeit-p1", german: "Was sind deine Hobbys?", english: "What are your hobbies?"),
            ExamPhrase(id: "a1-voc-freizeit-p2", german: "Ich lese gern Bücher.", english: "I like reading books."),
            ExamPhrase(id: "a1-voc-freizeit-p3", german: "Möchtest du am Samstag kommen?", english: "Do you want to come on Saturday?"),
            ExamPhrase(id: "a1-voc-freizeit-p4", german: "Ja, sehr gern!", english: "Yes, very much!")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-voc-freizeit-d1", speaker: "Vicki", german: "Was sind deine Hobbys?", english: "What are your hobbies?"),
            ExamDialogueLine(id: "a1-voc-freizeit-d2", speaker: "Daniel", german: "Ich spiele gern Fußball und höre viel Musik.", english: "I like playing football and I listen to a lot of music."),
            ExamDialogueLine(id: "a1-voc-freizeit-d3", speaker: "Vicki", german: "Am Samstag ist eine Party. Möchtest du kommen?", english: "On Saturday there is a party. Do you want to come?"),
            ExamDialogueLine(id: "a1-voc-freizeit-d4", speaker: "Daniel", german: "Ja, sehr gern! Um wie viel Uhr?", english: "Yes, very much! What time?")
        ],
        exercises: [
            ExamExercise(id: "a1-voc-freizeit-e1", kind: .gapFill, question: "Ich spiele ___ Fußball.", options: ["gern", "lecker", "weit", "krank"], correctIndex: 0, explanation: "gern = like to. \"Ich spiele gern Fußball.\""),
            ExamExercise(id: "a1-voc-freizeit-e2", kind: .multipleChoice, question: "\"die Freizeit\" means:", options: ["the sports hall", "free time", "the vacation"], correctIndex: 1, explanation: "Freizeit = free time; vacation = der Urlaub."),
            ExamExercise(id: "a1-voc-freizeit-e3", kind: .gapFill, question: "Wir ___ uns über den Film.", options: ["unterhalten", "bezahlen", "bestellen", "suchen"], correctIndex: 0, explanation: "sich unterhalten = to chat. \"Wir unterhalten uns ...\""),
            ExamExercise(id: "a1-voc-freizeit-e4", kind: .multipleChoice, question: "A good answer to \"Möchtest du kommen?\" is:", options: ["Ja, sehr gern!", "Gute Besserung!", "Entschuldigung!"], correctIndex: 0, explanation: "sehr gern = very much (gladly)."),
            ExamExercise(id: "a1-voc-freizeit-e5", kind: .listening, question: "Was macht die Frau in ihrer Freizeit?", options: ["sie kocht und macht Sport", "sie liest Bücher", "sie sieht Filme"], correctIndex: 0, explanation: "You hear: \"Hallo! In meiner Freizeit koche ich gern und ich mache Sport. Am Samstag lade ich meine Freunde zu einer Party ein.\"", spokenText: "Hallo! In meiner Freizeit koche ich gern und ich mache Sport. Am Samstag lade ich meine Freunde zu einer Party ein.")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    ),
    ExamUnit(
        id: "a1-voc-kleidung",
        section: .reading,
        title: "Kleidung",
        subtitle: "Clothes, sizes and trying things on",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-voc-kleidung-1", german: "die Kleidung", english: "clothes", example: "Ich kaufe neue Kleidung.", exampleEnglish: "I am buying new clothes."),
            ExamVocabularyItem(id: "a1-voc-kleidung-2", german: "das Hemd (die Hemden)", english: "shirt", example: "Das Hemd ist blau.", exampleEnglish: "The shirt is blue."),
            ExamVocabularyItem(id: "a1-voc-kleidung-3", german: "die Hose (die Hosen)", english: "trousers, pants", example: "Diese Hose ist zu groß.", exampleEnglish: "These trousers are too big."),
            ExamVocabularyItem(id: "a1-voc-kleidung-4", german: "das T-Shirt (die T-Shirts)", english: "T-shirt", example: "Das T-Shirt kostet zehn Euro.", exampleEnglish: "The T-shirt costs ten euros."),
            ExamVocabularyItem(id: "a1-voc-kleidung-5", german: "der Pullover (die Pullover)", english: "sweater", example: "Der Pullover ist warm.", exampleEnglish: "The sweater is warm."),
            ExamVocabularyItem(id: "a1-voc-kleidung-6", german: "die Jacke (die Jacken)", english: "jacket", example: "Ich brauche eine neue Jacke.", exampleEnglish: "I need a new jacket."),
            ExamVocabularyItem(id: "a1-voc-kleidung-7", german: "der Schuh (die Schuhe)", english: "shoe", example: "Die Schuhe passen gut.", exampleEnglish: "The shoes fit well."),
            ExamVocabularyItem(id: "a1-voc-kleidung-8", german: "der Rock (die Röcke)", english: "skirt", example: "Der Rock ist rot.", exampleEnglish: "The skirt is red."),
            ExamVocabularyItem(id: "a1-voc-kleidung-9", german: "die Größe (die Größen)", english: "size", example: "Ich brauche Größe M.", exampleEnglish: "I need size M."),
            ExamVocabularyItem(id: "a1-voc-kleidung-10", german: "passen", english: "to fit", example: "Die Jacke passt perfekt.", exampleEnglish: "The jacket fits perfectly."),
            ExamVocabularyItem(id: "a1-voc-kleidung-11", german: "anprobieren", english: "to try on", example: "Kann ich das Hemd anprobieren?", exampleEnglish: "Can I try on the shirt?"),
            ExamVocabularyItem(id: "a1-voc-kleidung-12", german: "die Umkleidekabine (die Umkleidekabinen)", english: "fitting room", example: "Die Umkleidekabine ist dort.", exampleEnglish: "The fitting room is over there.")
        ],
        phrases: [
            ExamPhrase(id: "a1-voc-kleidung-p1", german: "Kann ich das anprobieren?", english: "Can I try this on?"),
            ExamPhrase(id: "a1-voc-kleidung-p2", german: "Das passt perfekt.", english: "That fits perfectly."),
            ExamPhrase(id: "a1-voc-kleidung-p3", german: "Ich brauche Größe M.", english: "I need size M."),
            ExamPhrase(id: "a1-voc-kleidung-p4", german: "Wo sind die Umkleidekabinen?", english: "Where are the fitting rooms?")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-voc-kleidung-d1", speaker: "Vicki", german: "Kann ich dieses Hemd anprobieren?", english: "Can I try this shirt on?"),
            ExamDialogueLine(id: "a1-voc-kleidung-d2", speaker: "Daniel", german: "Natürlich. Die Umkleidekabine ist dort. Welche Größe brauchen Sie?", english: "Of course. The fitting room is over there. What size do you need?"),
            ExamDialogueLine(id: "a1-voc-kleidung-d3", speaker: "Vicki", german: "Ich brauche Größe M.", english: "I need size M."),
            ExamDialogueLine(id: "a1-voc-kleidung-d4", speaker: "Vicki", german: "— Es passt perfekt! Ich nehme es.", english: "— It fits perfectly! I will take it.")
        ],
        exercises: [
            ExamExercise(id: "a1-voc-kleidung-e1", kind: .gapFill, question: "Ich brauche Größe ___.", options: ["M", "zehn", "rot", "heute"], correctIndex: 0, explanation: "Size M (Medium). The others are a number, a color and a time word."),
            ExamExercise(id: "a1-voc-kleidung-e2", kind: .multipleChoice, question: "What does \"anprobieren\" mean?", options: ["to buy", "to try on", "to wash"], correctIndex: 1, explanation: "anprobieren = to try on clothes."),
            ExamExercise(id: "a1-voc-kleidung-e3", kind: .gapFill, question: "Die Schuhe ___ gut.", options: ["passen", "bestellen", "einkaufen", "wohnen"], correctIndex: 0, explanation: "passen = to fit. \"Die Schuhe passen gut.\""),
            ExamExercise(id: "a1-voc-kleidung-e4", kind: .multipleChoice, question: "Where do you try clothes on?", options: ["in der Umkleidekabine", "an der Kasse", "im Krankenhaus"], correctIndex: 0, explanation: "Umkleidekabine = fitting room."),
            ExamExercise(id: "a1-voc-kleidung-e5", kind: .listening, question: "Welche Größe braucht die Frau?", options: ["S", "M", "XL"], correctIndex: 1, explanation: "You hear: \"Entschuldigung, ich brauche dieses Hemd in Größe M.\"", spokenText: "Entschuldigung, ich brauche dieses Hemd in Größe M.")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    ),
    ExamUnit(
        id: "a1-voc-koerper",
        section: .reading,
        title: "Körper und Aussehen",
        subtitle: "Body parts and describing people",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-voc-koerper-1", german: "der Arm (die Arme)", english: "arm", example: "Mein Arm ist lang.", exampleEnglish: "My arm is long."),
            ExamVocabularyItem(id: "a1-voc-koerper-2", german: "die Hand (die Hände)", english: "hand", example: "Ich wasche meine Hände.", exampleEnglish: "I wash my hands."),
            ExamVocabularyItem(id: "a1-voc-koerper-3", german: "die Haare (Pl.)", english: "hair", example: "Sie hat lange, blonde Haare.", exampleEnglish: "She has long, blonde hair."),
            ExamVocabularyItem(id: "a1-voc-koerper-4", german: "das Auge (die Augen)", english: "eye", example: "Er hat blaue Augen.", exampleEnglish: "He has blue eyes."),
            ExamVocabularyItem(id: "a1-voc-koerper-5", german: "der Mund", english: "mouth", example: "Der Mund ist der wichtigste Teil des Gesichts." , exampleEnglish: "The mouth is the most important part of the face."),
            ExamVocabularyItem(id: "a1-voc-koerper-6", german: "die Nase", english: "nose", example: "Ihre Nase ist klein.", exampleEnglish: "Her nose is small."),
            ExamVocabularyItem(id: "a1-voc-koerper-7", german: "lang", english: "long", example: "Er ist groß und hat lange Haare.", exampleEnglish: "He is tall and has long hair."),
            ExamVocabularyItem(id: "a1-voc-koerper-8", german: "kurz", english: "short", example: "Ich habe kurzes Haar.", exampleEnglish: "I have short hair."),
            ExamVocabularyItem(id: "a1-voc-koerper-9", german: "groß", english: "tall, big", example: "Mein Bruder ist sehr groß.", exampleEnglish: "My brother is very tall."),
            ExamVocabularyItem(id: "a1-voc-koerper-10", german: "klein", english: "small, little", example: "Das Kind ist klein.", exampleEnglish: "The child is small."),
            ExamVocabularyItem(id: "a1-voc-koerper-11", german: "blond", english: "blonde", example: "Sie ist blond und nett.", exampleEnglish: "She is blonde and nice."),
            ExamVocabularyItem(id: "a1-voc-koerper-12", german: "dunkel", english: "dark", example: "Er hat dunkles Haar.", exampleEnglish: "He has dark hair.")
        ],
        phrases: [
            ExamPhrase(id: "a1-voc-koerper-p1", german: "Wie siehst du aus?", english: "What do you look like?"),
            ExamPhrase(id: "a1-voc-koerper-p2", german: "Ich habe kurze, dunkle Haare.", english: "I have short, dark hair."),
            ExamPhrase(id: "a1-voc-koerper-p3", german: "Sie ist groß und schlank.", english: "She is tall and slim."),
            ExamPhrase(id: "a1-voc-koerper-p4", german: "Er hat blaue Augen.", english: "He has blue eyes.")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-voc-koerper-d1", speaker: "Vicki", german: "Wie sieht deine Schwester aus?", english: "What does your sister look like?"),
            ExamDialogueLine(id: "a1-voc-koerper-d2", speaker: "Daniel", german: "Sie ist groß und schlank. Sie hat lange, blonde Haare.", english: "She is tall and slim. She has long, blonde hair."),
            ExamDialogueLine(id: "a1-voc-koerper-d3", speaker: "Vicki", german: "Und welche Augen hat sie?", english: "And what eyes does she have?"),
            ExamDialogueLine(id: "a1-voc-koerper-d4", speaker: "Daniel", german: "Sie hat grüne Augen und eine kleine Nase.", english: "She has green eyes and a small nose.")
        ],
        exercises: [
            ExamExercise(id: "a1-voc-koerper-e1", kind: .multipleChoice, question: "What is \"die Hand\"?", options: ["the arm", "the hand", "the foot"], correctIndex: 1, explanation: "die Hand = hand; der Arm = arm; der Fuß = foot."),
            ExamExercise(id: "a1-voc-koerper-e2", kind: .gapFill, question: "Sie hat lange, ___ Haare.", options: ["blonde", "grüne", "große", "kurze"], correctIndex: 0, explanation: "Hair can be blonde (blonde); the others describe eyes or size."),
            ExamExercise(id: "a1-voc-koerper-e3", kind: .multipleChoice, question: "\"kurz\" is the opposite of:", options: ["klein", "lang", "dunkel"], correctIndex: 1, explanation: "kurz = short; lang = long."),
            ExamExercise(id: "a1-voc-koerper-e4", kind: .gapFill, question: "Er ist sehr ___. Er hat lange Haare.", options: ["groß", "heute", "morgen", "lecker"], correctIndex: 0, explanation: "groß = tall (for people)."),
            ExamExercise(id: "a1-voc-koerper-e5", kind: .listening, question: "Wie sieht der Mann aus?", options: ["kurze, dunkle Haare und blaue Augen", "lange, blonde Haare und grüne Augen", "kurze, blonde Haare und braune Augen"], correctIndex: 0, explanation: "You hear: \"Er hat kurze, dunkle Haare und blaue Augen. Er ist groß und dünn.\"", spokenText: "Er hat kurze, dunkle Haare und blaue Augen. Er ist groß und dünn.")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    ),
    ExamUnit(
        id: "a1-voc-reisen",
        section: .reading,
        title: "Reisen",
        subtitle: "Travel, airport and hotel",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-voc-reisen-1", german: "die Reise (die Reisen)", english: "trip, journey", example: "Meine Reise dauert zwei Stunden.", exampleEnglish: "My trip takes two hours."),
            ExamVocabularyItem(id: "a1-voc-reisen-2", german: "das Flugzeug (die Flugzeuge)", english: "plane", example: "Das Flugzeug ist um 10 Uhr.", exampleEnglish: "The plane is at ten o'clock."),
            ExamVocabularyItem(id: "a1-voc-reisen-3", german: "der Flughafen (die Flughäfen)", english: "airport", example: "Ich fahre mit dem Taxi zum Flughafen.", exampleEnglish: "I take a taxi to the airport."),
            ExamVocabularyItem(id: "a1-voc-reisen-4", german: "das Hotel (die Hotels)", english: "hotel", example: "Das Hotel hat ein Schwimmbad.", exampleEnglish: "The hotel has a swimming pool."),
            ExamVocabularyItem(id: "a1-voc-reisen-5", german: "das Zimmer (die Zimmer)", english: "room", example: "Ich brauche ein Zimmer für zwei Nächte.", exampleEnglish: "I need a room for two nights."),
            ExamVocabularyItem(id: "a1-voc-reisen-6", german: "das Ticket (die Tickets)", english: "ticket", example: "Ich kaufe ein Ticket nach Berlin.", exampleEnglish: "I buy a ticket to Berlin."),
            ExamVocabularyItem(id: "a1-voc-reisen-7", german: "der Koffer (die Koffer)", english: "suitcase", example: "Mein Koffer ist schwer.", exampleEnglish: "My suitcase is heavy."),
            ExamVocabularyItem(id: "a1-voc-reisen-8", german: "das Gepäck", english: "luggage", example: "Wo ist mein Gepäck?", exampleEnglish: "Where is my luggage?"),
            ExamVocabularyItem(id: "a1-voc-reisen-9", german: "die Ankunft (die Ankünfte)", english: "arrival", example: "Die Ankunft ist um 14 Uhr 30.", exampleEnglish: "The arrival is at 2:30 p.m."),
            ExamVocabularyItem(id: "a1-voc-reisen-10", german: "der Abflug (die Abflüge)", english: "departure (flight)", example: "Der Abflug ist am Dienstag.", exampleEnglish: "The departure is on Tuesday."),
            ExamVocabularyItem(id: "a1-voc-reisen-11", german: "reservieren", english: "to book, to reserve", example: "Ich reserviere ein Zimmer.", exampleEnglish: "I book a room."),
            ExamVocabularyItem(id: "a1-voc-reisen-12", german: "ankommen", english: "to arrive", example: "Wir kommen morgen an.", exampleEnglish: "We arrive tomorrow.")
        ],
        phrases: [
            ExamPhrase(id: "a1-voc-reisen-p1", german: "Ich möchte ein Ticket nach Berlin kaufen.", english: "I would like to buy a ticket to Berlin."),
            ExamPhrase(id: "a1-voc-reisen-p2", german: "Haben Sie ein freies Zimmer?", english: "Do you have a free room?"),
            ExamPhrase(id: "a1-voc-reisen-p3", german: "Um wie viel Uhr ist der Abflug?", english: "What time is the departure?"),
            ExamPhrase(id: "a1-voc-reisen-p4", german: "Wo ist mein Gepäck?", english: "Where is my luggage?")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-voc-reisen-d1", speaker: "Vicki", german: "Guten Tag. Ich möchte ein Zimmer für zwei Nächte reservieren.", english: "Good day. I would like to book a room for two nights."),
            ExamDialogueLine(id: "a1-voc-reisen-d2", speaker: "Hotelempfang", german: "Gerne. Haben Sie eine Reservierung?", english: "Of course. Do you have a reservation?"),
            ExamDialogueLine(id: "a1-voc-reisen-d3", speaker: "Vicki", german: "Ja, auf den Namen Weber. Mein Zug ist um 15 Uhr.", english: "Yes, under the name Weber. My train is at 3 p.m."),
            ExamDialogueLine(id: "a1-voc-reisen-d4", speaker: "Hotelempfang", german: "Sehr gut. Ihr Zimmer ist fertig.", english: "Very good. Your room is ready.")
        ],
        exercises: [
            ExamExercise(id: "a1-voc-reisen-e1", kind: .gapFill, question: "Ich kaufe ein ___ nach Berlin.", options: ["Ticket", "Gepäck", "Koffer", "Flugzeug"], correctIndex: 0, explanation: "You buy a ticket (Ticket) for travel."),
            ExamExercise(id: "a1-voc-reisen-e2", kind: .multipleChoice, question: "What is \"der Abflug\"?", options: ["the arrival", "the departure", "the delay"], correctIndex: 1, explanation: "Abflug = departure; Ankunft = arrival."),
            ExamExercise(id: "a1-voc-reisen-e3", kind: .gapFill, question: "Mein ___ ist schwer.", options: ["Koffer", "Zimmer", "Hotel", "Flughafen"], correctIndex: 0, explanation: "Only a suitcase (Koffer) can be heavy."),
            ExamExercise(id: "a1-voc-reisen-e4", kind: .multipleChoice, question: "\"Ich reserviere ein Zimmer\" means:", options: ["I book a room", "I clean a room", "I pay for a room"], correctIndex: 0, explanation: "reservieren = to book/reserve."),
            ExamExercise(id: "a1-voc-reisen-e5", kind: .listening, question: "Wann ist der Abflug?", options: ["am Dienstag", "am Mittwoch", "am Montag"], correctIndex: 0, explanation: "You hear: \"Guten Tag! Ihr Abflug ist am Dienstag um 9 Uhr 15. Bitte gehen Sie zu Gate 12.\"", spokenText: "Guten Tag! Ihr Abflug ist am Dienstag um 9 Uhr 15. Bitte gehen Sie zu Gate 12.")
        ],
        speakingScenario: nil,
        writingPrompt: nil
    ),
    ExamUnit(
        id: "a1-voc-telefon",
        section: .reading,
        title: "Telefonieren",
        subtitle: "Phone calls and making appointments",
        text: nil,
        vocabulary: [
            ExamVocabularyItem(id: "a1-voc-telefon-1", german: "das Telefon (die Telefone)", english: "telephone", example: "Ich rufe dich am Telefon an.", exampleEnglish: "I call you on the phone."),
            ExamVocabularyItem(id: "a1-voc-telefon-2", german: "das Handy (die Handys)", english: "mobile phone", example: "Mein Handy ist voll.", exampleEnglish: "My mobile phone is fully charged."),
            ExamVocabularyItem(id: "a1-voc-telefon-3", german: "anrufen", english: "to call (someone)", example: "Ich rufe meine Mutter an.", exampleEnglish: "I call my mother."),
            ExamVocabularyItem(id: "a1-voc-telefon-4", german: "die Nummer (die Nummern)", english: "number", example: "Kennen Sie seine Telefonnummer?", exampleEnglish: "Do you know his phone number?"),
            ExamVocabularyItem(id: "a1-voc-telefon-5", german: "die Nachricht (die Nachrichten)", english: "message", example: "Ich schreibe eine kurze Nachricht.", exampleEnglish: "I write a short message."),
            ExamVocabularyItem(id: "a1-voc-telefon-6", german: "die Mail (die Mails)", english: "e-mail", example: "Ich sende dir eine Mail.", exampleEnglish: "I send you an e-mail."),
            ExamVocabularyItem(id: "a1-voc-telefon-7", german: "sich treffen", english: "to meet", example: "Wir treffen uns um 18 Uhr.", exampleEnglish: "We meet at 6 p.m."),
            ExamVocabularyItem(id: "a1-voc-telefon-8", german: "vereinbaren", english: "to arrange", example: "Wir vereinbaren einen Termin.", exampleEnglish: "We arrange an appointment."),
            ExamVocabularyItem(id: "a1-voc-telefon-9", german: "der Termin (die Termine)", english: "appointment", example: "Der Termin ist am Freitag.", exampleEnglish: "The appointment is on Friday."),
            ExamVocabularyItem(id: "a1-voc-telefon-10", german: "das Gespräch", english: "conversation, call", example: "Das Gespräch ist wichtig.", exampleEnglish: "The conversation is important."),
            ExamVocabularyItem(id: "a1-voc-telefon-11", german: "die Verbindung", english: "connection, line", example: "Die Verbindung ist schlecht.", exampleEnglish: "The connection is bad."),
            ExamVocabularyItem(id: "a1-voc-telefon-12", german: "auflegen", english: "to hang up", example: "Bitte leg nicht auf!", exampleEnglish: "Please don't hang up!")
        ],
        phrases: [
            ExamPhrase(id: "a1-voc-telefon-p1", german: "Hallo, ist Tom da?", english: "Hello, is Tom there?"),
            ExamPhrase(id: "a1-voc-telefon-p2", german: "Können wir uns am Samstag treffen?", english: "Can we meet on Saturday?"),
            ExamPhrase(id: "a1-voc-telefon-p3", german: "Was ist deine Nummer?", english: "What is your number?"),
            ExamPhrase(id: "a1-voc-telefon-p4", german: "Ich rufe dich später an.", english: "I will call you later.")
        ],
        dialogue: [
            ExamDialogueLine(id: "a1-voc-telefon-d1", speaker: "Vicki", german: "Hallo, ist Tom da?", english: "Hello, is Tom there?"),
            ExamDialogueLine(id: "a1-voc-telefon-d2", speaker: "Daniel", german: "Ja, hier ist Tom. Wie geht's?", english: "Yes, this is Tom. How are you?"),
            ExamDialogueLine(id: "a1-voc-telefon-d3", speaker: "Vicki", german: "Gut! Können wir uns am Samstag um 18 Uhr treffen?", english: "Good! Can we meet on Saturday at 6 p.m.?"),
            ExamDialogueLine(id: "a1-voc-telefon-d4", speaker: "Daniel", german: "Ja, super! Ich rufe dich morgen an und wir vereinbaren alles.", english: "Yes, great! I will call you tomorrow and we will arrange everything.")
        ],
        exercises: [
            ExamExercise(id: "a1-voc-telefon-e1", kind: .gapFill, question: "Ich ___ meine Mutter an.", options: ["rufe", "lege", "schreibe", "sende"], correctIndex: 0, explanation: "The fixed phrase is \"jemanden anrufen\" (to call someone)."),
            ExamExercise(id: "a1-voc-telefon-e2", kind: .multipleChoice, question: "What do you say at the start of a call?", options: ["Hallo, ist Tom da?", "Gute Besserung!", "Bis bald!"], correctIndex: 0, explanation: "\"Hallo, ist Tom da?\" = Hello, is Tom there?"),
            ExamExercise(id: "a1-voc-telefon-e3", kind: .gapFill, question: "Können wir uns am Samstag ___?", options: ["treffen", "bestellen", "bezahlen", "einkaufen"], correctIndex: 0, explanation: "sich treffen = to meet."),
            ExamExercise(id: "a1-voc-telefon-e4", kind: .multipleChoice, question: "\"auflegen\" means:", options: ["to answer", "to hang up", "to dial"], correctIndex: 1, explanation: "auflegen = to hang up the phone."),
            ExamExercise(id: "a1-voc-telefon-e5", kind: .listening, question: "Wann treffen sich die beiden?", options: ["am Samstag um 18 Uhr", "am Freitag um 12 Uhr", "am Montag um 9 Uhr"], correctIndex: 0, explanation: "You hear: \"Können wir uns am Samstag um 18 Uhr treffen? — Ja, super!\"", spokenText: "Können wir uns am Samstag um 18 Uhr treffen? — Ja, super!")
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
