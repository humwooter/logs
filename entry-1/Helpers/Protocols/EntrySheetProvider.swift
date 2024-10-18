//
//  EntrySheetProvider.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/18/24.
//

import SwiftUI
import UIKit
import CoreData

 protocol EntryCreationProvider {
    var coreDataManager: CoreDataManager { get }
    var userPreferences: UserPreferences { get }
    var reminderManager: ReminderManager { get }
    var eventManager: EventManager { get }
    var datesModel: DatesModel { get }
    var colorScheme: ColorScheme { get }
    
    var selectedData: Data? { get }
    var selectedTags: [String] { get }
    var reminderId: String? { get }
     var eventId: String? { get }
    var replyEntryId: String? { get }
    var entryContent: String { get }
    var selectedDate: Date { get }

}


extension EntryCreationProvider {
    func finalizeCreation() {
        let viewContext = coreDataManager.viewContext
        let newEntry = Entry(context: viewContext)
        newEntry.id = UUID()
        newEntry.content = entryContent
        newEntry.time = selectedDate
        newEntry.lastUpdated = nil
        newEntry.stampIndex = -1
        newEntry.color = UIColor.clear
        newEntry.stampIcon = ""
        newEntry.isHidden = false
        newEntry.isRemoved = false
        newEntry.isDrafted = false
        newEntry.isPinned = false
        newEntry.isShown = true
        newEntry.shouldSyncWithCloudKit = false
        newEntry.tagNames = selectedTags

        if let data = selectedData {
            if let savedFilename = saveMedia(data: data) {
                newEntry.mediaFilename = savedFilename
                newEntry.mediaFilenames = [savedFilename]
            } else {
                print("Failed to save media.")
            }
        }

        if  let reminderId = reminderId, !reminderId.isEmpty {
//            saveReminder()
            newEntry.reminderId = reminderId
        }
        
        if  let eventId = eventId, !eventId.isEmpty {
//            saveEvent()
            newEntry.eventId = eventId
        } else {
            newEntry.eventId = ""
        }

        if let replyEntryId = replyEntryId, !replyEntryId.isEmpty {
            newEntry.entryReplyId = replyEntryId
        }

        // Fetch the log with the appropriate day
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "day == %@", formattedDate(newEntry.time))

        do {
            let logs = try viewContext.fetch(fetchRequest)
            if let log = logs.first {
                newEntry.logId = log.id
            } else {
                let dateStringManager = DateStrings()
                let newLog = Log(context: viewContext)
                newLog.day = formattedDate(newEntry.time)
                dateStringManager.addDate(newLog.day)
                newLog.id = UUID()
                newEntry.logId = newLog.id
                datesModel.addTodayIfNotExists()
            }
            try viewContext.save()
        } catch {
            print("Error saving new entry: \(error)")
        }
    }
}
