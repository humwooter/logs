////
////  WidgetCoreDataManager.swift
////  entry-1
////
////  Created by Katyayani G. Raman on 6/25/24.
////
//
//import CoreData
//import CloudKit
//
//
//class WidgetCoreDataManager: ObservableObject {
//    
//    let persistenceController: PersistenceController
////    static let shared = CoreDataManager(persistenceController: PersistenceController.shared)
//
//
//    // Modify the initializer to accept a PersistenceController
//    init(persistenceController: PersistenceController) {
//        print("init(persistenceController: PersistenceController)")
//        self.persistenceController = persistenceController
//    }
//
//    // Use the container from the PersistenceController
//    var persistentContainer: NSPersistentContainer {
//        return persistenceController.container
//    }
//
//  // MARK: - Managed Object Contexts
//    var viewContext: NSManagedObjectContext {
//      
//      // Return main queue context
//      return persistentContainer.viewContext
//
//    }
//    
//  lazy var backgroundContext: NSManagedObjectContext = {
//    // Create a background context with private queue
//      let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//    // Set persistent store coordinator
//    context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
//    
//    return context
//    
//  }()
//    
//    func getStampedEntries(stampIndex: Int)-> [Entry] {
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "stampIndex == %@", stampIndex)
//        
//        do {
//            let entries = try viewContext.fetch(fetchRequest)
//            if entries.isEmpty {
//                return []
//            } else {
//                return entries
//            }
//        } catch {
//            print("failed to fetch stamped entries \(error)")
//        }
//        return []
//    }
//}
