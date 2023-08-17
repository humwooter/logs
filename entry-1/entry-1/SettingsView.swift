//
//  SettingsView.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//

import Foundation
import SwiftUI
import CoreData
import UIKit
import LocalAuthentication



class UserPreferences: ObservableObject {
    
    @Published var activatedButtons: [Bool] = [true, false, false, false, false] {
        didSet {
            UserDefaults.standard.set(activatedButtons, forKey: "activatedButtons")
        }
    }
    
    @Published var selectedImages: [String] =  ["star.fill", "staroflife", "heart.fill", "book.fill", "gamecontroller.fill"] {
        didSet {
            UserDefaults.standard.set(selectedImages, forKey: "selectedImages")
        }
    }
    @Published var selectedColors: [Color] = [.yellow, .cyan, .pink, .green, .indigo] {
        didSet {
            UserDefaults.standard.saveColors(colors: selectedColors, forKey: "selectedColors")
        }
    }

    @Published var accentColor: Color {
        didSet {
            UserDefaults.standard.setColor(color: accentColor, forKey: "accentColor")
        }
    }
    
    @Published var showLockScreen: Bool  {
        didSet {
            UserDefaults.standard.set(showLockScreen, forKey: "showLockScreen")
        }
    }
    @Published var isUnlocked: Bool = false 
    
    @Published var fontSize: CGFloat {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }
    @Published var fontName: String {
        didSet {
            UserDefaults.standard.set(fontName, forKey: "fontName")
        }
    }
    
    
    init() {
        self.accentColor = UserDefaults.standard.color(forKey: "accentColor") ?? Color.blue
        self.fontSize = CGFloat(UserDefaults.standard.float(forKey: "fontSize")) != 0.0 ? CGFloat(UserDefaults.standard.float(forKey: "fontSize")) : CGFloat(16)
        self.fontName = UserDefaults.standard.string(forKey: "fontName") ?? "seif"
        self.activatedButtons = UserDefaults.standard.array(forKey: "activatedButtons") as? [Bool] ?? [true, false, false, false, false]
        self.selectedImages = UserDefaults.standard.array(forKey: "selectedImages") as? [String] ?? ["star.fill", "staroflife", "heart.fill", "book.fill", "gamecontroller.fill"]
        self.selectedColors = UserDefaults.standard.loadColors(forKey: "selectedColors") ?? [.yellow, .cyan, .pink, .green, .indigo]
        self.showLockScreen = UserDefaults.standard.bool(forKey: "showLockScreen") ?? false
    }
}

extension UserDefaults {

    func saveColors(colors: [Color], forKey key: String) {
        let colorStrings = colors.map { $0.description }
        UserDefaults.standard.set(colorStrings, forKey: key)
    }

    func loadColors(forKey key: String) -> [Color]? {
        guard let data = array(forKey: key) as? [Data] else { return nil }
        return data.compactMap { try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData($0) as? Color }
    }

    func setColor(color: Color, forKey key: String) {
        let uiColor = UIColor(color)
        //         if let uiColor = UIColor(color) { // Assuming there's a UIColor initializer that takes a Color
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
            set(data, forKey: key)
        } catch {
            print("Error archiving color: \(error)")
        }
        //         }
    }
//    func setColors(colors: [Color], forKey key: String) {
//
//    }
    
    func color(forKey key: String) -> Color? {
        guard let data = data(forKey: key),
              let uiColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
        else { return nil }
        
        return Color(uiColor) // Assuming there's a Color initializer that takes a UIColor
    }
}


