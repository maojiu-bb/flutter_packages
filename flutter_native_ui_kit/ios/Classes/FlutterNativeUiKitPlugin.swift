import Flutter
import UIKit

public class FlutterNativeUiKitPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_native_ui_kit", binaryMessenger: registrar.messenger())
        let instance = FlutterNativeUiKitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        NativeAlertView.register(with: registrar)
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
