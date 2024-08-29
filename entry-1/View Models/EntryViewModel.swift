//
//  EntryViewModel.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/27/24.
//

import SwiftUI
import Foundation
import CoreData


@MainActor
class EntryViewModel: ObservableObject {
    @Binding var isShowingReplyCreationView: Bool
    @Binding var replyEntryId: String?
    @Environment(\.colorScheme) var colorScheme


    private var coreDataManager = CoreDataManager(persistenceController: PersistenceController.shared)
    @ObservedObject private var userPreferences: UserPreferences = UserPreferences()
    
    init(isShowingReplyCreationView: Binding<Bool>, replyEntryId: Binding<String?>) {
        self._isShowingReplyCreationView = isShowingReplyCreationView
        self._replyEntryId = replyEntryId
    }
    
//    var backgroundView: any View {
//        ZStack {
//            LinearGradient(colors: getBackgroundColors(), startPoint: .top, endPoint: .bottom)
//        }
//        .ignoresSafeArea(.all)
//    }
//    
    

    
    func entryContextMenuButtons(entry: Entry, isShowingEntryEditView: Binding<Bool>) -> some View {
        return VStack {
            Button(action: {
                withAnimation {
                    isShowingEntryEditView.wrappedValue = true
                }
            }) {
                Text("Edit")
                Image(systemName: "pencil")
                    .foregroundColor(userPreferences.accentColor)
            }
            
            Button(action: {
                withAnimation {
                    self.isShowingReplyCreationView = true
                    self.replyEntryId = entry.id.uuidString
                }
            }) {
                Text("Reply")
                Image(systemName: "arrow.uturn.left")
                    .foregroundColor(userPreferences.accentColor)
            }
            
            Button(action: {
                UIPasteboard.general.string = entry.content
                print("entry color : \(entry.color)")
            }) {
                Text("Copy Message")
                Image(systemName: "doc.on.doc")
            }
            
            Button(action: {
                withAnimation(.easeOut) {
                    entry.isHidden.toggle()
                    self.coreDataManager.save(context: self.coreDataManager.viewContext)
                }
            }) {
                Label(entry.isHidden ? "Unhide Entry" : "Hide Entry", systemImage: entry.isHidden ? "eye.slash.fill" : "eye.fill")
            }
            
            if let filename = entry.mediaFilename {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent(filename)
                if mediaExists(at: fileURL), let data = getMediaData(fromFilename: filename) {
                    if !isPDF(data: data) {
                        let image = UIImage(data: data)!
                        Button(action: {
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        }) {
                            Label("Save Image", systemImage: "photo.badge.arrow.down.fill")
                        }
                    }
                }
            }
            
            Button(action: {
                withAnimation {
                    entry.isPinned.toggle()
                    self.coreDataManager.save(context: self.coreDataManager.viewContext)
                }
            }) {
                Text(entry.isPinned ? "Unpin" : "Pin")
                Image(systemName: "pin.fill")
                    .foregroundColor(.red)
            }
            
            if userPreferences.enableCloudMirror {
                Button(action: {
                    entry.shouldSyncWithCloudKit.toggle()
                    
                    self.coreDataManager.save(context: self.coreDataManager.viewContext)
                    self.coreDataManager.saveEntry(entry)
                }) {
                    Text(entry.shouldSyncWithCloudKit && coreDataManager.isEntryInCloudStorage(entry) ? "Unsync" : "Sync")
                    Image(systemName: "cloud.fill")
                }
            }
        }
        
    }

    // Add your helper methods like mediaExists, getMediaData, isPDF, etc., here
}
