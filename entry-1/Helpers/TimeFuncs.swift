//
//  TimeFuncs.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/27/23.
//


import Foundation
import CoreData
import SwiftUI



func formattedTime(time: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: time)
}

func formattedTime_long(date: Date) -> String {
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
