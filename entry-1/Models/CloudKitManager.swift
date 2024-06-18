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
                    CoreDataManager.shared.saveFetchedEntries(entries)
                    completion(entries, nil)
                }
            }
        }

        privateDatabase.add(operation)
    }



    
    // Helper to convert a CKRecord back into an Entry object
    private func recordToEntry(_ record: CKRecord) -> Entry {
        let context = CoreDataManager.shared.viewContext
        let entry = Entry(context: context)
        entry.id = UUID(uuidString: record.recordID.recordName) ?? UUID()
        entry.content = record["content"] as? String ?? ""
        entry.time = record["time"] as? Date ?? Date()
        entry.lastUpdated = record["lastUpdated"] as? Date
        entry.stampIcon = record["stampIcon"] as? String ?? ""
        entry.name = record["name"] as? String
        entry.reminderId = record["reminderId"] as? String
        entry.mediaFilename = record["mediaFilename"] as? String
        entry.mediaFilenames = record["mediaFilenames"] as? [String]
        entry.entryReplyId = record["entryReplyId"] as? String
        entry.isHidden = record["isHidden"] as? Bool ?? false
        entry.isShown = record["isShown"] as? Bool ?? true
        entry.isPinned = record["isPinned"] as? Bool ?? false
        entry.isRemoved = record["isRemoved"] as? Bool ?? false
        entry.isDrafted = record["isDrafted"] as? Bool ?? false
        entry.shouldSyncWithCloudKit = record["shouldSyncWithCloudKit"] as? Bool ?? true
        entry.stampIndex = record["stampIndex"] as? Int16 ?? 0
        entry.pageNum_pdf = record["pageNum_pdf"] as? Int16 ?? 0
        
        return entry
    }
    
    // Helper to convert an Entry to a CloudKit record
    private func entryToRecord(entry: Entry) -> CKRecord {
        let recordID = CKRecord.ID(recordName: entry.id.uuidString)
        let record = CKRecord(recordType: "Entry", recordID: recordID)
        record["content"] = entry.content as CKRecordValue
        record["time"] = entry.time as CKRecordValue
        record["lastUpdated"] = entry.lastUpdated as CKRecordValue?
        record["stampIcon"] = entry.stampIcon as CKRecordValue
        record["name"] = entry.name as CKRecordValue?
        record["reminderId"] = entry.reminderId as CKRecordValue?
        record["mediaFilename"] = entry.mediaFilename as CKRecordValue?
        record["mediaFilenames"] = entry.mediaFilenames as CKRecordValue?
        record["entryReplyId"] = entry.entryReplyId as CKRecordValue?
        record["isHidden"] = entry.isHidden as CKRecordValue
        record["isShown"] = entry.isShown as CKRecordValue
        record["isPinned"] = entry.isPinned as CKRecordValue
        record["isRemoved"] = entry.isRemoved as CKRecordValue
        record["isDrafted"] = entry.isDrafted as CKRecordValue
        record["shouldSyncWithCloudKit"] = entry.shouldSyncWithCloudKit as CKRecordValue
        record["stampIndex"] = entry.stampIndex as CKRecordValue
        record["pageNum_pdf"] = entry.pageNum_pdf as CKRecordValue
        
        return record
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
                DispatchQueue.main.async {
                    if let error = error {
                        print("Failed to save entry to CloudKit: \(error)")
                    } else if let savedRecord = savedRecord {
                        CoreDataManager.shared.updateEntry(entry: entry, with: savedRecord)
                    }
                }
            }
        }
    }

    
    // MARK: - Sync All Data
    func syncAllData(entries: [Entry], documentsDirectoryURL: URL) {
        syncSpecificEntries(entries: entries)
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
    

}
