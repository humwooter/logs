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








struct SettingsView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    //    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    
    let fontCategories: [String: [String]] = [
        "Traditional": ["Helvetica Neue", "Gill Sans", "Menlo Regular", "Didot", "Futura", "Georgia", "Impact", "Arial Rounded MT Bold","Superclarendon Regular", ],
        "Monospace": ["Courier New", "STIX Two Math"],
        "Handwriting": ["Bradley Hand", "Noteworthy Light", "SavoyeLetPlain", "Marker Felt Thin", "BarelyEnough-Regular", "MotleyForces-Regular", "ClickerScript-Regular", "Magiera-Script", "Mueda-City", "SunnySpellsBasic-Regular", "Papyrus Condensed", "Nathan-CondensedRegular", "Lilly", "NjalBold", "Darlin\'Pop"],
        "Cursive" : ["Savoye LET", "Snell Roundhand", "SignPainter","AlexBrush-Regular", "DancingScript", "stainellascript"],
        "Decorative": ["Bodoni Ornaments",  "Auseklis", "AstroDotBasic", "MageScript", "HaraldRunic", "LuciusCipher"],
        "Other": ["American Typewriter", "Chalkboard SE Regular", "Academy Engraved LET Plain:1.0", "Copperplate Light", "PressStartReg", "Barrbar", "PixelDigivolve"],
        "Unique": ["ShootingStars", "aAnnyeongHaseyo", "Spicy-Chips", "Cute_Aurora_demo", "SparkyStones-Regular", "TheNightOne", "Boekopi", "Emperialisme"],
        "Antique": ["aAnggaranDasar", "IrishUncialfabeta-Bold", "QuaeriteRegnumDei"],
        "Calligraphy": []
    ]
    
    
    
    
    let imageCategories: [String: [String]] = [
        "Shapes": ["circle", "staroflife", "star.fill", "heart.fill", "bolt.heart.fill", "heart.slash.fill", "house.fill"],
        "Symbols": ["folder.fill", "exclamationmark", "checkmark","lightbulb", "gearshape", "bolt.fill", "bookmark.fill", "hourglass", "power"],
        "Human": ["brain", "ear.fill", "mustache.fill", "hand.raised.fill", "brain.filled.head.profile"],
        "Animals": ["bird.fill", "lizard.fill", "hare.fill", "tortoise.fill", "dog.fill", "cat.fill", "ladybug.fill", "fish.fill"],
        "Nature": ["leaf.fill", "moon.stars.fill", "sun.haze.circle.fill", "wind.snow", "sun.max.fill", "drop.fill", "globe.asia.australia.fill", "camera.macro", "snowflake"],
        "Actions": ["gamecontroller.fill", "figure.run", "figure.mind.and.body", "book.fill", "paintpalette.fill", "eye.fill", "list.clipboard" , "clipboard.fill", "figure.yoga", "figure.strengthtraining.traditional"],
        "Commerce": ["bag.fill", "cart.fill", "creditcard.fill", "giftcard.fill", "dollarsign"],
        "Sleep": ["bed.double.fill"],
        "Emotions" : ["face.smiling.inverse", "hand.thumbsup.fill", "hands.thumbsdown.fill", "hands.and.sparkles.fill"],
        "Transportation": ["car.fill", "bus.fill", "tram.fill", "ferry.fill", "sailboat.fill", "bicycle", "scooter"],
        "Other" : ["drop.halfull", "swirl.circle.righthalf.filled", "lightspectrum.horizontal", "camera.circle.fill",   "camera.aperture", "books.vertical.fill",  "key.fill", "poweroutlet.type.f", "doc.richtext.fill"],
        "Special" : ["graduationcap.fill", "backpack.fill"],
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
            List {
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
                    
                    Section(header: Text("Stamp Dasboard")) {
                        ButtonDashboard().environmentObject(userPreferences)
                            .listStyle(.automatic)

                    }
                    
                    ForEach(0..<7, id: \.self) { index in
                        if userPreferences.stamps[index].isActive {
                            
                            IconPicker(
                                selectedImage: $userPreferences.stamps[index].imageName,
                                selectedColor: $userPreferences.stamps[index].color, accentColor: $userPreferences.accentColor,
                                buttonIndex: index,
                                inputCategories: imageCategories
                            )
                        }
                    }

                }
            }
            .listStyle(.automatic)
            .navigationTitle("Settings")
            .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
            .accentColor(userPreferences.accentColor)
        }
    }
    
    
    private func exportData() {
        do {
            let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
            let logs = try coreDataManager.backgroundContext.fetch(fetchRequest)
            
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
                
                coreDataManager.backgroundContext.performAndWait {
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
                        try coreDataManager.backgroundContext.save()
                        
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

