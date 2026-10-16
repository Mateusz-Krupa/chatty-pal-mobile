import Foundation

struct LearningPhrase: Hashable {
    let mainContent: String
    let supportContent: String?
}

struct LearningVocabularyItem: Hashable, Identifiable {
    let id = UUID()
    let mainContent: String
    let supportContent: String?
    let usage: String?
}

struct LearningConversationLine: Hashable, Identifiable {
    let id = UUID()
    let speaker: String?
    let mainContent: String
    let supportContent: String?
}

struct LearningLesson: Hashable, Identifiable {
    let id: String
    let title: String
    let description: String
    let languageCode: String
    let level: String
    let topic: String
    let intro: String
    let goals: [String]
    let phrases: [LearningPhrase]
    let vocabulary: [LearningVocabularyItem]
    let conversation: [LearningConversationLine]
    let practicePrompt: String

    var languageName: String {
        LanguageConfig.all[languageCode]?.language ?? languageCode.uppercased()
    }
}

enum MobileLearningCatalog {
    static let germanLessons: [LearningLesson] = [
        LearningLesson(
            id: "de-g-01",
            title: "German Sounds: Read Anything Out Loud",
            description: "Start with what costs nothing: German spelling is fairly consistent, and thousands of words already sound familiar. After this lesson you can sound out almost any written German word.",
            languageCode: "de",
            level: "A1",
            topic: "Pronunciation and cognates",
            intro: "German looks scary but its spelling is fairly consistent: with about ten core sound rules you can make a good first attempt at words you have never heard. And German is full of English cousins (Cognate): Computer, Hotel, Bank. Learn the rules here, then read every new word in this course out loud - that one habit makes the whole path faster.",
            goals: [
                "Read German words out loud with correct vowels and consonants.",
                "Handle the tricky letters: w, z, ch, sch, ei/ie, ä/ö/ü, ß.",
                "Use familiar cognates to say hundreds of German words from day one."
            ],
            phrases: [
                LearningPhrase(mainContent: "Wasser wird kalt.", supportContent: "Water is getting cold. (w = English v; ä = short e)"),
                LearningPhrase(mainContent: "Nein, mein Wein ist klein.", supportContent: "No, my wine is small. (in native words ei says 'eye')"),
                LearningPhrase(mainContent: "Liebe Grüße, bis bald.", supportContent: "Best wishes, see you soon. (ie = long ee; ü = say 'ee' with rounded lips; ß = sharp s)"),
                LearningPhrase(mainContent: "Der Schneemann schläft im Schnee.", supportContent: "The snowman sleeps in the snow. (in native words sch = sh)"),
                LearningPhrase(mainContent: "Kommst du am Sonntag nach Hause?", supportContent: "Are you coming home on Sunday? (ch after a, o, u or au is the throat 'loch' sound)"),
                LearningPhrase(mainContent: "Deutschland ist schön.", supportContent: "Germany is beautiful. (eu = oy as in 'boy'; ö = say 'e' with rounded lips)"),
                LearningPhrase(mainContent: "Warum? Wann? Wo?", supportContent: "Why? When? Where? (German w is almost always a v-sound)"),
                LearningPhrase(mainContent: "Die Zahl null ist rund.", supportContent: "The number zero is round. (z is ts: 'tsaal nool')"),
                LearningPhrase(mainContent: "Ich heiße Anna.", supportContent: "My name is Anna. (ß = s; ch after e or i is the soft hissing ich-sound)")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "der Computer", supportContent: "the computer", usage: "Sounds almost English - and German nouns are always capitalized."),
                LearningVocabularyItem(mainContent: "das Hotel", supportContent: "the hotel", usage: "Many international words are easy to recognize - but learn the article with each noun."),
                LearningVocabularyItem(mainContent: "der Tank", supportContent: "the tank", usage: "A true cognate: same word, German pronunciation."),
                LearningVocabularyItem(mainContent: "das Restaurant", supportContent: "the restaurant", usage: "Internationally understood - a free word."),
                LearningVocabularyItem(mainContent: "die Bank", supportContent: "the bank", usage: "Same spelling as English bank - the money kind exists too.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Lena", mainContent: "Jetzt: 'ich' - ganz weich: 'ikh'.", supportContent: "Now: 'ich' - very soft: 'ikh'."),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ikh ... ikh ... schwer. Es geht!", supportContent: "Ikh ... ikh ... difficult. I am getting there!"),
                LearningConversationLine(speaker: "Lena", mainContent: "Sehr gut! Weiter: 'Warum'?", supportContent: "Very good! Next: 'Warum'?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Varam?", supportContent: "Varam?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Ja, genau! w = v. Perfekt!", supportContent: "Yes, exactly! w = v. Perfect!"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Danke, Lena! Bis bald.", supportContent: "Thanks, Lena! See you soon.")
            ],
            practicePrompt: "Practice German pronunciation with me. Give me one short German word or sentence at a time and ask me to read it out loud. Then give feedback in English on specific sounds: w, z, ch, sch, ei, ie, ü, ö, ß. Keep everything very simple at A1 level."
        ),
        LearningLesson(
            id: "de-g-02",
            title: "Three Genders: der, die, das",
            description: "Every German noun has a gender. Learn the endings that make most of them predictable, and say your name with your first verb: heißen.",
            languageCode: "de",
            level: "A1",
            topic: "Noun gender and heißen",
            intro: "In German every noun wears one of three articles: der (masculine), die (feminine), das (neuter). Gender is grammar, not logic - der Mond, die Sonne, but das Kind. Good news: word endings betray the gender. Words in -ung and -heit are always die; words in -chen are always das; days of the week are der. Learn each noun together with its article from day one and every later lesson becomes easier.",
            goals: [
                "Use der, die and das with common nouns.",
                "Predict the gender from word endings like -ung, -heit, -chen.",
                "Introduce yourself with the verb heißen."
            ],
            phrases: [
                LearningPhrase(mainContent: "Wie heißt du?", supportContent: "What is your name? (literally: how are you called?)"),
                LearningPhrase(mainContent: "Ich heiße Lena.", supportContent: "My name is Lena."),
                LearningPhrase(mainContent: "Das ist der Tisch.", supportContent: "That is the table. (masculine)"),
                LearningPhrase(mainContent: "Das ist die Lampe.", supportContent: "That is the lamp. (feminine)"),
                LearningPhrase(mainContent: "Das ist das Buch.", supportContent: "That is the book. (neuter)"),
                LearningPhrase(mainContent: "Der Hund heißt Bruno.", supportContent: "The dog's name is Bruno."),
                LearningPhrase(mainContent: "Wie heißt das auf Deutsch?", supportContent: "What is that called in German?"),
                LearningPhrase(mainContent: "Er heißt Thomas und sie heißt Anna.", supportContent: "His name is Thomas and her name is Anna.")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "die Zeitung", supportContent: "the newspaper", usage: "Words ending in -ung are always die."),
                LearningVocabularyItem(mainContent: "die Freiheit", supportContent: "freedom", usage: "Words ending in -heit are always die."),
                LearningVocabularyItem(mainContent: "das Mädchen", supportContent: "the girl", usage: "Words ending in -chen are always das - even this one."),
                LearningVocabularyItem(mainContent: "der Montag", supportContent: "Monday", usage: "Days of the week are der: der Montag, der Samstag."),
                LearningVocabularyItem(mainContent: "das Handy", supportContent: "the mobile phone", usage: "Many international words take das - still learn the article with each noun. German for 'cell phone'.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Lena", mainContent: "Hallo! Ich heiße Lena. Wie heißt du?", supportContent: "Hello! My name is Lena. What is your name?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich heiße Jonas. Wie heißt das?", supportContent: "My name is Jonas. What is that called?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Das ist der Tisch. Und das ist die Katze.", supportContent: "That is the table. And that is the cat."),
                LearningConversationLine(speaker: "Jonas", mainContent: "Und der Hund? Er heißt Bruno.", supportContent: "And the dog? His name is Bruno."),
                LearningConversationLine(speaker: "Lena", mainContent: "Richtig! Der, die, das - sehr gut.", supportContent: "Correct! Der, die, das - very good."),
                LearningConversationLine(speaker: "Jonas", mainContent: "Und das Buch? Das heißt 'Deutsch für Anfänger'.", supportContent: "And the book? It is called 'German for beginners'.")
            ],
            practicePrompt: "Practice German articles with me. Name simple objects in English and ask me to answer with the right article der, die or das. Also ask my name so I answer with heißen. Correct only the article gender and heißen forms."
        ),
        LearningLesson(
            id: "de-g-03",
            title: "Being Someone: pronouns and sein",
            description: "The most-used verb in German: sein (to be). With it and the personal pronouns you can say who everyone and everything is: ich bin, du bist, er ist.",
            languageCode: "de",
            level: "A1",
            topic: "Personal pronouns and the verb sein",
            intro: "German introduces itself constantly, so 'to be' is the best first verb: ich bin, du bist, er ist, wir sind, ihr seid, sie sind. One trick for pronouns: er, sie, es follow the grammatical gender, not nature. der Tisch becomes er, die Katze becomes sie, das Kind becomes es. Genders you learned in the previous lesson now do double duty.",
            goals: [
                "Conjugate sein for every person.",
                "Choose the right pronoun er/sie/es for people and things.",
                "Point at things with das ist and dieser/diese/dieses."
            ],
            phrases: [
                LearningPhrase(mainContent: "Ich bin Jonas.", supportContent: "I am Jonas."),
                LearningPhrase(mainContent: "Du bist neu hier.", supportContent: "You are new here."),
                LearningPhrase(mainContent: "Er ist nett.", supportContent: "He is nice. (also 'it is nice' for a masculine noun)"),
                LearningPhrase(mainContent: "Sie ist Ärztin.", supportContent: "She is a doctor."),
                LearningPhrase(mainContent: "Es ist kalt.", supportContent: "It is cold."),
                LearningPhrase(mainContent: "Wir sind Studenten.", supportContent: "We are students."),
                LearningPhrase(mainContent: "Seid ihr bereit?", supportContent: "Are you ready? (plural ihr)"),
                LearningPhrase(mainContent: "Sie sind Lehrer.", supportContent: "They are teachers."),
                LearningPhrase(mainContent: "Das bin ich.", supportContent: "That is me."),
                LearningPhrase(mainContent: "Dieser Kurs ist super.", supportContent: "This course is great.")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "sein", supportContent: "to be", usage: "Ich bin, du bist, er ist - irregular, learn it first."),
                LearningVocabularyItem(mainContent: "der Student", supportContent: "university student", usage: "Masculine; the female form is die Studentin."),
                LearningVocabularyItem(mainContent: "die Lehrerin", supportContent: "the teacher (female)", usage: "Professions add -in for the female form."),
                LearningVocabularyItem(mainContent: "bereit", supportContent: "ready", usage: "'Seid ihr bereit?' - are you all ready?"),
                LearningVocabularyItem(mainContent: "das Fenster", supportContent: "the window", usage: "Neuter: das Fenster, so it becomes es.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Lena", mainContent: "Hallo, ich bin Lena. Bist du neu?", supportContent: "Hi, I am Lena. Are you new?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ja, ich bin Jonas. Wer ist das?", supportContent: "Yes, I am Jonas. Who is that?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Das ist Frau Keller. Sie ist Lehrerin.", supportContent: "That is Ms. Keller. She is a teacher."),
                LearningConversationLine(speaker: "Jonas", mainContent: "Und der Mann dort?", supportContent: "And the man over there?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Er ist Student wie wir. Und müde!", supportContent: "He is a student like us. And tired!"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Stimmt. Wir sind alle müde!", supportContent: "True. We are all tired!")
            ],
            practicePrompt: "Role-play meeting new classmates with me. Ask me who people are and how we are, so I answer with ich bin, er ist, sie ist, wir sind. Correct only the sein forms and the pronoun choice er/sie/es."
        ),
        LearningLesson(
            id: "de-g-04",
            title: "Having Things: haben and ein, kein, mein, dein",
            description: "German's second power verb plus its friendliest little words: a, no, my, your. One pattern to learn and five words to master.",
            languageCode: "de",
            level: "A1",
            topic: "The verb haben and ein-words",
            intro: "haben (to have) is the verb you need most when talking about your life: ich habe, du hast, er hat. It is irregular - the b disappears in du hast and er hat - so drill it early. The words ein (a), kein (no), mein (my) and dein (your) all behave exactly like ein, so learning one pattern gives you four words for free.",
            goals: [
                "Conjugate haben and use it in daily sentences.",
                "Use ein and kein to say you have something or you do not.",
                "Say what is yours with mein and dein."
            ],
            phrases: [
                LearningPhrase(mainContent: "Ich habe Zeit.", supportContent: "I have time."),
                LearningPhrase(mainContent: "Hast du ein Handy?", supportContent: "Do you have a phone?"),
                LearningPhrase(mainContent: "Er hat eine Katze.", supportContent: "He has a cat."),
                LearningPhrase(mainContent: "Wir haben Hunger.", supportContent: "We are hungry (literally: we have hunger)."),
                LearningPhrase(mainContent: "Habt ihr Geld?", supportContent: "Do you (plural) have money?"),
                LearningPhrase(mainContent: "Sie haben keine Frage.", supportContent: "They have no question."),
                LearningPhrase(mainContent: "Das ist mein Buch.", supportContent: "That is my book."),
                LearningPhrase(mainContent: "Ist das deine Tasche?", supportContent: "Is that your bag?"),
                LearningPhrase(mainContent: "Kein Problem!", supportContent: "No problem!")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "haben", supportContent: "to have", usage: "ich habe, du hast, er hat - the b disappears in du hast and er hat."),
                LearningVocabularyItem(mainContent: "das Geld", supportContent: "money", usage: "Uncountable and singular: 'Ich habe kein Geld.'"),
                LearningVocabularyItem(mainContent: "die Tasche", supportContent: "the bag", usage: "Feminine: die Tasche."),
                LearningVocabularyItem(mainContent: "ein", supportContent: "a, one", usage: "Masculine 'a' will change after verbs: ein Mann -> einen Mann (case lesson 7)."),
                LearningVocabularyItem(mainContent: "kein", supportContent: "no, not a", usage: "Negates a noun: kein Geld, keine Zeit.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Lena", mainContent: "Hast du eine Minute? Ich habe eine Frage.", supportContent: "Do you have a minute? I have a question."),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ja, ich habe Zeit. Was ist los?", supportContent: "Yes, I have time. What is up?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Ich habe mein Buch nicht. Es ist weg!", supportContent: "I do not have my book. It is gone!"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Dein Buch ist hier!", supportContent: "Your book is here!"),
                LearningConversationLine(speaker: "Lena", mainContent: "Stimmt! Danke, Jonas.", supportContent: "True! Thanks, Jonas."),
                LearningConversationLine(speaker: "Jonas", mainContent: "Kein Problem.", supportContent: "No problem."),
                LearningConversationLine(speaker: "Lena", mainContent: "Dann sind wir fertig. Jetzt: Kaffee!", supportContent: "Then we are done. Now: coffee!")
            ],
            practicePrompt: "Play my roommate: we are looking for things around the flat. Ask me what I have and what I am looking for. I should use haben, ein, kein, mein and dein with the right forms. Correct only those words."
        ),
        LearningLesson(
            id: "de-g-05",
            title: "Present Tense: regular verbs and word order",
            description: "The German engine: verb endings -e, -st, -t, -en and the law that the verb is always second.",
            languageCode: "de",
            level: "A1",
            topic: "Present tense and verb position",
            intro: "Regular German verbs are almost mechanical: ich lerne, du lernst, er lernt, wir lernen. The endings are -e, -st, -t, -en - only the du and er/sie/es forms really need memory. The bigger rule is about position: the verb is always the second element of the sentence. Start with 'Morgen' and the subject flips behind the verb: Morgen lerne ich.",
            goals: [
                "Conjugate regular verbs in the present tense.",
                "Keep the verb in second position, even after time words.",
                "Form yes/no questions and w-questions in the present."
            ],
            phrases: [
                LearningPhrase(mainContent: "Ich lerne jeden Tag Deutsch.", supportContent: "I learn German every day."),
                LearningPhrase(mainContent: "Du spielst sehr gut.", supportContent: "You play very well."),
                LearningPhrase(mainContent: "Er arbeitet in München.", supportContent: "He works in Munich."),
                LearningPhrase(mainContent: "Sie wohnt in Berlin.", supportContent: "She lives in Berlin."),
                LearningPhrase(mainContent: "Wir machen es zusammen.", supportContent: "We do it together."),
                LearningPhrase(mainContent: "Ihr lernt schnell.", supportContent: "You (plural, friends) learn fast."),
                LearningPhrase(mainContent: "Arbeiten Sie auch hier?", supportContent: "Do you (formal) work here too?"),
                LearningPhrase(mainContent: "Was machst du heute?", supportContent: "What are you doing today?"),
                LearningPhrase(mainContent: "Morgen bleibe ich zu Hause.", supportContent: "Tomorrow I stay at home. (verb still second!)"),
                LearningPhrase(mainContent: "Heute lernen wir, morgen arbeiten wir.", supportContent: "Today we learn, tomorrow we work.")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "lernen", supportContent: "to learn", usage: "Regular model verb: ich lerne, du lernst."),
                LearningVocabularyItem(mainContent: "arbeiten", supportContent: "to work", usage: "Adds an extra e: er arbeitet (not 'er arb-tet')."),
                LearningVocabularyItem(mainContent: "spielen", supportContent: "to play", usage: "Regular: du spielst, er spielt."),
                LearningVocabularyItem(mainContent: "wohnen", supportContent: "to live, to reside", usage: "'Ich wohne in Berlin.'"),
                LearningVocabularyItem(mainContent: "zu Hause", supportContent: "at home", usage: "'Ich bleibe zu Hause.'")
            ],
            conversation: [
                LearningConversationLine(speaker: "Lena", mainContent: "Was machst du hier?", supportContent: "What are you doing here?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich lerne Deutsch. Und du? Arbeitest du hier?", supportContent: "I learn German. And you? Do you work here?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Ja, ich arbeite schon lange hier.", supportContent: "Yes, I have been working here a long time. (literally: I work here already long)"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich wohne auch hier. Meine Schwester wohnt auch hier.", supportContent: "I live here too. My sister lives here too."),
                LearningConversationLine(speaker: "Lena", mainContent: "Was machst du heute Abend?", supportContent: "What are you doing this evening?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Heute Abend bleibe ich zu Hause. Morgen komme ich wieder.", supportContent: "This evening I stay at home. Tomorrow I come back."),
                LearningConversationLine(speaker: "Lena", mainContent: "Dann bis morgen! Viel Spaß zu Hause!", supportContent: "See you tomorrow then! Enjoy your evening at home!")
            ],
            practicePrompt: "Chat with me about our daily routines in German. Ask me simple questions with was, wo and wann. Correct only the verb endings and the verb-second word order."
        ),
        LearningLesson(
            id: "de-g-06",
            title: "Vowel-Changing Verbs and werden",
            description: "The most common verbs break the pattern for du and er: du fährst, er spricht, sie liest, du isst. Plus werden: the verb of change.",
            languageCode: "de",
            level: "A1",
            topic: "Irregular present tense and werden",
            intro: "A handful of very common verbs change their vowel in du and er/sie/es forms: a becomes ä (du fährst), e becomes i (du sprichst), e becomes ie (er liest). The ich and wir forms stay normal, so you only learn the breaking forms once each. Then come meet werden (to become): the verb for everything that changes - weather, mood, plans.",
            goals: [
                "Use vowel-changing verbs correctly after du and er/sie/es.",
                "Conjugate werden and use it for changes.",
                "Talk about routines, food and weather with these verbs."
            ],
            phrases: [
                LearningPhrase(mainContent: "Ich fahre nach Hause.", supportContent: "I am going home. (fahren: du fährst)"),
                LearningPhrase(mainContent: "Fährst du nach Berlin?", supportContent: "Are you going to Berlin?"),
                LearningPhrase(mainContent: "Er spricht drei Sprachen.", supportContent: "He speaks three languages. (sprechen: du sprichst)"),
                LearningPhrase(mainContent: "Sprichst du auch Englisch?", supportContent: "Do you speak English too?"),
                LearningPhrase(mainContent: "Sie liest ein Buch.", supportContent: "She is reading a book. (lesen: er liest)"),
                LearningPhrase(mainContent: "Was liest du gern?", supportContent: "What do you like to read?"),
                LearningPhrase(mainContent: "Du schläfst zu viel.", supportContent: "You sleep too much. (schlafen: du schläfst)"),
                LearningPhrase(mainContent: "Was isst du?", supportContent: "What are you eating? (essen: du isst)"),
                LearningPhrase(mainContent: "Es wird kalt.", supportContent: "It is getting cold."),
                LearningPhrase(mainContent: "Ich werde müde.", supportContent: "I am getting tired.")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "sprechen", supportContent: "to speak", usage: "e becomes i: du sprichst, er spricht."),
                LearningVocabularyItem(mainContent: "fahren", supportContent: "to go, to drive", usage: "a becomes ä: du fährst, er fährt."),
                LearningVocabularyItem(mainContent: "lesen", supportContent: "to read", usage: "e becomes ie: du liest, er liest."),
                LearningVocabularyItem(mainContent: "essen", supportContent: "to eat", usage: "e becomes i and doubles: du isst, er isst."),
                LearningVocabularyItem(mainContent: "werden", supportContent: "to become", usage: "du wirst, er wird - and later it builds the passive voice.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Lena", mainContent: "Was machst du Samstag?", supportContent: "What are you doing Saturday?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich fahre nach Berlin!", supportContent: "I am going to Berlin!"),
                LearningConversationLine(speaker: "Lena", mainContent: "Nach Berlin? Wie lang fährst du?", supportContent: "To Berlin? How long are you traveling?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Nicht lange. Und du? Was machst du?", supportContent: "Not long. And you? What are you doing?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Ich arbeite und lese wie immer.", supportContent: "I work and read as always."),
                LearningConversationLine(speaker: "Jonas", mainContent: "Du arbeitest viel. Wirst du nicht müde?", supportContent: "You work a lot. Are you not getting tired?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Ja. Ich werde müde - gute Nacht!", supportContent: "Yes. I am getting tired - good night!"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Gute Nacht! Bis Montag!", supportContent: "Good night! See you Monday!")
            ],
            practicePrompt: "Talk with me in German about our weekend and about food. Make me use the vowel-changing verbs fahren, sprechen, lesen, essen, schlafen after du and er. Correct only those forms and werden forms."
        ),
        LearningLesson(
            id: "de-g-07",
            title: "The Accusative: what the action hits",
            description: "German marks the thing you do something to: ich sehe den Mann, ich habe einen Hund. Only masculine shouts about it.",
            languageCode: "de",
            level: "A1",
            topic: "Accusative case and its prepositions",
            intro: "When an action hits an object, that object is in the accusative. Only one gender advertises this: masculine. der becomes den, ein becomes einen, mein becomes meinen. Feminine, neuter and plural look identical to the nominative, so you only fight one gender. Prepositions für, ohne and gegen also always put their word in the accusative.",
            goals: [
                "Use den/einen/meinen after verbs with masculine nouns.",
                "Use the pronouns mich and dich.",
                "Build phrases with für, ohne and gegen."
            ],
            phrases: [
                LearningPhrase(mainContent: "Ich habe einen Bruder.", supportContent: "I have a brother."),
                LearningPhrase(mainContent: "Suchst du deinen Schlüssel?", supportContent: "Are you looking for your key?"),
                LearningPhrase(mainContent: "Ich sehe den Mann dort.", supportContent: "I see the man over there."),
                LearningPhrase(mainContent: "Sie kauft einen Tisch.", supportContent: "She is buying a table."),
                LearningPhrase(mainContent: "Der Kaffee ist für dich.", supportContent: "The coffee is for you."),
                LearningPhrase(mainContent: "Ich nehme den Kuchen.", supportContent: "I will take the cake."),
                LearningPhrase(mainContent: "Ich hole dich später.", supportContent: "I will pick you up later."),
                LearningPhrase(mainContent: "Ich brauche deine Hilfe.", supportContent: "I need your help."),
                LearningPhrase(mainContent: "Ohne dich ist es langweilig.", supportContent: "Without you it is boring."),
                LearningPhrase(mainContent: "Er kennt die Antwort.", supportContent: "He knows the answer.")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "den", supportContent: "the (masculine, after a verb)", usage: "der Mann -> Ich sehe den Mann."),
                LearningVocabularyItem(mainContent: "einen", supportContent: "a (masculine, after a verb)", usage: "Ich habe einen Bruder."),
                LearningVocabularyItem(mainContent: "mich", supportContent: "me", usage: "The object form of ich: 'Er kennt mich.'"),
                LearningVocabularyItem(mainContent: "dich", supportContent: "you", usage: "The object form of du: 'Ich hole dich.'"),
                LearningVocabularyItem(mainContent: "brauchen", supportContent: "to need", usage: "Takes the accusative: 'Ich brauche deinen Rat.'")
            ],
            conversation: [
                LearningConversationLine(speaker: "Lena", mainContent: "Was suchst du?", supportContent: "What are you looking for?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich suche meinen Schlüssel.", supportContent: "I am looking for my key."),
                LearningConversationLine(speaker: "Lena", mainContent: "Die Tür ist offen. Du brauchst den Schlüssel nicht!", supportContent: "The door is open. You do not need the key!"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Stimmt! Ich sehe den Schlüssel. Da ist er!", supportContent: "True! I see the key. There it is!"),
                LearningConversationLine(speaker: "Lena", mainContent: "Du suchst den Schlüssel jeden Tag!", supportContent: "You look for the key every day!"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Sehr lustig. Ich hole den Kaffee - ohne Zucker für dich?", supportContent: "Very funny. I am getting the coffee - without sugar for you?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Für mich mit Zucker, bitte!", supportContent: "For me with sugar, please!")
            ],
            practicePrompt: "Play hide-and-seek objects with me in German. Name things we lose, need or buy, and make me say them in the accusative after verbs like sehen, brauchen, suchen, nehmen, kaufen. Correct only the masculine accusative forms (den, einen, meinen, dich, mich)."
        ),
        LearningLesson(
            id: "de-g-08",
            title: "Telling Stories: the -te past and real questions",
            description: "Tell what happened with the simple written past of regular verbs, and learn to ask with w-words: was, wer, wo, wann, warum, wie.",
            languageCode: "de",
            level: "A2",
            topic: "Simple past of regular verbs and question words",
            intro: "German storytelling has a compact past for regular verbs: add -te. ich lernte, du lerntest, er lernte, wir lernten. You will hear it in books, news and fairy tales - and it is the fastest way to sound like you read German. To learn anything you must also ask about it, so this lesson brings the w-words too: was, wer, wo, wann, warum, wie.",
            goals: [
                "Form the -te past of regular verbs.",
                "Use past time words like gestern and früher.",
                "Ask open questions with all six w-words."
            ],
            phrases: [
                LearningPhrase(mainContent: "Gestern lernte ich bis Mitternacht.", supportContent: "Yesterday I studied until midnight."),
                LearningPhrase(mainContent: "Wir kauften einen Tisch.", supportContent: "We bought a table."),
                LearningPhrase(mainContent: "Er arbeitete in München.", supportContent: "He worked in Munich."),
                LearningPhrase(mainContent: "Sie fragte: 'Wie heißt du?'", supportContent: "She asked: 'What is your name?'"),
                LearningPhrase(mainContent: "Warum sagtest du das?", supportContent: "Why did you say that?"),
                LearningPhrase(mainContent: "Was machst du jetzt?", supportContent: "What are you doing now?"),
                LearningPhrase(mainContent: "Wo wohnt deine Schwester?", supportContent: "Where does your sister live?"),
                LearningPhrase(mainContent: "Wann kommt der Bus?", supportContent: "When does the bus come?"),
                LearningPhrase(mainContent: "Wer ist deine Lehrerin?", supportContent: "Who is your teacher?"),
                LearningPhrase(mainContent: "Wie heißt das Wort?", supportContent: "What is this word called?")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "gestern", supportContent: "yesterday", usage: "A common word in past sentences: 'Gestern lernte ich ...'"),
                LearningVocabularyItem(mainContent: "früher", supportContent: "earlier, in the past", usage: "'Früher wohnte ich in Köln.'"),
                LearningVocabularyItem(mainContent: "warum", supportContent: "why", usage: "Ask for reasons: 'Warum lachst du?'"),
                LearningVocabularyItem(mainContent: "sagen", supportContent: "to say", usage: "Past: er sagte."),
                LearningVocabularyItem(mainContent: "fragen", supportContent: "to ask", usage: "Past: sie fragte. A verb built for questions.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Lena", mainContent: "Warum lachst du?", supportContent: "Why are you laughing?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich denke an gestern. Mein Bruder fragte: 'Wann kommst du?' Und ich sagte: 'Morgen.'", supportContent: "I am thinking about yesterday. My brother asked: 'When are you coming?' And I said: 'Tomorrow.'"),
                LearningConversationLine(speaker: "Lena", mainContent: "Und du kommst morgen?", supportContent: "And are you coming tomorrow?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ja. Dann lernen wir zusammen. Gut?", supportContent: "Yes. Then we study together. Good?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Sehr gern. Früher lernte ich oft allein.", supportContent: "With pleasure. Earlier I often studied alone."),
                LearningConversationLine(speaker: "Jonas", mainContent: "Allein? Morgen lernen wir zusammen. Das ist besser!", supportContent: "Alone? Tomorrow we study together. That is better!"),
                LearningConversationLine(speaker: "Lena", mainContent: "Ja! Morgen lesen wir ein Buch.", supportContent: "Yes! Tomorrow we read a book.")
            ],
            practicePrompt: "Talk with me in German about yesterday and about plans. Ask me questions with was, wer, wo, wann, warum and wie, and let me answer in the -te past of regular verbs. Correct only the -te forms and the w-question words."
        ),
        LearningLesson(
            id: "de-g-09",
            title: "Story Past: war, hatte, ging, kam",
            description: "The five irregular past forms you will use every day, plus numbers and plurals so you can talk about your own life.",
            languageCode: "de",
            level: "A2",
            topic: "Irregular past, plurals and numbers",
            intro: "The most important verbs refuse to follow the regular past pattern: sein becomes war, haben becomes hatte, gehen becomes ging, kommen becomes kam, sehen becomes sah. There is no trick - just memorize these five and you can tell stories about yesterday, your age and your family. Numbers count too: German says the tens after the units, so 28 is achtundzwanzig.",
            goals: [
                "Use war, hatte, ging, kam and sah naturally.",
                "Say your age and understand numbers up to 100.",
                "Form the most common plurals (-e, -er, -s)."
            ],
            phrases: [
                LearningPhrase(mainContent: "Ich war gestern zu Hause.", supportContent: "I was at home yesterday."),
                LearningPhrase(mainContent: "Warst du krank?", supportContent: "Were you sick?"),
                LearningPhrase(mainContent: "Wir hatten keine Zeit.", supportContent: "We had no time."),
                LearningPhrase(mainContent: "Er ging nach Hause.", supportContent: "He went home."),
                LearningPhrase(mainContent: "Sie kam spät.", supportContent: "She came late."),
                LearningPhrase(mainContent: "Wie alt bist du?", supportContent: "How old are you?"),
                LearningPhrase(mainContent: "Ich bin achtundzwanzig Jahre alt.", supportContent: "I am 28 years old."),
                LearningPhrase(mainContent: "Wie viele Bücher hast du?", supportContent: "How many books do you have?"),
                LearningPhrase(mainContent: "Ich habe zwei Brüder und eine Schwester.", supportContent: "I have two brothers and one sister."),
                LearningPhrase(mainContent: "Er sah den Film gestern.", supportContent: "He saw the film yesterday.")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "war", supportContent: "was (past of sein)", usage: "ich war, du warst, er war."),
                LearningVocabularyItem(mainContent: "hatte", supportContent: "had (past of haben)", usage: "ich hatte, du hattest, er hatte."),
                LearningVocabularyItem(mainContent: "die Zahl", supportContent: "the number", usage: "German flips numbers: 26 = sechsundzwanzig (six-and-twenty)."),
                LearningVocabularyItem(mainContent: "der Bruder / die Brüder", supportContent: "brother / brothers", usage: "A common plural: add -er and an umlaut."),
                LearningVocabularyItem(mainContent: "das Buch / die Bücher", supportContent: "book / books", usage: "Neuter nouns often take -er plus umlaut in the plural.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Lena", mainContent: "Wie viele Brüder hast du?", supportContent: "How many brothers do you have?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Zwei. Tom ist dreißig und Ben ist achtundzwanzig.", supportContent: "Two. Tom is thirty and Ben is twenty-eight."),
                LearningConversationLine(speaker: "Lena", mainContent: "Was macht ihr gern zusammen?", supportContent: "What do you like to do together?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Wir sehen gern Filme - gestern auch! Ben war hier.", supportContent: "We like watching films - yesterday too! Ben was here."),
                LearningConversationLine(speaker: "Lena", mainContent: "Und der Film gestern? War er gut?", supportContent: "And the film? Was it good?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich war begeistert. Ben war müde und ging sofort nach Hause!", supportContent: "I was thrilled. Ben was tired and went straight home!"),
                LearningConversationLine(speaker: "Lena", mainContent: "Typisch Familie!", supportContent: "Typical family!")
            ],
            practicePrompt: "Interview me in German about my life and my yesterday: my age, my family, what I was and what I had. Make me use war, hatte, ging, kam, sah and real numbers. Correct only the irregular past forms and the numbers."
        ),
        LearningLesson(
            id: "de-g-10",
            title: "The Dative: giving, helping, liking",
            description: "The case for everything that arrives at someone: ich helfe dir, das Buch gehört mir, der Kurs gefällt mir.",
            languageCode: "de",
            level: "A2",
            topic: "Dative case and dative verbs",
            intro: "The dative is the receiver case: you help someone, something belongs to someone, something pleases someone - though some verbs and prepositions simply demand it. Masculine and neuter take dem, feminine becomes der; in the plural the article is den and the noun usually gains -n too (mit den Kindern). A handful of verbs (helfen, gefallen, gehören, danken) and prepositions (mit, zu, nach, aus, von) demand the dative automatically, so you learn them together with the case.",
            goals: [
                "Use dem, der and den + n after dative verbs and prepositions.",
                "Use the pronouns mir and dir.",
                "Say what you like with gefallen."
            ],
            phrases: [
                LearningPhrase(mainContent: "Ich helfe dir.", supportContent: "I help you. (natural English: I'll help you)"),
                LearningPhrase(mainContent: "Hilfst du mir?", supportContent: "Will you help me?"),
                LearningPhrase(mainContent: "Der Kurs gefällt mir.", supportContent: "I like the course. (literally: the course pleases me)"),
                LearningPhrase(mainContent: "Das Buch gehört mir.", supportContent: "The book belongs to me."),
                LearningPhrase(mainContent: "Ich danke dir.", supportContent: "I thank you."),
                LearningPhrase(mainContent: "Er fährt mit dem Bus.", supportContent: "He goes by bus. (mit + dative)"),
                LearningPhrase(mainContent: "Wir gehen zum Bahnhof.", supportContent: "We are going to the train station. (zum = zu + dem)"),
                LearningPhrase(mainContent: "Nach dem Kurs trinke ich Kaffee.", supportContent: "After the course I will drink coffee."),
                LearningPhrase(mainContent: "Das Geschenk ist von meiner Schwester.", supportContent: "The gift is from my sister."),
                LearningPhrase(mainContent: "Wie geht es dir?", supportContent: "How are you? (literally: how goes it to you)")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "helfen", supportContent: "to help", usage: "Always + dative: 'Ich helfe dir.'"),
                LearningVocabularyItem(mainContent: "gefallen", supportContent: "to please, to like", usage: "'Das gefällt mir.' - I like it."),
                LearningVocabularyItem(mainContent: "gehören", supportContent: "to belong to", usage: "Always + dative: 'Das gehört mir.'"),
                LearningVocabularyItem(mainContent: "mit", supportContent: "with, by (transport)", usage: "Always + dative: 'mit dem Bus', 'mit der Bahn'."),
                LearningVocabularyItem(mainContent: "zu", supportContent: "to", usage: "'zum Bahnhof' = zu + dem; 'zur Arbeit' = zu + der.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Lena", mainContent: "Ich verstehe das nicht. Hilfst du mir?", supportContent: "I do not understand this. Will you help me?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Natürlich. Was verstehst du nicht?", supportContent: "Of course. What do you not understand?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Der ganze Dativ! Meine Schwester sagte: Die Übungen gefallen dir bald.", supportContent: "The whole dative! My sister said: you will like the exercises soon."),
                LearningConversationLine(speaker: "Jonas", mainContent: "Sie hat recht. Ich fahre jetzt mit dem Bus. Morgen erkläre ich dir alles!", supportContent: "She is right. I am going by bus now. Tomorrow I will explain everything to you!"),
                LearningConversationLine(speaker: "Lena", mainContent: "Und danach? Trinken wir einen Kaffee?", supportContent: "And after that? Shall we drink a coffee?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Gern. Nach dem Kurs schmeckt der Kaffee besser.", supportContent: "Gladly. After the course the coffee tastes better."),
                LearningConversationLine(speaker: "Lena", mainContent: "Du erklärst gut - bis morgen!", supportContent: "You explain well - see you tomorrow!")
            ],
            practicePrompt: "Role-play everyday situations with me (station, cafe, classroom) where I must offer help, talk about what I like and what belongs to me. Make me use dative articles and mir/dir. Correct only the dative forms."
        ),
        LearningLesson(
            id: "de-g-11",
            title: "Modal Verbs: können, müssen, wollen",
            description: "Say what you can, must and want to do - with the second verb at the end - and connect ideas with und, aber, oder, denn.",
            languageCode: "de",
            level: "A2",
            topic: "Modal verbs and conjunctions",
            intro: "Modal verbs color the action: ich kann (ability), ich muss (necessity), ich will (intention). Two golden rules: ich and er look identical (ich kann, er kann - no ending), and the real action goes to the very end as an infinitive. Then conjunctions: und, aber, oder and denn keep the normal word order, so they are free to use today.",
            goals: [
                "Conjugate können, müssen and wollen.",
                "Send the second verb to the end of the sentence.",
                "Connect sentences with und, aber, oder and denn."
            ],
            phrases: [
                LearningPhrase(mainContent: "Ich kann schwimmen.", supportContent: "I can swim."),
                LearningPhrase(mainContent: "Kannst du mir helfen?", supportContent: "Can you help me?"),
                LearningPhrase(mainContent: "Er muss arbeiten.", supportContent: "He has to work."),
                LearningPhrase(mainContent: "Müssen wir heute zahlen?", supportContent: "Do we have to pay today?"),
                LearningPhrase(mainContent: "Ich will Deutsch lernen.", supportContent: "I want to learn German."),
                LearningPhrase(mainContent: "Was willst du machen?", supportContent: "What do you want to do?"),
                LearningPhrase(mainContent: "Wir können kommen, aber Tom kann nicht.", supportContent: "We can come, but Tom cannot."),
                LearningPhrase(mainContent: "Kaffee oder Tee?", supportContent: "Coffee or tea?"),
                LearningPhrase(mainContent: "Ich trinke keinen Kaffee, sondern Tee.", supportContent: "I do not drink coffee, but tea instead. (sondern corrects a negation)"),
                LearningPhrase(mainContent: "Ich lerne Deutsch, denn ich will in Berlin arbeiten.", supportContent: "I am learning German because I want to work in Berlin."),
                LearningPhrase(mainContent: "Du musst nicht suchen - ich habe den Schlüssel!", supportContent: "You do not have to search - I have the key!")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "können", supportContent: "can, to be able to", usage: "ich kann, du kannst, er kann."),
                LearningVocabularyItem(mainContent: "müssen", supportContent: "must, to have to", usage: "ich muss, du musst, er muss - no ending in ich/er."),
                LearningVocabularyItem(mainContent: "wollen", supportContent: "to want to", usage: "ich will, du willst, er will."),
                LearningVocabularyItem(mainContent: "aber", supportContent: "but", usage: "A conjunction that does not change word order."),
                LearningVocabularyItem(mainContent: "denn", supportContent: "because", usage: "Like und and aber, denn keeps normal verb-second order: 'Ich lerne Deutsch, denn ich will in Berlin arbeiten.'"),
                LearningVocabularyItem(mainContent: "sondern", supportContent: "but rather (after a negation)", usage: "After a no: 'Ich trinke keinen Kaffee, sondern Tee.'")
            ],
            conversation: [
                LearningConversationLine(speaker: "Lena", mainContent: "Was willst du nach dem Kurs machen?", supportContent: "What do you want to do after the course?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich will nur Kaffee trinken. Und du?", supportContent: "I just want to drink coffee. And you?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Ich muss arbeiten, aber ich kann später kommen.", supportContent: "I have to work, but I can come later."),
                LearningConversationLine(speaker: "Jonas", mainContent: "Dann trinken wir um acht. Kennst du ein gutes Café?", supportContent: "Then let us drink at eight. Do you know a good cafe?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Ja! Die Eule ist klein, aber der Kaffee ist super.", supportContent: "Yes! The Eule is small, but the coffee is great."),
                LearningConversationLine(speaker: "Jonas", mainContent: "Müssen wir reservieren?", supportContent: "Do we have to reserve?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Nein, kein Problem. Dann treffen wir uns um acht Uhr.", supportContent: "No, no problem. Then we meet at eight o'clock."),
            ],
            practicePrompt: "Give me short situations in German (exam tomorrow, no money, cannot sleep) and let me answer with können, müssen or wollen plus a verb at the end. Also let me connect two ideas with und, aber, oder, denn. Correct only the modal forms and the verb-at-the-end rule."
        ),
        LearningLesson(
            id: "de-g-12",
            title: "The Spoken Past: ich habe Kaffee gekauft",
            description: "The past tense Germans actually use when they talk: haben plus a ge- word at the end of the sentence.",
            languageCode: "de",
            level: "A2",
            topic: "Present perfect with haben",
            intro: "In much spoken German, completed actions take the present perfect: ich habe gekauft, du hast gelernt, wir haben gemacht - haben in position two, the ge- word at the very end. Regular ge- words are mechanical: ge + stem + t. The written past (lernte) survives mainly in books and news, and in conversation war, hatte, konnte and musste stay short and common.",
            goals: [
                "Form regular past participles (ge- ... -t).",
                "Put haben in second position and the participle at the end.",
                "Know when war and hatte are better than a participle."
            ],
            phrases: [
                LearningPhrase(mainContent: "Ich habe Deutsch gelernt.", supportContent: "I studied German."),
                LearningPhrase(mainContent: "Was hast du gemacht?", supportContent: "What did you do?"),
                LearningPhrase(mainContent: "Sie hat den ganzen Tag gearbeitet.", supportContent: "She worked the whole day."),
                LearningPhrase(mainContent: "Wir haben zwei Stunden gewartet.", supportContent: "We waited two hours."),
                LearningPhrase(mainContent: "Er hat seine Frau gefragt.", supportContent: "He asked his wife."),
                LearningPhrase(mainContent: "Ich habe die Rechnung bezahlt.", supportContent: "I paid the bill."),
                LearningPhrase(mainContent: "Habt ihr gut gespielt?", supportContent: "Did you (plural) play well?"),
                LearningPhrase(mainContent: "Der Kurs hat eine Stunde gedauert.", supportContent: "The course lasted one hour."),
                LearningPhrase(mainContent: "Ich habe die Frage nicht gehört.", supportContent: "I did not hear the question."),
                LearningPhrase(mainContent: "Gestern war ich müde, deshalb habe ich nichts gemacht.", supportContent: "Yesterday I was tired, so I did not do anything.")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "gemacht", supportContent: "done, made", usage: "Regular participle: ge + mach + t."),
                LearningVocabularyItem(mainContent: "gelernt", supportContent: "learned", usage: "ge + lern + t."),
                LearningVocabularyItem(mainContent: "gesucht", supportContent: "searched, looked for", usage: "ge + such + t."),
                LearningVocabularyItem(mainContent: "gesagt", supportContent: "said", usage: "sagen becomes gesagt (no umlaut, no surprise)."),
                LearningVocabularyItem(mainContent: "bezahlt", supportContent: "paid", usage: "Verbs with be- prefix skip the ge-: bezahlen -> bezahlt.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Lena", mainContent: "Was hast du gestern gemacht?", supportContent: "What did you do yesterday?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich habe den ganzen Tag gelernt.", supportContent: "I studied the whole day."),
                LearningConversationLine(speaker: "Lena", mainContent: "Nur das? Aber gestern war das Wetter schön!", supportContent: "Only that? But yesterday the weather was nice!"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich weiß. Ich war im Büro und habe den ganzen Tag gelernt.", supportContent: "I know. I was in the office and studied the whole day."),
                LearningConversationLine(speaker: "Lena", mainContent: "Und jetzt?", supportContent: "And now?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Jetzt habe ich frei. Ich habe einen Kuchen gekauft!", supportContent: "Now I am off. I bought a cake!"),
                LearningConversationLine(speaker: "Lena", mainContent: "Einen Kuchen? Was ist los?", supportContent: "A cake? What is going on?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich habe heute viel gelernt - jetzt habe ich gute Laune!", supportContent: "I studied a lot today - now I am in a good mood!")
            ],
            practicePrompt: "Ask me in German about yesterday, last weekend and last summer. Make me answer in the spoken past: ich habe ... gemacht, gelernt, gekauft. Correct only the participle form and the have-verb position, and remind me when war or hatte is the right choice."
        ),
        LearningLesson(
            id: "de-g-13",
            title: "Rich Descriptions: adjective endings and separable verbs",
            description: "Say a good story in German, not just a story: ein großes Brot, eine neue Tasche. And learn verbs that split themselves in two.",
            languageCode: "de",
            level: "A2",
            topic: "Adjective endings and separable prefixes",
            intro: "Two final upgrades make you sound fluent. Adjectives before a noun wear endings - the tiny cousin of the article sits on the adjective: ein gutes Brot, eine neue Tasche, einen heißen Kaffee. And separable verbs split: the prefix escapes to the end of the sentence. Ich stehe um sieben auf. Wir kaufen am Samstag ein. Both are pure pattern.",
            goals: [
                "Add the right ending to adjectives before a noun.",
                "Use separable verbs with the prefix at the end.",
                "Recognize common prefixes: auf-, ein-, an-, mit-, fern-."
            ],
            phrases: [
                LearningPhrase(mainContent: "Ich habe ein großes Zimmer.", supportContent: "I have a big room."),
                LearningPhrase(mainContent: "Der kleine Hund schläft.", supportContent: "The little dog is sleeping."),
                LearningPhrase(mainContent: "Ich trinke einen heißen Kaffee.", supportContent: "I am drinking a hot coffee."),
                LearningPhrase(mainContent: "Sie kauft eine neue Tasche.", supportContent: "She is buying a new bag."),
                LearningPhrase(mainContent: "Mein alter Computer ist kaputt.", supportContent: "My old computer is broken."),
                LearningPhrase(mainContent: "Ich stehe um sieben Uhr auf.", supportContent: "I get up at seven o'clock."),
                LearningPhrase(mainContent: "Wann stehst du auf?", supportContent: "When do you get up?"),
                LearningPhrase(mainContent: "Wir kaufen samstags ein.", supportContent: "We do the grocery shopping on Saturdays."),
                LearningPhrase(mainContent: "Der Kurs fängt um acht an.", supportContent: "The course starts at eight. (anfangen: fängt ... an)"),
                LearningPhrase(mainContent: "Ich rufe dich später an.", supportContent: "I will call you later.")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "aufstehen", supportContent: "to get up", usage: "Separable: 'Ich stehe um 7 Uhr auf.'"),
                LearningVocabularyItem(mainContent: "einkaufen", supportContent: "to go grocery shopping", usage: "'Wir kaufen ein.'"),
                LearningVocabularyItem(mainContent: "anfangen", supportContent: "to begin", usage: "'Der Film fängt an.' - and note the a becomes ä."),
                LearningVocabularyItem(mainContent: "fernsehen", supportContent: "to watch TV", usage: "'Ich sehe fern.' - even stronger: 'du siehst fern.'"),
                LearningVocabularyItem(mainContent: "mitbringen", supportContent: "to bring along", usage: "'Bringst du Kuchen mit?'")
            ],
            conversation: [
                LearningConversationLine(speaker: "Lena", mainContent: "Wann stehst du normalerweise auf?", supportContent: "When do you usually get up?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich wache um sechs auf, aber ich stehe erst um sieben auf.", supportContent: "I wake up at six, but I only get up at seven."),
                LearningConversationLine(speaker: "Lena", mainContent: "Früh! Ich brauche zuerst meinen Kaffee.", supportContent: "Early! I need my coffee first."),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich kaufe ein frisches Brot, und du machst den Kaffee?", supportContent: "I am buying a fresh loaf of bread, and you make the coffee?"),
                LearningConversationLine(speaker: "Lena", mainContent: "Abgemacht. Bringst du auch Äpfel mit?", supportContent: "Deal. Will you bring apples too?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Die alten Äpfel sind noch gut!", supportContent: "The old apples are still good!"),
                LearningConversationLine(speaker: "Lena", mainContent: "Dann bringen wir keine Äpfel mit.", supportContent: "Then we are not bringing any apples."),
                LearningConversationLine(speaker: "Jonas", mainContent: "Gut. Der Kurs fängt gleich an!", supportContent: "Good. The course starts soon!")
            ],
            practicePrompt: "Describe daily-life objects and routines with me in German: my room, my breakfast, my morning. Make me use adjective endings before nouns and separable verbs like aufstehen, einkaufen, anfangen, mitbringen. Correct only adjective endings and prefix placement."
        ),
        LearningLesson(
            id: "de-g-14",
            title: "Your Story: irregular participles, sein-perfect and dates",
            description: "The final piece: the ge- words that change (gegessen, gefahren), the verbs that take sein, and dates and times - so you can finally tell your story in the German past.",
            languageCode: "de",
            level: "A2",
            topic: "Irregular present perfect and dates",
            intro: "Common verbs keep a vowel change in their ge- word: essen - gegessen, sprechen - gesprochen, fahren - gefahren. And many intransitive verbs describing a change of location or state take sein, not haben: ich bin gefahren, ich bin gekommen, ich bin geblieben. Learn the helper together with the verb. Add dates - ich bin 1994 geboren, halb neun, im Mai - and you can finally tell your whole story in German.",
            goals: [
                "Use the most common irregular past participles.",
                "Choose sein or haben correctly in the spoken past.",
                "Say birth years, dates and clock time."
            ],
            phrases: [
                LearningPhrase(mainContent: "Ich bin nach Deutschland gekommen.", supportContent: "I came to Germany."),
                LearningPhrase(mainContent: "Bist du mit dem Zug gefahren?", supportContent: "Did you go by train?"),
                LearningPhrase(mainContent: "Wir haben gut gegessen.", supportContent: "We ate well."),
                LearningPhrase(mainContent: "Hast du schon getrunken?", supportContent: "Have you drunk something already?"),
                LearningPhrase(mainContent: "Er hat sehr gut gesprochen.", supportContent: "He spoke very well."),
                LearningPhrase(mainContent: "Ich bin 1994 geboren.", supportContent: "I was born in 1994."),
                LearningPhrase(mainContent: "Mein Geburtstag ist im Mai.", supportContent: "My birthday is in May."),
                LearningPhrase(mainContent: "Mein Geburtstag ist am ersten Mai.", supportContent: "My birthday is on May the first. (am + ordinal number for exact dates)"),
                LearningPhrase(mainContent: "Mein Opa ist 2010 gestorben.", supportContent: "My grandpa died in 2010. (sterben takes sein: ist gestorben)"),
                LearningPhrase(mainContent: "Es ist halb neun.", supportContent: "It is 8:30. (German counts toward the next hour)"),
                LearningPhrase(mainContent: "Ich bin zu Hause geblieben.", supportContent: "I stayed at home. (bleiben takes sein)"),
                LearningPhrase(mainContent: "Ich habe lange geschlafen.", supportContent: "I slept for a long time. (schlafen takes haben)"),
                LearningPhrase(mainContent: "Ich bin nach Berlin umgezogen.", supportContent: "I moved to Berlin. (in the sense of relocating home, umziehen takes sein)")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "gegessen", supportContent: "eaten", usage: "haben + gegessen: 'Wir haben gegessen.'"),
                LearningVocabularyItem(mainContent: "gefahren", supportContent: "gone (by vehicle)", usage: "sein + gefahren: 'Ich bin gefahren.'"),
                LearningVocabularyItem(mainContent: "gekommen", supportContent: "come", usage: "Always sein: 'Ich bin gekommen.'"),
                LearningVocabularyItem(mainContent: "geboren", supportContent: "born", usage: "'Ich bin 1995 geboren.' Dates in German: day.month.year - 05.10.1999."),
                LearningVocabularyItem(mainContent: "gelaufen", supportContent: "walked (past participle)", usage: "laufen takes sein: 'Ich bin viel gelaufen.'"),
                LearningVocabularyItem(mainContent: "der erste", supportContent: "first (ordinal number)", usage: "Dates use ordinals: der erste, der zweite, der zehnte - 'am ersten Mai'.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Lena", mainContent: "Erzähl mir von dir! Wo bist du geboren?", supportContent: "Tell me about yourself! Where were you born?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich bin 1994 in Krakau geboren.", supportContent: "I was born in 1994 in Krakow."),
                LearningConversationLine(speaker: "Lena", mainContent: "Und wann bist du nach Deutschland gekommen?", supportContent: "And when did you come to Germany?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Letztes Jahr im Mai. Ich bin mit dem Zug gefahren.", supportContent: "Last year in May. I travelled by train."),
                LearningConversationLine(speaker: "Lena", mainContent: "Und der erste Tag? Was hast du gemacht?", supportContent: "And the first day? What did you do?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich bin viel gelaufen und ich habe Pizza gegessen. Ich war müde, aber glücklich.", supportContent: "I walked a lot and I ate pizza. I was tired, but happy."),
                LearningConversationLine(speaker: "Lena", mainContent: "Und was ist dein Ziel?", supportContent: "And what is your goal?"),
                LearningConversationLine(speaker: "Jonas", mainContent: "Ich will gut Deutsch sprechen. Ich lerne jeden Tag!", supportContent: "I want to speak German well. I learn every day!")
            ],
            practicePrompt: "Interview me about my life story in German: when and where I was born, when I came to this city, what I did last year, what I ate and drank. Make me choose between sein and haben and use irregular participles. Also ask my birthday and what time it is, and make me say one date with an ordinal number (am ersten Mai). Correct only the perfect tense helper, the participle form, and dates."
        )
    ]
}

// MARK: - Auth (Strapi /auth/local — same as web app's auth.service.ts)
