//
//  Tag+CoreDataProperties.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/21/24.
//

import SwiftUI
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var numEntries: Int16
    @NSManaged public var entryIds: [String]

}

extension Tag : Identifiable {

}
