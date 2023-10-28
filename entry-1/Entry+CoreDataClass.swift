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
    
//    required public convenience init(from decoder: Decoder) throws {
//        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
//            throw DecoderConfigurationError.missingManagedObjectContext
//          }
//
//          self.init(context: context)
//
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        id = try values.decodeIfPresent(UUID.self, forKey: .id)!
//        content = try values.decodeIfPresent(String.self, forKey: .content)!
//        time = try values.decodeIfPresent(Date.self, forKey: .time)!
//        buttons = try values.decodeIfPresent([Bool].self, forKey: .buttons)!
////        color = try values.decodeIfPresent(UIColor.self, forKey: .color)!
//
//        if let colorData = try values.decodeIfPresent(Data.self, forKey: .color) {
//            color = try (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor)!
//        }
//
//        image = try values.decodeIfPresent(String.self, forKey: .image)!
//        imageContent = try values.decodeIfPresent(String.self, forKey: .imageContent)!
//        isHidden = try values.decodeIfPresent(Bool.self, forKey: .isHidden)!
////       relationship = try values.decodeIfPresent(Log.self, forKey: .relationship)!
//    }
    
    required public convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }

        self.init(context: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        content = try values.decodeIfPresent(String.self, forKey: .content) ?? ""
        time = try values.decodeIfPresent(Date.self, forKey: .time) ?? Date()
        buttons = try values.decodeIfPresent([Bool].self, forKey: .buttons) ?? [false, false, false, false, false]
        
        
        if let colorString = try values.decodeIfPresent(String.self, forKey: .color) {
            color = UIColor(Color(hex: colorString))
            print("\(self.content)")
            print("color: \(colorString)")
            print()
        } else {
            print("couldn't decode color:")
            color = UIColor.clear
        }
        
        image = try values.decodeIfPresent(String.self, forKey: .image) ?? ""
        
        // Check if the imageContent filename exists
        if let imageContent = try values.decodeIfPresent(String.self, forKey: .imageContent) {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(imageContent)
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                self.imageContent = imageContent
            } else {
                print("image file no longer exists")
                self.imageContent = ""
            }
        } else {
            self.imageContent = ""
        }
        
        isHidden = try values.decodeIfPresent(Bool.self, forKey: .isHidden) ?? false
    }
    
    public func encode(to encoder: Encoder) throws {
        print("entry: \(self)")
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(content, forKey: .content)
        try container.encodeIfPresent(time, forKey: .time)
        try container.encodeIfPresent(buttons, forKey: .buttons)
//        try container.encodeIfPresent(color, forKey: .color)
   
        try container.encode(Color(color).toHex(), forKey: .color)
        
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(imageContent, forKey: .imageContent)
        try container.encodeIfPresent(isHidden, forKey: .isHidden)

     }
    
    private enum CodingKeys: String, CodingKey {
        case id, time, content, buttons, color, image, imageContent, isHidden
    }
    
}


extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
