//
//  MediaFuncs.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/27/23.
//

import Foundation
import CoreData
import SwiftUI


func isGIF(data: Data) -> Bool {
    return data.prefix(6) == Data([0x47, 0x49, 0x46, 0x38, 0x37, 0x61]) || data.prefix(6) == Data([0x47, 0x49, 0x46, 0x38, 0x39, 0x61])
}


func isHeic(data: Data) -> Bool {
    return data.prefix(4) == Data([0x89, 0x48, 0x45, 0x49]) // Prefix for HEIC
}

public func imageExists(at url: URL) -> Bool {
    return FileManager.default.fileExists(atPath: url.path)
    }

func saveMedia(data: Data, viewContext: NSManagedObjectContext) -> String? {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var uniqueFilename: String

    // Determine file type
    if isGIF(data: data) {
        uniqueFilename = UUID().uuidString + ".gif"
    } else if isHeic(data: data) {
        uniqueFilename = UUID().uuidString + ".heic"
    } else {
        uniqueFilename = UUID().uuidString + ".png"
    }

    let fileURL = documentsDirectory.appendingPathComponent(uniqueFilename)
    
    do {
        try data.write(to: fileURL)
        let newEntry = Entry(context: viewContext)
        newEntry.imageContent = uniqueFilename
        print(": \(uniqueFilename)")
        return uniqueFilename
    } catch {
        print("Failed to write: \(error)")
        return nil
    }
}
