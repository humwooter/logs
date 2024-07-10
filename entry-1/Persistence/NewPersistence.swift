//
//  NewPersistence.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/1/24.
//
//



//import Foundation
//import CoreData
//import CloudKit
//
//class PersistenceController {
//    static let shared = PersistenceController()
//    let container: NSPersistentCloudKitContainer
//    let cloudKitManager = CloudKitManager.shared
//
//    private init(inMemory: Bool = false) {
//        print("DEBUG: Initializing PersistenceController")
//        container = NSPersistentCloudKitContainer(name: "entry_1")
//
//        if inMemory {
//            print("DEBUG: Setting up in-memory store")
//            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
//            container.viewContext.automaticallyMergesChangesFromParent = true
//        } else {
//            print("DEBUG: Setting up persistent stores")
//            
//            // Local store setup
//            let localStoreDescription = NSPersistentStoreDescription()
//            localStoreDescription.configuration = "Default"
//            localStoreDescription.url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("entry_1.sqlite")
//            print("DEBUG: Local store URL: \(localStoreDescription.url?.path ?? "unknown")")
//            localStoreDescription.shouldMigrateStoreAutomatically = true //
//            localStoreDescription.shouldInferMappingModelAutomatically = true
//
//            // Cloud store setup
//            let cloudStoreDescription = NSPersistentStoreDescription()
//            cloudStoreDescription.configuration = "Cloud"
//            cloudStoreDescription.url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("cloud.store")
//            cloudStoreDescription.shouldMigrateStoreAutomatically = true
//            cloudStoreDescription.shouldInferMappingModelAutomatically = true
//            
//            print("DEBUG: Cloud store URL: \(cloudStoreDescription.url?.path ?? "unknown")")
//
//            let cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.gnupes.dodum.logs")
//            cloudStoreDescription.cloudKitContainerOptions = cloudKitContainerOptions
//            print("DEBUG: CloudKit container identifier: \(cloudKitContainerOptions.containerIdentifier)")
//
//            container.persistentStoreDescriptions = [localStoreDescription, cloudStoreDescription]
//        }
//
//        container.loadPersistentStores { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("DEBUG: Unresolved error \(error), \(error.userInfo)")
//            }
//            print("DEBUG: Persistent store loaded: \(storeDescription.configuration)")
//        }
//        
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        print("DEBUG: PersistenceController initialization completed")
//    }
//
//    func enableCloudKitSync(_ enabled: Bool, completion: @escaping (Error?) -> Void) {
//        print("DEBUG: Enabling CloudKit sync: \(enabled)")
//        
//        guard let cloudStoreDescription = container.persistentStoreDescriptions.first(where: { $0.configuration == "Cloud" }) else {
//            let error = NSError(domain: "PersistenceController", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cloud store description not found"])
//            print("DEBUG: Error - \(error.localizedDescription)")
//            completion(error)
//            return
//        }
//
//        if enabled {
//            let cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.gnupes.dodum.logs")
//            cloudStoreDescription.cloudKitContainerOptions = cloudKitContainerOptions
//            print("DEBUG: CloudKit container options set")
//        } else {
//            cloudStoreDescription.cloudKitContainerOptions = nil
//            print("DEBUG: CloudKit container options removed")
//        }
//
//        // Ensure persistent history tracking is enabled
//        cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//        print("DEBUG: NSPersistentHistoryTrackingKey set to true for cloud store")
//
//        // Enable remote change notifications
//        cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
//        print("DEBUG: NSPersistentStoreRemoteChangeNotificationPostOptionKey set to true for cloud store")
//
//        // Reload the cloud store
//        if let cloudStore = container.persistentStoreCoordinator.persistentStores.first(where: { $0.configurationName == "Cloud" }) {
//            do {
//                print("DEBUG: Removing existing cloud store")
//                try container.persistentStoreCoordinator.remove(cloudStore)
//                print("DEBUG: Adding new cloud store")
//                try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: "Cloud", at: cloudStoreDescription.url, options: cloudStoreDescription.options)
//                print("DEBUG: Cloud store reloaded successfully")
//                self.assignEntriesToAppropriateStore()
//                completion(nil)
//            } catch {
//                print("DEBUG: Error reloading cloud store: \(error)")
//                completion(error)
//            }
//        } else {
//            print("DEBUG: Adding new cloud store")
//            do {
//                try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: "Cloud", at: cloudStoreDescription.url, options: cloudStoreDescription.options)
//                print("DEBUG: Cloud store added successfully")
//                self.assignEntriesToAppropriateStore()
//                completion(nil)
//            } catch {
//                print("DEBUG: Error adding cloud store: \(error)")
//                completion(error)
//            }
//        }
//    }
//
//    private func assignEntriesToAppropriateStore() {
//        print("DEBUG: Assigning entries to appropriate store")
//        let context = container.newBackgroundContext()
//        context.perform {
//            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//            do {
//                let entries = try context.fetch(fetchRequest)
//                print("DEBUG: Found \(entries.count) entries to process")
//                for entry in entries {
//                    if entry.shouldSyncWithCloudKit {
//                        self.assignEntryToCloud(entry, context: context)
//                    } else {
//                        self.assignEntryToLocal(entry, context: context)
//                    }
//                }
//                try context.save()
//                print("DEBUG: Entries assigned and context saved")
//            } catch {
//                print("DEBUG: Error assigning entries: \(error)")
//            }
//        }
//    }
//
//     func assignEntryToCloud(_ entry: Entry, context: NSManagedObjectContext) {
//        print("DEBUG: Assigning entry to cloud store: \(entry.id.uuidString)")
//        guard let cloudStore = container.persistentStoreCoordinator.persistentStores.first(where: { $0.configurationName == "Cloud" }) else {
//            print("DEBUG: Cloud store not found")
//            return
//        }
//        
//        context.assign(entry, to: cloudStore)
//        entry.shouldSyncWithCloudKit = true
//        print("DEBUG: Entry assigned to cloud store")
//    }
//
//     func assignEntryToLocal(_ entry: Entry, context: NSManagedObjectContext) {
//        print("DEBUG: Assigning entry to local store: \(entry.id.uuidString)")
//        guard let localStore = container.persistentStoreCoordinator.persistentStores.first(where: { $0.configurationName == "Default" }) else {
//            print("DEBUG: Local store not found")
//            return
//        }
//        
//        context.assign(entry, to: localStore)
//        entry.shouldSyncWithCloudKit = false
//        print("DEBUG: Entry assigned to local store")
//    }
//
//    func sync(preference: UserPreferences.SyncPreference, completion: @escaping (Error?) -> Void) {
//        print("DEBUG: Syncing with preference: \(preference)")
//        switch preference {
//        case .none:
//            print("DEBUG: No sync required")
//            completion(nil)
//        case .documents:
//            syncDocuments(completion: completion)
//        case .allEntries:
//            syncAllEntries(completion: completion)
//        case .specificEntries:
//            syncSpecificEntries(completion: completion)
//        }
//    }
//
//    private func syncDocuments(completion: @escaping (Error?) -> Void) {
//        print("DEBUG: Syncing documents")
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        cloudKitManager.syncDocumentsDirectory(documentsDirectoryURL: documentsURL)
//        completion(nil)
//    }
//
//    private func syncAllEntries(completion: @escaping (Error?) -> Void) {
//        print("DEBUG: Syncing all entries")
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "shouldSyncWithCloudKit == YES")
//        do {
//            let entries = try container.viewContext.fetch(fetchRequest)
//            print("DEBUG: Found \(entries.count) entries to sync")
//            cloudKitManager.syncSpecificEntries(entries: entries, completion: completion)
//        } catch {
//            print("DEBUG: Error fetching entries for sync: \(error)")
//            completion(error)
//        }
//    }
//
//    private func syncSpecificEntries(completion: @escaping (Error?) -> Void) {
//        print("DEBUG: Syncing specific entries")
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "shouldSyncWithCloudKit == YES")
//        do {
//            let entries = try container.viewContext.fetch(fetchRequest)
//            print("DEBUG: Found \(entries.count) specific entries to sync")
//            cloudKitManager.syncSpecificEntries(entries: entries, completion: completion)
//        } catch {
//            print("DEBUG: Error fetching specific entries for sync: \(error)")
//            completion(error)
//        }
//    }
//
//    // This function is to save the context
//    func saveContext(_ context: NSManagedObjectContext) {
//        if context.hasChanges {
//            do {
//                try context.save()
//                print("DEBUG: Context saved successfully")
//            } catch {
//                let nsError = error as NSError
//                print("DEBUG: Error saving context: \(nsError), \(nsError.userInfo)")
//            }
//        } else {
//            print("DEBUG: No changes to save in context")
//        }
//    }
//
//    // MARK: - Debug Helper Methods
//
//    func debugPrintAllEntries() {
//        print("DEBUG: Printing all entries")
//        let context = container.viewContext
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        do {
//            let entries = try context.fetch(fetchRequest)
//            print("DEBUG: Total entries: \(entries.count)")
//            for (index, entry) in entries.enumerated() {
//                print("DEBUG: Entry \(index + 1):")
//                print("DEBUG:   ID: \(entry.id.uuidString)")
//                print("DEBUG:   Content: \(entry.content ?? "No content")")
//                print("DEBUG:   Should Sync: \(entry.shouldSyncWithCloudKit)")
//                print("DEBUG:   Store: \(entry.managedObjectContext?.persistentStoreCoordinator?.persistentStores.first?.description ?? "unknown")")
//            }
//        } catch {
//            print("DEBUG: Error fetching entries: \(error)")
//        }
//    }
//
//    func debugCheckCloudKitStatus() {
//        print("DEBUG: Checking CloudKit status")
//        CKContainer(identifier: "iCloud.com.gnupes.dodum.logs").accountStatus { (accountStatus, error) in
//            if let error = error {
//                print("DEBUG: Error checking CloudKit account status: \(error)")
//                return
//            }
//            
//            switch accountStatus {
//            case .available:
//                print("DEBUG: CloudKit is available")
//            case .noAccount:
//                print("DEBUG: No iCloud account")
//            case .restricted:
//                print("DEBUG: iCloud account is restricted")
//            case .couldNotDetermine:
//                print("DEBUG: Could not determine iCloud account status")
//            @unknown default:
//                print("DEBUG: Unknown iCloud account status")
//            }
//        }
//    }
//}
//
//
//extension PersistenceController {
//    func fetchEntriesFromCloudStore() -> [Entry] {
//        let context = container.viewContext
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "shouldSyncWithCloudKit == YES")
//        
//        do {
//            return try context.fetch(fetchRequest)
//        } catch {
//            print("DEBUG: Error fetching entries from cloud store: \(error)")
//            return []
//        }
//    }
//    
//    func fetchAllEntries() -> [Entry] {
//        let context = container.viewContext
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        
//        do {
//            return try context.fetch(fetchRequest)
//        } catch {
//            print("DEBUG: Error fetching all entries: \(error)")
//            return []
//        }
//    }
//}




