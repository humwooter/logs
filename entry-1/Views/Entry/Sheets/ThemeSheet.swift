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

struct ThemeSheet: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager

    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(
          entity: UserTheme.entity(),
          sortDescriptors: []
      ) var savedThemes: FetchedResults<UserTheme>
    
    @State var selectedTheme: UserTheme?
    @State private var editTheme = false
    private var isEditThemeActive: Binding<Bool> {
           Binding<Bool>(
               get: {
                   selectedTheme != nil && editTheme
               },
               set: { newValue in
                   // This setter can be used to control editTheme and selectedTheme state
                   if !newValue {
                       editTheme = false
                       selectedTheme = nil
                   }
               }
           )
       }
    
    var body: some View {
        ScrollView {
            customThemesView()
            defaultThemesView()
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
        .sheet(isPresented: isEditThemeActive) {
            EditUserThemeView(userTheme: $selectedTheme)
                .environmentObject(coreDataManager)
                .environmentObject(userPreferences)
        }
    }
    @ViewBuilder
    func currentThemeView() -> some View {
        let currentTheme = Theme(
            name: "Current Theme",
            accentColor: userPreferences.accentColor,
            topColor: userPreferences.backgroundColors.first ?? .clear,
            bottomColor: userPreferences.backgroundColors.last ?? .clear,
            entryBackgroundColor: userPreferences.entryBackgroundColor,
            pinColor: userPreferences.pinColor,
            reminderColor: userPreferences.reminderColor,
            fontName: userPreferences.fontName,
            fontSize: userPreferences.fontSize,
            lineSpacing: userPreferences.lineSpacing
        )
        themeView(theme: currentTheme)
        .contextMenu {
            Button("Save") {
                let userTheme = UserTheme(context: coreDataManager.viewContext)
                userTheme.fromTheme(currentTheme)
                do {
                    try coreDataManager.viewContext.save()
                } catch {
                    print("Failed to save theme: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @ViewBuilder
    func customThemesView() -> some View {
        Text("Custom Themes").font(.headline)
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            currentThemeView()
            ForEach(savedThemes, id: \.id) { userTheme in
                let theme = userTheme.toTheme()
                themeView(theme: theme).contextMenu {
                    Button("Apply") {
                        userPreferences.applyTheme(theme)
                    }
                    Button("Edit") {
                        selectedTheme = userTheme
                        editTheme = true
                    }
                    
                    Button("Delete") {
                        do {
                            try coreDataManager.viewContext.delete(userTheme)
                            try coreDataManager.viewContext.save()
                        } catch {
                            print("Failed to save theme: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    func defaultThemesView() -> some View {
        Text("Default Themes").font(.headline)
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(refinedThemes) { theme in
                themeView(theme: theme).contextMenu {
                    Button("Apply") {
                        userPreferences.applyTheme(theme)
                    }
                }
            }
        }
        .padding()
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
        .shadow(color: Color(UIColor.fontColor(forBackgroundColor: UIColor.blendedColor(from: UIColor(userPreferences.backgroundColors.first ?? Color.clear), with: UIColor(userPreferences.backgroundColors[1])))).opacity(0.2), radius: 5)
        
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
