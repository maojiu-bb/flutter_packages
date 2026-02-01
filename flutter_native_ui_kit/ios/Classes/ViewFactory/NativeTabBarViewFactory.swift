//
//  NativeTabBarViewFactory.swift
//  flutter_native_ui_kit
//
//  Created by 钟钰 on 2026/2/1.
//

import Flutter
 
final class NativeTabBarViewFactory: BaseViewFactory {
  override func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
      return NativeTabBarView(
        frame: frame,
        viewId: viewId,
        args: args,
        messenger: messenger
      )
  }
}
