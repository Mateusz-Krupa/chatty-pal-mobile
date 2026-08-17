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
        ),
        LearningLesson(
            id: "de-a1-shopping",
            title: "Shopping in German",
            description: "Buy food and everyday things: ask what something costs, say how much you want, and pay politely.",
            languageCode: "de",
            level: "A1",
            topic: "Shopping and prices",
            intro: "Shopping is one of the first real situations you will have in a German-speaking country. Learn to ask for things, talk about quantities and prices, and pay. Short, polite phrases are enough at A1.",
            goals: [
                "Ask for products and say how much you want.",
                "Ask the price and understand numbers in euros.",
                "Pay politely and thank the seller."
            ],
            phrases: [
                LearningPhrase(mainContent: "Ich möchte ... , bitte.", supportContent: "I would like ..., please."),
                LearningPhrase(mainContent: "Wie viel kostet das?", supportContent: "How much does that cost?"),
                LearningPhrase(mainContent: "Das ist zu teuer.", supportContent: "That is too expensive."),
                LearningPhrase(mainContent: "Haben Sie das billiger?", supportContent: "Do you have that cheaper?"),
                LearningPhrase(mainContent: "Zwei Kilo, bitte.", supportContent: "Two kilos, please."),
                LearningPhrase(mainContent: "Ich zahle in bar.", supportContent: "I pay in cash."),
                LearningPhrase(mainContent: "Ich zahle mit Karte.", supportContent: "I pay by card."),
                LearningPhrase(mainContent: "Brauchen Sie eine Tüte?", supportContent: "Do you need a bag?"),
                LearningPhrase(mainContent: "Danke, auf Wiedersehen!", supportContent: "Thanks, good bye!")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "der Markt", supportContent: "the market", usage: "A place to buy food and flowers."),
                LearningVocabularyItem(mainContent: "der Supermarkt", supportContent: "the supermarket", usage: "A large self-service food store."),
                LearningVocabularyItem(mainContent: "das Brot", supportContent: "the bread", usage: "Bread is a daily staple."),
                LearningVocabularyItem(mainContent: "die Tomate", supportContent: "the tomato", usage: "A common vegetable at the market."),
                LearningVocabularyItem(mainContent: "kosten", supportContent: "to cost", usage: "Das Brot kostet drei Euro.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Vicki", mainContent: "Guten Morgen! Was möchten Sie?", supportContent: "Good morning! What would you like?"),
                LearningConversationLine(speaker: "Daniel", mainContent: "Ich möchte zwei Kilo Tomaten, bitte.", supportContent: "I would like two kilos of tomatoes, please."),
                LearningConversationLine(speaker: "Vicki", mainContent: "Ein Kilo kostet drei Euro fünfzig.", supportContent: "One kilo costs three euros fifty."),
                LearningConversationLine(speaker: "Daniel", mainContent: "Okay, das ist gut. Ich zahle in bar.", supportContent: "Okay, that is good. I pay in cash."),
                LearningConversationLine(speaker: "Vicki", mainContent: "Das macht sieben Euro. Hier ist Ihre Quittung.", supportContent: "That makes seven euros. Here is your receipt."),
                LearningConversationLine(speaker: "Daniel", mainContent: "Danke, auf Wiedersehen!", supportContent: "Thanks, good bye!")
            ],
            practicePrompt: "Practice a short shopping conversation. You are the seller in a market or supermarket. I want to buy a few things, ask the price, and pay. Keep it simple at A1 level."
        ),
        LearningLesson(
            id: "de-a1-restaurant",
            title: "Ordering in a Restaurant",
            description: "Sit down, read a little of the menu, order food and drink, ask for the bill, and pay.",
            languageCode: "de",
            level: "A1",
            topic: "Restaurant and ordering",
            intro: "In a German restaurant the waiter usually waits for you to order. Learn the few sentences that make ordering easy: what you want, how you pay, and polite words like bitte and danke.",
            goals: [
                "Order food and drink with bitte.",
                "Understand a simple menu and the waiter's questions.",
                "Ask for the bill and pay politely."
            ],
            phrases: [
                LearningPhrase(mainContent: "Ein Tisch für zwei, bitte.", supportContent: "A table for two, please."),
                LearningPhrase(mainContent: "Was empfehlen Sie?", supportContent: "What do you recommend?"),
                LearningPhrase(mainContent: "Ich hätte gerne ...", supportContent: "I would like ..."),
                LearningPhrase(mainContent: "Und zum Trinken?", supportContent: "And to drink?"),
                LearningPhrase(mainContent: "Ein Wasser, bitte.", supportContent: "A water, please."),
                LearningPhrase(mainContent: "Die Speisekarte, bitte.", supportContent: "The menu, please."),
                LearningPhrase(mainContent: "Die Rechnung, bitte.", supportContent: "The bill, please."),
                LearningPhrase(mainContent: "Kann ich mit Karte zahlen?", supportContent: "Can I pay by card?"),
                LearningPhrase(mainContent: "Es hat gut geschmeckt!", supportContent: "It tasted good!")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "die Speisekarte", supportContent: "the menu", usage: "The list of food and drinks."),
                LearningVocabularyItem(mainContent: "das Schnitzel", supportContent: "the schnitzel", usage: "A breaded cutlet, a German classic."),
                LearningVocabularyItem(mainContent: "der Kellner", supportContent: "the waiter", usage: "The person who serves you."),
                LearningVocabularyItem(mainContent: "die Rechnung", supportContent: "the bill", usage: "The paper with the price to pay."),
                LearningVocabularyItem(mainContent: "bestellen", supportContent: "to order", usage: "Ich möchte ein Schnitzel bestellen.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Vicki", mainContent: "Guten Abend! Haben Sie schon gewählt?", supportContent: "Good evening! Have you chosen already?"),
                LearningConversationLine(speaker: "Daniel", mainContent: "Was empfehlen Sie?", supportContent: "What do you recommend?"),
                LearningConversationLine(speaker: "Vicki", mainContent: "Das Schnitzel ist sehr gut.", supportContent: "The schnitzel is very good."),
                LearningConversationLine(speaker: "Daniel", mainContent: "Ja, ich hätte gerne ein Schnitzel. Und zum Trinken ein Wasser, bitte.", supportContent: "Yes, I would like a schnitzel. And a water to drink, please."),
                LearningConversationLine(speaker: "Vicki", mainContent: "Sehr gerne. Kann ich etwas anderes bringen?", supportContent: "With pleasure. Can I bring anything else?"),
                LearningConversationLine(speaker: "Daniel", mainContent: "Nein, vielen Dank. Später bitte die Rechnung.", supportContent: "No, thank you very much. Later please the bill.")
            ],
            practicePrompt: "Practice ordering in a German restaurant. You are the waiter. Ask what I want to eat and drink, bring it, then take my payment. Keep it simple at A1 level."
        ),
        LearningLesson(
            id: "de-a1-directions",
            title: "Asking for Directions",
            description: "Find your way in a new city: ask where things are, understand straight on, left and right, and thank your helper.",
            languageCode: "de",
            level: "A1",
            topic: "Directions and places in town",
            intro: "When you are lost, a short question is enough: where is the station, the pharmacy, the bathroom? Learn to ask and to follow simple answers like straight on, left, right.",
            goals: [
                "Ask where common places are.",
                "Understand straight on, left and right.",
                "Confirm you understood and say thanks."
            ],
            phrases: [
                LearningPhrase(mainContent: "Entschuldigung, wo ist ... ?", supportContent: "Excuse me, where is ...?"),
                LearningPhrase(mainContent: "Wie komme ich zum Bahnhof?", supportContent: "How do I get to the train station?"),
                LearningPhrase(mainContent: "Geradeaus.", supportContent: "Straight on."),
                LearningPhrase(mainContent: "Links abbiegen.", supportContent: "Turn left."),
                LearningPhrase(mainContent: "Rechts abbiegen.", supportContent: "Turn right."),
                LearningPhrase(mainContent: "Ist es weit?", supportContent: "Is it far?"),
                LearningPhrase(mainContent: "Es ist nicht weit.", supportContent: "It is not far."),
                LearningPhrase(mainContent: "Verstehe ich das richtig?", supportContent: "Do I understand that correctly?"),
                LearningPhrase(mainContent: "Danke für Ihre Hilfe!", supportContent: "Thanks for your help!")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "der Bahnhof", supportContent: "the train station", usage: "Where you catch the train."),
                LearningVocabularyItem(mainContent: "die Apotheke", supportContent: "the pharmacy", usage: "Where you buy medicine."),
                LearningVocabularyItem(mainContent: "das Museum", supportContent: "the museum", usage: "A place to see art and history."),
                LearningVocabularyItem(mainContent: "geradeaus", supportContent: "straight on", usage: "Go straight ahead."),
                LearningVocabularyItem(mainContent: "die Straße", supportContent: "the street", usage: "The road you walk or drive on.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Daniel", mainContent: "Entschuldigung, wo ist der Bahnhof?", supportContent: "Excuse me, where is the train station?"),
                LearningConversationLine(speaker: "Vicki", mainContent: "Geradeaus, dann links abbiegen.", supportContent: "Straight on, then turn left."),
                LearningConversationLine(speaker: "Daniel", mainContent: "Geradeaus und dann links? Ist es weit?", supportContent: "Straight on and then left? Is it far?"),
                LearningConversationLine(speaker: "Vicki", mainContent: "Nein, es ist nicht weit. Fünf Minuten zu Fuß.", supportContent: "No, it is not far. Five minutes on foot."),
                LearningConversationLine(speaker: "Daniel", mainContent: "Verstehe ich das richtig? Danke für Ihre Hilfe!", supportContent: "Do I understand that correctly? Thanks for your help!")
            ],
            practicePrompt: "Practice asking for directions. You are a local person. I ask where places are, you give simple directions (straight on, left, right, far or not far). Keep it at A1 level."
        ),
        LearningLesson(
            id: "de-a1-telephone",
            title: "Phone Calls in German",
            description: "Call a restaurant or a doctor: say who you are, ask for a person, and make a simple appointment.",
            languageCode: "de",
            level: "A1",
            topic: "Telephone and appointments",
            intro: "Phone calls are short and structured in German: who are you, who do you want, what do you need? Learn the fixed phrases and you can call a restaurant or a doctor without stress.",
            goals: [
                "Say who is calling and ask for a person.",
                "Make a simple appointment by day and time.",
                "Repeat and confirm details on the phone."
            ],
            phrases: [
                LearningPhrase(mainContent: "Hallo, ich spreche mit ... ?", supportContent: "Hello, am I speaking with ...?"),
                LearningPhrase(mainContent: "Ja, hier ist ...", supportContent: "Yes, this is ..."),
                LearningPhrase(mainContent: "Kann ich mit ... sprechen?", supportContent: "Can I speak with ...?"),
                LearningPhrase(mainContent: "Ich möchte einen Termin machen.", supportContent: "I would like to make an appointment."),
                LearningPhrase(mainContent: "Wann passt es Ihnen?", supportContent: "When suits you?"),
                LearningPhrase(mainContent: "Morgen um drei Uhr?", supportContent: "Tomorrow at three o'clock?"),
                LearningPhrase(mainContent: "Ja, das passt.", supportContent: "Yes, that works."),
                LearningPhrase(mainContent: "Können Sie das bitte wiederholen?", supportContent: "Can you please repeat that?"),
                LearningPhrase(mainContent: "Auf Wiederhören!", supportContent: "Good bye (phone)!")
            ],
            vocabulary: [
                LearningVocabularyItem(mainContent: "der Termin", supportContent: "the appointment", usage: "A fixed time for a doctor or an office."),
                LearningVocabularyItem(mainContent: "die Nummer", supportContent: "the number", usage: "A phone number."),
                LearningVocabularyItem(mainContent: "rufen", supportContent: "to call (phone)", usage: "Ich rufe Sie an. = I will call you."),
                LearningVocabularyItem(mainContent: "am Telefon", supportContent: "on the phone", usage: "Where the conversation happens."),
                LearningVocabularyItem(mainContent: "der Doktor", supportContent: "the doctor", usage: "A medical doctor.")
            ],
            conversation: [
                LearningConversationLine(speaker: "Daniel", mainContent: "Hallo, ich möchte einen Termin beim Doktor machen.", supportContent: "Hello, I would like to make an appointment with the doctor."),
                LearningConversationLine(speaker: "Vicki", mainContent: "Wann passt es Ihnen?", supportContent: "When suits you?"),
                LearningConversationLine(speaker: "Daniel", mainContent: "Morgen um drei Uhr, geht das?", supportContent: "Tomorrow at three o'clock, does that work?"),
                LearningConversationLine(speaker: "Vicki", mainContent: "Ja, das passt. Wie heißt Sie bitte?", supportContent: "Yes, that works. What is your name, please?"),
                LearningConversationLine(speaker: "Daniel", mainContent: "Daniel Weber. Danke, auf Wiederhören!", supportContent: "Daniel Weber. Thanks, good bye!")
            ],
            practicePrompt: "Practice a phone call. You are the office of a doctor or a restaurant. I call to make an appointment. Ask my name, offer a day and time, and confirm it. Keep it simple at A1 level."
        )
    ]
}

// MARK: - Auth (Strapi /auth/local — same as web app's auth.service.ts)

