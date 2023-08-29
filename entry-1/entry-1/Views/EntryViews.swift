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
import SwiftyGif
import Giffy


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

func oppositeColor(of color: Color) -> Color {
    // Extract the RGB components
    let uiColor = UIColor(color)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    // Calculate the opposite color by subtracting each component from 1
    let oppositeColor = UIColor(red: 1 - red, green: 1 - green, blue: 1 - blue, alpha: alpha)
    
    return Color(oppositeColor)
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
    @Binding var editingContent : String
    @Binding var isEditing : Bool
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
                        ZStack(alignment: .topTrailing) {
                            VStack {
                                Spacer()
                                    .frame(height: 20)
                                
                                
                                
                                if entry.isHidden {
                                    Text(entry.content)
                                        .foregroundColor(foregroundColor(entry: entry, background: entry.color))
                                    
                                        .fontWeight(entry.buttons.contains(true) ? .semibold : .regular)
                                        .frame(maxWidth: .infinity, alignment: .leading) // Full width with left alignment
                                        .blur(radius:7)
                                    
                                    if entry.imageContent != "" {
                                        if let filename = entry.imageContent {
                                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                            let fileURL = documentsDirectory.appendingPathComponent(filename)
                                            let data = try? Data(contentsOf: fileURL)
                                            
                                            
                                            if let data = data, isGIF(data: data) {

                                              let imageView = AnimatedImageView(url: fileURL)
                                              
                                                let asyncImage = UIImage(data: data)
                                              
                                                let height = asyncImage!.size.height
                                              
                                                AnimatedImageView(url: fileURL).scaledToFit()
                                                    .blur(radius:10)


                                              // Add imageView
                                            } else {
                                                AsyncImage(url: fileURL) { image in
                                                    image.resizable()
                                                        .scaledToFit()
                                                        .blur(radius:10)
                                                }
                                            placeholder: {
                                                ProgressView()
                                            }
                                            }
                                        }
                                    }
                                }
                                else {
                                    Text(entry.content)
                                        .foregroundColor(foregroundColor(entry: entry, background: entry.color))
                                    
                                        .fontWeight(entry.buttons.contains(true) ? .semibold : .regular)
                                        .frame(maxWidth: .infinity, alignment: .leading) // Full width with left alignment
                                    
                                    if entry.imageContent != "" {
                                        if let filename = entry.imageContent {
                                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                            let fileURL = documentsDirectory.appendingPathComponent(filename)
                                            let data = try? Data(contentsOf: fileURL)
                                            
                                            
                                            if let data = data, isGIF(data: data) {

                                              let imageView = AnimatedImageView(url: fileURL)
                                              
                                                let asyncImage = UIImage(data: data)
                                              
                                                let height = asyncImage!.size.height
                                              
                                                AnimatedImageView(url: fileURL).scaledToFit()


                                              // Add imageView
                                            } else {
                                                AsyncImage(url: fileURL) { image in
                                                    image.resizable()
                                                        .scaledToFit()
                                                }
                                            placeholder: {
                                                ProgressView()
                                            }
                                            }
                                        }
                                    }
                                }
                                
                                
                            }
                            
                            VStack {

                                Image(systemName: "ellipsis")
                                    .foregroundColor(foregroundColor(entry: entry, background: entry.color).opacity(0.15)) //to determinw whether black or white
                                    .font(.custom("serif", size: 20))
                                    .onTapGesture {
                                        withAnimation {
                                            editingContent = entry.content
                                            vibration_heavy.impactOccurred()
                                            isEditing = true
//                                            focusField = true

                                        }
               

                                    }

                            }
                            .padding(10)
                            
                            
                        }
                        
                    }
                    if isEditing {
                        VStack() {
                            VStack {
                                HStack(spacing: 25) {
                                    Image(systemName: "xmark").font(.custom("serif", size: 16))
                                        .onTapGesture {
                                            vibration_heavy.impactOccurred()
                                            cancelEdit() // Function to discard changes
                                        }

                                    Spacer()
                                    if (entry.isHidden) {
                                        Image(systemName: "eye.slash.fill").font(.custom("serif", size: 16))
                                            .onTapGesture {
                                                vibration_heavy.impactOccurred()
                                                hideEntry()
                                            }
                                            .foregroundColor(userPreferences.accentColor)

                                    }
                                    else {
                                        Image(systemName: "eye.fill").font(.custom("serif", size: 16))
                                            .onTapGesture {
                                                vibration_heavy.impactOccurred()
                                                hideEntry()
                                            }
                                            .foregroundColor(foregroundColor(entry: entry, background: entry.color)).opacity(0.1)
                                    }
                                    
                                    
                                    PhotosPicker(selection:$selectedItem, matching: .images) {
                                        Image(systemName: "photo.fill")
                                            .symbolRenderingMode(.multicolor)
                                            .font(.custom("serif", size: 16))
                                    }
                                    .onChange(of: selectedItem) { _ in
                                        Task {
                                            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                                deleteImage() //clear previous data
                                                selectedData = data
                                                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                                let uniqueFilename = UUID().uuidString + ".png"
                                                let fileURL = documentsDirectory.appendingPathComponent(uniqueFilename)
                                                try? data.write(to: fileURL)
                                                entry.imageContent = uniqueFilename
                                                return
                                            }
                                        }
                                    }
                                    
                                    Image(systemName: "camera.fill")
                                        .font(.custom("serif", size: 16))
                                        .onChange(of: selectedImage) { _ in
                                            Task {
                                                if let data = selectedImage?.jpegData(compressionQuality: 0.7) {
                                                    deleteImage() //clear previous data
                                                    selectedData = data
                                                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                                    let uniqueFilename = UUID().uuidString + ".png"
                                                    let fileURL = documentsDirectory.appendingPathComponent(uniqueFilename)
                                                    try? data.write(to: fileURL)
                                                    entry.imageContent = uniqueFilename
                                                    return
                                                }
                                            }
                                        }
                                        .onTapGesture {
                                            vibration_heavy.impactOccurred()
                                            showCamera = true
                                        }
                                    
                                    
                                    
                                    
                                    Image(systemName: "checkmark")
                                        .font(.custom("serif", size: 16))
                                        .onTapGesture {
                                            withAnimation() {
                                                vibration_heavy.impactOccurred()
                                                finalizeEdit()
                                                focusField = false
                                            }
                                        }
                       
                                    

                                }
                                .foregroundColor(foregroundColor(entry: entry, background: entry.color)) //to determinw whether black or white
                                
                            }
                            
                            
                            VStack {
                                TextField(entry.content, text: $editingContent, axis: .vertical)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .onSubmit {
                                        finalizeEdit()
                                    }
                                    .foregroundColor(foregroundColor(entry: entry, background: entry.color)).opacity(0.6) //to determinw whether black or white
                                    .onTapGesture {
                                        focusField = true
                                    }
                                    .focused($focusField)

                                
                                if entry.imageContent != "" {
                                    if let filename = entry.imageContent {
                                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                        let fileURL = documentsDirectory.appendingPathComponent(filename)
                                        let data = try? Data(contentsOf: fileURL)
                                        
                                        
                                        if let data = data, isGIF(data: data) {

                                          let imageView = AnimatedImageView(url: fileURL)
                                          
                                            let asyncImage = UIImage(data: data)
                                          
                                            let height = asyncImage!.size.height
                                          
                                            ZStack(alignment: .topLeading) {
                                                AnimatedImageView(url: fileURL).scaledToFit()
                                                Image(systemName: "minus.circle") // Cancel button
                                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))

                                                    .foregroundColor(.red).opacity(0.8)
                                                    .font(.custom("serif", size: 20))
                                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                                    .frame(width:70, height: 70)
                                                    .background(Color(.black).opacity(0.01))
                                                    .onTapGesture {
                                                        vibration_medium.impactOccurred()
                                                        deleteImage() // Function to discard changes
                                                    }
                                            }.padding(5)


                                          // Add imageView
                                        } else {
                                            AsyncImage(url: fileURL) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    ZStack(alignment: .topLeading) {
                                                        image.resizable().scaledToFit()
                                                        Image(systemName: "minus.circle") // Cancel button
                                                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))

                                                            .foregroundColor(.red).opacity(0.8)
                                                            .font(.custom("serif", size: 20))
                                                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                                            .frame(width: 70, height: 70)
                                                            .background(Color(.black).opacity(0.01))
                                                            .onTapGesture {
                                                                vibration_medium.impactOccurred()
                                                                deleteImage() // Function to discard changes
                                                            }
//                                                            .frame(width: 40, height: 40)

                                                    }.padding(5)
                                                case .failure:
                                                    Text("Failed to load image")
                                                case .empty:
                                                    ProgressView()
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                        .sheet(isPresented: $showCamera) {
                            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                        }
                        
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
//     func finalizeEdit() {
//         // Code to finalize the edit
//         if let data = selectedData {
//             let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//             let uniqueFilename = UUID().uuidString + ".png"
//             let fileURL = documentsDirectory.appendingPathComponent(uniqueFilename)
//             try? data.write(to: fileURL)
//             entry.imageContent = uniqueFilename
//         }
//         entry.content = editingContent
//         do {
//             try viewContext.save()
//         } catch {
//             print("Error updating entry content: \(error)")
//         }
//         isEditing = false
//         focusField = false
//     }

    func finalizeEdit() {
        // Code to finalize the edit
        let backgroundContext = coreDataManager.backgroundContext
        backgroundContext.perform {
            if let data = selectedData {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let uniqueFilename = UUID().uuidString + ".png"
                let fileURL = documentsDirectory.appendingPathComponent(uniqueFilename)
                try? data.write(to: fileURL)
                entry.imageContent = uniqueFilename
            }
            entry.content = editingContent

            // Save the context
            coreDataManager.save(context: backgroundContext)

            // Merge changes into the viewContext
            coreDataManager.mergeChanges(from: backgroundContext)
        }
        isEditing = false
        focusField = false
    }
    
    func getDefaultColor(entry: Entry) -> Color {
        if colorScheme == .dark {
            return .white
        }
        return .black
    }
    func cancelEdit() {
        editingContent = entry.content // Reset to the original content
        isEditing = false // Exit the editing mode
    }
    
//    func deleteImage() {
//        if let filename = entry.imageContent {
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
//        entry.imageContent = ""
//
//
//        do {
//            try viewContext.save()
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//    }
//    func deleteImage() {
//        let backgroundContext = coreDataManager.backgroundContext
//        backgroundContext.perform {
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
//            // Save the context
//            coreDataManager.save(context: backgroundContext)
//            // Merge changes into the viewContext
//            coreDataManager.mergeChanges(from: backgroundContext)
//        }
//    }
//    func deleteImage() {
//        let backgroundContext = coreDataManager.backgroundContext
//        backgroundContext.perform {
//            let backgroundEntry = backgroundContext.object(with: entry.objectID) as? Entry
//
//            if let filename = backgroundEntry?.imageContent {
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
//            backgroundEntry?.imageContent = ""
//            entry.imageContent = ""
//
//            // Save the context
//            coreDataManager.save(context: backgroundContext)
//            // Merge changes into the viewContext
//            coreDataManager.mergeChanges(from: backgroundContext)
//        }
//    }
    func deleteImage() {
        let backgroundContext = coreDataManager.backgroundContext
        backgroundContext.performAndWait {
            if let backgroundEntry = backgroundContext.object(with: entry.objectID) as? Entry,
               let filename = backgroundEntry.imageContent, !filename.isEmpty {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent(filename)
                do {
                    print("file URL from deleteImage: \(fileURL)")
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    print("Error deleting image file: \(error)")
                }
                backgroundEntry.imageContent = ""
//                entry.imageContent = ""
                coreDataManager.save(context: backgroundContext)
            }
        }
        entry.imageContent = ""
        coreDataManager.mergeChanges(from: backgroundContext)
    }


    
    
    
    
    private func foregroundColor(entry: Entry, background: UIColor) -> Color {
        
        let color = colorScheme == .dark ? Color.white : Color.black

        if !entry.buttons.contains(true) {
            return getDefaultColor(entry: entry)
        }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        print("brigtness value: \(brightness)")
        
        return brightness > 0.5 ? Color.black : Color.white
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
    //    @State private var entryToDelete: Entry?
    @State private var editingEntry: Entry?
    @State private var isEditing = false
    
    
    @State private var engine: CHHapticEngine?
    @State private var editingContent = ""
    
    
    var body : some View {
        if (!entry.isFault) {
            //            Section(header: Text(entry.formattedTime(debug: "from entry row view")).font(.system(size: UIFont.systemFontSize))) {
            
            TextView(entry: entry, editingContent: $editingContent, isEditing: $isEditing)
            //                .listRowInsets(EdgeInsets()) // remove default row spacing
                .environmentObject(userPreferences)
                .environmentObject(coreDataManager)
                .listRowBackground(backgroundColor(entry: entry))

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
        let backgroundContext = coreDataManager.backgroundContext
        backgroundContext.perform {
            let val : Bool = !entry.buttons[index] //this is what it means to toggle
            entry.buttons = [false, false, false, false, false]
            entry.buttons[index] = val
            entry.color = UIColor(userPreferences.selectedColors[index])
            entry.image = userPreferences.selectedImages[index]
            print("URL from inside activate button \(entry.imageContent)")
            
            coreDataManager.save(context: backgroundContext)
            coreDataManager.mergeChanges(from: backgroundContext)
            
            DispatchQueue.main.async {
                if entry.buttons[index] == true {
                    self.markedEntries.button_entries[index].insert(entry)
                } else {
                    print("color: \(entry.color)")
                    self.markedEntries.button_entries[index].remove(entry)
                }
            }
        }
    }
    
    private func foregroundColor(entry: Entry, background: UIColor) -> Color {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        
        return brightness > 0.5 ? Color.black : Color.white
    }
    private func backgroundColor(entry: Entry) -> Color {
        let opacity_val = colorScheme == .dark ? 0.90 : 0.75
        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground


        if !entry.buttons.contains(true) {
            return Color(color)
        }

        print("Color(entry.color).opacity(opacity_val): \(Color(entry.color).opacity(opacity_val))")
        return Color(entry.color).opacity(opacity_val)
    }
}



struct EntryView: View {
    // @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var currentDateFilter = formattedDate(Date())
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
    @State private var isEditing = false
    
    let vibration_heavy = UIImpactFeedbackGenerator(style: .heavy)
    let vibration_light = UIImpactFeedbackGenerator(style: .light)
    @State private var engine: CHHapticEngine?
    @State private var editingContent = ""
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
                            let backgroundContext = coreDataManager.backgroundContext
                            backgroundContext.perform {
                                for index in indexSet {
                                    let entryToDelete = sortedEntries[index]
                                    let filename = entryToDelete.imageContent
                                    let parentLog = entryToDelete.relationship
                                    
                                    // Fetch the entry in the background context
                                    let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
                                    fetchRequest.predicate = NSPredicate(format: "id == %@", entryToDelete.id as CVarArg)
                                    do {
                                        let fetchedEntries = try backgroundContext.fetch(fetchRequest)
                                        guard let entryToDeleteInContext = fetchedEntries.first else {
                                            print("Failed to fetch entry in background context")
                                            return
                                        }
                                        
                                        // Now perform the deletion
                                        entryToDelete.imageContent = nil
                                        parentLog.removeFromRelationship(entryToDelete)
                                        backgroundContext.delete(entryToDeleteInContext)
                                        coreDataManager.save(context: backgroundContext)
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
                                        coreDataManager.mergeChanges(from: backgroundContext)
                                        
                                    } catch {
                                        print("Failed to fetch entry in background context: \(error)")
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
        }
        
    }

    private func activateButton(entry: Entry, index: Int) {
        let backgroundContext = coreDataManager.backgroundContext
        backgroundContext.perform {
            let val : Bool = !entry.buttons[index] //this is what it means to toggle
            entry.buttons = [false, false, false, false, false]
            entry.buttons[index] = val
            entry.color = UIColor(userPreferences.selectedColors[index])
            entry.image = userPreferences.selectedImages[index]
            print("URL from inside activate button \(entry.imageContent)")

            // Save the context
            coreDataManager.save(context: backgroundContext)

            // Merge changes into the viewContext
            coreDataManager.mergeChanges(from: backgroundContext)

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
        let backgroundContext = coreDataManager.backgroundContext
        backgroundContext.perform {
            let parentLog = entry.relationship
            parentLog.removeFromRelationship(entry)
            backgroundContext.delete(entry)

            // Save the context
            coreDataManager.save(context: backgroundContext)

            // Merge changes into the viewContext
            coreDataManager.mergeChanges(from: backgroundContext)
        }
    }

   
    private func fetchMarkedEntries() { //fetches important entries before loading the view
        let backgroundContext = coreDataManager.backgroundContext
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
            for index in 0..<5 {
                fetchRequest.predicate = NSPredicate(format: "buttons[%d] == %@", index, NSNumber(value: true))
                do {
                    let entriesArray = try backgroundContext.fetch(fetchRequest)
                    markedEntries.button_entries[index] = Set(entriesArray)
                } catch {
                    print("Error fetching marked entries: \(error)")
                }
            }
        }
    }

    func finalizeEdit() {
        // Code to finalize the edit
        let backgroundContext = coreDataManager.backgroundContext
        backgroundContext.perform {
            editingEntry?.content = editingContent

            // Save the context
            coreDataManager.save(context: backgroundContext)

            // Merge changes into the viewContext
            coreDataManager.mergeChanges(from: backgroundContext)
        }
        isEditing = false
        editingEntry = nil
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
                                    .foregroundColor(isListening ? userPreferences.accentColor : oppositeColor(of: userPreferences.accentColor))
                                    .font(.custom("serif", size: 24))
                            }
                            
                            
                            PhotosPicker(selection:$selectedItem, matching: .images) {
                                Image(systemName: "photo.fill")
                                    .foregroundColor(oppositeColor(of: userPreferences.accentColor))
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
                                    .foregroundColor(oppositeColor(of: userPreferences.accentColor))
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