//
//import Foundation
//import CoreData
//import CloudKit
//
//
//class PersistenceController {
//    static let shared = PersistenceController()
//    
//    private(set) var container: NSPersistentCloudKitContainer
//    let cloudKitManager = CloudKitManager.shared
//    var isSyncEnabled: Bool
//    
//    private init() {
//        self.isSyncEnabled = false
//        self.container = PersistenceController.createContainer(withSync: false)
//    }
//    
//    private static func createContainer(withSync: Bool) -> NSPersistentCloudKitContainer {
//        let container = NSPersistentCloudKitContainer(name: "entry_1")
//        
//        guard let description = container.persistentStoreDescriptions.first else {
//            fatalError("###\(#function): Failed to retrieve a persistent store description.")
//        }
//        
//        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//        
//        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
//        description.setOption(true as NSNumber, forKey: remoteChangeKey)
//        
//        if !withSync {
//            description.cloudKitContainerOptions = nil
//        } else {
//            let cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.gnupes.dodum.logs")
//            description.cloudKitContainerOptions = cloudKitContainerOptions
//        }
//        
//        container.loadPersistentStores { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        }
//        
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        
//        return container
//    }
//    
//    func toggleSync(enabled: Bool) {
//        guard enabled != isSyncEnabled else { return }
//        
//        let newContainer = PersistenceController.createContainer(withSync: enabled)
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.migrateData(from: self.container, to: newContainer)
//            
//            DispatchQueue.main.async {
//                self.container = newContainer
//                self.isSyncEnabled = enabled
//                NotificationCenter.default.post(name: .syncStatusChanged, object: nil)
//            }
//        }
//    }
//    
//    private func migrateData(from oldContainer: NSPersistentCloudKitContainer, to newContainer: NSPersistentCloudKitContainer) {
//        // Implement data migration logic here if needed
//    }
//    
//    func sync(preference: UserPreferences.SyncPreference,completion: @escaping (Error?) -> Void) {
//        guard isSyncEnabled else {
//            print("Sync is currently disabled. Enable sync before attempting to sync data.")
//            return
//        }
//        
//        switch preference {
//        case .none:
//            break
//        case .documents:
//            syncDocuments()
//        case .allEntries:
//            syncAllEntries()
//        case .specificEntries:
//            syncSpecificEntries()
//        }
//    }
//
//    private func syncDocuments() {
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        cloudKitManager.syncDocumentsDirectory(documentsDirectoryURL: documentsURL)
//    }
//
//    private func syncAllEntries() {
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        do {
//            let entries = try container.viewContext.fetch(fetchRequest)
//            cloudKitManager.syncSpecificEntries(entries: entries)
//        } catch {
//            print("Failed to fetch entries for sync: \(error)")
//        }
//    }
//
//    private func syncSpecificEntries() {
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "shouldSyncWithCloudKit == YES")
//        do {
//            let entries = try container.viewContext.fetch(fetchRequest)
//            cloudKitManager.syncSpecificEntries(entries: entries)
//        } catch {
//            print("Failed to fetch specific entries for sync: \(error)")
//        }
//    }
//
//    func save() {
//        let context = container.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//}
//
//extension Notification.Name {
//    static let syncStatusChanged = Notification.Name("com.yourapp.syncStatusChanged")
//}
