import Foundation

/// Buffles streamed deltas and emits complete sentences for TTS.
struct UtteranceSplitter {
    private var buffer = ""
    private let maxUtteranceLength = 200

    private let terminators: Set<Character> = [".", "!", "?"]
    private let closers: Set<Character> = ["\"", "'", ")", "”", "’"]

    mutating func feed(_ delta: String) -> [String] {
        buffer += delta
        var emitted: [String] = []
        while let index = nextBoundary() {
            let sentence = String(buffer[buffer.startIndex..<index])
            buffer.removeSubrange(buffer.startIndex..<index)
            let trimmed = sentence.trimmingCharacters(in: .whitespaces)
            if trimmed.contains(where: { $0.isLetter || $0.isNumber }) {
                emitted.append(trimmed)
            }
        }
        if buffer.count > maxUtteranceLength, let space = forceSplitIndex() {
            let sentence = String(buffer[buffer.startIndex...space])
            buffer.removeSubrange(buffer.startIndex...space)
            let trimmed = sentence.trimmingCharacters(in: .whitespaces)
            if trimmed.contains(where: { $0.isLetter || $0.isNumber }) {
                emitted.append(trimmed)
            }
        }
        return emitted
    }

    mutating func finish() -> String? {
        let trimmed = buffer.trimmingCharacters(in: .whitespaces)
        buffer = ""
        guard trimmed.contains(where: { $0.isLetter || $0.isNumber }) else {
            return nil
        }
        return trimmed
    }

    /// Index of the whitespace that follows a sentence ending (terminator + optional closers).
    private func nextBoundary() -> String.Index? {
        var i = buffer.startIndex
        while i < buffer.endIndex {
            let char = buffer[i]
            if terminators.contains(char) {
                var j = buffer.index(after: i)
                while j < buffer.endIndex, closers.contains(buffer[j]) {
                    j = buffer.index(after: j)
                }
                if j < buffer.endIndex, buffer[j].isWhitespace {
                    return j
                }
                // Terminator at the very end without trailing whitespace: not final yet
                // (the stream may continue), unless we hit the max length guard in feed().
            }
            i = buffer.index(after: i)
        }
        return nil
    }

    /// First whitespace at or before `maxUtteranceLength`, scanning backwards.
    private func forceSplitIndex() -> String.Index? {
        let target = buffer.index(buffer.startIndex, offsetBy: maxUtteranceLength, limitedBy: buffer.endIndex)
        var i = target ?? buffer.index(before: buffer.endIndex)
        if i == buffer.endIndex {
            i = buffer.index(before: i)
        }
        while i > buffer.startIndex {
            if buffer[i].isWhitespace {
                return i
            }
            i = buffer.index(before: i)
        }
        return buffer[buffer.startIndex].isWhitespace ? buffer.startIndex : nil
    }
}
