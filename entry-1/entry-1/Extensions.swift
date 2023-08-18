//
//  Extensions.swift
//  entry-1
//
//  Created by Katya Raman on 8/16/23.
//

import Foundation
import SwiftUI

extension UIColor {
    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let hexString = String(
            format: "#%02X%02X%02X",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255)
        )
        
        return hexString
    }
}

extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        if uiColor != nil {
            return uiColor.toHexString()
        }
        return "#FFFFFF" // default color if conversion fails
    }
}
