//
//  Entry+CoreDataProperties.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//
//

import Foundation
import CoreData


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var content: String
    @NSManaged public var time: Date
    @NSManaged public var relationship: Log
    @NSManaged public var isImportant: Bool
    @NSManaged public var id: UUID

}

extension Entry : Identifiable {
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self.time)
    }
}
