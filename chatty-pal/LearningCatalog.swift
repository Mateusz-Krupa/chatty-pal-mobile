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
            id: "de-a1-basic-greetings",
            title: "Basic German Greetings and Introductions",
            description: "Learn the first phrases you need to greet someone, introduce yourself, and keep a polite conversation going.",
            languageCode: "de",
            level: "A1",
            topic: "Greetings and introductions",
            intro: "Greetings and introductions are the building blocks of polite conversation. Start by listening with your eyes, repeat the short patterns, then use your own name, city, and country.",
            goals: [
                "Greet someone formally and informally in German.",
                "Introduce your name and where you are from.",
                "Ask simple follow-up questions in a first conversation."
            ],
            phrases: [
                LearningPhrase(mainContent: "Hallo!", supportContent: "Hello!"),
                LearningPhrase(mainContent: "Guten Morgen!", supportContent: "Good morning!"),
                LearningPhrase(mainContent: "Wie geht es Ihnen?", supportContent: "How are you?"),
                LearningPhrase(mainContent: "Mir geht es gut, danke.", supportContent: "I'm fine, thank you."),
                LearningPhrase(mainContent: "Wie heißt du?", supportContent: "What's your name?"),
                LearningPhrase(mainContent: "Ich heiße ...", supportContent: "My name is ..."),
                LearningPhrase(mainContent: "Woher kommen Sie?", supportContent: "Where are you from?"),
                LearningPhrase(mainContent: "Ich komme aus ...", supportContent: "I come from ..."),
                LearningPhrase(mainContent: "Können Sie das bitte wiederholen?", supportContent: "Can you please repeat that?")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "Guten Tag!", supportContent: "Good day!", usage: "A polite greeting for daytime."),
                LearningVocabularyItem(mainContent: "Freut mich.", supportContent: "Nice to meet you.", usage: "Use after someone introduces themselves."),
                LearningVocabularyItem(mainContent: "Bitte.", supportContent: "Please.", usage: "Use to ask politely or respond to thanks."),
                LearningVocabularyItem(mainContent: "Danke.", supportContent: "Thank you.", usage: "Use to express gratitude."),
                LearningVocabularyItem(mainContent: "Entschuldigung.", supportContent: "Excuse me.", usage: "Use to get attention or apologize.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Vicki", mainContent: "Guten Tag! Wie heißen Sie?", supportContent: "Good day! What is your name?"),
                LearningConversationLine(speaker: "Daniel", mainContent: "Ich heiße Daniel. Und Sie?", supportContent: "My name is Daniel. And you?"),
                LearningConversationLine(speaker: "Vicki", mainContent: "Ich heiße Vicki. Freut mich, Sie kennenzulernen.", supportContent: "My name is Vicki. Pleased to meet you."),
                LearningConversationLine(speaker: "Daniel", mainContent: "Ich komme aus Berlin.", supportContent: "I am from Berlin."),
                LearningConversationLine(speaker: "Vicki", mainContent: "Sprechen Sie Englisch?", supportContent: "Do you speak English?")
            ],
            practicePrompt: "Practice a first meeting in German. Greet me, ask my name, say where you are from, and help me answer slowly."
        ),
        LearningLesson(
            id: "de-a2-housing-living",
            title: "German Housing and Living Arrangements",
            description: "Practice describing where you live, what your home is like, and everyday responsibilities around it.",
            languageCode: "de",
            level: "A2",
            topic: "Housing and living",
            intro: "Housing is a practical A2 topic because it combines daily routines, personal preferences, and real-life questions. Use this lesson to explain your own living situation in short connected sentences.",
            goals: [
                "Describe your home and living arrangement with more detail.",
                "Talk about rooms, chores, rent, and moving plans.",
                "Use housing vocabulary in a longer everyday conversation."
            ],
            phrases: [
                LearningPhrase(mainContent: "Ich wohne in einer Wohnung.", supportContent: "I live in an apartment."),
                LearningPhrase(mainContent: "Meine Wohnung hat zwei Schlafzimmer und eine große Küche.", supportContent: "My apartment has two bedrooms and a large kitchen."),
                LearningPhrase(mainContent: "Mein Mitbewohner und ich teilen uns das Badezimmer.", supportContent: "My flatmate and I share the bathroom."),
                LearningPhrase(mainContent: "Wir müssen jeden Samstag das Haus putzen.", supportContent: "We have to clean the house every Saturday."),
                LearningPhrase(mainContent: "Es ist schwer, eine günstige Wohnung zu finden.", supportContent: "It's hard to find an affordable apartment.")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "die Wohnung", supportContent: "apartment", usage: "Use for a flat or apartment."),
                LearningVocabularyItem(mainContent: "das Einfamilienhaus", supportContent: "detached house", usage: "A house for one family."),
                LearningVocabularyItem(mainContent: "die Miete", supportContent: "rent", usage: "Monthly housing payment."),
                LearningVocabularyItem(mainContent: "die Wäsche", supportContent: "laundry", usage: "A common household chore."),
                LearningVocabularyItem(mainContent: "umziehen", supportContent: "to move", usage: "Use when changing homes.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Vicki", mainContent: "Wo wohnst du im Moment?", supportContent: "Where do you live at the moment?"),
                LearningConversationLine(speaker: "Daniel", mainContent: "Ich wohne in einer kleinen Wohnung in Berlin.", supportContent: "I live in a small apartment in Berlin."),
                LearningConversationLine(speaker: "Vicki", mainContent: "Hast du Mitbewohner?", supportContent: "Do you have flatmates?"),
                LearningConversationLine(speaker: "Daniel", mainContent: "Ja, ich teile die Wohnung mit einem Freund.", supportContent: "Yes, I share the apartment with a friend."),
                LearningConversationLine(speaker: "Vicki", mainContent: "Welche Aufgaben machst du zu Hause?", supportContent: "Which chores do you do at home?")
            ],
            practicePrompt: "Practice a German conversation about housing. Ask me where I live, what rooms I have, what chores I do, and help me answer at A2 level."
        )
    ]
}

// MARK: - Auth (Strapi /auth/local — same as web app's auth.service.ts)

