//
//  NativeTabbarView.swift
//  flutter_native_ui_kit
//
//  Created by 钟钰 on 2026/1/31.
//

import SwiftUI
import UIKit
import Flutter

final class NativeTabBarView: NSObject, FlutterPlatformView {
    
    private let rootView: UIView
    private let tabBarController: TabBarViewController
    private let channel: FlutterMethodChannel
    
    init(
        frame: CGRect,
        viewId: Int64,
        args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        self.channel = FlutterMethodChannel(
            name: ChannelName.of(MethodName.NATIVE_TAB_BAR.withId(viewId)),
            binaryMessenger: messenger
        )
        
        self.rootView = UIView(frame: frame)
        self.tabBarController = TabBarViewController()
        
        super.init()
        
        setup(args)
        embedController()
        bindChannel()
    }
    
    private func setup(_ args: Any?) {
        guard let args = args as? [String: Any] else { return }
        tabBarController.configure(with: args)
        rootView.backgroundColor = .clear
    }
    
    private func embedController() {
        tabBarController.view.frame = rootView.bounds
        tabBarController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rootView.addSubview(tabBarController.view)
    }
    
    private func bindChannel() {
        tabBarController.onTabSelected = { [weak self] index in
            self?.channel.invokeMethod(
                MethodName.NATIVE_TAB_BAR,
                arguments: index
            )
        }
    }
    
    func view() -> UIView {
        return rootView
    }
}


final class TabBarViewController: UITabBarController {
    
    var onTabSelected: ((Int) -> Void)?
    private var activeColor: UIColor = .systemBlue
    private var inactiveColor: UIColor = .systemGray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        view.backgroundColor = .clear
        
        applyAppearance()
    }
    
    func configure(with args: [String: Any]) {
        guard let items = args["items"] as? [[String: Any]] else { return }
        if let activeColorHex = args["activeColor"] as? Int {
            activeColor = UIColor(hex: activeColorHex)
        }
        if let inactiveColorHex = args["inactiveColor"] as? Int {
            inactiveColor = UIColor(hex: inactiveColorHex)
        }
        
        let controller = items.enumerated().map { index, item -> UIViewController in
            let vc = UIViewController()
            vc.view.backgroundColor = .clear
            
            let label = item["label"] as? String
            let symbol = item["symbol"] as? String
            
            vc.tabBarItem = UITabBarItem(
                title: label,
                image: symbol.flatMap { UIImage(systemName: $0) },
                tag: index
            )
            
            return vc
        }
        
        viewControllers = controller
        selectedIndex = args["selectedIndex"] as? Int ?? 0

        if isViewLoaded {
            applyAppearance()
        }
    }
    
    func setSelectedIndex(_ index: Int) {
        guard index >= 0, index < (viewControllers?.count ?? 0) else { return }
        selectedIndex = index
    }
    
    func applyAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        appearance.stackedLayoutAppearance.selected.iconColor = activeColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: activeColor
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = inactiveColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: inactiveColor
        ]

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
}

extension TabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        onTabSelected?(selectedIndex)
    }
    
}
