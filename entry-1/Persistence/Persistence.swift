import CoreData
import CloudKit

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "entry_1")
        
        let fileManager = FileManager.default
        let oldStoreURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("entry_1.sqlite")
//        let newStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("entry_1.sqlite")
        let newStoreURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("entry_1.sqlite")
        print("Old store URL: \(oldStoreURL)")
        print("New store URL: \(newStoreURL)")
        
//        if fileManager.fileExists(atPath: oldStoreURL.path) {
//            do {
//                // Migrate data from the old store
//                try migrateData(from: oldStoreURL)
//                print("Data migration successful")
//            } catch {
//                print("Data migration failed: \(error)")
//                // Handle the error appropriately, e.g., create a new store
//            }
//        }
//        
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
                print("Failed to load persistent stores: \(error), \(error.userInfo)")
                fatalError("Failed to load persistent stores: \(error), \(error.userInfo)")
            } else {
                print("Successfully loaded persistent store: \(description.url?.absoluteString ?? "unknown URL")")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func printAllModels(model: NSManagedObjectModel) {
        print("Entities in the model:")
        for entity in model.entities {
            print("Entity name: \(entity.name ?? "Unnamed entity")")
            
            print("Attributes:")
            for (attributeName, attribute) in entity.attributesByName {
                print(" - \(attributeName): \(attribute.attributeType.rawValue)")
            }
            
            print("Relationships:")
            for (relationshipName, relationship) in entity.relationshipsByName {
                print(" - \(relationshipName): \(relationship.destinationEntity?.name ?? "Unknown")")
            }
            
            print("-----------------------------")
        }
    }

    
    // Method to migrate data from the old store
      private func migrateData(from oldStoreURL: URL) throws {
          print("Starting data migration from \(oldStoreURL)")
          
          // Check if the old store exists
          let fileManager = FileManager.default
          guard fileManager.fileExists(atPath: oldStoreURL.path) else {
              throw NSError(domain: "MigrationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Old store file does not exist"])
          }

          // Retrieve metadata from the old store
          let oldMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: oldStoreURL, options: nil)
          print("Old store metadata: \(oldMetadata)")

          print("old metadata values: \(oldMetadata.values)")
          print("old metadata description: \(oldMetadata.description)")
          print("old metadata first value: \(oldMetadata.first?.value)")


          // Load the old model from the metadata
          guard let oldModel = NSManagedObjectModel.mergedModel(from: [Bundle.main], forStoreMetadata: oldMetadata) else {
              throw NSError(domain: "MigrationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Old model not found"])
          }
          
          // Print old model entities and attributes
          print("Old model entities and attributes:")
          for entity in oldModel.entities {
              print("Entity name: \(entity.name ?? "Unnamed entity")")
              for (attributeName, attribute) in entity.attributesByName {
                  print(" - Attribute: \(attributeName), Type: \(attribute.attributeType)")
              }
          }

          let oldCoordinator = NSPersistentStoreCoordinator(managedObjectModel: oldModel)
          try oldCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: oldStoreURL, options: nil)
          
          let oldContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
          oldContext.persistentStoreCoordinator = oldCoordinator
          
          // Fetch all logs and their entries from the old store
          let logFetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
          let logs = try oldContext.fetch(logFetchRequest)
          
          var jsonArray: [[String: Any]] = []
          
          for log in logs {
              var jsonObject: [String: Any] = [
                  "day": log.day ?? "",
                  "id": log.id.uuidString ?? "",
              ]
              
              // Fetch entries related to this log
              var entryArray: [[String: Any]] = []
              
              // Fetch based on logId if the relationship field is not empty
              if let relationship = log.value(forKey: "relationship") as? Set<NSManagedObject>, !relationship.isEmpty {
                  let entryFetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
                  entryFetchRequest.predicate = NSPredicate(format: "logId == %@", log.id as CVarArg)
                  let entries = try oldContext.fetch(entryFetchRequest)
                  
                  for entry in entries {
                      let entryObject: [String: Any] = [
                        "id": entry.id.uuidString ?? "",
                          "logId": entry.logId?.uuidString ?? ""
                          // Add other entry attributes here
                      ]
                      entryArray.append(entryObject)
                  }
                  
                  // Also fetch entries based on relationship.id matching log.id
                  for relationshipEntry in relationship {
                      guard let relationshipEntryId = relationshipEntry.value(forKey: "id") as? UUID else {
                          continue
                      }
                      
                      let relationshipFetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
                      relationshipFetchRequest.predicate = NSPredicate(format: "relationship.id == %@", log.id as CVarArg)
                      let relationshipEntries = try oldContext.fetch(relationshipFetchRequest)
                      
                      for relationshipEntry in relationshipEntries {
                          let relationshipEntryObject: [String: Any] = [
                            "id": relationshipEntry.id.uuidString ?? "",
                              "logId": relationshipEntry.logId?.uuidString ?? ""
                              // Add other entry attributes here
                          ]
                          entryArray.append(relationshipEntryObject)
                      }
                  }
              }
              
              jsonObject["relationship"] = entryArray
              jsonArray.append(jsonObject)
          }
          
          // Call importLogs with the JSON data
