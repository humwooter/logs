//
////
////  Persistence.swift
////  entry-1
////
////  Created by Katya Raman on 8/14/23.
////
//
//import CoreData
//
//struct PersistenceController {
//    // static let shared = CoreDataManager.shared
//    static let shared = PersistenceController()
//    let container: NSPersistentCloudKitContainer
//
//    init(inMemory: Bool = false) {
//        container = NSPersistentCloudKitContainer(name: "entry_1")
//        
//        let fileManager = FileManager.default
//        let oldStoreURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("entry_1.sqlite")
//        let newStoreURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("entry_1.sqlite")
//        
//        let localStoreDescription = NSPersistentStoreDescription(url: newStoreURL)
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
//        container.loadPersistentStores { description, error in
//             if let error = error as NSError? {
//                 fatalError("Failed to load persistent stores: \(error), \(error.userInfo)")
//             } else {
//                 print("Successfully loaded persistent store: \(description.url?.absoluteString ?? "unknown URL")")
//                 
//                 do {
////                     try self.performCustomTransformations()
//                 } catch {
//                     print("Error performing custom transformations: \(error)")
//                 }
//             }
//         }
//        
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//    }
//}
