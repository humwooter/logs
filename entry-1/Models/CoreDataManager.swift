import CoreData
import CloudKit


final class CoreDataManager: ObservableObject {

  // MARK: - Core Data Stack

    // static let shared = CoreDataManager(persistenceController: PersistenceController())
    let persistenceController: PersistenceController
    static let shared = CoreDataManager(persistenceController: PersistenceController.shared)


    // Modify the initializer to accept a PersistenceController
    init(persistenceController: PersistenceController) {
        print("init(persistenceController: PersistenceController)")
        self.persistenceController = persistenceController
    }

    // Use the container from the PersistenceController
    var persistentContainer: NSPersistentContainer {
        return persistenceController.container
    }

  // MARK: - Managed Object Contexts
    var viewContext: NSManagedObjectContext {
      
      // Return main queue context
      return persistentContainer.viewContext

    }
    
  lazy var backgroundContext: NSManagedObjectContext = {
    // Create a background context with private queue
      let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    // Set persistent store coordinator
    context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
    
    return context
    
  }()
    

    func saveFetchedEntries(_ entries: [Entry]) {
         let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
         let context = viewContext

         for entry in entries {
             fetchRequest.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)

             do {
                 let existingEntries = try context.fetch(fetchRequest)
                 if existingEntries.isEmpty {
                     context.insert(entry)
                 } else {
                     if let existingEntry = existingEntries.first {
                         updateEntry(existingEntry, with: entry)
                     }
                 }
             } catch {
                 print("Failed to fetch entry: \(error)")
             }
         }
         save(context: context)
     }

    
    func save(context: NSManagedObjectContext) {
      print("Saving context: \(context)")
      context.performAndWait {
        do {
          try context.save()
          print("Successfully saved context: \(context)")
        } catch {
          print("Failed to save context: \(error)")
        }
      }
    }

func saveData() {
    if backgroundContext.hasChanges {
        save(context: backgroundContext)
        mergeChanges(from: backgroundContext)
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Failed to save viewContext: \(error)")
            }
        }
    }
}

func mergeChanges(from context: NSManagedObjectContext) {
    NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: context)
}

@objc func contextDidSave(_ notification: Notification) {
    NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: notification.object)
    viewContext.performAndWait {
        self.persistentContainer.viewContext.mergeChanges(fromContextDidSave: notification)
    }
}


  func undo() {
    viewContext.undoManager?.undo()
    saveData()
  }
  
  // MARK: - Convenience Core Data Fetch Methods
  func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {

    do {
      return try viewContext.fetch(request)
    } catch {
        print("Failed to fetch data: \(error)")
        return []
      // Handle fetch error

    }

  }
  func fetchInBackground<T: NSManagedObject>(request: NSFetchRequest<T>, completion: @escaping ([T]) -> Void) {
    backgroundContext.performAndWait {
        do {
            let results = try self.backgroundContext.fetch(request)
            completion(results)
        } catch {
            print("Failed to fetch data: \(error)")
            completion([])
        }
    }
}
    
    func updateEntry(entry: Entry, with record: CKRecord) {
        entry.content = record["content"] as? String ?? ""
        entry.time = record["time"] as? Date ?? Date()
        entry.lastUpdated = record["lastUpdated"] as? Date
        entry.stampIcon = record["stampIcon"] as? String ?? ""
        entry.name = record["name"] as? String
        entry.reminderId = record["reminderId"] as? String
        entry.mediaFilename = record["mediaFilename"] as? String
        entry.mediaFilenames = record["mediaFilenames"] as? [String]
        entry.entryReplyId = record["entryReplyId"] as? String
        entry.isHidden = record["isHidden"] as? Bool ?? false
        entry.isShown = record["isShown"] as? Bool ?? true
        entry.isPinned = record["isPinned"] as? Bool ?? false
        entry.isRemoved = record["isRemoved"] as? Bool ?? false
        entry.isDrafted = record["isDrafted"] as? Bool ?? false
        entry.shouldSyncWithCloudKit = record["shouldSyncWithCloudKit"] as? Bool ?? true
        entry.stampIndex = record["stampIndex"] as? Int16 ?? 0
        entry.pageNum_pdf = record["pageNum_pdf"] as? Int16 ?? 0

        save(context: viewContext)
    }
    
    func fetchEntriesByLog() -> [Log: [Entry]] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        do {
            let entries = try persistentContainer.viewContext.fetch(fetchRequest)
            return Dictionary(grouping: entries, by: { $0.relationship })
        } catch {
            print("Failed to fetch entries: \(error)")
            return [:]
        }
    }

    func fetchEntriesCountByStampIcon() -> [String: Int] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        do {
            let entries = try persistentContainer.viewContext.fetch(fetchRequest)
            return Dictionary(grouping: entries, by: { $0.stampIcon ?? "Unknown" })
                .mapValues { $0.count }
        } catch {
            print("Failed to fetch entries: \(error)")
            return [:]
        }
    }
    
    
    func updateEntry(_ existingEntry: Entry, with newEntry: Entry) {
           existingEntry.content = newEntry.content
           existingEntry.time = newEntry.time
           existingEntry.lastUpdated = newEntry.lastUpdated
           existingEntry.stampIcon = newEntry.stampIcon
           existingEntry.name = newEntry.name
           existingEntry.reminderId = newEntry.reminderId
           existingEntry.mediaFilename = newEntry.mediaFilename
           existingEntry.mediaFilenames = newEntry.mediaFilenames
           existingEntry.entryReplyId = newEntry.entryReplyId
           existingEntry.isHidden = newEntry.isHidden
           existingEntry.isShown = newEntry.isShown
           existingEntry.isPinned = newEntry.isPinned
           existingEntry.isRemoved = newEntry.isRemoved
           existingEntry.isDrafted = newEntry.isDrafted
           existingEntry.shouldSyncWithCloudKit = newEntry.shouldSyncWithCloudKit
           existingEntry.stampIndex = newEntry.stampIndex
           existingEntry.pageNum_pdf = newEntry.pageNum_pdf

           save(context: viewContext)
       }
    
    private func setupObservers() {
           NotificationCenter.default.addObserver(self, selector: #selector(entryDidChange(notification:)), name: .NSManagedObjectContextObjectsDidChange, object: viewContext)
       }

    @objc private func entryDidChange(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            for object in updatedObjects {
                if let entry = object as? Entry {
                    if let shouldSync = entry.changedValues()["shouldSyncWithCloudKit"] as? Bool, shouldSync {
                        CloudKitManager.shared.syncSpecificEntries(entries: [entry])
                    }
                }
            }
        }
    }
}
