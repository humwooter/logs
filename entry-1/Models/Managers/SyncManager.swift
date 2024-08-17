//
//  SyncManager.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/1/24.
//
//import Foundation
//import Combine
//import UIKit
//
//
//class SyncManager: ObservableObject {
//    static let shared = SyncManager()
//    @Published var userPreferences = UserPreferences()
//    
//    private init() {}
//    
//    func performSync() {
//        switch userPreferences.syncPreference {
//        case .none:
//            break
//        case .documents:
//            CloudKitManager.shared.fetchDocuments { error in
//                if let error = error {
//                    print("Error fetching documents: \(error)")
//                }
//            }
//        case .allEntries:
//            let entries = CoreDataManager.shared.fetchEntries(shouldSyncWithCloudKit: true)
//            CloudKitManager.shared.syncSpecificEntries(entries: entries) { error in
//                if let error = error {
//                    print("Error syncing entries: \(error)")
//                }
//            }
//        case .specificEntries:
//            let entries = CoreDataManager.shared.fetchEntries(shouldSyncWithCloudKit: true)
//            CloudKitManager.shared.syncSpecificEntries(entries: entries) { error in
//                if let error = error {
//                    print("Error syncing entries: \(error)")
//                }
//            }
//        }
//    }
//    
//    func updateSyncStatus(for entry: Entry, shouldSync: Bool) {
//        entry.shouldSyncWithCloudKit = shouldSync
//        if shouldSync {
//            CloudKitManager.shared.syncSpecificEntries(entries: [entry]) { error in
//                if let error = error {
//                    print("Error syncing specific entry: \(error)")
//                }
//            }
//        }
//    }
//}
