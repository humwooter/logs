import CoreData
import CloudKit

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "entry_1")
        
        let fileManager = FileManager.default
        let oldStoreURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("entry_1.sqlite")
        let newStoreURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("entry_1.sqlite")
        
        let localStoreDescription = NSPersistentStoreDescription(url: newStoreURL)
        localStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        localStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        let cloudStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("entry_1cloud.sqlite")
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreURL)
        cloudStoreDescription.configuration = "Cloud"
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.gnupes.dodum.logs")
        cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        container.persistentStoreDescriptions = [localStoreDescription, cloudStoreDescription]
        
        if inMemory {
            container.persistentStoreDescriptions.forEach { $0.url = URL(fileURLWithPath: "/dev/null") }
        }
        
        container.loadPersistentStores { description, error in
             if let error = error as NSError? {
                 fatalError("Failed to load persistent stores: \(error), \(error.userInfo)")
             } else {
                 print("Successfully loaded persistent store: \(description.url?.absoluteString ?? "unknown URL")")
                 
                 do {
                     try self.performCustomTransformations()
                 } catch {
                     print("Error performing custom transformations: \(error)")
                 }
             }
         }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    private func performMigrationIfNeeded(from sourceURL: URL, to destinationURL: URL) throws {
       let sourceMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: sourceURL, options: nil)
//        else {
//            throw NSError(domain: "MigrationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve source metadata"])
//        }
        
        let destinationModel = container.managedObjectModel
        
        if !destinationModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: sourceMetadata) {
            try migrateStore(from: sourceURL, to: destinationURL, destinationModel: destinationModel)
        }
    }
    
    private func migrateStore(from sourceURL: URL, to destinationURL: URL, destinationModel: NSManagedObjectModel) throws {
        guard let sourceModel = NSManagedObjectModel.loadModel(forResource: "entry_1", extension: "mom") else {
            throw NSError(domain: "MigrationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load source model"])
        }
        
        let migrationManager = NSMigrationManager(sourceModel: sourceModel, destinationModel: destinationModel)
        
        // Find all mapping models
        guard let mappingModels = try findMappingModels(from: sourceModel, to: destinationModel) else {
            throw NSError(domain: "MigrationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to find mapping models"])
        }
        
        // Perform migration in multiple passes if needed
        for mappingModel in mappingModels {
            try migrationManager.migrateStore(from: sourceURL, sourceType: NSSQLiteStoreType, options: nil, with: mappingModel, toDestinationURL: destinationURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
        }
        
        // Perform custom transformations if needed
        try performCustomTransformations()
    }
    
    private func findMappingModels(from sourceModel: NSManagedObjectModel, to destinationModel: NSManagedObjectModel) throws -> [NSMappingModel]? {
        // This is a simplified version. You might need to implement logic to find multiple mapping models if needed.
        if let mappingModel = NSMappingModel(from: [Bundle.main], forSourceModel: sourceModel, destinationModel: destinationModel) {
            return [mappingModel]
        }
        return nil
    }
    
    private func performCustomTransformations() throws {
           let context = container.newBackgroundContext()
           context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
           
           try context.performAndWait {
               let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Entry")
               let entries = try context.fetch(fetchRequest)
               
               for entry in entries {
                   if let tagNames = entry.value(forKey: "tagNames") {
                       if let tagNamesString = tagNames as? String {
                           // If tagNames is still a string, convert it to an array
                           let tagNamesArray = tagNamesString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                           entry.setValue(tagNamesArray, forKey: "tagNames")
                       } else if let tagNamesArray = tagNames as? [String] {
                           // If it's already an array, ensure all elements are trimmed
                           let trimmedArray = tagNamesArray.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                           entry.setValue(trimmedArray, forKey: "tagNames")
                       } else {
                           print("Unexpected type for tagNames: \(type(of: tagNames))")
                       }
                   }
               }
               
               if context.hasChanges {
                   try context.save()
               }
           }
       }
}

extension NSManagedObjectModel {
    static func loadModel(forResource resource: String, extension: String) -> NSManagedObjectModel? {
        let bundle = Bundle.main
        if let modelURL = bundle.url(forResource: resource, withExtension: `extension`) {
            return NSManagedObjectModel(contentsOf: modelURL)
        }
        return nil
    }
}
