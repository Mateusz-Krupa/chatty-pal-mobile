import Foundation

struct BargeInDetector {
    var threshold: Float = 0.02
    var settle: TimeInterval = 0.5
    var sustain: TimeInterval = 0.4
    var cooldown: TimeInterval = 1.0
    var now: () -> Date = { Date() }

    private var voiceSince: Date?
    private var lastFired: Date?
    private var armedAt: Date?
    private(set) var isArmed = false

    mutating func arm() {
        let t = now()
        isArmed = true
        armedAt = t
        voiceSince = nil
        lastFired = nil
    }

    mutating func disarm() {
        isArmed = false
        armedAt = nil
        voiceSince = nil
        lastFired = nil
    }

    @discardableResult
    mutating func feed(_ rms: Float) -> Bool {
        let t = now()
        guard isArmed, let armedAt else { return false }
        guard t.timeIntervalSince(armedAt) >= settle else { return false }
        if let lastFired, t.timeIntervalSince(lastFired) < cooldown {
            voiceSince = nil
            return false
        }
        if rms > threshold {
            if voiceSince == nil {
                voiceSince = t
            }
            if t.timeIntervalSince(voiceSince!) >= sustain {
                voiceSince = nil
                lastFired = t
                return true
            }
        } else {
            voiceSince = nil
        }
        return false
    }
}
