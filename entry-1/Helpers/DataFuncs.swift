//
//  DataFuncs.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 12/26/23.
//

import Foundation
import SwiftUI
import CoreData
import UIKit
import LocalAuthentication
import UniformTypeIdentifiers




//    private func importData(from url: URL) async throws {
//        print("entered import data")
//
//        guard url.startAccessingSecurityScopedResource() else {
//            throw NSError(domain: "Security", code: 1, userInfo: nil)
//        }
//        defer { url.stopAccessingSecurityScopedResource() }
//
//        let jsonData = try Data(contentsOf: url)
//
//        do {
//            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
//
//                coreDataManager.backgroundContext.performAndWait {
//                    do {
//                        print("jsonArray: \(jsonArray)")
//                        for jsonObject in jsonArray {
//                            print("jsonObject: \(jsonObject)")
//                            if let logIdString = jsonObject["id"] as? String, let logId = UUID(uuidString: logIdString) {
//                                print("ID: \(logId)")
//
//                                let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
//                                fetchRequest.predicate = NSPredicate(format: "id == %@", logId as CVarArg)
//
//                                let existingLogs = try coreDataManager.viewContext.fetch(fetchRequest)
//
//                                if existingLogs.first != nil {
//                                    print("LOG WITH ID: \(logId) ALREADY EXISTS")
//                                } else {
//                                    if let logData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) {
//                                        let decoder = JSONDecoder()
//                                        decoder.userInfo[CodingUserInfoKey.managedObjectContext] = coreDataManager.viewContext
//                                        let log = try decoder.decode(Log.self, from: logData)
//                                        coreDataManager.viewContext.insert(log)
//                                    }
//                                }
//                            }
//                        }
//                        try coreDataManager.backgroundContext.save()
//
//                    } catch {
//                        print("Failed to import data: \(error)")
//                    }
//                }
//            }
//        } catch {
//            print("Failed to parse JSON: \(error)")
//        }
//
//    }



func importData(from url: URL, coreDataManager: CoreDataManager) async throws {
    print("entered import data")
    
    guard url.startAccessingSecurityScopedResource() else {
        throw NSError(domain: "Security", code: 1, userInfo: nil)
    }
    defer { url.stopAccessingSecurityScopedResource() }
    
    let jsonData = try Data(contentsOf: url)
    
    do {
        if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
            
            coreDataManager.backgroundContext.performAndWait {
                do {
                    for jsonObject in jsonArray {
                        if let logIdString = jsonObject["id"] as? String, let logId = UUID(uuidString: logIdString) {
                            print("ID: \(logId)")
                            
                            let logFetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
                            logFetchRequest.predicate = NSPredicate(format: "id == %@", logId as CVarArg)
                            
                            if let existingLog = try coreDataManager.viewContext.fetch(logFetchRequest).first {
                                print("LOG WITH ID: \(logId) ALREADY EXISTS, CHECKING ENTRIES")
                                
                                // Extract entries from jsonObject and compare with existing entries
                                if let newEntries = jsonObject["relationship"] as? [[String: Any]] {
                                    for newEntryData in newEntries {
                                        print("newEntryData: \(newEntryData)")
                                        if let newEntryIdString = newEntryData["id"] as? String, let newEntryId = UUID(uuidString: newEntryIdString) {
                                            let entryFetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
                                            entryFetchRequest.predicate = NSPredicate(format: "id == %@", newEntryId as CVarArg, existingLog)
                                            
                                            let existingEntries = try coreDataManager.viewContext.fetch(entryFetchRequest)
                                            
                                            if existingEntries.isEmpty {
                                                // This is a new entry, add it to the log
                                                print("ENTRY DOESNT EXIST")
                                                if let entryData = try? JSONSerialization.data(withJSONObject: newEntryData, options: []) {
                                                    let decoder = JSONDecoder()
                                                    decoder.userInfo[CodingUserInfoKey.managedObjectContext] = coreDataManager.viewContext
                                                    if let newEntry = try? decoder.decode(Entry.self, from: entryData) {
                                                        
                                                        coreDataManager.viewContext.insert(newEntry)

                                                        print("new entry created")
                                                        existingLog.addToRelationship(newEntry)
                                                        
                                                        print("new entry added to log")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                // Log does not exist, import it as new
                                if let logData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) {
                                    let decoder = JSONDecoder()
                                    decoder.userInfo[CodingUserInfoKey.managedObjectContext] = coreDataManager.viewContext
                                    let log = try decoder.decode(Log.self, from: logData)
                                    coreDataManager.viewContext.insert(log)
                                }
                            }
                        }
                    }
                    try coreDataManager.backgroundContext.save()
                } catch {
                    print("Failed to import data: \(error)")
                }
            }
        }
    } catch {
        print("Failed to parse JSON: \(error)")
    }
}
