//
//  GlobalFuncs.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 9/25/23.
//

import Foundation

func formattedTime(time: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: time)
}

public func imageExists(at url: URL) -> Bool {
    return FileManager.default.fileExists(atPath: url.path)
}

func isGIF(data: Data) -> Bool {
    return data.prefix(6) == Data([0x47, 0x49, 0x46, 0x38, 0x37, 0x61]) || data.prefix(6) == Data([0x47, 0x49, 0x46, 0x38, 0x39, 0x61])
}

func formattedDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.string(from: date)
}


func checkDiskSpace() {
    do {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        if let capacity = values.volumeAvailableCapacityForImportantUsage {
            print("Available disk space: \(capacity) bytes")
        }
    } catch {
        print("Error retrieving disk capacity: \(error)")
    }
}

func currentDate() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter.string(from: Date())
}
