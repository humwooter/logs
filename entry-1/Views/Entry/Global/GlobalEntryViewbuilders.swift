//
//  GlobalEntryViewbuilders.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/13/24.
//

import SwiftUI
import Foundation
import SwiftUI

protocol EntryContextMenuProvider {
    var isShowingReplyCreationView: Binding<Bool> { get }
    var replyEntryId: Binding<String?> { get }
    var userPreferences: UserPreferences { get }
    var coreDataManager: CoreDataManager { get }
    
}

extension EntryContextMenuProvider {
    @ViewBuilder
    func entryContextMenuButtons(entry: Entry) -> some View {
        Button(action: {
            withAnimation {
                isShowingReplyCreationView.wrappedValue = true
                replyEntryId.wrappedValue = entry.id.uuidString
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
                coreDataManager.save(context: coreDataManager.viewContext)
            }
        }) {
            Label(entry.isHidden ? "Hide Entry" : "Unhide Entry", systemImage: entry.isHidden ? "eye.slash.fill" : "eye.fill")
        }
        
        if let filename = entry.mediaFilename {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            if mediaExists(at: fileURL) {
                if let data = getMediaData(fromFilename: filename) {
                    if !isPDF(data: data) {
                        if let image = UIImage(data: data) {
                            Button(action: {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            }) {
                                Label("Save Image", systemImage: "photo.badge.arrow.down.fill")
                            }
                        }
                    }
                }
            }
        }
        
        Button(action: {
            withAnimation {
                entry.isPinned.toggle()
                coreDataManager.save(context: coreDataManager.viewContext)
            }
        }) {
            Text(entry.isPinned ? "Unpin" : "Pin")
            Image(systemName: "pin.fill")
                .foregroundColor(.red)
        }
    }
}
