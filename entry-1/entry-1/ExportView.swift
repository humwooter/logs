//
//  ExportView.swift
//  entry-1
//
//  Created by Katya Raman on 8/15/23.
//

import Foundation
import SwiftUI
import CoreData

struct ExportData {
    let viewContext: NSManagedObjectContext

//    var body: some View {
//        Button("Export to JSON") {
//            exportDataToJson()
//        }
//    }
    
    private func exportDataToJson() {
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        
        do {
            let logs = try viewContext.fetch(fetchRequest)
            
            var jsonLogs: [[String: Any]] = []
            for log in logs {
                var jsonLog: [String: Any] = [
                    "day": log.day ?? "",
//                    "id": log.id ?? "",
                    
                    // add other attributes of Log here
                ]
                
                var jsonEntries: [[String: Any]] = []
                if let entries = log.relationship as? Set<Entry> {
                    for entry in entries {
                        let jsonEntry: [String: Any] = [
                            "content": entry.content ?? "",
                            "time": entry.formattedTime() ?? "",
//                            "id" : entry.id ?? "",
                            "isImportant" : entry.isImportant ?? false
                            // add other attributes of Entry here
                        ]
                        jsonEntries.append(jsonEntry)
                    }
                }
                
                jsonLog["entries"] = jsonEntries
                jsonLogs.append(jsonLog)
            }
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonLogs, options: .prettyPrinted) {
                // Write jsonData to a file or handle it as needed.
                // For example, writing to a file in the app's documents directory:
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent("logs.json")
                try jsonData.write(to: fileURL)
                print("JSON data successfully written to \(fileURL)")
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }

}
