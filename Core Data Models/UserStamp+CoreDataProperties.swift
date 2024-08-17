//
//  UserStamp+CoreDataProperties.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/14/24.
//
//

import Foundation
import CoreData


extension UserStamp {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserStamp> {
        return NSFetchRequest<UserStamp>(entityName: "UserStamp")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var index: Int16
    @NSManaged public var name: String?
    @NSManaged public var color: NSObject?
    @NSManaged public var imageName: String?
    @NSManaged public var isActive: Bool

}

extension UserStamp : Identifiable {

}
