//
//  NativeAlert.swift
//  flutter_native_ui_kit
//
//  Created by 钟钰 on 2026/1/31.
//

import Foundation
import Flutter
import UIKit

struct ActionSheetCell {
    
    let label: String
    let key: String
    let isDestructive: Bool
    
    init(label: String, key: String, isDestructive: Bool) {
        self.label = label
        self.key = key
        self.isDestructive = isDestructive
    }
}

class NativeActionSheetView: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let nativeActionSheetChannel = FlutterMethodChannel(name: ChannelName.of(MethodName.NATIVE_ACTION_SHEET), binaryMessenger: registrar.messenger())
        let instance = NativeActionSheetView()
        registrar.addMethodCallDelegate(instance, channel: nativeActionSheetChannel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case MethodName.NATIVE_ACTION_SHEET:
            
            guard let args = call.arguments as? [String: Any],
                  let title = args["title"] as? String,
                  let cells = args["cells"] as? [[String: Any]]
            else {
                result(FlutterError(code: "ARGUEMENTS_ERROR", message: "arguement error", details: nil))
                return
            }
            let message = args["message"] as? String
            
            let actionCells: [ActionSheetCell] = cells.map { arg in
                return ActionSheetCell(
                    label: arg["label"] as? String ?? "",
                    key: arg["key"] as? String ?? "",
                    isDestructive: arg["isDestructive"] as? Bool ?? false
                )
            }
            
            let actionSheet = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .actionSheet
            )
            
            for actionCell in actionCells {
                let action = UIAlertAction(
                    title: actionCell.label,
                    style: actionCell.isDestructive ? .destructive : .default
                ) { _ in
                    result(actionCell.key)
                }
                actionSheet.addAction(action)
            }
            
            let cancelAction = UIAlertAction(
                title: "Cancel",
                style: .cancel
            ) { _ in
                result(nil)
            }
            actionSheet.addAction(cancelAction)
            
            if let topVC = UIApplication.shared.topViewController() {
                topVC.present(actionSheet, animated: true)
            } else {
                result(FlutterError(code: "VIEW_CONTROLLER_ERROR", message: "top view controller is not found", details: nil))
            }
            
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
}
