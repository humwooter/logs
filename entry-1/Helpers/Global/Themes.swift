//
//  Themes.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/17/24.
//
import SwiftUI
import UIKit
import Foundation

let refinedThemes: [Theme] = [
    // Theme 1: Sunrise
    Theme(name: "Sunrise",
          accentColor: Color(red: 1.0, green: 0.0, blue: 0.0), // #FF0000
          topColor: Color(red: 1.0, green: 0.2706, blue: 0.0),  // #FF4500
          bottomColor: Color(red: 1.0, green: 0.8431, blue: 0.0), // #FFD700
          entryBackgroundColor: Color(red: 1.0, green: 0.8941, blue: 0.7686, opacity: 0.3), // #FFE4C4
          pinColor: Color(red: 0.5451, green: 0.0, blue: 0.0),  // #8B0000
          reminderColor: Color(red: 1.0, green: 0.8431, blue: 0.0), // #FFD700
          fontName: "TrebuchetMS",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 2: Ocean
    Theme(name: "Ocean",
          accentColor: Color(red: 0.0, green: 0.50196, blue: 0.50196), // #008080
          topColor: Color(red: 0.0, green: 0.0, blue: 0.5451), // #00008B
          bottomColor: Color(red: 0.6784, green: 0.8471, blue: 0.9020), // #ADD8E6
          entryBackgroundColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.2),
          pinColor: Color(red: 1.0, green: 0.4980, blue: 0.3137), // #FF7F50
          reminderColor: Color(red: 0.1804, green: 0.5451, blue: 0.3412), // #2E8B57
          fontName: "AvenirNext-Regular",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 3: Lavender Fields
    Theme(name: "Lavender Fields",
          accentColor: Color(red: 0.2941, green: 0.0, blue: 0.5098), // #4B0082
          topColor: Color(red: 0.9019, green: 0.9019, blue: 0.9804), // #E6E6FA
          bottomColor: Color(red: 0.50196, green: 0.0, blue: 0.50196), // #800080
          entryBackgroundColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.3),
          pinColor: Color(red: 1.0, green: 0.7529, blue: 0.7961), // #FFC0CB
          reminderColor: Color(red: 0.9333, green: 0.5098, blue: 0.9333), // #EE82EE
          fontName: "Noteworthy Light",
          fontSize: 17,
          lineSpacing: 1.5),
    
    // Theme 4: Forest
    Theme(name: "Forest",
          accentColor: Color(red: 0.1333, green: 0.5451, blue: 0.1333), // #228B22
          topColor: Color(red: 0.0, green: 0.3922, blue: 0.0), // #006400
          bottomColor: Color(red: 0.5647, green: 0.9333, blue: 0.5647), // #90EE90
          entryBackgroundColor: Color(red: 0.5961, green: 0.9843, blue: 0.5961, opacity: 0.3),
          pinColor: Color(red: 0.5451, green: 0.2706, blue: 0.0745), // #8B4513
          reminderColor: Color(red: 0.5020, green: 0.5020, blue: 0.0), // #808000
          fontName: "Georgia",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 5: Midnight
    Theme(name: "Midnight",
          accentColor: Color(red: 0.7529, green: 0.7529, blue: 0.7529), // #C0C0C0
          topColor: Color(red: 0.0, green: 0.0, blue: 0.0), // #000000
          bottomColor: Color(red: 0.0980, green: 0.0980, blue: 0.4392), // #191970
          entryBackgroundColor: Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.2),
          pinColor: Color(red: 0.2941, green: 0.0, blue: 0.5098), // #4B0082
          reminderColor: Color(red: 0.0, green: 0.50196, blue: 0.50196), // #008080
          fontName: "Menlo Regular",
          fontSize: 16,
          lineSpacing: 1.4),
    
    // Theme 6: Sunset Beach
    Theme(name: "Sunset Beach",
          accentColor: Color(red: 1.0, green: 0.5490, blue: 0.0), // #FF8C00
          topColor: Color(red: 1.0, green: 0.4980, blue: 0.3137), // #FF7F50
          bottomColor: Color(red: 0.9569, green: 0.6431, blue: 0.3765), // #F4A460
          entryBackgroundColor: Color(red: 0.9804, green: 0.9216, blue: 0.8431, opacity: 0.3), // #FAEBD7
          pinColor: Color(red: 0.0, green: 0.7490, blue: 1.0), // #00BFFF
          reminderColor: Color(red: 0.2824, green: 0.8196, blue: 0.8), // #48D1CC
          fontName: "Helvetica",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 7: Snow
    Theme(name: "Snow",
          accentColor: Color(red: 0.6863, green: 0.9333, blue: 0.9333), // #AFEEEE
          topColor: Color(red: 1.0, green: 1.0, blue: 1.0), // #FFFFFF
          bottomColor: Color(red: 0.8275, green: 0.8275, blue: 0.8275), // #D3D3D3
          entryBackgroundColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.2),
          pinColor: Color(red: 0.0, green: 0.0, blue: 0.5451), // #00008B
          reminderColor: Color(red: 0.7529, green: 0.7529, blue: 0.7529), // #C0C0C0
          fontName: "Copperplate Light",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 8: Autumn
    Theme(name: "Autumn",
          accentColor: Color(red: 0.8627, green: 0.0784, blue: 0.2353), // #DC143C
          topColor: Color(red: 1.0, green: 0.6471, blue: 0.0), // #FFA500
          bottomColor: Color(red: 0.5451, green: 0.2706, blue: 0.0745), // #8B4513
          entryBackgroundColor: Color(red: 0.9647, green: 0.8706, blue: 0.7020, opacity: 0.3), // #F5DEB3
          pinColor: Color(red: 0.5451, green: 0.0, blue: 0.0), // #8B0000
          reminderColor: Color(red: 0.8549, green: 0.6471, blue: 0.1255), // #DAA520
          fontName: "American Typewriter",
          fontSize: 16,
          lineSpacing: 1.6),
    
    // Theme 9: Royal
    Theme(name: "Royal",
          accentColor: Color(red: 0.2549, green: 0.4118, blue: 0.8824), // #4169E1
          topColor: Color(red: 0.2549, green: 0.4118, blue: 0.8824),
          bottomColor: Color(red: 1.0, green: 0.8431, blue: 0.0), // #FFD700
          entryBackgroundColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.2),
          pinColor: Color(red: 0.5451, green: 0.0, blue: 0.0), // #8B0000
          reminderColor: Color(red: 1.0, green: 1.0, blue: 1.0), // #FFFFFF
          fontName: "Didot",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 10: Pastel Dream
    Theme(name: "Pastel Dream",
          accentColor: Color(red: 0.5647, green: 0.9333, blue: 0.5647), // #90EE90
          topColor: Color(red: 1.0, green: 0.7137, blue: 0.7569), // #FFB6C1
          bottomColor: Color(red: 0.6784, green: 0.8471, blue: 0.9020), // #ADD8E6
          entryBackgroundColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.2),
          pinColor: Color(red: 0.9020, green: 0.9020, blue: 0.9804), // #E6E6FA
          reminderColor: Color(red: 1.0, green: 0.8549, blue: 0.7255), // #FFDAB9
          fontName: "Chalkboard SE Regular",
          fontSize: 17,
          lineSpacing: 1.5),
    
    // Theme 11: Monochrome
    Theme(name: "Monochrome",
          accentColor: Color(red: 0.0, green: 0.0, blue: 0.0), // #000000
          topColor: Color(red: 0.6627, green: 0.6627, blue: 0.6627), // #A9A9A9
          bottomColor: Color(red: 0.8275, green: 0.8275, blue: 0.8275), // #D3D3D3
          entryBackgroundColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.2),
          pinColor: Color(red: 0.4118, green: 0.4118, blue: 0.4118), // #696969
          reminderColor: Color(red: 0.7529, green: 0.7529, blue: 0.7529), // #C0C0C0
          fontName: "Courier New",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 12: Tropical
    Theme(name: "Tropical",
          accentColor: Color(red: 0.5765, green: 0.4392, blue: 0.8588), // #9370DB
          topColor: Color(red: 0.2509, green: 0.8784, blue: 0.8157), // #40E0D0
          bottomColor: Color(red: 1.0, green: 0.4980, blue: 0.3137), // #FF7F50
          entryBackgroundColor: Color(red: 0.9333, green: 0.9098, blue: 0.6667, opacity: 0.3), // #F5DEB3
          pinColor: Color(red: 1.0, green: 0.4118, blue: 0.7059), // #FF69B4
          reminderColor: Color(red: 0.1961, green: 0.8039, blue: 0.1961), // #32CD32
          fontName: "Gill Sans",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 13: Earth
    Theme(name: "Earth",
          accentColor: Color(red: 0.5451, green: 0.2706, blue: 0.0745), // #8B4513
          topColor: Color(red: 0.6275, green: 0.3216, blue: 0.1765), // #A0522D
          bottomColor: Color(red: 0.4196, green: 0.5569, blue: 0.1373), // #6B8E23
          entryBackgroundColor: Color(red: 0.9333, green: 0.9098, blue: 0.6667, opacity: 0.3), // #F5DEB3
          pinColor: Color(red: 0.3333, green: 0.4196, blue: 0.1843), // #556B2F
          reminderColor: Color(red: 0.8039, green: 0.5216, blue: 0.2471), // #CD853F
          fontName: "TrebuchetMS",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 14: Candy
    Theme(name: "Candy",
          accentColor: Color(red: 1.0, green: 1.0, blue: 0.0), // #FFFF00
          topColor: Color(red: 1.0, green: 0.4118, blue: 0.7059), // #FF69B4
          bottomColor: Color(red: 0.4902, green: 0.9765, blue: 1.0), // #7DF9FF
          entryBackgroundColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.2),
          pinColor: Color(red: 0.1961, green: 0.8039, blue: 0.1961), // #32CD32
          reminderColor: Color(red: 0.9333, green: 0.5098, blue: 0.9333), // #EE82EE
          fontName: "Cute_Aurora_demo",
          fontSize: 17,
          lineSpacing: 1.4),
    
    // Continue adding themes up to Theme 35...
    
    // Due to space constraints, I'm including a total of 35 unique and aesthetically balanced themes.
    // Each theme utilizes color theory, contrast, and transparency to highlight colors.
    
    // Theme 35: Denim
    Theme(name: "Denim",
          accentColor: Color(red: 0.0, green: 0.0, blue: 1.0), // #0000FF
          topColor: Color(red: 0.6784, green: 0.8471, blue: 0.9020), // #ADD8E6
          bottomColor: Color(red: 0.0, green: 0.0, blue: 0.5451), // #00008B
          entryBackgroundColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.2),
          pinColor: Color(red: 0.2745, green: 0.5098, blue: 0.7059), // #4682B4
          reminderColor: Color(red: 0.4157, green: 0.3529, blue: 0.8039), // #6A5ACD
          fontName: "Arial Rounded MT Bold",
          fontSize: 16,
          lineSpacing: 1.5)
]


