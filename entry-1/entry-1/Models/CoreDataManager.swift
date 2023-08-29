import CoreData



final class CoreDataManager: ObservableObject {

  // MARK: - Core Data Stack

    let persistenceController: PersistenceController

    // Modify the initializer to accept a PersistenceController
    init(persistenceController: PersistenceController) {
        print("init(persistenceController: PersistenceController)")
        self.persistenceController = persistenceController
    }

    // Use the container from the PersistenceController
    var persistentContainer: NSPersistentContainer {
        return persistenceController.container
    }

    // lazy var persistentContainer: NSPersistentContainer = {
    //     let container = NSPersistentContainer(name: "YourModelName")
    //     container.loadPersistentStores { (storeDescription, error) in
    //       if let error = error {
    //         print("Failed to load persistent stores: \(error)")
    //       }
    //     }
    //     return container
    //   }()

  // MARK: - Managed Object Contexts

  lazy var backgroundContext: NSManagedObjectContext = {
      
    // Create a background context with private queue
      let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    // Set persistent store coordinator 
    context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
    
    return context
    
  }()

  var viewContext: NSManagedObjectContext {
    
    // Return main queue context
    return persistentContainer.viewContext

  }
    
    func save(context: NSManagedObjectContext) {
      context.performAndWait {
        do {
          try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
      }
    }

    func mergeChanges(from context: NSManagedObjectContext) {
      NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: context)
    }

    @objc func contextDidSave(_ notification: Notification) {
//      NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: notification.object)
      viewContext.performAndWait {
//          self.persistentContainer.viewContext.mergeChanges(from: backgroundContext)
          self.persistentContainer.viewContext.mergeChanges(fromContextDidSave: notification)

//        self.viewContext.mergeChanges(fromContextDidSave: notification)
      }
    }

    func saveData() {
      save(context: backgroundContext)
      mergeChanges(from: backgroundContext)
    }

//  // MARK: - Core Data Saving and Undo
//
//  func save(context: NSManagedObjectContext) {
//
//    context.perform {
//
//      do {
//
//        try context.save()
//
//      } catch {
//          print("Failed to save context: \(error)")
//
//      }
//    }
//  }
//
//    // Fix for second error
//    func mergeChanges(from context: NSManagedObjectContext) {
//      NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: context)
//    }
//
//    @objc func contextDidSave(_ notification: Notification) {
//      viewContext.perform {
//        self.viewContext.mergeChanges(fromContextDidSave: notification)
//      }
//    }
//
//  func saveData() {
//
//    // Save in background
//
//    save(context: backgroundContext)
//
//    // Merge in main
//
//    mergeChanges(from: backgroundContext)
//
//  }

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
  
}
