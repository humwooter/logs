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
    @NSManaged public var previousContent: String?
    @NSManaged public var time: Date
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var relationship: Log
    @NSManaged public var id: UUID
    @NSManaged public var color: UIColor
    @NSManaged public var stampIcon: String
    @NSManaged public var reminderId: String?
    @NSManaged public var mediaFilename: String?
    @NSManaged public var isHidden: Bool
    @NSManaged public var isShown: Bool
    @NSManaged public var isPinned: Bool
    @NSManaged public var isRemoved: Bool
    @NSManaged public var isDrafted: Bool
    @NSManaged public var shouldSyncWithCloudKit: Bool
    @NSManaged public var stampIndex: Int16
    @NSManaged public var pageNum_pdf: Int16

    
    func deleteImage(coreDataManager: CoreDataManager) {
        print("in delete image")
        let mainContext = coreDataManager.viewContext
        if let filename = self.mediaFilename {
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
        
        self.mediaFilename = ""
        
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

        if let mediaFilename = self.mediaFilename, !mediaFilename.isEmpty { //deleting existing image
            let existingURL = documentsDirectory.appendingPathComponent(mediaFilename)
            if mediaExists(at: existingURL) {
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
        
        self.mediaFilename = uniqueFilename
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
            let log: Log

            if let matchingLog = results.first {
                // Use the existing log
                log = matchingLog
            } else {
                // Create a new log if none exists for the given day
                let datesStringManager = DateStrings()
                log = Log(context: coreDataManager.viewContext)
                log.day = formattedDay
                datesStringManager.addDate(log.day)
                log.id = UUID() // Assuming 'id' is required; generate a new UUID
            }

            // Add the entry to the log's relationship
            self.relationship = log
            self.isRemoved = false

            // Save the context
            try coreDataManager.viewContext.save()

        } catch let error as NSError {
            print("Fetch or save error: \(error), \(error.userInfo)")
        }
    }
}

extension Entry : Identifiable {
    
}
