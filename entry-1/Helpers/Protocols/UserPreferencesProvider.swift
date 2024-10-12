//
//  UserPreferencesProvider.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/6/24.
//

import SwiftUI
import UIKit
import Foundation

protocol UserPreferencesProvider {
    var userPreferences: UserPreferences { get }
    var colorScheme: ColorScheme { get }
}



extension UserPreferencesProvider {
    
    // Shortens a name to a 15-character prefix and adds "..."
    func getName(for name: String) -> String {
        return name.prefix(25) + "..."
    }
    
    // Formats hour in short with AM/PM
    func formatHour(hour: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h a" // 12-hour format with AM/PM

        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current // Ensure correct timezone

        let components = DateComponents(hour: hour)
        
        if let date = calendar.date(from: components) {
            return dateFormatter.string(from: date)
        }
        
        return "\(hour):00"
    }
    
    // Converts date string to Date object
    func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: dateString)
    }
    
    // Checks if the date string has a valid format
    func isValidDateFormat(_ dateString: String) -> Bool {
        return dateFromString(dateString) != nil
    }
    
    // Formats a date string into a medium style date
    func formattedDateString(_ dateString: String) -> String {
        if let date = dateFromString(dateString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        } else {
            return dateString
        }
    }
    
    // Gets the section color based on user preferences and color scheme
    func getSectionColor(colorScheme: ColorScheme) -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        } else {
            return userPreferences.entryBackgroundColor
        }
    }
    
    // Gets text color based on user preferences
    func getTextColor() -> Color {
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        let entryBackground = userPreferences.entryBackgroundColor
        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme // Assuming this is available in UserPreferences
        )
    }
    
    // Gets ideal header text color
    func getIdealHeaderTextColor() -> Color {
        let background1 = UIColor(userPreferences.backgroundColors.first ?? Color.clear)
        let background2 = UIColor(userPreferences.backgroundColors[1])
        let averageColor = UIColor.averageColor(of: background1, and: background2)
        return Color(UIColor.fontColor(forBackgroundColor: averageColor, colorScheme: self.colorScheme))
    }
    
    // Gets entry background color based on user preferences
    func getEntryBackgroundColor() -> Color {
        let entryBackgroundColor = userPreferences.entryBackgroundColor
        if isClear(for: UIColor(entryBackgroundColor)) {
            return getDefaultEntryBackgroundColor(colorScheme: self.colorScheme)
        } else {
            return entryBackgroundColor
        }
    }
    
    // Checks if a color is fully transparent
    private func isClear(for color: UIColor) -> Bool {
        return color.cgColor.alpha == 0
    }
}
