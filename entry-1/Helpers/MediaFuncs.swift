//
//  MediaFuncs.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/27/23.
//

import Foundation
import CoreData
import SwiftUI
import PDFKit
import AVFoundation
import AVKit


func clearTempDirectory() {
    let fileManager = FileManager.default
    let tempDirectory = fileManager.temporaryDirectory

    do {
        let contents = try fileManager.contentsOfDirectory(atPath: tempDirectory.path)
        for item in contents {
            let itemPath = tempDirectory.appendingPathComponent(item)
            try fileManager.removeItem(at: itemPath)
            print("Deleted \(itemPath)")
        }
        print("Temporary directory cleared.")
    } catch {
        print("Failed to clear temporary directory: \(error.localizedDescription)")
    }
}

func printContentsOfTmpDirectory() {
    let fileManager = FileManager.default
    let tempDirectory = fileManager.temporaryDirectory

    do {
        let contents = try fileManager.contentsOfDirectory(atPath: tempDirectory.path)
        
        if contents.isEmpty {
            print("The tmp directory is empty.")
        } else {
            print("Contents of tmp directory:")
            for item in contents {
                let itemPath = tempDirectory.appendingPathComponent(item).path
                print(itemPath)
            }
        }
    } catch {
        print("Failed to list contents of tmp directory: \(error.localizedDescription)")
    }
}


func getUrl(for filename: String) -> URL? {
    let fileManager = FileManager.default
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
    return documentsDirectory.appendingPathComponent(filename)
}

func isVideo(data: Data) -> Bool {
    // Write data to a temporary file
    let temporaryFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".tmp")
    do {
        try data.write(to: temporaryFileURL)
        
        // Create an asset from this temporary file
        let asset = AVAsset(url: temporaryFileURL)
        let videoTracks = asset.tracks(withMediaType: .video)
        
        // Clean up: remove the temporary file
        try FileManager.default.removeItem(at: temporaryFileURL)
        
        // Return true if there are video tracks
        return !videoTracks.isEmpty
    } catch {
        print("Failed to write to or delete temporary file, or failed to read video tracks: \(error)")
        return false
    }
}
func isGIF(data: Data) -> Bool {
    return data.prefix(6) == Data([0x47, 0x49, 0x46, 0x38, 0x37, 0x61]) || data.prefix(6) == Data([0x47, 0x49, 0x46, 0x38, 0x39, 0x61])
}

func isPDF(data: Data) -> Bool {
    guard let signature = String(data: data.prefix(5), encoding: .ascii) else { return false }
    return signature == "%PDF-"
}

func drawPDFfromURL(url: URL) -> UIImage? {
    guard let document = CGPDFDocument(url as CFURL) else { return nil }
    guard let page = document.page(at: 1) else { return nil }

    let pageRect = page.getBoxRect(.mediaBox)
    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
    let img = renderer.image { ctx in
        UIColor.white.set()
        ctx.fill(pageRect)

        ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

        ctx.cgContext.drawPDFPage(page)
    }

    return img
}

//func isPDF(data: Data) -> Bool {
//    return data.prefix(5) == Data([0x25, 0x50, 0x44, 0x46, 0x2d]) // Prefix for %PDF-
//} //same thing as implementation above

func isHeic(data: Data) -> Bool {
    return data.prefix(4) == Data([0x89, 0x48, 0x45, 0x49]) // Prefix for HEIC
}

public func mediaExists(at url: URL) -> Bool {
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


func savePDFDataToFile(data: Data, filename: String) -> URL? {
    guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
    let fileURL = directory.appendingPathComponent(filename)
    
    do {
        try data.write(to: fileURL)
        return fileURL
    } catch {
        print("Error saving PDF file: \(error)")
        return nil
    }
}


func getMediaData(fromFilename filename: String) -> Data? {
    if filename.isEmpty {
        return nil
    }
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsDirectory.appendingPathComponent(filename)
    
    if mediaExists(at: fileURL) {
        
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

func getMediaData(fromURL fileURL: URL) -> Data? {

    if mediaExists(at: fileURL) {
        
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

func generatePNGFromPDF(url: URL) -> Data? {
    guard let pdfDocument = PDFDocument(url: url), let page = pdfDocument.page(at: 0) else { return nil }
    let pageRect = page.bounds(for: .mediaBox)
    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
    let img = renderer.image { ctx in
        // Flip the context to correct for the PDF's coordinate system
        ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
        
        UIColor.white.set()
        ctx.fill(pageRect)
        page.draw(with: .mediaBox, to: ctx.cgContext)
    }
    return img.pngData()
}

func deleteImage(with mediaFilename: String?, coreDataManager: CoreDataManager) {
    print("in delete image")
    let mainContext = coreDataManager.viewContext
    
    guard let filename = mediaFilename, !filename.isEmpty else {
        print("Filename is empty or nil, no image to delete.")
        return
    }
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsDirectory.appendingPathComponent(filename)
    
    if FileManager.default.fileExists(atPath: fileURL.path) {
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Image at \(fileURL) has been deleted")
        } catch {
            print("Error deleting image file: \(error)")
        }
    } else {
        print("File does not exist at path: \(fileURL.path)")
    }
}

func generateComplementaryColors(baseColor: Color) -> [Color] {
    // Convert SwiftUI Color to HSB color space
    let uiColor = UIColor(baseColor)
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightness: CGFloat = 0
    var alpha: CGFloat = 0
    
    uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    
    // Generate five new colors
    var colors: [Color] = []
    for i in 1...5 {
        // Calculate new hue, shifted by 1/6th of the color wheel
        let newHue = (hue + CGFloat(i) * 0.2).truncatingRemainder(dividingBy: 1.0)
        let newColor = UIColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
        colors.append(Color(newColor))
    }
    
    return colors
}
