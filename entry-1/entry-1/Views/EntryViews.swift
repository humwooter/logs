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


func isGIF(data: Data) -> Bool {
    return data.prefix(6) == Data([0x47, 0x49, 0x46, 0x38, 0x37, 0x61]) || data.prefix(6) == Data([0x47, 0x49, 0x46, 0x38, 0x39, 0x61])
}

func formattedDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.string(from: date)
}


func checkDiskSpace() {
    do {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        if let capacity = values.volumeAvailableCapacityForImportantUsage {
            print("Available disk space: \(capacity) bytes")
        }
    } catch {
        print("Error retrieving disk capacity: \(error)")
    }
}


func currentTime_2(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMM d"
    return formatter.string(from: date)
}


class MarkedEntries: ObservableObject {
    @Published var button_entries: [Set<Entry>] = [[], [], [], [], []]
    
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
    @State private var selectedImage : UIImage?
    
    @State private var showPhotos = false
    @State private var selectedData: Data?
    @State private var showCamera = false
    
    
    var body : some View {
        if (!entry.isFault) {
            Section(header: Text(entry.formattedTime(debug: "from entry row view")).font(.system(size: UIFont.systemFontSize))) {
                VStack {
                    if !isEditing {
                        NotEditingView(entry: entry, editingContent: $editingContent, isEditing: $isEditing)
                    }
                    
                    if isEditing {
                        EditingView(entry: entry, editingContent: $editingContent, isEditing: $isEditing).environmentObject(coreDataManager).environmentObject(userPreferences)
                    }
                }
                
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
        
        
        
//        func deleteImage() {
//            let mainContext = coreDataManager.viewContext
//            if let filename = entry.imageContent {
//                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//                let fileURL = documentsDirectory.appendingPathComponent(filename)
//                do {
//                    print("file URL from deleteImage: \(fileURL)")
//                    try FileManager.default.removeItem(at: fileURL)
//                } catch {
//                    print("Error deleting image file: \(error)")
//                }
//            }
//
//            entry.imageContent = ""
//
//            do {
//                try mainContext.save()
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
//            }
//        }
    func deleteImage() {
        let mainContext = coreDataManager.viewContext
        if let filename = entry.imageContent {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            // Check if file exists before attempting to delete
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    print("file URL from deleteImage: \(fileURL)")
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    print("Error deleting image file: \(error)")
                }
            } else {
                print("File does not exist at path: \(fileURL.path)")
            }
        }
        
        entry.imageContent = ""
        
        do {
            try mainContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
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
        
        // private func foregroundColor(entry: Entry, background: UIColor) -> Color {
        
        //     var red: CGFloat = 0
        //     var green: CGFloat = 0
        //     var blue: CGFloat = 0
        //     var alpha: CGFloat = 0
        
        //     background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        //     let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        
        //     return brightness > 0.5 ? Color.black : Color.white
        // }
        // private func backgroundColor(entry: Entry) -> Color {
        //     let opacity_val = colorScheme == .dark ? 0.90 : 0.75
        //     let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
        
        
        //     if !entry.buttons.contains(true) {
        //         return Color(color)
        //     }
        
        //     print("Color(entry.color).opacity(opacity_val): \(Color(entry.color).opacity(opacity_val))")
        //     return Color(entry.color).opacity(opacity_val)
        // }
    }
    
    
    
    struct EntryView: View {
        // @Environment(\.managedObjectContext) private var viewContext
        @EnvironmentObject var coreDataManager: CoreDataManager
        @State private var currentDateFilter = Date.formattedDate(time: Date())
        @FetchRequest(
            entity: Log.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
            predicate: NSPredicate(format: "day == %@", formattedDate(Date()))
        ) var logs: FetchedResults<Log> // should only be 1 log
        
        
        @FetchRequest(entity: Entry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: true)]) var entries : FetchedResults<Entry>
        
        
        @State private var isShowingEntryCreationView = false
        
        @ObservedObject var markedEntries = MarkedEntries()
        @EnvironmentObject var userPreferences: UserPreferences
        @Environment(\.colorScheme) var colorScheme
        @State private var selectedEntry: Entry?
        @State private var showDeleteAlert = false
        //    @State private var entryToDelete: Entry?
        @State private var editingEntry: Entry?
//        @State private var isEditing = false
        
        let vibration_heavy = UIImpactFeedbackGenerator(style: .heavy)
        let vibration_light = UIImpactFeedbackGenerator(style: .light)
        @State private var engine: CHHapticEngine?
//        @State private var editingContent = ""
        //    @FocusState private var focusField: Bool
        
        //    @State private var editingEntry = false
        
        
        var body: some View {
            NavigationView {
                //            ScrollViewReader { proxy in
                List {
                    if let firstLog = logs.first, firstLog.relationship.count > 0 {
                        var sortedEntries: [Entry] {
                            if let firstLog = logs.first, firstLog.relationship.count > 0 {
                                return Array(firstLog.relationship as! Set<Entry>).sorted { $0.time > $1.time }
                            } else {
                                return []
                            }
                        }
                        
                        
                        ForEach(sortedEntries, id: \.id) { entry in
                            EntryRowView(entry: entry)
                                .environmentObject(userPreferences)
                                .environmentObject(coreDataManager)
                                .id("\(entry.id)")
                        }
                        
                        .onDelete { indexSet in
                            let mainContext = coreDataManager.viewContext
                            mainContext.performAndWait {
                                for index in indexSet {
                                    let entryToDelete = sortedEntries[index]
                                    let filename = entryToDelete.imageContent
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
                                        
                                        print("Entry being deleted: \(entryToDelete)")
                                        // Now perform the deletion
                                        entryToDelete.imageContent = nil
                                        parentLog.removeFromRelationship(entryToDelete)
                                        mainContext.delete(entryToDeleteInContext)
                                        try mainContext.save()
                                        if let filename = filename {
                                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                            let fileURL = documentsDirectory.appendingPathComponent(filename)
                                            
                                            do {
                                                // Delete file
                                                try FileManager.default.removeItem(at: fileURL)
                                            } catch {
                                                // Handle file deletion errors
                                                print("Failed to delete file: \(error)")
                                            }
                                        }
                                        
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
                
                .onAppear {
                    check_files()
                    validateDate()
                }
                
                .navigationTitle(currentTime_2(date: Date()))
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
                    
                }
                //            .onAppear {
                //                checkDiskSpace()
                //            }
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
        
        
        func currentDate() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: Date())
        }
        
        
        private func deleteEntry(entry: Entry) {
            let mainContext = coreDataManager.viewContext
            mainContext.performAndWait {
                let parentLog = entry.relationship
                parentLog.removeFromRelationship(entry)
                mainContext.delete(entry)
                
                // Save the context
                do {
                    try mainContext.save()
                } catch {
                    print("Failed to save mainContext: \(error)")
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
        @State private var micImage = "mic"
        //    @State private var selectedImage: UIImage? = nil
        @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
        
        //    @State private var selectedItems = [PhotosPickerItem]()
        //    @State private var selectedImages : [UIImage] = []
        @State private var selectedItem : PhotosPickerItem?
        @State private var selectedImage : UIImage?
        @State private var selectedData: Data? //used for gifs
        @State private var isCameraPresented = false
        @State private var filename = ""
        @State private var imageData : Data?
        @State private var imageIsAnimated = false
        //    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        //    let fileURL = documentsDirectory.appendingPathComponent("imageContent.png")
        
        
        
        @State private var entryContent = ""
        
        
        var body: some View {
            NavigationView {
                VStack {
                    TextEditor(text: $entryContent)
                        .overlay(
                            HStack(spacing: 15) {
                                Spacer()
                                Button(action: startOrStopRecognition) {
                                    Image(systemName: "mic.fill")
                                        .foregroundColor(isListening ? userPreferences.accentColor : Color.oppositeColor(of: userPreferences.accentColor))
                                        .font(.custom("serif", size: 24))
                                }
                                
                                
                                PhotosPicker(selection:$selectedItem, matching: .images) {
                                    Image(systemName: "photo.fill")
                                        .foregroundColor(Color.oppositeColor(of: userPreferences.accentColor))
                                        .font(.custom("serif", size: 24))
                                    
                                }
                                .onChange(of: selectedItem) { _ in
                                    Task {
                                        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                            //                                        imageData = data
                                            if isGIF(data: data) {
                                                selectedData = data
                                                imageIsAnimated = true
                                            }
                                            else {
                                                selectedData = nil
                                                imageIsAnimated = false
                                            }
                                            selectedImage = UIImage(data: data)
                                            //                                        selectedData = data
                                            print("imageData: \(imageData)")
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
                                        .foregroundColor(Color.oppositeColor(of: userPreferences.accentColor))
                                        .font(.custom("serif", size: 24))
                                }
                                
                            }, alignment: .bottomTrailing
                        )
                        .padding()
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                        
                    }
                    
                }
                .sheet(isPresented: $isCameraPresented) {
                    ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                    
                }
                
                .navigationBarTitle("New Entry")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
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
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Done")
                                .font(.system(size: 16))
                                .foregroundColor(userPreferences.accentColor)
                        }
                    }
                }
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
    
    
    
