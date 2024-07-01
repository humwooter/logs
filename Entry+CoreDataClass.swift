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

struct AttributedStringCodableWrapper: Codable {
    let attributedString: NSAttributedString
    
    init(attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        do {
            self.attributedString = try NSAttributedString(data: data, options: [:], documentAttributes: nil)
        } catch {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Failed to decode NSAttributedString: \(error)")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = try attributedString.data(from: NSRange(location: 0, length: attributedString.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])
        try container.encode(data)
    }
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
        content = try values.decodeIfPresent(String.self, forKey: .content)!
        let attributedContentWrapper = try values.decodeIfPresent(AttributedStringCodableWrapper.self, forKey: .attributedContent)
        attributedContent = attributedContentWrapper?.attributedString
        time = try values.decodeIfPresent(Date.self, forKey: .time)!
        
        if let colorData = try values.decodeIfPresent(Data.self, forKey: .color) {
            color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) ?? UIColor.clear
        }
        
        stampIcon = try values.decodeIfPresent(String.self, forKey: .stampIcon)!
        entryReplyId = try values.decodeIfPresent(String.self, forKey: .entryReplyId) ?? ""
        stampIndex = try values.decodeIfPresent(Int16.self, forKey: .stampIndex)!
        mediaFilename = try values.decodeIfPresent(String.self, forKey: .mediaFilename) ?? ""
        isHidden = try values.decodeIfPresent(Bool.self, forKey: .isHidden)!
        isPinned = try values.decodeIfPresent(Bool.self, forKey: .isPinned)!
        
        isShown = try values.decode(Bool.self, forKey: .isShown)
        isRemoved = try values.decode(Bool.self, forKey: .isRemoved)
        isDrafted = try values.decode(Bool.self, forKey: .isDrafted)
        pageNum_pdf = try values.decode(Int16.self, forKey: .pageNum_pdf)
        reminderId = try values.decodeIfPresent(String.self, forKey: .reminderId)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(reminderId, forKey: .reminderId)
        try container.encodeIfPresent(content, forKey: .content)
        try container.encodeIfPresent(time, forKey: .time)
        try container.encode(stampIndex, forKey: .stampIndex)
        
        try container.encodeIfPresent(try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true), forKey: .color)
        
        try container.encodeIfPresent(stampIcon, forKey: .stampIcon)
        try container.encodeIfPresent(entryReplyId, forKey: .entryReplyId)
        
        try container.encodeIfPresent(mediaFilename, forKey: .mediaFilename)
        try container.encodeIfPresent(isHidden, forKey: .isHidden)
        try container.encodeIfPresent(isPinned, forKey: .isPinned)
        
        try container.encode(isShown, forKey: .isShown)
        try container.encode(isRemoved, forKey: .isRemoved)
        try container.encode(isDrafted, forKey: .isDrafted)
        try container.encode(pageNum_pdf, forKey: .pageNum_pdf)
        
        if let attributedContent = self.attributedContent {
            let attributedContentWrapper = AttributedStringCodableWrapper(attributedString: attributedContent)
            try container.encode(attributedContentWrapper, forKey: .attributedContent)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, time, content, color, stampIcon, stampIndex, mediaFilename, isHidden, isPinned, isShown, isRemoved, isDrafted, pageNum_pdf, reminderId, entryReplyId, attributedContent
    }
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