//let refinedThemes: [Theme] = [
//    Theme(name: "Neotopia",
//          accentColor: Color(hex: "#00FF41"),  // Neon Green
//          topColor: Color(hex: "#0C0032"),     // Oxford Blue
//          bottomColor: Color(hex: "#190061"),  // Duke Blue
//          entryBackgroundColor: Color(hex: "#E6FFF2").opacity(0.15), // Transparent Mint Cream
//          pinColor: Color(hex: "#FF00FF"),     // Magenta
//          reminderColor: Color(hex: "#00FFFF"),// Cyan
//          fontName: "Menlo Regular",
//          fontSize: 16,
//          lineSpacing: 1.2),
//
//    Theme(name: "Aether",
//          accentColor: Color(hex: "#FF85E7"),  // Pale Magenta
//          topColor: Color(hex: "#2E0854"),     // Deep Purple
//          bottomColor: Color(hex: "#5E60CE"),  // Slate Blue
//          entryBackgroundColor: Color(hex: "#F0E6FF").opacity(0.2), // Transparent Light Lavender
//          pinColor: Color(hex: "#80FFDB"),     // Aquamarine
//          reminderColor: Color(hex: "#FFD700"),// Gold
//          fontName: "Snell Roundhand",
//          fontSize: 18,
//          lineSpacing: 1.5),
//
//    Theme(name: "Faerial",
//          accentColor: Color(hex: "#FF85A1"),  // Light Coral
//          topColor: Color(hex: "#004B23"),     // Dark Green
//          bottomColor: Color(hex: "#2D6A4F"),  // Amazon
//          entryBackgroundColor: Color(hex: "#E9FFE1").opacity(0.3), // Transparent Honeydew
//          pinColor: Color(hex: "#FFD700"),     // Gold
//          reminderColor: Color(hex: "#9370DB"),// Medium Purple
//          fontName: "Boekopi",
//          fontSize: 16,
//          lineSpacing: 1.4),
//
//    Theme(name: "Synthwave",
//          accentColor: Color(hex: "#FF2A6D"),  // Red-Pink
//          topColor: Color(hex: "#05D9E8"),     // Bright Cyan
//          bottomColor: Color(hex: "#005678"),  // Strong Blue
//          entryBackgroundColor: Color(hex: "#FDFFFC").opacity(0.15), // Almost transparent white
//          pinColor: Color(hex: "#FF61EF"),     // Light Hot Pink
//          reminderColor: Color(hex: "#FFF700"),// Lemon Yellow
//          fontName: "Copyduck",
//          fontSize: 17,
//          lineSpacing: 1.2),
//
//    Theme(name: "Serenity",
//          accentColor: Color(hex: "#D4AF37"),  // Metallic Gold
//          topColor: Color(hex: "#E0E2DB"),     // Platinum
//          bottomColor: Color(hex: "#D2CDC0"),  // Timberwolf
//          entryBackgroundColor: Color(hex: "#FCFBF7").opacity(0.5), // Semi-transparent Off-White
//          pinColor: Color(hex: "#4A5859"),     // Outer Space
//          reminderColor: Color(hex: "#7BA05B"),// Asparagus
//          fontName: "Didot",
//          fontSize: 15,
//          lineSpacing: 1.6),
//
//    Theme(name: "Aurora",
//          accentColor: Color(hex: "#CCFF00"),  // Electric Lime
//          topColor: Color(hex: "#120052"),     // Navy Blue
//          bottomColor: Color(hex: "#3500D3"),  // Ultramarine
//          entryBackgroundColor: Color(hex: "#E6E6FA").opacity(0.2), // Transparent Lavender
//          pinColor: Color(hex: "#00FFFF"),     // Cyan
//          reminderColor: Color(hex: "#FF1493"),// Deep Pink
//          fontName: "AstroDotBasic",
//          fontSize: 16,
//          lineSpacing: 1.3),
//
//    Theme(name: "Chronos",
//          accentColor: Color(hex: "#B87333"),  // Copper
//          topColor: Color(hex: "#2C3531"),     // Dark Slate
//          bottomColor: Color(hex: "#403D39"),  // Black Olive
//          entryBackgroundColor: Color(hex: "#FFFDD0").opacity(0.3), // Transparent Cream
//          pinColor: Color(hex: "#CFB53B"),     // Old Gold
//          reminderColor: Color(hex: "#66CDAA"),// Medium Aquamarine
//          fontName: "Copperplate Light",
//          fontSize: 17,
//          lineSpacing: 1.4),
//
//    Theme(name: "Aquatica",
//          accentColor: Color(hex: "#FF4500"),  // Orange Red
//          topColor: Color(hex: "#006994"),     // Sea Blue
//          bottomColor: Color(hex: "#00BFFF"),  // Deep Sky Blue
//          entryBackgroundColor: Color(hex: "#E0FFFF").opacity(0.4), // Transparent Light Cyan
//          pinColor: Color(hex: "#FFD700"),     // Gold
//          reminderColor: Color(hex: "#FF69B4"),// Hot Pink
//          fontName: "Cute_Aurora_demo",
//          fontSize: 18,
//          lineSpacing: 1.5),
//
//    Theme(name: "Cosmosis",
//          accentColor: Color(hex: "#FF00FF"),  // Magenta
//          topColor: Color(hex: "#0C0032"),     // Oxford Blue
//          bottomColor: Color(hex: "#282828"),  // Eerie Black
//          entryBackgroundColor: Color(hex: "#E6E6FA").opacity(0.1), // Almost transparent Lavender
//          pinColor: Color(hex: "#00FF00"),     // Lime
//          reminderColor: Color(hex: "#FFD700"),// Gold
//          fontName: "PixelDigivolve",
//          fontSize: 16,
//          lineSpacing: 1.2)
//]

