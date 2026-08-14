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

struct AuthUser: Codable, Hashable {
    let id: Int
    let username: String
    let email: String
}

struct AuthResponse: Codable {
    let jwt: String
    let user: AuthUser
}

struct UserProfileRole: Codable {
    let name: String?
}

// Mirrors the web app's getMe() -> /users/me/?populate=role,user_info,language,teaching,languages
struct UserProfile: Codable {
    let id: Int
    let username: String
    let email: String
    let nativeLanguage: String?
    let language: UserProfileLanguage?
    let languages: [UserProfileLanguage]?
    let role: UserProfileRole?
}

struct UserProfileLanguage: Codable, Hashable, Identifiable {
    let id: Int?
    let code: String?
    let level: String?
}

struct AuthService {
    static var backendURL: URL { AppEnvironment.cmsAPIBaseURL }

    func login(identifier: String, password: String) async throws -> AuthResponse {
        var request = URLRequest(url: Self.backendURL.appendingPathComponent("auth/local"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["identifier": identifier, "password": password]
        request.httpBody = try JSONEncoder().encode(payload)
        return try await send(request)
    }

    func register(username: String, email: String, password: String) async throws -> AuthResponse {
        var request = URLRequest(url: Self.backendURL.appendingPathComponent("auth/local/register"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["username": username, "email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(payload)
        return try await send(request)
    }

    func exchangeOAuthCallback(queryString: String) async throws -> AuthResponse {
        var request = URLRequest(url: Self.backendURL
            .appendingPathComponent("auth/google/callback?\(queryString)"))
        request.httpMethod = "GET"
        return try await send(request)
    }

    /// GET /users/me?populate=... — same as web app's getMe()
    func getMe(jwt: String) async throws -> UserProfile {
        let url = URL(string: "\(Self.backendURL.absoluteString)/users/me/?populate=role,user_info,language,teaching,languages")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw AuthError.badRequest(status: (response as? HTTPURLResponse)?.statusCode ?? -1,
                                       body: String(data: data, encoding: .utf8) ?? "")
        }
        return try JSONDecoder().decode(UserProfile.self, from: data)
    }

    private func send(_ request: URLRequest) async throws -> AuthResponse {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw AuthError.badRequest(status: (response as? HTTPURLResponse)?.statusCode ?? -1, body: body)
        }
        do {
            return try JSONDecoder().decode(AuthResponse.self, from: data)
        } catch {
            throw AuthError.decodingFailed(body: String(data: data, encoding: .utf8) ?? "")
        }
    }
}

enum AuthError: LocalizedError {
    case badRequest(status: Int, body: String)
    case decodingFailed(body: String)

    var errorDescription: String? {
        switch self {
        case .badRequest(let status, let body):
            // Strapi errors look like {"message":[{"messages":[{"message":"..."}]}]}
            return "Login failed (\(status))"
        case .decodingFailed(let body):
            return "Unexpected response from server"
        }
    }
}

// MARK: - Homework (Strapi /homeworks — student flow)

enum HomeworkStatus: String, Codable {
    case new = "NEW"
    case inProgress = "IN_PROGRESS"
    case done = "DONE"
    case finished = "FINISHED"
}

struct HomeworkMessage: Codable, Hashable {
    let role: String
    let content: String?
    let author: String?
}

struct HomeworkSituation: Codable {
    let name: String?
    let prompt: String?
}

struct HomeworkClassroom: Codable {
    let name: String?
    let language: String?
    let level: String?
}

struct HomeworkRelationData<T: Codable>: Codable {
    let id: Int?
    let attributes: T?
}

struct HomeworkRelation<T: Codable>: Codable {
    let data: HomeworkRelationData<T>?
}

struct HomeworkAttributes: Codable {
    let title: String?
    let status: String?
    let finishDate: String?
    let messages: [HomeworkMessage]?
    let situation: HomeworkRelation<HomeworkSituation>?
    let classroom: HomeworkRelation<HomeworkClassroom>?
}

struct HomeworkListItem: Codable, Identifiable {
    let id: Int
    let attributes: HomeworkAttributes
}

struct HomeworkListResponse: Codable {
    let data: [HomeworkListItem]?
}

struct HomeworkDetailResponse: Codable {
    let data: HomeworkListItem?
}

struct StrapiErrorResponse: Codable {
    let data: AnyCodable?
    let error: StrapiError?
}

struct StrapiError: Codable {
    let status: Int?
    let name: String?
    let message: String?
    let details: AnyCodable?
}

struct AnyCodable: Codable {
    let value: Any?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.value = nil
        } else if let v = try? container.decode(Bool.self) {
            self.value = v
        } else if let v = try? container.decode(Int.self) {
            self.value = v
        } else if let v = try? container.decode(Double.self) {
            self.value = v
        } else if let v = try? container.decode(String.self) {
            self.value = v
        } else if let v = try? container.decode([AnyCodable].self) {
            self.value = v
        } else if let v = try? container.decode([String: AnyCodable].self) {
            self.value = v
        } else {
            self.value = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case nil: try container.encodeNil()
        case let v as Bool: try container.encode(v)
        case let v as Int: try container.encode(v)
        case let v as Double: try container.encode(v)
        case let v as String: try container.encode(v)
        case let v as [AnyCodable]: try container.encode(v)
        case let v as [String: AnyCodable]: try container.encode(v)
        default: try container.encodeNil()
        }
    }
}

struct HomeworkViewModel: Identifiable, Hashable {
    let id: Int
    let title: String
    let status: HomeworkStatus
    let finishDate: String?
    let languageCode: String?
    let level: String?
    let situationName: String?
    let prompt: String?
    let messages: [HomeworkMessage]
    let classroomName: String?

