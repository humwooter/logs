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
    let fonts = ["Helvetica Neue", "Times New Roman", "Courier New", "American Typewriter", "Bradley Hand", "Cochin", "Noteworthy Light", "Papyrus Condensed", "PartyLetPlain", "SnellRoundhand", "Superclarendon Regular", "SavoyeLetPlain", "Menlo Regular", "Marker Felt Thin", "Marker Felt Wide", "Gill Sans", "Copperplate Light", "Chalkboard SE Regular", "Academy Engraved LET Plain:1.0", "Bodoni 72 Oldstyle Book", "Forgotten Futurist Regular"]
    
    let systemImages = [ "folder.fill", "staroflife", "star.fill", "heart.fill", "exclamationmark", "lightbulb", "gamecontroller.fill", "figure.run", "leaf.fill", "drop.fill", "figure.mind.and.body", "book.fill", "gearshape", "bolt.fill", "bookmark.fill", "hourglass", "paintpalette.fill", "moon.stars.fill", "wind.snow", "lizard.fill", "bird.fill", "dollarsign", "sun.max.fill", "power", "eye.fill", "circle"]
    @State var advancedSettings = false
    @State private var isExportDocumentPickerPresented = false
    @State private var isImportDocumentPickerPresented = false
    @StateObject var docPickerDelegate = DocumentPickerDelegate()
    
    
    //    @State private var isExportDocumentPickerPresented = false
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
                    Button {
                        exportData()
                        print("Export button tapped")
                        isExporting = true
                    } label: {
                        Label("Export Data", systemImage: "arrow.up.doc")
                    }
                    .fileExporter(isPresented: $isExporting, document: LogDocument(logs: Array(logs)), contentType: .json, defaultFilename: "default_filename.json") { result in
                        switch result {
                        case .success(let url):
                            print("File successfully saved at \(url)")
                        case .failure(let error):
                            print("Failed to save file: \(error)")
                        }
                    }
                    
                    Button {
                        isImporting = true
                    } label: {
                        Label("Import Data", systemImage: "arrow.down.doc")
                    }
                    .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
                        switch result {
                        case .success(let url):
                            importData(from: url)
                        case .failure(let error):
                            print("Failed to import file: \(error)")
                        }
                    }
                }
                
                
                
                //                  Section(header: Text("Import Data")) {
                //                      Button {
                //                          isImporting = true
                //                      } label: {
                //                          Label("Import Data", systemImage: "arrow.down.doc")
                //                      }
                //                      .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
                //                          switch result {
                //                          case .success(let url):
                //                              importData(from: url)
                //                          case .failure(let error):
                //                              print("Failed to import file: \(error)")
                //                          }
                //                      }
                //                  }
                
                //                Section(header: Text("Export Data")) {
                //
                //
                //                    Button {
                //                        exportData()
                //                        print("Export button tapped")
                //                        isExportDocumentPickerPresented = true
                //                    } label: {
                //                        Label("Export Data", systemImage: "arrow.up.doc")
                //                    }
                //                    .sheet(isPresented: $isExportDocumentPickerPresented) {
                //                        if let url = tempFileURL {
                ////                            print("Presenting DocumentPickerView with url: \(url)") // Debugging statement
                //                            DocumentPickerView(url: url)
                //                        } else {
                ////                            print("Failed to present DocumentPickerView because tempFileURL is nil") // Debugging statement
                //                        }
                //                    }
                //
                //
                //
                //                    Button {
                //                        isImportDocumentPickerPresented = true
                //                        importData()
                //                    } label: {
                //                        Label("Import Data", systemImage: "arrow.down.doc")
                //                    }
                //
                //                }
                
                
                
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
    
    // Call this function when Import button is tapped
    private func importData(from url: URL) {
        print("entered import data")
        do {
            let secureURL = url.startAccessingSecurityScopedResource()
            let jsonData = try Data(contentsOf: url)
            
            let decoder = JSONDecoder()
            decoder.userInfo[CodingUserInfoKey.managedObjectContext] = coreDataManager.viewContext
            let logs = try decoder.decode([Log].self, from: jsonData)
            
            print("logs: \(logs)")
            // Now `logs` is an array of `Log` objects that you can use to update your Core Data context
            for log in logs {
                print("CREATING NEW LOG!!")
                let newLog = Log(context: coreDataManager.viewContext)
                newLog.id = log.id
                newLog.day = log.day
                                newLog.relationship = log.relationship
                
//                for importedEntry in log.entries {
//                    
//                    let newEntry = Entry(context: coreDataManager.viewContext)
//                    newEntry.content = importedEntry.content
//                    newEntry.color = importedEntry.color
//                    newEntry.id = importedEntry.id
//                    newEntry.image = importedEntry.image
//                    newEntry.time = importedEntry.time
//                    newEntry.imageContent = importedEntry.imageContent
//                    
//                    
//                    
//                    
//                    // map over other properties
//                    
//                    existingLog.addToEntries(newEntry)
//                    
//                }
                
                
                // Add any other properties you need to copy
            }
            
            try coreDataManager.viewContext.save()
            url.stopAccessingSecurityScopedResource()
        } catch {
            print("Failed to import data: \(error)")
        }
    }
    
    //    private func importData(from url: URL) {
    //        do {
    //            let secureURL = url.startAccessingSecurityScopedResource()
    //            let jsonData = try Data(contentsOf: url)
    //
    //            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [[String: Any]]
    //
    //            for log in json {
    //                let newLog = Log(context: coreDataManager.viewContext)
    //                newLog.day = log["day"] as? String ?? ""
    //                newLog.id = UUID(uuidString: log["id"] as? String ?? "") ?? UUID()
    //
    //                if let entries = log["entries"] as? [[String: Any]] {
    //                    for entryJson in entries {
    //                        let newEntry = Entry(context: coreDataManager.viewContext)
    //                        newEntry.content = entryJson["content"] as? String ?? ""
    //                        newEntry.time = entryJson["time"] as? Date ?? Date()
    //                        newEntry.id = UUID(uuidString: entryJson["id"] as? String ?? "") ?? UUID()
    //                        newEntry.buttons = entryJson["buttons"] as? [Bool] ?? [false, false, false, false, false]
    //                        newEntry.color = UIColor(named: entryJson["color"] as? String ?? "white") ?? UIColor(.cyan)
    //                        newEntry.image = entryJson["image"] as? String ?? ""
    //                        newEntry.imageContent = entryJson["imageContent"] as? String ?? "" // Add check for imageContent here
    //
    //                        newLog.addToRelationship(newEntry)
    //                    }
    //                }
    //            }
    //
    //            // Save context
    //            do {
    //                try coreDataManager.viewContext.save()
    //            } catch {
    //                print("Error saving context: \(error)")
    //            }
    //
    //            url.stopAccessingSecurityScopedResource()
    //        } catch {
    //            print("Failed to import data: \(error)")
    //        }
    //    }
    
    
    
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

struct DocumentPickerView: UIViewControllerRepresentable {
    var url: URL
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [url])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPickerView
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


struct EntryDocument: FileDocument {
    var entries: [Entry]
    
    static var readableContentTypes: [UTType] { [.json] }
    
    init(entries: [Entry]) {
        self.entries = entries
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let entries = try? JSONDecoder().decode([Entry].self, from: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.entries = entries
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(entries)
        return .init(regularFileWithContents: data)
    }
}

struct LogDocument: FileDocument {
    var logs: [Log]
    
    static var readableContentTypes: [UTType] { [.json] }
    
    init(logs: [Log]) {
        self.logs = logs
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let logs = try? JSONDecoder().decode([Log].self, from: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.logs = logs
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(logs)
        return .init(regularFileWithContents: data)
    }
}
