import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    let audioStreamer = AudioStreamer()
    var eventSink: FlutterEventSink?

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    override func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "audio_streamer", binaryMessenger: controller.engine.binaryMessenger)

        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "start":
                self?.audioStreamer.onAudioData = { (data: Data) in
                    self?.eventSink?(FlutterStandardTypedData(bytes: data))
                }

                self?.audioStreamer.startStreaming()
                result("started")
            case "stop":
                self?.audioStreamer.stopStreaming()
                result("stopped")
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // 📡 Event channel for audio data
        let eventChannel = FlutterEventChannel(name: "audio_streamer_events", binaryMessenger: controller.engine.binaryMessenger)
        eventChannel.setStreamHandler(self)

        super.applicationDidFinishLaunching(notification)
    }
}


// 📡 Add this extension for stream handler
extension AppDelegate: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
