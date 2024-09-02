//
//  Folder+CoreDataProperties.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/22/24.
//

import Foundation
import CoreData


extension Folder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Folder> {
        return NSFetchRequest<Folder>(entityName: "Folder")
    }

    @NSManaged public var id: UUID
    @NSManaged public var parentId: UUID?
    @NSManaged public var name: String?
    @NSManaged public var folderType: String?
    @NSManaged public var order: Int16
    @NSManaged public var entryCount: Int16

}

extension Folder : Identifiable {

}