struct SettingsView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    let fonts = ["Helvetica Neue", "Times New Roman", "Courier New", "American Typewriter", "Bradley Hand", "Cochin", "Noteworthy Light", "Papyrus Condensed", "PartyLetPlain", "SnellRoundhand", "Superclarendon Regular", "SavoyeLetPlain", "Menlo Regular", "Marker Felt Thin", "Marker Felt Wide", "Gill Sans", "Copperplate Light", "Chalkboard SE Regular", "Academy Engraved LET Plain:1.0", "Bodoni 72 Oldstyle Book", "Forgotten Futurist Regular"]
    
    let systemImages = [ "folder.fill", "staroflife", "star.fill", "heart.fill", "exclamationmark", "lightbulb", "gamecontroller.fill", "figure.run", "leaf.fill", "figure.mind.and.body", "book.fill", "gearshape", "bolt.fill", "bookmark.fill", "hourglass", "paintpalette.fill", "moon.stars.fill", "wind.snow", "wind.snow", "cat", "dog", "lizard.fill", "dollarsign", "sun.min", "sun.min.fill", "sun.max.fill", "power"]
    @State var advancedSettings = false

    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Accent Color")) {
                    ColorPicker("Accent Color", selection: $userPreferences.accentColor)
                }
                Section(header: Text("Font Size")) {
                    Slider(value: $userPreferences.fontSize, in: 10...30, step: 1, label: { Text("Font Size") })
                }
                Section(header: Text("Font Family")) {
                    Picker("Font Type", selection: $userPreferences.fontName) {
                        ForEach(fonts, id: \.self) { font in
                            Text(font).tag(font)
                                .font(.custom(font, size: userPreferences.fontSize))
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                }
                Section(header: Text("Export Data")) {
                    
                    Button(action: exportData) {
                        Label("Export Data", systemImage: "arrow.down.doc") // Added icon here
                    }
                }
                
                
                Section(header: Text("Advanced Settings")) {
                    Toggle("Advanced Settings", isOn: $advancedSettings) // Make sure to add this property to UserPreferences
                }
                
                
                if advancedSettings {
                    Section(header: Text("Enable authentication")) {
                        Toggle("Enable authentication", isOn: $userPreferences.showLockScreen) // Make sure to add this property to UserPreferences
                            .onChange(of: userPreferences.showLockScreen) { newValue in
                                if newValue {
                                    authenticate()
                                }
                            }
                    }
                    VStack {
//                          Text("(i) You can define up to 5 buttons. Enabling all of them simultaneously may lead to undesired behavior, but you can switch them on or off as you wish.")
//                              .font(.footnote)
//                              .foregroundColor(.gray)
//
                        Spacer()
                        Text("BUTTON DASHBOARD")
                            .bold()
                        Spacer()
                          HStack(alignment: .center, spacing: 45) {
                              ForEach(0..<3, id: \.self) { index in
                                  buttonSection(index: index)
                              }
                          }
                          HStack(alignment: .center, spacing: 45) {
                              ForEach(3..<5, id: \.self) { index in
                                  buttonSection(index: index)
                              }
                          }
                        Spacer()
                      }
                
                    .frame(maxWidth: .infinity) // Makes the HStacks evenly spaced
                    ForEach(0..<5, id: \.self) { index in
                        if userPreferences.activatedButtons[index] {
                            Section(header: Text("Button \(index + 1)")) {
                                Picker("Button \(index + 1) Image", selection: $userPreferences.selectedImages[index]) {
                                    ForEach(systemImages, id: \.self) { image in
                                        HStack {
                                            Image(systemName: image).tag(image)
                                            Text(image)
                                        }
                                    }                                }
                                .pickerStyle(.navigationLink)

                                ColorPicker("Button \(index + 1) Color", selection: $userPreferences.selectedColors[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
            .accentColor(userPreferences.accentColor)
        }
    }
    
    private func exportData() {
        let exporter = ExportData(viewContext: viewContext)
        // Get the root view controller to present the document picker
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            exporter.exportDataToJson(from: rootViewController)
        }
    }
    
    private func foregroundColor() -> Color {
        if (userPreferences.activatedButtons[0]) {
            return userPreferences.selectedColors[0]
        }
        else if (userPreferences.activatedButtons[1]) {
            return userPreferences.selectedColors[1]
        }
        else if (userPreferences.activatedButtons[2]) {
            return userPreferences.selectedColors[2]
        }
        else if (userPreferences.activatedButtons[3]) {
            return userPreferences.selectedColors[3]
        }
        else {
            return userPreferences.selectedColors[4]
        }
    }
    
    func authenticate() {
        print("entry.buttons: \(userPreferences.activatedButtons)")

        if userPreferences.showLockScreen {
            userPreferences.isUnlocked = true //for now
        }
    }
    
    @ViewBuilder
    private func buttonSection(index: Int) -> some View {
        Section {
            VStack(alignment: .center) {
                Text("Button \(index + 1)")
                    .multilineTextAlignment(.center)
                ToggleButton(isOn: $userPreferences.activatedButtons[index], color: userPreferences.selectedColors[index])
            }
        }
    }
    
}


extension EnvironmentValues {
    var viewController: UIViewController? {
        self[UIViewControllerKey.self]
    }
}

struct UIViewControllerKey: EnvironmentKey {
    static let defaultValue: UIViewController? = nil
}

struct ToggleButton: View {
    @Binding var isOn: Bool
    var color: Color

    var body: some View {
        Toggle("", isOn: $isOn)
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle(tint: color))
    }
    
}
