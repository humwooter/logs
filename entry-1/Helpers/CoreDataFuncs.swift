//
//  CoreDataFuncs.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 3/25/24.
//

import Foundation
import CoreData
import SwiftUI
import EventKit




func fetchLogByDate(date: String, coreDataManager: CoreDataManager) -> Log? {
    let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "day == %@", date)

    do {
        let logs = try coreDataManager.viewContext.fetch(fetchRequest)
        return logs.first // Assuming there's either one log per date or you're interested in the first one
    } catch let error as NSError {
        print("Could not fetch log for date \(date): \(error), \(error.userInfo)")
        return nil
    }
}

func createLog(date: Date, coreDataManager: CoreDataManager) -> Log{
    let newLog = Log(context: coreDataManager.viewContext) // Create a new Log instance in the managed object context.
    newLog.id = UUID() // Assign a unique ID.
    newLog.day = formattedDate(date) // Format and set the date string for the log.

    newLog.relationship = NSSet()

    do {
        try coreDataManager.viewContext.save() // Save the new log to the persistent store.
    } catch {
        print("Failed to save the new log: \(error.localizedDescription)")
    }
    
    return newLog
}

func fetchEntryById(id: String, coreDataManager: CoreDataManager) -> Entry? {
    let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %@", UUID(uuidString: id) as CVarArg? ?? "")

    
    do {
        let entries = try coreDataManager.viewContext.fetch(fetchRequest)
        return entries.first // Assuming there's either one log per date or you're interested in the first one
    } catch let error as NSError {
        print("Could not fetch entry with id \(id): \(error), \(error.userInfo)")
        return nil
    }
    
}
