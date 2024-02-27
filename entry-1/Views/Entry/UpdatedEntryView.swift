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
