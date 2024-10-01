//import CoreData
//
//struct PersistenceController {
//    static let shared = PersistenceController()
//    let container: NSPersistentCloudKitContainer
//
//    enum CoreDataError: Error {
//        case migrationFailed(Error)
//        case failedToLoadPersistentStores(Error)
//    }
//
//    init(inMemory: Bool = false) throws {
//        container = NSPersistentCloudKitContainer(name: "entry_1")
//
//        let localStoreDescription = NSPersistentStoreDescription()
//        localStoreDescription.url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("entry_1.sqlite")
//        localStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
//        localStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//
//        let cloudStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("entry_1cloud.sqlite")
//        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreURL)
//        cloudStoreDescription.configuration = "Cloud"
//        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.gnupes.dodum.logs")
//        cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
//        cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//
//        container.persistentStoreDescriptions = [localStoreDescription, cloudStoreDescription]
//
//        if inMemory {
//            container.persistentStoreDescriptions.forEach { $0.url = URL(fileURLWithPath: "/dev/null") }
//        }
//
//        try container.loadPersistentStores { description, error in
//            if let error = error {
//                throw CoreDataError.failedToLoadPersistentStores(error)
//            } else {
//                print("Successfully loaded persistent store: \(description.url?.absoluteString ?? "unknown URL")")
//
//                // Optionally, perform custom transformations here after the store loads
//                do {
//                    try performCustomTransformations() // Add your custom transformations
//                } catch {
//                    print("Error performing custom transformations: \(error)")
//                }
//            }
//        }
//
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//    }
//
//    // Add your custom migration logic here
//    private func performCustomTransformations() throws {
//        // 1. Check if migration is needed (e.g., using UserDefaults)
//        let userDefaults = UserDefaults.standard
//        guard !userDefaults.bool(forKey: "migrationCompleted") else {
//            return // Migration already done
//        }
//
//        // 2. Disable automatic migration (temporarily)
//        container.persistentStoreDescriptions.forEach {
//            $0.shouldInferMappingModelAutomatically = false
//            $0.shouldMigrateStoreAutomatically = false
//        }
//
//        // 3. Perform the migration
//        let coordinator = container.persistentStoreCoordinator
//        let sourceStoreURL = // ... URL of the old store if needed ...
//        do {
//            try coordinator.migratePersistentStore(
//                at: sourceStoreURL,
//                to: container.persistentStoreDescriptions[0].url!,
//                options: nil,
//                withType: NSSQLiteStoreType
//            )
//
//            // 4. Re-enable automatic migration after your custom migration
//            container.persistentStoreDescriptions.forEach {
//                $0.shouldInferMappingModelAutomatically = true
//                $0.shouldMigrateStoreAutomatically = true
//            }
//
//            // 5. Mark migration as complete
//            userDefaults.set(true, forKey: "migrationCompleted")
//            print("Custom migration successful!")
//        } catch {
//            // Handle migration error, e.g., rollback, notify the user
//            throw CoreDataError.migrationFailed(error)
//        }
//    }
//}
