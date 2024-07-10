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

    var persistentContainer: NSPersistentCloudKitContainer {
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

    func saveEntry(_ entry: Entry) {
        print("ENTERED SAVE ENTRY")
         backgroundContext.perform { [weak self] in
             guard let self = self else { return }
             
             do {
                 removeEntryFromAllStores(entry)
                 let store = self.getAppropriateStore(for: entry.shouldSyncWithCloudKit)
                 print("STORE: \(store)")
                 
                 // Fetch or create the entry in the background context
                 let backgroundEntry: Entry
                 if let existingEntry = try self.fetchExistingEntry(with: entry.id, in: store, context: self.backgroundContext) {
                     backgroundEntry = existingEntry
                 } else {
                     print("ENTRY DOES NOT EXIST")
                     removeEntryFromAllStores(entry)
                     backgroundEntry = Entry(context: self.backgroundContext)
                     backgroundEntry.id = entry.id
                     try self.backgroundContext.assign(backgroundEntry, to: store)
                 }

                 // Update entry properties
                 self.updateEntryProperties(backgroundEntry, from: entry)

                 // Fetch or create the associated Log in the background context
                 if let log = self.fetchOrCreateLog(for: backgroundEntry.time, in: self.backgroundContext) {
                     backgroundEntry.relationship = log
                 }

                 // Save the context
                 try self.backgroundContext.save()

                 // Sync with CloudKit if necessary
                 if backgroundEntry.shouldSyncWithCloudKit {
                     self.syncWithCloudKit(context: self.backgroundContext)
                 }

             } catch {
                 print("Failed to save entry: \(error)")
             }
         }
     }
    
    private func removeEntryFromAllStores(_ entry: Entry) {
        print("REMOVING ENTRY FROM ALL STORES")
        let stores = persistentContainer.persistentStoreCoordinator.persistentStores
        print("STORES: \(stores)")
        for store in stores {
            do {
                if let existingEntry = try fetchExistingEntry(with: entry.id, in: store, context: backgroundContext) {
                    backgroundContext.delete(existingEntry)
                    print("Removed entry from store: \(store.configurationName ?? "Unknown")")
                }
            } catch {
                print("Failed to remove entry from store \(store.configurationName ?? "Unknown"): \(error)")
            }
        }
    }

     private func fetchExistingEntry(with id: UUID, in store: NSPersistentStore, context: NSManagedObjectContext) throws -> Entry? {
         let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
         fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
         fetchRequest.fetchLimit = 1
         fetchRequest.affectedStores = [store]
         
         let results = try context.fetch(fetchRequest)
         return results.first
     }

    private func updateEntryProperties(_ target: Entry, from source: Entry) {
        // Compare lastUpdated dates
        let recentEntry = source.lastUpdated ?? source.time > target.lastUpdated  ?? target.time ? source : target
        let lessRecentEntry = source.lastUpdated ?? source.time > target.lastUpdated ?? target.time ? target : source

        // Ensure both entries have the most recent properties
        lessRecentEntry.stampIcon = recentEntry.stampIcon
        lessRecentEntry.color = recentEntry.color
        lessRecentEntry.content = recentEntry.content
        lessRecentEntry.formattedContent = recentEntry.formattedContent
        lessRecentEntry.attributedContent = recentEntry.attributedContent
        lessRecentEntry.title = recentEntry.title
        lessRecentEntry.previousContent = recentEntry.previousContent
        lessRecentEntry.time = recentEntry.time
        lessRecentEntry.lastUpdated = recentEntry.lastUpdated
        lessRecentEntry.name = recentEntry.name
        lessRecentEntry.stampName = recentEntry.stampName
        lessRecentEntry.reminderId = recentEntry.reminderId
        lessRecentEntry.mediaFilename = recentEntry.mediaFilename
        lessRecentEntry.mediaFilenames = recentEntry.mediaFilenames
        lessRecentEntry.entryReplyId = recentEntry.entryReplyId
        lessRecentEntry.isHidden = recentEntry.isHidden
        lessRecentEntry.isShown = recentEntry.isShown
        lessRecentEntry.isPinned = recentEntry.isPinned
        lessRecentEntry.isRemoved = recentEntry.isRemoved
        lessRecentEntry.isDrafted = recentEntry.isDrafted
        lessRecentEntry.shouldSyncWithCloudKit = recentEntry.shouldSyncWithCloudKit
        lessRecentEntry.stampIndex = recentEntry.stampIndex
        lessRecentEntry.pageNum_pdf = recentEntry.pageNum_pdf

        // Ensure both entries are up-to-date
        if recentEntry === source {
            target.stampIcon = source.stampIcon
            target.color = source.color
            target.content = source.content
            target.formattedContent = source.formattedContent
            target.attributedContent = source.attributedContent
            target.title = source.title
            target.previousContent = source.previousContent
            target.time = source.time
            target.lastUpdated = source.lastUpdated
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
        } else {
            source.stampIcon = target.stampIcon
            source.color = target.color
            source.content = target.content
            source.formattedContent = target.formattedContent
            source.attributedContent = target.attributedContent
            source.title = target.title
            source.previousContent = target.previousContent
            source.time = target.time
            source.lastUpdated = target.lastUpdated
            source.name = target.name
            source.stampName = target.stampName
            source.reminderId = target.reminderId
            source.mediaFilename = target.mediaFilename
            source.mediaFilenames = target.mediaFilenames
            source.entryReplyId = target.entryReplyId
            source.isHidden = target.isHidden
            source.isShown = target.isShown
            source.isPinned = target.isPinned
            source.isRemoved = target.isRemoved
            source.isDrafted = target.isDrafted
            source.shouldSyncWithCloudKit = target.shouldSyncWithCloudKit
            source.stampIndex = target.stampIndex
            source.pageNum_pdf = target.pageNum_pdf
        }
    }


     private func fetchOrCreateLog(for date: Date, in context: NSManagedObjectContext) -> Log? {
         let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
         fetchRequest.predicate = NSPredicate(format: "day == %@", formattedDate(date))

         do {
             let logs = try context.fetch(fetchRequest)
             if let existingLog = logs.first {
                 return existingLog
             } else {
                 let newLog = Log(context: context)
                 newLog.id = UUID()
                 newLog.day = formattedDate(date)
                 return newLog
             }
         } catch {
             print("Failed to fetch or create Log: \(error)")
             return nil
         }
     }
    
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
//    func syncWithCloudKit(context: NSManagedObjectContext) {
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "shouldSyncWithCloudKit == YES")
//
//        if let cloudStore = persistentContainer.persistentStoreCoordinator.persistentStores.first(where: { $0.configurationName == "Cloud" }) {
//            fetchRequest.affectedStores = [cloudStore]
//        } else {
//            print("Cloud store not found")
//            return
//        }
//
//        do {
//            let entriesToSync = try context.fetch(fetchRequest)
//            CloudKitManager.shared.syncSpecificEntries(entries: entriesToSync) { error in
//                if let error = error {
//                    print("Error syncing with CloudKit: \(error)")
//                }
//            }
//        } catch {
//            print("Failed to fetch entries for sync: \(error)")
//        }
//    }


    func fetchEntries(shouldSyncWithCloudKit: Bool) -> [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate =   NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "time >= %@ OR isPinned == true", Calendar.current.startOfDay(for: Date()) as NSDate),
            NSPredicate(format: "shouldSyncWithCloudKit == %@", NSNumber(value: shouldSyncWithCloudKit))
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
        context.performAndWait {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
func saveData() {
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
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        do {
            let entries = try persistentContainer.viewContext.fetch(fetchRequest)
            return Dictionary(grouping: entries, by: { $0.relationship })
        } catch {
            print("Failed to fetch entries: \(error)")
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
    

    @objc private func entryDidChange(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            for object in updatedObjects {
                if let entry = object as? Entry {
                    if let shouldSync = entry.changedValues()["shouldSyncWithCloudKit"] as? Bool, shouldSync {
                        CloudKitManager.shared.syncSpecificEntries(entries: [entry]) { error in
                            if let error = error {
                                print("Error syncing entry: \(error.localizedDescription)")
                            } else {
                                print("Successfully synced entry to CloudKit")
                            }
                        }
                    }
                }
            }
        }
    }

}
