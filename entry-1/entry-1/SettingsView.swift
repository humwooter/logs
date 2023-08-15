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
        self.fontSize = CGFloat(UserDefaults.standard.float(forKey: "fontSize")) ?? 16
        self.fontName = UserDefaults.standard.string(forKey: "fontName") ?? "Helvetica"
    }
}

extension UserDefaults {
    func setColor(color: Color, forKey key: String) {
        let data = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false)
        set(data, forKey: key)
    }
    
    func color(forKey key: String) -> Color? {
        guard let data = data(forKey: key),
              let color = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
        else { return nil }
        return Color(color)
    }
}

struct SettingsView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    let fonts = ["Default", "Helvetica", "monospace", "serif"]
    
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 30) // Adjust the height
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
            }
        }
    }
}
    
