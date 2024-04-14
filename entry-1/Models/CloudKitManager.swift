//
//  CloudKitManager.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 4/6/24.
//

import Foundation
import CloudKit
import CoreData

class CloudKitManager {
    static let shared = CloudKitManager()
    private init() {}
    
    let privateDatabase = CKContainer.default().privateCloudDatabase
    
    
    func fetchEntries(completion: @escaping ([Entry]?, Error?) -> Void) {
        let query = CKQuery(recordType: "Entry", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        // Optionally, specify a results limit and desired keys if needed
        // operation.resultsLimit = CKQueryOperation.maximumResults
        // operation.desiredKeys = ["id", "content", "time", ...]

        var fetchedRecords: [CKRecord] = []

        operation.recordFetchedBlock = { record in
            fetchedRecords.append(record)
        }

        operation.queryCompletionBlock = { cursor, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                } else {
                    let entries = fetchedRecords.map { self.recordToEntry($0) }
                    completion(entries, nil)
                }
            }
        }

        privateDatabase.add(operation)
    }
    
    // Helper to convert a CKRecord back into an Entry object
    private func recordToEntry(_ record: CKRecord) -> Entry {
        // Assuming you have a method to create a new Entry object
        let entry = Entry() // This should be adapted to your data model creation logic
        // Map record fields back to Entry properties
        return entry
    }
    
    // MARK: - Fetch Documents from CloudKit
    func fetchDocuments(completion: @escaping (Error?) -> Void) {
        let query = CKQuery(recordType: "Document", predicate: NSPredicate(value: true))
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(error)
                    return
                }
                guard let records = records else { completion(NSError(domain: "CloudKitError", code: 0, userInfo: nil)); return }
                
                for record in records {
                    if let asset = record["data"] as? CKAsset, let fileURL = asset.fileURL {
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let destinationURL = documentsDirectory.appendingPathComponent(record["name"] as? String ?? UUID().uuidString)
                        do {
                            if FileManager.default.fileExists(atPath: destinationURL.path) {
                                try FileManager.default.removeItem(at: destinationURL)
                            }
                            try FileManager.default.copyItem(at: fileURL, to: destinationURL)
                        } catch {
                            print("Error copying document from CloudKit: \(error)")
                        }
                    }
                }
                completion(nil)
            }
        }
    }
    
    func handleRestore() {
        // Show options: Restore Entries, Restore Documents, Restore Everything
        // Based on user selection, call the appropriate method
        
        // Example: Restore Entries
        CloudKitManager.shared.fetchEntries { (entries, error) in
            guard let entries = entries else {
                // Handle error
                return
            }
            // Process and save entries to CoreData or your local storage solution
        }
        
        // Example: Restore Documents
        CloudKitManager.shared.fetchDocuments { error in
            // Handle completion
        }
    }
    
    // MARK: - Sync Specific Entries
    func syncSpecificEntries(entries: [Entry]) {
        for entry in entries where entry.shouldSyncWithCloudKit {
            let record = entryToRecord(entry: entry)
            privateDatabase.save(record) { (savedRecord, error) in
                // Handle save result
            }
        }
    }
    
    // MARK: - Sync All Data
    func syncAllData(entries: [Entry], documentsDirectoryURL: URL) {
        // Sync Entries
        syncSpecificEntries(entries: entries)
        
        // Sync Documents Directory
        syncDocumentsDirectory(documentsDirectoryURL: documentsDirectoryURL)
    }

    // MARK: - Sync Documents Directory
    func syncDocumentsDirectory(documentsDirectoryURL: URL) {
        let fileManager = FileManager.default
        do {
            let documentURLs = try fileManager.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: nil)
            for documentURL in documentURLs {
                let documentData = try Data(contentsOf: documentURL)
                let asset = CKAsset(fileURL: documentURL)
                let record = CKRecord(recordType: "Document")
                record["data"] = asset
                // Set other fields as necessary, e.g., a document identifier or name
                record["name"] = documentURL.lastPathComponent

                privateDatabase.save(record) { (savedRecord, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Failed to save document to CloudKit: \(error)")
                            return
                        }
                        print("Document successfully saved to CloudKit")
                    }
                }
            }
        } catch {
            print("Error syncing documents directory: \(error)")
        }
    }

    
    // Helper to convert an Entry to a CloudKit record
    private func entryToRecord(entry: Entry) -> CKRecord {
        let record = CKRecord(recordType: "Entry")
        // Set record fields based on entry properties
        return record
    }
}
