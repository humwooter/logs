//
//  FoldersView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/22/24.
//

import SwiftUI
import CoreData

struct FoldersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: true)]
    ) var entries: FetchedResults<Entry>
    
    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: true)],
        predicate: NSPredicate(format: "isRemoved == %@", NSNumber(value: true))
    ) var deletedEntries: FetchedResults<Entry>

    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Folder.order, ascending: true),
            NSSortDescriptor(keyPath: \Folder.name, ascending: true) // Secondary sort by name
        ]
    ) var folders: FetchedResults<Folder>
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var showingFoldersSheet = false
    @State private var selectedEntry: Entry?
    @State private var selectedFolder: Folder?
    @State private var searchText: String = ""

    @State private var editMode: EditMode = .inactive
    @State private var editingFolder: Folder?
    @State private var newFolderName: String = ""
    
    @State private var showingRenameAlert = false
    @State private var editedFolderName = ""

    @State private var showingDeleteConfirmation = false
    @State private var folderToDelete: Folder?
    @State var droppedTasks : [String] = []
    @State var targeted: [UUID : Bool] = [:]
    @State var isEditing: [UUID: Bool] = [:]
    
    @State private var isPresentingNewFolderSheet = false
    @Binding var isShowingReplyCreationView: Bool
    @Binding var replyEntryId: String?


    
    var entryViewModel: EntryViewModel {
        return EntryViewModel(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId)
    }

    
    private var filteredFolders: [Folder] {
        folders.filter { folder in
            searchText.isEmpty || folder.name?.localizedCaseInsensitiveContains(searchText) == true
        }
    }

    private func editFolder(_ folder: Folder) {
        isEditing[folder.id] = true
        editingFolder = folder
        editedFolderName = folder.name ?? ""
        showingRenameAlert = true
    }

    private func confirmFolderDeletion(_ folder: Folder) {
        folderToDelete = folder
        showingDeleteConfirmation = true
    }

    private func handleFolderDrop(items: [String], folder: Folder) -> Bool {
        guard let entryId = items.first else { return false }
        handleDrop(entryId: entryId, folder: folder)
        return true
    }

    private func updateTargetedState(for folder: Folder, isTargeted: Bool) {
        targeted[folder.id] = isTargeted
        selectedFolder = isTargeted ? folder : nil
    }
    
    
    var body: some View {
        List {
            foldersView()
            NavigationLink(destination: RecentlyDeletedView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId).environmentObject(coreDataManager).environmentObject(userPreferences)) {
                HStack {
                    Text("Recently Deleted").foregroundStyle(getTextColor())
                    Spacer()
                    Image(systemName: "trash").foregroundStyle(.red)
                }
            }
            .scrollContentBackground(.hidden)
            .listRowBackground(getSectionColor(colorScheme: colorScheme))
        }
        .navigationTitle("Folders")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
