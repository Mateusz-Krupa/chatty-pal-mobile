import Foundation

enum WAVFile {
    /// Builds a 16-bit mono PCM WAV from little-endian float32 samples in [-1, 1].
    static func make(fromFloatSamples data: Data, sampleRate: Double) -> Data? {
        let sampleCount = data.count / 4
        guard sampleCount > 0 else { return nil }

        var pcm = Data(capacity: sampleCount * 2)
        data.withUnsafeBytes { raw in
            let floats = raw.bindMemory(to: Float32.self)
            for i in 0..<sampleCount {
                let clamped = max(-1.0, min(1.0, Double(floats[i])))
                let value = Int16(clamped >= 0 ? clamped * 32767.0 : clamped * 32768.0)
                var little = UInt16(bitPattern: value).littleEndian
                pcm.append(Data(bytes: &little, count: 2))
            }
        }

        let dataBytes = UInt32(pcm.count)
        var header = Data()
        header.appendASCII("RIFF")
        header.appendLE(36 + dataBytes)
        header.appendASCII("WAVE")
        header.appendASCII("fmt ")
        header.appendLE(UInt32(16))
        header.appendLE(UInt16(1))
        header.appendLE(UInt16(1))
        header.appendLE(UInt32(sampleRate))
        header.appendLE(UInt32(sampleRate) * 2)
        header.appendLE(UInt16(2))
        header.appendLE(UInt16(16))
        header.appendASCII("data")
        header.appendLE(dataBytes)
        return header + pcm
    }
}

private extension Data {
    mutating func appendASCII(_ string: String) {
        append(contentsOf: Array(string.utf8))
    }

    mutating func appendLE<T: FixedWidthInteger>(_ value: T) {
        var little = value.littleEndian
        append(Data(bytes: &little, count: MemoryLayout<T>.size))
    }
}
