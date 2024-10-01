import CoreData
import CloudKit
import SwiftUI

final class CoreDataManager: ObservableObject {
    let persistenceController: PersistenceController
    static let shared = CoreDataManager(persistenceController: PersistenceController.shared)

    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        setupObservers()
    }

//    var persistentContainer: NSPersistentCloudKitContainer {
//        return persistenceController.container
//    }
    
    var persistentContainer: NSPersistentContainer {
        return persistenceController.container
    }


    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave), name: .NSManagedObjectContextDidSave, object: nil)
    }

    @objc private func contextDidSave(_ notification: Notification) {
        let context = notification.object as! NSManagedObjectContext
        if context === viewContext {
            backgroundContext.perform {
                self.backgroundContext.mergeChanges(fromContextDidSave: notification)
            }
        } else if context === backgroundContext {
            viewContext.perform {
                self.viewContext.mergeChanges(fromContextDidSave: notification)
            }
        }
    }
    
    func createEntry(in context: NSManagedObjectContext, for date: Date, shouldSync: Bool = false) -> Entry {
        let store = getAppropriateStore(for: shouldSync)
        let entry = Entry(context: context)
//        if entry.relationship != nil {
//            entry.logId = entry.relationship?.id
////            entry.relationship?.entry_ids.append(entry.id.uuidString)
//            entry.relationship = nil //remove relationship before moving to cloud
//            entry.relationship?.removeFromRelationship(entry)
//            print("removed log from relationship")
//        }
        do {
            try context.assign(entry, to: store)
            
            // Fetch or create the appropriate log
//            if let log = fetchOrCreateLog(for: date, in: context, store: store) {
//                entry.logId = log.id
////                entry.relationship = log
////                log.addToRelationship(entry)
//            } else {
//                print("Failed to fetch or create log for entry")
//            }
        } catch {
            print("Error assigning entry to store: \(error)")
        }
        return entry
    }

//    
    func fetchOrCreateLog(for date: Date, in context: NSManagedObjectContext, store: NSPersistentStore) -> Log? {
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "day == %@", formattedDate(date))
        fetchRequest.affectedStores = [store]
        
        do {
            let logs = try context.fetch(fetchRequest)
            if let existingLog = logs.first {
                return existingLog
            } else {
                let newLog = Log(context: context)
                newLog.id = UUID()
                newLog.day = formattedDate(date)
                try context.assign(newLog, to: store)
                return newLog
            }
        } catch {
            print("Failed to fetch or create Log: \(error)")
            return nil
        }
    }
    
    func saveEntry(_ entry: Entry) {
        print("Entered saveEntry")
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            
            do {
                let shouldSync = entry.shouldSyncWithCloudKit
                let targetStore = self.getAppropriateStore(for: shouldSync)
                print("Target store: \(targetStore.configurationName ?? "Unknown")")
                
                if let existingEntry = self.fetchExistingEntryFromAnyStore(with: entry.id) {
                    try self.handleExistingEntry(existingEntry, newEntry: entry, targetStore: targetStore)
                } else {
                    try self.createNewEntry(from: entry, in: targetStore)
                }
                
                try self.saveAndSyncIfNeeded(shouldSync: shouldSync)
                
                print("Entry saved successfully: \(entry.id)")
            } catch {
                print("Failed to save entry: \(error)")
            }
        }
    }

    private func handleExistingEntry(_ existingEntry: Entry, newEntry: Entry, targetStore: NSPersistentStore) throws {
        let isInCloudStore = isEntryInCloudStorage(existingEntry)
        
        if isEntryInCorrectStore(targetStore: targetStore, isInCloudStore: isInCloudStore) {
            updateExistingEntry(existingEntry, with: newEntry)
        } else {
            try moveEntryToCorrectStore(existingEntry, newEntry: newEntry, targetStore: targetStore)
        }
    }

    private func isEntryInCorrectStore(targetStore: NSPersistentStore, isInCloudStore: Bool) -> Bool {
        return (targetStore.configurationName == "Cloud" && isInCloudStore) ||
               (targetStore.configurationName != "Cloud" && !isInCloudStore)
    }

    private func updateExistingEntry(_ existingEntry: Entry, with newEntry: Entry) {
        self.updateEntryProperties(existingEntry, from: newEntry)
        print("Updated existing entry in correct store: \(existingEntry.id)")
    }

