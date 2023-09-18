
import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers







struct ImportData {
    let viewContext: NSManagedObjectContext
    

//    func presentDocumentPicker(from view: UIViewController, url: URL) {
//        let documentPicker = UIDocumentPickerViewController(url: url, in: .exportToService)
//        documentPicker.delegate = view as? UIDocumentPickerDelegate
//        view.present(documentPicker, animated: true, completion: nil)
//    }
//
    func importDataFromJson(from view: UIViewController) {
        let documentTypes = [UTType.json.identifier]
        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
        documentPicker.delegate = view as? UIDocumentPickerDelegate
        view.present(documentPicker, animated: true, completion: nil)
    }

    func presentDocumentPicker(from view: UIViewController) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [UTType.json.identifier], in: .import)
        documentPicker.delegate = view as? UIDocumentPickerDelegate
        view.present(documentPicker, animated: true, completion: nil)
    }

    
    func importFromJson(_ jsonData: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] else {
            print("Invalid JSON data")
            return
        }
        
        print("JSON data received: \(json)")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy, h:mm a" // Adjust this format to match the format of your date strings

        for log in json {
            print("Processing log: \(log)")
            let newLog = Log(context: viewContext)
            newLog.day = log["day"] as? String ?? ""

            if let entries = log["entries"] as? [[String: Any]] {
                for entryJson in entries {
                    print("Processing entry: \(entryJson)")
                    let newEntry = Entry(context: viewContext)
                    newEntry.content = (entryJson["content"] as? String ?? "nothing")

                    if let timeString = entryJson["time"] as? String {
                        newEntry.time = dateFormatter.date(from: timeString)!
                    }

                    if let colorString = entryJson["color"] as? String {
                        newEntry.color = UIColor(hex: colorString) // Assuming a method to convert Hex to UIColor
                    }

                    newEntry.id = UUID(uuidString: entryJson["id"] as? String ?? "") ?? UUID()
                    newEntry.buttons = entryJson["buttons"] as? [Bool] ?? [false, false, false, false, false]
                    newEntry.image = entryJson["image"] as? String ?? ""
                    newEntry.imageContent = entryJson["imageContent"] as? String ?? ""

                    // Handle other fields...

                    newLog.addToRelationship(newEntry)
                }
            }
        }
        // Save context
        do {
            try viewContext.save()
            print("Context saved successfully.")
        } catch {
            print("Error saving context: \(error)")
        }
    }


    
    
//    func importFromJson(_ jsonData: Data) {
//        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] else {
//            print("Invalid JSON data")
//            return
//        }
//
//        for log in json {
//            let newLog = Log(context: viewContext)
//            newLog.day = log["day"] as? String ?? ""
//            newLog.id = UUID(uuidString: log["id"] as? String ?? "") ?? UUID()
//
//            if let entries = log["entries"] as? [[String: Any]] {
//                for entryJson in entries {
//                    let newEntry = Entry(context: viewContext)
//                    newEntry.content = entryJson["content"] as? String ?? ""
//                    newEntry.time = entryJson["time"] as? Date ?? Date()
//                    newEntry.id = UUID(uuidString: entryJson["id"] as? String ?? "") ?? UUID()
//                    newEntry.buttons = entryJson["buttons"] as? [Bool] ?? [false, false, false, false, false]
//                    newEntry.color = UIColor(named: entryJson["color"] as? String ?? "white") ?? UIColor(.cyan)
//                    newEntry.image = entryJson["image"] as? String ?? ""
//                    newEntry.imageContent = entryJson["imageContent"] as? String
//                    // Add other attributes of Entry here
//
//                    newLog.addToRelationship(newEntry)
//                }
//            }
//        }
//
//        // Save context
//        do {
//            try viewContext.save()
//        } catch {
//            print("Error saving context: \(error)")
//        }
//    }
    
}



