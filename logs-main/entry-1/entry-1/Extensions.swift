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
    

    
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    static func foregroundColor(entry: Entry, background: UIColor, colorScheme: ColorScheme) -> Color {
        let color = colorScheme == .dark ? Color.white : Color.black
        
        if !entry.buttons.contains(true) {
            if colorScheme == .dark {
                return .white
            }
            return .black
        }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        print("brigtness value: \(brightness)")
        
        return brightness > 0.5 ? Color.black : Color.white
    }
    
    static func foregroundColor(entry: Entry, background: UIColor) -> Color {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        
        return brightness > 0.5 ? Color.black : Color.white
    }
    
    
    static func backgroundColor(entry: Entry, colorScheme: ColorScheme) -> Color {
        let opacity_val = colorScheme == .dark ? 0.90 : 0.75
        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
        
        
        if !entry.buttons.contains(true) {
            return Color(color)
        }
        
        print("Color(entry.color).opacity(opacity_val): \(Color(entry.color).opacity(opacity_val))")
        return Color(entry.color).opacity(opacity_val)
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
    
    
    static func oppositeColor(of color: Color) -> Color {
        // Extract the RGB components
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate the opposite color by subtracting each component from 1
        let oppositeColor = UIColor(red: 1 - red, green: 1 - green, blue: 1 - blue, alpha: alpha)
        
        return Color(oppositeColor)
    }
}


extension Data {
    var isGIF: Bool {
        return self.prefix(6) == Data([0x47, 0x49, 0x46, 0x38, 0x37, 0x61]) || self.prefix(6) == Data([0x47, 0x49, 0x46, 0x38, 0x39, 0x61])
    }
}

extension Date {
    static func formattedDate(time: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: time)
    }
}


extension URL {
    static var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
