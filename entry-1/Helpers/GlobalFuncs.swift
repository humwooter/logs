//
//  GlobalFuncs.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 9/25/23.
//

import Foundation
import CoreData
import SwiftUI

func textColor(for backgroundColor: UIColor) -> Color {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    backgroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    let brightness = (red * 299 + green * 587 + blue * 114) / 1000
    
    return brightness > 0.5 ? Color.black : Color.white
}

func isColorLight(_ color: Color) -> Bool {
    let uiColor = UIColor(color)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    let brightness = (red * 299 + green * 587 + blue * 114) / 1000
    
    return brightness > 0.5
}



func createLog(in viewContext: NSManagedObjectContext) {
    if (!logExists(day: Date(), inContext: viewContext)) {
        let newLog = Log(context: viewContext)
        newLog.day = formattedDate(Date())
        newLog.id = UUID()
        do {
            try viewContext.save()
        } catch {
            print("Error saving new log: \(error)")
        }
    }
    else {
        print("log already exists")
    }
}

func logExists(id: UUID, inContext context: NSManagedObjectContext) -> Bool {
    var exists = false
    context.performAndWait {
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let existingLogs = try context.fetch(fetchRequest)
            exists = existingLogs.first != nil
        } catch {
            print("Failed to check log existence: \(error)")
        }
    }
    return exists
}

func logExists(day: Date, inContext context: NSManagedObjectContext) -> Bool {
    var exists = false
    context.performAndWait {
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "day == %@", formattedDate(day))
        do {
            let existingLogs = try context.fetch(fetchRequest)
            exists = existingLogs.first != nil
        } catch {
            print("Failed to check log existence: \(error)")
        }
    }
    return exists
}



func checkDiskSpace() {
    do {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        if let capacity = values.volumeAvailableCapacityForImportantUsage {
            print("Available disk space: \(capacity) bytes")
        }
    } catch {
        print("Error retrieving disk capacity: \(error)")
    }
}


func deleteEntry(entry: Entry, coreDataManager: CoreDataManager) {
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

//removes entries that are older than 10 days old
func deleteOldEntries() {
    let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: Date())
    
    let mainContext = CoreDataManager.shared.viewContext
    let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
        NSPredicate(format: "isRemoved == %@", NSNumber(value: true)),
        NSPredicate(format: "time < %@", tenDaysAgo! as CVarArg)
    ])
    
    do {
        let oldEntries = try mainContext.fetch(fetchRequest)
        for entry in oldEntries {
            deleteEntry(entry: entry, coreDataManager: CoreDataManager.shared)
        }
        try mainContext.save()
    } catch let error {
        print("Failed to delete old entries: \(error)")
    }
}


