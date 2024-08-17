//import CoreData
//import CloudKit
//
//struct PersistenceController {
//    static let shared = PersistenceController()
//
//    let localContainer: NSPersistentContainer
//    var cloudContainer: NSPersistentCloudKitContainer?
//
//    init(inMemory: Bool = false) {
//        let modelName = "entry_1"
//        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
//        let model = NSManagedObjectModel(contentsOf: modelURL)!
//
//        localContainer = NSPersistentContainer(name: modelName, managedObjectModel: model)
//        
//        let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
//        let localStoreURL = defaultDirectoryURL.appendingPathComponent("entry_1.sqlite")
//        let localStoreDescription = NSPersistentStoreDescription(url: localStoreURL)
//        localStoreDescription.configuration = "Default"
//
//        localContainer.persistentStoreDescriptions = [localStoreDescription]
//
//        if inMemory {
//            for description in localContainer.persistentStoreDescriptions {
//                description.url = URL(fileURLWithPath: "/dev/null")
//            }
//        }
//
//        localContainer.loadPersistentStores { description, error in
//            if let error = error as NSError? {
//                fatalError("Failed to load persistent stores: \(error), \(error.userInfo)")
//            }
//        }
//
//        localContainer.viewContext.automaticallyMergesChangesFromParent = true
//        localContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//
////        if UserDefaults.standard.bool(forKey: "enableCloudMirror") {
//            setCloudContainer()
////        }
//    }
//
//    mutating func setCloudContainer() {
////        if cloudContainer != nil {
////            removeCloudContainer()
////        }
//
//        let modelName = "entry_1"
//        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
//        let model = NSManagedObjectModel(contentsOf: modelURL)!
//
//        let container = NSPersistentCloudKitContainer(name: modelName, managedObjectModel: model)
//        let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
//
//        let localStoreURL = defaultDirectoryURL.appendingPathComponent("entry_1.sqlite")
//        let localStoreDescription = NSPersistentStoreDescription(url: localStoreURL)
//        localStoreDescription.configuration = "Default"
//
//        let cloudStoreURL = defaultDirectoryURL.appendingPathComponent("entry_1cloud.sqlite")
//        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreURL)
//        cloudStoreDescription.configuration = "Cloud"
//        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.gnupes.dodum.logs")
//
//        container.persistentStoreDescriptions = [localStoreDescription, cloudStoreDescription]
//
//        container.loadPersistentStores { description, error in
//            if let error = error as NSError? {
//                fatalError("Failed to load persistent stores: \(error), \(error.userInfo)")
//            }
//        }
//
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//
//        cloudContainer = container
//    }
//
//    mutating func removeCloudContainer() {
//        deleteAllCloudEntries()
//        cloudContainer = nil
//        print("Cloud sync turned off and cloud entries deleted")
//    }
//
//    private func deleteAllCloudEntries() {
//        guard let cloudContainer = cloudContainer else { return }
//        let context = cloudContainer.viewContext
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Entry.fetchRequest()
//        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
//        do {
//            try context.execute(batchDeleteRequest)
//            try context.save()
//            print("Deleted all cloud entries")
//        } catch {
//            print("Failed to delete cloud entries: \(error)")
//        }
//    }
//}