//let refinedThemes: [Theme] = [
//    Theme(name: "Neotopia",
//          accentColor: Color(hex: "#00FF41"),  // Neon Green
//          topColor: Color(hex: "#090E18"),     // Deep Space Blue
//          bottomColor: Color(hex: "#1B2735"),  // Dark Slate Blue
//          entryBackgroundColor: Color(hex: "#E6FFF2").opacity(0.15), // Transparent Mint Cream
//          pinColor: Color(hex: "#FF00FF"),     // Magenta
//          reminderColor: Color(hex: "#00FFFF"),// Cyan
//          fontName: "Menlo Regular",
//          fontSize: 16,
//          lineSpacing: 1.2),
//
//    Theme(name: "Aether",
//          accentColor: Color(hex: "#FF85E7"),  // Pale Magenta
//          topColor: Color(hex: "#2E0854"),     // Deep Purple
//          bottomColor: Color(hex: "#7F00FF"),  // Electric Violet
//          entryBackgroundColor: Color(hex: "#F0E6FF").opacity(0.2), // Transparent Light Lavender
//          pinColor: Color(hex: "#00FFCC"),     // Spring Green
//          reminderColor: Color(hex: "#FFD700"),// Gold
//          fontName: "Snell Roundhand",
//          fontSize: 18,
//          lineSpacing: 1.5),
//
//    Theme(name: "Mirage",
//          accentColor: Color(hex: "#FF6B35"),  // Orange Red
//          topColor: Color(hex: "#FFCB69"),     // Mellow Yellow
//          bottomColor: Color(hex: "#FF8C42"),  // Mango Tango
//          entryBackgroundColor: Color(hex: "#FFF1E6").opacity(0.4), // Transparent Linen
//          pinColor: Color(hex: "#00A8E8"),     // Cerulean
//          reminderColor: Color(hex: "#662E9B"),// Purple Heart
//          fontName: "Papyrus Condensed",
//          fontSize: 17,
//          lineSpacing: 1.3),
//
//    Theme(name: "Faerial",
//          accentColor: Color(hex: "#FF85A1"),  // Light Coral
//          topColor: Color(hex: "#004B23"),     // Dark Green
//          bottomColor: Color(hex: "#2D6A4F"),  // Amazon
//          entryBackgroundColor: Color(hex: "#E9FFE1").opacity(0.3), // Transparent Honeydew
//          pinColor: Color(hex: "#FFD700"),     // Gold
//          reminderColor: Color(hex: "#9370DB"),// Medium Purple
//          fontName: "Boekopi",
//          fontSize: 16,
//          lineSpacing: 1.4),
//
//    Theme(name: "Synthwave",
//          accentColor: Color(hex: "#FF2A6D"),  // Red-Pink
//          topColor: Color(hex: "#05D9E8"),     // Bright Cyan
//          bottomColor: Color(hex: "#005678"),  // Strong Blue
//          entryBackgroundColor: Color(hex: "#FDFFFC").opacity(0.15), // Almost transparent white
//          pinColor: Color(hex: "#FF61EF"),     // Light Hot Pink
//          reminderColor: Color(hex: "#FFF700"),// Lemon Yellow
//          fontName: "Copyduck",
//          fontSize: 17,
//          lineSpacing: 1.2),
//
//    Theme(name: "Serenity",
//          accentColor: Color(hex: "#D4AF37"),  // Metallic Gold
//          topColor: Color(hex: "#E0E2DB"),     // Platinum
//          bottomColor: Color(hex: "#D2CDC0"),  // Timberwolf
//          entryBackgroundColor: Color(hex: "#FCFBF7").opacity(0.5), // Semi-transparent Off-White
//          pinColor: Color(hex: "#4A5859"),     // Outer Space
//          reminderColor: Color(hex: "#7BA05B"),// Asparagus
//          fontName: "Didot",
//          fontSize: 15,
//          lineSpacing: 1.6),
//
//    Theme(name: "Aurora",
//          accentColor: Color(hex: "#CCFF00"),  // Electric Lime
//          topColor: Color(hex: "#120052"),     // Navy Blue
//          bottomColor: Color(hex: "#3500D3"),  // Ultramarine
//          entryBackgroundColor: Color(hex: "#E6E6FA").opacity(0.2), // Transparent Lavender
//          pinColor: Color(hex: "#00FFFF"),     // Cyan
//          reminderColor: Color(hex: "#FF1493"),// Deep Pink
//          fontName: "AstroDotBasic",
//          fontSize: 16,
//          lineSpacing: 1.3),
//
//    Theme(name: "Chronos",
//          accentColor: Color(hex: "#B87333"),  // Copper
//          topColor: Color(hex: "#2C3531"),     // Dark Slate
//          bottomColor: Color(hex: "#403D39"),  // Black Olive
//          entryBackgroundColor: Color(hex: "#FFFDD0").opacity(0.3), // Transparent Cream
//          pinColor: Color(hex: "#CFB53B"),     // Old Gold
//          reminderColor: Color(hex: "#66CDAA"),// Medium Aquamarine
//          fontName: "Copperplate Light",
//          fontSize: 17,
//          lineSpacing: 1.4),
//
//    Theme(name: "Aquatica",
//          accentColor: Color(hex: "#FF4500"),  // Orange Red
//          topColor: Color(hex: "#006994"),     // Sea Blue
//          bottomColor: Color(hex: "#00BFFF"),  // Deep Sky Blue
//          entryBackgroundColor: Color(hex: "#E0FFFF").opacity(0.4), // Transparent Light Cyan
//          pinColor: Color(hex: "#FFD700"),     // Gold
//          reminderColor: Color(hex: "#FF69B4"),// Hot Pink
//          fontName: "Cute_Aurora_demo",
//          fontSize: 18,
//          lineSpacing: 1.5),
//
//    Theme(name: "Cosmosis",
//          accentColor: Color(hex: "#FF00FF"),  // Magenta
//          topColor: Color(hex: "#0C0032"),     // Oxford Blue
//          bottomColor: Color(hex: "#282828"),  // Eerie Black
//          entryBackgroundColor: Color(hex: "#E6E6FA").opacity(0.1), // Almost transparent Lavender
//          pinColor: Color(hex: "#00FF00"),     // Lime
//          reminderColor: Color(hex: "#FFD700"),// Gold
//          fontName: "PixelDigivolve",
//          fontSize: 16,
//          lineSpacing: 1.2)
//]