    init(item: HomeworkListItem) {
        self.id = item.id
        let attr = item.attributes
        self.title = attr.title ?? attr.situation?.data?.attributes?.name ?? "Homework"
        self.status = HomeworkStatus(rawValue: attr.status ?? "NEW") ?? .new
        self.finishDate = attr.finishDate
        self.languageCode = attr.classroom?.data?.attributes?.language
        self.level = attr.classroom?.data?.attributes?.level
        self.situationName = attr.situation?.data?.attributes?.name
        self.prompt = attr.situation?.data?.attributes?.prompt
        self.messages = attr.messages ?? []
        self.classroomName = attr.classroom?.data?.attributes?.name
    }

    init(id: Int, title: String, status: HomeworkStatus, finishDate: String?,
         languageCode: String?, level: String?, situationName: String?,
         prompt: String?, messages: [HomeworkMessage], classroomName: String?) {
        self.id = id
        self.title = title
        self.status = status
        self.finishDate = finishDate
        self.languageCode = languageCode
        self.level = level
        self.situationName = situationName
        self.prompt = prompt
        self.messages = messages
        self.classroomName = classroomName
    }
}

struct HomeworkService {
    static var backendURL: URL { AuthService.backendURL }

    func getMyHomeworks(jwt: String) async throws -> [HomeworkViewModel] {
        let url = URL(string: "\(Self.backendURL.absoluteString)/homeworks?populate=*&user=me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw HomeworkError.requestFailed(status: (response as? HTTPURLResponse)?.statusCode ?? -1, detail: body)
        }
        return try parseHomeworkList(data)
    }

    func getHomework(id: Int, jwt: String) async throws -> HomeworkViewModel {
        let url = URL(string: "\(Self.backendURL.absoluteString)/homeworks/\(id)?populate=*")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw HomeworkError.requestFailed(status: (response as? HTTPURLResponse)?.statusCode ?? -1, detail: body)
        }
        return try parseHomeworkDetail(data)
    }

    func updateHomework(id: Int, jwt: String, status: HomeworkStatus, messages: [HomeworkMessage]? = nil) async throws {
        let url = URL(string: "\(Self.backendURL.absoluteString)/homeworks/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var payload: [String: Any] = ["status": status.rawValue]
        if let messages { payload["messages"] = messages.map { ["role": $0.role, "content": $0.content ?? "", "author": $0.author ?? ""] } }
        request.httpBody = try JSONSerialization.data(withJSONObject: ["data": payload])
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw HomeworkError.requestFailed(status: (response as? HTTPURLResponse)?.statusCode ?? -1, detail: body)
        }
    }

