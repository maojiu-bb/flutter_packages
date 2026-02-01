//
//  NativeAppBarView.swift
//  flutter_native_ui_kit
//
//  Created by 钟钰 on 2026/2/1.
//

import UIKit
import Flutter

final class NativeAppBarView: NSObject, FlutterPlatformView {
    
    private let channel: FlutterMethodChannel
    private let rootView: UIView
    private let navBar = UINavigationBar()
    
    private var leadingAction: (() -> Void)?
    private var actionActions: [Int: () -> Void] = [:]
    
    init(
        frame: CGRect,
        viewId: Int64,
        args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        self.channel = FlutterMethodChannel(
            name: ChannelName.of(MethodName.NATIVE_APP_BAR.withId(viewId)),
            binaryMessenger: messenger
        )
        
        self.rootView = UIView(frame: frame)
        
        super.init()
        
        setup(args)
        embedNavBar()
    }
    
    private func setup(_ args: Any?) {
        rootView.backgroundColor = .clear
        
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.isTranslucent = true
        navBar.prefersLargeTitles = false
        
        let item = UINavigationItem(title: "")
        navBar.setItems([item], animated: false)
        
        guard let args = args as? [String: Any] else { return }
        
        let title = args["title"] as? String
        let titleColor = args["titleColor"] as? Int
        let leading = args["leading"] as? [String: Any]
        let actions = args["actions"] as? [[String: Any]]
        
        updateTitle(title, color: titleColor)
        updateLeading(leading)
        updateActions(actions)
    }
    
    private func embedNavBar() {
        rootView.addSubview(navBar)
        
        NSLayoutConstraint.activate([
            navBar.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            navBar.topAnchor.constraint(equalTo: rootView.topAnchor),
            navBar.bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
        ])
    }
    
    private func updateTitle(_ title: String?, color: Int?) {
        guard let item = navBar.items?.first else { return }
        
        item.title = title
        
        if let color = color {
            navBar.titleTextAttributes = [
                .foregroundColor: UIColor(hex: color)
            ]
        }
    }
    
    private func updateLeading(_ leading: [String: Any]?) {
        guard let item = navBar.items?.first else { return }
        
        leadingAction = nil
        item.leftBarButtonItem = nil
        
        guard let leading = leading else { return }
        
        let barButton = makeBarButton(
            from: leading,
            index: 0,
            isLeading: true
        )
        
        item.leftBarButtonItem = barButton
    }
    
    private func updateActions(_ actions: [[String: Any]]?) {
        guard let item = navBar.items?.first else { return }

        actionActions.removeAll()
        item.rightBarButtonItems = nil

        guard let actions = actions else { return }

        let barButtons = actions.enumerated().map {
            makeBarButton(
                from: $0.element,
                index: $0.offset,
                isLeading: false
            )
        }

        item.rightBarButtonItems = barButtons.reversed()
    }

    private func makeBarButton(
        from json: [String: Any],
        index: Int,
        isLeading: Bool
    ) -> UIBarButtonItem {

        let symbol = json["symbol"] as? String
        let colorValue = json["color"] as? Int

        let color = colorValue.map { UIColor(hex: $0) }

        let image = symbol.flatMap { UIImage(systemName: $0) }

        let uiAction = UIAction { [weak self] (_: UIAction) in
            self?.channel.invokeMethod(
                MethodName.NATIVE_APP_BAR,
                arguments: [
                    "position": isLeading ? "leading" : "action",
                    "index": index
                ]
            )
        }

        let barButton: UIBarButtonItem

        if #available(iOS 14.0, *) {
            if let image = image {
                barButton = UIBarButtonItem(image: image, primaryAction: uiAction)
            } else {
                barButton = UIBarButtonItem(title: "", primaryAction: uiAction)
            }
        } else {
            if let image = image {
                barButton = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
            } else {
                barButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            }
        }

        barButton.tag = index
        barButton.tintColor = color

        return barButton
    }

    func view() -> UIView {
        return rootView
    }
}
