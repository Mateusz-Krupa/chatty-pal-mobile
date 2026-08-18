import AVFoundation
import Speech

final class SpeechController {
    private let localeIdentifier: String
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognizer: SFSpeechRecognizer?
    private var capturedPCM = Data()
    private var capturedSampleRate: Double = 44100

    var onTranscription: ((String, Bool) -> Void)?
    var onError: ((Error) -> Void)?
    var onAudioLevel: ((Float) -> Void)?

    init(localeIdentifier: String) {
        self.localeIdentifier = localeIdentifier
        self.recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
    }

    static func rms(of buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0 }
        let frames = Int(buffer.frameLength)
        guard frames > 0 else { return 0 }
        let samples = channelData[0]
        var sum: Float = 0
        for i in 0..<frames {
            let sample = samples[i]
            sum += sample * sample
        }
        return sqrt(sum / Float(frames))
    }

    func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        }
    }

    func startRecording() throws {
        if audioEngine.isRunning {
            return
        }

        recognitionTask?.cancel()
        recognitionTask = nil

        let session = AVAudioSession.sharedInstance()
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
        try session.setCategory(.record, mode: .measurement, options: [.duckOthers, .allowBluetooth])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        let inputFormat = inputNode.outputFormat(forBus: 0)
        capturedPCM = Data()
        capturedSampleRate = inputFormat.sampleRate > 0 ? inputFormat.sampleRate : 44100
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            self?.appendMono(buffer)
            self?.onAudioLevel?(Self.rms(of: buffer))
        }

        audioEngine.prepare()
        try audioEngine.start()

        guard let request = recognitionRequest else {
            throw SpeechControllerError.missingRequest
        }

        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            if let result {
                self?.onTranscription?(result.bestTranscription.formattedString, result.isFinal)
            }
            if let error {
                self?.onError?(error)
            }
        }
    }

    func stopRecording() -> Data? {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        onAudioLevel = nil
        let wav = makeUploadWAV()
        capturedPCM = Data()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        return wav
    }

    private func makeUploadWAV() -> Data? {
        guard capturedPCM.count > 0 else { return nil }
        let samples = capturedPCM.withUnsafeBytes { ptr in
            Array(ptr.bindMemory(to: Float32.self))
        }
        guard capturedSampleRate > WAVFile.targetSampleRate else {
            return WAVFile.make(fromFloatSamples: capturedPCM, sampleRate: capturedSampleRate)
        }
        let resampled = WAVFile.resample(samples, from: capturedSampleRate, to: WAVFile.targetSampleRate)
        let resampledData = resampled.withUnsafeBytes { Data($0) }
        return WAVFile.make(fromFloatSamples: resampledData, sampleRate: WAVFile.targetSampleRate)
    }

    private func appendMono(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        let frames = Int(buffer.frameLength)
        guard frames > 0 else { return }
        let channels = max(1, Int(buffer.format.channelCount))
        var mono = [Float](repeating: 0, count: frames)
        for channel in 0..<channels {
            for frame in 0..<frames {
                mono[frame] += channelData[channel][frame]
            }
        }
        if channels > 1 {
            let divisor = Float(channels)
            for frame in 0..<frames {
                mono[frame] /= divisor
            }
        }
        withUnsafeBytes(of: mono) { capturedPCM.append(contentsOf: $0) }
    }
}

enum SpeechControllerError: Error {
    case missingRequest
}
