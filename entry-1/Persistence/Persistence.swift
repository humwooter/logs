//
//  Persistence.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Initialize the container with the default (local) configuration
        container = NSPersistentContainer(name: "entry_1")

        if inMemory {
            // For testing purposes, use in-memory store
            if let storeDescription = container.persistentStoreDescriptions.first {
                storeDescription.url = URL(fileURLWithPath: "/dev/null")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        } else {
            // Set up the local store description
            let description = NSPersistentStoreDescription()
            description.url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("entry_1.sqlite")
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            // Ensure it's using the default configuration
            description.configuration = nil // or omit this line as nil is default
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                print("Error initializing persistent store: \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

