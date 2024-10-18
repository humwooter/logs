//
//  NewEntryView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/28/23.
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
import UniformTypeIdentifiers
import PDFKit
import EventKit


struct NewEntryView: View, EntryCreationProvider {
    var replyEntryId: String? = ""
    
    // environment objects
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var datesModel: DatesModel
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var coreDataManager: CoreDataManager

    // state for speech recognition
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var isListening = false

    // state for image and document pickers
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State  var selectedData: Data? // for gifs
    @State private var selectedPDFLink: URL? // for pdfs
    @State private var isCameraPresented = false
    @State private var filename = ""
    @State private var imageData: Data?
    @State private var imageIsAnimated = false
    @State private var isHidden = false
    @State private var isDocumentPickerPresented = false

    // state for text entry and focus
    @State  var entryContent = ""
    @State private var dynamicHeight: CGFloat = 100
    @State private var imageHeight: CGFloat = 0
    @State private var keyboardHeight: CGFloat = 0
    @State private var isFullScreen = false
    @State private var isTextButtonBarVisible: Bool = false
    @State private var cursorPosition: NSRange? = nil
    @FocusState private var focusField: Bool

  

    // state for tags and entry details
    @State  var currentTags: [Tag: Bool] = [:]
    @State  var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()

    
    // state for editing and entry details
    @State var isEditing = false
    @State private var selectedStamp: Stamp?
    @State private var showingEntryTitle = false
    @State private var entryTitle: String = ""
    @State private var entryId: UUID = UUID()
    @State private var folderId: String?

    // temporary states
    @State private var tempEntryTitle: String = ""

    // state for tag selection
    @State  var selectedTags: [String] = []
    @State private var showTagSelection = false
    @State private var showFolderSelection = false
    @State private var showEntryNameSelection = false

    // state object for tag management
    @StateObject var tagViewModel: TagViewModel

    // available tags
    let availableTags = ["Work", "Personal", "Urgent", "Ideas", "To-Do"]
    
    // state for reminder popup
    @State private var showingReminderSheet = false
    @State private var selectedRecurrence = "None"
    @State var reminderId: String? = ""
    @State private var hasReminderAccess = false
    @State private var showDeleteReminderAlert = false
    let recurrenceOptions = ["None", "Daily", "Weekly", "Weekends", "Biweekly", "Monthly"]


    // state for event popup
    @State private var showingEventSheet = false
    @State  var eventId: String? = ""
    @State private var showDeleteEventAlert = false

    // state for date picker
    @State private var showingDatePicker = false // to control the visibility of the date picker

    // state for text editor
    @ObservedObject var textEditorViewModel = TextEditorViewModel()
    // state objects for reminder and event management
    @StateObject  var reminderManager: ReminderManager
    @StateObject  var eventManager: EventManager
    
    var body: some View {
        NavigationStack {
            VStack {
                    VStack {
                        
                        
                        
                        iconHeaderView()
                        
                        VStack {
                         entryTitleView()

                            textFieldView()
                        }
                    }
                    .onTapGesture {
                        focusField = true
                    }

   buttonBars()
           
            }
            .onAppear {
                if !reminderManager.hasReminderAccess {
                    print("CHECKING PERMISSIONS FOR REMINDERS")
                    reminderManager.checkReminderAccess(eventStore: eventStore)
                }
            }
            .background {
                    ZStack {
                        Color(UIColor.systemGroupedBackground)
                        LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                    }
                    .ignoresSafeArea()
            }
            .fullScreenCover(isPresented: $isCameraPresented) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera).ignoresSafeArea()
            }
            
