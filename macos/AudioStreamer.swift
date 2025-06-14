import Foundation
import AVFoundation

class AudioStreamer: NSObject {
    private let engine = AVAudioEngine()
    var onAudioData: ((Data) -> Void)?

    func startStreaming() {
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, time) in
            let audioBuffer = buffer.audioBufferList.pointee.mBuffers
            let data = Data(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
            self.onAudioData?(data) // This will send raw PCM data
        }

        try? engine.start()
    }

    func stopStreaming() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
    }
}
