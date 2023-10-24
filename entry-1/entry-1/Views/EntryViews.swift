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


let vibration_heavy = UIImpactFeedbackGenerator(style: .heavy)
let vibration_light = UIImpactFeedbackGenerator(style: .light)
let vibration_medium = UIImpactFeedbackGenerator(style: .medium)




class MarkedEntries: ObservableObject {
    @Published var button_entries: [Set<Entry>] = [[], [], [], [], []]
    
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
    
    
    
    var body : some View {
        if (!entry.isFault) {
            Section(header: Text(formattedTime(time: entry.time)).font(.system(size: UIFont.systemFontSize))) {
                VStack {
                    //                    if !isEditing {
                    NotEditingView(entry: entry, editingContent: $editingContent, isEditing: $isEditing)
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
                            
                        }
                        .alert(isPresented: $showingDeleteConfirmation) {
                            Alert(title: Text("Delete entry"),
                                  message: Text("Are you sure you want to delete this entry? This action cannot be undone."),
                                  primaryButton: .destructive(Text("Delete")) {
                                deleteEntry(entry: entry)
//                                coreDataManager.viewContext.performAndWait {
//                                    deleteEntry(entry: entry)
//                                }
//                                refresh.needsRefresh.toggle()
//                                refresh.needsRefresh.toggle()
                            },
                                  secondaryButton: .cancel())
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
            //            Section(header: Text(entry.formattedTime(debug: "from entry row view")).font(.system(size: UIFont.systemFontSize))) {
            
            TextView(entry: entry)
            
            //                    .id(isEditing)
            //                .listRowInsets(EdgeInsets()) // remove default row spacing
                .environmentObject(userPreferences)
                .environmentObject(coreDataManager)
                .listRowBackground(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme))
            
                .swipeActions(edge: .leading) {
                    ForEach(0..<userPreferences.activatedButtons.count, id: \.self) { index in
                        if userPreferences.activatedButtons[index] {
                            Button(action: {
                                activateButton(entry: entry, index: index)
                            }) {
                                Label("", systemImage: userPreferences.selectedImages[index])
                            }
                            .tint(userPreferences.selectedColors[index])
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
            let val : Bool = !entry.buttons[index] //this is what it means to toggle
            entry.buttons = [false, false, false, false, false]
            entry.buttons[index] = val
            entry.color = UIColor(userPreferences.selectedColors[index])
            entry.image = userPreferences.selectedImages[index]
            print("URL from inside activate button \(entry.imageContent)")
            
            // Save the context
            do {
                try mainContext.save()
            } catch {
                print("Failed to save mainContext: \(error)")
            }
            
            if entry.buttons[index] == true {
                markedEntries.button_entries[index].insert(entry)
            } else {
                entry.color = colorScheme == .dark ? UIColor(.black) : UIColor(.white)
                markedEntries.button_entries[index].remove(entry)
            }
        }
    }
}



struct EntryView: View {
    // @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var currentDateFilter = Date.formattedDate(time: Date())
//    @FetchRequest(
//        entity: Log.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
//        predicate: NSPredicate(format: "day == %@", formattedDate(Date()))
//    ) var logs: FetchedResults<Log> // should only be 1 log
    
    
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
//    @FetchRequest(
//        entity: Log.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
//        predicate: NSPredicate(format: "day == %@", formattedDate(Date()))
//    ) var logs_request: FetchedResults<Log> // should only be 1 log
//    @FetchRequest(
//        entity: Log.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
//        predicate: NSPredicate(format: "day == %@", currentDay)
//    ) var logs: FetchedResults<Log>

    @ObservedObject var log: Log

    

    var body: some View {
        NavigationView {
            List {
                if log.relationship.count > 0 {
//                    @FetchRequest(
//                        entity: Log.entity(),
//                        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
//                        predicate: NSPredicate(format: "day == %@", formattedDate(Date()))
//                    ) var logs: FetchedResults<Log>
                    
//                    if let selected_log = logs.first {
                        
                        let entries = Array(log.relationship as! Set<Entry>).sorted { $0.time > $1.time }
                        
                        
                        ForEach(entries, id: \.id) { entry in
                            if (!entry.isFault) {
                                EntryRowView(entry: entry)
                                    .environmentObject(userPreferences)
                                    .environmentObject(coreDataManager)
                                    .id("\(entry.id)")
                            }
                        }
                        
                        
                        
                        
                        //                    var sortedEntries: [Entry] {
                        //                        if let firstLog = logs.first, firstLog.relationship.count > 0 {
                        //                            return Array(firstLog.relationship as! Set<Entry>).sorted { $0.time > $1.time }
                        //                        } else {
                        //                            return []
                        //                        }
                        //                    }
                        //
                        //
                        //                    ForEach(sortedEntries, id: \.id) { entry in
                        //                        if (!entry.isFault) {
                        //                            EntryRowView(entry: entry)
                        //                                .environmentObject(userPreferences)
                        //                                .environmentObject(coreDataManager)
                        //                                .id("\(entry.id)")
                        //                        }
                        //                    }
                        
                        
                        .onDelete { indexSet in
                            let mainContext = coreDataManager.viewContext
                            mainContext.performAndWait {
                                for index in indexSet {
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
                    else {
                        Text("No entries")
                            .foregroundColor(.gray)
                            .italic()
                    }
                    
                }
//            }
//            .refreshable {
//                deleteOldEntries()
//            }

            
            
            .navigationTitle(currentDate())
            .navigationBarItems(trailing:
                                    Button(action: {
                isShowingEntryCreationView = true
            }, label: {
                Image(systemName: "plus")
                    .font(.system(size: 16))
            })
            )
            
            .sheet(isPresented: $isShowingEntryCreationView) {
                NewEntryView()
                    .environmentObject(coreDataManager)
                    .environmentObject(userPreferences)
                    .foregroundColor(userPreferences.accentColor)
                
            }

        }
        
    }
    
    
    
    private func activateButton(entry: Entry, index: Int) {
        let mainContext = coreDataManager.viewContext
        mainContext.performAndWait {
            let val : Bool = !entry.buttons[index] //this is what it means to toggle
            entry.buttons = [false, false, false, false, false]
            entry.buttons[index] = val
            entry.color = UIColor(userPreferences.selectedColors[index])
            entry.image = userPreferences.selectedImages[index]
            print("URL from inside activate button \(entry.imageContent)")
            
            // Save the context
            do {
                try mainContext.save()
            } catch {
                print("Failed to save mainContext: \(error)")
            }
            
            if entry.buttons[index] == true {
                markedEntries.button_entries[index].insert(entry)
            } else {
                entry.color = colorScheme == .dark ? UIColor(.black) : UIColor(.white)
                markedEntries.button_entries[index].remove(entry)
            }
        }
    }
    


    
    func deleteRow(at indexSet: IndexSet) {
        self.toBeDeleted = indexSet           // store rows for delete
        self.showingDeleteAlert = true
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




struct NewEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var isListening = false
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @FocusState private var focusField: Bool


    @State private var selectedItem : PhotosPickerItem?
    @State private var selectedImage : UIImage?
    @State private var selectedData: Data? //used for gifs
    @State private var isCameraPresented = false
    @State private var filename = ""
    @State private var imageData : Data?
    @State private var imageIsAnimated = false
    @State private var isHidden = false

    
    
    
    @State private var entryContent = ""
    
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    TextField(entryContent.isEmpty ? "Start typing here..." : entryContent, text: $entryContent, axis: .vertical)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(colorScheme == .dark ? .white : .black).opacity(0.8)
                        .onTapGesture {
                            focusField = true
                        }
                        .focused($focusField)
                        .padding(.vertical, 30)
                    //                    .padding(.horizontal, 20)
                    
                    
                    Spacer()
                    //                ButtonDashboard_2(activatedButtons: $activatedButtons).environmentObject(userPreferences)
                    //                ImageViewer(selectedImage: selectedImage)
                    if let image = selectedImage { //add gif support and option to pass by data
                        ImageViewer(selectedImage: selectedImage)
                            .contextMenu {
                                Button(role: .destructive, action: {
                                    selectedImage = nil
                                    selectedData = nil
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
            
                    }
                }
                
                HStack(spacing: 25) {
                    Button(action: startOrStopRecognition) {
                        Image(systemName: "mic.fill")
                            .foregroundColor(isListening ? userPreferences.accentColor : Color.oppositeColor(of: userPreferences.accentColor))
                            .font(.system(size: 20))
                    }
                    Spacer()
                    
                    Image(systemName: isHidden ? "eye.slash.fill" : "eye.fill").font(.system(size: 20))

                        .onTapGesture {
                            vibration_heavy.impactOccurred()
                            isHidden.toggle()
                        }
                        .foregroundColor(userPreferences.accentColor).opacity(isHidden ? 1 : 0.1)
                    
                    
                    
                    PhotosPicker(selection:$selectedItem, matching: .images) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 20))

                    }
                    .onChange(of: selectedItem) { _ in
                        Task {
                            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                if isGIF(data: data) {
                                    selectedData = data
                                    selectedImage = UIImage(data: selectedData!)
                                    imageIsAnimated = true
                                }
                                else {
                                    selectedData = nil
                                    selectedImage = nil
                                    imageIsAnimated = false
                                }
                                selectedImage = UIImage(data: data)
                            }
                        }
                    }
                    Button(action: {
                        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                            if response {
                                isCameraPresented = true
                            } else {
                                
                            }
                        }
                    }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 20))
                    }
//                    .padding(.vertical)
                }
                .padding(.vertical)
//                .padding(.horizontal, 15)
                    
                
            }
            .sheet(isPresented: $isCameraPresented) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                
            }
            .padding(.horizontal, 20)
            
            

//            .padding(.horizontal, 30)
            .navigationBarTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        vibration_heavy.impactOccurred()

                     finalizeCreation()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .font(.system(size: 15))
                            .foregroundColor(userPreferences.accentColor)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        vibration_heavy.impactOccurred()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 15))
                    }
                }
            }
        }
    }
    
    func finalizeCreation() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let uniqueFilename = UUID().uuidString + ".png"
        let fileURL = documentsDirectory.appendingPathComponent(uniqueFilename)
        
        let color = colorScheme == .dark ? Color.white : Color.black
        let newEntry = Entry(context: viewContext)
        
        
        
        if let image = selectedImage {
            if let data = imageIsAnimated ? selectedData : image.jpegData(compressionQuality: 0.7) {
                do {
                    try data.write(to: fileURL)
                    filename = uniqueFilename
                    newEntry.imageContent = filename
                    
                    print(": \(filename)")
                    //                                selectedImage = nil // Clear the selectedImage to avoid duplicate writes
                    
                } catch {
                    print("Failed to write: \(error)")
                }
            }
        }
        
        newEntry.content = entryContent
        newEntry.time = Date()
        newEntry.buttons = [false, false, false, false, false]
        newEntry.color = UIColor(color)
        newEntry.image = "star.fill"
        newEntry.id = UUID()
        newEntry.isHidden = false
        newEntry.isRemoved = false
        
        // Fetch the log with the appropriate day
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "day == %@", formattedDate(newEntry.time))
        
        do {
            let logs = try viewContext.fetch(fetchRequest)
            print("LOGS: ", logs)
            if let log = logs.first {
                log.addToRelationship(newEntry)
                newEntry.relationship = log
            } else {
                // Create a new log if needed
                let newLog = Log(context: viewContext)
                newLog.day = formattedDate(newEntry.time)
                newLog.addToRelationship(newEntry)
                newLog.id = UUID()
                newEntry.relationship = newLog
            }
            try viewContext.save()
        } catch {
            print("Error saving new entry: \(error)")
        }
    }
    
    func startRecognition() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        
        // Remove existing taps if any
        inputNode.removeTap(onBus: 0)
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, _ in
            if let result = result {
                entryContent = result.bestTranscription.formattedString
            }
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { (buffer: AVAudioPCMBuffer, _) in
            recognitionRequest.append(buffer)
        }
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func stopRecognition() {
        audioEngine.stop()
        recognitionTask?.cancel()
    }
    func startOrStopRecognition() {
        isListening.toggle()
        if isListening {
            startRecognition()
        }
        else {
            stopRecognition()
        }
    }
    func deleteImage() {
        if filename != "" {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            do {
                print("file URL from deleteImage: \(fileURL)")
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Error deleting image file: \(error)")
            }
        }
        
        selectedImage = nil
        
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}




struct ImageViewer: View {
    @State private var isLoading = true
    var selectedImage: UIImage?

    var body: some View {
        ZStack {
            // Image display
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .background(Color.black)
                    .onAppear {
                        // Image has appeared, so stop showing the progress view
                        isLoading = false
                    }
            }

            // Progress view
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2)
            }
        }
    }
}
