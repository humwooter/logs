//
//  NewFolderView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/22/24.
//

import SwiftUI
import CoreData

//struct NewFolderView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(
//        entity: Folder.entity(),
//        sortDescriptors: [
//            NSSortDescriptor(keyPath: \Folder.order, ascending: true),
//            NSSortDescriptor(keyPath: \Folder.name, ascending: true)
//        ]
//    ) var folders: FetchedResults<Folder>
//    
//    @State private var newFolderName: String = ""
//    @State private var isPresentingNewFolderSheet = false
//    @State private var editingFolder: Folder?
//    @State private var searchText: String = ""
//    @Environment(\.presentationMode) var presentationMode
//    @Environment(\.colorScheme) var colorScheme
//    @EnvironmentObject var userPreferences: UserPreferences
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                headerView()
//                
//                foldersListView()
//                
//                bottomToolbar()
//            }
//            .scrollContentBackground(.hidden)
//            .background(backgroundView())
//            .sheet(isPresented: $isPresentingNewFolderSheet) {
//                newFolderSheet()
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private func headerView() -> some View {
//        HStack {
//            Text("Folders")
//                .font(.largeTitle)
//                .bold()
//            Spacer()
//        }
//        .padding()
//    }
//    
//    @ViewBuilder
//    private func foldersListView() -> some View {
//        List {
//            Section(header: Text("Folders")) {
//                ForEach(folders.filter {
//                    searchText.isEmpty ? true : $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
//                }, id: \.self) { folder in
//                    folderRow(name: folder.name ?? "Unnamed", icon: "folder", count: Int(folder.entryCount), folderId: folder.id) {
//                        selectFolder(folder: folder)
//                    }
//                    .contextMenu {
//                        Button("Rename") {
//                            editingFolder = folder
//                            newFolderName = folder.name ?? ""
//                            isPresentingNewFolderSheet = true
//                        }
//                        Button("Delete", role: .destructive) {
//                            deleteFolder(folder: folder)
//                        }
//                    }
//                }
//                .onMove(perform: moveFolders)
//                .onDelete(perform: deleteFolders)
//            }
//            .scrollContentBackground(.hidden)
//            .listSectionSpacing(10)
//            .listRowBackground(getSectionColor(colorScheme: colorScheme).opacity(0.5))
//        }
//    }
//    
//    @ViewBuilder
//    private func bottomToolbar() -> some View {
//        HStack {
//            Button(action: {
//                newFolderName = ""
//                editingFolder = nil
//                isPresentingNewFolderSheet = true
//            }) {
//                Image(systemName: "folder.badge.plus")
//                    .foregroundColor(userPreferences.accentColor)
//            }
//            Spacer()
//        }
//        .padding(.bottom)
//    }
//    
//    @ViewBuilder
//    private func backgroundView() -> some View {
//        ZStack {
//            LinearGradient(colors: [userPreferences.backgroundColors.first ?? Color.clear, userPreferences.backgroundColors[1]], startPoint: .top, endPoint: .bottom)
//        }
//        .ignoresSafeArea(.all)
//    }
//    
//    @ViewBuilder
//    private func folderRow(name: String, icon: String, count: Int, folderId: UUID?, selectFolder: @escaping () -> Void) -> some View {
//        HStack {
//            Image(systemName: icon)
//                .foregroundColor(userPreferences.accentColor)
//            Text(name)
//            Spacer()
//            Text("\(count)")
//                .foregroundColor(.gray)
//            Button(action: selectFolder) {
//                Image(systemName: "plus.circle.fill")
//                    .foregroundColor(.green)
//            }
//        }
//        .padding(.vertical, 5)
//    }
//    
//    @ViewBuilder
//    private func newFolderSheet() -> some View {
//        NavigationView {
//            List {
//                TextField("New Folder", text: $newFolderName)
//                    .foregroundStyle(colorScheme == .dark ? .white : .black)
//                    .cornerRadius(8)
//            }
//            .navigationBarTitle(editingFolder == nil ? "New Folder" : "Rename Folder", displayMode: .inline)
//            .navigationBarItems(leading: Button("Cancel") {
//                isPresentingNewFolderSheet = false
//            }, trailing: Button("Done") {
//                createFolder()
//                isPresentingNewFolderSheet = false
//            })
//            .scrollContentBackground(.hidden)
//            .background(backgroundView())
//            .foregroundStyle(userPreferences.accentColor)
//        }
//    }
//    
//    private func createFolder() {
//        guard !newFolderName.isEmpty else { return }
//        
//        if let folder = editingFolder {
//            folder.name = newFolderName
//        } else {
//            let newFolder = Folder(context: viewContext)
//            newFolder.id = UUID()
//            newFolder.name = newFolderName
//            newFolder.order = Int16(folders.count)
//        }
//        
//        try? viewContext.save()
//        newFolderName = ""
//    }
//    
//    private func deleteFolder(folder: Folder) {
//        viewContext.delete(folder)
//        try? viewContext.save()
//    }
//    
//    private func deleteFolders(at offsets: IndexSet) {
//        for index in offsets {
//            let folder = folders[index]
//            viewContext.delete(folder)
//        }
//        try? viewContext.save()
//    }
//    
//    private func moveFolders(from source: IndexSet, to destination: Int) {
//        var revisedFolders = folders.map { $0 }
//        revisedFolders.move(fromOffsets: source, toOffset: destination)
//        
//        for index in revisedFolders.indices {
//            revisedFolders[index].order = Int16(index)
//        }
//
//        try? viewContext.save()
//    }
//    
//    private func selectFolder(folder: Folder) {
//        presentationMode.wrappedValue.dismiss()
//    }
//    
//    func getSectionColor(colorScheme: ColorScheme) -> Color {
//        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
//            return entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)
//        } else {
//            return userPreferences.entryBackgroundColor
//        }
//    }
//}


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
    @State private var isPresentingNewFolderSheet = false
    @State private var editingFolder: Folder?
    @State private var searchText: String = ""
    @Binding var isShowingReplyCreationView: Bool
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
            newFolder.order = Int16(folders.count)
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
