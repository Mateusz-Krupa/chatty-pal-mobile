import Foundation

enum ShadowingScorer {
    struct WordMatch: Hashable {
        let word: String
        let matched: Bool
    }

    struct Result: Hashable {
        let percent: Int
        let words: [WordMatch]
    }

    static func score(reference: String, spoken: String) -> Result {
        let refWords = cleanWords(reference)
        let spokenWords = cleanWords(spoken)
        guard !refWords.isEmpty else {
            return Result(percent: 0, words: [])
        }

        var matches: [WordMatch] = []
        var spokenIndex = 0
        var matchedCount = 0

        for refWord in refWords {
            var found = false
            var j = spokenIndex
            while j < spokenWords.count {
                if TranscriptTracker.isSimilar(spokenWords[j], to: refWord) {
                    found = true
                    spokenIndex = j + 1
                    break
                }
                j += 1
            }
            if found {
                matchedCount += 1
            }
            matches.append(WordMatch(word: refWord, matched: found))
        }

        let percent = Int((Double(matchedCount) / Double(refWords.count) * 100).rounded())
        return Result(percent: percent, words: matches)
    }

    static func cleanWords(_ text: String) -> [String] {
        let lowered = text.lowercased()
        return lowered.split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "'" }).map(String.init)
    }
}
