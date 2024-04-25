import CoreData



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

  
}
