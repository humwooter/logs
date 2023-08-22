////
////  ImportData.swift
////  entry-1
////
////  Created by Katya Raman on 8/21/23.
////
//
//import Foundation
//import SwiftUI
//import CoreData
//import UniformTypeIdentifiers
//
//struct ImportData {
//
//  let viewContext: NSManagedObjectContext
//
//  func importFromJson(_ jsonData: Data) {
//
//    guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
//      print("Invalid JSON data")
//      return
//    }
//
//    guard let logs = json["logs"] as? [[String: Any]] else {
//      print("No logs in JSON")
//      return
//    }
//
//    for log in logs {
//
//      guard let day = log.keys.first,
//            let entries = log[day]!["entries"] as? [[String: Any]] else {
//        continue
//      }
//
//      let newLog = Log(context: viewContext)
//      newLog.day = day
//
//      for entryJson in entries {
//
//        let newEntry = Entry(context: viewContext)
//        newEntry.content = entryJson["content"] as? String
//        newEntry.time = // convert entryJson["time"] to Date
//        newEntry.buttons = entryJson["buttons"] as? [Bool]
//        newEntry.color = // convert entryJson["color"] to UIColor
//        newEntry.image = entryJson["image"] as? String
//
//        newLog.addToEntries(newEntry)
//      }
//    }
//
//    // Save context
//    do {
//      try viewContext.save()
//    } catch {
//      print("Error saving context: \(error)")
//    }
//  }
//
//}
