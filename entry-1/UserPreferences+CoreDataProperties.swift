//
//  UserPreferences+CoreDataProperties.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//
//

import Foundation
import CoreData
import SwiftUI


extension UserPreferences {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserPreferences> {
        return NSFetchRequest<UserPreferences>(entityName: "UserPreferences")
    }

    @NSManaged public var color: UIColor
    @NSManaged public var font: String
    @NSManaged public var fontsize: Int16

}

extension UserPreferences : Identifiable {

}
