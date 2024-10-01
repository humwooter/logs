//
//  CloudPersistence.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 9/30/24.
//

import CoreData

class CloudPersistenceController {
    static let shared = CloudPersistenceController()
    let container: NSPersistentCloudKitContainer

    private init() {
        // initialize the container with the name of your data model
        container = NSPersistentCloudKitContainer(name: "entry_1")

        // set up the cloud store description
        let cloudStoreURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("entry_1_cloud.sqlite")
        let cloudDescription = NSPersistentStoreDescription(url: cloudStoreURL)
        // use the default configuration
        cloudDescription.configuration = nil
        cloudDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.gnupes.dodum.logs"
        )
        cloudDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        cloudDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        cloudDescription.shouldMigrateStoreAutomatically = true
        cloudDescription.shouldInferMappingModelAutomatically = true

        container.persistentStoreDescriptions = [cloudDescription]

        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                print("error initializing cloud persistent store: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true

        // observe remote change notifications to keep the context updated
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(processRemoteChange),
            name: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator
        )
    }

    @objc private func processRemoteChange(notification: Notification) {
        // merge changes from cloud into the context
        container.viewContext.perform {
            self.container.viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }
}



//// let localController = LocalPersistenceController.shared
//let localContext = localController.container.viewContext
//
//// perform local data operations
//let cloudController = CloudPersistenceController.shared
//let cloudContext = cloudController.container.viewContext
//
//// perform cloud data operations
//
