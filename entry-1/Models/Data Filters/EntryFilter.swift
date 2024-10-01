////
////  EntryFilter.swift
////  entry-1
////
////  Created by Katyayani G. Raman on 8/31/24.
////
//
import Foundation
import CoreData
import SwiftUI

class EntryFilter: ObservableObject {
    @Binding var searchText: String
    @Binding var filters: [FilterType]
    
    init(searchText: Binding<String>, filters: Binding<[FilterType]>) {
        _searchText = searchText
        _filters = filters
    }
    
    func buildPredicate() -> NSPredicate {
        var subpredicates: [NSPredicate] = []
        
        if !searchText.isEmpty, filters.isEmpty {
            let contentPredicate = NSPredicate(format: "content CONTAINS[cd] %@", searchText)
            let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            subpredicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [contentPredicate, titlePredicate]))
        }
        
        for filter in filters {
            
            
            if !searchText.isEmpty, filter.id != "stampIcon_" {
                let contentPredicate = NSPredicate(format: "content CONTAINS[cd] %@", searchText)
                let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
                subpredicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [contentPredicate, titlePredicate]))
            }
            
            switch filter {
            case .isHidden(let value):
                subpredicates.append(NSPredicate(format: "isHidden == %@", NSNumber(value: value)))
            case .stampIcon(let icon):
                subpredicates.append(NSPredicate(format: "stampIndex != -1 AND stampIcon CONTAINS[cd] %@", searchText))
            case .hasMedia(let value):
                if value {
                    subpredicates.append(NSPredicate(format: "mediaFilename != nil AND mediaFilename != ''"))
                } else {
                    subpredicates.append(NSPredicate(format: "mediaFilename == nil OR mediaFilename == ''"))
                }
            case .hasReminder(let value):
                if value {
                    subpredicates.append(NSPredicate(format: "reminderId != nil AND reminderId != ''"))
                } else {
                    subpredicates.append(NSPredicate(format: "reminderId == nil OR reminderId == ''"))
                }
            case .isPinned(let value):
                subpredicates.append(NSPredicate(format: "isPinned == %@", NSNumber(value: value)))
            case .tag(let tagName):
                subpredicates.append(NSPredicate(format: "ANY tagNames CONTAINS[cd] %@", tagName))
            case .date(let date):
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                subpredicates.append(NSPredicate(format: "time >= %@ AND time < %@", startOfDay as NSDate, endOfDay as NSDate))
            default:
                // Handle other cases as needed
                break
            }
        }
        
        if subpredicates.isEmpty {
            return NSPredicate(value: true)  // If no filters, return all entries
        } else {
            return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        }
    }
    
    func fetchEntries(in context: NSManagedObjectContext, limit: Int? = nil, offset: Int? = nil) -> [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = buildPredicate()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
        
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        
        if let offset = offset {
            fetchRequest.fetchOffset = offset
        }
        
        do {
            let entries = try context.fetch(fetchRequest)
            return entries
        } catch {
            print("Error fetching filtered entries: \(error)")
            return []
        }
    }
}

// Extension to handle image existence check
extension EntryFilter {
    private func imageExists(at filename: String) -> Bool {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: fileURL.path)
    }
}
