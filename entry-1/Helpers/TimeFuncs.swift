//
//  TimeFuncs.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/27/23.
//


import Foundation
import CoreData
import SwiftUI



func dateFromString(_ dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"  // Set date format
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")  // Use POSIX to ensure consistent parsing
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter.date(from: dateString)
}


func dateComponents(from dateString: String) -> DateComponents? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    let calendar = Calendar.current

    if let date = dateFormatter.date(from: dateString) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return components
    } else {
        // Return nil if the dateString does not convert to a valid Date
        return nil
    }
}

func formattedDateString(from components: DateComponents) -> String? {
    let calendar = Calendar.current
    if let date = calendar.date(from: components) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: date)
    } else {
        return nil  // Return nil if the DateComponents don't form a valid date
    }
}

func formattedTimeShort(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm"
    return formatter.string(from: date)
}

func formattedTime(time: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: time)
}

func formattedTimeLong(date: Date) -> String {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let startOfDay = calendar.startOfDay(for: date)

    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .short

    if today == startOfDay {
        return "\(dateFormatter.string(from: date))"
    } else {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E" // "Mon", "Tue", etc.
        return "\(dayFormatter.string(from: date)) - \(dateFormatter.string(from: date))"
    }
}

func formattedDateShort(from date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d" // "Oct 19" format
    return dateFormatter.string(from: date)
}


func formattedDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.string(from: date)
}

func formattedDateLong(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM d, yyyy"
    return dateFormatter.string(from: date)
}

func formattedDateFull(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
    return dateFormatter.string(from: date)
}


func currentDate() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter.string(from: Date())
}
