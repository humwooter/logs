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



let vibration_heavy = UIImpactFeedbackGenerator(style: .heavy)
let vibration_light = UIImpactFeedbackGenerator(style: .light)
let vibration_medium = UIImpactFeedbackGenerator(style: .medium)

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
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var entry : Entry
    @Binding var editingContent : String
    @Binding var isEditing : Bool
    @State private var engine: CHHapticEngine?
    @FocusState private var focusField: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedItem : PhotosPickerItem?
    @State private var showPhotos = false
    
    
    var body : some View {
        if (!entry.isFault) {
            Section(header: Text(entry.formattedTime(debug: "from entry row view")).font(.system(size: UIFont.systemFontSize))) {
                VStack {
                    if !isEditing {
                        ZStack(alignment: .topTrailing) {
                            VStack {
                                Spacer()
                                    .frame(height: 15)
                                Text(entry.content)
                                    .foregroundColor(foregroundColor(entry: entry, background: entry.color)) //to determinw whether black or white
                                    .fontWeight(entry.buttons.filter{$0}.count > 0 ? .semibold : .regular)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Full width with left alignment
                                //                                if let urlString = entry.imageContent, let url = URL(string: urlString) {
                                //                                    AsyncImage(url: url) { image in
                                //                                        image.resizable()
                                //                                            .scaledToFit()
                                //                                    }
                                //                                    placeholder: {
                                //                                        ProgressView()
                                //                                    }
                                //                                }
                                if entry.imageContent != "" {
                                    if let filename = entry.imageContent {
                                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                        let fileURL = documentsDirectory.appendingPathComponent(filename)
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
                            
                            VStack {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(foregroundColor(entry: entry, background: entry.color).opacity(0.15)) //to determinw whether black or white
                                    .font(.custom("serif", size: 20))
                                    .onTapGesture {
                                        withAnimation() {
                                            vibration_heavy.impactOccurred()
                                            isEditing.toggle()
                                            focusField.toggle()
                                            editingContent = entry.content
                                        }
                                    }
                                Spacer()
                                    .frame(height: 10)
                            }
                            
                        }
                        
                    }
                    if isEditing {
                        ZStack(alignment: .topTrailing) {
                            VStack {
                                Spacer()
                                    .frame(height: 20)
                                TextField(entry.content, text: $editingContent, axis: .vertical)
                                    .focused($focusField)
                                    .onSubmit {
                                        finalizeEdit()
                                    }
                                    .foregroundColor(foregroundColor(entry: entry, background: entry.color)).opacity(0.6) //to determinw whether black or white
                                
//                                ZStack(alignment: .topLeading) {
//                                    if entry.imageContent != "" {
//                                        if entry.imageContent != "" {
//                                            if let filename = entry.imageContent {
//                                                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//                                                let fileURL = documentsDirectory.appendingPathComponent(filename)
//                                                AsyncImage(url: fileURL) { image in
//                                                    image.resizable()
//                                                        .scaledToFit()
//                                                }
//                                            placeholder: {
//                                                ProgressView()
//                                            }
//                                            }
//                                        }
//
//                                        Image(systemName: "minus.circle") // Cancel button
//                                            .foregroundColor(.red).opacity(0.8)
//                                            .onTapGesture {
//                                                vibration_medium.impactOccurred()
//                                                deleteImage() // Function to discard changes
//                                            }
//                                            .padding()
//                                    }
//                                }
                                if entry.imageContent != nil && entry.imageContent != "" {
                                    if let filename = entry.imageContent {
                                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                        let fileURL = documentsDirectory.appendingPathComponent(filename)
                                        AsyncImage(url: fileURL) { phase in
                                            switch phase {
                                            case .success(let image):
                                                ZStack(alignment: .topLeading) {
                                                    image.resizable().scaledToFit()
                                                    Image(systemName: "minus.circle") // Cancel button
                                                        .foregroundColor(.red).opacity(0.8)
                                                        .onTapGesture {
                                                            vibration_medium.impactOccurred()
                                                            deleteImage() // Function to discard changes
                                                        }
                                                        .padding()
                                                }
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
                            
                            VStack {
                                HStack {
                                    Image(systemName: "xmark") // Cancel button
                                        .onTapGesture {
                                            vibration_heavy.impactOccurred()
                                            cancelEdit() // Function to discard changes
                                        }
                                    Spacer()
                                    
                                    
                                    PhotosPicker(selection:$selectedItem, matching: .images) {
                                        Image(systemName: "photo.fill")
                                            .symbolRenderingMode(.multicolor)
                                            .font(.custom("serif", size: 16))
                                    }
                                    .onChange(of: selectedItem) { _ in
                                        Task {
                                            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                                let uniqueFilename = UUID().uuidString + ".png"
                                                let fileURL = documentsDirectory.appendingPathComponent(uniqueFilename)
                                                try? data.write(to: fileURL)
                                                entry.imageContent = uniqueFilename
                                                return
                                            }
                                        }
                                        //                                        Task {
                                        //                                            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                        ////                                                let uiImage = UIImage(data: data)
                                        //                                                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                        //                                                let fileURL = documentsDirectory.appendingPathComponent("imageContent.png")
                                        //                                                try? data.write(to: fileURL)
                                        //                                                entry.imageContent = fileURL.absoluteString
                                        //                                                print("File URL: \(fileURL)")
                                        //                                                return
                                        //                                            }
                                        //                                        }
                                    }
                                    
                                    Spacer()
                                        .frame(width: 20)
                                    
                                    Image(systemName: "checkmark")
                                        .onTapGesture {
                                            withAnimation() {
                                                vibration_heavy.impactOccurred()
                                                finalizeEdit()
                                            }
                                        }
                                }
                                .foregroundColor(foregroundColor(entry: entry, background: entry.color)) //to determinw whether black or white
                                
                                Spacer()
                                    .frame(height: 10)
                                
                            }
                        }
                        
                    }
                    
                }
            }
            
            .listRowBackground(backgroundColor(entry: entry))
        }
    }
    
    func finalizeEdit() {
        // Code to finalize the edit
        entry.content = editingContent
        do {
            try viewContext.save()
        } catch {
            print("Error updating entry content: \(error)")
        }
        isEditing = false
        focusField = false
    }
    
    func cancelEdit() {
        editingContent = entry.content // Reset to the original content
        isEditing = false // Exit the editing mode
    }
    
    func deleteImage() {
        if let filename = entry.imageContent {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            do {
                print("file URL from deleteImage: \(fileURL)")
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Error deleting image file: \(error)")
            }
        }
        
        entry.imageContent = ""
        
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    
    private func foregroundColor(entry: Entry, background: UIColor) -> Color {
        
        let color = colorScheme == .dark ? Color.white : Color.black
        if (entry.buttons.filter{$0}.count == 0) {
            return color
        }
        
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
        
        if entry.buttons.count < 5 {
            print("true")
            entry.buttons = [true, false, false, false, false]
        }
        
        for index in 0..<5 {
            if entry.buttons[index] {
                return Color(entry.color).opacity(opacity_val)
            }
        }
        
        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
        entry.color = colorScheme == .dark ? UIColor(Color.white) : UIColor(Color.black)
        return Color(color)
    }
}

struct EntryRowView: View {
    @Environment(\.managedObjectContext) private var viewContext
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
    @FocusState private var focusField: Bool
    
    
    var body : some View {
        if (!entry.isFault) {
            //            Section(header: Text(entry.formattedTime(debug: "from entry row view")).font(.system(size: UIFont.systemFontSize))) {
            
            TextView(entry: entry, editingContent: $editingContent, isEditing: $isEditing)
                .environmentObject(userPreferences)
                .environment(\.managedObjectContext, viewContext)
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
    
    func finalizeEdit() {
        // Code to finalize the edit
        entry.content = editingContent
        do {
            try viewContext.save()
        } catch {
            print("Error updating entry content: \(error)")
        }
        isEditing = false
        focusField = false
    }
    
    private func activateButton(entry: Entry, index: Int) {
        if (index+1 > entry.buttons.count) {
            entry.buttons = [false, false, false, false, false]
            entry.buttons[index] = true
        }
        else {
            let val : Bool = !entry.buttons[index] //this is what it means to toggle
            entry.buttons = [false, false, false, false, false]
            entry.buttons[index] = val
        }
        entry.color = UIColor(userPreferences.selectedColors[index])
        entry.image = userPreferences.selectedImages[index]
        print("URL from inside activate button \(entry.imageContent)")
        //        entry.imageContent = []
        
        do {
            try viewContext.save()
            if entry.buttons[index] == true {
                markedEntries.button_entries[index].insert(entry)
            } else {
                markedEntries.button_entries[index].remove(entry)
            }
        } catch {
            print("Error toggling button \(index+1): \(error)")
        }
    }
    
    private func foregroundColor(entry: Entry, background: UIColor) -> Color {
        
        let color = colorScheme == .dark ? Color.white : Color.black
        if (entry.buttons.filter{$0}.count == 0) {
            return color
        }
        
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
        
        if entry.buttons.count < 5 {
            print("true")
            entry.buttons = [true, false, false, false, false]
        }
        
        for index in 0..<5 {
            if entry.buttons[index] {
                return Color(entry.color).opacity(opacity_val)
            }
        }
        
        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
        entry.color = colorScheme == .dark ? UIColor(Color.white) : UIColor(Color.black)
        return Color(color)
    }
}



struct EntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var currentDateFilter = formattedDate(Date())
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
        predicate: NSPredicate(format: "day == %@", formattedDate(Date()))
    ) var logs: FetchedResults<Log> // should only be 1 log
    
    
    @FetchRequest(entity: Entry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: true)]) var entries : FetchedResults<Entry>
    @FocusState private var focusField: Bool
    
    
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
    //    @State private var editingEntry = false
    
    
    var body: some View {
        NavigationView {
            List {
                validateDate()
                if let firstLog = logs.first, firstLog.relationship.count > 0 {
                    var sortedEntries: [Entry] {
                        if let firstLog = logs.first, firstLog.relationship.count > 0 {
                            return Array(firstLog.relationship as! Set<Entry>).sorted { $0.time > $1.time }
                        } else {
                            return []
                        }
                    }
                    
                    //                    var sortedEntries = Array(firstLog.relationship as! Set<Entry>).sorted { $0.time > $1.time }
                    ForEach(sortedEntries, id: \.id) { entry in
                        EntryRowView(entry: entry)
                            .environmentObject(userPreferences)
                            .environment(\.managedObjectContext, viewContext)
                        
                        
                        
                    }
                    
                    .onDelete { indexSet in
                        for index in indexSet {
                            let entryToDelete = sortedEntries[index]
                            print("Entry to delete: \(entryToDelete)")

                            
                            
                            // Delete the image file
                            
                            if let filename = entryToDelete.imageContent {
                                if entryToDelete.imageContent != "" {
                                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                    let fileURL = documentsDirectory.appendingPathComponent(filename)
                                    print("file URL from onDelete closure: \(fileURL)")
                                    
                                    do {
                                        try FileManager.default.removeItem(at: fileURL)
                                    } catch {
                                        print("Error deleting image file: \(error)")
                                    }
                                }
                            }
                            
                            
                            entryToDelete.relationship.removeFromRelationship(entryToDelete)
                            //                        sortedEntries.remove(at: index)
                            //                          sortedEntries.removeAll { $0.isDeleted }
                            viewContext.delete(entryToDelete)
                        }
                        
                        do {
                            try viewContext.save()
                            viewContext.refreshAllObjects()
                            
                            print("entry has been deleted")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                    
                    
                }
                else {
                    Text("No entries")
                        .foregroundColor(.gray)
                        .italic()
                }
                
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
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(userPreferences)
                
            }
        }
        
    }
    private func activateButton(entry: Entry, index: Int) {
        if (index+1 > entry.buttons.count) {
            entry.buttons = [false, false, false, false, false]
            entry.buttons[index] = true
        }
        else {
            let val : Bool = !entry.buttons[index] //this is what it means to toggle
            entry.buttons = [false, false, false, false, false]
            entry.buttons[index] = val
        }
        entry.color = UIColor(userPreferences.selectedColors[index])
        entry.image = userPreferences.selectedImages[index]
        print("URL from inside activate button \(entry.imageContent)")
        
        //        entry.imageContent = []
        
        do {
            try viewContext.save()
            if entry.buttons[index] == true {
                markedEntries.button_entries[index].insert(entry)
            } else {
                markedEntries.button_entries[index].remove(entry)
            }
        } catch {
            print("Error toggling button \(index+1): \(error)")
        }
    }
    
    
    func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    private func deleteEntry(at offsets: IndexSet, from entries: [Entry]) {
        
        for index in offsets {
            let entryToDelete = entries[index]
            viewContext.delete(entryToDelete)
        }
        
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    private func fetchMarkedEntries() { //fetches important entries before loading the view
        let fetchRequest_1: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest_1.predicate = NSPredicate(format: "buttons[0] == %@", NSNumber(value: true))
        
        let fetchRequest_2: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest_2.predicate = NSPredicate(format: "buttons[1] == %@", NSNumber(value: true))
        
        let fetchRequest_3: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest_3.predicate = NSPredicate(format: "buttons[2] == %@", NSNumber(value: true))
        
        let fetchRequest_4: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest_4.predicate = NSPredicate(format: "buttons[3] == %@", NSNumber(value: true))
        
        let fetchRequest_5: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest_5.predicate = NSPredicate(format: "buttons[4] == %@", NSNumber(value: true))
        
        
        
        
        do {
            let button1_entriesArray = try viewContext.fetch(fetchRequest_1)
            markedEntries.button_entries[0] = Set(button1_entriesArray)
            
            let button2_entriesArray = try viewContext.fetch(fetchRequest_2)
            markedEntries.button_entries[1] = Set(button2_entriesArray)
            
            
            let button3_entriesArray = try viewContext.fetch(fetchRequest_3)
            markedEntries.button_entries[2] = Set(button3_entriesArray)
            
            let button4_entriesArray = try viewContext.fetch(fetchRequest_4)
            markedEntries.button_entries[3] = Set(button4_entriesArray)
            
            
            let button5_entriesArray = try viewContext.fetch(fetchRequest_5)
            markedEntries.button_entries[4] = Set(button5_entriesArray)
        } catch {
            print("Error fetching marked entries: \(error)")
        }
    }
    
    
    private func deleteEntry(entry: Entry) {
        let parentLog = entry.relationship
        parentLog.removeFromRelationship(entry)
        viewContext.delete(entry)
        do {
            try viewContext.save()
        } catch {
            print("Error deleting entry: \(error)")
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
    
    func finalizeEdit() {
        // Code to finalize the edit
        editingEntry?.content = editingContent
        do {
            try viewContext.save()
        } catch {
            print("Error updating entry content: \(error)")
        }
        isEditing = false
        editingEntry = nil
        
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
    @State private var selectedData: Data?
    @State private var filename = ""
    //    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    //    let fileURL = documentsDirectory.appendingPathComponent("imageContent.png")
    
    
    
    @State private var entryContent = ""
    
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $entryContent)
                    .overlay(
                        HStack {
                            Spacer()
                            Button(action: startOrStopRecognition) {
                                Image(systemName: "mic.fill")
                                    .foregroundColor(isListening ? userPreferences.accentColor : oppositeColor(of: userPreferences.accentColor))
                                    .font(.custom("serif", size: 24))
                            }
                            .padding(.trailing)
                            PhotosPicker(selection:$selectedItem, matching: .images) {
                                Image(systemName: "photo.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .foregroundColor(oppositeColor(of: userPreferences.accentColor))
                                    .font(.custom("serif", size: 24))
                                
                            }
                            .onChange(of: selectedItem) { _ in
          
                                Task {
                                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                        let uniqueFilename = UUID().uuidString + ".png"
                                        let fileURL = documentsDirectory.appendingPathComponent(uniqueFilename)
                                        try? data.write(to: fileURL)
                                        filename = uniqueFilename
                                        //                                            entry.imageContent = uniqueFilename
                                        return
                                    }
                                }
                                //                                }
                            }
                        }, alignment: .bottomTrailing
                    )
                    .padding()
                
                //                if let imageData = selectedData {
                //                    if let image = UIImage(data: imageData) {
                //                        Image(uiImage: image)
                //                            .resizable()
                //                            .scaledToFit()
                //                    }
                //                }
                if filename != "" {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsDirectory.appendingPathComponent(filename)
                    AsyncImage(url: fileURL) { image in
                        image.resizable()
                            .scaledToFit()
                    }
                placeholder: {
                    ProgressView()
                }
                }
                
            }
            .navigationBarTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let fileURL = documentsDirectory.appendingPathComponent("imageContent.png")
                        
                        
                        let color = colorScheme == .dark ? Color.white : Color.black
                        let newEntry = Entry(context: viewContext)
                        
                        if filename != "" {
                            newEntry.imageContent = filename
                        }
                        //                        let imageData: Data = selectedImage.compactMap { $0.pngData() }
                        
                        //                        if selectedData != nil {
                        //                            newEntry.imageContent = filename
                        ////                            newEntry.imageContent = selectedData
                        //
                        //                        }
                        //                        else {
                        //                            newEntry.imageContent = ""
                        //                        }
                        
                        newEntry.content = entryContent
                        newEntry.time = Date()
                        newEntry.buttons = [false, false, false, false, false]
                        newEntry.color = UIColor(color)
                        newEntry.image = "star.fill"
                        newEntry.id = UUID()
                        
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
                        Image(systemName: "checkmark.circle.fill")
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
}



