//
//  LogDataView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 2/13/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import CoreData

struct LogsDataView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)]
    ) var logs: FetchedResults<Log>
    
    @State private var isExporting = false
    @State private var isImporting = false
    
    var body: some View {
        Section(header: Text("Logs Data").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
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
                        Image(systemName: "arrow.up.doc")
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
                        Image(systemName: "arrow.down.doc")
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
        .background(.clear) // Use a clear background to prevent any visual breaks
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
}