//    private func moveEntryToCorrectStore(_ existingEntry: Entry, newEntry: Entry, targetStore: NSPersistentStore) throws {
//        let movedEntry = Entry(context: self.backgroundContext)
//        movedEntry.id = newEntry.id
//        self.updateEntryProperties(movedEntry, from: newEntry)
//        
//        self.backgroundContext.delete(existingEntry)
//        try self.backgroundContext.assign(movedEntry, to: targetStore)
//        
//        print("Moved entry to correct store: \(movedEntry.id)")
//    }
    
    private func moveEntryToCorrectStore(_ existingEntry: Entry, newEntry: Entry, targetStore: NSPersistentStore) throws {
        // Step 1: Remove the existing entry from its current store
        let currentStore = getAppropriateStore(for: existingEntry.shouldSyncWithCloudKit)
            
        if existingEntry.shouldSyncWithCloudKit != newEntry.shouldSyncWithCloudKit {
                // Only delete if it's in a different store
                
                self.backgroundContext.delete(existingEntry)
                try self.backgroundContext.save() // Save to ensure the deletion is processed
            } else {
                // If it's already in the correct store, just update it
                self.updateEntryProperties(existingEntry, from: newEntry)
                try self.backgroundContext.save()
                print("Entry updated in place: \(existingEntry.id)")
                return
            }
        

        // Step 2: Create a new entry in the target store
        let movedEntry = Entry(context: self.backgroundContext)
        movedEntry.id = newEntry.id
        self.updateEntryProperties(movedEntry, from: newEntry)
        
        // Step 3: Assign the new entry to the target store
        try self.backgroundContext.assign(movedEntry, to: targetStore)
        
        // Step 4: Save the context to ensure changes are persisted
        try self.backgroundContext.save()
        
        print("Moved entry to correct store: \(movedEntry.id)")
    }

    private func createNewEntry(from entry: Entry, in targetStore: NSPersistentStore) throws {
        let newEntry = Entry(context: self.backgroundContext)
        newEntry.id = entry.id
        self.updateEntryProperties(newEntry, from: entry)
        try self.backgroundContext.assign(newEntry, to: targetStore)
        print("Created new entry: \(newEntry.id)")
    }

    private func saveAndSyncIfNeeded(shouldSync: Bool) throws {
        try self.backgroundContext.save()
        
        if shouldSync {
            self.syncWithCloudKit(context: self.backgroundContext)
        }
    }

    func fetchExistingEntryFromAnyStore(with id: UUID) -> Entry? {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try backgroundContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch existing entry: \(error)")
            return nil
        }
    }

    private func updateEntryProperties(_ target: Entry, from source: Entry) {
        print("Updating entry properties")
        
        // Update all properties
        target.stampIcon = source.stampIcon
        target.color = source.color
        target.content = source.content
        target.title = source.title
        target.previousContent = source.previousContent
        target.time = source.time
        target.lastUpdated = source.lastUpdated ?? Date()
        target.name = source.name
        target.stampName = source.stampName
        target.reminderId = source.reminderId
        target.mediaFilename = source.mediaFilename
        target.mediaFilenames = source.mediaFilenames
        target.entryReplyId = source.entryReplyId
        target.isHidden = source.isHidden
        target.isShown = source.isShown
        target.isPinned = source.isPinned
        target.isRemoved = source.isRemoved
        target.isDrafted = source.isDrafted
        target.shouldSyncWithCloudKit = source.shouldSyncWithCloudKit
        target.stampIndex = source.stampIndex
        target.pageNum_pdf = source.pageNum_pdf
    }


