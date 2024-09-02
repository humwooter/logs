import CoreData
import CloudKit

class MigrationManager {
    static let shared = MigrationManager()
    
    private init() {}
    
    func migrateStoreIfNeeded(at storeURL: URL, to destinationModel: NSManagedObjectModel, container: NSPersistentContainer) throws {
        guard let metadata = try? NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil) else {
            throw NSError(domain: "MigrationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve store metadata"])
        }
        
        if !destinationModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) {
            try migrateStore(at: storeURL, toVersion: destinationModel.versionIdentifiers.first as? String ?? "", container: container)
        }
    }
    
    private func migrateStore(at storeURL: URL, toVersion destinationVersion: String, container: NSPersistentContainer) throws {
        let sourceVersion = try determineSourceVersion(for: storeURL)
        let migrationSteps = try determineMigrationSteps(from: sourceVersion, to: destinationVersion)
        
        for step in migrationSteps {
            try performMigrationStep(step, for: storeURL)
        }
        
        try performCustomTransformations(container: container)
    }
    
    private func determineSourceVersion(for storeURL: URL) throws -> String {
        // Implement logic to determine the current version of the store
        // This could involve checking metadata or a version number stored in UserDefaults
        // For now, we'll return a placeholder version
        return "1.0"
    }
    
    private func determineMigrationSteps(from sourceVersion: String, to destinationVersion: String) throws -> [MigrationStep] {
        // Implement logic to determine the necessary migration steps
        // This could involve a graph or dictionary of possible migrations
        // For now, we'll return a placeholder step
        return [MigrationStep(sourceVersion: sourceVersion, destinationVersion: destinationVersion)]
    }
    
    private func performMigrationStep(_ step: MigrationStep, for storeURL: URL) throws {
        guard let sourceModel = NSManagedObjectModel.modelVersioned(for: step.sourceVersion),
              let destinationModel = NSManagedObjectModel.modelVersioned(for: step.destinationVersion),
              let mappingModel = NSMappingModel(from: [Bundle.main], forSourceModel: sourceModel, destinationModel: destinationModel) else {
            throw NSError(domain: "MigrationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load models for migration"])
        }
        
        let manager = NSMigrationManager(sourceModel: sourceModel, destinationModel: destinationModel)
        let destinationURL = storeURL.deletingLastPathComponent().appendingPathComponent("Migrating_\(UUID().uuidString).sqlite")
        
        try manager.migrateStore(from: storeURL, sourceType: NSSQLiteStoreType, options: nil, with: mappingModel, toDestinationURL: destinationURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
        
        // Replace the old store with the new one
        try FileManager.default.removeItem(at: storeURL)
        try FileManager.default.moveItem(at: destinationURL, to: storeURL)
    }
    
    private func performCustomTransformations(container: NSPersistentContainer) throws {
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

struct MigrationStep {
    let sourceVersion: String
    let destinationVersion: String
}

extension NSManagedObjectModel {
    static func modelVersioned(for version: String) -> NSManagedObjectModel? {
        guard let modelURL = Bundle.main.url(forResource: version, withExtension: "mom") else { return nil }
        return NSManagedObjectModel(contentsOf: modelURL)
    }
}
