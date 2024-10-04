//
//  FolderDetailView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/28/24.
//

import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct FolderDetailView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    @Binding var isShowingReplyCreationView: Bool
    @Binding var replyEntryId: String?
    let folderIdString: String
    
    @State private var isEditing = false

    @FetchRequest private var entries: FetchedResults<Entry>
    
    init(folderIdString: String, isShowingReplyCreationView: Binding<Bool>, replyEntryId: Binding<String?>) {
        self.folderIdString = folderIdString
        self._isShowingReplyCreationView = isShowingReplyCreationView
        self._replyEntryId = replyEntryId
        
        // Set up the fetch request with a predicate that matches entries for the specific folderId
        self._entries = FetchRequest<Entry>(
            entity: Entry.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: false)],
            predicate: NSPredicate(format: "folderId == %@ AND isRemoved == NO", folderIdString)
        )
    }

    var entryViewModel: EntryViewModel {
        EntryViewModel(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId)
    }
    
    var body: some View {
        if !entries.isEmpty {
            List(entries, id: \.self) { entry in
                EntryDetailView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, entry: entry, showContextMenu: true, isInList: true, filterOption: nil)
                    .environmentObject(coreDataManager)
                    .environmentObject(userPreferences)
                    .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                    .lineSpacing(userPreferences.lineSpacing)
                    .listRowBackground(getSectionColor(colorScheme: colorScheme))
            }
            .background {
                userPreferences.backgroundView(colorScheme: colorScheme)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.automatic)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Folder Details")
        } else {
            Text("No entries available")
                .foregroundColor(.gray)
        }
    }
    
    func getSectionColor(colorScheme: ColorScheme) -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        } else {
            return userPreferences.entryBackgroundColor
        }
    }
}
