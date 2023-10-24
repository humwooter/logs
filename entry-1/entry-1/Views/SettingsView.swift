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
import UniformTypeIdentifiers


struct TempLog: Decodable {
    var id: UUID
    var day: String
    var relationship: String
}


func defaultLogsName() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "M-d-yy"
    let dateString = formatter.string(from: date)
    return "logs backup \(dateString)"
}

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
    @Published var backgroundColor: Color {
        didSet {
            UserDefaults.standard.setColor(color: backgroundColor, forKey: "backgroundColor")
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
        self.backgroundColor = Color(.clear)
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
    //    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    
//    let fonts = ["Helvetica Neue", "Times New Roman", "Courier New", "American Typewriter", "Bradley Hand", "Cochin", "Noteworthy Light", "Papyrus Condensed", "PartyLetPlain", "SnellRoundhand", "Superclarendon Regular", "SavoyeLetPlain", "Menlo Regular", "Marker Felt Thin", "Marker Felt Wide", "Gill Sans", "Copperplate Light", "Chalkboard SE Regular", "Academy Engraved LET Plain:1.0", "Bodoni 72 Oldstyle Book", "Forgotten Futurist Regular"]
    
    let fontCategories: [String: [String]] = [
        "Traditional": ["Helvetica Neue", "Gill Sans", "Menlo Regular", "Didot", "Futura", "Georgia", "Impact", "Arial Rounded MT Bold"],
        "Monospace": ["Courier New", "STIX Two Math", "Skia"],
        "Handwriting": ["Bradley Hand", "Noteworthy Light", "SavoyeLetPlain", "Marker Felt Thin"],
        "Cursive" : ["Savoye LET", "Snell Roundhand", "SignPainter"],
        "Decorative": ["Papyrus Condensed", "Bodoni Ornaments", "Superclarendon Regular",  "Luminari"],
        "Other": ["American Typewriter", "Chalkboard SE Regular", "Academy Engraved LET Plain:1.0", "Copperplate Light", "GB18030 Bitmap"]
    ]

    

    
    let imageCategories: [String: [String]] = [
        "Shapes": ["circle", "staroflife", "star.fill", "heart.fill"],
        "Symbols": ["folder.fill", "exclamationmark", "lightbulb", "gearshape", "bolt.fill", "bookmark.fill", "hourglass", "power"],
        "Animals": ["bird.fill", "lizard.fill"],
        "Nature": ["leaf.fill", "moon.stars.fill", "wind.snow", "sun.max.fill", "drop.fill"],
        "Actions": ["gamecontroller.fill", "figure.run", "figure.mind.and.body", "book.fill", "paintpalette.fill", "eye.fill"],
        "Currency": ["dollarsign"]
    ]
    
    @State var advancedSettings = false
    @State private var isExportDocumentPickerPresented = false
    @State private var isImportDocumentPickerPresented = false
    @StateObject var docPickerDelegate = DocumentPickerDelegate()
    
    
    @State private var tempFileURL: URL?
    
    @State private var selectedURL: URL?
    
    @State private var isExporting = false
    @State private var isImporting = false
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)]
    ) var logs: FetchedResults<Log>
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Accent Color")) {
                    ColorPicker("Accent Color", selection: $userPreferences.accentColor)
                }
                
     
                FontPicker(selectedFont: $userPreferences.fontName, selectedFontSize: $userPreferences.fontSize, accentColor: $userPreferences.accentColor, inputCategories: fontCategories)
                
                
                Section(header: Text("Export Data")) {
                    Button {
                        exportData()
                        print("Export button tapped")
                        isExporting = true
                    } label: {
                        Label("Export Data", systemImage: "arrow.up.doc")
                    }
                    .fileExporter(isPresented: $isExporting, document: LogDocument(logs: Array(logs)), contentType: .json, defaultFilename: "\(defaultLogsName()).json") { result in
                        switch result {
                        case .success(let url):
                            print("File successfully saved at \(url)")
                        case .failure(let error):
                            print("Failed to save file: \(error)")
                        }
                    }

                }
                
                Section(header: Text("Import Data")) {
                    Button {
                        isImporting = true
                    } label: {
                        Label("Import Data", systemImage: "arrow.down.doc")
                    }
                    .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
                        Task {
                            switch result {
                            case .success(let url):
                                do {
                                    try await importData(from: url)
                                } catch {
                                    print("Failed to import data: \(error)")
                                }
                            case .failure(let error):
                                print("Failed to import file: \(error)")
                            }
                        }
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
                    ButtonDashboard().environmentObject(userPreferences)

                    .frame(maxWidth: .infinity) // Makes the HStacks evenly spaced
                    
                    ForEach(0..<5, id: \.self) { index in
                        if userPreferences.activatedButtons[index] {

                            IconPicker(
                                          selectedImage: $userPreferences.selectedImages[index],
                                          selectedColor: $userPreferences.selectedColors[index], accentColor: $userPreferences.accentColor,
                                          buttonIndex: index,
                                          inputCategories: imageCategories
                                      )
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
        do {
            let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
            let logs = try coreDataManager.viewContext.fetch(fetchRequest)
            
            // Check if logs is not empty
            guard !logs.isEmpty else {
                print("No logs to export")
                return
            }
            
            isExporting = true
        } catch {
            print("Failed to fetch logs: \(error)")
        }
    }
    

    
    private func importData(from url: URL) async throws {
        print("entered import data")
        
        guard url.startAccessingSecurityScopedResource() else {
            throw NSError(domain: "Security", code: 1, userInfo: nil)
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let jsonData = try Data(contentsOf: url)
        
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                
                coreDataManager.viewContext.performAndWait {
                    do {
                        for jsonObject in jsonArray {
                            if let logIdString = jsonObject["id"] as? String, let logId = UUID(uuidString: logIdString) {
                                print("ID: \(logId)")
                                
                                let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
                                fetchRequest.predicate = NSPredicate(format: "id == %@", logId as CVarArg)
                                
                                let existingLogs = try coreDataManager.viewContext.fetch(fetchRequest)
                                
                                if existingLogs.first != nil {
                                    print("LOG WITH ID: \(logId) ALREADY EXISTS")
                                } else {
                                    if let logData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) {
                                        let decoder = JSONDecoder()
                                        decoder.userInfo[CodingUserInfoKey.managedObjectContext] = coreDataManager.viewContext
                                        let log = try decoder.decode(Log.self, from: logData)
                                        coreDataManager.viewContext.insert(log)
                                    }
                                }
                            }
                        }
                        try coreDataManager.viewContext.save()
                        
                    } catch {
                        print("Failed to import data: \(error)")
                    }
                }
            }
        } catch {
            print("Failed to parse JSON: \(error)")
        }

        }
    
    // UIDocumentPickerDelegate method
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        if controller.documentPickerMode == .exportToService {
            do {
                
                // Handle export (write jsonData to the selected URL)
            } catch {
                print("Failed to export data: \(error)")
            }
        } else if controller.documentPickerMode == .import {
            do {
                // Handle import (read jsonData from the selected URL)
            } catch {
                print("Failed to import data: \(error)")
            }
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


class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate, ObservableObject {
    @Published var pickedURL: URL? = nil
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        pickedURL = urls.first
    }
}


// struct DocumentPicker: UIViewControllerRepresentable {
//     var url: URL
//     var delegate: UIDocumentPickerDelegate

//     func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
//         let picker = UIDocumentPickerViewController(forExporting: [url])
//         picker.delegate = delegate
//         return picker
//     }

//     func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
//         // Nothing to update
//     }
// }

