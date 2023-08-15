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
//
//struct SettingsView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @EnvironmentObject var userPreferences: UserPreferences
//    @State private var isExportingData = false
//
//    let fonts = ["Helvetica Neue", "Times New Roman", "Courier New", "AmericanTypewriter", "Bradley Hand", "Cochin", "GillSans", "Papyrus Condensed"]
//
//
//    var body: some View {
//            NavigationView {
//                Form {
//                    Section(header: Text("Accent Color")) {
//                        ColorPicker("Accent Color", selection: $userPreferences.accentColor)
//                    }
//                    Section(header: Text("Font Size")) {
//                        Slider(value: $userPreferences.fontSize, in: 10...30, step: 1, label: { Text("Font Size") })
//                    }
//                    Section(header: Text("Font Family")) {
//                        Picker("Font Type", selection: $userPreferences.fontName) {
//                            ForEach(fonts, id: \.self) { font in
//                                Text(font).tag(font)
//                            }
//                        }
//                    }
//                }
//                .navigationTitle("Settings")
//                .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
//                .accentColor(userPreferences.accentColor)
//            }
//    }
//}

//struct SettingsView: View {
//    @EnvironmentObject var userPreferences: UserPreferences
//    @Environment(\.managedObjectContext) private var viewContext
//    @State private var exportedLogs: ExportedLogs? = nil
//
//    let fonts = ["Helvetica Neue", "Times New Roman", "Courier New", "AmericanTypewriter", "Bradley Hand", "Cochin", "GillSans", "Papyrus Condensed"]
////
////    func exportDataToJson() {
////        let exporter = ExportData(viewContext: viewContext)
////        exporter.e
////        xportDataToJson()
////    }
//    func exportDataToJson() {
//        ExportData(viewContext: viewContext).exportDataToJson { fileURL in
//            guard let fileURL = fileURL else { return }
//            do {
//                let data = try Data(contentsOf: fileURL)
//                exportedLogs = ExportedLogs(logsData: data)
//            } catch {
//                print("Error reading file: \(error)")
//            }
//        }
//    }
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Accent Color")) {
//                    ColorPicker("Accent Color", selection: $userPreferences.accentColor)
//                }
//                Section(header: Text("Font Size")) {
//                    Slider(value: $userPreferences.fontSize, in: 10...30, step: 1, label: { Text("Font Size") })
//                }
//                Section(header: Text("Font Family")) {
//                    Picker("Font Type", selection: $userPreferences.fontName) {
//                        ForEach(fonts, id: \.self) { font in
//                            Text(font).tag(font)
//                        }
//                    }
//                }
//                Section(header: Text("Data Export")) {
//                     Button(action: exportDataToJson) {
//                         Label("Export Data", systemImage: "arrow.down.doc") // Added icon here
//                     }
//                 }
//            }
//            .navigationTitle("Settings")
//            .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
//            .accentColor(userPreferences.accentColor)
//        }
//    }
//}

struct SettingsView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    let fonts = ["Helvetica Neue", "Times New Roman", "Courier New", "AmericanTypewriter", "Bradley Hand", "Cochin", "GillSans", "Papyrus Condensed"]

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
                Section(header: Text("Export Data")) {
                    
                    Button(action: exportData) {
                        Label("Export Data", systemImage: "arrow.down.doc") // Added icon here
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

}


extension EnvironmentValues {
    var viewController: UIViewController? {
        self[UIViewControllerKey.self]
    }
}

struct UIViewControllerKey: EnvironmentKey {
    static let defaultValue: UIViewController? = nil
}

//extension UIView {
//    var viewController: UIViewController? {
//        return next as? UIViewController ?? next?.viewController
//    }
//}
