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
    
    required public convenience init(from decoder: Decoder) throws { // FOR IMPORTING DATA
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
          }

          self.init(context: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decodeIfPresent(UUID.self, forKey: .id)!
        content = try values.decodeIfPresent(String.self, forKey: .content)!
        time = try values.decodeIfPresent(Date.self, forKey: .time)!
        buttons = try values.decodeIfPresent([Bool].self, forKey: .buttons)!

        if let colorData = try values.decodeIfPresent(Data.self, forKey: .color) {
            color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) ?? UIColor()
        }

        image = try values.decodeIfPresent(String.self, forKey: .image)!
        imageContent = try values.decodeIfPresent(String.self, forKey: .imageContent)!
        isHidden = try values.decodeIfPresent(Bool.self, forKey: .isHidden)!
    }
    

    
    public func encode(to encoder: Encoder) throws { // FOR EXPORTING DATA
        print("entry: \(self)")
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(content, forKey: .content)
        try container.encodeIfPresent(time, forKey: .time)
        try container.encodeIfPresent(stampIndex, forKey: .stampIndex)
   
//        try container.encode(Color(color).toHex(), forKey: .color)
        try container.encodeIfPresent(try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true), forKey: .color)

        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(imageContent, forKey: .imageContent)
        try container.encodeIfPresent(isHidden, forKey: .isHidden)

     }
    
    private enum CodingKeys: String, CodingKey {
        case id, time, content, buttons, color, image, imageContent, isHidden, stampIndex
    }
    
}


extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
