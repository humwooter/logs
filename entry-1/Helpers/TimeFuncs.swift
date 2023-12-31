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



func formattedDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.string(from: date)
}

func currentDate() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter.string(from: Date())
}
