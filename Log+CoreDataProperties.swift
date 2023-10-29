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

extension Log {

    @objc(addRelationshipObject:)
    @NSManaged public func addToRelationship(_ value: Entry)

    @objc(removeRelationshipObject:)
    @NSManaged public func removeFromRelationship(_ value: Entry)

    @objc(addRelationship:)
    @NSManaged public func addToRelationship(_ values: NSSet)

    @objc(removeRelationship:)
    @NSManaged public func removeFromRelationship(_ values: NSSet)
    
    @objc 
    static func dayDidChange() {
        print("ENTERED DAY DID CHANEG")
        // Here we can do our cleanup and refresh the fetch request
        deleteOldEntries()
        // FetchRequest will automatically reload since the underlying data changes
    }

}

extension Log : Identifiable {

}
