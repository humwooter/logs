//
//  EditUserThemeView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/17/24.
//
import SwiftUI
import CoreData
import SwiftUI
import CoreData
struct EditUserThemeView: View {
    @Binding var userTheme: UserTheme?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences

    // Create a temporary Theme object to work with during the editing session
    @State private var theme: Theme

    init(userTheme: Binding<UserTheme?>) {
        self._userTheme = userTheme
        if let unwrappedUserTheme = userTheme.wrappedValue {
            _theme = State(initialValue: unwrappedUserTheme.toTheme())
        } else {
            _theme = State(initialValue: Theme(
                name: "Default Theme",
                accentColor: .blue,
                topColor: .white,
                bottomColor: .black,
                entryBackgroundColor: .gray,
                pinColor: .red,
                reminderColor: .orange,
                fontName: "Helvetica",
                fontSize: 16.0,
                lineSpacing: 1.0
            ))
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Preferences")
                    .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))
                    .font(.system(size: UIFont.systemFontSize))
                ) {
                    ColorPicker("Accent Color", selection: $theme.accentColor)
                    FontPicker(
                        selectedFont: $theme.fontName,
                        selectedFontSize: $theme.fontSize,
                        accentColor: $theme.accentColor,
                        inputCategories: fontCategories,
                        topColor_background: $theme.topColor,
                        bottomColor_background: $theme.bottomColor,
                        defaultTopColor: getDefaultBackgroundColor(colorScheme: colorScheme)
                    )
                    HStack {
                        Text("Line Spacing")
                        Slider(value: $theme.lineSpacing, in: 0...15, step: 1, label: { Text("Line Spacing") })
                    }
                }
                
                Section {
                    BackgroundColorPickerView(topColor: $theme.topColor, bottomColor: $theme.bottomColor)
                } header: {
                    HStack {
                        Text("Background Colors")
                            .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))                        .font(.system(size: UIFont.systemFontSize))
                        Spacer()
                        Label("reset", systemImage: "gobackward").foregroundStyle(.red).font(.system(size: UIFont.systemFontSize))
                            .onTapGesture {
                                vibration_light.impactOccurred()
                                theme.topColor = .clear
                                theme.bottomColor = .clear
                            }
                    }
                }
                
                Section {
                    ColorPicker("Default Entry Background Color:", selection: $theme.entryBackgroundColor)
                } header: {
                    HStack {
                        Text("Entry Background")
                            .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))                        .font(.system(size: UIFont.systemFontSize))
                        Spacer()
                        Label("reset", systemImage: "gobackward").foregroundStyle(.red).font(.system(size: UIFont.systemFontSize))
                            .onTapGesture {
                                vibration_light.impactOccurred()
                                theme.entryBackgroundColor = .clear
                            }
                    }
                }
                
                Section {
                    ColorPicker("Pin Color", selection: $theme.pinColor)
                } header: {
                    HStack {
                        Text("Pin Color")
                            .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))                        .font(.system(size: UIFont.systemFontSize))
                        Spacer()
                        Image(systemName: "pin.fill").foregroundStyle(theme.pinColor)
                    }.font(.system(size: UIFont.systemFontSize))
                }
                
                Section {
                    ColorPicker("Reminder Color", selection: $theme.reminderColor)
                } header: {
                    HStack {
                        Text("Alerts")
                            .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))                        .font(.system(size: UIFont.systemFontSize))
                        Spacer()
                        Image(systemName: "bell.fill").foregroundStyle(theme.reminderColor)
                    }.font(.system(size: UIFont.systemFontSize))
                }
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
            .toolbar {
                Button {
                    saveTheme()
                } label: {
                    Label("Save", systemImage: "")
                        .foregroundStyle(theme.accentColor)                        .font(.system(size: UIFont.systemFontSize+5))
                }

            }
//            .navigationBarItems(trailing: Button("Save") {
//                saveTheme()
//            })
           
            .navigationTitle("Edit Theme")
        }
    }
    
    private func saveTheme() {
        // Update the userTheme with the modified theme properties if it exists
        if userTheme != nil {
            userTheme?.fromTheme(theme)
        } else {
            // Handle the case where userTheme is nil if necessary
        }

        // Save the context
        do {
            try coreDataManager.viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            // Handle the error appropriately in a real app
            print("Failed to save user theme: \(error.localizedDescription)")
        }
    }
}
