//
//  String+Extension.swift
//  flutter_native_ui_kit
//
//  Created by 钟钰 on 2026/2/1.
//

import Foundation

extension String {
    
    func withId(_ id: Int64) -> String {
        return "\(self)/\(id)"
    }
    
}