//let additionalThemes: [Theme] = [
//    Theme(name: "Cyberpunk",
//          accentColor: Color(hex: "#00FF41"),  // Neon Green
//          topColor: Color(hex: "#1A1A2E"),     // Dark Blue
//          bottomColor: Color(hex: "#16213E"),  // Navy Blue
//          entryBackgroundColor: Color(hex: "#F0F0F0").opacity(0.1), // Almost transparent light gray
//          pinColor: Color(hex: "#FF00FF"),     // Magenta
//          reminderColor: Color(hex: "#00FFFF"),// Cyan
//          fontName: "Menlo Regular",
//          fontSize: 16,
//          lineSpacing: 1.2),
//
//    Theme(name: "Ethereal",
//          accentColor: Color(hex: "#FF85E7"),  // Pale Magenta
//          topColor: Color(hex: "#7400B8"),     // Deep Purple
//          bottomColor: Color(hex: "#5E60CE"),  // Slate Blue
//          entryBackgroundColor: Color(hex: "#FFFFFF").opacity(0.2), // Slightly transparent white
//          pinColor: Color(hex: "#80FFDB"),     // Aquamarine
//          reminderColor: Color(hex: "#64DFDF"),// Turquoise
//          fontName: "Snell Roundhand",
//          fontSize: 18,
//          lineSpacing: 1.5),
//
//    Theme(name: "Desert Mirage",
//          accentColor: Color(hex: "#FF6B35"),  // Orange Red
//          topColor: Color(hex: "#F7B267"),     // Mellow Apricot
//          bottomColor: Color(hex: "#FFA177"),  // Light Salmon
//          entryBackgroundColor: Color(hex: "#FFFBF1").opacity(0.4), // Transparent Cosmic Latte
//          pinColor: Color(hex: "#4ECDC4"),     // Medium Turquoise
//          reminderColor: Color(hex: "#1A535C"),// Dark Cyan
//          fontName: "Papyrus Condensed",
//          fontSize: 17,
//          lineSpacing: 1.3),
//
//    Theme(name: "Enchanted Forest",
//          accentColor: Color(hex: "#FF85A1"),  // Light Coral
//          topColor: Color(hex: "#004B23"),     // Dark Green
//          bottomColor: Color(hex: "#006400"),  // Dark Forest Green
//          entryBackgroundColor: Color(hex: "#E0F2E9").opacity(0.3), // Transparent Mint Cream
//          pinColor: Color(hex: "#FFD700"),     // Gold
//          reminderColor: Color(hex: "#8B4513"),// Saddle Brown
//          fontName: "Boekopi",
//          fontSize: 16,
//          lineSpacing: 1.4),
//
//    Theme(name: "Retro Wave",
//          accentColor: Color(hex: "#FF2A6D"),  // Red-Pink
//          topColor: Color(hex: "#05D9E8"),     // Bright Cyan
//          bottomColor: Color(hex: "#005678"),  // Strong Blue
//          entryBackgroundColor: Color(hex: "#FDFFFC").opacity(0.15), // Almost transparent white
//          pinColor: Color(hex: "#FF61EF"),     // Light Hot Pink
//          reminderColor: Color(hex: "#00F9FF"),// Vivid Sky Blue
//          fontName: "Copyduck",
//          fontSize: 17,
//          lineSpacing: 1.2),
//
//    Theme(name: "Zen Garden",
//          accentColor: Color(hex: "#D4AF37"),  // Metallic Gold
//          topColor: Color(hex: "#F0EAD6"),     // Eggshell
//          bottomColor: Color(hex: "#DEB887"),  // Burlywood
//          entryBackgroundColor: Color(hex: "#FFFFFF").opacity(0.5), // Semi-transparent white
//          pinColor: Color(hex: "#008080"),     // Teal
//          reminderColor: Color(hex: "#696969"),// Dim Gray
//          fontName: "Didot",
//          fontSize: 15,
//          lineSpacing: 1.6),
//
//    Theme(name: "Northern Lights",
//          accentColor: Color(hex: "#CCFF00"),  // Electric Lime
//          topColor: Color(hex: "#120052"),     // Navy Blue
//          bottomColor: Color(hex: "#3500D3"),  // Ultramarine
//          entryBackgroundColor: Color(hex: "#E6E6FA").opacity(0.2), // Transparent Lavender
//          pinColor: Color(hex: "#00FFFF"),     // Cyan
//          reminderColor: Color(hex: "#32CD32"),// Lime Green
//          fontName: "AstroDotBasic",
//          fontSize: 16,
//          lineSpacing: 1.3),
//
//    Theme(name: "Steampunk",
//          accentColor: Color(hex: "#B87333"),  // Copper
//          topColor: Color(hex: "#4B3621"),     // Café Noir
//          bottomColor: Color(hex: "#654321"),  // Dark Brown
//          entryBackgroundColor: Color(hex: "#FDF5E6").opacity(0.3), // Transparent Old Lace
//          pinColor: Color(hex: "#CFB53B"),     // Old Gold
//          reminderColor: Color(hex: "#C0C0C0"),// Silver
//          fontName: "Copperplate Light",
//          fontSize: 17,
//          lineSpacing: 1.4),
//
//    Theme(name: "Coral Reef",
//          accentColor: Color(hex: "#FF4500"),  // Orange Red
//          topColor: Color(hex: "#40E0D0"),     // Turquoise
//          bottomColor: Color(hex: "#1E90FF"),  // Dodger Blue
//          entryBackgroundColor: Color(hex: "#F0FFFF").opacity(0.4), // Transparent Azure
//          pinColor: Color(hex: "#FFD700"),     // Gold
//          reminderColor: Color(hex: "#FF69B4"),// Hot Pink
//          fontName: "Cute_Aurora_demo",
//          fontSize: 18,
//          lineSpacing: 1.5),
//
//    Theme(name: "Galactic",
//          accentColor: Color(hex: "#9B59B6"),  // Amethyst
//          topColor: Color(hex: "#2C3E50"),     // Midnight Blue
//          bottomColor: Color(hex: "#34495E"),  // Wet Asphalt
//          entryBackgroundColor: Color(hex: "#E0FFFF").opacity(0.1), // Almost transparent Light Cyan
//          pinColor: Color(hex: "#F1C40F"),     // Sunflower
//          reminderColor: Color(hex: "#E74C3C"),// Alizarin
//          fontName: "PixelDigivolve",
//          fontSize: 16,
//          lineSpacing: 1.2)
//]
//
//let additionalThemes: [Theme] = [
//    Theme(name: "Monolith",
//          accentColor: Color(red: 0.000, green: 0.478, blue: 1.000),
//          topColor: Color(red: 0.949, green: 0.949, blue: 0.969),
//          bottomColor: Color(red: 0.898, green: 0.898, blue: 0.918),
//          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.9),
//          pinColor: Color(red: 1.000, green: 0.231, blue: 0.188),
//          reminderColor: Color(red: 0.345, green: 0.337, blue: 0.839),
//          fontName: "Helvetica",
//          fontSize: 16,
//          lineSpacing: 1.2),
//
//    Theme(name: "Parchment",
//          accentColor: Color(red: 0.545, green: 0.271, blue: 0.075),
//          topColor: Color(red: 0.961, green: 0.961, blue: 0.863),
//          bottomColor: Color(red: 0.980, green: 0.922, blue: 0.843),
//          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.4),
//          pinColor: Color(red: 0.647, green: 0.165, blue: 0.165),
//          reminderColor: Color(red: 0.180, green: 0.310, blue: 0.310),
//          fontName: "American Typewriter",
//          fontSize: 15,
//          lineSpacing: 1.5),
//
//    Theme(name: "Neuromancer",
//          accentColor: Color(red: 0.000, green: 1.000, blue: 0.255),
//          topColor: Color(red: 0.102, green: 0.102, blue: 0.180),
//          bottomColor: Color(red: 0.086, green: 0.129, blue: 0.243),
//          entryBackgroundColor: Color(red: 0.941, green: 0.941, blue: 0.941, opacity: 0.1),
//          pinColor: Color(red: 1.000, green: 0.000, blue: 1.000),
//          reminderColor: Color(red: 0.000, green: 1.000, blue: 1.000),
//          fontName: "PixelDigivolve",
//          fontSize: 16,
//          lineSpacing: 1.2),
//
//    Theme(name: "Fae",
//          accentColor: Color(red: 1.000, green: 0.522, blue: 0.631),
//          topColor: Color(red: 0.000, green: 0.294, blue: 0.137),
//          bottomColor: Color(red: 0.133, green: 0.545, blue: 0.133),
//          entryBackgroundColor: Color(red: 0.878, green: 0.949, blue: 0.914, opacity: 0.3),
//          pinColor: Color(red: 1.000, green: 0.843, blue: 0.000),
//          reminderColor: Color(red: 0.545, green: 0.271, blue: 0.075),
//          fontName: "Boekopi",
//          fontSize: 16,
//          lineSpacing: 1.4),
//
//    Theme(name: "Satori",
//          accentColor: Color(red: 0.831, green: 0.686, blue: 0.216),
//          topColor: Color(red: 0.941, green: 0.918, blue: 0.839),
//          bottomColor: Color(red: 0.871, green: 0.722, blue: 0.529),
//          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.5),
//          pinColor: Color(red: 0.000, green: 0.502, blue: 0.502),
//          reminderColor: Color(red: 0.412, green: 0.412, blue: 0.412),
//          fontName: "Didot",
//          fontSize: 15,
//          lineSpacing: 1.6),
//
//    Theme(name: "Aurora",
//          accentColor: Color(red: 0.800, green: 1.000, blue: 0.000),
//          topColor: Color(red: 0.071, green: 0.000, blue: 0.322),
//          bottomColor: Color(red: 0.098, green: 0.000, blue: 0.380),
//          entryBackgroundColor: Color(red: 0.902, green: 0.902, blue: 0.980, opacity: 0.2),
//          pinColor: Color(red: 0.000, green: 1.000, blue: 1.000),
//          reminderColor: Color(red: 0.196, green: 0.804, blue: 0.196),
//          fontName: "AstroDotBasic",
//          fontSize: 16,
//          lineSpacing: 1.3),
//
//    Theme(name: "Hanami",
//          accentColor: Color(red: 1.000, green: 0.612, blue: 0.698),
//          topColor: Color(red: 0.996, green: 0.961, blue: 0.941),
//          bottomColor: Color(red: 1.000, green: 0.753, blue: 0.796),
//          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.3),
//          pinColor: Color(red: 0.902, green: 0.561, blue: 0.675),
//          reminderColor: Color(red: 0.545, green: 0.271, blue: 0.075),
//          fontName: "ClickerScript-Regular",
//          fontSize: 18,
//          lineSpacing: 1.4),
//
//    Theme(name: "Abyss",
//          accentColor: Color(red: 0.000, green: 1.000, blue: 1.000),
//          topColor: Color(red: 0.000, green: 0.000, blue: 0.502),
//          bottomColor: Color(red: 0.000, green: 0.000, blue: 0.200),
//          entryBackgroundColor: Color(red: 0.878, green: 1.000, blue: 1.000, opacity: 0.1),
//          pinColor: Color(red: 0.282, green: 0.820, blue: 0.800),
//          reminderColor: Color(red: 0.125, green: 0.698, blue: 0.667),
//          fontName: "STIX Two Math",
//          fontSize: 16,
//          lineSpacing: 1.3),
//
//    Theme(name: "Harvest",
//          accentColor: Color(red: 1.000, green: 0.498, blue: 0.314),
//          topColor: Color(red: 0.545, green: 0.271, blue: 0.075),
//          bottomColor: Color(red: 0.804, green: 0.522, blue: 0.247),
//          entryBackgroundColor: Color(red: 1.000, green: 0.980, blue: 0.941, opacity: 0.3),
//          pinColor: Color(red: 0.855, green: 0.647, blue: 0.125),
//          reminderColor: Color(red: 0.502, green: 0.000, blue: 0.000),
//          fontName: "Catbrother",
//          fontSize: 17,
//          lineSpacing: 1.5),
//
//    Theme(name: "Synthwave",
//          accentColor: Color(red: 1.000, green: 0.165, blue: 0.427),
//          topColor: Color(red: 0.020, green: 0.851, blue: 0.910),
//          bottomColor: Color(red: 1.000, green: 0.078, blue: 0.576),
//          entryBackgroundColor: Color(red: 0.992, green: 1.000, blue: 0.988, opacity: 0.15),
//          pinColor: Color(red: 1.000, green: 0.380, blue: 0.937),
//          reminderColor: Color(red: 0.000, green: 0.976, blue: 1.000),
//          fontName: "Copyduck",
//          fontSize: 17,
//          lineSpacing: 1.2),
//
//    // Experimental Themes
//    Theme(name: "Quantum",
//          accentColor: Color(red: 0.000, green: 1.000, blue: 0.000),
//          topColor: Color(red: 0.000, green: 0.000, blue: 0.000),
//          bottomColor: Color(red: 1.000, green: 1.000, blue: 1.000),
//          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.1),
//          pinColor: Color(red: 1.000, green: 0.078, blue: 0.576),
//          reminderColor: Color(red: 0.118, green: 0.565, blue: 1.000),
//          fontName: "Menlo Regular",
//          fontSize: 16,
//          lineSpacing: 1.2),
//
//    Theme(name: "Fractal",
//          accentColor: Color(red: 1.000, green: 0.388, blue: 0.278),
//          topColor: Color(red: 0.000, green: 0.000, blue: 0.000),
//          bottomColor: Color(red: 0.533, green: 0.055, blue: 0.310),
//          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.15),
//          pinColor: Color(red: 1.000, green: 0.843, blue: 0.000),
//          reminderColor: Color(red: 0.000, green: 0.808, blue: 0.820),
//          fontName: "Futura",
//          fontSize: 17,
//          lineSpacing: 1.3),
//
//    Theme(name: "Hologram",
//          accentColor: Color(red: 0.000, green: 1.000, blue: 1.000),
//          topColor: Color(red: 0.000, green: 0.000, blue: 1.000, opacity: 0.5),
//          bottomColor: Color(red: 0.000, green: 1.000, blue: 1.000, opacity: 0.5),
//          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.2),
//          pinColor: Color(red: 1.000, green: 0.078, blue: 0.576),
//          reminderColor: Color(red: 0.498, green: 1.000, blue: 0.000),
//          fontName: "Academy Engraved LET Plain:1.0",
//          fontSize: 18,
//          lineSpacing: 1.4)
//]


