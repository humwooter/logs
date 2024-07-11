//
//  GlobalFuncs.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 9/25/23.
//

import Foundation
import CoreData
import SwiftUI
import EventKit
import AVKit


// Helper function to safely apply attributes to a mutable attributed string
func safelyApplyAttributes(to mutableAttributedString: NSMutableAttributedString, attributes: [NSAttributedString.Key: Any], range: NSRange) {
    let safeRange = NSRange(location: min(range.location, mutableAttributedString.length), length: min(range.length, mutableAttributedString.length - range.location))
    mutableAttributedString.addAttributes(attributes, range: safeRange)
}


func createThumbnailOfVideoFromRemoteUrl(url: URL) -> UIImage? {
    let asset = AVAsset(url: url)
    let assetImgGenerate = AVAssetImageGenerator(asset: asset)
    assetImgGenerate.appliesPreferredTrackTransform = true
    //Can set this to improve performance if target size is known before hand
    //assetImgGenerate.maximumSize = CGSize(width,height)
    let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
    do {
        let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
        let thumbnail = UIImage(cgImage: img)
        return thumbnail
    } catch {
      print(error.localizedDescription)
      return nil
    }
}

//func extractFirstURL(from text: String) -> URL? {
//    print("ENTERED extractFirstURL")
//    let pattern = "https?://[a-zA-Z0-9_./-]+\\??[a-zA-Z0-9_=&./-]*"
//    if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
//        let nsText = text as NSString
//        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))
//        
//        if let match = matches.first {
//            let range = match.range
//            let urlString = nsText.substring(with: range)
//            print("URL STRING: \(urlString)")
//            return URL(string: urlString)
//        }
//    }
//    return nil
//}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}


func printColorComponents(color: UIColor) {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
        print("Red: \(red), Green: \(green), Blue: \(blue), Alpha: \(alpha)")
    } else {
        print("Could not retrieve color components.")
    }
}


func isClear(for color: UIColor) -> Bool {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    return ((red + green + blue + alpha) == 0 || alpha == 0)
}
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
        let dateStringManager = DateStrings()
        let newLog = Log(context: viewContext)
        newLog.day = formattedDate(Date())
        dateStringManager.addDate(formattedDate(Date()))
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


//func deleteEntry(entry: Entry, coreDataManager: CoreDataManager) {
//    let mainContext = coreDataManager.viewContext
//    mainContext.performAndWait {
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
//        do {
//            let fetchedEntries = try mainContext.fetch(fetchRequest)
//            guard let entryToDeleteInContext = fetchedEntries.first else {
//                print("Failed to fetch entry in main context")
//                return
//            }
//            print("entry to delete: \(entryToDeleteInContext)")
//
//            // Delete image
//            entry.deleteImage(coreDataManager: coreDataManager)
//
//            // Now perform the entry deletion
//            entry.relationship.removeFromRelationship(entryToDeleteInContext)
//            mainContext.delete(entryToDeleteInContext)
//
//
//            try mainContext.save()
//            print("DONE!")
//            print("entry to delete: \(entryToDeleteInContext)")
//        } catch {
//            print("Failed to save main context: \(error)")
//        }
//    }
//}




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
            
            // If there's an associated reminder, attempt to delete it
            if let reminderId = entryToDeleteInContext.reminderId, !reminderId.isEmpty {
                let eventStore = EKEventStore() // Initialize EKEventStore to work with reminders
                eventStore.requestFullAccessToReminders { granted, error in
                    guard granted, error == nil else {
                        print("Access to reminders denied or failed: \(String(describing: error))")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
                            do {
                                try eventStore.remove(reminder, commit: true)
                                print("Reminder successfully deleted")
                            } catch {
                                print("Failed to delete reminder: \(error)")
                            }
                        }
                    }
                }
            }
            
            // Delete image associated with the entry
            entry.deleteImage(coreDataManager: coreDataManager)
            
            // Perform the entry deletion
            entry.relationship.removeFromRelationship(entryToDeleteInContext)
            mainContext.delete(entryToDeleteInContext)
            
            try mainContext.save()
            print("Entry successfully deleted")
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



// Text Funcs
func countNewlines(in string: String) -> Int {
    return string.filter { $0 == "\n" }.count
}

//func insertOrAppendText(_ text: String, into content: String, at cursorPosition: NSRange?) -> (String, NSRange) {
//    var modifiedContent = content
//    var newCursorPosition = cursorPosition
//
//    if let cursorPosition = cursorPosition,
//       let rangeStart = content.index(content.startIndex, offsetBy: cursorPosition.location, limitedBy: content.endIndex) {
//
//        // If cursorPosition.length > 0, it means text is selected, and we are replacing it.
//        let rangeEnd = cursorPosition.length > 0 ?
//            content.index(rangeStart, offsetBy: cursorPosition.length, limitedBy: content.endIndex) ?? rangeStart :
//            rangeStart
//        let stringRange = rangeStart..<rangeEnd
//        modifiedContent.replaceSubrange(stringRange, with: text)
//
//        // Update cursor position to be right after the inserted text
//        let newLocation = content.distance(from: content.startIndex, to: rangeStart) + text.count
//        newCursorPosition = NSRange(location: newLocation, length: 0)
//    } else {
//        modifiedContent += text
//
//        // Update cursor position to the end of the content
//        let newLocation = modifiedContent.count
//        newCursorPosition = NSRange(location: newLocation, length: 0)
//    }
//
//    return (modifiedContent, newCursorPosition!)
//}

func insertOrAppendText(_ text: String, into content: String, at cursorPosition: NSRange?) -> (String, NSRange) {
    var modifiedContent = content
    var newCursorPosition = cursorPosition
    
    if let cursorPosition = cursorPosition,
       let rangeStart = content.index(content.startIndex, offsetBy: cursorPosition.location, limitedBy: content.endIndex) {
        
        // If cursorPosition.length > 0, it means text is selected, and we are replacing it.
        let rangeEnd = cursorPosition.length > 0 ?
        content.index(rangeStart, offsetBy: cursorPosition.length, limitedBy: content.endIndex) ?? rangeStart :
        rangeStart
        let stringRange = rangeStart..<rangeEnd
        modifiedContent.replaceSubrange(stringRange, with: text)
        
        // Update cursor position to be right after the inserted text.
        // The new position should be calculated based on the modifiedContent.
        let newLocation = modifiedContent.distance(from: modifiedContent.startIndex, to: rangeStart) + text.count
        newCursorPosition = NSRange(location: newLocation, length: 0)
    } else {
        modifiedContent += text
        
        // Update cursor position to the end of the content, which is the length of the modifiedContent
        let newLocation = modifiedContent.count
        newCursorPosition = NSRange(location: newLocation, length: 0)
    }
    
    return (modifiedContent, newCursorPosition!)
}



func getDefaultEntryBackgroundColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .dark ? defaultEntryBackgroundColor_dark : .white
}

func getDefaultBackgroundColor(colorScheme: ColorScheme) -> Color {
    let uiColor = colorScheme == .dark ? UIColor.black : UIColor(defaultBackgroundColor)
    return Color(uiColor)
}
