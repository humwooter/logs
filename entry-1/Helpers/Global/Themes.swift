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
    Theme(name: "Neotopia",
          accentColor: Color(hex: "#00FF41"),  // Neon Green
          topColor: Color(hex: "#0C0032"),     // Oxford Blue
          bottomColor: Color(hex: "#190061"),  // Duke Blue
          entryBackgroundColor: Color(hex: "#E6FFF2").opacity(0.15), // Transparent Mint Cream
          pinColor: Color(hex: "#FF00FF"),     // Magenta
          reminderColor: Color(hex: "#00FFFF"),// Cyan
          fontName: "Menlo Regular",
          fontSize: 16,
          lineSpacing: 1.2),

    Theme(name: "Aether",
          accentColor: Color(hex: "#FF85E7"),  // Pale Magenta
          topColor: Color(hex: "#2E0854"),     // Deep Purple
          bottomColor: Color(hex: "#5E60CE"),  // Slate Blue
          entryBackgroundColor: Color(hex: "#F0E6FF").opacity(0.2), // Transparent Light Lavender
          pinColor: Color(hex: "#80FFDB"),     // Aquamarine
          reminderColor: Color(hex: "#FFD700"),// Gold
          fontName: "Snell Roundhand",
          fontSize: 18,
          lineSpacing: 1.5),

    Theme(name: "Mirage",
          accentColor: Color(hex: "#FF6B35"),  // Orange Red
          topColor: Color(hex: "#FFCB69"),     // Mellow Yellow
          bottomColor: Color(hex: "#FFA177"),  // Light Salmon
          entryBackgroundColor: Color(hex: "#FFF1E6").opacity(0.4), // Transparent Linen
          pinColor: Color(hex: "#00A8E8"),     // Cerulean
          reminderColor: Color(hex: "#662E9B"),// Purple Heart
          fontName: "Papyrus Condensed",
          fontSize: 17,
          lineSpacing: 1.3),

    Theme(name: "Faerial",
          accentColor: Color(hex: "#FF85A1"),  // Light Coral
          topColor: Color(hex: "#004B23"),     // Dark Green
          bottomColor: Color(hex: "#2D6A4F"),  // Amazon
          entryBackgroundColor: Color(hex: "#E9FFE1").opacity(0.3), // Transparent Honeydew
          pinColor: Color(hex: "#FFD700"),     // Gold
          reminderColor: Color(hex: "#9370DB"),// Medium Purple
          fontName: "Boekopi",
          fontSize: 16,
          lineSpacing: 1.4),

    Theme(name: "Synthwave",
          accentColor: Color(hex: "#FF2A6D"),  // Red-Pink
          topColor: Color(hex: "#05D9E8"),     // Bright Cyan
          bottomColor: Color(hex: "#005678"),  // Strong Blue
          entryBackgroundColor: Color(hex: "#FDFFFC").opacity(0.15), // Almost transparent white
          pinColor: Color(hex: "#FF61EF"),     // Light Hot Pink
          reminderColor: Color(hex: "#FFF700"),// Lemon Yellow
          fontName: "Copyduck",
          fontSize: 17,
          lineSpacing: 1.2),

    Theme(name: "Serenity",
          accentColor: Color(hex: "#D4AF37"),  // Metallic Gold
          topColor: Color(hex: "#E0E2DB"),     // Platinum
          bottomColor: Color(hex: "#D2CDC0"),  // Timberwolf
          entryBackgroundColor: Color(hex: "#FCFBF7").opacity(0.5), // Semi-transparent Off-White
          pinColor: Color(hex: "#4A5859"),     // Outer Space
          reminderColor: Color(hex: "#7BA05B"),// Asparagus
          fontName: "Didot",
          fontSize: 15,
          lineSpacing: 1.6),

    Theme(name: "Aurora",
          accentColor: Color(hex: "#CCFF00"),  // Electric Lime
          topColor: Color(hex: "#120052"),     // Navy Blue
          bottomColor: Color(hex: "#3500D3"),  // Ultramarine
          entryBackgroundColor: Color(hex: "#E6E6FA").opacity(0.2), // Transparent Lavender
          pinColor: Color(hex: "#00FFFF"),     // Cyan
          reminderColor: Color(hex: "#FF1493"),// Deep Pink
          fontName: "AstroDotBasic",
          fontSize: 16,
          lineSpacing: 1.3),

    Theme(name: "Chronos",
          accentColor: Color(hex: "#B87333"),  // Copper
          topColor: Color(hex: "#2C3531"),     // Dark Slate
          bottomColor: Color(hex: "#403D39"),  // Black Olive
          entryBackgroundColor: Color(hex: "#FFFDD0").opacity(0.3), // Transparent Cream
          pinColor: Color(hex: "#CFB53B"),     // Old Gold
          reminderColor: Color(hex: "#66CDAA"),// Medium Aquamarine
          fontName: "Copperplate Light",
          fontSize: 17,
          lineSpacing: 1.4),

    Theme(name: "Aquatica",
          accentColor: Color(hex: "#FF4500"),  // Orange Red
          topColor: Color(hex: "#006994"),     // Sea Blue
          bottomColor: Color(hex: "#00BFFF"),  // Deep Sky Blue
          entryBackgroundColor: Color(hex: "#E0FFFF").opacity(0.4), // Transparent Light Cyan
          pinColor: Color(hex: "#FFD700"),     // Gold
          reminderColor: Color(hex: "#FF69B4"),// Hot Pink
          fontName: "Cute_Aurora_demo",
          fontSize: 18,
          lineSpacing: 1.5),

    Theme(name: "Cosmosis",
          accentColor: Color(hex: "#FF00FF"),  // Magenta
          topColor: Color(hex: "#0C0032"),     // Oxford Blue
          bottomColor: Color(hex: "#282828"),  // Eerie Black
          entryBackgroundColor: Color(hex: "#E6E6FA").opacity(0.1), // Almost transparent Lavender
          pinColor: Color(hex: "#00FF00"),     // Lime
          reminderColor: Color(hex: "#FFD700"),// Gold
          fontName: "PixelDigivolve",
          fontSize: 16,
          lineSpacing: 1.2)
]

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

