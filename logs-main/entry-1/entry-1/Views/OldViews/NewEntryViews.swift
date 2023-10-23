////
////  EntryViews.swift
////  entry-1
////
////  Created by Katya Raman on 8/14/23.
////
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
////import SwiftyGif
////import Giffy
//
//
//let vibration_heavy = UIImpactFeedbackGenerator(style: .heavy)
//let vibration_light = UIImpactFeedbackGenerator(style: .light)
//let vibration_medium = UIImpactFeedbackGenerator(style: .medium)
//
//
//
//func currentTime_2(date: Date) -> String {
//    let formatter = DateFormatter()
//    formatter.dateFormat = "EEEE, MMM d"
//    return formatter.string(from: date)
//}
//
//
//class MarkedEntries: ObservableObject {
//    @Published var button_entries: [Set<Entry>] = [[], [], [], [], []]
//    
//}
//
//class Refresh: ObservableObject {
//    @Published var needsRefresh: Bool = false
//}
//
//
//
//struct EntryView: View {
//    @EnvironmentObject var coreDataManager: CoreDataManager
//    @EnvironmentObject var userPreferences: UserPreferences
//    @ObservedObject var markedEntries = MarkedEntries()
//    @Environment(\.colorScheme) var colorScheme
//    
//    @State private var currentDateFilter = Date.formattedDate(time: Date())
//    
//    @FetchRequest(
//        entity: Log.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
//        predicate: NSPredicate(format: "day == %@", formattedDate(Date()))
//    ) var logs: FetchedResults<Log> // should only be 1 log
//    
//    
//    @FetchRequest(entity: Entry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: true)]) var entries : FetchedResults<Entry>
//    
//    
//    @State private var editingContent : String = ""
//    @State private var isEditing : Bool = false
//    @FocusState private var focusField: Bool
//    
//    
//    @State private var engine: CHHapticEngine?
//    
//    @State private var selectedItem : PhotosPickerItem?
//    @State private var selectedImage : UIImage?
//    @State private var selectedData: Data?
//    @State private var selectedEntry: Entry? // Add this line
//    
//    
//    
//    
//    @State private var showingDeleteConfirmation = false
//    @State private var isShowingEntryCreationView = false
//    
//    
//    @State private var showPhotos = false
//    @State private var showCamera = false
//    
//    var body: some View {
//        NavigationView {
//            List {
//                content
//            }
//            .onAppear {
//                //                validateDate()
//            }
//            .navigationTitle(currentTime_2(date: Date()))
//            .navigationBarItems(trailing:
//                                    Button(action: {
//                isShowingEntryCreationView = true
//            }, label: {
//                Image(systemName: "plus")
//                    .font(.system(size: 16))
//            })
//            )
//            .sheet(isPresented: $isShowingEntryCreationView) {
//                NewEntryView()
//                    .environmentObject(coreDataManager)
//                    .environmentObject(userPreferences)
//                    .foregroundColor(userPreferences.accentColor)
//            }
//            .sheet(isPresented: $isEditing) {
//                if let entry = selectedEntry {
//                    EditingEntryView(entry: entry, editingContent: $editingContent, isEditing: $isEditing)
//                        .foregroundColor(userPreferences.accentColor)
//                }
//            }
//        }
//    }
//    
//    @ViewBuilder
//    var content: some View {
//        if let firstLog = logs.first, firstLog.relationship.count > 0 {
//            ForEach(sortedEntries(from: firstLog), id: \.id) { entry in
////                if (!entry.isFault) {
//                    Section(header: Text(formattedTime(entry: entry)).font(.system(size: UIFont.systemFontSize))) {
////                        if !entry.isDeleted && !entry.isFault {
//                            entryRow(for: entry)
//                        
////                        }
//                    }
////                }
//                
//                
//            }
//   
//        } else {
//            Text("No entries")
//                .foregroundColor(.gray)
//                .italic()
//        }
//    }
//    
//    func sortedEntries(from log: Log) -> [Entry] {
//        return Array(log.relationship as! Set<Entry>).sorted { $0.time > $1.time }
//    }
//    
//    @ViewBuilder
//    func entryRow(for entry: Entry) -> some View {
//        VStack {
//            //            Text(formattedTime(entry: entry))
//            //                .font(.system(size: UIFont.systemFontSize))
//            //                .padding()
//            //                .background(Color(.systemGray6))
//            //                .frame(maxWidth: .infinity, alignment: .leading)
//            
//            if (!isEditing) {
//                NotEditingView(entry: entry, editingContent: $editingContent, isEditing: $isEditing)
//                    .contextMenu {
//                        Button(action: {
//                            withAnimation {
//                                isEditing = true
//                                selectedEntry = entry
//                                
//                            }
//                        }) {
//                            Text("Edit")
//                            Image(systemName: "pencil")
//                                .foregroundColor(userPreferences.accentColor)
//                        }
//                        
//                        Button(action: {
//                            UIPasteboard.general.string = entry.content ?? ""
//                        }) {
//                            Text("Copy Message")
//                            Image(systemName: "doc.on.doc")
//                        }
//                        
//                        Button(role: .destructive, action: {
//                            print("entry.id: \(entry)")
//                            showingDeleteConfirmation = true
//                        }) {
//                            Text("Delete")
//                            Image(systemName: "trash")
//                                .foregroundColor(.red)
//                        }
//                        
//                    }
////                    .alert(isPresented: $showingDeleteConfirmation) {
////                        Alert(title: Text("Delete entry"),
////                              message: Text("Are you sure you want to delete this entry? This action cannot be undone."),
////                              primaryButton: .destructive(Text("Delete")) {
////                            
////                            coreDataManager.viewContext.performAndWait {
////                                withAnimation {
////                                    deleteEntry(entry: entry)
////                                }
////                            }
////                        },
////                              secondaryButton: .cancel())
////                    }
//                    .alert(isPresented: $showingDeleteConfirmation) {
//                        Alert(title: Text("Delete entry"),
//                              message: Text("Are you sure you want to delete this entry? This action cannot be undone."),
//                              primaryButton: .destructive(Text("Delete")) {
//                            withAnimation {
//                                deleteEntry(entry: entry)
//                            }
//                        },
//                        secondaryButton: .cancel())
//                    }
//                    .swipeActions(edge: .leading) {
//                        ForEach(0..<userPreferences.activatedButtons.count, id: \.self) { index in
//                            if userPreferences.activatedButtons[index] {
//                                Button(action: {
//                                    activateButton(entry: entry, index: index)
//                                }) {
//                                    Label("", systemImage: userPreferences.selectedImages[index])
//                                }
//                                .tint(userPreferences.selectedColors[index])
//                            }
//                        }
//                        
//                    }
//            }
//        }
//        .onChange(of: isEditing) { newValue in
//            if newValue {
//                editingContent = entry.content
//            }
//        }
//        .listRowBackground(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme))
//    }
//    
//    
//    private func activateButton(entry: Entry, index: Int) {
//        let mainContext = coreDataManager.viewContext
//        mainContext.performAndWait {
//            let val : Bool = !entry.buttons[index] //this is what it means to toggle
//            entry.buttons = [false, false, false, false, false]
//            entry.buttons[index] = val
//            entry.color = UIColor(userPreferences.selectedColors[index])
//            entry.image = userPreferences.selectedImages[index]
//            print("URL from inside activate button \(entry.imageContent)")
//            
//            // Save the context
//            do {
//                try mainContext.save()
//            } catch {
//                print("Failed to save mainContext: \(error)")
//            }
//            
//            if entry.buttons[index] == true {
//                markedEntries.button_entries[index].insert(entry)
//            } else {
//                entry.color = colorScheme == .dark ? UIColor(.black) : UIColor(.white)
//                markedEntries.button_entries[index].remove(entry)
//            }
//        }
//    }
//    
//    
//    
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
//    
//    
//    func finalizeEdit(entry: Entry) {
//        // Code to finalize the edit
//        let mainContext = coreDataManager.viewContext
//        mainContext.performAndWait {
//            entry.content = editingContent
//            
//            // Save the context
//            coreDataManager.save(context: mainContext)
//        }
//        isEditing = false
//    }
//    
//    
//    func cancelEdit(entry: Entry) {
//        editingContent = entry.content // Reset to the original content
//        isEditing = false // Exit the editing mode
//    }
//    
//    
//    func deleteEntry(entry: Entry) {
//        let mainContext = coreDataManager.viewContext
//        mainContext.performAndWait {
//            let filename = entry.imageContent
//            let parentLog = entry.relationship
//            
//            
////            // Fetch the entry in the main context
//            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
//            do {
//                let fetchedEntries = try mainContext.fetch(fetchRequest)
//                guard let entryToDeleteInContext = fetchedEntries.first else {
//                    print("Failed to fetch entry in main context")
//                    return
//                }
//                
//                print("Entry being deleted: \(entry)")
//                // Now perform the deletion
//                
//                if entryToDeleteInContext.imageContent != nil {
//                    if (entryToDeleteInContext.imageContent != "") {
//                        if imageExists(at: URL.documentsDirectory.appendingPathComponent(entryToDeleteInContext.imageContent!)) {
//                            entryToDeleteInContext.deleteImage(coreDataManager: coreDataManager)
//                        }
//                    }
//                }
//                
//                parentLog.removeFromRelationship(entryToDeleteInContext)
//                mainContext.delete(entryToDeleteInContext)
//                try mainContext.save()
//                
//            } catch {
//                print("Failed to fetch entry in main context: \(error)")
//            }
//        }
//    }
//}
//
////
////struct EntryView: View {
////    @EnvironmentObject var coreDataManager: CoreDataManager
////    @EnvironmentObject var userPreferences: UserPreferences
////    @ObservedObject var markedEntries = MarkedEntries()
////    @Environment(\.colorScheme) var colorScheme
////
////    @State private var currentDateFilter = Date.formattedDate(time: Date())
////
////    @FetchRequest(
////        entity: Log.entity(),
////        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
////        predicate: NSPredicate(format: "day == %@", formattedDate(Date()))
////    ) var logs: FetchedResults<Log> // should only be 1 log
////
////
////    @FetchRequest(entity: Entry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: true)]) var entries : FetchedResults<Entry>
////
////
////    @State private var editingContent : String = ""
////    @State private var isEditing : Bool = false
////    @FocusState private var focusField: Bool
////
////
////    @State private var engine: CHHapticEngine?
////
////    @State private var selectedItem : PhotosPickerItem?
////    @State private var selectedImage : UIImage?
////    @State private var selectedData: Data?
////
////
////
////    @State private var showingDeleteConfirmation = false
////    @State private var isShowingEntryCreationView = false
////
////
////    @State private var showPhotos = false
////    @State private var showCamera = false
////
////
////    var body : some View {
////        NavigationView {
////            List {
////                if let firstLog = logs.first, firstLog.relationship.count > 0 {
////                    var sortedEntries: [Entry] {
////                        if let firstLog = logs.first, firstLog.relationship.count > 0 {
////                            return Array(firstLog.relationship as! Set<Entry>).sorted { $0.time > $1.time }
////                        } else {
////                            return []
////                        }
////                    }
////
////
////                    ForEach(sortedEntries, id: \.id) { entry in
////                        if (!entry.isFault) {
////                            //                        Section(header: Text(entry.formattedTime(debug: "from entry row view")).font(.system(size: UIFont.systemFontSize)))
////                            //                        Section(header: Text(formattedTime(entry: entry)), content: <#() -> _#>).font(.system(size: UIFont.systemFontSize))) {
////                            //
////                            //                        }
////                            //                        Section(<#T##title: StringProtocol##StringProtocol#>, content: <#T##() -> View#>)
////                            //                        Section(content: <#T##() -> View#>, header: <#T##() -> View#>, footer: <#T##() -> View#>)
////
////
////                            // Section(header: Text(formattedTime(entry: entry)).font(.system(size: UIFont.systemFontSize))) {
////                                // Your section content here
////
////
//////                            Text(formattedTime(entry: entry))
//////                               .font(.system(size: UIFont.systemFontSize))
//////                               .padding()
//////                               .background(Color(.systemGray6))
//////                               .frame(maxWidth: .infinity, alignment: .leading)
////
////                                VStack {
////                                    Text(formattedTime(entry: entry))
////                                       .font(.system(size: UIFont.systemFontSize))
////                                       .padding()
////                                       .background(Color(.systemGray6))
////                                       .frame(maxWidth: .infinity, alignment: .leading)
////
////                                    if (!isEditing) {
////                                        NotEditingView(entry: entry, editingContent: $editingContent, isEditing: $isEditing)
////                                            .contextMenu {
////                                                Button(action: {
////                                                    withAnimation {
////                                                        isEditing = true
////                                                    }
////                                                }) {
////                                                    Text("Edit")
////                                                    Image(systemName: "pencil")
////                                                        .foregroundColor(userPreferences.accentColor)
////                                                }
////
////                                                Button(action: {
////                                                    UIPasteboard.general.string = entry.content ?? ""
////                                                }) {
////                                                    Text("Copy Message")
////                                                    Image(systemName: "doc.on.doc")
////                                                }
////
////                                                Button(role: .destructive, action: {
////                                                    showingDeleteConfirmation = true
////                                                }) {
////                                                    Text("Delete")
////                                                    Image(systemName: "trash")
////                                                        .foregroundColor(.red)
////                                                }
////
////                                            }
////                                            .alert(isPresented: $showingDeleteConfirmation) {
////                                                Alert(title: Text("Delete entry"),
////                                                      message: Text("Are you sure you want to delete this entry? This action cannot be undone."),
////                                                      primaryButton: .destructive(Text("Delete")) {
////                                                    deleteEntry(entry: entry)
////                                                    //                                coreDataManager.viewContext.performAndWait {
////                                                    //                                    deleteEntry(entry: entry)
////                                                    //                                }
////                                                    //                                refresh.needsRefresh.toggle()
////                                                    //                                refresh.needsRefresh.toggle()
////                                                },
////                                                      secondaryButton: .cancel())
////                                            }
////                                            .swipeActions(edge: .leading) {
////                                                ForEach(0..<userPreferences.activatedButtons.count, id: \.self) { index in
////                                                    if userPreferences.activatedButtons[index] {
////                                                        Button(action: {
////                                                            activateButton(entry: entry, index: index)
////                                                        }) {
////                                                            Label("", systemImage: userPreferences.selectedImages[index])
////                                                        }
////                                                        .tint(userPreferences.selectedColors[index])
////                                                    }
////                                                }
////
////                                            }
////                                    }
////                                    else {
////
////                                    }
////
////
////                                }
////                                .onChange(of: isEditing) { newValue in
////                                    if newValue {
////                                        editingContent = entry.content
////                                    }
////                                }
////
////                            // }
////                        }
////                            .listRowBackground(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme))
////                        //
////                    }
////
////
////                }
////                else {
////                    Text("No entries")
////                        .foregroundColor(.gray)
////                        .italic()
////                }
////
////            }
////        }
////        .onAppear {
//////            validateDate()
////        }
////
////        .navigationTitle(currentTime_2(date: Date()))
////        .navigationBarItems(trailing:
////                                Button(action: {
////            isShowingEntryCreationView = true
////        }, label: {
////            Image(systemName: "plus")
////                .font(.system(size: 16))
////        })
////        )
////
////        .sheet(isPresented: $isShowingEntryCreationView) {
////            NewEntryView()
////                .environmentObject(coreDataManager)
////                .environmentObject(userPreferences)
////                .foregroundColor(userPreferences.accentColor)
////
////        }
////        .sheet(isPresented: $isEditing) {
////            EditingEntryView(entry: entry, editingContent: $editingContent, isEditing: $isEditing)
////                .foregroundColor(userPreferences.accentColor)
////        }
////
////    }
////
////    private func activateButton(entry: Entry, index: Int) {
////        let mainContext = coreDataManager.viewContext
////        mainContext.performAndWait {
////            let val : Bool = !entry.buttons[index] //this is what it means to toggle
////            entry.buttons = [false, false, false, false, false]
////            entry.buttons[index] = val
////            entry.color = UIColor(userPreferences.selectedColors[index])
////            entry.image = userPreferences.selectedImages[index]
////            print("URL from inside activate button \(entry.imageContent)")
////
////            // Save the context
////            do {
////                try mainContext.save()
////            } catch {
////                print("Failed to save mainContext: \(error)")
////            }
////
////            if entry.buttons[index] == true {
////                markedEntries.button_entries[index].insert(entry)
////            } else {
////                entry.color = colorScheme == .dark ? UIColor(.black) : UIColor(.white)
////                markedEntries.button_entries[index].remove(entry)
////            }
////        }
////    }
////
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
////    func finalizeEdit(entry: Entry) {
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
////    func cancelEdit(entry: Entry) {
////        editingContent = entry.content // Reset to the original content
////        isEditing = false // Exit the editing mode
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
////                // Now perform the deletion
////
////                if imageExists(at: URL.documentsDirectory.appendingPathComponent(entry.imageContent!)) {
////                    entry.deleteImage(coreDataManager: coreDataManager)
////                }
////
////                parentLog.removeFromRelationship(entryToDeleteInContext)
////                mainContext.delete(entryToDeleteInContext)
////                try mainContext.save()
////
////            } catch {
////                print("Failed to fetch entry in main context: \(error)")
////            }
////        }
////    }
////}
//
//struct NewEntryView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @Environment(\.managedObjectContext) private var viewContext
//    @EnvironmentObject var userPreferences: UserPreferences
//    @Environment(\.colorScheme) var colorScheme
//    @State private var speechRecognizer = SFSpeechRecognizer()
//    @State private var recognitionTask: SFSpeechRecognitionTask?
//    @State private var audioEngine = AVAudioEngine()
//    @State private var isListening = false
//    @State private var isImagePickerPresented = false
//    //    @State private var selectedImage: UIImage? = nil
//    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
//    
//    //    @State private var selectedItems = [PhotosPickerItem]()
//    //    @State private var selectedImages : [UIImage] = []
//    @State private var selectedItem : PhotosPickerItem?
//    @State private var selectedImage : UIImage?
//    @State private var selectedData: Data? //used for gifs
//    @State private var isCameraPresented = false
//    @State private var filename = ""
//    @State private var imageData : Data?
//    @State private var imageIsAnimated = false
//    @State private var isHidden = false
//    //    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//    //    let fileURL = documentsDirectory.appendingPathComponent("imageContent.png")
//    
//    
//    
//    @State private var entryContent = ""
//    
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                TextField(entryContent.isEmpty ? "Start typing here..." : entryContent, text: $entryContent, axis: .vertical)
//                    .fixedSize(horizontal: false, vertical: true)
//                    .foregroundColor(colorScheme == .dark ? .white : .black).opacity(0.8)
//                    .padding()
//                
//                
//                //                    TextEditor(text: $entryContent.isEmpty ? "Start typing here ..." : $entryContent)
//                Spacer()
//                
//                
//                if let image = selectedImage {
//                    Image(uiImage: image)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                    //                            .frame(width: 200, height: 200) // Adjust the size as needed
//                        .frame(maxWidth: .infinity, maxHeight: 150)
//                    
//                        .background(Color.black)
//                }
//                
//                HStack(spacing: 25) {
//                    Button(action: startOrStopRecognition) {
//                        Image(systemName: "mic.fill")
//                            .foregroundColor(isListening ? userPreferences.accentColor : Color.oppositeColor(of: userPreferences.accentColor))
//                            .font(.custom("serif", size: 24))
//                    }
//                    Spacer()
//                    
//                    Image(systemName: isHidden ? "eye.slash.fill" : "eye.fill").font(.custom("serif", size: 24))
//                        .onTapGesture {
//                            vibration_heavy.impactOccurred()
//                            isHidden.toggle()
//                        }
//                        .foregroundColor(userPreferences.accentColor).opacity(isHidden ? 1 : 0.1)
//                    
//                    
//                    
//                    PhotosPicker(selection:$selectedItem, matching: .images) {
//                        Image(systemName: "photo.fill")
//                            .font(.custom("serif", size: 24))
//                        
//                    }
//                    .onChange(of: selectedItem) { _ in
//                        Task {
//                            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
//                                if isGIF(data: data) {
//                                    selectedData = data
//                                    imageIsAnimated = true
//                                }
//                                else {
//                                    selectedData = nil
//                                    imageIsAnimated = false
//                                }
//                                selectedImage = UIImage(data: data)
//                            }
//                        }
//                    }
//                    Button(action: {
//                        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
//                            if response {
//                                isCameraPresented = true
//                            } else {
//                                
//                            }
//                        }
//                    }) {
//                        Image(systemName: "camera.fill")
//                            .font(.custom("serif", size: 24))
//                    }
//                    .padding(.vertical)
//                    //                                .padding(.horizontal)
//                }
//                
//            }
//            .sheet(isPresented: $isCameraPresented) {
//                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
//                
//            }
//            .padding(.horizontal, 30)
//            .navigationBarTitle("New Entry")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button {
//                        vibration_heavy.impactOccurred()
//                        presentationMode.wrappedValue.dismiss()
//                    } label: {
//                        Image(systemName: "arrow.backward")
//                            .font(.custom("serif", size: 16))
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//                        let uniqueFilename = UUID().uuidString + ".png"
//                        let fileURL = documentsDirectory.appendingPathComponent(uniqueFilename)
//                        
//                        let color = colorScheme == .dark ? Color.white : Color.black
//                        let newEntry = Entry(context: viewContext)
//                        
//                        
//                        
//                        if let image = selectedImage {
//                            if let data = imageIsAnimated ? selectedData : image.jpegData(compressionQuality: 0.7) {
//                                do {
//                                    try data.write(to: fileURL)
//                                    filename = uniqueFilename
//                                    newEntry.imageContent = filename
//                                    
//                                    print(": \(filename)")
//                                    //                                selectedImage = nil // Clear the selectedImage to avoid duplicate writes
//                                    
//                                } catch {
//                                    print("Failed to write: \(error)")
//                                }
//                            }
//                        }
//                        
//                        newEntry.content = entryContent
//                        newEntry.time = Date()
//                        newEntry.buttons = [false, false, false, false, false]
//                        newEntry.color = UIColor(color)
//                        newEntry.image = "star.fill"
//                        newEntry.id = UUID()
//                        newEntry.isHidden = false
//                        
//                        // Fetch the log with the appropriate day
//                        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
//                        fetchRequest.predicate = NSPredicate(format: "day == %@", formattedDate(newEntry.time))
//                        
//                        do {
//                            let logs = try viewContext.fetch(fetchRequest)
//                            print("LOGS: ", logs)
//                            if let log = logs.first {
//                                log.addToRelationship(newEntry)
//                                newEntry.relationship = log
//                            } else {
//                                // Create a new log if needed
//                                let newLog = Log(context: viewContext)
//                                newLog.day = formattedDate(newEntry.time)
//                                newLog.addToRelationship(newEntry)
//                                newLog.id = UUID()
//                                newEntry.relationship = newLog
//                            }
//                            try viewContext.save()
//                        } catch {
//                            print("Error saving new entry: \(error)")
//                        }
//                        presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Text("Done")
//                            .font(.system(size: 16))
//                            .foregroundColor(userPreferences.accentColor)
//                    }
//                }
//            }
//        }
//    }
//    func startRecognition() {
//        let audioSession = AVAudioSession.sharedInstance()
//        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        let inputNode = audioEngine.inputNode
//        
//        // Remove existing taps if any
//        inputNode.removeTap(onBus: 0)
//        
//        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, _ in
//            if let result = result {
//                entryContent = result.bestTranscription.formattedString
//            }
//        }
//        
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { (buffer: AVAudioPCMBuffer, _) in
//            recognitionRequest.append(buffer)
//        }
//        audioEngine.prepare()
//        try? audioEngine.start()
//    }
//    
//    func stopRecognition() {
//        audioEngine.stop()
//        recognitionTask?.cancel()
//    }
//    func startOrStopRecognition() {
//        isListening.toggle()
//        if isListening {
//            startRecognition()
//        }
//        else {
//            stopRecognition()
//        }
//    }
//    func deleteImage() {
//        if filename != "" {
//            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let fileURL = documentsDirectory.appendingPathComponent(filename)
//            do {
//                print("file URL from deleteImage: \(fileURL)")
//                try FileManager.default.removeItem(at: fileURL)
//            } catch {
//                print("Error deleting image file: \(error)")
//            }
//        }
//        
//        selectedImage = nil
//        
//        
//        do {
//            try viewContext.save()
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//    }
//    
//}
//
//
//
