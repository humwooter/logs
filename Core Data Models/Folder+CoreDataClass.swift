//
//  Folder+CoreDataClass.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/22/24.
//


import Foundation
import CoreData



@objc(Folder)
public class Folder: NSManagedObject, Codable {
    required public convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
          }

          self.init(context: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decodeIfPresent(UUID.self, forKey: .id)!
        name = try values.decodeIfPresent(String.self, forKey: .name)!
        order = try values.decodeIfPresent(Int16.self, forKey: .order)!
        entryCount = try values.decodeIfPresent(Int16.self, forKey: .entryCount)!

    }
    
    public func encode(to encoder: Encoder) throws {
        print("entry: \(self)")
     
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(order, forKey: .order)
        try container.encodeIfPresent(entryCount, forKey: .entryCount)

        try container.encodeIfPresent(name, forKey: .name)

    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, order, entryCount
    }
}