//     private func fetchOrCreateLog(for date: Date, in context: NSManagedObjectContext) -> Log? {
//         let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
//         fetchRequest.predicate = NSPredicate(format: "day == %@", formattedDate(date))
//
//         do {
//             let logs = try context.fetch(fetchRequest)
//             if let existingLog = logs.first {
//                 return existingLog
//             } else {
//                 let newLog = Log(context: context)
//                 newLog.id = UUID()
//                 newLog.day = formattedDate(date)
//                 return newLog
//             }
//         } catch {
//             print("Failed to fetch or create Log: \(error)")
//             return nil
//         }
//     }
    
    func printConfigurationNames() {
        let stores = persistentContainer.persistentStoreCoordinator.persistentStores
        print("Persistent Stores Configuration Names:")
        for (index, store) in stores.enumerated() {
            print("Store \(index + 1): \(store.configurationName ?? "No configuration name")")
            print("  - URL: \(store.url?.absoluteString ?? "No URL")")
            print("  - Type: \(store.type)")
        }
        print("Total number of stores: \(stores.count)")
    }




       private func getAppropriateStore(for shouldSyncWithCloudKit: Bool) -> NSPersistentStore {
           print("ENTERED getAppropriateStore")
           print("persistentContainer.persistentStoreCoordinator.persistentStores: ", persistentContainer.persistentStoreCoordinator.persistentStores)
           if shouldSyncWithCloudKit {
               print("USING CLOUD STORE")
               return persistentContainer.persistentStoreCoordinator.persistentStores.first { $0.configurationName == "Cloud" }!
           } else {
               print("USING LOCAL STORE")
               if let store = persistentContainer.persistentStoreCoordinator.persistentStores.first { $0.configurationName == "PF_DEFAULT_CONFIGURATION_NAME" } {
                   return store
               } else {
                   print("USING LOCAL STORENO MATTER WHAT")
                   print("persistentContainer.persistentStoreCoordinator.persistentStores: \(persistentContainer.persistentStoreCoordinator.persistentStores)")
                   printConfigurationNames()
                   return persistentContainer.persistentStoreCoordinator.persistentStores[0]
               }
           }
       }



    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func syncWithCloudKit(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "shouldSyncWithCloudKit == YES")

        guard let cloudStore = persistentContainer.persistentStoreCoordinator.persistentStores.first(where: { $0.configurationName == "Cloud" }) else {
            print("Error: Cloud store not found")
            return
        }

        fetchRequest.affectedStores = [cloudStore]

        do {
            let entriesToSync = try context.fetch(fetchRequest)
            print("Syncing \(entriesToSync.count) entries to CloudKit")
            
            CloudKitManager.shared.syncSpecificEntries(entries: entriesToSync) { error in
                if let error = error {
                    print("Error syncing with CloudKit: \(error.localizedDescription)")
                } else {
                    print("Successfully synced \(entriesToSync.count) entries to CloudKit")
                    // Optionally, update the UI or perform any post-sync operations here
                }
            }
        } catch {
            print("Failed to fetch entries for sync: \(error.localizedDescription)")
        }
    }


    func fetchEntries(shouldSyncWithCloudKit: Bool) -> [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate =   NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "time >= %@ OR isPinned == true", Calendar.current.startOfDay(for: Date()) as NSDate),
//            NSPredicate(format: "shouldSyncWithCloudKit == %@", NSNumber(value: shouldSyncWithCloudKit))
        ])
        
        let affectedStore = getAppropriateStore(for: shouldSyncWithCloudKit) //Local or Cloud
        
        let context: NSManagedObjectContext
        if shouldSyncWithCloudKit {
            context = backgroundContext
        } else {
            context = viewContext
        }

        fetchRequest.affectedStores = [affectedStore]

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch entries: \(error)")
            return []
        }
    }

    func saveFetchedEntries(_ entries: [Entry]) {
         let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
         let context = viewContext

         for entry in entries {
             fetchRequest.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)

             do {
                 let existingEntries = try context.fetch(fetchRequest)
                 if existingEntries.isEmpty {
                     context.insert(entry)
                 } else {
                     if let existingEntry = existingEntries.first {
                         updateEntry(existingEntry, with: entry)
                     }
                 }
             } catch {
                 print("Failed to fetch entry: \(error)")
             }
             saveEntry(entry)
         }
