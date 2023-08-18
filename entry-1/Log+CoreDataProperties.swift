//
//  Log+CoreDataProperties.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//
//

import Foundation
import CoreData


extension Log {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Log> {
        return NSFetchRequest<Log>(entityName: "Log")
    }

    @NSManaged public var day: String
    @NSManaged public var id: UUID
    @NSManaged public var relationship: NSSet
    @NSManaged public var recentlyDeleted: NSSet


}

// MARK: Generated accessors for relationship
extension Log {
//    func addToEntries(_ entry: Entry) {
////        guard let time = entry.time, let content = entry.content else { return }
//        self.entries.append(entry)
//    }

    @objc(addRelationshipObject:)
    @NSManaged public func addToRelationship(_ value: Entry)

    @objc(removeRelationshipObject:)
    @NSManaged public func removeFromRelationship(_ value: Entry)

    @objc(addRelationship:)
    @NSManaged public func addToRelationship(_ values: NSSet)

    @objc(removeRelationship:)
    @NSManaged public func removeFromRelationship(_ values: NSSet)

}

extension Log : Identifiable {

}
