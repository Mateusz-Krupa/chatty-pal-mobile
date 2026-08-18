import AVFoundation

protocol VoiceMonitoring: AnyObject {
    var onLevel: ((Float) -> Void)? { get set }
    func start() throws
    func stop()
}

final class VoiceMonitor: NSObject, VoiceMonitoring {
    private let engine = AVAudioEngine()
    private(set) var isRunning = false
    var onLevel: ((Float) -> Void)?

    func start() throws {
        guard !isRunning else { return }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            let rms = SpeechController.rms(of: buffer)
            DispatchQueue.main.async { [weak self] in
                self?.onLevel?(rms)
            }
        }

        engine.prepare()
        try engine.start()
        isRunning = true
    }

    func stop() {
        guard isRunning else { return }
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        isRunning = false
        // Release the mic capture; the app rests in a plain playback session.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
    }
}
