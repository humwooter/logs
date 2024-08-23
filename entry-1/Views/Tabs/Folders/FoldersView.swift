////
////  FoldersView.swift
////  entry-1
////
////  Created by Katyayani G. Raman on 8/22/24.
////
//
//import SwiftUI
//import CoreData
//
//struct FolderView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(
//        entity: Entry.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.title, ascending: true)]
//    ) var entries: FetchedResults<Entry>
//    
//    @FetchRequest(
//        entity: Entry.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.title, ascending: true)],
//        predicate: NSPredicate(format: "isRemoved == %@", NSNumber(value: true))
//    ) var deletedEntries: FetchedResults<Entry>
//
//    @FetchRequest(
//        entity: Folder.entity(),
//        sortDescriptors: [
//            NSSortDescriptor(keyPath: \Folder.order, ascending: true),
//            NSSortDescriptor(keyPath: \Folder.name, ascending: true) // Secondary sort by name
//        ]
//    ) var folders: FetchedResults<Folder>
//    
//    @Environment(\.colorScheme) var colorScheme
//    @EnvironmentObject var userPreferences: UserPreferences
//    @EnvironmentObject var coreDataManager: CoreDataManager
//    @State private var showingFoldersSheet = false
//    @State private var selectedEntry: Entry?
//    @State private var selectedFolder: Folder?
//    @State private var searchText: String = ""
//    @State private var isBookmarked = false
//    @State private var showingBookmarkAlert = false
//    @State private var editMode: EditMode = .inactive
//    @State private var editingFolder: Folder?
//    @State private var newFolderName: String = ""
//    
//    @State private var showingRenameAlert = false
//    @State private var editedFolderName = ""
//
//    @State private var showingDeleteConfirmation = false
//    @State private var folderToDelete: Folder?
//    @State var droppedTasks : [String] = []
//    @State var targeted: [UUID : Bool] = [:]
//    @State var isEditing: [UUID: Bool] = [:]
//    
//    @State private var isPresentingNewFolderSheet = false
//    @State private var isShowingReplyCreationView = false
//    @State private var replyEntryId: UUID?
//    
//    var body: some View {
//        List {
//            foldersView()
//            NavigationLink(destination: RecentlyDeletedView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId).environmentObject(coreDataManager).environmentObject(userPreferences)) {
//                HStack {
//                    Text("Recently Deleted").foregroundStyle(getTextColor())
//                    Spacer()
//                    Image(systemName: "trash").foregroundStyle(.red)
//                }
//            }
//            .scrollContentBackground(.hidden)
//            .listRowBackground(getSectionColor(colorScheme: colorScheme))
//        }
//        .navigationTitle("Folders")
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                EditButton()
//                    .foregroundStyle(userPreferences.accentColor)
//            }
//            
//            ToolbarItem(placement: .bottomBar) {
//                HStack {
//                    Button(action: {
//                        newFolderName = ""
//                        editingFolder = nil
//                        isPresentingNewFolderSheet = true
//                    }) {
//                        Image(systemName: "folder.badge.plus")
//                        .foregroundStyle(userPreferences.accentColor)
//                    }
//                    Spacer()
//                }
//            }
//        }
//        .environment(\.editMode, $editMode)
////        .fullScreenCover(isPresented: $showingFoldersSheet) {
////            FoldersView(selectedEntry: $selectedEntry, accentColor: $userPreferences.accentColor)
////        }
//        .sheet(isPresented: $isPresentingNewFolderSheet) {
//            NewFolderSheet(isPresented: $isPresentingNewFolderSheet, newFolderName: $newFolderName, createFolder: createFolder, editingFolder: $editingFolder, accentColor: $userPreferences.accentColor)
//        }
//        .alert(isPresented: $showingDeleteConfirmation) {
//            Alert(
//                title: Text("Delete Folder"),
//                message: Text("Are you sure you want to delete this folder? All associated entries will be marked as removed."),
//                primaryButton: .destructive(Text("Delete")) {
//                    if let folder = folderToDelete {
//                        markEntriesAsRemoved(for: folder)
//                        deleteFolder(folder: folder)
//                    }
//                },
//                secondaryButton: .cancel()
//            )
//        }
//        .alert("Rename Folder", isPresented: $showingRenameAlert) {
//            VStack {
//                TextField("Folder Name", text: $editedFolderName)
//                HStack {
//                    Button("Save") {
//                        if let folder = editingFolder {
//                            folder.name = editedFolderName
//                            try? viewContext.save()
//                        }
//                        editingFolder = nil
//                        showingRenameAlert = false
//                    }
//                    Button("Cancel", role: .cancel) {
//                        editingFolder = nil
//                        showingRenameAlert = false
//                    }
//                }
//            }.padding()
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
//        markEntriesAsRemoved(for: folder)
//        viewContext.delete(folder)
//        try? viewContext.save()
//    }
//
//    private func markEntriesAsRemoved(for folder: Folder) {
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "folderId == %@", folder.id.uuidString)
//
//        do {
//            let entries = try viewContext.fetch(fetchRequest)
//            for entry in entries {
//                entry.isRemoved = true
//            }
//            try viewContext.save()
//        } catch {
//            print("Failed to mark entries as removed: \(error)")
//        }
//    }
//
//    private func deleteFolders(at offsets: IndexSet) {
//        for index in offsets {
//            let folder = folders[index]
//            markEntriesAsRemoved(for: folder)
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
//    private func isFolderNonExistent(folderId: UUID?, context: NSManagedObjectContext) -> Bool {
//        guard let folderId = folderId else {
//            return true
//        }
//
//        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", folderId as CVarArg)
//
//        do {
//            let count = try context.count(for: fetchRequest)
//            return count == 0
//        } catch {
//            print("Failed to fetch Folder: \(error)")
//            return true
//        }
//    }
//
//    @ViewBuilder
//    func foldersView() -> some View {
//        if !folders.isEmpty {
//            Section {
//                NavigationLink {
//                    entriesView()
//                } label: {
//                    folderRowView(folder: nil, name: "All Entries")
//                }
//                ForEach(folders.filter {
//                    searchText.isEmpty ? true : $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
//                }, id: \.self) { folder in
//                    NavigationLink(destination: folderDetailView(folder: folder)) {
//                        folderRowView(folder: folder, name: "")
//                        
//                    }
//                    .contextMenu {
//                        Button {
//                            isEditing[folder.id] = true
//                            editingFolder = folder
//                            editedFolderName = folder.name ?? ""
//                            showingRenameAlert = true
//                            
//                        } label: {
//                            Label("Rename", systemImage: "pencil")
//                        }
//
//                    }
//                    .dropDestination(for: String.self) { items, location in
//                        print("DROPPED TASKS: \(droppedTasks)")
//                        guard let transferable = items.first else { return false }
//                        droppedTasks.append(transferable)
//                        handleDrop(url: URL(string: transferable)! , folder: folder)
//                        return true
//                    } isTargeted: { isTargeted in
//                        targeted[folder.id] = isTargeted
//                        if isTargeted {
//                            selectedFolder = folder
//                        } else {
//                            selectedFolder = nil
//                        }
//                    }
//                    .swipeActions(edge: .trailing) {
//                        Button(role: .destructive) {
//                            folderToDelete = folder
//                            showingDeleteConfirmation = true
//                        } label: {
//                            Label("Delete", systemImage: "trash")
//                        }
//                    }
//                }
//                .onMove(perform: moveFolders)
//            } header: {
//                Text("Folders").font(.custom("Georgia", size: UIFont.systemFontSize * 1.2)).bold()
//            } footer: {
//                Spacer(minLength: 20)
//            }
//            .listSectionSpacing(10)
//            .scrollContentBackground(.hidden)
//            .listRowBackground(getSectionColor(colorScheme: colorScheme))
//            .listStyle(InsetGroupedListStyle())
//        }
//    }
//
//    @ViewBuilder
//    func folderRowView(folder: Folder?, name: String?) -> some View {
//        if let folder = folder {
//            HStack {
//                Image(systemName: "folder")
//                    .foregroundColor(targeted[folder.id] == true ? .green : userPreferences.accentColor.opacity(1))
//        
//                Text(folder.name ?? "Unnamed").foregroundColor(getTextColor())
//                Spacer()
//                Text("\(folder.entryCount ?? 0)")
//                    .foregroundColor(.gray)
//                    .dropDestination(for: String.self) { items, location in
//                        print("DROPPED TASKS: \(droppedTasks)")
//                        guard let transferable = items.first else { return false }
//                        droppedTasks.append(transferable)
//                        handleDrop(url: URL(string: transferable)! , folder: folder)
//                        return true
//                    } isTargeted: { isTargeted in
//                        targeted[folder.id] = isTargeted
//                    }
//            }
//        } else { //The case for all entries
//            HStack {
//                Image(systemName: "folder.fill").foregroundStyle(userPreferences.accentColor.opacity(1))
//                Text(name ?? "").foregroundStyle(getTextColor())
//                Spacer()
//                Text("\(entries.count ?? 0)")
//                    .foregroundColor(.gray)
//            }
//        }
//    }
//    
//    
//    @ViewBuilder
//    func entryContextMenuButtons(entry: Entry) -> some View {
//        
//        Button(action: {
//            withAnimation {
//                isShowingReplyCreationView = true
//                replyEntryId = entry.id.uuidString
//            }
//        }) {
//            Text("Reply")
//            Image(systemName: "arrow.uturn.left")
//                .foregroundColor(userPreferences.accentColor)
//        }
//        
//        Button(action: {
//            UIPasteboard.general.string = entry.content
//            print("entry color : \(entry.color)")
//        }) {
//            Text("Copy Message")
//            Image(systemName: "doc.on.doc")
//        }
//    
//        
//        Button(action: {
//            withAnimation(.easeOut) {
//                entry.isHidden.toggle()
//                coreDataManager.save(context: coreDataManager.viewContext)
//            }
//
//        }, label: {
//            Label(entry.isHidden ? "Hide Entry" : "Unhide Entry", systemImage: entry.isHidden ? "eye.slash.fill" : "eye.fill")
//        })
//        
//        if let filename = entry.mediaFilename {
//            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let fileURL = documentsDirectory.appendingPathComponent(filename)
//            if mediaExists(at: fileURL) {
//                if let data =  getMediaData(fromFilename: filename) {
//                    if isPDF(data: data) {
//                    } else {
//                        let image = UIImage(data: data)!
//                        Button(action: {
//                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                            
//                        }, label: {
//                            Label("Save Image", systemImage: "photo.badge.arrow.down.fill")
//                        })
//                    }
//                }
//            }
//        }
//        
//        Button(action: {
//            withAnimation {
//                entry.isPinned.toggle()
//                coreDataManager.save(context: coreDataManager.viewContext)
//            }
//        }) {
//            Text(entry.isPinned ? "Unpin" : "Pin")
//            Image(systemName: "pin.fill")
//                .foregroundColor(.red)
//        }
//        
//        
//        
//        Button(action: {
//            entry.shouldSyncWithCloudKit.toggle()
//            
//            // Save the flag change in local storage first
//            coreDataManager.save(context: coreDataManager.viewContext)
//
////            CoreDataManager.shared.save(context: CoreDataManager.shared.viewContext)
//
//            // Save the entry in the appropriate store
//            CoreDataManager.shared.saveEntry(entry)
//        }) {
//            Text(entry.shouldSyncWithCloudKit && coreDataManager.isEntryInCloudStorage(entry) ? "Unsync" : "Sync")
//            Image(systemName: "cloud.fill")
//        }
//        
//    }
//
//    @ViewBuilder
//    func entryFrontView(entry: Entry) -> some View {
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
//    }
//
//    
//    @ViewBuilder
//    func folderDetailView(folder: Folder) -> some View {
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
//    }
//
//
//    
//    func handleDrop(url: URL, folder: Folder) {
//        print("entered handle drop")
//
//        // Create a fetch request for Entry
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        
//        // Set the predicate to filter by the url
//        fetchRequest.predicate = NSPredicate(format: "url == %@", url.absoluteString)
//        
//        do {
//            // Perform the fetch request
//            let results = try viewContext.fetch(fetchRequest)
//            
//            // Check if an entry was found
//            if let entry = results.first {
//                entry.folderId = folder.id.uuidString
//                try viewContext.save()
//            }
//        } catch {
//            print("Failed to fetch Entry: \(error)")
//        }
//    }
//    
//    func getTextColor() -> Color {
//        // Retrieve the background colors from user preferences
//        let background1 = userPreferences.backgroundColors.first ?? Color.clear
//        let background2 = userPreferences.backgroundColors[1]
//        let entryBackground = userPreferences.entryBackgroundColor
//        
//        // Call the calculateTextColor function with these values
//        return calculateTextColor(
//            basedOn: background1,
//            background2: background2,
//            entryBackground: entryBackground,
//            colorScheme: colorScheme
//        )
//    }
//    
//    func getIdealHeaderTextColor() -> Color {
//        return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(userPreferences.backgroundColors.first ?? Color.clear), and: UIColor(userPreferences.backgroundColors[1])), colorScheme: colorScheme))
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
