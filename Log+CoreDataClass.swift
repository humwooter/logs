//
//  Log+CoreDataClass.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//
//

import Foundation
import CoreData

@objc(Log)
public class Log: NSManagedObject, Codable {
    required public convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
          }

          self.init(context: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decodeIfPresent(UUID.self, forKey: .id)!
        day = try values.decodeIfPresent(String.self, forKey: .day)!
        relationship = try (values.decode(Set<Entry>?.self, forKey: .relationship) as NSSet?)!
        self.entry_ids = try values.decodeIfPresent([String].self, forKey: .entry_ids) ?? []

    }
    
    public func encode(to encoder: Encoder) throws {
        print("entry: \(self)")
     
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(day, forKey: .day)
        if let relationshipSet = relationship as? Set<Entry> {
            try container.encode(relationshipSet, forKey: .relationship)
        }
        try container.encodeIfPresent(entry_ids, forKey: .entry_ids)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, day, relationship,entry_ids
    }
}
