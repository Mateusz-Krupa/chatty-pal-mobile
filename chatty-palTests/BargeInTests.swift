import XCTest
@testable import chatty_pal

private final class Clock {
    var date: Date
    init(date: Date) { self.date = date }
    func advance(by interval: TimeInterval) {
        date = date.addingTimeInterval(interval)
    }
}

final class BargeInTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_000_000)

    private func makeDetector(settle: TimeInterval, sustain: TimeInterval, cooldown: TimeInterval) -> (BargeInDetector, Clock) {
        let clock = Clock(date: start)
        var detector = BargeInDetector()
        detector.settle = settle
        detector.sustain = sustain
        detector.cooldown = cooldown
        detector.now = { clock.date }
        return (detector, clock)
    }

    func testSustainedVoiceFires() {
        var (d, clock) = makeDetector(settle: 0.5, sustain: 0.4, cooldown: 1)
        d.arm()
        clock.advance(by: 0.5)
        XCTAssertFalse(d.feed(0.1))   // opens the sustain window
        clock.advance(by: 0.3)
        XCTAssertFalse(d.feed(0.1))   // 0.3 < 0.4
        clock.advance(by: 0.11)
        XCTAssertTrue(d.feed(0.1))    // 0.41 >= 0.4
    }

    func testBlipBelowSustainDoesNotFire() {
        var (d, clock) = makeDetector(settle: 0, sustain: 0.4, cooldown: 1)
        d.arm()
        clock.advance(by: 0.1)
        XCTAssertFalse(d.feed(0.1))    // voice starts
        clock.advance(by: 0.1)
        XCTAssertFalse(d.feed(0.1))    // 0.2s, still < 0.4
        clock.advance(by: 0.1)
        XCTAssertFalse(d.feed(0.001))  // silence resets the sustain window
        clock.advance(by: 0.2)
        XCTAssertFalse(d.feed(0.1))    // fresh burst, 0.0s so far
        clock.advance(by: 0.1)
        XCTAssertFalse(d.feed(0.1))    // 0.3s, still < 0.4
    }

    func testBelowThresholdNeverFires() {
        var (d, clock) = makeDetector(settle: 0, sustain: 0.1, cooldown: 1)
        d.arm()
        clock.advance(by: 1.0)
        XCTAssertFalse(d.feed(0.001))
        clock.advance(by: 1.0)
        XCTAssertFalse(d.feed(0.001))
    }

    func testSettleSuppressesEarlyTrigger() {
        var (d, clock) = makeDetector(settle: 0.5, sustain: 0.1, cooldown: 1)
        d.arm()
        clock.advance(by: 0.3)
        XCTAssertFalse(d.feed(0.1))    // inside settle window, ignored
        clock.advance(by: 0.2)
        XCTAssertFalse(d.feed(0.1))    // settle elapsed, sustain window opens
        clock.advance(by: 0.11)
        XCTAssertTrue(d.feed(0.1))     // sustained long enough
    }

    func testCooldownSuppressesSecondTrigger() {
        var (d, clock) = makeDetector(settle: 0, sustain: 0, cooldown: 1.0)
        d.arm()
        clock.advance(by: 0.1)
        XCTAssertTrue(d.feed(0.1))     // fires
        clock.advance(by: 0.4)
        XCTAssertFalse(d.feed(0.1))    // within 1.0s cooldown
        clock.advance(by: 0.7)
        XCTAssertTrue(d.feed(0.1))     // past cooldown fires again
    }

    func testDisarmedNeverFires() {
        var (d, clock) = makeDetector(settle: 0, sustain: 0.1, cooldown: 1)
        d.arm()
        d.disarm()
        clock.advance(by: 1.0)
        XCTAssertFalse(d.feed(0.1))
    }
}