//          try importLogs(from: jsonArray)
      }
    
//    func importLogs(from jsonArray: [[String: Any]]) throws {
//        let context = container.viewContext
//        
//        context.performAndWait {
//            do {
//                for jsonObject in jsonArray {
//                    print("Processing log jsonObject: \(jsonObject)")
//                    
//                    guard let logDayString = jsonObject["day"] as? String,
//                          let logIdString = jsonObject["id"] as? String else {
//                        print("Missing required log fields, skipping: \(jsonObject)")
//                        continue
//                    }
//                    
//                    // Fetch or create the log
//                    let logFetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
//                    logFetchRequest.predicate = NSPredicate(format: "day == %@", logDayString)
//                    
//                    let existingLogs = try context.fetch(logFetchRequest)
//                    let log: Log
//                    let entryIds = jsonObject["entry_ids"] as? [String] ?? []
//
//                    if let existingLog = existingLogs.first {
//                        log = existingLog
//                        print("Found existing log: \(log)")
//                    } else {
//                        log = Log(context: context)
//                        log.day = logDayString
//                        log.id = UUID(uuidString: logIdString) ?? UUID()
//                        print("Created new log: \(log)")
//                    }
//                    
//                    // Updating dates
//                    let dateStringsManager = DateStrings()
//                    dateStringsManager.addDate(log.day ?? "")
//                    print("Updated dates for log: \(log.day ?? "")")
//
////                    // Fetch or create entries
////                    for entryIdString in log.entry_ids ?? [] {
////                        print("Processing entryIdString: \(entryIdString)")
////                        
////                        let entryFetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
////                        entryFetchRequest.predicate = NSPredicate(format: "id == %@", entryIdString)
////                        
////                        let existingEntries = try context.fetch(entryFetchRequest)
////                        
////                        if existingEntries.isEmpty {
////                            // This is a new entry, add it
////                            if let entryData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) {
////                                let decoder = JSONDecoder()
////                                decoder.userInfo[CodingUserInfoKey.managedObjectContext] = context
////                                if let newEntry = try? decoder.decode(Entry.self, from: entryData) {
////                                    newEntry.logId = log.id
////                                    log.addEntryId(newEntry.id.uuidString ?? "")
////                                    context.insert(newEntry)
////                                    print("New entry created with ID: \(newEntry.id.uuidString ?? ""), assigned to log: \(log.id.uuidString ?? "")")
////                                }
////                            }
////                        } else {
////                            if let existingEntry = existingEntries.first {
////                                existingEntry.logId = log.id
////                                log.addEntryId(existingEntry.id.uuidString ?? "")
////                            }
////                            print("Entry with ID: \(entryIdString) already exists, skipping")
////                        }
////                    }
//                    
//                    if let newEntries = jsonObject["relationship"] as? [[String: Any]] {
//                        for newEntryData in newEntries {
//                            print("Processing newEntryData: \(newEntryData)")
//                            if let newEntryIdString = newEntryData["id"] as? String,
//                               let newEntryId = UUID(uuidString: newEntryIdString) {
//                                
//                                let entryFetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//                                entryFetchRequest.predicate = NSPredicate(format: "id == %@", newEntryId as CVarArg)
//                                
//                                do {
//                                    let existingEntries = try context.fetch(entryFetchRequest)
//                                    
//                                    if let existingEntry = existingEntries.first {
//                                        // Entry exists, update its logId
//                                        print("Updating existing entry")
//                                        existingEntry.logId = log.id
//                                    } else {
//                                        // This is a new entry, create and add it to the log
//                                        print("Creating new entry")
//                                        if let entryData = try? JSONSerialization.data(withJSONObject: newEntryData, options: []) {
//                                            let decoder = JSONDecoder()
//                                            decoder.userInfo[CodingUserInfoKey.managedObjectContext] = context
//                                            if let newEntry = try? decoder.decode(Entry.self, from: entryData) {
//                                                newEntry.logId = log.id
//                                                context.insert(newEntry)
//                                                print("New entry created and added to log")
//                                            }
//                                        }
//                                    }
//                      
//                                    
//                                } catch {
//                                    print("Error processing entry: \(error)")
//                                }
//                            }
//                        }
//                        
//                        // Save changes
//                        do {
//                            try context.save()
//                            print("Changes saved successfully")
//                        } catch {
//                            print("Error saving changes: \(error)")
//                        }
//                    }
//                    
//                    context.insert(log)
//                }
//                try context.save()
//                print("Successfully saved logs and entries")
//            } catch {
//                print("Failed to import logs: \(error)")
//            }
//        }
//    }
}
