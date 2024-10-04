//
//  NewFolderView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/22/24.
//

import SwiftUI
import CoreData


struct NewFolderSheet: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Folder.order, ascending: true),
            NSSortDescriptor(keyPath: \Folder.name, ascending: true)
        ]
    ) var folders: FetchedResults<Folder>
    
    @State private var newFolderName: String = ""
    @State private var editingFolder: Folder?
    @State private var searchText: String = ""
    @Binding var isShowingReplyCreationView: Bool
    @Binding var isPresentingNewFolderSheet: Bool
    @Binding var replyEntryId: String?
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    
    
    var entryViewModel: EntryViewModel {
        EntryViewModel(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId)
    }

    var body: some View {
        newFolderSheet()
    }
    
    
    @ViewBuilder
    private func folderRow(name: String, icon: String, count: Int, folderId: UUID?, selectFolder: @escaping () -> Void) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(userPreferences.accentColor)
            Text(name)
            Spacer()
            Text("\(count)")
                .foregroundColor(.gray)
            Button(action: selectFolder) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 5)
    }
    
    @ViewBuilder
    private func newFolderSheet() -> some View {
        NavigationView {
            List {
                TextField("New Folder", text: $newFolderName)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .cornerRadius(8)
            }
            .navigationBarTitle(editingFolder == nil ? "New Folder" : "Rename Folder", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                isPresentingNewFolderSheet = false
            }, trailing: Button("Done") {
                createFolder()
                isPresentingNewFolderSheet = false
            }).font(.customHeadline)
            .scrollContentBackground(.hidden)
            .background {
                userPreferences.backgroundView(colorScheme: colorScheme)
            }
            .foregroundStyle(userPreferences.accentColor)
        }
    }
    
    private func createFolder() {
        guard !newFolderName.isEmpty else { return }
        
        if let folder = editingFolder {
            folder.name = newFolderName
        } else {
            let newFolder = Folder(context: coreDataManager.viewContext)
            newFolder.id = UUID()
            newFolder.name = newFolderName
            newFolder.folderType = "entry"
            newFolder.order = Int16(folders.count)
            newFolder.isRemoved = false
            newFolder.dateCreated = Date()
        }
        
        try? coreDataManager.viewContext.save()
//        newFolderName = ""
        presentationMode.wrappedValue.dismiss()
    }
    
    private func deleteFolder(folder: Folder) {
        coreDataManager.viewContext.delete(folder)
        try? viewContext.save()
    }
    
    private func deleteFolders(at offsets: IndexSet) {
        for index in offsets {
            let folder = folders[index]
            coreDataManager.viewContext.delete(folder)
        }
        try? coreDataManager.viewContext.save()
    }
    
    private func moveFolders(from source: IndexSet, to destination: Int) {
        var revisedFolders = folders.map { $0 }
        revisedFolders.move(fromOffsets: source, toOffset: destination)
        
        for index in revisedFolders.indices {
            revisedFolders[index].order = Int16(index)
        }

        try? viewContext.save()
    }
    
}
