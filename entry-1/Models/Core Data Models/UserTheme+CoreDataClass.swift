//
//  UserTheme+CoreDataClass.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/17/24.
//

import CoreData
import SwiftUI




@objc(UserTheme)
public class UserTheme: NSManagedObject, Codable {
    
    enum CodingKeys: String, CodingKey {
         case id, name, accentColor, topColor, bottomColor, entryBackgroundColor, pinColor, reminderColor, fontName, fontSize, lineSpacing
     }
    
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var accentColor: UIColor?
    @NSManaged public var topColor: UIColor?
    @NSManaged public var bottomColor: UIColor?
    @NSManaged public var entryBackgroundColor: UIColor?
    @NSManaged public var pinColor: UIColor?
    @NSManaged public var reminderColor: UIColor?
    @NSManaged public var fontName: String?
    @NSManaged public var fontSize: Double  // Changed from CGFloat to Double
    @NSManaged public var lineSpacing: Double  // Changed from CGFloat to Double
    
    
    public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          
          try container.encode(id, forKey: .id)
          try container.encode(name, forKey: .name)
        
        try container.encodeIfPresent(try NSKeyedArchiver.archivedData(withRootObject: accentColor!, requiringSecureCoding: true), forKey: .accentColor)
        try container.encodeIfPresent(try NSKeyedArchiver.archivedData(withRootObject: topColor!, requiringSecureCoding: true), forKey: .topColor)
        try container.encodeIfPresent(try NSKeyedArchiver.archivedData(withRootObject: bottomColor!, requiringSecureCoding: true), forKey: .bottomColor)
        try container.encodeIfPresent(try NSKeyedArchiver.archivedData(withRootObject: entryBackgroundColor!, requiringSecureCoding: true), forKey: .entryBackgroundColor)
        try container.encodeIfPresent(try NSKeyedArchiver.archivedData(withRootObject: pinColor!, requiringSecureCoding: true), forKey: .pinColor)
        try container.encodeIfPresent(try NSKeyedArchiver.archivedData(withRootObject: reminderColor!, requiringSecureCoding: true), forKey: .reminderColor)
        try container.encode(fontName, forKey: .fontName)
          try container.encode(fontSize, forKey: .fontSize)
          try container.encode(lineSpacing, forKey: .lineSpacing)
      }
      
      public required convenience init(from decoder: Decoder) throws {
          guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
              throw DecoderConfigurationError.missingManagedObjectContext
          }
          self.init(context: context)
          
          let container = try decoder.container(keyedBy: CodingKeys.self)
          let values = try decoder.container(keyedBy: CodingKeys.self)

          
          id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
          name = try values.decodeIfPresent(String.self, forKey: .name) ?? "Unnamed theme"

          
          if let colorData = try values.decodeIfPresent(Data.self, forKey: .entryBackgroundColor) {
              entryBackgroundColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) ?? UIColor.clear
          }
          
          if let colorData = try values.decodeIfPresent(Data.self, forKey: .accentColor) {
              accentColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) ?? UIColor.clear
          }
          
          if let colorData = try values.decodeIfPresent(Data.self, forKey: .topColor) {
              topColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) ?? UIColor.clear
          }
          if let colorData = try values.decodeIfPresent(Data.self, forKey: .bottomColor) {
              bottomColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) ?? UIColor.clear
          }
          if let colorData = try values.decodeIfPresent(Data.self, forKey: .pinColor) {
              pinColor = try
              NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) ?? UIColor.clear
          }
          if let colorData = try values.decodeIfPresent(Data.self, forKey: .reminderColor) {
              reminderColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) ?? UIColor.clear
          }
        
          fontName = try container.decode(String.self, forKey: .fontName)
          fontSize = try container.decode(Double.self, forKey: .fontSize)
          lineSpacing = try container.decode(Double.self, forKey: .lineSpacing)
      }
    
    // Convert from UserTheme to Theme struct
    func toTheme() -> Theme {
        return Theme(
            name: self.name ?? "",
            accentColor: Color(self.accentColor ?? UIColor.clear),
            topColor: Color(self.topColor ?? UIColor.clear),
            bottomColor: Color(self.bottomColor ?? UIColor.clear),
            entryBackgroundColor: Color(self.entryBackgroundColor ?? UIColor.clear),
            pinColor: Color(self.pinColor ?? UIColor.clear),
            reminderColor: Color(self.reminderColor ?? UIColor.clear),
            fontName: self.fontName ?? "System",
            fontSize: CGFloat(self.fontSize),  // Convert back to CGFloat when used
            lineSpacing: CGFloat(self.lineSpacing)  // Convert back to CGFloat when used
        )
    }
    
    // Convert from Theme struct to UserTheme
    func fromTheme(_ theme: Theme) {
        self.id = theme.id
        self.name = theme.name
        self.accentColor = UIColor(theme.accentColor)
        self.topColor = UIColor(theme.topColor)
        self.bottomColor = UIColor(theme.bottomColor)
        self.entryBackgroundColor = UIColor(theme.entryBackgroundColor)
        self.pinColor = UIColor(theme.pinColor)
        self.reminderColor = UIColor(theme.reminderColor)
        self.fontName = theme.fontName
        self.fontSize = Double(theme.fontSize)  // Convert from CGFloat to Double for Core Data
        self.lineSpacing = Double(theme.lineSpacing)  // Convert from CGFloat to Double for Core Data
    }
}

