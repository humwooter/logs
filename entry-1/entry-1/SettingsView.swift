//
//  SettingsView.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//

import Foundation
import SwiftUI
import CoreData


class UserPreferences: ObservableObject {
    
    @Published var accentColor: Color {
        didSet {
            UserDefaults.standard.setColor(color: accentColor, forKey: "accentColor")
        }
    }
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
        self.fontName = UserDefaults.standard.string(forKey: "fontName") ?? "monospace"
    }

}

extension UserDefaults {
    func setColor(color: Color, forKey key: String) {
        let data = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false)
        set(data, forKey: key)
    }
    
    func color(forKey key: String) -> Color? {
         guard let data = data(forKey: key) else { return nil }
         do {
             if let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
                 return Color(color)
             }
         } catch {
             print("Error unarchiving color: \(error)")
         }
         return nil
     }
}

struct SettingsView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    let fonts = ["Helvetica Neue", "Times New Roman", "Courier New", "AmericanTypewriter", "Bradley Hand"]


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
                            }
                        }
                    }
                }
                .navigationTitle("Settings")
                .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
                .accentColor(userPreferences.accentColor)
            }
    }
}
