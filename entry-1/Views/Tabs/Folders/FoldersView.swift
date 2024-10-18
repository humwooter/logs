//
//  FoldersView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/22/24.
//
import SwiftUI
import CoreData
import EventKit


struct FoldersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.colorScheme) var colorScheme

    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Folder.order, ascending: true),
            NSSortDescriptor(keyPath: \Folder.name, ascending: true) // secondary sort by name
        ],
        predicate:   NSPredicate(format: "isRemoved != true")
    ) var folders: FetchedResults<Folder>
    
    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: true)]
    ) var entries: FetchedResults<Entry>
    
    @State private var searchText: String = ""
    @State private var showingRenameAlert = false
    @State private var showingDeleteConfirmation = false
    @State private var showingNewFolderAlert = false
    
    @State private var editingFolder: Folder?
    @State private var folderToDelete: Folder?
    @State private var editedFolderName = ""
    @State private var newFolderName = ""

    @State private var targeted: [UUID: Bool] = [:]

    @Binding var isShowingReplyCreationView: Bool
    @Binding var replyEntryId: String?
    @ObservedObject var searchModel: SearchModel
    @State var reminderManager: ReminderManager

    private var filteredFolders: [Folder] {
        folders.filter { folder in
            searchText.isEmpty || folder.name?.localizedCaseInsensitiveContains(searchText) == true
        }
    }

    var body: some View {
            List {
                foldersView()
                recentlyDeletedLink()
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Folders")
            .toolbar { addFolderButton() }
            .alert(isPresented: $showingDeleteConfirmation) {
                deleteFolderAlert()
            }
            .alert("Rename Folder", isPresented: $showingRenameAlert) {
                renameFolderAlert()
            }
            .alert("New Folder", isPresented: $showingNewFolderAlert) {
                newFolderAlert()
            }
    }

    @ViewBuilder
    private func foldersView() -> some View {
        Section {
            NavigationLink(destination: allEntriesView()) {
                folderRowView(folder: nil, name: "All Entries")
            }
            ForEach(filteredFolders, id: \.id) { folder in
                NavigationLink(destination: folderDetailView(folder: folder)) {
                    folderRowView(folder: folder, name: folder.name ?? "")
                }
                .contextMenu { renameButton(folder: folder) }
                .swipeActions(edge: .trailing) { deleteButton(folder: folder) }
                .dropDestination(for: String.self) { items, _ in
                                            handleFolderDrop(items: items, folder: folder)
                                        } isTargeted: { isTargeted in
                                            updateTargetedState(for: folder, isTargeted: isTargeted)
                                        }
//                .onDrag {
//                    NSItemProvider(object: folder.id.uuidString as NSString)
//                }
//                .dropDestination(for: String.self) { items, _ in
//                    handleFolderDrop(items: items, folder: folder)
//                } isTargeted: { isTargeted in
//                    updateTargetedState(for: folder, isTargeted: isTargeted)
//                }
            }
            .onMove(perform: moveFolders)
        } header: {
            Text("Folders").foregroundStyle(getIdealHeaderTextColor()).opacity(0.4)
        }
        .listRowBackground(getSectionColor(colorScheme: colorScheme))
    }

    @ViewBuilder
    private func recentlyDeletedLink() -> some View {
        NavigationLink(destination: RecentlyDeletedView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, reminderManager: reminderManager).environmentObject(coreDataManager).environmentObject(userPreferences)) {
            HStack {
                Text("Recently Deleted").foregroundStyle(getTextColor())
                Spacer()
                Image(systemName: "trash").foregroundStyle(.red)
            }
        }
        .listRowBackground(getSectionColor(colorScheme: colorScheme))
    }

    @ToolbarContentBuilder
    private func addFolderButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                showingNewFolderAlert = true
            }) {
                Image(systemName: "folder.badge.plus").foregroundStyle(userPreferences.accentColor)
            }
        }
    }

    private func deleteFolderAlert() -> Alert {
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

    private func renameFolderAlert() -> some View {
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

    private func newFolderAlert() -> some View {
        VStack {
            TextField("Folder Name", text: $newFolderName)
            HStack {
                Button("Create") {
                    createFolder()
                    showingNewFolderAlert = false
                }
                Button("Cancel", role: .cancel) {
                    showingNewFolderAlert = false
                }
            }
        }.padding()
    }

    private func createFolder() {
        guard !newFolderName.isEmpty else { return }
        
        let newFolder = Folder(context: viewContext)
        newFolder.id = UUID()
        newFolder.name = newFolderName
        newFolder.order = Int16(folders.count)
        newFolder.dateCreated = Date()
        newFolder.isRemoved = false
        newFolder.entryCount = 0
        
        do {
            try viewContext.save()
            newFolderName = ""
        } catch {
            print("Failed to create new folder: \(error)")
        }
    }

    private func renameButton(folder: Folder) -> some View {
        Button {
            editFolder(folder)
        } label: {
            Label("Rename", systemImage: "pencil")
        }
    }

    private func deleteButton(folder: Folder) -> some View {
        Button(role: .destructive) {
            confirmFolderDeletion(folder)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func editFolder(_ folder: Folder) {
        editingFolder = folder
        editedFolderName = folder.name ?? ""
        showingRenameAlert = true
    }

    private func confirmFolderDeletion(_ folder: Folder) {
        folderToDelete = folder
        showingDeleteConfirmation = true
    }

    private func deleteFolderPermanently(folder: Folder) {
        markEntriesAsRemoved(for: folder)
//        coreDataManager.removeFolder(folder: folder, context: coreDataManager.viewContext)
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

    private func moveFolders(from source: IndexSet, to destination: Int) {
        var revisedFolders = folders.map { $0 }
        revisedFolders.move(fromOffsets: source, toOffset: destination)
        
        for index in revisedFolders.indices {
            revisedFolders[index].order = Int16(index)
        }

        try? viewContext.save()
    }

    @ViewBuilder
    private func folderRowView(folder: Folder?, name: String?) -> some View {
        HStack {
            Image(systemName: folder == nil ? "folder.fill" : "folder")
                .font(.buttonSize)
                .foregroundColor(folder == nil ? userPreferences.accentColor : (targeted[folder!.id] == true ? .green : userPreferences.accentColor))
            Text(folder?.name ?? name ?? "Unnamed")
                .foregroundColor(getTextColor())
            Spacer()
            HStack {
                Text("\(folder == nil ? entries.count : entries.filter { $0.folderId == folder?.id.uuidString }.count)")
                    .foregroundStyle(userPreferences.accentColor.opacity(0.5))
//                Image(systemName: "chevron.right")
//                    .foregroundStyle(getTextColor().opacity(0.5))
            }
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
    private func allEntriesView() -> some View {
        AllEntriesView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, searchModel: searchModel)
            .environmentObject(userPreferences)
            .environmentObject(coreDataManager)
            .background {
                userPreferences.backgroundView(colorScheme: colorScheme)
            }
            .searchable(text: $searchModel.searchText, tokens: $searchModel.tokens) { token in
                        switch token {
                        case .isHidden(let value):
                            Label("Hidden", systemImage: "eye.slash")
                                .foregroundColor(value ? .primary : .secondary)
                        case .hasMedia(let value):
                            Label("Media", systemImage: "paperclip")
                                .foregroundColor(value ? .primary : .secondary)
                        case .hasReminder(let value):
                            Label("Reminder", systemImage: "bell")
                                .foregroundColor(value ? .primary : .secondary)
                        case .isPinned(let value):
                            Label("Pinned", systemImage: "pin")
                                .foregroundColor(value ? .primary : .secondary)
                        case .stampIcon(let icon):
                            if icon.isEmpty {
                                Label("Stamp Label", systemImage: "hare.fill")
                            } else {
                                Label(icon, systemImage: "stamp")
                            }
                        case .content(let searchText):
                            Label(searchText, systemImage: "magnifyingglass")
                        case .title(let searchText):
                            Label(searchText, systemImage: "text.magnifyingglass")
                        case .tag(let tagName):
                            Label(tagName, systemImage: "tag")
                        case .date(let date):
                            Label(dateFormatter.string(from: date), systemImage: "calendar")
                        case .time(let start, let end):
                            Label("\(dateFormatter.string(from: start)) - \(dateFormatter.string(from: end))", systemImage: "clock")
                        case .lastUpdated(let start, let end):
                            Label("Updated: \(dateFormatter.string(from: start)) - \(dateFormatter.string(from: end))", systemImage: "clock.arrow.circlepath")
                        case .color(let color):
                            Label("Color", systemImage: "circle.fill")
                                .foregroundColor(Color(color))
                        case .tagNames(let tags):
                            Label(tags.joined(separator: ", "), systemImage: "tag")
                        case .isShown(let value):
                            Label("Shown", systemImage: "eye")
                                .foregroundColor(value ? .primary : .secondary)
                        case .isRemoved(let value):
                            Label("Removed", systemImage: "trash")
                                .foregroundColor(value ? .primary : .secondary)
                        case .isDrafted(let value):
                            Label("Draft", systemImage: "doc.text")
                                .foregroundColor(value ? .primary : .secondary)
                        case .shouldSyncWithCloudKit(let value):
                            Label("Sync", systemImage: "icloud")
                                .foregroundColor(value ? .primary : .secondary)
                        case .folderId(let id):
                            Label("Folder: \(id)", systemImage: "folder")
                        }
                    }
    }

    @ViewBuilder
    private func folderDetailView(folder: Folder) -> some View {
        FolderDetailView(folderIdString: folder.id.uuidString, isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId)
    }

    private func handleFolderDrop(items: [String], folder: Folder) -> Bool {
        guard let entryId = items.first else { return false }
        handleDrop(entryId: entryId, folder: folder)
        return true
    }

    private func updateTargetedState(for folder: Folder, isTargeted: Bool) {
        targeted[folder.id] = isTargeted
    }

    private func handleDrop(entryId: String, folder: Folder) {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", entryId)

        do {
            let results = try viewContext.fetch(fetchRequest)
            if let entry = results.first {
                entry.folderId = folder.id.uuidString
                try viewContext.save()
            }
        } catch {
            print("Failed to fetch Entry: \(error)")
        }
    }

    func getTextColor() -> Color {
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        let entryBackground = userPreferences.entryBackgroundColor
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

enum EntryDateFilters: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    
    var id: String { self.rawValue }
}

struct AllEntriesView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    
    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: false)],
        predicate: NSPredicate(format: "isRemoved == NO")
    ) var entries: FetchedResults<Entry>
    
    @State private var filterOption: EntryDateFilters = .day
    
    @Binding var isShowingReplyCreationView: Bool
    @Binding var replyEntryId: String?
    
    @ObservedObject var searchModel: SearchModel
    @Environment(\.isSearching) private var isSearching

    
    var body: some View {
        if isSearching {
            if searchModel.tokens.isEmpty && searchModel.searchText.isEmpty { //present possible tokens
                suggestedSearchView()
            } else {
                entriesListView()
            }
        } else {
            entriesListView()
        }
        
    }
    
    @ViewBuilder
        func entriesListView() -> some View {
            FilteredEntriesView(searchModel: searchModel, entryFilter: EntryFilter(searchText: $searchModel.searchText, filters: $searchModel.tokens), isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId)
                .environmentObject(userPreferences)
                .environmentObject(coreDataManager)
                .scrollContentBackground(.hidden)
                .listRowBackground(getSectionColor(colorScheme: colorScheme))
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
    
    @ViewBuilder
        func suggestedSearchView() -> some View {
            List {
                Section(header: Text("Suggested").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.5)) {
                    Button {
                        searchModel.tokens.append(.isHidden(true))
                    } label: {
                        HStack {
                            Image(systemName: "eye.fill")
                                .foregroundStyle(userPreferences.accentColor)
                                .padding(.horizontal, 5)
                            Text("Hidden Entries")
                                .foregroundStyle(getTextColor())
                        }
                    }
                    
                    Button {
                        searchModel.tokens.append(.hasMedia(true))
                    } label: {
                        HStack {
                            Image(systemName: "paperclip")
                                .foregroundStyle(userPreferences.accentColor)
                                .padding(.horizontal, 5)
                            
                            Text("Entries with Media")
                                .foregroundStyle(getTextColor())
                        }
                    }
                    
                    Button {
                        searchModel.tokens.append(.hasReminder(true))
                    } label: {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(userPreferences.accentColor)
                                .padding(.horizontal, 5)
                            
                            Text("Entries with Reminder")
                                .foregroundStyle(getTextColor())
                        }
                    }
                    
                    Button {
                        searchModel.tokens.append(.isPinned(true))
                    } label: {
                        HStack {
                            Image(systemName: "pin.fill")
                                .foregroundStyle(userPreferences.accentColor)
                                .padding(.horizontal, 5)
                            
                            Text("Pinned Entries")
                                .foregroundStyle(getTextColor())
                        }
                    }
                    
                    Button {
                        searchModel.tokens.append(.stampIcon(searchModel.searchText))
                    } label: {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .foregroundStyle(userPreferences.accentColor)
                                .padding(.horizontal, 5)
                            
                            Text("Stamp Icon Label")
                                .foregroundStyle(getTextColor())
                        }
                    }
                }
                .listRowBackground(getSectionColor(colorScheme: colorScheme))

            }
//            .background(userPreferences.backgroundView(colorScheme: colorScheme))

            .scrollContentBackground(.hidden)
        }
    
    private var groupedEntries: [Date: [Entry]] {
        Dictionary(grouping: entries, by: { entry in
            switch filterOption {
            case .day:
                return Calendar.current.startOfDay(for: entry.time )
            case .week:
                return Calendar.current.dateInterval(of: .weekOfYear, for: entry.time)?.start ?? Date()
            case .month:
                return Calendar.current.dateInterval(of: .month, for: entry.time )?.start ?? Date()
            }
        })
    }
    
    private func sectionHeader(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        switch filterOption {
        case .day:
            dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        case .week:
            dateFormatter.dateFormat = "'Week of' MMM d, yyyy"
        case .month:
            dateFormatter.dateFormat = "MMMM yyyy"
        }
        return dateFormatter.string(from: date)
    }
    
    func getSectionColor(colorScheme: ColorScheme) -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        } else {
            return userPreferences.entryBackgroundColor
        }
    }
}