//                Menu {
                    
                    Button(action: {
                        newFolderName = ""
                        editingFolder = nil
                        isPresentingNewFolderSheet = true
                    }) {
                        Image(systemName: "folder.badge.plus")
                        .foregroundStyle(userPreferences.accentColor)
                    }
            }
        }
        .sheet(isPresented: $isPresentingNewFolderSheet) {
            NewFolderSheet(isShowingReplyCreationView: $isShowingReplyCreationView, isPresentingNewFolderSheet: $isPresentingNewFolderSheet, replyEntryId: $replyEntryId)
                .environmentObject(userPreferences)
                .environmentObject(coreDataManager)
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("Delete Folder"),
                message: Text("Are you sure you want to delete this folder? All associated entries will be marked as removed."),
                primaryButton: .destructive(Text("Delete")) {
                    if let folder = folderToDelete {
                        deleteFolderPermanently(folder: folder)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .alert("Rename Folder", isPresented: $showingRenameAlert) {
            VStack {
                TextField("Folder Name", text: $editedFolderName)
                HStack {
                    Button("Save") {
                        if let folder = editingFolder {
                            folder.name = editedFolderName
                            try? viewContext.save()
                        }
                        editingFolder = nil
                        showingRenameAlert = false
                    }
                    Button("Cancel", role: .cancel) {
                        editingFolder = nil
                        showingRenameAlert = false
                    }
                }
            }.padding()
        }
    }
    
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

    private func deleteFolderPermanently(folder: Folder) {
        markEntriesAsRemoved(for: folder)
        deleteFolder(folder: folder, coreDataManager: coreDataManager)
//        viewContext.delete(folder)
//        try? viewContext.save()
    }

    private func markEntriesAsRemoved(for folder: Folder) {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "folderId == %@", folder.id.uuidString)

        do {
            let entries = try viewContext.fetch(fetchRequest)
            for entry in entries {
                entry.isRemoved = true
            }
            try viewContext.save()
        } catch {
            print("Failed to mark entries as removed: \(error)")
        }
    }
    
    private func deleteFolders(at offsets: IndexSet) {
        for index in offsets {
            let folder = folders[index]
            markEntriesAsRemoved(for: folder)
            viewContext.delete(folder)
        }
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete folders: \(error)")
        }
    }

