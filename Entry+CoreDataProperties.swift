//
//  Entry+CoreDataProperties.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/14/24.
//
//

import Foundation
import CoreData


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var attributedContent: NSObject?
    @NSManaged public var color: NSObject?
    @NSManaged public var content: String?
    @NSManaged public var entryReplyId: String?
    @NSManaged public var formattedContent: Data?
    @NSManaged public var id: UUID?
    @NSManaged public var isDrafted: Bool
    @NSManaged public var isHidden: Bool
    @NSManaged public var isPinned: Bool
    @NSManaged public var isRemoved: Bool
    @NSManaged public var isShown: Bool
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var mediaFilename: String?
    @NSManaged public var mediaFilenames: NSObject?
    @NSManaged public var name: String?
    @NSManaged public var pageNum_pdf: Int16
    @NSManaged public var previousContent: String?
    @NSManaged public var reminderId: String?
    @NSManaged public var shouldSyncWithCloudKit: Bool
    @NSManaged public var stampIcon: String?
    @NSManaged public var stampIndex: Int16
    @NSManaged public var stampName: String?
    @NSManaged public var time: Date?
    @NSManaged public var title: String?
    @NSManaged public var folderId: String?
    @NSManaged public var relationship: Log?

}

extension Entry : Identifiable {

}
