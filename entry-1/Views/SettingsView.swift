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
    
    
    
    @State var advancedSettings = false
    @State private var isExportDocumentPickerPresented = false
    @State private var isImportDocumentPickerPresented = false
    @StateObject var docPickerDelegate = DocumentPickerDelegate()
    @Environment(\.colorScheme) var colorScheme
    
    
    @State private var tempFileURL: URL?
    
    @State private var selectedURL: URL?
    
    @State private var isExporting = false
    @State private var isImporting = false
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)]
    ) var logs: FetchedResults<Log>
    
    
    @State private var selectedTab = 0
    
//    init(color: UIColor) {
//        if !isClear(for: color) {
//            let textColor = UIColor(UIColor.foregroundColor(background: color))
//            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: textColor]
//            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: textColor]
//        }
//        if isClear(for: color) {
//            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color("TextColor"))]
//        }
//        
//   }
    
    var body: some View {

        NavigationStack {
            VStack {
                Picker("Options", selection: $selectedTab) {
                    Text("General").padding().tag(0)
                    Text("Preferences").padding().tag(1)
                    Text("Stamps").padding().tag(2)
                }.foregroundStyle(Color(UIColor.secondarySystemBackground))
                .background {
                    ZStack {
                        Color(UIColor.tertiarySystemBackground)
//                        userPreferences.accentColor.opacity(0.7)
                    }
                }.cornerRadius(5)
//                .background(userPreferences.accentColor.opacity(0.5)).cornerRadius(5)
                .pickerStyle(.segmented)
                .padding(10)
                .padding(.horizontal, 5)

                List {
                    
                    if selectedTab == 0 {
                        
                        Section(header: Text("About").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                            .font(.system(size: UIFont.systemFontSize))

                        ) {
                            
                            NavigationLink {
                                IntroViews()
                                    .environmentObject(userPreferences)
                            } label: {
                                Label("User Guide", systemImage: "info.circle.fill")
                            }

                      
                            
                        }
                        
                        Section(header: Text("Data").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                            .font(.system(size: UIFont.systemFontSize))

                        ) {
                            HStack {
                                Spacer()
                                Button {
                                    exportData()
                                    print("Export button tapped")
                                    isExporting = true
                                } label: {
                                    VStack(spacing: 2) {
                                       
                                        Image(systemName:  "arrow.up.doc")
                                        
                                        Text("BACKUP").fontWeight(.bold).font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                                    }

                                }
                                .fileExporter(isPresented: $isExporting, document: LogDocument(logs: Array(logs)), contentType: .json, defaultFilename: "\(defaultLogsName()).json") { result in
                                    switch result {
                                    case .success(let url):
                                        print("File successfully saved at \(url)")
                                    case .failure(let error):
                                        print("Failed to save file: \(error)")
                                    }
                                }
                                .buttonStyle(BackupButtonStyle())
                                .foregroundColor(Color(UIColor.tertiarySystemBackground))
                                
                                Spacer()
                                Button {
                                    isImporting = true
                                } label: {
                                    VStack(spacing: 2) {
                                        Image(systemName:  "arrow.down.doc")
                                        Text("RESTORE").fontWeight(.bold).font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                                    }
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
                                .buttonStyle(RestoreButtonStyle())
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                                
                                Spacer()
                            }
                            .zIndex(1) // Ensure it lays on top if using ZStack
                        }
                        .background(.clear)  // Use a clear background to prevent any visual breaks
                        
                        Section(header: Text("Advanced Settings").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                            .font(.system(size: UIFont.systemFontSize))

                        ) {
                            Toggle("Advanced Settings", isOn: $advancedSettings) // Make sure to add this property to UserPreferences
                        }
                        
                        
                        if advancedSettings {
                            Section(header: Text("Enable authentication").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                                .font(.system(size: UIFont.systemFontSize))

                            ) {
                                Toggle("Enable authentication", isOn: $userPreferences.showLockScreen) // Make sure to add this property to UserPreferences
                                    .onChange(of: userPreferences.showLockScreen) { newValue in
                                        if newValue {
                                            authenticate()
                                        }
                                    }
                            }
              
                            Section(header: Text("Link Detection").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                                .font(.system(size: UIFont.systemFontSize))

                            ) {
                                Toggle("Activate hyperlinks", isOn: $userPreferences.showLinks) // Make sure to add this property to UserPreferences
                                    .onChange(of: userPreferences.showLinks) { newValue in
                                        if newValue {
                                            userPreferences.showLinks = newValue
                                        }
                                    }
                            }
                            
                            
                        }
                    }
                    if selectedTab == 1 {
                        
                        Section(header: Text("Preferences").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                            .font(.system(size: UIFont.systemFontSize))

                        ) {
                            ColorPicker("Accent Color", selection: $userPreferences.accentColor)
                            FontPicker(selectedFont:  $userPreferences.fontName, selectedFontSize: $userPreferences.fontSize, accentColor: $userPreferences.accentColor, inputCategories: fontCategories, topColor_background: $userPreferences.backgroundColors[0], bottomColor_background: $userPreferences.backgroundColors[1])
                            HStack {
                                Text("Line Spacing")
                                Slider(value: $userPreferences.lineSpacing, in: 0...15, step: 1, label: { Text("Line Spacing") })
                            }
                            
                            
                        }
                        
                        
                        
                        Section(header: Text("Background Colors").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                            .font(.system(size: UIFont.systemFontSize))

                        ) {
                            BackgroundColorPickerView(topColor: $userPreferences.backgroundColors[0], bottomColor: $userPreferences.backgroundColors[1])
                        }
                        
//                        Section(header: Text("Entry background color").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
//                            .font(.system(size: UIFont.systemFontSize))
//
//                        ) {
//                            BackgroundColorPickerView(topColor: $userPreferences.backgroundColors[0], bottomColor: $userPreferences.backgroundColors[1])
//                        }
                        
                        Section {
                            ColorPicker("Pin Color", selection: $userPreferences.pinColor)
                        } header: {
                            HStack {
                                Text("Pin Color").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)                                .font(.system(size: UIFont.systemFontSize))


                                
                                Spacer()
                                Label("", systemImage: "pin.fill").foregroundStyle(userPreferences.pinColor)
                            }
                        }
                        
  
                    }
                    
                    
                    if selectedTab == 2 {
                        Section(header: Text("Stamp Dashboard").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                            .font(.system(size: UIFont.systemFontSize))

                        ) {
                            ButtonDashboard().environmentObject(userPreferences)
                                .listStyle(.automatic)
                                .padding(.horizontal, 5)
                            
                        }
                        ForEach(0..<userPreferences.stamps.count, id: \.self) { index in
                            if userPreferences.stamps[index].isActive {
                                
                                IconPicker(selectedImage: $userPreferences.stamps[index].imageName, selectedColor: $userPreferences.stamps[index].color, accentColor: $userPreferences.accentColor, topColor_background: $userPreferences.backgroundColors[0], bottomColor_background: $userPreferences.backgroundColors[1], buttonIndex: index, inputCategories: imageCategories)

                                
                            }
                        }
                    }
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
            .navigationTitle("Settings")
            .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
            .accentColor(userPreferences.accentColor)

        }
        
    }
    
    
    
    func importData(from url: URL) async throws {
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
                            if let dayString = jsonObject["day"] as? String {
                                print("Day: \(dayString)")

                                   let logFetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
                                   logFetchRequest.predicate = NSPredicate(format: "day == %@", dayString as String)
                                
                                if let existingLog = try coreDataManager.viewContext.fetch(logFetchRequest).first {
                                    print("LOG WITH DAY: \(dayString) ALREADY EXISTS, CHECKING ENTRIES")
                                    
                                    // Extract entries from jsonObject and compare with existing entries
                                    if let newEntries = jsonObject["relationship"] as? [[String: Any]] {
                                        for newEntryData in newEntries {
                                            print("newEntryData: \(newEntryData)")
                                            if let newEntryIdString = newEntryData["id"] as? String, let newEntryId = UUID(uuidString: newEntryIdString) {
                                                let entryFetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
                                                entryFetchRequest.predicate = NSPredicate(format: "id == %@", newEntryId as CVarArg, existingLog)
                                                
                                                let existingEntries = try coreDataManager.viewContext.fetch(entryFetchRequest)
                                                
                                                if existingEntries.isEmpty {
                                                    // This is a new entry, add it to the log
                                                    print("ENTRY DOESNT EXIST")
                                                    if let entryData = try? JSONSerialization.data(withJSONObject: newEntryData, options: []) {
                                                        let decoder = JSONDecoder()
                                                        decoder.userInfo[CodingUserInfoKey.managedObjectContext] = coreDataManager.viewContext
                                                        if let newEntry = try? decoder.decode(Entry.self, from: entryData) {
                                                            
                                                            coreDataManager.viewContext.insert(newEntry)

                                                            print("new entry created")
                                                            existingLog.addToRelationship(newEntry)
                                                            
                                                            print("new entry added to log")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    // Log does not exist, import it as new
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



struct BackupButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .padding(.horizontal, 10)
            .background {
                LinearGradient(colors: [.green, .cyan], startPoint: .leading, endPoint: .trailing)
            }
        //            .foregroundColor(colorScheme == .dark ? .white : .black)
            .clipShape(RoundedRectangle(cornerSize: .init(width: 30, height: 30)))
            .scaleEffect(!configuration.isPressed ? 0.95 : 1.05)
    }
}

struct RestoreButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .padding(.horizontal, 10)
            .background {
                LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
            }
        //            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerSize: .init(width: 30, height: 30)))
            .scaleEffect(!configuration.isPressed ? 0.95 : 1.05)
    }
}
