//
//  Entry+CoreDataClass.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//
//

import Foundation
import CoreData
import SwiftUI


//
//@NSManaged public var content: String
//@NSManaged public var time: Date
//@NSManaged public var lastUpdated: Date?
//@NSManaged public var relationship: Log
//@NSManaged public var id: UUID
//@NSManaged public var color: UIColor
//@NSManaged public var stampIcon: String
//@NSManaged public var reminderId: String?
//@NSManaged public var mediaFilename: String?
//@NSManaged public var isHidden: Bool
//@NSManaged public var isShown: Bool
//@NSManaged public var isPinned: Bool
//@NSManaged public var isRemoved: Bool
//@NSManaged public var isDrafted: Bool
//@NSManaged public var stampIndex: Int16
//@NSManaged public var pageNum_pdf: Int16


enum DecoderConfigurationError: Error {
  case missingManagedObjectContext
}

@objc(Entry)
public class Entry: NSManagedObject, Codable {
    
    required public convenience init(from decoder: Decoder) throws { // FOR IMPORTING DATA
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
          }

          self.init(context: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decodeIfPresent(UUID.self, forKey: .id)!
        content = try values.decodeIfPresent(String.self, forKey: .content)!
        time = try values.decodeIfPresent(Date.self, forKey: .time)!

        if let colorData = try values.decodeIfPresent(Data.self, forKey: .color) {
            color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) ?? UIColor.clear
        }

        stampIcon = try values.decodeIfPresent(String.self, forKey: .stampIcon)!
        mediaFilename = try values.decodeIfPresent(String.self, forKey: .mediaFilename) ?? ""
        isHidden = try values.decodeIfPresent(Bool.self, forKey: .isHidden)!
        isPinned = try values.decodeIfPresent(Bool.self, forKey: .isPinned)!
        
        isShown = try values.decode(Bool.self, forKey: .isShown)
           isRemoved = try values.decode(Bool.self, forKey: .isRemoved)
           isDrafted = try values.decode(Bool.self, forKey: .isDrafted)
           pageNum_pdf = try values.decode(Int16.self, forKey: .pageNum_pdf)

    }
    

    
    public func encode(to encoder: Encoder) throws { // FOR EXPORTING DATA
        print("entry: \(self)")
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(content, forKey: .content)
        try container.encodeIfPresent(time, forKey: .time)
        try container.encodeIfPresent(stampIndex, forKey: .stampIndex)
   
        try container.encodeIfPresent(try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true), forKey: .color)

        try container.encodeIfPresent(stampIcon, forKey: .stampIcon)
        try container.encodeIfPresent(mediaFilename, forKey: .mediaFilename)
        try container.encodeIfPresent(isHidden, forKey: .isHidden)
        try container.encodeIfPresent(isPinned, forKey: .isPinned)
        
        try container.encode(isShown, forKey: .isShown)
        try container.encode(isRemoved, forKey: .isRemoved)
        try container.encode(isDrafted, forKey: .isDrafted)
        try container.encode(pageNum_pdf, forKey: .pageNum_pdf)

     }
    
    private enum CodingKeys: String, CodingKey {
        case id, time, content, color, stampIcon, mediaFilename, isHidden, isPinned, isShown, isRemoved, isDrafted, pageNum_pdf, stampIndex
    }

    
}


extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
