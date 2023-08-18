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
    
    private func presentDocumentPicker(from view: UIViewController, url: URL) {
        let picker = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
        view.present(picker, animated: true, completion: nil)
    }


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
                            "time": entry.time.formatted() ?? "",
                            "buttons": entry.buttons,
//                            "id": entry.id.uuidString ?? UUID().uuidString,
                            "color": entry.color.toHexString() ?? "", // Assuming a method to convert UIColor to Hex
                            "image": entry.image ?? ""
                        ]
                        jsonLogEntries.append(jsonEntry)
                    }
                }

                let jsonLog: [String: Any] = ["Log from \(day)": ["entries": jsonLogEntries]]
                jsonLogs.append(jsonLog)
            }

//            // Include UserDefaults
//            let userDefaults = UserDefaults.standard
//            let defaults: [String: Any] = [
//                "activatedButtons": userDefaults.array(forKey: "activatedButtons") as? [Bool] ?? [],
//                "selectedImages": userDefaults.array(forKey: "selectedImages") as? [String] ?? [],
//                "selectedColors": userDefaults.loadColors(forKey: "selectedColors") ?? "", // Assuming a method to load colors
//                "accentColor": userDefaults.color(forKey: "accentColor") ?? "", // Assuming a method to load color
////                "showLockScreen": userDefaults.bool(forKey: "showLockScreen") ?? "",
////                "isUnlocked": userDefaults.bool(forKey: "isUnlocked") ?? "",
////                "fontSize": userDefaults.float(forKey: "fontSize") ?? "",
////                "fontName": userDefaults.string(forKey: "fontName") ?? ""
//            ]
//            let jsonData = ["logs": jsonLogs, "userPreferences": defaults] as [String : Any]
            let jsonData = ["logs": jsonLogs] as [String : Any]
//            let jsonData = ["userPreferences": defaults] as [String : Any]
//            jsonLogs.append(jsonData)


            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted) {
                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("logs.json")
                try jsonData.write(to: fileURL)
                presentDocumentPicker(from: view, url: fileURL)
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