            .navigationBarTitle(entryTitle.isEmpty ? "New Entry" : entryTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        toolbarMenu()
                      
            
                        Button(action: {
                            vibration_heavy.impactOccurred()
                            
                            finalizeCreation()
                            presentationMode.wrappedValue.dismiss()
                            focusField = false
                            keyboardHeight = 0
                        }) {
                            Text("Done")
                                .foregroundColor(userPreferences.accentColor)
                                .font(.customHeadline)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        vibration_heavy.impactOccurred()
                        //delete any reminders if set:
                        // Delete any reminders if set:
                        reminderManager.deleteReminder(reminderId: reminderId ?? "") { result in
                            switch result {
                            case .success:
                                // Handle successful deletion, e.g., clear the reminderId or show a confirmation message
                                print("Reminder successfully deleted.")
                                self.reminderId = "" // Optionally clear the reminderId if it was deleted
                            case .failure(let error):
                                // Handle the error, e.g., show an alert or log the error
                                print("Failed to delete reminder: \(error.localizedDescription)")
                                // You could also present an alert to the user here if needed
                            }
                        }

                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.customHeadline)
                    }
                }
            }
            .font(.customHeadline)

        }
        .overlay(
            CustomPopupView(isPresented: $showingDatePicker, height: 300, title:
                                "Edit Date", onSave: {
                // Dismiss the view
                                    showingDatePicker = false
            }) {
                DateEditPopupView(selectedDate: $selectedDate)
                    .environmentObject(userPreferences)
            }
        )
        .overlay(
            CustomPopupView(isPresented: $showTagSelection, title: "Select Tags", onSave: {
                // Dismiss the view
                showTagSelection = false
                tagViewModel.saveSelectedTags(to: &selectedTags)
                print("SELECTED TAGS: \(selectedTags)")
                // Then save the tags
            }) {
                TagSelectionPopup(isPresented: $showTagSelection, entryId: $entryId, selectedTagNames: $selectedTags, tagViewModel: tagViewModel)
                    .environmentObject(userPreferences)
                    .environmentObject(coreDataManager)
            }
        )
        .overlay(
            CustomPopupView(isPresented: $showFolderSelection, title: "Select Folder", onSave: {
                showFolderSelection = false

            }) {
                FolderSelectionView(isPresented: $showFolderSelection, folderId: $folderId)
                    .environmentObject(userPreferences)
                    .environmentObject(coreDataManager)
            }
        )
        .overlay(
            CustomPopupView(isPresented: $showEntryNameSelection, title: "Entry Title" , onSave: {
                // Dismiss the view
                showEntryNameSelection = false

            }) {
                EntryNamePopup(isPresented: $showEntryNameSelection, entryName: $entryTitle)
                    .environmentObject(userPreferences)
            }
        )
        .overlay(
            CustomPopupView(isPresented: $showingReminderSheet, title: "Reminder", onSave: {
                // Dismiss the view
//                showingReminderSheet = false
                // Then save the reminder
                if let reminderId = reminderId, reminderId.isEmpty {
                    self.reminderId = UUID().uuidString
                }
                
            }) {
                ReminderPopupView(
                    isPresented: $showingReminderSheet,
                    reminderTitle: $reminderManager.reminderTitle,
                    selectedReminderDate: $reminderManager.selectedReminderDate,
                    selectedReminderTime: $reminderManager.selectedReminderTime,
                    selectedRecurrence: $reminderManager.selectedRecurrence,
                    reminderNotes: $entryContent,
                    reminderId: $reminderId,
                    showingReminderSheet: $showingReminderSheet,
                    showDeleteReminderAlert: $showDeleteReminderAlert,
                    reminderManager: reminderManager
                )

            }
        )
        .overlay(
            CustomPopupView(isPresented: $showingEventSheet, title: "Event", onSave: {
                // Dismiss the view
//                showingReminderSheet = false
                // Then save the reminder
                if let eventId = eventId, eventId.isEmpty {
                    self.eventId = UUID().uuidString
                }
            }) {
                EventPopupView(
                    isPresented: $showingEventSheet,
                    eventTitle: $eventManager.eventTitle,
                    selectedEventStartDate: $eventManager.selectedEventStartDate,
                    selectedEventEndDate: $eventManager.selectedEventEndDate,
                    eventNotes: $eventManager.eventNotes,
                    eventId: $eventId,
                    showingEventSheet: $showingEventSheet,
                    showDeleteEventAlert: $showDeleteEventAlert,
                    eventManager: eventManager
                )
            }
        )

        .onTapGesture {
            focusField = true
            keyboardHeight = UIScreen.main.bounds.height/3
        }
       
    }
    
    @ViewBuilder
    func iconHeaderView() -> some View {
        HStack() {
            Spacer()
            if let reminderId = reminderId, !reminderId.isEmpty {
                if let eventId = eventId, !eventId.isEmpty {
                    Image(systemName: "calendar.badge.clock").foregroundStyle(userPreferences.reminderColor)

                }
                    Image(systemName: "bell.fill").foregroundStyle(userPreferences.reminderColor)
                        .padding(.horizontal)
            }
            else {
                if let eventId = eventId, !eventId.isEmpty {
                    Image(systemName: "calendar.badge.clock").foregroundStyle(userPreferences.accentColor)
                        .padding(.horizontal)
                }
            }
        }
        .font(.buttonSize)
    }
    
    
    
    private func saveEvent() {
        // Call the EventManager to create or update the event
        eventManager.createOrUpdateEvent(eventId: eventId) { result in
            switch result {
            case .success(let savedEventId):
                print("Event saved with ID: \(savedEventId)")
                // Optionally, update any related data here
            case .failure(let error):
                print("Failed to save event: \(error)")
            }
        }
    }

    private func saveReminder() {
        // Call the ReminderManager to create or update the reminder
        reminderManager.createOrUpdateReminder(reminderId: reminderId) { result in
            switch result {
            case .success(let savedReminderId):
                self.reminderId = savedReminderId
                print("Reminder saved with ID: \(savedReminderId)")
                // Optionally, update any related data here
            case .failure(let error):
                print("Failed to save reminder: \(error)")
            }
        }
    }

    
    
       func createOrUpdateReminder() {
           let combinedDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: selectedTime), minute: Calendar.current.component(.minute, from: selectedTime), second: 0, of: self.selectedDate) ?? Date()

           eventStore.requestAccess(to: .reminder) { granted, error in
               guard granted, error == nil else {
                   print("Access to reminders denied or failed.")
                   showingReminderSheet = false
                   return
               }

               if let reminderId = self.reminderId, reminderManager.reminderExists(with: reminderId) {
                   // Existing reminder found, update it
                   reminderManager.editAndSaveReminder(reminderId: reminderId, title: reminderManager.reminderTitle.isEmpty ? "Reminder" : reminderManager.reminderTitle, dueDate: combinedDateTime, recurrenceOption: self.selectedRecurrence) { success, updatedReminderId in
                       if success, let updatedReminderId = updatedReminderId {
                           self.reminderId = updatedReminderId
                           print("Reminder updated with identifier: \(updatedReminderId)")
                       } else {
                           print("Failed to update the reminder")
                       }
                       showingReminderSheet = false
                   }
               } else {
                   // No existing reminder, create a new one
                   reminderManager.createAndSaveReminder(title: reminderManager.reminderTitle.isEmpty ? "Reminder" : reminderManager.reminderTitle, dueDate: combinedDateTime, recurrenceOption: selectedRecurrence) { success, newReminderId in
                       if success, let newReminderId = newReminderId {
                           self.reminderId = newReminderId
                           print("New reminder created with identifier: \(newReminderId)")
                       } else {
                           print("Failed to create a new reminder")
                       }
                       showingReminderSheet = false
                   }
               }
           }
       }
    
    @ViewBuilder
    func toolbarMenu() -> some View {
        Menu("", systemImage: "ellipsis.circle") {
            
            // Menu for Entry and Date Management
            Menu("Manage Entry") {
                ControlGroup {
                    // Add Entry Name
                    Button {
                        showEntryNameSelection = true
                    } label: {
                        Label("Add Name", systemImage: "pencil")
                    }

                    // Edit Date
                    Button {
                        showingDatePicker.toggle()
                    } label: {
                        Label("Edit Date", systemImage: "calendar")
                    }
                }
            }

            // Menu for Event and Reminder Management
            Menu("Manage Events & Reminders") {
                ControlGroup {
                    // Add/Edit Event
                    Button {
                        showingEventSheet = true
                    } label: {
                        if let eventId = eventId, !eventId.isEmpty {
                            Label(eventId.isEmpty ? "Add Event" :
                                    "Edit Event", systemImage: "calendar.badge.clock")
                        }
                    }

                    // Add/Edit Reminder
                    Button {
                        showingReminderSheet = true
                    } label: {
                        Label(self.reminderId?.isEmpty == true ? "Add Reminder" :
                                "Edit Reminder", systemImage: "bell.fill")
                    }
                }
            }

            // Menu for Tag and Folder Management
            Menu("Manage Tags & Folders") {
                ControlGroup {
                    // Add Tag
                    Button {
                        showTagSelection = true
                    } label: {
                        Label("Add tag", systemImage: "number")
                    }

                    // Add to Folder
                    Button {
                        showFolderSelection = true
                    } label: {
                        Label("Add to folder", systemImage: "folder.fill")
                    }
                }
            }

        }
        .font(.customHeadline)
    }

    
    @ViewBuilder
    func entryTitleView() -> some View {
        if showingEntryTitle {
                        HStack {
                ZStack {
                    if tempEntryTitle.isEmpty {
                        HStack {
                            Text("Enter title")
                                .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.3))
                                .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                            Spacer()
                        }.padding(.horizontal, 20)
                    }
                    GrowingTextField(text: $tempEntryTitle, fontName: userPreferences.fontName, fontSize: userPreferences.fontSize, fontColor: UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))), cursorColor: UIColor(userPreferences.accentColor), isScrollEnabled: false, hasInset: false, cursorPosition: $cursorPosition, viewModel: textEditorViewModel).cornerRadius(15)
                        .frame(maxHeight: 30)
                }
                Spacer()
                Button {
                    entryTitle = tempEntryTitle
                    showingEntryTitle = false
                } label: {
                    Image(systemName: "checkmark").foregroundStyle(.green)
                }
                
            }.onAppear {
                tempEntryTitle = entryTitle
            }
            .padding(.horizontal)
            
            .onTapGesture {
                focusField = true
            }
