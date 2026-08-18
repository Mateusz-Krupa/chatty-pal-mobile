import XCTest
@testable import chatty_pal

final class WAVFileTests: XCTestCase {
    private func floatData(_ values: [Float]) -> Data {
        values.withUnsafeBytes { Data($0) }
    }

    private func le16(_ data: Data, _ offset: Int) -> Int {
        Int(data[offset]) | (Int(data[offset + 1]) << 8)
    }

    private func le32(_ data: Data, _ offset: Int) -> Int {
        Int(data[offset]) | (Int(data[offset + 1]) << 8) | (Int(data[offset + 2]) << 16) | (Int(data[offset + 3]) << 24)
    }

    func testBuildsCanonicalWAVHeader() {
        let wav = WAVFile.make(fromFloatSamples: floatData([0, 0, 0, 0]), sampleRate: 44100)
        let data = try! XCTUnwrap(wav)
        XCTAssertEqual(data.count, 44 + 8)

        XCTAssertEqual(String(data: data.prefix(4), encoding: .ascii), "RIFF")
        let riffSize = le32(data, 4)
        XCTAssertEqual(riffSize, 36 + 8)
        XCTAssertEqual(String(data: data[8..<12], encoding: .ascii), "WAVE")
        XCTAssertEqual(String(data: data[12..<16], encoding: .ascii), "fmt ")
        let fmtChunkSize = le32(data, 16)
        XCTAssertEqual(fmtChunkSize, 16)
        let audioFormat = le16(data, 20)
        XCTAssertEqual(audioFormat, 1)
        let channels = le16(data, 22)
        XCTAssertEqual(channels, 1)
        let sampleRate = le32(data, 24)
        XCTAssertEqual(sampleRate, 44100)
        let blockAlign = le16(data, 32)
        XCTAssertEqual(blockAlign, 2)
        let bitsPerSample = le16(data, 34)
        XCTAssertEqual(bitsPerSample, 16)
        XCTAssertEqual(String(data: data[36..<40], encoding: .ascii), "data")
        let dataSize = le32(data, 40)
        XCTAssertEqual(dataSize, 8)
    }

    func testEncodesExtremesAsInt16() {
        let wav = WAVFile.make(fromFloatSamples: floatData([1.0, -1.0, 0.0, 5.0, -5.0]), sampleRate: 8000)
        let data = try! XCTUnwrap(wav)
        let payload = Array(data[44...])
        // 1.0 -> 0x7FFF, -1.0 -> 0x8000, 0.0 -> 0x0000, clamped like the extremes
        XCTAssertEqual(payload[0], 0xFF)
        XCTAssertEqual(payload[1], 0x7F)
        XCTAssertEqual(payload[2], 0x00)
        XCTAssertEqual(payload[3], 0x80)
        XCTAssertEqual(payload[4], 0x00)
        XCTAssertEqual(payload[5], 0x00)
        XCTAssertEqual(payload[6], 0xFF)
        XCTAssertEqual(payload[7], 0x7F)
        XCTAssertEqual(payload[8], 0x00)
        XCTAssertEqual(payload[9], 0x80)
    }

    func testEmptyInputReturnsNil() {
        XCTAssertNil(WAVFile.make(fromFloatSamples: Data(), sampleRate: 44100))
    }

    func testResampleDownsampleLength() {
        // 88200 samples @ 44.1 kHz = 2 seconds of audio → 32000 samples @ 16 kHz
        let src = (0..<88200).map { Float($0 % 100) / 100 }
        let out = WAVFile.resample(src, from: 44100, to: 16000)
        XCTAssertEqual(out.count, 32000)
    }

    func testResamplePreservesConstantSignal() {
        let src = [Float](repeating: 0.25, count: 4410)
        let out = WAVFile.resample(src, from: 44100, to: 16000)
        // 4410 samples @ 44.1 kHz = 0.1 s → 1600 samples @ 16 kHz
        XCTAssertEqual(out.count, 1600)
        for sample in out {
            XCTAssertEqual(sample, 0.25, accuracy: 0.0001)
        }
    }

    func testResampleFollowsRamp() {
        let src = (0..<100).map { Float($0) }
        let out = WAVFile.resample(src, from: 100, to: 50)
        XCTAssertEqual(out.count, 50)
        XCTAssertEqual(out[0], 0, accuracy: 0.001)
        XCTAssertEqual(out[49], 98, accuracy: 0.001)
        XCTAssertEqual(out[25], 50, accuracy: 0.01)
    }

    func testResampleIdentityAtEqualRates() {
        let src: [Float] = [0.1, 0.2, 0.3, 0.4]
        XCTAssertEqual(WAVFile.resample(src, from: 16000, to: 16000), src)
    }

    func testResampleTrivialInputUnchanged() {
        let empty: [Float] = []
        XCTAssertEqual(WAVFile.resample(empty, from: 44100, to: 16000), empty)
        let single: [Float] = [0.5]
        XCTAssertEqual(WAVFile.resample(single, from: 44100, to: 16000), single)
    }
}