let additionalThemes: [Theme] = [
    Theme(name: "Monolith",
          accentColor: Color(red: 0.000, green: 0.478, blue: 1.000),
          topColor: Color(red: 0.949, green: 0.949, blue: 0.969),
          bottomColor: Color(red: 0.898, green: 0.898, blue: 0.918),
          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.9),
          pinColor: Color(red: 1.000, green: 0.231, blue: 0.188),
          reminderColor: Color(red: 0.345, green: 0.337, blue: 0.839),
          fontName: "Helvetica",
          fontSize: 16,
          lineSpacing: 1.2),

    Theme(name: "Parchment",
          accentColor: Color(red: 0.545, green: 0.271, blue: 0.075),
          topColor: Color(red: 0.961, green: 0.961, blue: 0.863),
          bottomColor: Color(red: 0.980, green: 0.922, blue: 0.843),
          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.4),
          pinColor: Color(red: 0.647, green: 0.165, blue: 0.165),
          reminderColor: Color(red: 0.180, green: 0.310, blue: 0.310),
          fontName: "American Typewriter",
          fontSize: 15,
          lineSpacing: 1.5),

    Theme(name: "Neuromancer",
          accentColor: Color(red: 0.000, green: 1.000, blue: 0.255),
          topColor: Color(red: 0.102, green: 0.102, blue: 0.180),
          bottomColor: Color(red: 0.086, green: 0.129, blue: 0.243),
          entryBackgroundColor: Color(red: 0.941, green: 0.941, blue: 0.941, opacity: 0.1),
          pinColor: Color(red: 1.000, green: 0.000, blue: 1.000),
          reminderColor: Color(red: 0.000, green: 1.000, blue: 1.000),
          fontName: "PixelDigivolve",
          fontSize: 16,
          lineSpacing: 1.2),

    Theme(name: "Fae",
          accentColor: Color(red: 1.000, green: 0.522, blue: 0.631),
          topColor: Color(red: 0.000, green: 0.294, blue: 0.137),
          bottomColor: Color(red: 0.133, green: 0.545, blue: 0.133),
          entryBackgroundColor: Color(red: 0.878, green: 0.949, blue: 0.914, opacity: 0.3),
          pinColor: Color(red: 1.000, green: 0.843, blue: 0.000),
          reminderColor: Color(red: 0.545, green: 0.271, blue: 0.075),
          fontName: "Boekopi",
          fontSize: 16,
          lineSpacing: 1.4),

    Theme(name: "Satori",
          accentColor: Color(red: 0.831, green: 0.686, blue: 0.216),
          topColor: Color(red: 0.941, green: 0.918, blue: 0.839),
          bottomColor: Color(red: 0.871, green: 0.722, blue: 0.529),
          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.5),
          pinColor: Color(red: 0.000, green: 0.502, blue: 0.502),
          reminderColor: Color(red: 0.412, green: 0.412, blue: 0.412),
          fontName: "Didot",
          fontSize: 15,
          lineSpacing: 1.6),

    Theme(name: "Aurora",
          accentColor: Color(red: 0.800, green: 1.000, blue: 0.000),
          topColor: Color(red: 0.071, green: 0.000, blue: 0.322),
          bottomColor: Color(red: 0.098, green: 0.000, blue: 0.380),
          entryBackgroundColor: Color(red: 0.902, green: 0.902, blue: 0.980, opacity: 0.2),
          pinColor: Color(red: 0.000, green: 1.000, blue: 1.000),
          reminderColor: Color(red: 0.196, green: 0.804, blue: 0.196),
          fontName: "AstroDotBasic",
          fontSize: 16,
          lineSpacing: 1.3),

    Theme(name: "Hanami",
          accentColor: Color(red: 1.000, green: 0.612, blue: 0.698),
          topColor: Color(red: 0.996, green: 0.961, blue: 0.941),
          bottomColor: Color(red: 1.000, green: 0.753, blue: 0.796),
          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.3),
          pinColor: Color(red: 0.902, green: 0.561, blue: 0.675),
          reminderColor: Color(red: 0.545, green: 0.271, blue: 0.075),
          fontName: "ClickerScript-Regular",
          fontSize: 18,
          lineSpacing: 1.4),

    Theme(name: "Abyss",
          accentColor: Color(red: 0.000, green: 1.000, blue: 1.000),
          topColor: Color(red: 0.000, green: 0.000, blue: 0.502),
          bottomColor: Color(red: 0.000, green: 0.000, blue: 0.200),
          entryBackgroundColor: Color(red: 0.878, green: 1.000, blue: 1.000, opacity: 0.1),
          pinColor: Color(red: 0.282, green: 0.820, blue: 0.800),
          reminderColor: Color(red: 0.125, green: 0.698, blue: 0.667),
          fontName: "STIX Two Math",
          fontSize: 16,
          lineSpacing: 1.3),

    Theme(name: "Harvest",
          accentColor: Color(red: 1.000, green: 0.498, blue: 0.314),
          topColor: Color(red: 0.545, green: 0.271, blue: 0.075),
          bottomColor: Color(red: 0.804, green: 0.522, blue: 0.247),
          entryBackgroundColor: Color(red: 1.000, green: 0.980, blue: 0.941, opacity: 0.3),
          pinColor: Color(red: 0.855, green: 0.647, blue: 0.125),
          reminderColor: Color(red: 0.502, green: 0.000, blue: 0.000),
          fontName: "Catbrother",
          fontSize: 17,
          lineSpacing: 1.5),

    Theme(name: "Synthwave",
          accentColor: Color(red: 1.000, green: 0.165, blue: 0.427),
          topColor: Color(red: 0.020, green: 0.851, blue: 0.910),
          bottomColor: Color(red: 1.000, green: 0.078, blue: 0.576),
          entryBackgroundColor: Color(red: 0.992, green: 1.000, blue: 0.988, opacity: 0.15),
          pinColor: Color(red: 1.000, green: 0.380, blue: 0.937),
          reminderColor: Color(red: 0.000, green: 0.976, blue: 1.000),
          fontName: "Copyduck",
          fontSize: 17,
          lineSpacing: 1.2),

    // Experimental Themes
    Theme(name: "Quantum",
          accentColor: Color(red: 0.000, green: 1.000, blue: 0.000),
          topColor: Color(red: 0.000, green: 0.000, blue: 0.000),
          bottomColor: Color(red: 1.000, green: 1.000, blue: 1.000),
          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.1),
          pinColor: Color(red: 1.000, green: 0.078, blue: 0.576),
          reminderColor: Color(red: 0.118, green: 0.565, blue: 1.000),
          fontName: "Menlo Regular",
          fontSize: 16,
          lineSpacing: 1.2),

    Theme(name: "Fractal",
          accentColor: Color(red: 1.000, green: 0.388, blue: 0.278),
          topColor: Color(red: 0.000, green: 0.000, blue: 0.000),
          bottomColor: Color(red: 0.533, green: 0.055, blue: 0.310),
          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.15),
          pinColor: Color(red: 1.000, green: 0.843, blue: 0.000),
          reminderColor: Color(red: 0.000, green: 0.808, blue: 0.820),
          fontName: "Futura",
          fontSize: 17,
          lineSpacing: 1.3),

    Theme(name: "Hologram",
          accentColor: Color(red: 0.000, green: 1.000, blue: 1.000),
          topColor: Color(red: 0.000, green: 0.000, blue: 1.000, opacity: 0.5),
          bottomColor: Color(red: 0.000, green: 1.000, blue: 1.000, opacity: 0.5),
          entryBackgroundColor: Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 0.2),
          pinColor: Color(red: 1.000, green: 0.078, blue: 0.576),
          reminderColor: Color(red: 0.498, green: 1.000, blue: 0.000),
          fontName: "Academy Engraved LET Plain:1.0",
          fontSize: 18,
          lineSpacing: 1.4)
]

