//
//  UserTheme+CoreDataClass.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/17/24.
//

import CoreData
import SwiftUI

@objc(UserTheme)
public class UserTheme: NSManagedObject {
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

