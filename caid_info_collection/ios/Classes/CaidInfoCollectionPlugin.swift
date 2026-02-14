import Flutter
import UIKit

public class CaidInfoCollectionPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "caid_info_collection", binaryMessenger: registrar.messenger())
        let instance = CaidInfoCollectionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)

        case "getCAIDEncryptedInfo":
            guard let args = call.arguments as? [String: Any],
                  let publicKeyBase64 = args["publicKeyBase64"] as? String
            else {
                result(FlutterError(code: "ARGUEMENTS_ERROR", message: "Arguements Error", details: nil))
                return
            }

            result(CaidInfoCollection.shared.getEncryptedDeviceInfo(publicKeyBase64))

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
