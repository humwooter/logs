//
//  Documents.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/17/23.
//

import Foundation
import SwiftUI
import CoreData
import UIKit
import LocalAuthentication
import UniformTypeIdentifiers

struct DocumentPickerView: UIViewControllerRepresentable {
    var url: URL
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [url])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPickerView
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


struct EntryDocument: FileDocument {
    var entries: [Entry]
    
    static var readableContentTypes: [UTType] { [.json] }
    
    init(entries: [Entry]) {
        self.entries = entries
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let entries = try? JSONDecoder().decode([Entry].self, from: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.entries = entries
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(entries)
        return .init(regularFileWithContents: data)
    }
}

struct LogDocument: FileDocument {
    var logs: [Log]
    
    static var readableContentTypes: [UTType] { [.json] }
    
    init(logs: [Log]) {
        self.logs = logs
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let logs = try? JSONDecoder().decode([Log].self, from: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.logs = logs
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(logs)
        return .init(regularFileWithContents: data)
    }
}
