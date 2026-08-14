import Foundation

struct TranscriptTracker {
    static let wordSimilarityThreshold: Double = 0.7

    private var sentNormalized: String = ""

    mutating func nextDelta(from fullTranscript: String) -> String? {
        let normalized = Self.normalize(fullTranscript)
        guard !normalized.isEmpty else { return nil }

        defer { sentNormalized = normalized }

        guard !sentNormalized.isEmpty else { return Self.trimmed(fullTranscript) }
        guard normalized != sentNormalized else { return nil }

        let words = normalized.split(separator: " ").map(String.init)
        let sentWords = sentNormalized.split(separator: " ").map(String.init)

        if Self.isWordBoundaryContinuation(normalized, after: sentNormalized) {
            let consumed = Self.nonWhitespaceCount(of: sentNormalized)
            return Self.rawSuffix(afterNonWhitespaceCount: consumed, in: fullTranscript)
        }

        let overlap = min(words.count, sentWords.count)
        let matchesSentPrefix = (0..<overlap).allSatisfy { Self.isSimilar(words[$0], to: sentWords[$0]) }
        guard matchesSentPrefix else { return Self.trimmed(fullTranscript) }
        guard words.count > sentWords.count else { return nil }

        let consumed = Self.nonWhitespaceCount(of: words[0..<sentWords.count].joined(separator: " "))
        return Self.rawSuffix(afterNonWhitespaceCount: consumed, in: fullTranscript)
    }

    mutating func reset() {
        sentNormalized = ""
    }

    static func normalize(_ text: String) -> String {
        let lowered = text.lowercased()
        return lowered.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    static func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func isSimilar(_ a: String, to b: String, threshold: Double = wordSimilarityThreshold) -> Bool {
        let maxLength = max(a.count, b.count)
        guard maxLength > 0 else { return true }
        let distance = levenshtein(a, b)
        return 1.0 - Double(distance) / Double(maxLength) >= threshold
    }

    private static func isWordBoundaryContinuation(_ normalized: String, after prefix: String) -> Bool {
        guard normalized.hasPrefix(prefix) else { return false }
        return normalized.dropFirst(prefix.count).first == " "
    }

    private static func nonWhitespaceCount(of text: String) -> Int {
        text.split(whereSeparator: { $0.isWhitespace }).reduce(0) { $0 + $1.count }
    }

    private static func rawSuffix(afterNonWhitespaceCount count: Int, in raw: String) -> String? {
        var seen = 0
        var index = raw.startIndex
        while index < raw.endIndex {
            let char = raw[index]
            index = raw.index(after: index)
            if char.isWhitespace { continue }
            seen += 1
            if seen == count {
                let suffix = String(raw[index...]).trimmingCharacters(in: .whitespacesAndNewlines)
                return suffix.isEmpty ? nil : suffix
            }
        }
        return nil
    }

    private static func levenshtein(_ a: String, _ b: String) -> Int {
        let aChars = Array(a)
        let bChars = Array(b)
        guard !aChars.isEmpty else { return bChars.count }
        guard !bChars.isEmpty else { return aChars.count }
        var previous = Array(0...bChars.count)
        var current = [Int](repeating: 0, count: bChars.count + 1)

        for i in 1...aChars.count {
            current[0] = i
            for j in 1...bChars.count {
                let substitutionCost = aChars[i - 1] == bChars[j - 1] ? 0 : 1
                current[j] = min(
                    previous[j] + 1,
                    current[j - 1] + 1,
                    previous[j - 1] + substitutionCost
                )
            }
            swap(&previous, &current)
        }
        return previous[bChars.count]
    }
}
