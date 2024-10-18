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

enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
}



@objc(Entry)
public class Entry: NSManagedObject, Codable {
    
    required public convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        self.init(context: context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decodeIfPresent(UUID.self, forKey: .id)!
        content = try values.decodeIfPresent(String.self, forKey: .content) ?? "could not retrieve content"
        time = try values.decodeIfPresent(Date.self, forKey: .time) ?? Date()
        
        if let colorData = try values.decodeIfPresent(Data.self, forKey: .color) {
            color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) ?? UIColor.clear
        }
        
        stampIcon = try values.decodeIfPresent(String.self, forKey: .stampIcon) ?? ""
        entryReplyId = try values.decodeIfPresent(String.self, forKey: .entryReplyId) ?? ""
        prompt = try values.decodeIfPresent(String.self, forKey: .prompt) ?? ""

        logId = try values.decodeIfPresent(UUID.self, forKey: .logId)

        stampIndex = try values.decodeIfPresent(Int16.self, forKey: .stampIndex) ?? -1
        mediaFilename = try values.decodeIfPresent(String.self, forKey: .mediaFilename) ?? ""
        isHidden = try values.decodeIfPresent(Bool.self, forKey: .isHidden) ?? false
        isPinned = try values.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        
        isShown = try values.decode(Bool.self, forKey: .isShown)
        isRemoved = try values.decode(Bool.self, forKey: .isRemoved)
        isDrafted = try values.decode(Bool.self, forKey: .isDrafted)
        pageNum_pdf = try values.decode(Int16.self, forKey: .pageNum_pdf)
        reminderId = try values.decodeIfPresent(String.self, forKey: .reminderId)
        eventId = try values.decodeIfPresent(String.self, forKey: .eventId)

        self.tagNames = try values.decodeIfPresent([String].self, forKey: .tagNames) ?? []

    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(reminderId, forKey: .reminderId)
        try container.encodeIfPresent(eventId, forKey: .eventId)

        try container.encodeIfPresent(content, forKey: .content)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(prompt, forKey: .prompt)

        try container.encodeIfPresent(time, forKey: .time)
        try container.encodeIfPresent(stampIndex, forKey: .stampIndex)
        
        try container.encodeIfPresent(try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true), forKey: .color)
        
        try container.encodeIfPresent(stampIcon, forKey: .stampIcon)
        try container.encodeIfPresent(entryReplyId, forKey: .entryReplyId)
        
        try container.encodeIfPresent(mediaFilename, forKey: .mediaFilename)
        try container.encodeIfPresent(isHidden, forKey: .isHidden)
        try container.encodeIfPresent(isPinned, forKey: .isPinned)
        
        try container.encode(isShown, forKey: .isShown)
        try container.encode(isRemoved, forKey: .isRemoved)
        try container.encodeIfPresent(isDrafted, forKey: .isDrafted)
        try container.encodeIfPresent(pageNum_pdf, forKey: .pageNum_pdf)
        try container.encodeIfPresent(logId, forKey: .logId)
        try container.encodeIfPresent(tagNames, forKey: .tagNames)

    }
    
    private enum CodingKeys: String, CodingKey {
        case id, time, content, color, stampIcon, stampIndex, mediaFilename, isHidden, isPinned, isShown, isRemoved, isDrafted, pageNum_pdf, reminderId, entryReplyId, logId, tagNames, eventId, prompt, title
    }
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
