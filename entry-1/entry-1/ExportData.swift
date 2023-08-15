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
    
    public func exportDataToJson(from view: UIViewController) {
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()

        do {
            let logs = try viewContext.fetch(fetchRequest)

            var jsonLogs: [[String: Any]] = []
            for log in logs {
                let day = log.day ?? ""
                var jsonLogEntries: [[String: Any]] = []

                if let entries = log.relationship as? Set<Entry> {
                    for entry in entries {
                        let jsonEntry: [String: Any] = [
                            "content": entry.content ?? "",
                            "time": entry.formattedTime() ?? "",
                            "isImportant": entry.isImportant ?? false
                            // add other attributes of Entry here
                        ]
                        jsonLogEntries.append(jsonEntry)
                    }
                }

                let jsonLog: [String: Any] = ["Log from \(day)": ["entries": jsonLogEntries]]
                jsonLogs.append(jsonLog)
            }

            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonLogs, options: .prettyPrinted) {
                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("logs.json")
                try jsonData.write(to: fileURL)
                presentDocumentPicker(from: view, url: fileURL)
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }


    private func presentDocumentPicker(from view: UIViewController, url: URL) {
         let picker = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
         view.present(picker, animated: true, completion: nil)
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