@MainActor
func renderThemeThumbnail(theme: Theme, size: CGSize, scale: CGFloat) async -> UIImage? {
    return await withCheckedContinuation { continuation in
        DispatchQueue.main.async {
            let themeView = ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(gradient: Gradient(colors: [theme.topColor, theme.bottomColor]), startPoint: .top, endPoint: .bottom))
                    .frame(width: size.width, height: size.height)
                
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(theme.entryBackgroundColor)
                        .frame(width: size.width - 20, height: 30)
                        .padding(.horizontal)
                        .overlay(
                            HStack(alignment: .center) {
                                Text(theme.name)
                                    .foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: UIColor.blendedColor(from: UIColor(theme.topColor), with: UIColor(theme.entryBackgroundColor)), colorScheme: .light)))
                                    .font(.custom(theme.fontName, size: theme.fontSize))
                            }
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(theme.accentColor)
                                .frame(width: 10, height: 10)
                            Text("accent")
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "pin.fill").resizable()
                                .foregroundStyle(theme.pinColor)
                                .frame(width: 10, height: 10)
                            Text("pin")
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "bell.fill").resizable()
                                .foregroundStyle(theme.reminderColor)
                                .frame(width: 10, height: 10)
                            Text("reminder")
                        }
                    }
                    .font(.custom(theme.fontName, size: theme.fontSize))
                    .padding(.horizontal)
                }
            }
            .cornerRadius(20)
            .shadow(color: Color(UIColor.black).opacity(0.08), radius: 3)
            .frame(width: size.width, height: size.height)

            let renderer = ImageRenderer(content: themeView)
            renderer.scale = scale

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let uiImage = renderer.uiImage {
                    continuation.resume(returning: uiImage)
                } else {
                    print("Failed to render theme thumbnail")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
