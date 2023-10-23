//
//  GlobalFuncs.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 9/25/23.
//

import Foundation
import CoreData

public func imageExists(at url: URL) -> Bool {
    return FileManager.default.fileExists(atPath: url.path)
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

func formattedTime(time: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: time)
}

func isGIF(data: Data) -> Bool {
    return data.prefix(6) == Data([0x47, 0x49, 0x46, 0x38, 0x37, 0x61]) || data.prefix(6) == Data([0x47, 0x49, 0x46, 0x38, 0x39, 0x61])
}

func formattedDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.string(from: date)
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

func currentDate() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter.string(from: Date())
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

func deleteOldEntries() { //only deletes old deleted entroes
    let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    
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


