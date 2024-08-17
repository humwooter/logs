////
////  NewCoreDataManager.swift
////  entry-1
////
////  Created by Katyayani G. Raman on 7/18/24.
////
//import CoreData
//import CloudKit
//import SwiftUI
//
//final class CoreDataManager: ObservableObject {
//    let persistenceController: PersistenceController
//    static let shared = CoreDataManager(persistenceController: PersistenceController.shared)
//
//    init(persistenceController: PersistenceController) {
//        self.persistenceController = persistenceController
//        setupObservers()
//    }
//
//    var localPersistentContainer: NSPersistentContainer {
//        return persistenceController.localContainer
//    }
//
//    var cloudPersistentContainer: NSPersistentCloudKitContainer? {
//        return persistenceController.cloudContainer
//    }
//
//    var viewContext: NSManagedObjectContext {
//        return localPersistentContainer.viewContext
//    }
//
//    lazy var backgroundContext: NSManagedObjectContext = {
//        let context = localPersistentContainer.newBackgroundContext()
//        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        return context
//    }()
//
//    private func setupObservers() {
//        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave), name: .NSManagedObjectContextDidSave, object: nil)
//    }
//
//    @objc private func contextDidSave(_ notification: Notification) {
//        let context = notification.object as! NSManagedObjectContext
//        if context === viewContext {
//            backgroundContext.perform {
//                self.backgroundContext.mergeChanges(fromContextDidSave: notification)
//            }
//        } else if context === backgroundContext {
//            viewContext.perform {
//                self.viewContext.mergeChanges(fromContextDidSave: notification)
//            }
//        }
//    }
//
//    func createEntry(in context: NSManagedObjectContext, for date: Date, shouldSync: Bool = false) -> Entry {
//        let store = getAppropriateStore(for: shouldSync)
//        let entry = Entry(context: context)
//        do {
//            try context.assign(entry, to: store)
//            
//            if let log = fetchOrCreateLog(for: date, in: context, store: store) {
//                entry.logId = log.id
//            } else {
//                print("Failed to fetch or create log for entry")
//            }
//        } catch {
//            print("Error assigning entry to store: \(error)")
//        }
//        return entry
//    }
//
//    func saveEntry(_ entry: Entry) {
//        backgroundContext.perform { [weak self] in
//            guard let self = self else { return }
//            
//            do {
//                let store = self.getAppropriateStore(for: entry.shouldSyncWithCloudKit)
//                if let existingEntry = try self.fetchExistingEntry(with: entry.id, in: store, context: self.backgroundContext) {
//                    self.removeEntryFromCloudStore(existingEntry)
//                }
//
//                let backgroundEntry = Entry(context: self.backgroundContext)
//                backgroundEntry.id = entry.id
//                self.updateEntryProperties(backgroundEntry, from: entry)
//                try self.backgroundContext.assign(backgroundEntry, to: store)
//
//                if let log = self.fetchOrCreateLog(for: backgroundEntry.time, in: self.backgroundContext, store: store) {
//                    backgroundEntry.relationship = log
//                }
//
//                try self.backgroundContext.save()
//
//            } catch {
//                print("Failed to save entry: \(error)")
//            }
//        }
//    }
//
//    private func fetchExistingEntry(with id: UUID, in store: NSPersistentStore, context: NSManagedObjectContext) throws -> Entry? {
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//        fetchRequest.fetchLimit = 1
//        fetchRequest.affectedStores = [store]
//        
//        let results = try context.fetch(fetchRequest)
//        return results.first
//    }
//
//    private func fetchOrCreateLog(for date: Date, in context: NSManagedObjectContext, store: NSPersistentStore) -> Log? {
//        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "day == %@", formattedDate(date))
//        fetchRequest.affectedStores = [store]
//        
//        do {
//            let logs = try context.fetch(fetchRequest)
//            if let existingLog = logs.first {
//                return existingLog
//            } else {
//                let newLog = Log(context: context)
//                newLog.id = UUID()
//                newLog.day = formattedDate(date)
//                try context.assign(newLog, to: store)
//                return newLog
//            }
//        } catch {
//            print("Failed to fetch or create Log: \(error)")
//            return nil
//        }
//    }
//
//    private func removeEntryFromCloudStore(_ entry: Entry) {
//        if let store = getCloudStore() {
//            do {
//                if let existingEntry = try fetchExistingEntry(with: entry.id, in: store, context: backgroundContext) {
//                    backgroundContext.delete(existingEntry)
//                    print("Removed entry from store: \(store.configurationName ?? "Unknown")")
//                }
//            } catch {
//                print("Failed to remove entry from store \(store.configurationName ?? "Unknown"): \(error)")
//            }
//        } else {
//            print("NO CLOUD STORE")
//        }
//    }
//
//    private func getAppropriateStore(for shouldSyncWithCloudKit: Bool) -> NSPersistentStore {
//        if shouldSyncWithCloudKit {
//            guard let cloudContainer = cloudPersistentContainer else {
//                fatalError("Cloud container is not set")
//            }
//            return cloudContainer.persistentStoreCoordinator.persistentStores.first { $0.configurationName == "Cloud" }!
//        } else {
//            return localPersistentContainer.persistentStoreCoordinator.persistentStores.first { $0.configurationName == "PF_DEFAULT_CONFIGURATION_NAME" }!
//        }
//    }
//
//    private func formattedDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        return formatter.string(from: date)
//    }
//
//    private func getCloudStore() -> NSPersistentStore? {
//        guard let cloudStore = cloudPersistentContainer?.persistentStoreCoordinator.persistentStores.first(where: { $0.configurationName == "Cloud" }) else {
//            print("LOCAL FALLBACK")
//            return nil
//        }
//        return cloudStore
//    }
//
//    func updateEntryProperties(_ target: Entry, from source: Entry) {
//        target.stampIcon = source.stampIcon
//        target.color = source.color
//        target.content = source.content
//        target.title = source.title
//        target.previousContent = source.previousContent
//        target.time = source.time
//        target.lastUpdated = source.lastUpdated
//        target.name = source.name
//        target.stampName = source.stampName
//        target.reminderId = source.reminderId
//        target.mediaFilename = source.mediaFilename
//        target.mediaFilenames = source.mediaFilenames
//        target.entryReplyId = source.entryReplyId
//        target.isHidden = source.isHidden
//        target.isShown = source.isShown
//        target.isPinned = source.isPinned
//        target.isRemoved = source.isRemoved
//        target.isDrafted = source.isDrafted
//        target.shouldSyncWithCloudKit = source.shouldSyncWithCloudKit
//        target.stampIndex = source.stampIndex
//        target.pageNum_pdf = source.pageNum_pdf
//    }
//
//    func save(context: NSManagedObjectContext) {
//        context.performAndWait {
//            do {
//                try context.save()
//            } catch {
//                print("Failed to save context: \(error)")
//            }
//        }
//    }
//
//    func isEntryInCloudStorage(_ entry: Entry) -> Bool {
//        let entryObjectID = entry.objectID
//        if let cloudStore = getCloudStore() {
//            do {
//                let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//                fetchRequest.predicate = NSPredicate(format: "SELF == %@", entryObjectID)
//                fetchRequest.fetchLimit = 1
//                fetchRequest.affectedStores = [cloudStore]
//                
//                let result = try backgroundContext.fetch(fetchRequest)
//                print("RESULT: \(result)")
//                return !result.isEmpty
//            } catch {
//                print("Error checking if entry is in cloud storage: \(error)")
//                return false
//            }
//        } else {
//            print("NO CLOUD STORE")
//            return false
//        }
//    }
//
//    func fetchEntries(shouldSyncWithCloudKit: Bool) -> [Entry] {
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        fetchRequest.predicate = shouldSyncWithCloudKit ? NSPredicate(format: "shouldSyncWithCloudKit == true") : NSPredicate(format: "shouldSyncWithCloudKit == false")
//        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Entry.time, ascending: true)]
//        
//        let context: NSManagedObjectContext = shouldSyncWithCloudKit ? (cloudPersistentContainer?.newBackgroundContext() ?? viewContext) : viewContext
//        do {
//            return try context.fetch(fetchRequest)
//        } catch {
//            print("Failed to fetch entries: \(error)")
//            return []
//        }
//    }
//
//    func fetchCloudEntries() -> [Entry] {
//        return fetchEntries(shouldSyncWithCloudKit: true)
//    }
//
//    func fetchLocalEntries() -> [Entry] {
//        return fetchEntries(shouldSyncWithCloudKit: false)
//    }
//}
