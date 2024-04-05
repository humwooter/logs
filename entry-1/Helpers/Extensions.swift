//
//  Extensions.swift
//  entry-1
//
//  Created by Katya Raman on 8/16/23.
//

import Foundation
import SwiftUI



extension View {
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
        return self
    }
}

extension UIColor {
    
    func getAlpha() -> CGFloat {
        var alpha: CGFloat = 0
        self.getRed(nil, green: nil, blue: nil, alpha: &alpha)
        return alpha
    }
    
    
    static func blendedColor(from color1: UIColor, with color2: UIColor) -> UIColor {
        print("entered blended color")

        print("color1: \(color1)")
        print("color2: \(color2)")

        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        if (a1 == 1) { //foreground color is completely opaque
            return color1
        }
        let rBlended = (r1 * a1) + (r2 * a2)
        let gBlended = (g1 * a1) + (g2 * a2)
        let bBlended = (b1 * a1) + (b2 * a2)
        let aBlended = min(1, a1 + (a2 * (1 - a1)))
        print("aBlended")
        
        printColorComponents(color: color1)
        printColorComponents(color: color2)


        return UIColor(red: rBlended, green: gBlended, blue: bBlended, alpha: aBlended)
    }

    

    
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


    static func foregroundColor(entry: Entry, background: UIColor, userPreferences: UserPreferences) -> Color {
        if entry.stampIndex == -1 {
            if userPreferences.entryBackgroundColor != .clear {
                let blendedColor = blendedColor(from: background, with: UIColor(userPreferences.entryBackgroundColor))
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                blendedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                let brightness = (red * 299 + green * 587 + blue * 114) / 1000
                return brightness > 0.5 ? Color.black : Color.white
            }
        }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        
        return brightness > 0.5 ? Color.black : Color.white
    }

    static func foregroundColor2(colorScheme: ColorScheme, userPreferences: UserPreferences) -> Color {
        if userPreferences.entryBackgroundColor != .clear {
            let blendedColor = blendedColor(from: UIColor(userPreferences.backgroundColors.first!), with: UIColor(userPreferences.entryBackgroundColor))
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            blendedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let brightness = (red * 299 + green * 587 + blue * 114) / 1000
            return brightness > 0.5 ? Color.black : Color.white
        } else {
            let background = UIColor(Color("DefaultEntryBackground"))
            
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            let brightness = (red * 299 + green * 587 + blue * 114) / 1000
            
            return brightness > 0.5 ? Color.black : Color.white
        }
    }



    static func foregroundColor(background: UIColor) -> Color {
        
        print("entered foreground color func")
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        if (isClear(for: background)) {
            let new_background = UIColor.systemGroupedBackground
            new_background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        
        print("print background color: \(background)")

        
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        
        print("brightness value: \(brightness)")
        
        return brightness > 0.5 ? Color.black : Color.white
    }
    
    
    static func backgroundColor(entry: Entry, colorScheme: ColorScheme, userPreferences: UserPreferences) -> Color {
        let opacity_val = colorScheme == .dark ? 0.90 : 0.85
//        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
        let color = getDefaultEntryBackgroundColor(colorScheme: colorScheme)

        if  entry.stampIndex == -1 || entry.stampIndex == nil {
            
            if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
                print("default color returned for entry background color")
                return color
            } else {
                return userPreferences.entryBackgroundColor
            }
        }
        return Color(entry.color).opacity(opacity_val)
    }
    


    static func fontColor(forBackgroundColor backgroundColor: UIColor) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        // Decompose the UIColor into its RGBA components
        backgroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Calculate luminance using the RGB values
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue

        // Determine and return the font color based on luminance to maximize contrast
        // If the luminance is greater than 0.5 (more light), we choose black font color, otherwise white.
        print("luminance: \(luminance)")
        return luminance > 0.5 ? .black : .white
    }
    
    static func fontColor(forBackgroundColor backgroundColor: UIColor, colorScheme: ColorScheme) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        var color = backgroundColor
        
        if isClear(for: backgroundColor) {
            print("background color is clear")
                color = UIColor(getDefaultBackgroundColor(colorScheme: colorScheme))
        }

        // Decompose the UIColor into its RGBA components
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Calculate luminance using the RGB values
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue

        // Determine and return the font color based on luminance to maximize contrast
        // If the luminance is greater than 0.5 (more light), we choose black font color, otherwise white.
        print("luminance: \(luminance)")
        return luminance > 0.5 ? .black : .white
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
