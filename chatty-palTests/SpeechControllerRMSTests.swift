import AVFoundation
import XCTest
@testable import chatty_pal

final class SpeechControllerRMSTests: XCTestCase {
    private func makeBuffer(samples: [Float]) -> AVAudioPCMBuffer {
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                   sampleRate: 44100,
                                   channels: 1,
                                   interleaved: false)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format,
                                      frameCapacity: AVAudioFrameCount(samples.count))!
        buffer.frameLength = AVAudioFrameCount(samples.count)
        samples.withUnsafeBufferPointer { pointer in
            buffer.floatChannelData![0].update(from: pointer.baseAddress!, count: samples.count)
        }
        return buffer
    }

    func testRmsOfConstantAmplitude() {
        let buffer = makeBuffer(samples: Array(repeating: 0.1, count: 100))
        XCTAssertEqual(SpeechController.rms(of: buffer), 0.1, accuracy: 0.0001)
    }

    func testRmsOfAlternatingAmplitude() {
        let samples = (0..<100).map { $0.isMultiple(of: 2) ? Float(0.1) : Float(-0.1) }
        let buffer = makeBuffer(samples: samples)
        XCTAssertEqual(SpeechController.rms(of: buffer), 0.1, accuracy: 0.0001)
    }

    func testRmsOfSilence() {
        let buffer = makeBuffer(samples: Array(repeating: 0, count: 100))
        XCTAssertEqual(SpeechController.rms(of: buffer), 0)
    }

    func testRmsOfEmptyBuffer() {
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                   sampleRate: 44100,
                                   channels: 1,
                                   interleaved: false)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 0)!
        buffer.frameLength = 0
        XCTAssertEqual(SpeechController.rms(of: buffer), 0)
    }
}
