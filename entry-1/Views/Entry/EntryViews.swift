//
//  EntryViews.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
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
//import SwiftyGif
//import Giffy



class DayChange: ObservableObject {
    @Published var dayChanged = false
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(dayDidChange), name: .NSCalendarDayChanged, object: nil)
    }
    @objc func dayDidChange() {
        dayChanged.toggle()
    }
}


class MarkedEntries: ObservableObject {
    @Published var button_entries: [Set<Entry>] = [[], [], [], [], [], [], []]
    
}

class Refresh: ObservableObject {
    @Published var needsRefresh: Bool = false
}

struct TextView : View {
    @ObservedObject private var refresh: Refresh = Refresh()
    // @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var coreDataManager: CoreDataManager
    
    @EnvironmentObject var userPreferences: UserPreferences
    @ObservedObject var entry : Entry
    
    @State private var editingContent : String = ""
    @State private var isEditing : Bool = false
    
    @State private var engine: CHHapticEngine?
    @FocusState private var focusField: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedItem : PhotosPickerItem?
    @State private var showingDeleteConfirmation = false
    
    @State private var selectedImage : UIImage?
    
    @State private var showPhotos = false
    @State private var selectedData: Data?
    @State private var showCamera = false
    @State private var shareImage: UIImage? = nil

    
    var body : some View {
        if (!entry.isFault) {
            Section(header: Text(formattedTime(time: entry.time)).font(.system(size: UIFont.systemFontSize))) {
                VStack {
                    //                    if !isEditing {
                    NotEditingView(entry: entry).environmentObject(userPreferences)
                        .contextMenu {
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
                                UIPasteboard.general.string = entry.content ?? ""
                            }) {
                                Text("Copy Message")
                                Image(systemName: "doc.on.doc")
                            }
                            
//                            Button(role: .destructive, action: {
//                             showingDeleteConfirmation = true
//                            }) {
//                                Text("Delete")
//                                Image(systemName: "trash")
//                                    .foregroundColor(.red)
//                            }
                            
//                            Button {
//                                shareImage = (EntryDetailView_PDF(entry: entry).environmentObject(coreDataManager).environmentObject(userPreferences)).capture()
//                            } label: {
//                                Label("Share Entry", systemImage: "square.and.arrow.up")
//                            }
                            
                        }
//                    if let imageToShare = shareImage {
//                        
//                        ShareLink(items: [imageToShare])
//                    
//                             }
                    
                    
//                        .alert(isPresented: $showingDeleteConfirmation) {
//                            Alert(title: Text("Delete entry"),
//                                  message: Text("Are you sure you want to delete this entry? This action cannot be undone."),
//                                  primaryButton: .destructive(Text("Delete")) {
//                                deleteEntry(entry: entry)
//
//                            },
//                                  secondaryButton: .cancel())
//                        }

                }
                .onChange(of: isEditing) { newValue in
                    if newValue {
                        editingContent = entry.content
                    }
                }
                .sheet(isPresented: $isEditing) {
                    EditingEntryView(entry: entry, editingContent: $editingContent, isEditing: $isEditing)
                        .foregroundColor(userPreferences.accentColor)
                }
                
                
            }
        }
    }
    
    func deleteEntry(entry: Entry) {
        let mainContext = coreDataManager.viewContext
        mainContext.performAndWait {
            let filename = entry.imageContent
            let parentLog = entry.relationship
            
            
            // Fetch the entry in the main context
            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
            do {
                let fetchedEntries = try mainContext.fetch(fetchRequest)
                guard let entryToDeleteInContext = fetchedEntries.first else {
                    print("Failed to fetch entry in main context")
                    return
                }
                
                print("Entry being deleted: \(entryToDeleteInContext)")
                // Now perform the deletion
                
//                if imageExists(at: URL.documentsDirectory.appendingPathComponent(entry.imageContent!)) {
//                    entry.deleteImage(coreDataManager: coreDataManager)
//                }
//
//                parentLog.removeFromRelationship(entryToDeleteInContext)
//                mainContext.delete(entryToDeleteInContext)
//                try mainContext.save()
                
                parentLog.removeFromRelationship(entry)
                entryToDeleteInContext.isRemoved = true
                try mainContext.save()
                
            } catch {
                print("Failed to fetch entry in main context: \(error)")
            }
        }
    }
    
    func hideEntry () {
        if entry.isHidden == nil {
            entry.isHidden = false
        }
        entry.isHidden.toggle()
    }
    
    func finalizeEdit() {
        // Code to finalize the edit
        let mainContext = coreDataManager.viewContext
        mainContext.performAndWait {
            entry.content = editingContent
            
            // Save the context
            coreDataManager.save(context: mainContext)
        }
        isEditing = false
    }
    
    
    func cancelEdit() {
        editingContent = entry.content // Reset to the original content
        isEditing = false // Exit the editing mode
    }
    
    
}

