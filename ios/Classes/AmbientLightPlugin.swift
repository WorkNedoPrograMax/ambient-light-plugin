import Flutter
import UIKit

public class AmbientLightPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var result: FlutterResult?
    private var eventSink: FlutterEventSink?
    private var isListeningForResult = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "ambient_light.aliyou.dev", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "ambient_light_stream.aliyou.dev", binaryMessenger: registrar.messenger())

        let instance = AmbientLightPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getAmbientLight":
            if isListeningForResult {
                result(FlutterError(code: "IN_PROGRESS", message: "Another ambient light request is in progress", details: nil))
            } else {
                self.result = result
                startListeningForResult()
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startListeningForResult() {
        addObservers()
    }

    private func startListening() {
        addObservers()
    }

    private func stopListening() {
        removeObservers()
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        startListening()
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopListening()
        self.eventSink = nil
        return nil
    }

    deinit {
        removeObservers()
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onScreenBrightnessChanged(_:)), name: UIScreen.brightnessDidChangeNotification, object: nil)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func onScreenBrightnessChanged(_ sender: Notification) {
        let brightnessValue = UIScreen.main.brightness

        DispatchQueue.main.async {
            if let result = self.result {
                result(brightnessValue)
                self.result = nil
                self.isListeningForResult = false
                self.stopListening()
            } else if let eventSink = self.eventSink {
                eventSink(brightnessValue)
            }
        }
    }
}