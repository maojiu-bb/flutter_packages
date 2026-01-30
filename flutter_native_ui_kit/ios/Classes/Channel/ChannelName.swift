//
//  ChannelName.swift
//  flutter_native_ui_kit
//
//  Created by 钟钰 on 2026/1/30.
//

import Foundation

class ChannelName {
    
    static private let basename = "flutter_native_ui_kit"
    
    
    static func of(_ name: String) -> String {
        return "\(basename)/\(name)"
    }
}