struct EntryRowView: View {
    // @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var coreDataManager: CoreDataManager
    @ObservedObject var entry: Entry
    
    @State private var isShowingEntryCreationView = false
    
    @ObservedObject var markedEntries = MarkedEntries()
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedEntry: Entry?
    @State private var showDeleteAlert = false
    @State private var editingEntry: Entry?
    
    
    @State private var engine: CHHapticEngine?
    //        @State private var editingContent = ""
    
    
    var body : some View {
        if (!entry.isFault) {
            
            TextView(entry: entry)
            
                .environmentObject(userPreferences)
                .environmentObject(coreDataManager)
                .listRowBackground(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
                .padding(.vertical, 2)

                .swipeActions(edge: .leading) {
                    ForEach(0..<userPreferences.stamps.count, id: \.self) { index in
                        if userPreferences.stamps[index].isActive {
                            Button(action: {
                                activateButton(entry: entry, index: index)
                            }) {
                                Label("", systemImage: userPreferences.stamps[index].imageName)
                            }
                            .tint(userPreferences.stamps[index].color)
                        }
                    }
                }

        }
        
        
        else {
            ProgressView()
        }
        
    }
    
    
    
    private func activateButton(entry: Entry, index: Int) {
        let mainContext = coreDataManager.viewContext
        mainContext.performAndWait {
//            let val : Bool = userPreferences.stamps[index].isActive
            
            
            if (index == entry.stampIndex) {
                withAnimation {
                    entry.stampIndex = -1
                    entry.image = ""
                    entry.color = UIColor.tertiarySystemBackground
                }
            }
            else {
                entry.stampIndex = Int16(index)
                entry.image = userPreferences.stamps[index].imageName
                entry.color = UIColor(userPreferences.stamps[index].color)
            }

            // Save the context
            do {
                try mainContext.save()
            } catch {
                print("Failed to save mainContext: \(error)")
            }

            if userPreferences.stamps[index].isActive {
                markedEntries.button_entries[index].insert(entry)
            } else {
                entry.color = UIColor.tertiarySystemBackground
                markedEntries.button_entries[index].remove(entry)
            }

        }
    }

}



struct EntryView: View {
    // @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var currentDateFilter = Date.formattedDate(time: Date())
    
    
    @State private var isShowingEntryCreationView = false
    
    @ObservedObject var markedEntries = MarkedEntries()
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedEntry: Entry?
    @State private var showDeleteAlert = false
    //    @State private var entryToDelete: Entry?
    @State private var showingDeleteConfirmation = false
    
    @State private var editingEntry: Entry?
    //        @State private var isEditing = false
    
    let vibration_heavy = UIImpactFeedbackGenerator(style: .heavy)
    let vibration_light = UIImpactFeedbackGenerator(style: .light)
    @State private var engine: CHHapticEngine?
    @State private var toBeDeleted: IndexSet?
    @State private var showingDeleteAlert = false
    @State private var refreshToggle = false
    
    @State private var currentDay: Date = Date()

