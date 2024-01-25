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



func makeAttributedString(from string: String) -> AttributedString {
    guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
        return AttributedString(string)
    }
    
    let attributedString = NSMutableAttributedString(string: string)
    let matches = detector.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))

    for match in matches {
        guard let range = Range(match.range, in: string) else { continue }
        let nsRange = NSRange(range, in: string)
        attributedString.addAttribute(.link, value: match.url!, range: nsRange)
    }

    return AttributedString(attributedString)
}
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