//
//    private func deleteFolders(at offsets: IndexSet) {
//        for index in offsets {
//            let folder = folders[index]
//            markEntriesAsRemoved(for: folder)
//            viewContext.delete(folder)
//        }
//        try? viewContext.save()
//    }

    private func moveFolders(from source: IndexSet, to destination: Int) {
        var revisedFolders = folders.map { $0 }
        revisedFolders.move(fromOffsets: source, toOffset: destination)
        
        for index in revisedFolders.indices {
            revisedFolders[index].order = Int16(index)
        }

        try? viewContext.save()
    }
    
    private func isFolderNonExistent(folderId: UUID?, context: NSManagedObjectContext) -> Bool {
        guard let folderId = folderId else {
            return true
        }

        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", folderId as CVarArg)

        do {
            let count = try context.count(for: fetchRequest)
            return count == 0
        } catch {
            print("Failed to fetch Folder: \(error)")
            return true
        }
    }
    
    @ViewBuilder
    func allEntriesView() -> some View {
        
    }

    @ViewBuilder
    func foldersView() -> some View {
//        NavigationLink {
//            allEntriesView()
//        } label: {
//            folderRowView(folder: nil, name: "All Entries")
//        }
//        if !folders.isEmpty {
            Section {
                NavigationLink {
                    allEntriesView()
                } label: {
                    folderRowView(folder: nil, name: "All Entries")
                }
                if !folders.isEmpty {
                    ForEach(filteredFolders, id: \.id) { folder in
                        NavigationLink(destination: folderDetailView(folder: folder)) {
                            folderRowView(folder: folder, name: folder.name ?? "")
                        }
                        .contextMenu {
                            Button {
                                editFolder(folder)
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                confirmFolderDeletion(folder)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .dropDestination(for: String.self) { items, _ in
                            handleFolderDrop(items: items, folder: folder)
                        } isTargeted: { isTargeted in
                            updateTargetedState(for: folder, isTargeted: isTargeted)
                        }
                    }
                    .onMove(perform: moveFolders)
                }
                  } header: {
                      Text("Folders")
                      .foregroundStyle(getIdealHeaderTextColor()).opacity(0.4)
                  } footer: {
                      if folders.isEmpty {
//                          Text("No folders created yet")
                      } else {
                          Spacer(minLength: 20)
                      }
                  }
                  .listSectionSpacing(10)
                  .listRowBackground(getSectionColor(colorScheme: colorScheme))
            .listSectionSpacing(10)
            .scrollContentBackground(.hidden)
            .listRowBackground(getSectionColor(colorScheme: colorScheme))
            .listStyle(InsetGroupedListStyle())
//        }
    }
    
    
    @ViewBuilder
    func folderRowView(folder: Folder?, name: String?) -> some View {
        HStack {
            // Folder icon
            Image(systemName: folder == nil ? "folder.fill" : "folder")
                .font(.buttonSize)
                .foregroundColor(folder == nil ? userPreferences.accentColor.opacity(1) :
                                 (targeted[folder!.id] == true ? .green : userPreferences.accentColor.opacity(1)))
            
            // Folder name
            Text(folder?.name ?? name ?? "Unnamed")
                .foregroundColor(getTextColor())
            
            Spacer()
            
            // Entry count
            Text("\(folder?.entryCount ?? Int16(entries.count ?? 0))")
                .foregroundColor(.gray)
        }
        .if(folder != nil) { view in
            view.dropDestination(for: String.self) { items, _ in
                guard let entryId = items.first else { return false }
                handleDrop(entryId: entryId, folder: folder!)
                return true
            } isTargeted: { isTargeted in
                targeted[folder!.id] = isTargeted
            }
        }
    }

    

    @ViewBuilder
    func entryFrontView(entry: Entry) -> some View {
//        EntryDetailView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, entry: entry, showContextMenu: true)
//            .environmentObject(userPreferences)
//            .environmentObject(coreDataManager)
//            .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
//            .lineSpacing(userPreferences.lineSpacing)
//            .padding(.horizontal)
//            .padding(.vertical, 10)
//            .background(isClear(for: UIColor(userPreferences.entryBackgroundColor)) ? Color("DefaultEntryBackground") : userPreferences.entryBackgroundColor)
//            .cornerRadius(10)
//            .contextMenu {
//                entryContextMenuButtons(entry: entry)
//            }
    }

    
    @ViewBuilder
    func folderDetailView(folder: Folder) -> some View {
        FolderDetailView(folderIdString: folder.id.uuidString, isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId)
//        List {
//            ForEach((folder.relationship?.allObjects as? [Entry] ?? []).filter { !$0.isRemoved }) { entry in
//                Section {
//                    entryFrontView(entry: entry)
//                        .swipeActions(edge: .leading) {
//                            Button {
//                                if (!showingFoldersSheet) {
//                                    selectedEntry = entry
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                        showingFoldersSheet = true
//                                    }
//                                }
//                            } label: {
//                                Label("Add to Folder", systemImage: "folder")
//                            }
//                            .tint(userPreferences.accentColor)
//                        }
//                }
//                .listSectionSpacing(10)
//                .scrollContentBackground(.hidden)
//                .listRowBackground(getSectionColor(colorScheme: colorScheme))
//            }
//        }
//        .navigationTitle(folder.name ?? "Folder")
//        .scrollContentBackground(.hidden)
//        .background {
//            ZStack {
//                Color(UIColor.systemGroupedBackground)
//                LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
//            }
//            .ignoresSafeArea()
//        }
    }


    func handleDrop(entryId: String, folder: Folder) {
        print("entered handle drop")

        // Create a fetch request for Entry
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()

        // Set the predicate to filter by the entryId
        fetchRequest.predicate = NSPredicate(format: "id == %@", entryId)

        do {
            // Perform the fetch request
            let results = try viewContext.fetch(fetchRequest)

            // Check if an entry was found
            if let entry = results.first {
                entry.folderId = folder.id.uuidString
                try viewContext.save()
            }
        } catch {
            print("Failed to fetch Entry: \(error)")
        }
    }
    
    func getTextColor() -> Color {
        // Retrieve the background colors from user preferences
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        let entryBackground = userPreferences.entryBackgroundColor
        
        // Call the calculateTextColor function with these values
        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme
        )
    }
    
    func getIdealHeaderTextColor() -> Color {
        return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(userPreferences.backgroundColors.first ?? Color.clear), and: UIColor(userPreferences.backgroundColors[1])), colorScheme: colorScheme))
    }
    
    func getSectionColor(colorScheme: ColorScheme) -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        } else {
            return userPreferences.entryBackgroundColor
        }
    }
}