//let additionalThemes: [Theme] = [
//    Theme(name: "Cyberpunk Neon",
//          accentColor: Color(hex: "#00FF41"),  // Neon Green
//          topColor: Color(hex: "#1A1A2E"),     // Dark Blue
//          bottomColor: Color(hex: "#16213E"),  // Navy Blue
//          entryBackgroundColor: Color(hex: "#F0F0F0").opacity(0.1),
//          pinColor: Color(hex: "#FF00FF"),     // Magenta
//          reminderColor: Color(hex: "#00FFFF"),// Cyan
//          fontName: "Menlo Regular",
//          fontSize: 16,
//          lineSpacing: 1.2),
//
//    Theme(name: "Ethereal Dream",
//          accentColor: Color(hex: "#FF85E7"),  // Pale Magenta
//          topColor: Color(hex: "#7400B8"),     // Deep Purple
//          bottomColor: Color(hex: "#5E60CE"),  // Slate Blue
//          entryBackgroundColor: Color(hex: "#FFFFFF").opacity(0.2),
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
//          entryBackgroundColor: Color(hex: "#FFFBF1").opacity(0.4),
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
//          entryBackgroundColor: Color(hex: "#E0F2E9").opacity(0.3),
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
//          entryBackgroundColor: Color(hex: "#FDFFFC").opacity(0.15),
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
//          entryBackgroundColor: Color(hex: "#FFFFFF").opacity(0.5),
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
//          entryBackgroundColor: Color(hex: "#E6E6FA").opacity(0.2),
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
//          entryBackgroundColor: Color(hex: "#FDF5E6").opacity(0.3),
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
//          entryBackgroundColor: Color(hex: "#F0FFFF").opacity(0.4),
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
//          entryBackgroundColor: Color(hex: "#E0FFFF").opacity(0.1),
//          pinColor: Color(hex: "#F1C40F"),     // Sunflower
//          reminderColor: Color(hex: "#E74C3C"),// Alizarin
//          fontName: "PixelDigivolve",
//          fontSize: 16,
//          lineSpacing: 1.2),
//
//    // New themes start here
//    Theme(name: "Sakura Blossom",
//          accentColor: Color(hex: "#FF9CB2"),  // Cherry Blossom Pink
//          topColor: Color(hex: "#FEF5F0"),     // Pale Peach
//          bottomColor: Color(hex: "#FFE4E1"),  // Misty Rose
//          entryBackgroundColor: Color(hex: "#FFFFFF").opacity(0.3),
//          pinColor: Color(hex: "#E68FAC"),     // Rose Pink
//          reminderColor: Color(hex: "#8B4513"),// Saddle Brown (for branches)
//          fontName: "ClickerScript-Regular",
//          fontSize: 18,
//          lineSpacing: 1.4),
//
//    Theme(name: "Deep Ocean",
//          accentColor: Color(hex: "#00FFFF"),  // Cyan
//          topColor: Color(hex: "#000080"),     // Navy
//          bottomColor: Color(hex: "#191970"),  // Midnight Blue
//          entryBackgroundColor: Color(hex: "#E0FFFF").opacity(0.1),
//          pinColor: Color(hex: "#48D1CC"),     // Medium Turquoise
//          reminderColor: Color(hex: "#20B2AA"),// Light Sea Green
//          fontName: "STIX Two Math",
//          fontSize: 16,
//          lineSpacing: 1.3),
//
//    Theme(name: "Autumn Harvest",
//          accentColor: Color(hex: "#FF7F50"),  // Coral
//          topColor: Color(hex: "#8B4513"),     // Saddle Brown
//          bottomColor: Color(hex: "#D2691E"),  // Chocolate
//          entryBackgroundColor: Color(hex: "#FFFAF0").opacity(0.3),
//          pinColor: Color(hex: "#DAA520"),     // Goldenrod
//          reminderColor: Color(hex: "#800000"),// Maroon
//          fontName: "American Typewriter",
//          fontSize: 17,
//          lineSpacing: 1.5),
//
//    Theme(name: "Neon Cityscape",
//          accentColor: Color(hex: "#FF1493"),  // Deep Pink
//          topColor: Color(hex: "#000000"),     // Black
//          bottomColor: Color(hex: "#1A1A1A"),  // Very Dark Gray
//          entryBackgroundColor: Color(hex: "#FFFFFF").opacity(0.05),
//          pinColor: Color(hex: "#00FF00"),     // Lime
//          reminderColor: Color(hex: "#FF4500"),// Orange Red
//          fontName: "Impact",
//          fontSize: 16,
//          lineSpacing: 1.2),
//
//    Theme(name: "Lavender Fields",
//          accentColor: Color(hex: "#9932CC"),  // Dark Orchid
//          topColor: Color(hex: "#E6E6FA"),     // Lavender
//          bottomColor: Color(hex: "#D8BFD8"),  // Thistle
//          entryBackgroundColor: Color(hex: "#FFFFFF").opacity(0.4),
//          pinColor: Color(hex: "#DDA0DD"),     // Plum
//          reminderColor: Color(hex: "#4B0082"),// Indigo
//          fontName: "Savoye LET",
//          fontSize: 18,
//          lineSpacing: 1.6),
//
//    Theme(name: "Arctic Frost",
//          accentColor: Color(hex: "#4682B4"),  // Steel Blue
//          topColor: Color(hex: "#F0F8FF"),     // Alice Blue
//          bottomColor: Color(hex: "#E0FFFF"),  // Light Cyan
//          entryBackgroundColor: Color(hex: "#FFFFFF").opacity(0.6),
//          pinColor: Color(hex: "#87CEEB"),     // Sky Blue
//          reminderColor: Color(hex: "#1E90FF"),// Dodger Blue
//          fontName: "Futura",
//          fontSize: 16,
//          lineSpacing: 1.3),
//
//    Theme(name: "Vintage Typewriter",
//          accentColor: Color(hex: "#8B4513"),  // Saddle Brown
//          topColor: Color(hex: "#F5F5DC"),     // Beige
//          bottomColor: Color(hex: "#FAEBD7"),  // Antique White
//          entryBackgroundColor: Color(hex: "#FFFFFF").opacity(0.2),
//          pinColor: Color(hex: "#A52A2A"),     // Brown
//          reminderColor: Color(hex: "#2F4F4F"),// Dark Slate Gray
//          fontName: "Courier New",
//          fontSize: 15,
//          lineSpacing: 1.5),
//
//    Theme(name: "Mystic Twilight",
//          accentColor: Color(hex: "#9370DB"),  // Medium Purple
//          topColor: Color(hex: "#191970"),     // Midnight Blue
//          bottomColor: Color(hex: "#483D8B"),  // Dark Slate Blue
//          entryBackgroundColor: Color(hex: "#E6E6FA").opacity(0.15),
//          pinColor: Color(hex: "#DDA0DD"),     // Plum
//          reminderColor: Color(hex: "#00CED1"),// Dark Turquoise
//          fontName: "Magiera-Script",
//          fontSize: 17,
//          lineSpacing: 1.4),
//
//    Theme(name: "Tropical Paradise",
//          accentColor: Color(hex: "#FF6347"),  // Tomato
//          topColor: Color(hex: "#00CED1"),     // Dark Turquoise
//          bottomColor: Color(hex: "#20B2AA"),  // Light Sea Green
//          entryBackgroundColor: Color(hex: "#F0FFF0").opacity(0.3),
//          pinColor: Color(hex: "#FFD700"),     // Gold
//          reminderColor: Color(hex: "#FF4500"),// Orange Red
//          fontName: "Bradley Hand",
//          fontSize: 18,
//          lineSpacing: 1.5),
//
//    Theme(name: "Minimalist Mono",
//          accentColor: Color(hex: "#000000"),  // Black
//          topColor: Color(hex: "#FFFFFF"),     // White
//          bottomColor: Color(hex: "#F5F5F5"),  // White Smoke
//          entryBackgroundColor: Color(hex: "#000000").opacity(0.05),
//          pinColor: Color(hex: "#696969"),     // Dim Gray
//          reminderColor: Color(hex: "#A9A9A9"),// Dark Gray
//          fontName: "Helvetica",
//          fontSize: 16,
//          lineSpacing: 1.2)
//]
//
//let themes: [Theme] = [
//    Theme(name: "Meadow",
//          accentColor: Color(hex: "#FF6B6B"),  // Coral
//          topColor: Color(hex: "#4ECDC4"),     // Medium Turquoise
//          bottomColor: Color(hex: "#45B7A0"),  // Keppel
//          entryBackgroundColor: Color(hex: "#F7FFF7").opacity(0.9), // Mint Cream
//          pinColor: Color(hex: "#FFD93D"),     // Mustard
//          reminderColor: Color(hex: "#2F4858"),// Charcoal
//          fontName: "AvenirNext-Regular",
//          fontSize: 16,
//          lineSpacing: 1.2),
//
//    Theme(name: "Midnight",
//          accentColor: Color(hex: "#FF61D2"),  // Hot Pink
//          topColor: Color(hex: "#120458"),     // Navy Blue
//          bottomColor: Color(hex: "#2D0E36"),  // Dark Purple
//          entryBackgroundColor: Color(hex: "#F0EFF4").opacity(0.15), // Lavender Mist
//          pinColor: Color(hex: "#7BCDBA"),     // Middle Blue Green
//          reminderColor: Color(hex: "#9D94FF"),// Light Pastel Purple
//          fontName: "Futura",
//          fontSize: 17,
//          lineSpacing: 1.4),
//
//    Theme(name: "Autumn",
//          accentColor: Color(hex: "#D96941"),  // Burnt Sienna
//          topColor: Color(hex: "#FFF1E6"),     // Linen
//          bottomColor: Color(hex: "#F4A261"),  // Sandy Brown
//          entryBackgroundColor: Color(hex: "#FAE1DD").opacity(0.4), // Misty Rose
//          pinColor: Color(hex: "#2A9D8F"),     // Persian Green
//          reminderColor: Color(hex: "#264653"),// Charcoal
//          fontName: "Catbrother",
//          fontSize: 18,
//          lineSpacing: 1.5),
//
//    Theme(name: "Arctic",
//          accentColor: Color(hex: "#48CAE4"),  // Sky Blue
//          topColor: Color(hex: "#E3F2FD"),     // Alice Blue
//          bottomColor: Color(hex: "#90E0EF"),  // Light Sky Blue
//          entryBackgroundColor: Color.white.opacity(0.7),
//          pinColor: Color(hex: "#023E8A"),     // Navy Blue
//          reminderColor: Color(hex: "#0077B6"),// Strong Blue
//          fontName: "Gill Sans",
//          fontSize: 16,
//          lineSpacing: 1.3),
//
//    Theme(name: "Forest",
//          accentColor: Color(hex: "#FF9F1C"),  // Orange Peel
//          topColor: Color(hex: "#1B4332"),     // Brunswick Green
//          bottomColor: Color(hex: "#2D6A4F"),  // Amazon
//          entryBackgroundColor: Color(hex: "#D8F3DC").opacity(0.3), // Honeydew
//          pinColor: Color(hex: "#FFBF69"),     // Mellow Apricot
//          reminderColor: Color(hex: "#B7E4C7"),// Celadon
//          fontName: "Noteworthy Light",
//          fontSize: 17,
//          lineSpacing: 1.4),
//
//    Theme(name: "Neon",
//          accentColor: Color(hex: "#FF00F5"),  // Magenta
//          topColor: Color(hex: "#0C0032"),     // Oxford Blue
//          bottomColor: Color(hex: "#190061"),  // Duke Blue
//          entryBackgroundColor: Color(hex: "#FFFFFF").opacity(0.15), // White
//          pinColor: Color(hex: "#00FF41"),     // Neon Green
//          reminderColor: Color(hex: "#FDF200"),// Lemon
//          fontName: "Impact",
//          fontSize: 16,
//          lineSpacing: 1.2),
//
//    Theme(name: "Vintage",
//          accentColor: Color(hex: "#6D4C41"),  // Brown Sugar
//          topColor: Color(hex: "#F1E8E0"),     // Alabaster
//          bottomColor: Color(hex: "#D7CCC8"),  // Pale Silver
//          entryBackgroundColor: Color(hex: "#F9F5EB").opacity(0.7), // Floral White
//          pinColor: Color(hex: "#795548"),     // Bole
//          reminderColor: Color(hex: "#A1887F"),// Beaver
//          fontName: "American Typewriter",
//          fontSize: 15,
//          lineSpacing: 1.6),
//
//    Theme(name: "Pastel",
//          accentColor: Color(hex: "#FFB3BA"),  // Light Pink
//          topColor: Color(hex: "#E6E6FA"),     // Lavender
//          bottomColor: Color(hex: "#BBEEF3"),  // Light Blue
//          entryBackgroundColor: Color(hex: "#FFFFFF").opacity(0.6), // White
//          pinColor: Color(hex: "#FFF5BA"),     // Pale Yellow
//          reminderColor: Color(hex: "#B4F0A8"),// Mint Green
//          fontName: "Bradley Hand",
//          fontSize: 17,
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
