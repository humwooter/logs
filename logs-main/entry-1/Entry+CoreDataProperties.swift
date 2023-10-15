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
    @NSManaged public var isRemoved: Bool

    
//    func formattedTime(debug: String) -> String {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        return formatter.string(from: self.time)
//    }
    
    
    func deleteImage(coreDataManager: CoreDataManager) {
        print("in delete image")
        let mainContext = coreDataManager.viewContext
        if let filename = self.imageContent {
            if filename.isEmpty {
                print("Filename is empty, no image to delete.")
                return
            }
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    print("image at \(fileURL) has been deleted")
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
    
    func hideEntry () {
        if self.isHidden == nil {
            self.isHidden = false
        }
        self.isHidden.toggle()
    }
    
    func saveImage(data: Data, coreDataManager: CoreDataManager) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let uniqueFilename = self.id.uuidString + ".png"
        let fileURL = documentsDirectory.appendingPathComponent(uniqueFilename)
        
        do {
            print("file URL from saveImage: \(fileURL)")
            try data.write(to: fileURL)
        } catch {
            print("Error saving image file: \(error)")
        }
        
        self.imageContent = uniqueFilename
        print("entry from saveImage: \(self)")
        
        let mainContext = coreDataManager.viewContext
        do {
            try mainContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
}

extension Entry : Identifiable {
    
}