//         save(context: context)
     }

    

    func save(context: NSManagedObjectContext) {
        print("ENTERED THE GENERIC SAVE")
        context.performAndWait {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
func saveData() {
    print("entered saveData")
    if backgroundContext.hasChanges {
        save(context: backgroundContext)
        mergeChanges(from: backgroundContext)
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Failed to save viewContext: \(error)")
            }
        }
    }
}

func mergeChanges(from context: NSManagedObjectContext) {
    NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: context)
}


  func undo() {
    viewContext.undoManager?.undo()
    saveData()
  }
  
  // MARK: - Convenience Core Data Fetch Methods
  func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {

    do {
      return try viewContext.fetch(request)
    } catch {
        print("Failed to fetch data: \(error)")
        return []
      // Handle fetch error

    }

  }
  func fetchInBackground<T: NSManagedObject>(request: NSFetchRequest<T>, completion: @escaping ([T]) -> Void) {
    backgroundContext.performAndWait {
        do {
            let results = try self.backgroundContext.fetch(request)
            completion(results)
        } catch {
            print("Failed to fetch data: \(error)")
            completion([])
        }
    }
}
    
    func updateEntry(entry: Entry, with record: CKRecord) {
        entry.content = record["content"] as? String ?? ""
        entry.time = record["time"] as? Date ?? Date()
        entry.lastUpdated = record["lastUpdated"] as? Date
        entry.stampIcon = record["stampIcon"] as? String ?? ""
        entry.name = record["name"] as? String
        entry.reminderId = record["reminderId"] as? String
        entry.mediaFilename = record["mediaFilename"] as? String
        entry.mediaFilenames = record["mediaFilenames"] as? [String]
        entry.entryReplyId = record["entryReplyId"] as? String
        entry.isHidden = record["isHidden"] as? Bool ?? false
        entry.isShown = record["isShown"] as? Bool ?? true
        entry.isPinned = record["isPinned"] as? Bool ?? false
        entry.isRemoved = record["isRemoved"] as? Bool ?? false
        entry.isDrafted = record["isDrafted"] as? Bool ?? false
        entry.shouldSyncWithCloudKit = record["shouldSyncWithCloudKit"] as? Bool ?? true
        entry.stampIndex = record["stampIndex"] as? Int16 ?? 0
        entry.pageNum_pdf = record["pageNum_pdf"] as? Int16 ?? 0

        saveEntry(entry)
    }
    
    func fetchEntriesByLog() -> [Log: [Entry]] {
        let logFetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        let entryFetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        
        do {
            let logs = try persistentContainer.viewContext.fetch(logFetchRequest)
            let entries = try persistentContainer.viewContext.fetch(entryFetchRequest)
            
            var result: [Log: [Entry]] = Dictionary(uniqueKeysWithValues: logs.map { ($0, []) })
            
            for entry in entries {
                if let relationship = entry.relationship as? Log {
                    result[relationship, default: []].append(entry)
                } else {
                    let dateString = Date.formattedDate(time: entry.time)
                    if let matchingLog = logs.first(where: { $0.day == dateString }) {
                        result[matchingLog, default: []].append(entry)
                    } else {
                        // If no matching log is found, create a new one
                        let newLog = Log(context: persistentContainer.viewContext)
                        newLog.day = dateString
                        newLog.id = UUID()
                        result[newLog] = [entry]
                        
                        // Optionally, you might want to save the context here to persist the new log
                        // try persistentContainer.viewContext.save()
                    }
                }
            }
            
            return result
        } catch {
            print("Failed to fetch entries or logs: \(error)")
            return [:]
        }
    }


    func fetchEntriesCountByStampIcon() -> [String: Int] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        do {
            let entries = try persistentContainer.viewContext.fetch(fetchRequest)
            return Dictionary(grouping: entries, by: { $0.stampIcon ?? "Unknown" })
                .mapValues { $0.count }
        } catch {
            print("Failed to fetch entries: \(error)")
            return [:]
        }
    }
    
    
    func updateEntry(_ existingEntry: Entry, with newEntry: Entry) {
        print("Entered updateEntry")
           existingEntry.content = newEntry.content
           existingEntry.time = newEntry.time
           existingEntry.lastUpdated = newEntry.lastUpdated
           existingEntry.stampIcon = newEntry.stampIcon
           existingEntry.name = newEntry.name
           existingEntry.reminderId = newEntry.reminderId
           existingEntry.mediaFilename = newEntry.mediaFilename
           existingEntry.mediaFilenames = newEntry.mediaFilenames
           existingEntry.entryReplyId = newEntry.entryReplyId
           existingEntry.isHidden = newEntry.isHidden
           existingEntry.isShown = newEntry.isShown
           existingEntry.isPinned = newEntry.isPinned
           existingEntry.isRemoved = newEntry.isRemoved
           existingEntry.isDrafted = newEntry.isDrafted
           existingEntry.shouldSyncWithCloudKit = newEntry.shouldSyncWithCloudKit
           existingEntry.stampIndex = newEntry.stampIndex
           existingEntry.pageNum_pdf = newEntry.pageNum_pdf

        saveEntry(existingEntry)
       }
    
    func deleteAllLogEntities() {
        let context = self.viewContext
        
        // Create a fetch request for the Log entity
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Log")
        
        // Create a batch delete request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            // Perform the batch delete
            try context.execute(batchDeleteRequest)
            
            // Save the context to persist the changes
            try context.save()
            
            print("Successfully deleted all Log entities")
        } catch {
            print("Failed to delete Log entities: \(error)")
        }
        
        // Refresh the view context to ensure it reflects the changes
        context.reset()
    }

    func deleteAllLogEntitiesWithUndo() {
        print("Deleting all logs permanently")
        let context = self.viewContext
        
        // Create a fetch request for the Log entity
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Log")
        
        do {
            // Fetch all Log entities
            let logs = try context.fetch(fetchRequest)
            
            // Delete each Log entity
            for log in logs {
                print("Deleting log: \(log)")
                context.delete(log)
            }
            
            // Save the context to persist the changes
            try context.save()
            
            print("Successfully deleted all Log entities")
        } catch {
            print("Failed to delete Log entities: \(error)")
        }
    }

}


