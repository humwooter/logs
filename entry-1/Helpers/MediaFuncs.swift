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
    if FileManager.default.fileExists(atPath: url.path) {
        print("IMAGE EXISTS!")
    }
    return FileManager.default.fileExists(atPath: url.path)
    }

public func imageExists(at filename: String) -> Bool {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let url = documentsDirectory.appendingPathComponent(filename)
    
    if FileManager.default.fileExists(atPath: url.path) {
        print("IMAGE EXISTS!")
    }
    return FileManager.default.fileExists(atPath: url.path)
    }

func saveMedia(data: Data) -> String? {
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
        return uniqueFilename
    } catch {
        print("Failed to write: \(error)")
        return nil
    }
}


func getMediaData(fromFilename filename: String) -> Data? {
    if filename.isEmpty {
        return nil
    }
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsDirectory.appendingPathComponent(filename)
    
    if imageExists(at: fileURL) {
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                return data
            } catch {
                print("Error reading image file: \(error)")
                return nil
            }
        } else {
            print("File does not exist at path: \(fileURL.path)")
            return nil
        }
    }
    else {
        return nil
    }
}
