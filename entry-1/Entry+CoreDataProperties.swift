//
//  Entry+CoreDataProperties.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//
//

import Foundation
import CoreData
import SwiftUI


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    
    @NSManaged public var content: String
    @NSManaged public var time: Date
    @NSManaged public var relationship: Log
    @NSManaged public var buttons: [Bool]
    @NSManaged public var id: UUID
    @NSManaged public var color: UIColor
    @NSManaged public var image: String
    @NSManaged public var imageContent: String?
    @NSManaged public var isHidden: Bool

    func formattedTime(debug: String) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self.time)
    }
    
    
    func deleteImage(coreDataManager: CoreDataManager) {
        let mainContext = coreDataManager.viewContext
        if let filename = self.imageContent {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    print("Error deleting image file: \(error)")
                }
            } else {
                print("File does not exist at path: \(fileURL.path)")
            }
        }
        
        self.imageContent = ""
        
        do {
            try mainContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
//    func deleteEntry(coreDataManager: CoreDataManager) {
//        print("entered delete entry")
//        let mainContext = coreDataManager.viewContext
//        mainContext.performAndWait {
//
//            let parentLog = self.relationship
//
//            //remove from log relationship
//            parentLog.removeFromRelationship(self)
//            print("removed from log")
//
//            //delete image
//            self.deleteImage(coreDataManager: coreDataManager)
//            print("deleted image")
//
//            mainContext.delete(self)
//            print("deleted entry")
//
//            do {
//                try mainContext.save()
//            } catch {
//                print("Failed to save main context: \(error)")
//            }
//        }
//    }
    
//    static func deleteEntry(_ entry: Entry, coreDataManager: CoreDataManager) {
//        print("1")
//        let mainContext = coreDataManager.viewContext
//        mainContext.performAndWait {
//            print("2")
//            let parentLog = entry.relationship
//            print("3")
//            // Now perform the entry deletion
//            parentLog.removeFromRelationship(entry)
//            print("4")
//            // Delete image
//            entry.deleteImage(coreDataManager: coreDataManager)
//
//print("5")
//            mainContext.delete(entry)
//
//            do {
//                try mainContext.save()
//                print("6")
//            } catch {
//                print("Failed to save main context: \(error)")
//            }
//        }
//    }
    
    static func deleteEntry(entry: Entry, coreDataManager: CoreDataManager) {
        let mainContext = coreDataManager.viewContext
        mainContext.performAndWait {
            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
            do {
                let fetchedEntries = try mainContext.fetch(fetchRequest)
                guard let entryToDeleteInContext = fetchedEntries.first else {
                    print("Failed to fetch entry in main context")
                    return
                }
                print("entry to delete: \(entryToDeleteInContext)")
                
                // Delete image
                entry.deleteImage(coreDataManager: coreDataManager)
                
                // Now perform the entry deletion
                entry.relationship.removeFromRelationship(entryToDeleteInContext)
                mainContext.delete(entryToDeleteInContext)
                
                
                try mainContext.save()
                print("DONE!")
                print("entry to delete: \(entryToDeleteInContext)")
            } catch {
                print("Failed to save main context: \(error)")
            }
        }
    }

    

}

extension Entry : Identifiable {

}
