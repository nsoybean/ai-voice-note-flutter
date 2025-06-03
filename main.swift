import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    var recorder: AVAudioRecorder?
    var outputURL: URL

    init(outputPath: String) {
        self.outputURL = URL(fileURLWithPath: outputPath)
        super.init()
    }

    func startRecording() {

        let settings: [String: Any] = [
            
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]

        do {
            recorder = try AVAudioRecorder(url: outputURL, settings: settings)
            recorder?.delegate = self
            recorder?.prepareToRecord()
            recorder?.record()
            print("🎙️ Recording started at \(outputURL.path)")
        } catch {
            print("❌ Failed to start recording: \(error.localizedDescription)")
            exit(1)
        }
    }

    func stopRecording() {
        recorder?.stop()
        print("✅ Recording stopped. File saved to \(outputURL.path)")
    }
}

// Entry point
let args = CommandLine.arguments

guard args.count >= 3 else {
    print("Usage: AudioRecorderHelper start --output /path/to/file.wav")
    exit(1)
}

let command = args[1]
let outputFlagIndex = args.firstIndex(of: "--output")

guard let outputIndex = outputFlagIndex, outputIndex + 1 < args.count else {
    print("Error: Missing --output argument")
    exit(1)
}

let outputPath = args[outputIndex + 1]
let recorder = AudioRecorder(outputPath: outputPath)

switch command {
case "start":
    recorder.startRecording()

    signal(SIGINT) { _ in
        recorder.stopRecording()
        exit(0)
    }

    // Keep alive until manually stopped (e.g., via Ctrl+C)
    RunLoop.current.run()

default:
    print("Unknown command: \(command)")
    exit(1)
}