    @FetchRequest(
           entity: Log.entity(),
           sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
           predicate: NSPredicate(format: "day == %@", formattedDate(Date()))
       ) var logs: FetchedResults<Log>
    
    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: true)]
    ) var entries: FetchedResults<Entry>
    


    @ObservedObject var dayChange = DayChange()
//    var currentDate: String = formattedDate(Date())
    

    enum SortOption {
        case timeAscending
        case timeDescending
        case image
        case wordCount
    }
    
    @State private var selectedSortOption: SortOption = .timeAscending
    @State var sortedEntries: [Entry] = []
    
    
    var body: some View {
        
        NavigationView {
            List {
                
                if let log = logs.first, log.relationship.count > 0 {
                    ForEach(sortedEntries) { entry in
                        if (!entry.isFault) {
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
                else {
                    Text("No entries")
                        .foregroundColor(.gray)
                        .italic()
                }
                
            }
            .onChange(of: selectedSortOption) { newValue in
                sortEntries(by: newValue)
            }
            .onAppear(perform: {
                sortEntries(by: .timeAscending)
            })
  
            .onChange(of: dayChange.dayChanged) { _ in
                _ = $logs.wrappedValue
                _ = $entries.wrappedValue
                sortEntries(by: selectedSortOption)
            }
   
            
            .navigationTitle(entry_1.currentDate())
            .navigationBarItems(trailing:
                                    Button(action: {
                isShowingEntryCreationView = true
            }, label: {
                Image(systemName: "plus")
                    .font(.system(size: 15))
            })
            )
            .navigationBarItems(trailing:
                                    Menu {
                Button(action: {
                    selectedSortOption = .timeAscending
                }) {
                    Text("Time Ascending")
                    Image(systemName: selectedSortOption == .timeAscending ? "checkmark" : "")
                }
                
                Button(action: {
                    selectedSortOption = .timeDescending
                }) {
                    Text("Time Descending")
                    Image(systemName: selectedSortOption == .timeDescending ? "checkmark" : "")
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
//                                    Image(systemName: "line.3.horizontal.circle.fill")
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size:13))
                
            }
            )
            
            .sheet(isPresented: $isShowingEntryCreationView) {
                NewEntryView()
                    .environmentObject(coreDataManager)
                    .environmentObject(userPreferences)
                    .foregroundColor(userPreferences.accentColor)
                
            }
            
        }
        
    }
    
    
    private func sortEntries(by option: SortOption) {
        if let log = logs.first, log.relationship.count > 0 {
            switch option {
            case .timeAscending:
                sortedEntries = entries.filter { $0.relationship == log }.sorted { $0.time > $1.time }
            case .timeDescending:
                sortedEntries = entries.filter { $0.relationship == log }.sorted { $0.time < $1.time }
            case .image:
                sortedEntries = entries.filter { $0.relationship == log }
                // Implement the sorting by image if needed
            case .wordCount:
                sortedEntries = entries.filter { $0.relationship == log }
                // Implement the sorting by word count if needed
            }
        } else {
            sortedEntries = []
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
    
    
    private func fetchMarkedEntries() { //fetches important entries before loading the view
        let mainContext = coreDataManager.viewContext
        mainContext.perform {
            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
            for index in 0..<5 {
                fetchRequest.predicate = NSPredicate(format: "buttons[%d] == %@", index, NSNumber(value: true))
                do {
                    let entriesArray = try mainContext.fetch(fetchRequest)
                    markedEntries.button_entries[index] = Set(entriesArray)
                } catch {
                    print("Error fetching marked entries: \(error)")
                }
            }
        }
    }
    
    
    @ViewBuilder
    private func validateDate() -> some View {
        if currentDateFilter != formattedDate(Date()) {
            Button("Refresh") {
                currentDateFilter = formattedDate(Date())
            }
        }
    }
    
    
    func check_files() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                print(fileURL)
            }
        } catch {
            print("Error while enumerating files \(documentsDirectory.path): \(error.localizedDescription)")
        }
    }
}




