//
//  EntryView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 11/28/23.
//

import Foundation

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
    @Published var button_entries: [Set<Entry>] = Array(repeating: Set<Entry>(), count: 21)
}

class Refresh: ObservableObject {
    @Published var needsRefresh: Bool = false
}

struct TextView : View {
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
    
    @State private var showEntry = true
    
    var body : some View {
        
        if (!entry.isFault) {
            Section {
                if (entry.isShown) {
                    
                    NotEditingView(entry: entry, isEditing: $isEditing).environmentObject(userPreferences).environmentObject(coreDataManager)
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
                
                            
                        }
                    
                    
                    
                        .onChange(of: isEditing) { newValue in
                            if newValue {
                                editingContent = entry.content
                            }
                        }
                        .sheet(isPresented: $isEditing) {
                            EditingEntryView(entry: entry, editingContent: $editingContent, isEditing: $isEditing)
                                .foregroundColor(userPreferences.accentColor)
//                                .presentationDetents([.medium, .large])
                                .presentationDragIndicator(.hidden)

                        }
                }
            } header: {
                HStack {
                    Text("\(entry.isPinned && formattedDate(entry.time) != formattedDate(Date()) ? formattedDateShort(from: entry.time) : formattedTime(time: entry.time))").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))).opacity(0.4)
                        
                    Label("", systemImage: entry.stampIcon).foregroundStyle(Color(entry.color))
                    Spacer()

                    if (entry.isPinned) {
                        Label("", systemImage: "pin.fill").foregroundColor(userPreferences.pinColor)

                    }
//                    Label("", systemImage: entry.isShown ? "chevron.up" : "chevron.down").foregroundColor(userPreferences.accentColor)
//                        .contentTransition(.symbolEffect(.replace.offUp))
                    
                    Image(systemName: entry.isShown ? "chevron.up" : "chevron.down").foregroundColor(userPreferences.accentColor)
                        .contentTransition(.symbolEffect(.replace.offUp))
                        .font(.system(size: UIFont.systemFontSize))

                    
                }
                .font(.system(size: UIFont.systemFontSize))
                .onTapGesture {
                    vibration_light.impactOccurred()
                        entry.isShown.toggle()
                        coreDataManager.save(context: coreDataManager.viewContext)
                }
            }
            .onAppear {
                showEntry = !entry.isHidden
            }
        }
         
        
    }
    
    func deleteEntry(entry: Entry) {
        let mainContext = coreDataManager.viewContext
        mainContext.performAndWait {
            let filename = entry.mediaFilename
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
    @EnvironmentObject var coreDataManager: CoreDataManager
    @ObservedObject var entry: Entry
    
    @State private var isShowingEntryCreationView = false
    
    @ObservedObject var markedEntries = MarkedEntries()
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedEntry: Entry?
    @State private var showDeleteAlert = false
    @State private var editingEntry: Entry?
    @State private var padding: CGFloat = 0.0

    
    @State private var engine: CHHapticEngine?
    
    var body : some View {
        if (!entry.isFault) {
         
           
                TextView(entry: entry)
                
                    .environmentObject(userPreferences)
                    .environmentObject(coreDataManager)
                    .listRowBackground(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
//                    .padding(.vertical, 2.0)
                    .padding(.bottom, padding)
                
                    .swipeActions(edge: .leading) {
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

        }
        
        
        else {
            ProgressView()
        }
        
    }
    

    
    private func activateButton(entry: Entry, index: Int) {
        let mainContext = coreDataManager.viewContext
        mainContext.performAndWait {
            
            if (index == entry.stampIndex) {
                    entry.stampIndex = -1
                    entry.stampIcon = ""
                    entry.color = UIColor.tertiarySystemBackground
            }
            else {
                    entry.stampIndex = Int16(index)
                    entry.stampIcon = userPreferences.stamps[index].imageName
                    entry.color = UIColor(userPreferences.stamps[index].color)
            }
            
            if userPreferences.stamps[index].isActive {
                markedEntries.button_entries[index].insert(entry)
            } else {
                entry.color = UIColor.tertiarySystemBackground
                markedEntries.button_entries[index].remove(entry)
            }
            // Save the context
            do {
                try mainContext.save()
            } catch {
                print("Failed to save mainContext: \(error)")
            }



        }
    }

}




struct EntryView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences

    @State private var isShowingEntryCreationView = false
    
    @ObservedObject var markedEntries = MarkedEntries()
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedEntry: Entry?
    @State private var showDeleteAlert = false
    @State private var showingDeleteConfirmation = false
    
    @State private var editingEntry: Entry?
 
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
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: true)],
        predicate: NSPredicate(format: "time >= %@ OR isPinned == true", Calendar.current.startOfDay(for: Date()) as NSDate)
    ) var entries: FetchedResults<Entry>

    @State private var currentTime: Date = Date()

    
    
    @State private var selectedSortOption: SortOption = .timeAscending
    init(color: UIColor) {
        if !isClear(for: color) {
            let textColor = UIColor(UIColor.foregroundColor(background: color))
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: textColor]
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: textColor]
        }
        if isClear(for: color) {
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color("TextColor"))]
        }
        
   }
    
    
    var body: some View {
        NavigationStack {
            List {
                
                if entries.count == 0 {
                    Section {
                        Text("No entries")
                    }
//                    VStack {
//                        Text("No entries")
//                            .italic()
//                        Spacer()
//                    }
                            .refreshable(action: {
                                updateFetchRequests()
                            })
                }
                else {
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
                    }
                }
                    
                }
            .background {
                    ZStack {
                        Color(UIColor.systemGroupedBackground)
                        LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                    }
                    .ignoresSafeArea()
            }
            .scrollContentBackground(.hidden)
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
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size:13))
                
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
      
        .onAppear {
            updateFetchRequests()
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
    
    
//    private func fetchMarkedEntries() { //fetches important entries before loading the view
//        let mainContext = coreDataManager.viewContext
//        mainContext.perform {
//            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//            for index in 0..<5 {
//                fetchRequest.predicate = NSPredicate(format: "buttons[%d] == %@", index, NSNumber(value: true))
//                do {
//                    let entriesArray = try mainContext.fetch(fetchRequest)
//                    markedEntries.button_entries[index] = Set(entriesArray)
//                } catch {
//                    print("Error fetching marked entries: \(error)")
//                }
//            }
//        }
//    }
    
    private func fetchMarkedEntries() { //fetches important entries before loading the view
        let mainContext = coreDataManager.viewContext
        mainContext.perform {
            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
            for index in 0..<5 {
                fetchRequest.predicate = NSPredicate(format: "stampIndex == %d", index)
                do {
                    let entriesArray = try mainContext.fetch(fetchRequest)
                    markedEntries.button_entries[index] = Set(entriesArray)
                } catch {
                    print("Error fetching marked entries: \(error)")
                }
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