    // Manual JSON parsing: the custom CMS list endpoint returns a flat array,
    // while Strapi core endpoints return { data: ... } envelopes.
    private func parseHomeworkList(_ data: Data) throws -> [HomeworkViewModel] {
        let json = try JSONSerialization.jsonObject(with: data)
        if let dataArray = json as? [[String: Any]] {
            return dataArray.map { parseHomeworkItem($0) }
        }

        guard let jsonObject = json as? [String: Any] else {
            throw HomeworkError.decodingFailed(detail: String(data: data, encoding: .utf8) ?? "")
        }

        if let dataArray = jsonObject["data"] as? [[String: Any]] {
            return dataArray.map { parseHomeworkItem($0) }
        }
        if let single = jsonObject["data"] as? [String: Any] {
            return [parseHomeworkItem(single)]
        }
        if let error = jsonObject["error"] {
            throw HomeworkError.decodingFailed(detail: "CMS returned error: \(error)")
        }
        return []
    }

    private func parseHomeworkDetail(_ data: Data) throws -> HomeworkViewModel {
        let json = try JSONSerialization.jsonObject(with: data)
        if let item = json as? [String: Any], item["id"] != nil {
            return parseHomeworkItem(item)
        }
        guard let jsonObject = json as? [String: Any] else {
            throw HomeworkError.decodingFailed(detail: String(data: data, encoding: .utf8) ?? "")
        }
        guard let item = jsonObject["data"] as? [String: Any] else {
            throw HomeworkError.decodingFailed(detail: "No homework item in response: \(String(data: data, encoding: .utf8) ?? "")")
        }
        return parseHomeworkItem(item)
    }

    private func parseHomeworkItem(_ item: [String: Any]) -> HomeworkViewModel {
        let fields = flattenedFields(from: item)
        let id = intValue(item["id"]) ?? intValue(fields["id"]) ?? -1

        let title = fields["title"] as? String
        let statusStr = fields["status"] as? String ?? "NEW"
        let status = HomeworkStatus(rawValue: statusStr) ?? .new
        let finishDate = fields["finishDate"] as? String
        let messages = parseMessages(fields["messages"])

        let situation = relationFields(fields["situation"])
        let classroom = relationFields(fields["classroom"])

        let situationName = situation?["name"] as? String
        let prompt = situation?["prompt"] as? String
        let classroomName = classroom?["name"] as? String
        let languageCode = classroom?["language"] as? String
        let level = classroom?["level"] as? String

        return HomeworkViewModel(
            id: id, title: title ?? situationName ?? "Homework", status: status,
            finishDate: finishDate, languageCode: languageCode, level: level,
            situationName: situationName, prompt: prompt, messages: messages,
            classroomName: classroomName
        )
    }

    private func flattenedFields(from item: [String: Any]) -> [String: Any] {
        var fields = item
        if let attributes = item["attributes"] as? [String: Any] {
            for (key, value) in attributes {
                fields[key] = value
            }
        }
        return fields
    }

    private func relationFields(_ relation: Any?) -> [String: Any]? {
        if let relation = relation as? [String: Any] {
            if let data = relation["data"] as? [String: Any] {
                return flattenedFields(from: data)
            }
            return flattenedFields(from: relation)
        }
        return nil
    }

    private func parseMessages(_ value: Any?) -> [HomeworkMessage] {
        guard let messageObjects = value as? [[String: Any]] else { return [] }
        return messageObjects.map { message in
            HomeworkMessage(
                role: message["role"] as? String ?? "user",
                content: message["content"] as? String,
                author: message["author"] as? String
            )
        }
    }

    private func intValue(_ value: Any?) -> Int? {
        if let int = value as? Int { return int }
        if let number = value as? NSNumber { return number.intValue }
        if let string = value as? String { return Int(string) }
        return nil
    }
}

enum HomeworkError: LocalizedError {
    case requestFailed(status: Int, detail: String)
    case decodingFailed(detail: String)

    var errorDescription: String? {
        switch self {
        case .requestFailed(let status, let detail):
            if detail.isEmpty {
                return "Homework request failed (\(status))"
            }
            return "Homework request failed (\(status)): \(detail)"
        case .decodingFailed(let detail):
            return "Data format error: \(detail)"
        }
    }
}
