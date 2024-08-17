//
//  ThemeSheet.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/17/24.
//

import SwiftUI
import Foundation

struct Theme: Identifiable {
    let id = UUID()
    var name: String
    var accentColor: Color
    var topColor: Color
    var bottomColor: Color
    var entryBackgroundColor: Color
    var pinColor: Color
    var reminderColor: Color
    var fontName: String
    var fontSize: CGFloat
    var lineSpacing: CGFloat
}

let themes: [Theme] = [
    Theme(name: "Meadow",
          accentColor: Color(hex: "#FF6B6B"),
          topColor: Color(hex: "#4ECDC4"),
          bottomColor: Color(hex: "#45B7A0"),
          entryBackgroundColor: Color.white.opacity(0.7),
          pinColor: Color(hex: "#FFD93D"),
          reminderColor: Color(hex: "#FF8C42"),
          fontName: "AvenirNext-Regular",
          fontSize: 16,
          lineSpacing: 1.2),

    Theme(name: "Midnight",
          accentColor: Color(hex: "#FF61D2"),
          topColor: Color(hex: "#200F21"),
          bottomColor: Color(hex: "#382039"),
          entryBackgroundColor: Color(hex: "#553555").opacity(0.4),
          pinColor: Color(hex: "#FF9DE2"),
          reminderColor: Color(hex: "#A16AE8"),
          fontName: "Futura",
          fontSize: 17,
          lineSpacing: 1.4),

    Theme(name: "Autumn",
          accentColor: Color(hex: "#D96941"),
          topColor: Color(hex: "#F2E8CF"),
          bottomColor: Color(hex: "#F4A261"),
          entryBackgroundColor: Color(hex: "#E9C46A").opacity(0.2),
          pinColor: Color(hex: "#E76F51"),
          reminderColor: Color(hex: "#2A9D8F"),
          fontName: "Catbrother",
          fontSize: 18,
          lineSpacing: 1.5),

    Theme(name: "Arctic",
          accentColor: Color(hex: "#48CAE4"),
          topColor: Color(hex: "#CAF0F8"),
          bottomColor: Color(hex: "#90E0EF"),
          entryBackgroundColor: Color.white.opacity(0.5),
          pinColor: Color(hex: "#023E8A"),
          reminderColor: Color(hex: "#0077B6"),
          fontName: "Gill Sans",
          fontSize: 16,
          lineSpacing: 1.3),

    Theme(name: "Forest",
          accentColor: Color(hex: "#FF9F1C"),
          topColor: Color(hex: "#2B9348"),
          bottomColor: Color(hex: "#007F5F"),
          entryBackgroundColor: Color(hex: "#55A630").opacity(0.15),
          pinColor: Color(hex: "#FFBF69"),
          reminderColor: Color(hex: "#CBF3F0"),
          fontName: "Noteworthy Light",
          fontSize: 17,
          lineSpacing: 1.4),

    Theme(name: "Neon",
          accentColor: Color(hex: "#FF00F5"),
          topColor: Color(hex: "#0C0032"),
          bottomColor: Color(hex: "#190061"),
          entryBackgroundColor: Color(hex: "#3500D3").opacity(0.3),
          pinColor: Color(hex: "#00FF41"),
          reminderColor: Color(hex: "#FDF200"),
          fontName: "Impact",
          fontSize: 16,
          lineSpacing: 1.2),

    Theme(name: "Vintage",
          accentColor: Color(hex: "#6D4C41"),
          topColor: Color(hex: "#EFEBE9"),
          bottomColor: Color(hex: "#D7CCC8"),
          entryBackgroundColor: Color(hex: "#BCAAA4").opacity(0.2),
          pinColor: Color(hex: "#795548"),
          reminderColor: Color(hex: "#8D6E63"),
          fontName: "American Typewriter",
          fontSize: 15,
          lineSpacing: 1.6),

    Theme(name: "Pastel",
          accentColor: Color(hex: "#FFD1DC"), // Light pink
          topColor: Color(hex: "#E6E6FA"),    // Lavender
          bottomColor: Color(hex: "#B0E0E6"), // Powder blue
          entryBackgroundColor: Color.white.opacity(0.6),
          pinColor: Color(hex: "#FFD700"),    // Gold
          reminderColor: Color(hex: "#98FB98"),// Pale green
          fontName: "Bradley Hand",
          fontSize: 17,
          lineSpacing: 1.4)
]

struct ThemeSheet: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(themes) { theme in
                    themeView(theme: theme).contextMenu {
                        Button("Apply") {
                            userPreferences.applyTheme(theme)
                        }
                    }
                }
            }
            .padding()
        }
        .background {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()
        }
        .scrollContentBackground(.hidden)
        .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
        .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
        .accentColor(userPreferences.accentColor)
    }
    
    @ViewBuilder
    func themeView(theme: Theme) -> some View {
        ZStack {
            // Larger square
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(gradient: Gradient(colors: [theme.topColor, theme.bottomColor]), startPoint: .top, endPoint: .bottom))
                .frame(width: 150, height: 150)  // Entire square block
            
            VStack(alignment: .leading, spacing: 8) {
                // Small cube for entry background
                RoundedRectangle(cornerRadius: 10)
                    .fill(theme.entryBackgroundColor)
                    .frame(width: 130, height: 30)  // Adjusted to fit better within the square
                    .padding(.horizontal)
                    .overlay(
                        HStack(alignment: .center) {
                            Text(theme.name)
                                .foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: UIColor.blendedColor(from: UIColor(theme.topColor), with: UIColor(theme.entryBackgroundColor)), colorScheme: colorScheme)))
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
        .cornerRadius(20)  // Rounded corners for the entire block
        .shadow(radius: 5)
    }
}


extension UserPreferences {
    func applyTheme(_ theme: Theme) {
           self.accentColor = theme.accentColor
           self.backgroundColors = [theme.topColor, theme.bottomColor]
           self.entryBackgroundColor = theme.entryBackgroundColor
           self.pinColor = theme.pinColor
           self.reminderColor = theme.reminderColor
           self.fontName = theme.fontName
           self.fontSize = theme.fontSize
           self.lineSpacing = theme.lineSpacing
       }
}
