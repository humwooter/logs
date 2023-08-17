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
    @Published var activatedButtons: [Bool] = [true, false, false] {
        didSet {
            UserDefaults.standard.set(activatedButtons, forKey: "activatedButtons")
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
    
    @Published var image1: String {
        didSet {
            UserDefaults.standard.set(image1, forKey: "image1")
        }
    }
    @Published var image2: String {
        didSet {
            UserDefaults.standard.set(image2, forKey: "image2")
        }
    }
    
    @Published var image3: String {
        didSet {
            UserDefaults.standard.set(image3, forKey: "image3")
        }
    }
    
    @Published var buttonColor1: Color {
        didSet {
            UserDefaults.standard.setColor(color:buttonColor1, forKey: "buttonColor1")
        }
    }
    @Published var buttonColor2: Color {
        didSet {
            UserDefaults.standard.setColor(color: buttonColor2, forKey: "buttonColor2")
        }
    }
    @Published var buttonColor3: Color {
        didSet {
            UserDefaults.standard.setColor(color: buttonColor3, forKey: "buttonColor3")
        }
    }
//    @Published var activatedButtons: [Bool] = [true, false, false]
    
    init() {
        self.accentColor = UserDefaults.standard.color(forKey: "accentColor") ?? Color.blue
        self.fontSize = CGFloat(UserDefaults.standard.float(forKey: "fontSize")) != 0.0 ? CGFloat(UserDefaults.standard.float(forKey: "fontSize")) : CGFloat(16)
        self.fontName = UserDefaults.standard.string(forKey: "fontName") ?? "monospace"
        self.image1 = UserDefaults.standard.string(forKey: "image1") ?? "staroflife"
        self.image2 = UserDefaults.standard.string(forKey: "image2") ?? "star.fill"
        self.image3 = UserDefaults.standard.string(forKey: "image3") ?? "heart.fill"
        self.buttonColor1 = UserDefaults.standard.color(forKey: "buttonColor1") ?? Color.yellow
        self.buttonColor2 = UserDefaults.standard.color(forKey: "buttonColor2") ?? Color.cyan
        self.buttonColor3 = UserDefaults.standard.color(forKey: "buttonColor3") ?? Color.pink
        self.activatedButtons = UserDefaults.standard.array(forKey: "activatedButtons") as? [Bool] ?? [true, false, false]
        self.showLockScreen = UserDefaults.standard.bool(forKey: "showLockScreen") ?? false
//        self.isUnlocked = UserDefaults.standard.bool(forKey: "isUnlocked") ?? false

    }
}

extension UserDefaults {
    //    func setColor(color: Color, forKey key: String) {
    //        let data = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false)
    //        set(data, forKey: key)
    //    }
    //
    //    func color(forKey key: String) -> Color? {
    //         guard let data = data(forKey: key) else { return nil }
    //         do {
    //             if let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
    //                 return Color(color)
    //             }
    //         } catch {
    //             print("Error unarchiving color: \(error)")
    //         }
    //         return nil
    //     }
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
                    HStack(alignment: .center, spacing: 45) {
                        ForEach(0...2, id: \.self) { index in
                            
                            Section {
                                VStack(alignment: .center) {
                                    Text("Button \(index+1)")
                                    //                                                    .font(.system(size: 10)) // Adjust the size as needed
                                        .multilineTextAlignment(.center)
                                    if (index == 0) {
                                        ToggleButton(isOn: $userPreferences.activatedButtons[index], color: userPreferences.buttonColor1)
                                    }
                                    if (index == 1) {
                                        ToggleButton(isOn: $userPreferences.activatedButtons[index], color: userPreferences.buttonColor2)
                                        
                                    }
                                    if (index == 2) {
                                        ToggleButton(isOn: $userPreferences.activatedButtons[index], color: userPreferences.buttonColor3)
                                        
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity) // Makes the HStacks evenly spaced
                    ForEach(1...3, id: \.self) { buttonIndex in
                        if (userPreferences.activatedButtons[buttonIndex-1]) {
                            Section(header: Text("Button \(buttonIndex)")) {
                                Picker("Button \(buttonIndex) Image", selection: buttonIndex == 1 ? $userPreferences.image1 : (buttonIndex == 2 ? $userPreferences.image2 : $userPreferences.image3)) {
                                    ForEach(systemImages, id: \.self) { image in
                                        HStack {
                                            Image(systemName: image).tag(image)
                                            Text(image)
                                        }
                                    }
                                }
                                .pickerStyle(.navigationLink)
                                
                                ColorPicker("Button \(buttonIndex) Color", selection: buttonIndex == 1 ? $userPreferences.buttonColor1 : (buttonIndex == 2 ? $userPreferences.buttonColor2 : $userPreferences.buttonColor3))
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
            return userPreferences.buttonColor1
        }
        else if (userPreferences.activatedButtons[1]) {
            return userPreferences.buttonColor2
        }
        else {
            return userPreferences.buttonColor3
        }
    }
    
    func authenticate() {
        if userPreferences.showLockScreen {
            userPreferences.isUnlocked = true //for now
//            let context = LAContext()
//            var error: NSError?
//
//            // check whether biometric authentication is possible
//            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//                // it's possible, so go ahead and use it
//                let reason = "We need to unlock your data."
//
//                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
//                    // authentication has now completed
//                    DispatchQueue.main.async {
//                        if success {
//                            userPreferences.isUnlocked = true
//                        } else {
//                            // there was a problem
//                        }
//                    }
//                }
//            } else {
//                // no biometrics
//            }
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




//extension UIView {
//    var viewController: UIViewController? {
//        return next as? UIViewController ?? next?.viewController
//    }
//}
