//
//
//
//import Foundation
//import SwiftUI
//import CoreData
//import Speech
//import AVFoundation
//import Photos
//import CoreHaptics
//import PhotosUI
//import FLAnimatedImage
//
//
//struct EntriesView: View {
//    @ObservedObject var log: Log
//    @EnvironmentObject var userPreferences: UserPreferences
//    @EnvironmentObject var coreDataManager: CoreDataManager
//    @State private var editingEntry: Entry?
//    @State var selectedSortOption: SortOption
//    
//    
//    var body : some View {
//        NavigationStack {
//            List {
//                switch selectedSortOption {
//                case .timeAscending:
//                    @FetchRequest(
//                        entity: Entry.entity(),
//                        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: true)],
//                        predicate: NSPredicate(format: "relationship == %@", log)
//                    ) var sortedEntries: FetchedResults<Entry>
//                    
//                    ForEach(sortedEntries) { entry in
//                        if (!entry.isFault && formattedDate(entry.time) == formattedDate(Date())) {
//                            EntryRowView(entry: entry)
//                                .environmentObject(userPreferences)
//                                .environmentObject(coreDataManager)
//                                .id("\(entry.id)")
//                        }
//                    }
//                    
//                    .onDelete { indexSet in
//                        deleteEntries(from: indexSet, entries: sortedEntries)
//                    }
//                    
//                case .timeDescending:
//                    @FetchRequest(
//                        entity: Entry.entity(),
//                        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: false)],
//                        predicate: NSPredicate(format: "relationship == %@", log)
//                    ) var sortedEntries: FetchedResults<Entry>
//                    
//                    ForEach(sortedEntries) { entry in
//                        if (!entry.isFault && formattedDate(entry.time) == formattedDate(Date())) {
//                            EntryRowView(entry: entry)
//                                .environmentObject(userPreferences)
//                                .environmentObject(coreDataManager)
//                                .id("\(entry.id)")
//                        }
//                    }
//                    
//                    .onDelete { indexSet in
//                        deleteEntries(from: indexSet, entries: sortedEntries)
//                    }
//                case .image:
//                    @FetchRequest(
//                        entity: Entry.entity(),
//                        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.image, ascending: true)],
//                        predicate: NSPredicate(format: "relationship == %@", log)
//                    ) var sortedEntries: FetchedResults<Entry>
//                    
//                    ForEach(sortedEntries) { entry in
//                        if (!entry.isFault && formattedDate(entry.time) == formattedDate(Date())) {
//                            EntryRowView(entry: entry)
//                                .environmentObject(userPreferences)
//                                .environmentObject(coreDataManager)
//                                .id("\(entry.id)")
//                        }
//                    }
//                    
//                    .onDelete { indexSet in
//                        deleteEntries(from: indexSet, entries: sortedEntries)
//                    }
//                case .wordCount:
//                    @FetchRequest(
//                        entity: Entry.entity(),
//                        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.content.count, ascending: true)],
//                        predicate: NSPredicate(format: "relationship == %@", log)
//                    ) var sortedEntries: FetchedResults<Entry>
//                    
//                    ForEach(sortedEntries) { entry in
//                        if (!entry.isFault && formattedDate(entry.time) == formattedDate(Date())) {
//                            EntryRowView(entry: entry)
//                                .environmentObject(userPreferences)
//                                .environmentObject(coreDataManager)
//                                .id("\(entry.id)")
//                        }
//                    }
//                    
//                    .onDelete { indexSet in
//                        deleteEntries(from: indexSet, entries: sortedEntries)
//                    }
//                    
//                }
//            }
//        }
//    }
//    func deleteEntries(from indexSet: IndexSet, entries: FetchedResults<Entry>) {
//        let mainContext = coreDataManager.viewContext
//        mainContext.performAndWait {
//            for index in indexSet {
//                // Ensure the index is within the range of the entries
//                if entries.indices.contains(index) {
//                    let entryToDelete = entries[index]
//                    let parentLog = entryToDelete.relationship
//                    
//                    // Fetch the entry in the main context
//                    let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//                    fetchRequest.predicate = NSPredicate(format: "id == %@", entryToDelete.id as CVarArg)
//                    
//                    do {
//                        let fetchedEntries = try mainContext.fetch(fetchRequest)
//                        guard let entryToDeleteInContext = fetchedEntries.first else {
//                            print("Failed to fetch entry in main context")
//                            return
//                        }
//                        
//                        print("Entry being removed: \(entryToDelete)")
//                        
//                        // Mark the entry as removed and detach it from the parent log
//                        entryToDeleteInContext.isRemoved = true
//                        parentLog.removeFromRelationship(entryToDeleteInContext)
//                        
//                        // Save changes
//                        try mainContext.save()
//                        
//                    } catch {
//                        print("Failed to fetch entry in main context: \(error)")
//                    }
//                }
//            }
//        }
//    }
//
//}
//
//
//
//
//
//////
//////  EntryViews.swift
//////  entry-1
//////
//////  Created by Katya Raman on 8/14/23.
//////
////
////import Foundation
////import SwiftUI
////import CoreData
////import Speech
////import AVFoundation
////import Photos
////import CoreHaptics
////import PhotosUI
////import FLAnimatedImage
//////import SwiftyGif
//////import Giffy
////
////
////
////
////
////class DayChange: ObservableObject {
////    @Published var dayChanged = false
////    init() {
////        NotificationCenter.default.addObserver(self, selector: #selector(dayDidChange), name: .NSCalendarDayChanged, object: nil)
////    }
////    @objc func dayDidChange() {
////        dayChanged.toggle()
////    }
////}
////
////
////class MarkedEntries: ObservableObject {
////    @Published var button_entries: [Set<Entry>] = [[], [], [], [], [], [], []]
////    
////}
////
////class Refresh: ObservableObject {
////    @Published var needsRefresh: Bool = false
////}
////
////struct TextView : View {
////    @ObservedObject private var refresh: Refresh = Refresh()
////    // @Environment(\.managedObjectContext) private var viewContext
////    @EnvironmentObject var coreDataManager: CoreDataManager
////    
////    @EnvironmentObject var userPreferences: UserPreferences
////    @ObservedObject var entry : Entry
////    
////    @State private var editingContent : String = ""
////    @State private var isEditing : Bool = false
////    
////    @State private var engine: CHHapticEngine?
////    @FocusState private var focusField: Bool
////    @Environment(\.colorScheme) var colorScheme
////    @State private var selectedItem : PhotosPickerItem?
////    @State private var showingDeleteConfirmation = false
////    
////    @State private var selectedImage : UIImage?
////    
////    @State private var showPhotos = false
////    @State private var selectedData: Data?
////    @State private var showCamera = false
////    @State private var shareImage: UIImage? = nil
////    
////    
////    
////    var body : some View {
////        
////        if (!entry.isFault) {
////            Section {
////                if (entry.isShown) {
////                    
////                    NotEditingView(entry: entry).environmentObject(userPreferences)
////                        .contextMenu {
////                            Button(action: {
////                                withAnimation {
////                                    isEditing = true
////                                }
////                            }) {
////                                Text("Edit")
////                                Image(systemName: "pencil")
////                                    .foregroundColor(userPreferences.accentColor)
////                            }
////                            
////                            Button(action: {
////                                UIPasteboard.general.string = entry.content ?? ""
////                            }) {
////                                Text("Copy Message")
////                                Image(systemName: "doc.on.doc")
////                            }
////                            
////                            
////                            
////                        }
////                    
////                    
////                    
////                        .onChange(of: isEditing) { newValue in
////                            if newValue {
////                                editingContent = entry.content
////                            }
////                        }
////                        .sheet(isPresented: $isEditing) {
////                            EditingEntryView(entry: entry, editingContent: $editingContent, isEditing: $isEditing)
////                                .foregroundColor(userPreferences.accentColor)
////                        }
////                }
////            } header: {
////                HStack {
////                    Text("\(formattedTime(time: entry.time))").font(.system(size: UIFont.systemFontSize))
////                     
////                    Spacer()
////                    Label("", systemImage: entry.isShown ? "chevron.up" : "chevron.down").foregroundColor(userPreferences.accentColor).font(.system(size: UIFont.systemFontSize))
////                        .contentTransition(.symbolEffect(.replace.offUp))
////
////                        .onTapGesture {
////                            vibration_medium.impactOccurred()
////                            withAnimation(.easeInOut(duration: 5.0)) {
////                                entry.isShown.toggle()
////                            }
////                        }
////                }
////            } 
////
//////            Section(header: Text(formattedTime(time: entry.time)).font(.system(size: UIFont.systemFontSize))) {
//////                if (entry.isShown) {
//////                    
//////                    NotEditingView(entry: entry).environmentObject(userPreferences)
//////                        .contextMenu {
//////                            Button(action: {
//////                                withAnimation {
//////                                    isEditing = true
//////                                }
//////                            }) {
//////                                Text("Edit")
//////                                Image(systemName: "pencil")
//////                                    .foregroundColor(userPreferences.accentColor)
//////                            }
//////                            
//////                            Button(action: {
//////                                UIPasteboard.general.string = entry.content ?? ""
//////                            }) {
//////                                Text("Copy Message")
//////                                Image(systemName: "doc.on.doc")
//////                            }
//////                            
//////                            
//////                            
//////                        }
//////                    
//////                    
//////                    
//////                        .onChange(of: isEditing) { newValue in
//////                            if newValue {
//////                                editingContent = entry.content
//////                            }
//////                        }
//////                        .sheet(isPresented: $isEditing) {
//////                            EditingEntryView(entry: entry, editingContent: $editingContent, isEditing: $isEditing)
//////                                .foregroundColor(userPreferences.accentColor)
//////                        }
//////                }
//////                        
//////            }
////
////
////
////        }
////        
////    }
////    
////    func deleteEntry(entry: Entry) {
////        let mainContext = coreDataManager.viewContext
////        mainContext.performAndWait {
////            let filename = entry.imageContent
////            let parentLog = entry.relationship
////            
////            
////            // Fetch the entry in the main context
////            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
////            fetchRequest.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
////            do {
////                let fetchedEntries = try mainContext.fetch(fetchRequest)
////                guard let entryToDeleteInContext = fetchedEntries.first else {
////                    print("Failed to fetch entry in main context")
////                    return
////                }
////                
////                print("Entry being deleted: \(entryToDeleteInContext)")
////  
////                parentLog.removeFromRelationship(entry)
////                entryToDeleteInContext.isRemoved = true
////                try mainContext.save()
////                
////            } catch {
////                print("Failed to fetch entry in main context: \(error)")
////            }
////        }
////    }
////    
////    func hideEntry () {
////        if entry.isHidden == nil {
////            entry.isHidden = false
////        }
////        entry.isHidden.toggle()
////    }
////    
////    func finalizeEdit() {
////        // Code to finalize the edit
////        let mainContext = coreDataManager.viewContext
////        mainContext.performAndWait {
////            entry.content = editingContent
////            
////            // Save the context
////            coreDataManager.save(context: mainContext)
////        }
////        isEditing = false
////    }
////    
////    
////    func cancelEdit() {
////        editingContent = entry.content // Reset to the original content
////        isEditing = false // Exit the editing mode
////    }
////    
////    
////}
////
////struct EntryRowView: View {
////    @EnvironmentObject var coreDataManager: CoreDataManager
////    @ObservedObject var entry: Entry
////    
////    @State private var isShowingEntryCreationView = false
////    
////    @ObservedObject var markedEntries = MarkedEntries()
////    @EnvironmentObject var userPreferences: UserPreferences
////    @Environment(\.colorScheme) var colorScheme
////    @State private var selectedEntry: Entry?
////    @State private var showDeleteAlert = false
////    @State private var editingEntry: Entry?
////    @State private var padding: CGFloat = 2.0
////
////    
////    @State private var engine: CHHapticEngine?
////    
////    var body : some View {
////        if (!entry.isFault) {
////         
////           
////                TextView(entry: entry)
////                
////                    .environmentObject(userPreferences)
////                    .environmentObject(coreDataManager)
////                    .listRowBackground(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
////                    .padding(.vertical, padding)
////                
////                    .swipeActions(edge: .leading) {
////                        ForEach(0..<userPreferences.stamps.count, id: \.self) { index in
////                            if userPreferences.stamps[index].isActive {
////                                Button(action: {
////                                    withAnimation {
////                                        activateButton(entry: entry, index: index)
////                                    }
////                                }) {
////                                    Label("", systemImage: userPreferences.stamps[index].imageName)
////                                }
////                                .tint(userPreferences.stamps[index].color)
////                            }
////                        }
////                    }
////
////        }
////        
////        
////        else {
////            ProgressView()
////        }
////        
////    }
////    
////    
////    
////    private func activateButton(entry: Entry, index: Int) {
////        let mainContext = coreDataManager.viewContext
////        mainContext.performAndWait {
////            
////            if (index == entry.stampIndex) {
////                withAnimation {
////                    entry.stampIndex = -1
////                    entry.image = ""
////                    entry.color = UIColor.tertiarySystemBackground
////                }
////            }
////            else {
////                withAnimation {
////                    entry.stampIndex = Int16(index)
////                    entry.image = userPreferences.stamps[index].imageName
////                    entry.color = UIColor(userPreferences.stamps[index].color)
////                }
////            }
////
////            // Save the context
////            do {
////                try mainContext.save()
////            } catch {
////                print("Failed to save mainContext: \(error)")
////            }
////
////            if userPreferences.stamps[index].isActive {
////                markedEntries.button_entries[index].insert(entry)
////            } else {
////                entry.color = UIColor.tertiarySystemBackground
////                markedEntries.button_entries[index].remove(entry)
////            }
////
////        }
////    }
////
////}
////
////
////
////
////struct EntryView: View {
////    @EnvironmentObject var coreDataManager: CoreDataManager
////    @State private var currentDateFilter = Date.formattedDate(time: Date())
////    
////    @State private var isShowingEntryCreationView = false
////    
////    @ObservedObject var markedEntries = MarkedEntries()
////    @EnvironmentObject var userPreferences: UserPreferences
////    @Environment(\.colorScheme) var colorScheme
////    @State private var selectedEntry: Entry?
////    @State private var showDeleteAlert = false
////    @State private var showingDeleteConfirmation = false
////    
////    @State private var editingEntry: Entry?
////    
////    let vibration_heavy = UIImpactFeedbackGenerator(style: .heavy)
////    let vibration_light = UIImpactFeedbackGenerator(style: .light)
////    @State private var engine: CHHapticEngine?
////    @State private var toBeDeleted: IndexSet?
////    @State private var showingDeleteAlert = false
////    @State private var refreshToggle = false
////    
////    @State private var currentDay: Date = Date()
////
////    @FetchRequest(
////           entity: Log.entity(),
////           sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
////           predicate: NSPredicate(format: "day == %@", formattedDate(Date()))
////       ) var logs: FetchedResults<Log>
////    
////    @FetchRequest(
////        entity: Entry.entity(),
////        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: true)]
////    ) var entries: FetchedResults<Entry>
////    
////    
////    @State private var selectedSortOption: SortOption = .timeAscending
////    
////    
////    var body: some View {
////        
////        NavigationStack {
////            List {
////                
////                if let log = logs.first, log.relationship.count > 0, log.day == formattedDate(Date()) {
////                    switch selectedSortOption {
////                    case .timeAscending:
////                        let sortedEntries = entries.filter { $0.relationship == log }.sorted { $0.time > $1.time }
////               
////                        ForEach(entries.filter { $0.relationship == log }.sorted { $0.time > $1.time }) { entry in
//////                      
//////                                Button(action: {
//////                                    withAnimation(.smooth) {
//////                                        if (entry.isShown == nil) {
//////                                            entry.isShown = false
//////                                        }
//////                                        entry.isShown.toggle()
//////                                    }
//////                                }, label: {
//////                                    Label("", systemImage: entry.isShown ? "chevron.up" : "chevron.down")
//////                                }).frame(width: 10, height: 10)
////                            if (!entry.isFault && formattedDate(entry.time) == formattedDate(Date())) {
////             
//////                                if (entry.isShown) {
////                                    EntryRowView(entry: entry)
////                                        .environmentObject(userPreferences)
////                                        .environmentObject(coreDataManager)
////                                        .id("\(entry.id)")
//////                                }
////                            }
////                        }
////                        
////                        .onDelete { indexSet in
////                            deleteEntries(from: indexSet, entries: sortedEntries)
////                        }
////                    case .timeDescending:
////                        let sortedEntries = entries.filter { $0.relationship == log }.sorted { $0.time < $1.time }
////                        ForEach(sortedEntries) { entry in
////                            if (!entry.isFault && formattedDate(entry.time) == formattedDate(Date())) {
////                                EntryRowView(entry: entry)
////                                    .environmentObject(userPreferences)
////                                    .environmentObject(coreDataManager)
////                                    .id("\(entry.id)")
////                            }
////                        }
////                        
////                        .onDelete { indexSet in
////                            deleteEntries(from: indexSet, entries: sortedEntries)
////                        }
////                    case .image:
////                        let sortedEntries = entries.filter { $0.relationship == log }.sorted { $0.image > $1.image }
////                        ForEach(sortedEntries) { entry in
////                            if (!entry.isFault && formattedDate(entry.time) == formattedDate(Date())) {
////                                EntryRowView(entry: entry)
////                                    .environmentObject(userPreferences)
////                                    .environmentObject(coreDataManager)
////                                    .id("\(entry.id)")
////                            }
////                        }
////                        
////                        .onDelete { indexSet in
////                            deleteEntries(from: indexSet, entries: sortedEntries)
////                        }
////                    case .wordCount:
////                        let sortedEntries = entries.filter { $0.relationship == log }.sorted { $0.content.count > $1.content.count }
////                        ForEach(sortedEntries) { entry in
////                            if (!entry.isFault && formattedDate(entry.time) == formattedDate(Date())) {
////                                EntryRowView(entry: entry)
////                                    .environmentObject(userPreferences)
////                                    .environmentObject(coreDataManager)
////                                    .id("\(entry.id)")
////                            }
////                        }
////                        
////                        .onDelete { indexSet in
////                            deleteEntries(from: indexSet, entries: sortedEntries)
////                        }
////                    }
////              
////                    
////                    
////                    
////                }
////                else {
////                    Text("No entries")
////                        .foregroundColor(.gray)
////                        .italic()
////                        .onAppear {
////                            updateFetchRequests()
////                        }
////                    if let log = logs.first {
////                        if (log.day != formattedDate(Date())) {
////                            ProgressView()
////                    
////                            
////                        }
////                    }
////                    
////                }
////                
////            }
////
////            .onAppear(perform: {
////                updateFetchRequests()
////
////            })
////    
////
//////            .refreshable {
//////                updateFetchRequests()
//////            }
////            
////            .navigationTitle(entry_1.currentDate())
////            .navigationBarItems(trailing:
////                                    Button(action: {
////                isShowingEntryCreationView = true
////            }, label: {
////                Image(systemName: "plus")
////                    .font(.system(size: 15))
////            })
////            )
////            .navigationBarItems(trailing:
////                                    Menu {
////                Button(action: {
////                    selectedSortOption = .timeAscending
////                }) {
////                    Text("Time Ascending")
////                    Image(systemName: selectedSortOption == .timeAscending ? "checkmark" : "")
////                }
////                
////                Button(action: {
////                    selectedSortOption = .timeDescending
////                }) {
////                    Text("Time Descending")
////                    Image(systemName: selectedSortOption == .timeDescending ? "checkmark" : "")
////                }
////                
////                Button(action: {
////                    selectedSortOption = .image
////                }) {
////                    Text("Stamp Name")
////                    Image(systemName: selectedSortOption == .image ? "checkmark" : "")
////                }
////                Button(action: {
////                    selectedSortOption = .wordCount
////                }) {
////                    Text("Word Count")
////                    Image(systemName: selectedSortOption == .wordCount ? "checkmark" : "")
////                }
////            } label: {
//////                                    Image(systemName: "line.3.horizontal.circle.fill")
////                Image(systemName: "arrow.up.arrow.down")
////                    .font(.system(size:13))
////                
////            }
////            )
////            
////            .sheet(isPresented: $isShowingEntryCreationView) {
////                NewEntryView()
////                    .environmentObject(coreDataManager)
////                    .environmentObject(userPreferences)
////                    .foregroundColor(userPreferences.accentColor)
////                
////            }
////            
////        }
////        
////    }
////    
////    
//////    private func sortEntries(by option: SortOption, entries: FetchedResults<Entry>) {
//////        if let log = logs.first, log.relationship.count > 0 {
//////            switch option {
//////            case .timeAscending:
//////                sortedEntries = entries.filter { $0.relationship == log }.sorted { $0.time > $1.time }
//////            case .timeDescending:
//////                sortedEntries = entries.filter { $0.relationship == log }.sorted { $0.time < $1.time }
//////            case .image:
//////                sortedEntries = entries.filter { $0.relationship == log }
//////                // Implement the sorting by image if needed
//////            case .wordCount:
//////                sortedEntries = entries.filter { $0.relationship == log }
//////                // Implement the sorting by word count if needed
//////            }
//////        } else {
//////            sortedEntries = []
//////        }
//////    }
////    
////    
////    func updateFetchRequests() {
////        let currentDay = formattedDate(Date())
////        logs.nsPredicate = NSPredicate(format: "day == %@", currentDay)
////        if let log = logs.first {
////            entries.nsPredicate = NSPredicate(format: "relationship == %@", log)
////        }
////    }
////    
////    func deleteRow(at indexSet: IndexSet) {
////        self.toBeDeleted = indexSet           // store rows for delete
////        self.showingDeleteAlert = true
////    }
////    
////    func deleteEntries(from indexSet: IndexSet, entries: [Entry]) {
////        let mainContext = coreDataManager.viewContext
////        mainContext.performAndWait {
////            for index in indexSet {
////                if index < entries.count {
////                    let entryToDelete = entries[index]
////                    let parentLog = entryToDelete.relationship
////                    
////                    // Fetch the entry in the main context
////                    let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
////                    fetchRequest.predicate = NSPredicate(format: "id == %@", entryToDelete.id as CVarArg)
////                    
////                    do {
////                        let fetchedEntries = try mainContext.fetch(fetchRequest)
////                        guard let entryToDeleteInContext = fetchedEntries.first else {
////                            print("Failed to fetch entry in main context")
////                            return
////                        }
////                        
////                        print("Entry being removed: \(entryToDelete)")
////                        
////                        // Mark the entry as removed and detach it from the parent log
////                        entryToDeleteInContext.isRemoved = true
////                        parentLog.removeFromRelationship(entryToDeleteInContext)
////                        
////                        // Save changes
////                        try mainContext.save()
////                        
////                    } catch {
////                        print("Failed to fetch entry in main context: \(error)")
////                    }
////                }
////            }
////        }
////    }
////    
////    
////    private func fetchMarkedEntries() { //fetches important entries before loading the view
////        let mainContext = coreDataManager.viewContext
////        mainContext.perform {
////            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
////            for index in 0..<5 {
////                fetchRequest.predicate = NSPredicate(format: "buttons[%d] == %@", index, NSNumber(value: true))
////                do {
////                    let entriesArray = try mainContext.fetch(fetchRequest)
////                    markedEntries.button_entries[index] = Set(entriesArray)
////                } catch {
////                    print("Error fetching marked entries: \(error)")
////                }
////            }
////        }
////    }
////    
////    
////    @ViewBuilder
////    private func validateDate() -> some View {
////        if currentDateFilter != formattedDate(Date()) {
////            Button("Refresh") {
////                currentDateFilter = formattedDate(Date())
////            }
////        }
////    }
////    
////    
////    func check_files() {
////        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
////        do {
////            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
////            for fileURL in fileURLs {
////                print(fileURL)
////            }
////        } catch {
////            print("Error while enumerating files \(documentsDirectory.path): \(error.localizedDescription)")
////        }
////    }
////}
////
////
////
////
