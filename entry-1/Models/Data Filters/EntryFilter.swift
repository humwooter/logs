//
//  EntryFilter.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/31/24.
//
import CoreData
import UIKit

class EntryFilter {
    enum FilterType {
        case content(String)
        case title(String)
        case time(Date, Date)
        case lastUpdated(Date, Date)
        case color(UIColor)
        case tagNames(String)
        case isHidden(Bool)
        case hasMedia(Bool)
        case hasReminder(Bool)
        case isShown(Bool)
        case isPinned(Bool)
        case isRemoved(Bool)
        case isDrafted(Bool)
        case shouldSyncWithCloudKit(Bool)
        case stampIcon(String)
        case folderId(String)
    }
    
    private var filters: [FilterType] = []
    
    func addFilter(_ filter: FilterType) {
        filters.append(filter)
    }
    
    func clearFilters() {
        filters.removeAll()
    }
    
    func buildPredicate() -> NSPredicate {
        var subpredicates: [NSPredicate] = []
        
        for filter in filters {
            switch filter {
            case .content(let searchString):
                subpredicates.append(NSPredicate(format: "content CONTAINS[cd] %@", searchString))
            case .title(let searchString):
                subpredicates.append(NSPredicate(format: "title CONTAINS[cd] %@", searchString))
            case .time(let startDate, let endDate):
                subpredicates.append(NSPredicate(format: "time >= %@ AND time <= %@", startDate as NSDate, endDate as NSDate))
            case .lastUpdated(let startDate, let endDate):
                subpredicates.append(NSPredicate(format: "lastUpdated >= %@ AND lastUpdated <= %@", startDate as NSDate, endDate as NSDate))
            case .color(let color):
                subpredicates.append(NSPredicate(format: "color == %@", color))
            case .tagNames(let tags):
                let tagPredicates = tags.components(separatedBy: ",").map { tag in
                    NSPredicate(format: "tagNames CONTAINS[cd] %@", tag.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                subpredicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: tagPredicates))
            case .isHidden(let value):
                subpredicates.append(NSPredicate(format: "isHidden == %@", NSNumber(value: value)))
            case .isShown(let value):
                subpredicates.append(NSPredicate(format: "isShown == %@", NSNumber(value: value)))
            case .isPinned(let value):
                subpredicates.append(NSPredicate(format: "isPinned == %@", NSNumber(value: value)))
            case .isRemoved(let value):
                subpredicates.append(NSPredicate(format: "isRemoved == %@", NSNumber(value: value)))
            case .isDrafted(let value):
                subpredicates.append(NSPredicate(format: "isDrafted == %@", NSNumber(value: value)))
            case .shouldSyncWithCloudKit(let value):
                subpredicates.append(NSPredicate(format: "shouldSyncWithCloudKit == %@", NSNumber(value: value)))
            case .stampIcon(let icon):
                subpredicates.append(NSPredicate(format: "stampIcon == %@", icon))
            case .folderId(let id):
                subpredicates.append(NSPredicate(format: "folderId == %@", id))
            case .hasMedia(let hasMedia):
                if hasMedia {
                    subpredicates.append(NSPredicate(format: "mediaFilename != nil AND mediaFilename != ''"))
                } else {
                    subpredicates.append(NSPredicate(format: "mediaFilename == nil OR mediaFilename == ''"))
                }
            case .hasReminder(let hasReminder):
                if hasReminder {
                    subpredicates.append(NSPredicate(format: "reminderId != nil AND reminderId != ''"))
                } else {
                    subpredicates.append(NSPredicate(format: "reminderId == nil OR reminderId == ''"))
                }
            }
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
    }
    
    func fetchEntries(in context: NSManagedObjectContext, limit: Int? = nil, offset: Int? = nil) -> [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = buildPredicate()
        
        // Optimize fetch request
        fetchRequest.includesPropertyValues = true
        
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        
        if let offset = offset {
            fetchRequest.fetchOffset = offset
        }
        
        // Add sorting if needed
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching filtered entries: \(error)")
            return []
        }
    }
}
