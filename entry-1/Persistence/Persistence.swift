//
//  Persistence.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//

import CoreData




struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "entry_1")
        
        let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
        
        let localStoreURL = defaultDirectoryURL.appendingPathComponent("entry_1.sqlite")
        let localStoreDescription = NSPersistentStoreDescription(url: localStoreURL)
        localStoreDescription.configuration = "Default"
        
        let cloudStoreURL = defaultDirectoryURL.appendingPathComponent("entry_1cloud.sqlite")
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreURL)
        cloudStoreDescription.configuration = "Cloud"
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.gnupes.dodum.logs")
        
        container.persistentStoreDescriptions = [localStoreDescription, cloudStoreDescription]
        
        if inMemory {
            for description in container.persistentStoreDescriptions {
                description.url = URL(fileURLWithPath: "/dev/null")
            }
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Failed to load persistent stores: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}


//struct PersistenceController {
//    // static let shared = CoreDataManager.shared
//     static let shared = PersistenceController()
//     let container: NSPersistentContainer
//
//    
//    init(inMemory: Bool = false) {
//           container = NSPersistentContainer(name: "entry_1")
//
//           if inMemory {
//               container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
//               container.viewContext.automaticallyMergesChangesFromParent = true
//           } else {
//               let description = NSPersistentStoreDescription()
//               description.url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("entry_1.sqlite")
//               description.shouldMigrateStoreAutomatically = true
//               description.shouldInferMappingModelAutomatically = true
//               container.persistentStoreDescriptions = [description]
//           }
//
//           container.loadPersistentStores(completionHandler: { (_, error) in
//               if let error = error as NSError? {
//                   print("Error initializing persistent store: \(error), \(error.userInfo)")
//               }
//           })
//        container.viewContext.automaticallyMergesChangesFromParent = true
//       }
//}
