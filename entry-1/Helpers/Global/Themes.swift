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
    // Theme 14: Silver Moon
    Theme(name: "Silver Moon",
          accentColor: Color(red: 0.753, green: 0.753, blue: 0.753), // #C0C0C0 Silver
          topColor: Color(red: 0.000, green: 0.000, blue: 0.000),    // #000000 Black
          bottomColor: Color(red: 0.753, green: 0.753, blue: 0.753), // Silver
          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.2), // #FFFFFF White with opacity
          pinColor: Color(red: 1.000, green: 1.000, blue: 1.000),    // White
          reminderColor: Color(red: 0.753, green: 0.753, blue: 0.753), // Silver
          fontName: "Copperplate Light",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 15: Golden Sunset
    Theme(name: "Golden Sunset",
          accentColor: Color(red: 1.000, green: 0.843, blue: 0.000), // #FFD700 Gold
          topColor: Color(red: 0.996, green: 0.737, blue: 0.102),    // #FEBC17 Bright Orange
          bottomColor: Color(red: 0.863, green: 0.078, blue: 0.235), // #DC143C Crimson
          entryBackgroundColor: Color(red: 1.000, green: 0.894, blue: 0.769, opacity: 0.3), // #FFE4C4 Bisque
          pinColor: Color(red: 1.000, green: 0.549, blue: 0.000),    // #FF8C00 Dark Orange
          reminderColor: Color(red: 1.000, green: 0.271, blue: 0.000), // #FF4500 Orange Red
          fontName: "TrebuchetMS",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 16: Azure Sky
    Theme(name: "Azure Sky",
          accentColor: Color(red: 0.000, green: 0.498, blue: 1.000), // #007FFF Azure
          topColor: Color(red: 0.529, green: 0.808, blue: 0.922),    // #87CEEB Sky Blue
          bottomColor: Color(red: 0.000, green: 0.749, blue: 1.000), // #00BFFF Deep Sky Blue
          entryBackgroundColor: Color(red: 0.831, green: 0.925, blue: 0.969, opacity: 0.3), // #D4F2F0 Light Blue with opacity
          pinColor: Color(red: 1.000, green: 1.000, blue: 1.000),    // White
          reminderColor: Color(red: 0.000, green: 0.000, blue: 0.804), // #0000CD Medium Blue
          fontName: "AvenirNext-Regular",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 17: Rustic Earth
    Theme(name: "Rustic Earth",
          accentColor: Color(red: 0.545, green: 0.271, blue: 0.075), // #8B4513 Saddle Brown
          topColor: Color(red: 0.627, green: 0.322, blue: 0.176),    // #A0522D Sienna
          bottomColor: Color(red: 0.333, green: 0.420, blue: 0.184), // #556B2F Dark Olive Green
          entryBackgroundColor: Color(red: 0.961, green: 0.871, blue: 0.702, opacity: 0.3), // #F5DEB3 Wheat
          pinColor: Color(red: 0.545, green: 0.000, blue: 0.000),    // #8B0000 Dark Red
          reminderColor: Color(red: 0.804, green: 0.522, blue: 0.247), // #CD853F Peru
          fontName: "Georgia",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 18: Crimson Tide
    Theme(name: "Crimson Tide",
          accentColor: Color(red: 0.863, green: 0.078, blue: 0.235), // #DC143C Crimson
          topColor: Color(red: 0.545, green: 0.000, blue: 0.000),    // #8B0000 Dark Red
          bottomColor: Color(red: 0.000, green: 0.000, blue: 0.000), // Black
          entryBackgroundColor: Color(red: 0.753, green: 0.753, blue: 0.753, opacity: 0.2), // #C0C0C0 Silver with opacity
          pinColor: Color(red: 1.000, green: 1.000, blue: 1.000),    // White
          reminderColor: Color(red: 0.863, green: 0.078, blue: 0.235), // Crimson
          fontName: "Impact",
          fontSize: 17,
          lineSpacing: 1.4),
    
    // Theme 19: Arctic Ice
    Theme(name: "Arctic Ice",
          accentColor: Color(red: 0.753, green: 0.753, blue: 0.753), // #C0C0C0 Silver
          topColor: Color(red: 0.878, green: 0.925, blue: 0.957),    // #E0ECF4 Light Blue
          bottomColor: Color(red: 1.000, green: 1.000, blue: 1.000), // White
          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.2), // White with opacity
          pinColor: Color(red: 0.529, green: 0.808, blue: 0.922),    // #87CEEB Sky Blue
          reminderColor: Color(red: 0.000, green: 0.749, blue: 1.000), // #00BFFF Deep Sky Blue
          fontName: "Gill Sans",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 20: Forest Green
    Theme(name: "Forest Green",
          accentColor: Color(red: 0.000, green: 0.392, blue: 0.000), // #006400 Dark Green
          topColor: Color(red: 0.133, green: 0.545, blue: 0.133),    // #228B22 Forest Green
          bottomColor: Color(red: 0.196, green: 0.804, blue: 0.196), // #32CD32 Lime Green
          entryBackgroundColor: Color(red: 0.859, green: 0.929, blue: 0.859, opacity: 0.3), // #DBEDDB Light Green
          pinColor: Color(red: 0.545, green: 0.271, blue: 0.075),    // #8B4513 Saddle Brown
          reminderColor: Color(red: 0.000, green: 0.392, blue: 0.000), // Dark Green
          fontName: "Noteworthy Light",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 21: Midnight Blue
    Theme(name: "Midnight Blue",
          accentColor: Color(red: 0.098, green: 0.098, blue: 0.439), // #191970 Midnight Blue
          topColor: Color(red: 0.000, green: 0.000, blue: 0.000),    // Black
          bottomColor: Color(red: 0.098, green: 0.098, blue: 0.439), // Midnight Blue
          entryBackgroundColor: Color(red: 0.753, green: 0.753, blue: 0.753, opacity: 0.2), // Silver with opacity
          pinColor: Color(red: 1.000, green: 1.000, blue: 1.000),    // White
          reminderColor: Color(red: 0.416, green: 0.353, blue: 0.804), // #6A5ACD Slate Blue
          fontName: "Menlo Regular",
          fontSize: 16,
          lineSpacing: 1.4),
    
    // Theme 22: Autumn Leaves
    Theme(name: "Autumn Leaves",
          accentColor: Color(red: 0.804, green: 0.361, blue: 0.361), // #CD5C5C Indian Red
          topColor: Color(red: 0.996, green: 0.737, blue: 0.102),    // #FEBC17 Bright Orange
          bottomColor: Color(red: 0.545, green: 0.271, blue: 0.075), // Saddle Brown
          entryBackgroundColor: Color(red: 0.961, green: 0.871, blue: 0.702, opacity: 0.3), // Wheat
          pinColor: Color(red: 0.863, green: 0.078, blue: 0.235),    // Crimson
          reminderColor: Color(red: 0.804, green: 0.361, blue: 0.361), // Indian Red
          fontName: "American Typewriter",
          fontSize: 16,
          lineSpacing: 1.6),
    
    // Theme 23: Rose Gold
    Theme(name: "Rose Gold",
          accentColor: Color(red: 0.718, green: 0.427, blue: 0.565), // #B77090 Rose
          topColor: Color(red: 0.863, green: 0.627, blue: 0.478),    // #DC9F7A Light Brown
          bottomColor: Color(red: 0.718, green: 0.427, blue: 0.565), // Rose
          entryBackgroundColor: Color(red: 0.961, green: 0.871, blue: 0.702, opacity: 0.3), // Wheat
          pinColor: Color(red: 1.000, green: 0.843, blue: 0.000),    // Gold
          reminderColor: Color(red: 0.863, green: 0.627, blue: 0.478), // Light Brown
          fontName: "SavoyeLetPlain",
          fontSize: 17,
          lineSpacing: 1.5),
    
    // Theme 24: Ocean Wave
    Theme(name: "Ocean Wave",
          accentColor: Color(red: 0.000, green: 0.502, blue: 0.502), // #008080 Teal
          topColor: Color(red: 0.529, green: 0.808, blue: 0.922),    // Sky Blue
          bottomColor: Color(red: 0.000, green: 0.502, blue: 0.502), // Teal
          entryBackgroundColor: Color(red: 0.831, green: 0.925, blue: 0.969, opacity: 0.3), // Light Blue with opacity
          pinColor: Color(red: 1.000, green: 1.000, blue: 1.000),    // White
          reminderColor: Color(red: 0.000, green: 0.749, blue: 1.000), // Deep Sky Blue
          fontName: "Futura",
          fontSize: 16,
          lineSpacing: 1.4),
    
    // Theme 25: Sand Dune
    Theme(name: "Sand Dune",
          accentColor: Color(red: 0.824, green: 0.706, blue: 0.549), // #D2B48C Tan
          topColor: Color(red: 0.961, green: 0.871, blue: 0.702),    // Wheat
          bottomColor: Color(red: 0.824, green: 0.706, blue: 0.549), // Tan
          entryBackgroundColor: Color(red: 0.961, green: 0.871, blue: 0.702, opacity: 0.3), // Wheat with opacity
          pinColor: Color(red: 0.545, green: 0.271, blue: 0.075),    // Saddle Brown
          reminderColor: Color(red: 0.627, green: 0.322, blue: 0.176), // Sienna
          fontName: "Superclarendon Regular",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 26: Cherry Blossom
    Theme(name: "Cherry Blossom",
          accentColor: Color(red: 1.000, green: 0.714, blue: 0.757), // #FFB6C1 Light Pink
          topColor: Color(red: 1.000, green: 0.753, blue: 0.796),    // #FFC0CB Pink
          bottomColor: Color(red: 1.000, green: 0.894, blue: 0.961), // #FFE4E1 Misty Rose
          entryBackgroundColor: Color(red: 1.000, green: 0.937, blue: 0.961, opacity: 0.3), // #FFF0F5 Lavender Blush with opacity
          pinColor: Color(red: 0.196, green: 0.804, blue: 0.196),    // #32CD32 Lime Green
          reminderColor: Color(red: 1.000, green: 0.714, blue: 0.757), // Light Pink
          fontName: "Lilly",
          fontSize: 17,
          lineSpacing: 1.5),
    
    // Theme 27: Stormy Night
    Theme(name: "Stormy Night",
          accentColor: Color(red: 0.184, green: 0.310, blue: 0.310), // #2F4F4F Dark Slate Gray
          topColor: Color(red: 0.169, green: 0.169, blue: 0.169),    // #2B2B2B Dark Gray
          bottomColor: Color(red: 0.098, green: 0.098, blue: 0.439), // Midnight Blue
          entryBackgroundColor: Color(red: 0.753, green: 0.753, blue: 0.753, opacity: 0.2), // Silver with opacity
          pinColor: Color(red: 0.416, green: 0.353, blue: 0.804),    // Slate Blue
          reminderColor: Color(red: 0.502, green: 0.000, blue: 0.502), // #800080 Purple
          fontName: "Menlo Regular",
          fontSize: 16,
          lineSpacing: 1.4),
    
    // Theme 28: Sunflower
    Theme(name: "Sunflower",
          accentColor: Color(red: 1.000, green: 0.843, blue: 0.000), // Gold
          topColor: Color(red: 0.933, green: 0.910, blue: 0.667),    // #EEE8AA Pale Goldenrod
          bottomColor: Color(red: 0.196, green: 0.804, blue: 0.196), // Lime Green
          entryBackgroundColor: Color(red: 0.965, green: 0.871, blue: 0.702, opacity: 0.3), // Wheat
          pinColor: Color(red: 0.545, green: 0.271, blue: 0.075),    // Saddle Brown
          reminderColor: Color(red: 1.000, green: 0.843, blue: 0.000), // Gold
          fontName: "SunnySpellsBasic-Regular",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 29: Lavender Fields
    Theme(name: "Lavender Fields",
          accentColor: Color(red: 0.729, green: 0.333, blue: 0.827), // #BA55D3 Medium Orchid
          topColor: Color(red: 0.792, green: 0.608, blue: 0.827),    // #CA9EC4 Light Purple
          bottomColor: Color(red: 0.529, green: 0.808, blue: 0.922), // Sky Blue
          entryBackgroundColor: Color(red: 0.902, green: 0.902, blue: 0.980, opacity: 0.3), // Lavender
          pinColor: Color(red: 0.541, green: 0.169, blue: 0.886),    // #8A2BE2 Blue Violet
          reminderColor: Color(red: 0.933, green: 0.510, blue: 0.933), // Violet
          fontName: "Noteworthy Light",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 30: Coral Reef
    Theme(name: "Coral Reef",
          accentColor: Color(red: 1.000, green: 0.498, blue: 0.314), // #FF7F50 Coral
          topColor: Color(red: 0.282, green: 0.820, blue: 0.800),    // #48D1CC Medium Turquoise
          bottomColor: Color(red: 0.529, green: 0.808, blue: 0.922), // Sky Blue
          entryBackgroundColor: Color(red: 0.831, green: 0.925, blue: 0.969, opacity: 0.3), // Light Blue with opacity
          pinColor: Color(red: 1.000, green: 0.412, blue: 0.706),    // #FF69B4 Hot Pink
          reminderColor: Color(red: 0.282, green: 0.820, blue: 0.800), // Medium Turquoise
          fontName: "Bradley Hand",
          fontSize: 17,
          lineSpacing: 1.5),
    
    // Theme 31: Sapphire
    Theme(name: "Sapphire",
          accentColor: Color(red: 0.059, green: 0.322, blue: 0.729), // #0F52BA Sapphire Blue
          topColor: Color(red: 0.000, green: 0.000, blue: 0.502),    // #000080 Navy
          bottomColor: Color(red: 0.098, green: 0.098, blue: 0.439), // Midnight Blue
          entryBackgroundColor: Color(red: 0.753, green: 0.753, blue: 0.753, opacity: 0.2), // Silver with opacity
          pinColor: Color(red: 1.000, green: 1.000, blue: 1.000),    // White
          reminderColor: Color(red: 0.000, green: 0.000, blue: 0.545), // #00008B Dark Blue
          fontName: "Arial Rounded MT Bold",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 32: Emerald Isle
    Theme(name: "Emerald Isle",
          accentColor: Color(red: 0.000, green: 0.502, blue: 0.000), // #008000 Green
          topColor: Color(red: 0.235, green: 0.702, blue: 0.443),    // #3BB371 Medium Sea Green
          bottomColor: Color(red: 0.000, green: 0.392, blue: 0.000), // Dark Green
          entryBackgroundColor: Color(red: 0.859, green: 0.929, blue: 0.859, opacity: 0.3), // Light Green with opacity
          pinColor: Color(red: 1.000, green: 0.843, blue: 0.000),    // Gold
          reminderColor: Color(red: 0.000, green: 0.502, blue: 0.000), // Green
          fontName: "Georgia",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 33: Fire and Ice
    Theme(name: "Fire and Ice",
          accentColor: Color(red: 1.000, green: 0.271, blue: 0.000), // #FF4500 Orange Red
          topColor: Color(red: 0.118, green: 0.565, blue: 1.000),    // #1E90FF Dodger Blue
          bottomColor: Color(red: 1.000, green: 0.549, blue: 0.000), // #FF8C00 Dark Orange
          entryBackgroundColor: Color(red: 0.878, green: 0.925, blue: 0.957, opacity: 0.3), // Light Blue with opacity
          pinColor: Color(red: 1.000, green: 1.000, blue: 1.000),    // White
          reminderColor: Color(red: 1.000, green: 0.271, blue: 0.000), // Orange Red
          fontName: "Impact",
          fontSize: 17,
          lineSpacing: 1.4),
    
    // Theme 34: Cocoa Delight
    Theme(name: "Cocoa Delight",
          accentColor: Color(red: 0.396, green: 0.263, blue: 0.129), // #654321 Dark Brown
          topColor: Color(red: 0.545, green: 0.271, blue: 0.075),    // Saddle Brown
          bottomColor: Color(red: 0.627, green: 0.322, blue: 0.176), // Sienna
          entryBackgroundColor: Color(red: 0.961, green: 0.871, blue: 0.702, opacity: 0.3), // Wheat
          pinColor: Color(red: 0.824, green: 0.706, blue: 0.549),    // Tan
          reminderColor: Color(red: 0.545, green: 0.271, blue: 0.075), // Saddle Brown
          fontName: "STIX Two Math",
          fontSize: 16,
          lineSpacing: 1.5),
    
    // Theme 35: Royal Purple
    Theme(name: "Royal Purple",
          accentColor: Color(red: 0.416, green: 0.353, blue: 0.804), // #6A5ACD Slate Blue
          topColor: Color(red: 0.541, green: 0.169, blue: 0.886),    // #8A2BE2 Blue Violet
          bottomColor: Color(red: 0.294, green: 0.000, blue: 0.510), // #4B0082 Indigo
          entryBackgroundColor: Color(red: 0.902, green: 0.902, blue: 0.980, opacity: 0.3), // Lavender with opacity
          pinColor: Color(red: 1.000, green: 0.843, blue: 0.000),    // Gold
          reminderColor: Color(red: 0.416, green: 0.353, blue: 0.804), // Slate Blue
          fontName: "Didot",
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
