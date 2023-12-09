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
    @NSManaged public var id: UUID
    @NSManaged public var color: UIColor
    @NSManaged public var image: String
    @NSManaged public var imageContent: String?
    @NSManaged public var isHidden: Bool
    @NSManaged public var isShown: Bool
    @NSManaged public var isPinned: Bool
    @NSManaged public var isRemoved: Bool
    @NSManaged public var stampIndex: Int16
    @NSManaged public var buttons: [Bool]

    
    
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
    

    
    func hideEntry () {
        if self.isHidden == nil {
            self.isHidden = false
        }
        self.isHidden.toggle()
    }
    
    func saveImage(data: Data, coreDataManager: CoreDataManager) { //should check whether image exists already first and delete it
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        if let mediaFilename = self.imageContent, !mediaFilename.isEmpty { //deleting existing image
            let existingURL = documentsDirectory.appendingPathComponent(mediaFilename)
            if imageExists(at: existingURL) {
                self.deleteImage(coreDataManager: coreDataManager)
            }
        }

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
    
    func unRemove(coreDataManager: CoreDataManager) {
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        
        let formattedDay = formattedDate(self.time)
        fetchRequest.predicate = NSPredicate(format: "day == %@", formattedDay)
        
        do {
            let results = try coreDataManager.viewContext.fetch(fetchRequest)
            if let matchingLog = results.first {
                self.relationship = matchingLog
                self.isRemoved = false
                try coreDataManager.viewContext.save()
            }
        } catch let error as NSError {
            print("Fetch error: \(error), \(error.userInfo)")
        }
    }
    
    
}

extension Entry : Identifiable {
    
}