//            .padding()
//            .padding(.horizontal)
            
            .cornerRadius(15)
        } else {

        }
//            .padding(.horizontal)
    }
    
    @ViewBuilder
    func buttonBars() -> some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.5)) {
                        isTextButtonBarVisible.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: isTextButtonBarVisible ? "chevron.left" : "text.justify.left")
                            .font(.buttonSize)
                            .foregroundColor(userPreferences.accentColor)
                            .padding()
                    }
                }
                
                if isTextButtonBarVisible {
                    textFormattingButtonBar()
                }
                Spacer()
            }
            buttonBar()
        }
    }
    
    
    @ViewBuilder
    func textFieldView() -> some View {
        VStack(alignment: .leading) {
            ZStack {
                if entryContent.isEmpty {
                    VStack {
                        HStack {
                            Text("Start typing here...")
                                .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.3))
                                .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                            Spacer()
                        }.padding(20)
                        Spacer()
                    }
                }
                GrowingTextField(text: $entryContent, fontName: userPreferences.fontName, fontSize: userPreferences.fontSize, fontColor: UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))), cursorColor: UIColor(userPreferences.accentColor), cursorPosition: $cursorPosition, viewModel: textEditorViewModel).cornerRadius(15)
            }
            
            ZStack(alignment: .topTrailing) {
                entryMediaView().cornerRadius(15.0).padding(10).scaledToFit()
                if selectedData != nil {
                    Button(role: .destructive, action: {
                        vibration_light.impactOccurred()
                        selectedData = nil
                        imageHeight = 0
                    }) {
                        Image(systemName: "x.circle").foregroundColor(.red.opacity(0.9)).frame(width: 25, height: 25).padding(15)                            .foregroundColor(.red)
                    }
                }
            }
        }
        .background {
            ZStack {
                Color(UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))))).opacity(0.05)
            }.ignoresSafeArea(.all)
        }
        .cornerRadius(15)
        .padding()
        .onSubmit {
            finalizeCreation()
        }
    }


    @ViewBuilder
    func entryMediaView() -> some View {
        if let data = selectedData {
            if isGIF(data: data) {
                AnimatedImageView_data(data: data)
                    .contextMenu {
                        Button(role: .destructive, action: {
                                selectedData = nil
                                imageHeight = 0
                        }) {
                            Text("Delete")
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
            } else if isPDF(data: data) { // Assuming you have an
                    PDFKitView(data: data)
                        .contextMenu {
                            Button(role: .destructive, action: {
                                    selectedData = nil
                                    imageHeight = 0
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
         
            } else {
                CustomAsyncImageView_uiImage(image: UIImage(data: data)!)
                    .contextMenu {
                        Button(role: .destructive, action: {
                                selectedData = nil
                                imageHeight = 0
                        }) {
                            Text("Delete")
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
            }
        }
    }
    @ViewBuilder
    func textFormattingButtonBar() -> some View {
        HStack(spacing: 35) {
            // Bullet Point Button
            Button(action: {
                self.textEditorViewModel.textToInsert = "\t• "
            }) {
                Image(systemName: "list.bullet")
                    .font(.buttonSize)
                    .foregroundColor(userPreferences.accentColor)
            }

            // Tab Button
            Button(action: {
                // Signal to insert a tab character.
                self.textEditorViewModel.textToInsert = "\t"
            }) {
                Image(systemName: "arrow.forward.to.line")
                    .font(.buttonSize)
                    .foregroundColor(userPreferences.accentColor)
            }

            // New Line Button
            Button(action: {
                // Signal to insert a new line.
                self.textEditorViewModel.textToInsert = "\n"
            }) {
                Image(systemName: "return")
                    .font(.buttonSize)
                    .foregroundColor(userPreferences.accentColor)
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.05))
        .cornerRadius(15)
    }

    @ViewBuilder
    func buttonBar() -> some View {
        HStack(spacing: 35) {
            
            
            Button(action: startOrStopRecognition) {
                Image(systemName: "mic.fill")
                    .foregroundColor(!isListening ? userPreferences.accentColor : Color.complementaryColor(of: userPreferences.accentColor))
                    .font(.buttonSize)
            }
            Spacer()
        
            Button {
                vibration_heavy.impactOccurred()
                isHidden.toggle()
            } label: {
                Image(systemName: isHidden ? "eye.slash.fill" : "eye.fill")
                    .font(.buttonSize)
                    .foregroundColor(userPreferences.accentColor).opacity(isHidden ? 1 : 0.1)
            }
            
            
            PhotosPicker(selection:$selectedItem, matching: .images) {
                Image(systemName: "photo.fill")
                    .font(.buttonSize)

            }
            .onChange(of: selectedItem) { _ in
                selectedData = nil
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                        selectedData = data
                        imageHeight = UIScreen.main.bounds.height/7
                    }
                }
            }

            
            Image(systemName: "camera.fill")
                .font(.buttonSize)
                .onChange(of: selectedImage) { _ in
                    selectedData = nil
                    Task {
                        if let data = selectedImage?.jpegData(compressionQuality: 0.7) {
                            selectedData = data
                            imageHeight = UIScreen.main.bounds.height/7
                        }
                    }
                }
                .onTapGesture {
                    vibration_heavy.impactOccurred()
                    isCameraPresented = true
                }
            
            Button {
                selectedData = nil
                vibration_heavy.impactOccurred()
                isDocumentPickerPresented = true
            } label: {
                Image(systemName: "link")
                    .font(.buttonSize)
            }
            .fileImporter(
                isPresented: $isDocumentPickerPresented,
                allowedContentTypes: [UTType.image, UTType.pdf], // Customize as needed
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    let url = urls[0]
                    do {
                        // Attempt to start accessing the security-scoped resource
                        if url.startAccessingSecurityScopedResource() {
                            // Here, instead of creating a bookmark, we read the file data directly
                            let fileData = try Data(contentsOf: url)
                            selectedData = fileData // Assuming selectedData is of type Data
                            imageHeight = UIScreen.main.bounds.height/7
                            
                            if isPDF(data: fileData) {
                                selectedPDFLink = url
                            }
                            
                            // Remember to stop accessing the security-scoped resource when you’re done
                            url.stopAccessingSecurityScopedResource()
                        } else {
                            // Handle failure to access the file
                            print("Error accessing file")
                        }
                    } catch {
                        // Handle errors such as file not found, insufficient permissions, etc.
                        print("Error reading file: \(error)")
                    }
                case .failure(let error):
                    // Handle the case where the document picker failed to return a file
                    print("Error selecting file: \(error)")
                }
            }
            
            
            
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.05))

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
        selectedData = nil
        
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}



struct PDFThumbnailRepresented : UIViewRepresentable {
    var pdfView : PDFView
    
    func makeUIView(context: Context) -> PDFThumbnailView {
        let thumbnail = PDFThumbnailView()
        thumbnail.pdfView = pdfView
        thumbnail.thumbnailSize = CGSize(width: 100, height: 100)
        thumbnail.layoutMode = .horizontal
        return thumbnail
    }
    
    func updateUIView(_ uiView: PDFThumbnailView, context: Context) {
        //do any updates you need
        //you could update the thumbnailSize to the size of the view here if you want, for example
        //uiView.thumbnailSize = uiView.bounds.size
    }
}
