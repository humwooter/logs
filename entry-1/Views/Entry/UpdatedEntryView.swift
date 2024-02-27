//
//  UpdatedEntryView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 2/26/24.
//

import Foundation
import SwiftUI
import CoreData
import Speech
import AVFoundation
import Photos
import CoreHaptics
import PhotosUI
import FLAnimatedImage




struct NotEditingView: View {
    // data management objects
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @ObservedObject var entry: Entry

    // environment and view state
    @Environment(\.colorScheme) var colorScheme
    @State private var showEntry = true

    // editing state
    @Binding var isEditing: Bool
    @State private var cursorPosition: NSRange? = nil

    // media handling
    @State var currentMediaData: Data?
    @State private var isFullScreen = false
    @State private var selectedURL: URL? = nil

    var body : some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                entryHeaderView()
                entryTextView()
                entryMediaView()
            }
        }
    }
    
    @ViewBuilder
    func entryMediaView() -> some View {
        if entry.mediaFilename != "" {
            
            if let filename = entry.mediaFilename {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent(filename)
                let data = try? Data(contentsOf: fileURL)
            
                
                if let data = data, isGIF(data: data) {
                    let asyncImage = UIImage(data: data)
                    AnimatedImageView(url: fileURL).scaledToFit()
                        .blur(radius: entry.isHidden ? 10 : 0)
                        .quickLookPreview($selectedURL)
                        .onTapGesture {
                            selectedURL = fileURL
                        }
                    // Add imageView
                } else if let data, isPDF(data: data) {
                    VStack {
                            HStack {
                                Spacer()
                                Label("Expand PDF", systemImage: "arrow.up.left.and.arrow.down.right") .foregroundColor(Color(UIColor.foregroundColor(background: UIColor.blendedColor(from: UIColor(userPreferences.backgroundColors.first!), with: UIColor(userPreferences.entryBackgroundColor)))))
                                    .onTapGesture {
                                    isFullScreen.toggle()
                                }
                                .padding(.horizontal, 3)
                                .cornerRadius(20)
                            }

                       
                        AsyncPDFKitView(url: fileURL).scaledToFit()
                            .blur(radius: entry.isHidden ? 10 : 0)
                      
                    }

                } else {
                    if imageExists(at: fileURL) {
                        CustomAsyncImageView(url: fileURL).scaledToFit()
                            .blur(radius: entry.isHidden ? 10 : 0)
                            .quickLookPreview($selectedURL)
                            .onTapGesture {
                                selectedURL = fileURL
                            }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func entryHeaderView() -> some View {
        HStack {
            Spacer()
            
            Menu {
                Button(action: {
                    withAnimation {
                        isEditing = true
                    }
                }) {
                    Text("Edit")
                    Image(systemName: "pencil")
                        .foregroundColor(userPreferences.accentColor)
                }
                
                Button(action: {
                    UIPasteboard.general.string = entry.content
                }) {
                    Text("Copy Message")
                    Image(systemName: "doc.on.doc")
                }
                
                
                Button(action: {
                    withAnimation(.easeOut) {
                        showEntry.toggle()
                        entry.isHidden = !showEntry
                        coreDataManager.save(context: coreDataManager.viewContext)
                    }
                    
                }, label: {
                    Label(showEntry ? "Hide Entry" : "Unhide Entry", systemImage: showEntry ? "eye.slash.fill" : "eye.fill")
                })
                
                if let filename = entry.mediaFilename {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsDirectory.appendingPathComponent(filename)
                    if imageExists(at: fileURL) {
                        if let data =  getMediaData(fromFilename: filename) {
                            if isPDF(data: data) {
                            }
                            else {
                                let image = UIImage(data: data)!
                                Button(action: {
                                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                    let fileURL = documentsDirectory.appendingPathComponent(filename)
                                    
                                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                    
                                }, label: {
                                    Label("Save Image", systemImage: "photo.badge.arrow.down.fill")
                                })
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
            } label: {
                Image(systemName: "ellipsis").padding(.vertical, 3).padding(.leading, 5)
                    .font(.system(size: UIFont.systemFontSize+5)).fontWeight(.bold)
                    .onTapGesture {
                        vibration_medium.prepare()
                        vibration_medium.impactOccurred()
                    }
                
            }
            .foregroundColor(UIColor.foregroundColor(entry: entry, background: entry.color, userPreferences: userPreferences)).opacity(0.3)

            
        
        }
        .padding(.top, 5)
    }
    
    @ViewBuilder
    func entryTextView() -> some View {
        VStack {
            let foregroundColor = isClear(for: entry.color) ? UIColor(userPreferences.entryBackgroundColor) : entry.color
            let blendedBackgroundColors = UIColor.blendColors(foregroundColor: UIColor(userPreferences.backgroundColors[1].opacity(0.5) ?? Color.clear), backgroundColor: UIColor(userPreferences.backgroundColors[0] ?? Color.clear))
            let blendedColor = UIColor.blendColors(foregroundColor: foregroundColor, backgroundColor: UIColor(Color(blendedBackgroundColors).opacity(0.4)))
            let fontColor = UIColor.fontColor(backgroundColor: blendedColor)
            
            if (userPreferences.showLinks) {
        
                Text(makeAttributedString(from: entry.content))
                    .foregroundStyle(Color(fontColor))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading) // Full width with left alignment
                    .onAppear {
                        print("ENTRY COLOR IS: \( entry.color)")
                        print("isClear(for: entry.color): \(isClear(for: entry.color))")
                    }

            } else {
                Text(entry.content)
                    .frame(maxWidth: .infinity, alignment: .leading) // Full width with left alignment
                    .foregroundStyle(Color(fontColor))

            }
        }
            .fixedSize(horizontal: false, vertical: true) // Allow text to wrap vertically
            .padding(2)
            .padding(.vertical, 5)
            .lineSpacing(userPreferences.lineSpacing)
            .blur(radius: entry.isHidden ? 7 : 0)
            .shadow(radius: 0)
    }
}

struct EntryRowView: View {
    // data management
    @EnvironmentObject var coreDataManager: CoreDataManager
    @ObservedObject var entry: Entry

    // user interface state
    @State private var isShowingEntryCreationView = false
    @State private var selectedEntry: Entry?
    @State private var showDeleteAlert = false
    @State private var editingEntry: Entry?
    @State private var padding: CGFloat = 0.0

    // user preferences and environment settings
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme

    // haptic feedback engine
    @State private var engine: CHHapticEngine?

    
    
    var body: some View {
        if !entry.isFault {
            TextView(entry: entry)
                .environmentObject(userPreferences)
                .environmentObject(coreDataManager)
                .listRowBackground(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
                .padding(.bottom, padding)
                .swipeActions(edge: .leading) {
                    stampsRowView()
                }
        }
    }
    
    @ViewBuilder
    private func stampsRowView() -> some View {
        ForEach(0..<userPreferences.stamps.count, id: \.self) { index in
            if userPreferences.stamps[index].isActive {
                Button(action: {
                    withAnimation(.smooth) {
                        activateButton(entry: entry, index: index)
                    }
                }) {
                    Label("", systemImage: userPreferences.stamps[index].imageName)
                }
                .tint(userPreferences.stamps[index].color)
            }
        }
    }
    
    private func activateButton(entry: Entry, index: Int) {
        let mainContext = coreDataManager.viewContext
        mainContext.performAndWait {
            
            if (index == entry.stampIndex) {
                    entry.stampIndex = -1
                    entry.stampIcon = ""
                    entry.color = UIColor.clear
            }
            else {
                    entry.stampIndex = Int16(index)
                    entry.stampIcon = userPreferences.stamps[index].imageName
                    entry.color = UIColor(userPreferences.stamps[index].color)
            }

            do {
                try mainContext.save()
            } catch {
                print("Failed to save mainContext: \(error)")
            }
        }
    }
}

struct EntryView: View {
    
    // Core Data Management
    @EnvironmentObject var coreDataManager: CoreDataManager
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
        predicate: NSPredicate(format: "day == %@", formattedDate(Date()))
    ) var logs: FetchedResults<Log>
    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: true)],
        predicate: NSPredicate(format: "time >= %@ OR isPinned == true", Calendar.current.startOfDay(for: Date()) as NSDate)
    ) var entries: FetchedResults<Entry>
    
    // User Preferences and UI Settings
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    
    // Entry Management State
    @State private var selectedEntry: Entry?
    @State private var editingEntry: Entry?
    @State private var isShowingEntryCreationView = false
    @State private var showDeleteAlert = false
    @State private var showingDeleteConfirmation = false
    @State private var toBeDeleted: IndexSet?
    @State private var showingDeleteAlert = false
    @State private var refreshToggle = false
    
    // Date and Time
    @State private var currentDay: Date = Date()
    @State private var currentTime: Date = Date()
    @State var excludeStampedEntries: [Bool] = Array(repeating: false, count: 21)
    
    // Sorting and Custom UI Configuration
    @State private var selectedSortOption: SortOption = .timeAscending
    init(color: UIColor) {
        if !isClear(for: color) {
            let textColor = UIColor(UIColor.foregroundColor(background: color))
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: textColor]
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: textColor]
        }
        if isClear(for: color) {
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color("TextColor"))]
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color("TextColor"))]
        }
    }
    
    
    var body : some View {
        NavigationStack {
            List {
                if entries.count == 0 {
                    Section {
                        Text("No entries")
                    }
                    .refreshable(action: {
                        updateFetchRequests()
                    })
                } else {
                    sortedEntriesView()
                }
            }
            .background {
                backgroundView()
            }
            .scrollContentBackground(.hidden)
            .navigationTitle(entry_1.currentDate())
            
            .navigationBarItems(trailing:
                                    HStack {
                Button(action: {
                    isShowingEntryCreationView = true
                }, label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15))
                })
                
                sortedEntriesMenu()
            }
            )
            .refreshable(action: {
                updateFetchRequests()
            })
            .sheet(isPresented: $isShowingEntryCreationView) {
                NewEntryView()
                    .environmentObject(coreDataManager)
                    .environmentObject(userPreferences)
                    .foregroundColor(userPreferences.accentColor)
                    .presentationDragIndicator(.hidden)
            }
        }
    }
    
    func updateFetchRequests() {
        let currentDay = formattedDate(Date())
        print("current day: \(currentDay)")
        logs.nsPredicate = NSPredicate(format: "day == %@", currentDay)
        if let log = logs.first {
            entries.nsPredicate = NSPredicate(format: "relationship == %@ OR isPinned == true", log)
        }
        else {
            let newLog = Log(context: coreDataManager.viewContext)
            newLog.day = currentDay
            newLog.id = UUID()
            entries.nsPredicate = NSPredicate(format: "relationship == %@ OR isPinned == true", newLog)
        }
    }
    
    func deleteRow(at indexSet: IndexSet) {
        self.toBeDeleted = indexSet           // store rows for delete
        self.showingDeleteAlert = true
    }
    
    func deleteEntries(from indexSet: IndexSet, entries: [Entry]) {
        let mainContext = coreDataManager.viewContext
        mainContext.performAndWait {
            for index in indexSet {
                if index < entries.count {
                    let entryToDelete = entries[index]
                    let parentLog = entryToDelete.relationship
                    
                    // Fetch the entry in the main context
                    let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", entryToDelete.id as CVarArg)
                    
                    do {
                        let fetchedEntries = try mainContext.fetch(fetchRequest)
                        guard let entryToDeleteInContext = fetchedEntries.first else {
                            print("Failed to fetch entry in main context")
                            return
                        }
                        
                        print("Entry being removed: \(entryToDelete)")
                        
                        // Mark the entry as removed and detach it from the parent log
                        entryToDeleteInContext.isRemoved = true
                        parentLog.removeFromRelationship(entryToDeleteInContext)
                        
                        // Save changes
                        try mainContext.save()
                        
                    } catch {
                        print("Failed to fetch entry in main context: \(error)")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func sortedEntriesMenu() -> some View {
        Menu {
            
            Menu {
                ControlGroup {
                    Button(action: {
                        selectedSortOption = .timeAscending
                    }) {
                        VStack {
                            Text("Increasing")
                        }
                    }
                    Button(action: {
                        selectedSortOption = .timeDescending
                    }) {
                        VStack {
                            Text("Decreasing")
                        }
                    }
                } label: {
                    Text("Sort by Time")
                }
                
                Button(action: {
                    selectedSortOption = .image
                }) {
                    Text("Stamp Name")
                    Image(systemName: selectedSortOption == .image ? "checkmark" : "")
                }
                Button(action: {
                    selectedSortOption = .wordCount
                }) {
                    Text("Word Count")
                    Image(systemName: selectedSortOption == .wordCount ? "checkmark" : "")
                }
            } label: {
                Text("Sort")
            }
            
            Menu {
                ControlGroup {
                    Button(action: {
                        selectedSortOption = .isShown
                    }) {
                        Label("is Open", systemImage: "book.pages.fill")
                        Image(systemName: selectedSortOption == .isShown ? "checkmark" : "")
                    }
                    
                    Button(action: {
                        selectedSortOption = .isHidden
                    }) {
                        Label("is Shown", systemImage: "eye.fill")
                        Image(systemName: selectedSortOption == .isHidden ? "checkmark" : "")
                    }
                } label: {
                    Text("Filter by")
                }
            } label: {
                Text("Filter")
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size:13))
            
        }
    }
    
    
    @ViewBuilder
    func backgroundView() -> some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
            LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
        }
        .ignoresSafeArea()
    }
    @ViewBuilder
    func sortedEntriesView() -> some View {
        switch selectedSortOption {
        case .timeAscending:
            let sortedEntries = entries.sorted { $0.time > $1.time }
            
            ForEach(sortedEntries) { entry in
                if (!entry.isFault && !entry.isRemoved) {
                    EntryRowView(entry: entry)
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
                        .id("\(entry.id)")
                }
            }
            
            .onDelete { indexSet in
                deleteEntries(from: indexSet, entries: sortedEntries)
            }
        case .timeDescending:
            let sortedEntries = entries.sorted { $0.time < $1.time }
            ForEach(sortedEntries) { entry in
                if (!entry.isFault && !entry.isRemoved) {
                    EntryRowView(entry: entry)
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
                        .id("\(entry.id)")
                    
                }
            }
            
            .onDelete { indexSet in
                deleteEntries(from: indexSet, entries: sortedEntries)
            }
        case .image:
            let sortedEntries = entries.sorted { $0.stampIcon > $1.stampIcon }
            ForEach(sortedEntries) { entry in
                if (!entry.isFault && !entry.isRemoved) {
                    EntryRowView(entry: entry)
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
                        .id("\(entry.id)")
                    
                }
            }
            
            .onDelete { indexSet in
                deleteEntries(from: indexSet, entries: sortedEntries)
            }
        case .wordCount:
            let sortedEntries = entries.sorted { $0.content.count > $1.content.count }
            ForEach(sortedEntries) { entry in
                if (!entry.isFault && !entry.isRemoved) {
                    EntryRowView(entry: entry)
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
                        .id("\(entry.id)")
                    
                }
            }
            
            .onDelete { indexSet in
                deleteEntries(from: indexSet, entries: sortedEntries)
            }
            
        case .isShown:
            let sortedEntries = entries.filter { $0.isShown }.sorted { $0.time > $1.time }
            
            ForEach(sortedEntries) { entry in
                if (!entry.isFault && !entry.isRemoved) {
                    EntryRowView(entry: entry)
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
                        .id("\(entry.id)")
                }
            }
            
            .onDelete { indexSet in
                deleteEntries(from: indexSet, entries: sortedEntries)
            }
        case .isHidden:
            let sortedEntries = entries.filter { $0.isHidden == false }.sorted { $0.time > $1.time }
            
            ForEach(sortedEntries) { entry in
                if (!entry.isFault && !entry.isRemoved) {
                    EntryRowView(entry: entry)
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
                        .id("\(entry.id)")
                }
            }
            
            .onDelete { indexSet in
                deleteEntries(from: indexSet, entries: sortedEntries)
            }
        }
    }
    
}
