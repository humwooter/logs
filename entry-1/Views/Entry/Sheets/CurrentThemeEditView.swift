//
//  CurrentThemeEditView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/28/24.
//

import SwiftUI
import CoreData

struct CurrentThemeEditView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.presentationMode) var presentationMode

    @State private var accentColor: Color = Color.clear
    @State private var name: String = ""
    @State private var fontName: String = ""
    @State private var fontSize: CGFloat = 0
    @State private var lineSpacing: CGFloat = 0
    @State private var backgroundColor_top: Color = Color.clear
    @State private var backgroundColor_bottom: Color = Color.clear
    @State private var entryBackgroundColor: Color = Color.clear
    @State private var pinColor: Color = Color.clear
    @State private var reminderColor: Color = Color.clear
    @Environment(\.colorScheme) var colorScheme
    @State var hasInitialized: Bool = false

    var body : some View {
       
        NavigationStack {
            mainThemeView()
                .toolbar {
                    Button {
                        saveProperties()
                    } label: {
                        Label("Save", systemImage: "")
                            .foregroundStyle(accentColor)
                            .font(.customHeadline)
                    }

                }
        }
        .onAppear {
            if !hasInitialized {
                initializeProperties()
            }
        }
    }
    
    private func saveProperties() {
        userPreferences.themeName = name
        userPreferences.accentColor = accentColor
        userPreferences.fontName = fontName
        userPreferences.fontSize = fontSize
        userPreferences.lineSpacing = lineSpacing
        userPreferences.backgroundColors = [backgroundColor_top, backgroundColor_bottom]
        userPreferences.entryBackgroundColor = entryBackgroundColor
        userPreferences.pinColor = pinColor
        userPreferences.reminderColor = reminderColor
        presentationMode.wrappedValue.dismiss()
        hasInitialized = true

    }

    
    private func initializeProperties() {
        name = userPreferences.themeName
        accentColor = userPreferences.accentColor
        fontName = userPreferences.fontName
        fontSize = userPreferences.fontSize
        lineSpacing = userPreferences.lineSpacing
        backgroundColor_top = userPreferences.backgroundColors.first ?? Color.clear
        backgroundColor_bottom = userPreferences.backgroundColors[1]
        entryBackgroundColor = userPreferences.entryBackgroundColor
        pinColor = userPreferences.pinColor
        reminderColor = userPreferences.reminderColor
    }
    
    func getIdealHeaderTextColor() -> Color {
        return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(backgroundColor_top), and: UIColor(backgroundColor_bottom)), colorScheme: colorScheme))
    }
    
    @ViewBuilder
    func mainThemeView() -> some View {
        List {
            listSectionsView()
                .listRowBackground(getSectionColor(colorScheme: colorScheme))
                .foregroundStyle(getIdealHeaderTextColor())
        }
        .scrollContentBackground(.hidden)
        .font(.custom(String(fontName), size: CGFloat(Float(fontSize))))
        .background {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                LinearGradient(colors: [backgroundColor_top, backgroundColor_bottom], startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()
        }
        .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(backgroundColor_top), colorScheme: colorScheme)))
        .accentColor(accentColor)
    }
    
    @ViewBuilder
    func listSectionsView() -> some View {
        Section(header: Text("Preferences")
            .foregroundStyle(getIdealHeaderTextColor().opacity(0.5))
            .font(.customHeadline)
        ) {
            
            
            HStack {
                Text("Theme name: ")
                TextField("", text: $name)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundStyle(getIdealTextColor(topColor: backgroundColor_top, bottomColor: backgroundColor_bottom, colorScheme: colorScheme))
                Spacer()
            }
            
            ColorPicker("Accent Color", selection: $accentColor)
            FontPicker(selectedFont:  $fontName, selectedFontSize: $fontSize, accentColor: $accentColor, inputCategories: fontCategories, topColor_background: $backgroundColor_top, bottomColor_background: $backgroundColor_bottom, defaultTopColor: getDefaultBackgroundColor(colorScheme: colorScheme))
            HStack {
                Text("Line Spacing")
                Slider(value: $lineSpacing, in: 0...15, step: 1, label: { Text("Line Spacing") })
            }
        }
        
        Section {
            BackgroundColorPickerView(topColor: $backgroundColor_top, bottomColor: $backgroundColor_bottom)
        } header: {
            
            HStack {
                Text("Background Colors")
                    .foregroundStyle(getIdealHeaderTextColor().opacity(0.5))
                    .font(.customHeadline)
                Spacer()
                Label("reset", systemImage: "gobackward").foregroundStyle(.red)
                    .font(.customHeadline)
                    .onTapGesture {
                        vibration_light.impactOccurred()
                        backgroundColor_top = .clear
                        backgroundColor_bottom = .clear
                    }
            }
        }
        
        Section {
            ColorPicker("Default Entry Background Color:", selection: $entryBackgroundColor)
            
        } header: {
            HStack {
                Text("Entry Background")
                    .foregroundStyle(getIdealHeaderTextColor().opacity(0.5))
                    .font(.customHeadline)
                Spacer()
                Label("reset", systemImage: "gobackward").foregroundStyle(.red)
                    .font(.customHeadline)
                    .onTapGesture {
                        vibration_light.impactOccurred()
                        entryBackgroundColor = .clear
//                        userPreferences.entryBackgroundColor = .clear
                    }
            }
        }
        
        
        Section {
            ColorPicker("Pin Color", selection: $pinColor)
        } header: {
            HStack {
                Text("Pin Color")
                    .foregroundStyle(getIdealHeaderTextColor().opacity(0.5))
                    .font(.customHeadline)
                Spacer()
                Image(systemName: "pin.fill").foregroundStyle(pinColor)
            }
            .font(.customHeadline)
        }
        
        Section {
            ColorPicker("Reminder Color", selection: $reminderColor)
        } header: {
            HStack {
                Text("Alerts")
                    .foregroundStyle(getIdealHeaderTextColor().opacity(0.5))
                    .font(.customHeadline)
                Spacer()
                Image(systemName: "bell.fill").foregroundStyle(reminderColor)
            }
            .font(.customHeadline)
        }
    }
    
    func getSectionColor(colorScheme: ColorScheme) -> Color {
        if isClear(for: UIColor(entryBackgroundColor)) {
            return entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        } else {
            return entryBackgroundColor
        }
    }
}
