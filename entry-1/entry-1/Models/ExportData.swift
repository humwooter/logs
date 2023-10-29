//
//  ExportView.swift
//  entry-1
//
//  Created by Katya Raman on 8/15/23.
//

import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers


struct ExportData {
    let viewContext: NSManagedObjectContext
    
    
//    func presentDocumentPicker(from view: UIViewController, url: URL) {
//        let documentPicker = UIDocumentPickerViewController(url: url, in: .exportToService)
//        documentPicker.delegate = view as? UIDocumentPickerDelegate
//        view.present(documentPicker, animated: true, completion: nil)
//    }
    
    private func presentDocumentPicker(from view: UIViewController, url: URL) {
        let picker = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
        view.present(picker, animated: true, completion: nil)
    }
    
//    private func exportDataToJson() {
//        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
//
//        do {
//            let logs = try viewContext.fetch(fetchRequest)
//
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .prettyPrinted
//            let jsonData = try encoder.encode(logs)
//
//            // Write jsonData to a file or handle it as needed.
//            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let fileURL = documentsDirectory.appendingPathComponent("logs.json")
//            try jsonData.write(to: fileURL)
//            print("JSON data successfully written to \(fileURL)")
//        } catch {
//            print("Error fetching data: \(error)")
//        }
//    }
    public func exportDataToJson(from view: UIViewController) {
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()

        do {
            let logs = try viewContext.fetch(fetchRequest)

            var jsonLogs: [[String: Any]] = []
            for log in logs {
                var jsonLog: [String: Any] = [
                    "day": log.day ?? "",
                    "id": log.id.uuidString ?? "", // Include the id of the Log
                    // add other attributes of Log here
                ]

                var jsonEntries: [[String: Any]] = []
                if let entries = log.relationship as? Set<Entry> {
                    for entry in entries {
                        let jsonEntry: [String: Any] = [
                            "content": entry.content ?? "",
                            "time": entry.time.formatted() ?? "",
                            "id": entry.id.uuidString ?? UUID().uuidString,
                            "color": entry.color.toHexString() ?? "", // Assuming a method to convert UIColor to Hex
                            "image": entry.image ?? "",
                            "imageContent": entry.imageContent ?? ""
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
                presentDocumentPicker(from: view, url: fileURL)
                print("JSON data successfully written to \(fileURL)")
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    
}


struct ExportedLogs: FileDocument {
    var logsData: Data
    
    static var readableContentTypes: [UTType] { [.json] }
    
    init(logsData: Data) {
        self.logsData = logsData
    }
    
    init(configuration: ReadConfiguration) throws {
        self.logsData = Data()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return .init(regularFileWithContents: logsData)
    }
}
