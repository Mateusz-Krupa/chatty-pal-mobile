import Foundation

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
