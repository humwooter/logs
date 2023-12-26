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
            format: "#%02X%02X%02X%02X",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255),
            Int(alpha * 255)
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
        case 7: // XRGB (28-bit) Custom case
            (a, r, g, b) = (255, int >> 20, int >> 12 & 0xFF, int >> 4 & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        case 12: // AXRGB (48-bit) Custom case
            (a, r, g, b) = (int >> 36, int >> 28 & 0xFF, int >> 20 & 0xFF, int >> 12 & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }


    static func foregroundColor(entry: Entry, background: UIColor, colorScheme: ColorScheme, userPreferences: UserPreferences) -> Color {
        if !userPreferences.stamps.contains(where: { $0.isActive }) {
            return colorScheme == .dark ? Color.white : Color.black
        }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        
        return brightness > 0.5 ? Color.black : Color.white
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
    
    static func foregroundColor(background: UIColor) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if background == UIColor(Color.clear) {
            let new_background = UIColor.systemGroupedBackground
            new_background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        else {
            background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        
        return brightness > 0.5 ? Color.black : Color.white
    }
    
    
    static func backgroundColor(entry: Entry, colorScheme: ColorScheme, userPreferences: UserPreferences) -> Color {
        let opacity_val = colorScheme == .dark ? 0.90 : 0.75
        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
//        
//        
        if  entry.stampIndex == -1 || entry.stampIndex == nil {
            return Color(color)
        }
//        
//        print("Color(entry.color).opacity(opacity_val): \(Color(entry.color).opacity(opacity_val))")
        return Color(entry.color).opacity(opacity_val)
    }
    
    
}

extension Color {
    
    

    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.5  // Default grey
        var g: CGFloat = 0.5  // Default grey
        var b: CGFloat = 0.5  // Default grey
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        if Scanner(string: hexSanitized).scanHexInt64(&rgb) {
            if length == 6 {
                r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
                g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
                b = CGFloat(rgb & 0x0000FF) / 255.0
            } else if length == 8 {
                r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
                g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
                b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
                a = CGFloat(rgb & 0x000000FF) / 255.0
            }
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }

    
    func toHex() -> String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return "808080"  // Default grey hex
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
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
    
    static func complementaryColor(of color: Color) -> Color {
        let uiColor = UIColor(color)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        // Shift hue by 180 degrees
        let newHue = (hue + 0.5).truncatingRemainder(dividingBy: 1)
        
        let complementaryUIColor = UIColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
        
        return Color(complementaryUIColor)
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
    
    func startOfWeek(for date: Date) -> Date {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Optional, set first weekday as Monday
        return cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
    }
    
    func startOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
    }
}


extension URL {
    static var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

extension View {
    func capture() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let screenSize = UIScreen.main.bounds.size
        let targetSize = CGSize(width: screenSize.width, height: controller.sizeThatFits(in: screenSize).height)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

    
//    func snapshot() -> UIImage {
//         let controller = UIHostingController(rootView: self)
//         let view = controller.view
//
//         let targetSize = controller.view.intrinsicContentSize
//         view?.bounds = CGRect(origin: .zero, size: targetSize)
//         view?.backgroundColor = .clear
//
//         let renderer = UIGraphicsImageRenderer(size: targetSize)
//
//         return renderer.image { _ in
//             view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
//         }
//     }

//extension Dictionary where Key == UUID, Value == CGFloat {
//    subscript(binding key: UUID) -> Binding<CGFloat> {
//        mutating get {
//            Binding<CGFloat>(
//                get: { self[key] ?? 0 },
//                set: { self[key] = $0 }
//            )
//        }
//    }
//}
