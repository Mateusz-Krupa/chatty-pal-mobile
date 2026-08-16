import Foundation

struct ChatMessage: Identifiable, Codable {
    enum Role: String, Codable {
        case system
        case user
        case assistant
        case teacher
        case translation
        case suggestion
    }

    let id: UUID
    let role: Role
    let message: String

    init(id: UUID = UUID(), role: Role, message: String) {
        self.id = id
        self.role = role
        self.message = message
    }
}

// MARK: - Language / level selection (mirrors src/configs/language.config.ts)

struct Language: Identifiable, Hashable {
    let code: String
    let voice: String
    let voiceGender: String        // "woman" / "man" (raw, like the web config)
    let country: String
    let language: String           // display name, e.g. "German"
    let speechLocale: String       // for SFSpeechRecognizer, e.g. "de-DE"

    var id: String { code }

    // nicer wording for the persona prompt
    var genderWord: String { voiceGender == "man" ? "male" : "female" }
}

enum LanguageConfig {
    static let all: [String: Language] = [
        "de": Language(code: "de", voice: "Vicki",  voiceGender: "woman", country: "Germany",        language: "German",           speechLocale: "de-DE"),
        "en": Language(code: "en", voice: "Amy",    voiceGender: "woman", country: "United States",  language: "English (British)", speechLocale: "en-GB"),
        "ja": Language(code: "ja", voice: "Kazuha", voiceGender: "woman", country: "Japan",          language: "Japanese",         speechLocale: "ja-JP"),
        "it": Language(code: "it", voice: "Bianca", voiceGender: "woman", country: "Italy",          language: "Italian",          speechLocale: "it-IT"),
        "es": Language(code: "es", voice: "Lucia",  voiceGender: "woman", country: "Spain",          language: "Spanish",          speechLocale: "es-ES"),
        "ko": Language(code: "ko", voice: "Seoyeon",voiceGender: "woman", country: "South Korea",    language: "Korean",           speechLocale: "ko-KR"),
        "pl": Language(code: "pl", voice: "Ola",    voiceGender: "woman", country: "Poland",         language: "Polish",           speechLocale: "pl-PL"),
        "fr": Language(code: "fr", voice: "Remi",   voiceGender: "man",   country: "France",         language: "French",           speechLocale: "fr-FR"),
    ]

    static let sorted: [Language] = all.values.sorted { $0.language < $1.language }
    static let levels = ["A1", "A2", "B1", "B2", "C1", "C2"]
    static let `default` = all["de"]!
}

// MARK: - Mobile Learning Materials

