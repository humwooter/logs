////
////  NewLogDataView.swift
////  entry-1
////
////  Created by Katyayani G. Raman on 7/18/24.
////
//import Foundation
//import SwiftUI
//import UniformTypeIdentifiers
//import CoreData
//
//func defaultEntriesName() -> String {
//    let date = Date()
//    let formatter = DateFormatter()
//    formatter.dateFormat = "M-d-yy"
//    let dateString = formatter.string(from: date)
//    return "entries backup \(dateString)"
//}
//
//struct LogsDataView: View {
//    @EnvironmentObject var userPreferences: UserPreferences
//    @EnvironmentObject var coreDataManager: CoreDataManager
//    @EnvironmentObject var datesModel: DatesModel
//    
//    @Environment(\.colorScheme) var colorScheme
//    @FetchRequest(
//        entity: Entry.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: true)]
//    ) var entries: FetchedResults<Entry>
//    
//    @State private var isExporting = false
//    @State private var isImporting = false
//    
//    @State private var isHidden = false
//    @Binding var showNotification: Bool
//    @Binding var isSuccess: Bool
//    @Binding var isFailure: Bool
//    @State private var notificationMessage = ""
//    
//    var body: some View {
//        Section {
//            if !isHidden {
//                mainView()
//            }
//        } header: {
//            HStack {
//                Image(systemName: "book.fill").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
//                Text("Entries Data").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
//                Spacer()
//                Image(systemName: isHidden ? "chevron.down" : "chevron.up").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
//            }
//            .font(.system(size: UIFont.systemFontSize))
//            .onTapGesture {
//                isHidden.toggle()
//            }
//        }
//        .background(.clear)
//    }
//    
//    @ViewBuilder
//    func mainView() -> some View {
//        HStack {
//            Spacer()
//            Button {
//                exportData()
//                print("Export button tapped")
//                isExporting = true
//            } label: {
//                VStack(spacing: 2) {
//                    Image(systemName: "arrow.up.doc")
//                    Text("BACKUP").fontWeight(.bold).font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
//                }
//            }
//            .fileExporter(isPresented: $isExporting, document: EntriesDocument(entries: Array(entries)), contentType: .json, defaultFilename: "\(defaultEntriesName()).json") { result in
//                switch result {
//                case .success(let url):
//                    showNotification = true
//                    isSuccess = true
//                    isFailure = false
//                    notificationMessage = "Export Complete"
//                    print("File successfully saved at \(url)")
//                case .failure(let error):
//                    showNotification = true
//                    isSuccess = false
//                    isFailure = true
//                    notificationMessage = "Export Cancelled"
//                    print("Failed to save file: \(error)")
//                }
//            }
//            .buttonStyle(BackupButtonStyle())
//            .foregroundColor(Color(UIColor.tertiarySystemBackground))
//            
//            Spacer()
//            Button {
//                isImporting = true
//            } label: {
//                VStack(spacing: 2) {
//                    Image(systemName: "arrow.down.doc")
//                    Text("RESTORE").fontWeight(.bold).font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
//                }
//            }
//            .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
//                Task {
//                    switch result {
//                    case .success(let url):
//                        do {
//                            try await importData(from: url)
//                            showNotification = true
//                            isSuccess = true
//                            isFailure = false
//                            notificationMessage = "Import Completed"
//                        } catch {
//                            print("Failed to import data: \(error)")
//                        }
//                    case .failure(let error):
//                        showNotification = true
//                        isSuccess = false
//                        isFailure = true
//                        notificationMessage = "Import Cancelled"
//                        print("Failed to import file: \(error)")
//                    }
//                }
//            }
//            .alert(isPresented: $showNotification) {
//                if isSuccess {
//                    Alert(title: Text("Success"), message: Text(notificationMessage), dismissButton: .default(Text("OK")))
//                } else if isFailure {
//                    Alert(title: Text("Failure"), message: Text("Data failed to export or import"), dismissButton: .default(Text("OK")))
//                } else {
//                    Alert(title: Text("Failure"), message: Text("Data failed to export or import"), dismissButton: .default(Text("OK")))
//                }
//            }
//            .buttonStyle(RestoreButtonStyle())
//            .foregroundColor(colorScheme == .dark ? .black : .white)
//            
//            Spacer()
//        }
//        .zIndex(1)
//    }
//    
//    func updateDates() {
//        print("updating the date range")
//        // Fetch all logs after import is done
//        let logFetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
//        do {
//            let allLogs = try coreDataManager.viewContext.fetch(logFetchRequest)
//            print("Fetched logs: \(allLogs.count)")
//            self.datesModel.updateDateRange(with: allLogs)
//        } catch {
//            print("Failed to fetch logs for date range update: \(error)")
//        }
//    }
//
//    func importLogs(from jsonArray: [[String: Any]]) throws {
//        let context = coreDataManager.backgroundContext
//        
//        context.performAndWait {
//            do {
//                for jsonObject in jsonArray {
//                    print("Processing log jsonObject: \(jsonObject)")
//                    
//                    guard let logDayString = jsonObject["day"] as? String,
//                          let logIdString = jsonObject["id"] as? String else {
//                        print("Missing required log fields, skipping: \(jsonObject)")
//                        continue
//                    }
//                    
//                    // Fetch or create the log
//                    let logFetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
//                    logFetchRequest.predicate = NSPredicate(format: "day == %@", logDayString)
//                    
//                    let existingLogs = try context.fetch(logFetchRequest)
//                    let log: Log
//                    let entryIds = jsonObject["entry_ids"] as? [String] ?? []
//
//                    if let existingLog = existingLogs.first {
//                        log = existingLog
//                        print("Found existing log: \(log)")
//                    } else {
//                        log = Log(context: context)
//                        log.day = logDayString
//                        log.id = UUID(uuidString: logIdString) ?? UUID()
//                        log.entry_ids = entryIds
//                        print("Created new log: \(log)")
//                    }
//                    
//                    // Updating dates
//                    let dateStringsManager = DateStrings()
//                    datesModel.addDateIfNotExists(dateString: log.day)
//                    dateStringsManager.addDate(log.day)
//                    print("Updated dates for log: \(log.day)")
//
//                    // Fetch or create entries
//                    for entryIdString in log.entry_ids {
//                        print("Processing entryIdString: \(entryIdString)")
//                        
//                        let entryFetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//                        entryFetchRequest.predicate = NSPredicate(format: "id == %@", entryIdString)
//                        
//                        let existingEntries = try context.fetch(entryFetchRequest)
//                        
//                        if existingEntries.isEmpty {
//                            // This is a new entry, add it
//                            if let entryData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) {
//                                let decoder = JSONDecoder()
//                                decoder.userInfo[CodingUserInfoKey.managedObjectContext] = context
//                                if let newEntry = try? decoder.decode(Entry.self, from: entryData) {
//                                    newEntry.logId = log.id
//                                    log.addEntryId(newEntry.id.uuidString)
//                                    context.insert(newEntry)
//                                    print("New entry created with ID: \(newEntry.id.uuidString), assigned to log: \(log.id)")
//                                }
//                            }
//                        } else {
//                            if let existingEntry = existingEntries.first {
//                                existingEntry.logId = log.id
//                                log.addEntryId(existingEntry.id.uuidString)
//                            }
//                            print("Entry with ID: \(entryIdString) already exists, skipping")
//                        }
//                    }
//                    
//                    if let newEntries = jsonObject["relationship"] as? [[String: Any]] {
//                        for newEntryData in newEntries {
//                            print("Processing newEntryData: \(newEntryData)")
//                            if let newEntryIdString = newEntryData["id"] as? String,
//                               let newEntryId = UUID(uuidString: newEntryIdString) {
//                                
//                                let entryFetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//                                entryFetchRequest.predicate = NSPredicate(format: "id == %@", newEntryId as CVarArg)
//                                
//                                do {
//                                    let existingEntries = try coreDataManager.viewContext.fetch(entryFetchRequest)
//                                    
//                                    if let existingEntry = existingEntries.first {
//                                        // Entry exists, update its logId
//                                        print("Updating existing entry")
//                                        existingEntry.logId = log.id
//                                    } else {
//                                        // This is a new entry, create and add it to the log
//                                        print("Creating new entry")
//                                        if let entryData = try? JSONSerialization.data(withJSONObject: newEntryData, options: []) {
//                                            let decoder = JSONDecoder()
//                                            decoder.userInfo[CodingUserInfoKey.managedObjectContext] = coreDataManager.viewContext
//                                            if let newEntry = try? decoder.decode(Entry.self, from: entryData) {
//                                                newEntry.logId = log.id
//                                                coreDataManager.viewContext.insert(newEntry)
//                                                print("New entry created and added to log")
//                                            }
//                                        }
//                                    }
//                                    
//                                    // Ensure the entry ID is in the log's entry_ids array
//                                    if !log.entry_ids.contains(newEntryIdString) {
//                                        log.entry_ids.append(newEntryIdString)
//                                    }
//                                    
//                                } catch {
//                                    print("Error processing entry: \(error)")
//                                }
//                            }
//                        }
//                        
//                        // Save changes
//                        do {
//                            try coreDataManager.viewContext.save()
//                            print("Changes saved successfully")
//                        } catch {
//                            print("Error saving changes: \(error)")
//                        }
//                    }
//                    
//                    
//                    context.insert(log)
//                }
//                try context.save()
//                print("Successfully saved logs and entries")
//            } catch {
//                print("Failed to import logs: \(error)")
//            }
//        }
//    }
//    
//    func importEntries(from jsonArray: [[String: Any]]) throws {
//        let context = coreDataManager.backgroundContext
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        
//        try context.performAndWait {
//            do {
//                for jsonObject in jsonArray {
//                    print("Processing entry jsonObject: \(jsonObject)")
//                    
//                    guard let entryIdString = jsonObject["id"] as? String,
//                          let entryId = UUID(uuidString: entryIdString),
//                          let timeString = jsonObject["time"] as? String,
//                          let entryTime = ISO8601DateFormatter().date(from: timeString) else {
//                        print("Missing required entry fields, skipping: \(jsonObject)")
//                        continue
//                    }
//                    
//                    let entryDayString = dateFormatter.string(from: entryTime)
//                    
//                    // Fetch or create the log
//                    let logFetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
//                    logFetchRequest.predicate = NSPredicate(format: "day == %@", entryDayString)
//                    
//                    let existingLogs = try context.fetch(logFetchRequest)
//                    let log: Log
//                    
//                    if let existingLog = existingLogs.first {
//                        log = existingLog
//                        print("Found existing log: \(log)")
//                    } else {
//                        log = Log(context: context)
//                        log.day = entryDayString
//                        log.id = UUID()
//                        print("Created new log: \(log)")
//                    }
//                    
//                    // Updating dates
//                    let dateStringsManager = DateStrings()
//                    datesModel.addDateIfNotExists(dateString: entryDayString)
//                    dateStringsManager.addDate(entryDayString)
//                    print("Updated dates for log: \(entryDayString)")
//
//                    // Add the entry ID to the log's entry_ids if not already present
//                    if !log.entry_ids.contains(entryIdString) {
//                        log.entry_ids.append(entryIdString)
//                    }
//                    
//                    // Fetch or create the entry
//                    let entryFetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//                    entryFetchRequest.predicate = NSPredicate(format: "id == %@", entryIdString)
//                    
//                    let existingEntries = try context.fetch(entryFetchRequest)
//                    
//                    if existingEntries.isEmpty {
//                        // This is a new entry, add it
//                        do {
//                            let entryData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
//                            let decoder = JSONDecoder()
//                            decoder.userInfo[CodingUserInfoKey.managedObjectContext] = context
//                            let newEntry = try decoder.decode(Entry.self, from: entryData)
//                            newEntry.logId = log.id
//                            context.insert(newEntry)
//                            print("New entry created with ID: \(newEntry.id.uuidString), assigned to log: \(log.id)")
//                        } catch {
//                            print("Error creating new entry: \(error)")
//                            throw error
//                        }
//                    } else {
//                        if let existingEntry = existingEntries.first {
//                            existingEntry.logId = log.id
//                            print("Updated existing entry with ID: \(existingEntry.id.uuidString), assigned to log: \(log.id)")
//                        }
//                    }
//                }
//                try context.save()
//                print("Successfully saved entries")
//            } catch {
//                print("Failed to import entries: \(error)")
//                throw error
//            }
//        }
//    }
//    
//    func importData(from url: URL) async throws {
//        print("entered import data")
//        
//        guard url.startAccessingSecurityScopedResource() else {
//            throw NSError(domain: "Security", code: 1, userInfo: nil)
//        }
//        defer { url.stopAccessingSecurityScopedResource() }
//        
//        let jsonData = try Data(contentsOf: url)
//        
//        do {
//            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
//                print("Parsed JSON array: \(jsonArray.count) items")
//                if jsonArray.first?["day"] != nil {
//                    try importLogs(from: jsonArray)
//                } else {
//                    try importEntries(from: jsonArray)
//                }
//            }
//        } catch {
//            print("Failed to parse JSON: \(error)")
//            throw error
//        }
//    }
//
//    private func exportData() {
//        do {
//            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//            let entries = try coreDataManager.backgroundContext.fetch(fetchRequest)
//            
//            guard !entries.isEmpty else {
//                print("No entries to export")
//                return
//            }
//            
//            isExporting = true
//            print("Exporting \(entries.count) entries")
//            // Add export logic here
//        } catch {
//            print("Failed to fetch entries: \(error)")
//        }
//    }
//
//}
//
//struct EntriesDocument: FileDocument {
//    static var readableContentTypes: [UTType] { [.json] }
//
//    var entries: [Entry]
//
//    init(entries: [Entry]) {
//        self.entries = entries
//    }
//
//    init(configuration: ReadConfiguration) throws {
//        guard let data = configuration.file.regularFileContents,
//              let entries = try? JSONDecoder().decode([Entry].self, from: data)
//        else {
//            throw CocoaError(.fileReadCorruptFile)
//        }
//        self.entries = entries
//    }
//
//    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
//        let data = try JSONEncoder().encode(entries)
//        return .init(regularFileWithContents: data)
//    }
//}
