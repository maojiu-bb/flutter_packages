//
//  NativeAlert.swift
//  flutter_native_ui_kit
//
//  Created by 钟钰 on 2026/1/30.
//

import Foundation
import Flutter
import UIKit

class NativeAlertView: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let nativeAlertChannel = FlutterMethodChannel(name: ChannelName.of(MethodName.NATIVE_ALERT), binaryMessenger: registrar.messenger())
        let instance = NativeAlertView()
        registrar.addMethodCallDelegate(instance, channel: nativeAlertChannel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case MethodName.NATIVE_ALERT:
            
            guard let args = call.arguments as? [String: Any],
                  let title = args["title"] as? String else {
                result(FlutterError(code: "ARGUEMENTS_ERROR", message: "title is require", details: nil))
                return
            }
            let message = args["message"] as? String
            let cancelText = args["cancelText"] as? String
            let confirmText = args["confirmText"] as? String
            let isDestructive = args["isDestructive"] as? Bool ?? false
            
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            if let cancelText = cancelText {
                let cancelAction = UIAlertAction(
                    title: cancelText ?? "Cancel",
                    style: .cancel
                ) { _ in
                    result(false)
                }
                alert.addAction(cancelAction)
            }
            if let confirmText = confirmText {
                let confirmAction = UIAlertAction(
                    title: confirmText ?? "Confirm",
                    style: isDestructive ? .destructive : .default
                ) { _ in
                    result(true)
                }
                alert.addAction(confirmAction)
            }
            
            if let topVC = UIApplication.shared.topViewController() {
                topVC.present(alert, animated: true)
            } else {
                result(FlutterError(code: "VIEW_CONTROLLER_ERROR", message: "top view controller is not found", details: nil))
            }
            
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
}
