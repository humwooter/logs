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