extension CoreDataManager {
    func isEntryInCloudStorage(_ entry: Entry) -> Bool {
        guard let cloudStore = getCloudStore() else {
            print("Cloud store not found")
            return false
        }
        
        let entryObjectID = entry.objectID
        do {
            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "SELF == %@", entryObjectID)
            fetchRequest.fetchLimit = 1
            fetchRequest.affectedStores = [cloudStore]
            
            let result = try backgroundContext.fetch(fetchRequest)
            let isInCloud = !result.isEmpty
            print("Entry is \(isInCloud ? "" : "not ")in cloud storage")
            return isInCloud
        } catch {
            print("Error checking if entry is in cloud storage: \(error)")
            return false
        }
    }

    func isEntryInLocalStorage(_ entry: Entry) -> Bool {
        guard let localStore = getLocalStore() else {
            print("Local store not found")
            return false
        }
        
        let entryObjectID = entry.objectID
        do {
            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "SELF == %@", entryObjectID)
            fetchRequest.fetchLimit = 1
            fetchRequest.affectedStores = [localStore]
            
            let result = try backgroundContext.fetch(fetchRequest)
            let isInLocal = !result.isEmpty
            print("Entry is \(isInLocal ? "" : "not ")in local storage")
            return isInLocal
        } catch {
            print("Error checking if entry is in local storage: \(error)")
            return false
        }
    }

    private func getCloudStore() -> NSPersistentStore? {
        let coordinator = persistentContainer.persistentStoreCoordinator
        let cloudStore = coordinator.persistentStores.first { store in
            store.configurationName == "Cloud"
        }
        return cloudStore
    }

    private func getLocalStore() -> NSPersistentStore? {
        let coordinator = persistentContainer.persistentStoreCoordinator
        let localStore = coordinator.persistentStores.first { store in
            store.configurationName == nil || store.configurationName == ""
        }
        return localStore
    }
}

