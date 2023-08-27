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

    enum CodingKeys: String, CodingKey {
      case id, content, time, buttons, color, image
    }
    
    @NSManaged public var content: String
    @NSManaged public var time: Date
    @NSManaged public var relationship: Log
    @NSManaged public var buttons: [Bool]
    @NSManaged public var id: UUID
    @NSManaged public var color: UIColor
    @NSManaged public var image: String
    @NSManaged public var imageContent: String?
    @NSManaged public var isHidden: Bool

    func formattedTime(debug: String) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self.time)
    }
//    func formattedTime_2(debug: String) -> String {
//        print("\(debug)")
//        print("entered formatted time")
//        print("entry is: \(self)")
//        print("entry.time = \(self.time)")
//        let formatter = DateFormatter()
//        formatter.dateFormat = "E, MMM d"
//        return formatter.string(from: self.time)
//    }

    

}

extension Entry : Identifiable {

}
