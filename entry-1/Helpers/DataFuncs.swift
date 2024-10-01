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
import PDFKit
import SQLite3


func printSQLiteContents(forPath path: String) {
    var db: OpaquePointer? = nil
    if sqlite3_open(path, &db) == SQLITE_OK {
        print("Successfully opened connection to database at \(path)")
        
        var queryStatement: OpaquePointer? = nil
        let query = "SELECT name FROM sqlite_master WHERE type='table';"
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                if let cString = sqlite3_column_text(queryStatement, 0) {
                    let tableName = String(cString: cString)
                    print("Table: \(tableName)")
                    printTableContents(db: db, tableName: tableName)
                }
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        
        sqlite3_finalize(queryStatement)
    } else {
        print("Unable to open database.")
    }
    
    sqlite3_close(db)
}

func printTableContents(db: OpaquePointer?, tableName: String) {
    var queryStatement: OpaquePointer? = nil
    let query = "SELECT * FROM \(tableName);"
    
    if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
        let columnCount = sqlite3_column_count(queryStatement)
        
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            var rowContents = [String]()
            for i in 0..<columnCount {
                if let columnText = sqlite3_column_text(queryStatement, i) {
                    let columnValue = String(cString: columnText)
                    rowContents.append(columnValue)
                } else {
                    rowContents.append("NULL")
                }
            }
            print(rowContents.joined(separator: " | "))
        }
    } else {
        print("SELECT statement could not be prepared for table \(tableName).")
    }
    
    sqlite3_finalize(queryStatement)
}

//
//func printSQLiteContents(forPath path: String) {
//    var db: OpaquePointer?
//    
//    // Open the database
//    if sqlite3_open(path, &db) != SQLITE_OK {
//        print("Error opening database")
//        return
//    }
//    
//    defer {
//        sqlite3_close(db)
//    }
//    
//    // Get all table names
//    let tableQuery = "SELECT name FROM sqlite_master WHERE type='table';"
//    var statement: OpaquePointer?
//    
//    if sqlite3_prepare_v2(db, tableQuery, -1, &statement, nil) != SQLITE_OK {
//        print("Error preparing table query")
//        return
//    }
//    
//    defer {
//        sqlite3_finalize(statement)
//    }
//    
//    while sqlite3_step(statement) == SQLITE_ROW {
//        guard let tableName = sqlite3_column_text(statement, 0) else { continue }
//        let table = String(cString: tableName)
//        
//        print("\n--- Table: \(table) ---")
//        
//        // Get all rows for the current table
//        let rowQuery = "SELECT * FROM \(table);"
//        var rowStatement: OpaquePointer?
//        
//        if sqlite3_prepare_v2(db, rowQuery, -1, &rowStatement, nil) != SQLITE_OK {
//            print("Error preparing row query for table \(table)")
//            continue
//        }
//        
//        defer {
//            sqlite3_finalize(rowStatement)
//        }
//        
//        // Print column names
//        let columnCount = sqlite3_column_count(rowStatement)
//        var columnNames: [String] = []
//        
//        for i in 0..<columnCount {
//            if let columnName = sqlite3_column_name(rowStatement, i) {
//                let name = String(cString: columnName)
//                columnNames.append(name)
//                print("\(name)", terminator: "\t")
//            }
//        }
//        print()
//        
//        // Print rows
//        while sqlite3_step(rowStatement) == SQLITE_ROW {
//            for i in 0..<columnCount {
//                if let value = sqlite3_column_text(rowStatement, i) {
//                    let strValue = String(cString: value)
//                    print("\(strValue)", terminator: "\t")
//                } else {
//                    print("NULL", terminator: "\t")
//                }
//            }
//            print()
//        }
//    }
//}

func pngDataFromFirstPageOfPDF(at fileURL: URL) -> Data? {
    guard let pdfDocument = PDFDocument(url: fileURL),
          let page = pdfDocument.page(at: 0) else {
        return nil
    }
    
    let pageRect = page.bounds(for: .mediaBox)
    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
    let img = renderer.image { ctx in
        UIColor.white.set()
        ctx.fill(pageRect)
        ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
        
        page.draw(with: .mediaBox, to: ctx.cgContext)
    }
    
    return img.pngData()
}

func calculateDirectorySize(url: URL) -> Double {
    let fileManager = FileManager.default
    let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: .skipsHiddenFiles)
    var totalSize: Int = 0
    
    for case let fileURL as URL in enumerator! {
        if let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize {
            totalSize += fileSize
        }
    }
    return Double(totalSize) / 1_000_000 // Convert bytes to megabytes
}

func calculateSizeForExtensions(url: URL, extensions: [String]) -> Double {
    let fileManager = FileManager.default
    let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: .skipsHiddenFiles)
    var totalSize: Int = 0
    
    for case let fileURL as URL in enumerator! {
        if extensions.contains(fileURL.pathExtension.lowercased()) {
            if let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize {
                totalSize += fileSize
            }
        }
    }
    return Double(totalSize) / 1_000_000 // Convert bytes to megabytes
}

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

func extractFirstURL(from string: String) -> String? {
    guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
        return nil
    }

    let matches = detector.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
    for match in matches {
        if let url = match.url {
            return url.absoluteString
        }
    }
    return nil
}

