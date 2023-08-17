//
//  Entry+CoreDataProperties.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//
//

import Foundation
import CoreData
import SwiftUI


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var content: String
    @NSManaged public var time: Date
    @NSManaged public var relationship: Log
    @NSManaged public var isButton1: Bool
    @NSManaged public var isButton2: Bool
    @NSManaged public var isButton3: Bool
    @NSManaged public var id: UUID
    @NSManaged public var color: UIColor
    @NSManaged public var image: String


//    @NSManaged public var activatedButtons: [Bool]

}

extension Entry : Identifiable {
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self.time)
    }
}
