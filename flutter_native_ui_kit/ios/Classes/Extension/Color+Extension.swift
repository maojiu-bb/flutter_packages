//
//  Color+Extension.swift
//  flutter_native_ui_kit
//
//  Created by 钟钰 on 2026/2/1.
//

import UIKit

extension UIColor {

    convenience init(hex value: Int) {
        let r, g, b, a: CGFloat

        if value <= 0xFFFFFF {
            r = CGFloat((value >> 16) & 0xFF) / 255.0
            g = CGFloat((value >> 8) & 0xFF) / 255.0
            b = CGFloat(value & 0xFF) / 255.0
            a = 1.0
        } else {
            a = CGFloat((value >> 24) & 0xFF) / 255.0
            r = CGFloat((value >> 16) & 0xFF) / 255.0
            g = CGFloat((value >> 8) & 0xFF) / 255.0
            b = CGFloat(value & 0xFF) / 255.0
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
