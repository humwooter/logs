//
//  EditingEntryView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 12/19/23.
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
import EventKit

struct EditingEntryView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
//    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var userPreferences: UserPreferences

    @ObservedObject var entry: Entry
    @Binding var editingContent: String
    @Binding var isEditing: Bool
    @State private var engine: CHHapticEngine?
    @FocusState private var focusField: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showPhotos = false
    @State private var selectedData: Data?
    @State private var showCamera = false
    @State private var isListening = false
    
    
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    
    @State private var previousEntryContent: String = ""
    @State private var previousMediaFilename: String = ""
    @State private var previousMediaData: Data?
    @State var imageHeight: CGFloat = 0
    @State private var isTextButtonBarVisible: Bool = false
    

    @State private var selectedDate : Date = Date()


    @State private var showingDatePicker = false
    
    @State private var isDocumentPickerPresented = false
    @State private var selectedPDFLink: URL? //used for gifs
    @State private var deletePrevMedia = false
    @ObservedObject var textEditorViewModel = TextEditorViewModel()
    @State private var cursorPosition: NSRange? = nil
    
    @State private var showingReminderSheet = false
    @State private var showDeleteReminderAlert = false

    @State private var selectedTime = Date()
    @State private var selectedRecurrence = "None"
    @State private var reminderTitle: String = ""
    @State private var reminderId: String?
    @State private var hasReminderAccess = false
    @State private var dateUpdated = false

    // Define your recurrence options
    let recurrenceOptions = ["None", "Daily", "Weekly", "Weekends", "Biweekly", "Monthly"]

    
    var body : some View {
        NavigationStack {
            VStack {
                
                iconHeaderView()
                
                    VStack {
                        GrowingTextField(text: $editingContent, fontName: userPreferences.fontName, fontSize: userPreferences.fontSize, fontColor: UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))), cursorColor: UIColor(userPreferences.accentColor),
                                         cursorPosition: $cursorPosition, viewModel: textEditorViewModel).cornerRadius(15)
                            .padding()
    
                    }

                VStack {
                    HStack {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.5)) {
                                isTextButtonBarVisible.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: isTextButtonBarVisible ? "chevron.left" : "text.justify.left")
                                    .font(.system(size: 20))
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
                    entryMediaView()
                }
   
            }
            .onAppear {
                if let reminderId = entry.reminderId {
                    fetchAndInitializeReminderDetails(reminderId: reminderId)
                }
                
                if entry.relationship == nil {
                    let log = createLog(date: selectedDate, coreDataManager: coreDataManager)
                    entry.relationship = log
                    log.addToRelationship(entry)
                }
                print("ENTRY: \(entry)")
                if let lastUpdated = entry.lastUpdated {
                    print("\(formattedTime_long(date: lastUpdated))")
                }
            }
            .background {
                    ZStack {
                        Color(UIColor.systemGroupedBackground)
                        LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                    }
                    .ignoresSafeArea()
            }
            .onAppear {
                if let filename = entry.mediaFilename, previousMediaFilename.isEmpty {
                    previousMediaFilename = filename
                    previousMediaData = getMediaData(fromFilename: filename)
                    selectedData = previousMediaData
                }
                if !entry.content.isEmpty {
                    previousEntryContent = entry.content
                    editingContent = entry.content
                }

            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                
            }
            .sheet(isPresented: $showingDatePicker) {
                
                    VStack {
                        HStack {
                            Button("Cancel") {
                                showingDatePicker = false
                            }.foregroundStyle(.red)
                            Spacer()
                            Button("Done") {
                                // Perform the action when the date is selected
                                showingDatePicker = false
                                dateUpdated = true
                            }.foregroundStyle(Color(UIColor.label))
                        }
                        .font(.system(size: 15))
                        .padding()
                    }
                List {

                    DatePicker("Edit Date", selection: $selectedDate)
                        .presentationDetents([.fraction(0.25)])
                        .font(.system(size: 15))
                        .foregroundColor(userPreferences.accentColor)
                        .padding(.horizontal)
                    
                    
                    
                }.navigationTitle("Select Custom Date")
            }
            .sheet(isPresented: $showingReminderSheet) {
   reminderSheet()

                
                .onAppear {
                    if let reminderId = entry.reminderId {
                        fetchAndInitializeReminderDetails(reminderId: reminderId)
                    }
                    requestReminderAccess { granted in
                        if granted {
                            hasReminderAccess = true
                            print("Access to reminders granted.")
                        } else {
                            hasReminderAccess = false
                            print("Access to reminders denied or failed.")
                        }
                    }
                }
            }
            .navigationBarTitle("Editing Entry")
            .foregroundColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.systemGroupedBackground))))

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                  
                    HStack {
                        Menu("", systemImage: "ellipsis.circle") {
                            Button {
                                showingDatePicker.toggle()

                            } label: {
                                Label("Edit Date", systemImage: "calendar")
                            }
                            
                            Button {
                                showingReminderSheet = true

                            } label: {
                                Label("Set Reminder", systemImage: "bell.fill")
                            }
                        }
                     
                        Button(action: {
                            vibration_heavy.impactOccurred()
                            finalizeEdit()
                            focusField = false
                        }) {
                            Text("Done")
                                .font(.system(size: 15))
                                .foregroundColor(userPreferences.accentColor)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        vibration_heavy.impactOccurred()
                        cancelEdit() // Function to discard changes
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15))
                    }
                }
            }
        }
   
        .onTapGesture {
            focusField = true
        }
    }
    
    @ViewBuilder
    func iconHeaderView() -> some View {
        HStack() {
            Spacer()
            if let reminderId = entry.reminderId {
                if (entry.stampIcon != "") {
                    Image(systemName: entry.stampIcon).foregroundStyle(Color(entry.color))
                        .font(.system(size: 15))
                    
                }
                if let reminderId = entry.reminderId, !reminderId.isEmpty {
                    Image(systemName: "bell.fill").foregroundStyle(userPreferences.reminderColor)
                        .font(.system(size: 15))
                        .padding(.horizontal)
                }
            }
            else {
                Image(systemName: entry.stampIcon).foregroundStyle(Color(entry.color))
                    .font(.system(size: 15))
                    .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    func reminderSheet() -> some View {
        NavigationView {
            if hasReminderAccess {
                List {
                    Section {
                        TextField("Title", text: $reminderTitle)
                            .background(Color.clear) // Set the background to clear
                               .textFieldStyle(PlainTextFieldStyle()) // Use
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)

                    }
                    Section {
                        DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)

                    }
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                    .accentColor(userPreferences.accentColor)

                    NavigationLink {
                        List {
                            Picker("Recurrence", selection: $selectedRecurrence) {
                                ForEach(recurrenceOptions, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                            .font(.system(size: 15))
                            .pickerStyle(.inline)
                            .accentColor(userPreferences.accentColor)

                        }
                    } label: {
                        Label("Repeat", systemImage: "repeat")
                    }
      
                    .font(.system(size: 15))
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                    .accentColor(userPreferences.accentColor)
                    
                    Section {
              
                        
                        Button {
                            if let reminderId = entry.reminderId, !reminderId.isEmpty {
                                completeReminder(reminderId: reminderId) { success, error in
                                    if success {
                                        print("Reminder completed successfully.")
                                        entry.reminderId = ""
                                    } else {
                                        print("Failed to complete the reminder: \(String(describing: error))")
                                    }
                                }
                                print("Reminder completed")
                                showingReminderSheet = false
                            }
                        } label: {
                            Label("Complete", systemImage: "calendar.badge.checkmark")
                                .foregroundColor(.green)
                        }

                        Button {
                            showDeleteReminderAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .foregroundColor(.red)
                        }

                    }
                }
                    
                .alert("Are you sure you want to delete this reminder?", isPresented: $showDeleteReminderAlert) {
                          Button("Delete", role: .destructive) {
                              // Call your delete reminder function here
                              deleteReminder(reminderId: entry.reminderId)
                              showingReminderSheet = false
                          }
                          Button("Cancel", role: .cancel) {}
                      } message: {
                          Text("This action cannot be undone.")
                      }
                
                .background {
                        ZStack {
                            Color(UIColor.systemGroupedBackground)
                                .ignoresSafeArea()
                        }.cornerRadius(15.0)
                }
                .scrollContentBackground(.hidden)
                .font(.system(size: 15))
                .navigationTitle("Set Reminder")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingReminderSheet = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            createOrUpdateReminder()
                        }

                    }
                }
                .font(.system(size: 15))
                .padding()
            } else {
                Text("Reminder Permissions Disabled")
            }
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
                                selectedImage = nil
                            deletePrevMedia = true
                                
                        }) {
                            Text("Delete")
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
            } else {
                if isPDF(data: data) {
                    PDFKitView(data: data).scaledToFit()
                        .contextMenu {
                            Button(role: .destructive, action: {
                                    selectedData = nil
                                    selectedImage = nil
                                    entry.deleteImage(coreDataManager: coreDataManager)
                                    
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
                                    selectedImage = nil
                                deletePrevMedia = true
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
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
                // Signal to insert a bullet point at the current cursor position.
                // Update the viewModel's textToInsert property, which triggers the insertion.
                self.textEditorViewModel.textToInsert = "\t• "
            }) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 20))
                    .foregroundColor(userPreferences.accentColor)
            }

            // Tab Button
            Button(action: {
                // Signal to insert a tab character.
                self.textEditorViewModel.textToInsert = "\t"
            }) {
                Image(systemName: "arrow.forward.to.line")
                    .font(.system(size: 20))
                    .foregroundColor(userPreferences.accentColor)
            }

            // New Line Button
            Button(action: {
                // Signal to insert a new line.
                self.textEditorViewModel.textToInsert = "\n"
            }) {
                Image(systemName: "return")
                    .font(.system(size: 20))
                    .foregroundColor(userPreferences.accentColor)
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.05))
        .cornerRadius(15)
    }

    func insertText(_ textToInsert: String) {
        // Check if the editingContent already contains the marker to avoid duplication
        if editingContent.contains(cursorPositionMarker) {
            // If the marker is already present, replace it with the new text directly
            editingContent = editingContent.replacingOccurrences(of: cursorPositionMarker, with: textToInsert)
        } else {
            // If the marker is not present, insert the marker at the end of the text
            // This is a simplistic approach; you might have a more sophisticated method to determine the insertion point
            editingContent += cursorPositionMarker
            // Then replace the marker with the actual text to insert
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.editingContent = self.editingContent.replacingOccurrences(of: cursorPositionMarker, with: textToInsert)
            }
        }
    }

    @ViewBuilder
    func buttonBar() -> some View {
        HStack(spacing: 35) {
            
            
            Button(action: startOrStopRecognition) {
                Image(systemName: "mic.fill")
                    .foregroundColor(isListening ? userPreferences.accentColor : Color.complementaryColor(of: userPreferences.accentColor))
                    .font(.system(size: 20))
            }
            Spacer()
        
            Button {
                vibration_heavy.impactOccurred()
                entry.isHidden.toggle()
            } label: {
                Image(systemName: entry.isHidden ? "eye.slash.fill" : "eye.fill").font(.system(size: 20)).foregroundColor(userPreferences.accentColor).opacity(entry.isHidden ? 1 : 0.1)
            }
            
            
            PhotosPicker(selection:$selectedItem, matching: .images) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 20))
                
            }
            .onChange(of: selectedItem) { _ in
                selectedData = nil
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                        selectedData = data
                        deletePrevMedia = true
                        imageHeight = UIScreen.main.bounds.height/7
                    }
                }
            }

            
            Image(systemName: "camera.fill")
                .font(.system(size: 20))
                .onChange(of: selectedImage) { _ in
                    selectedData = nil
                    Task {
                        if let data = selectedImage?.jpegData(compressionQuality: 0.7) {
                            selectedData = data
                            deletePrevMedia = true
                            imageHeight = UIScreen.main.bounds.height/7
                        }
                    }
                }
                .onTapGesture {
                    vibration_heavy.impactOccurred()
                    showCamera = true
                }
            
            Button {
                selectedData = nil
                vibration_heavy.impactOccurred()
                isDocumentPickerPresented = true
            } label: {
                Image(systemName: "link")
                    .font(.system(size: 20))
            }
            .fileImporter(
                isPresented: $isDocumentPickerPresented,
                allowedContentTypes: [UTType.image, UTType.pdf],
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
                            
                            if isPDF(data: fileData) {
                                selectedPDFLink = url
                            }
                            
                            deletePrevMedia = true
                            
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
        .foregroundColor(userPreferences.accentColor)
    }
    
    
    
    func finalizeEdit() {
          // Code to finalize the edit
        let mainContext = coreDataManager.viewContext
          mainContext.performAndWait {
              entry.content = editingContent
              
              if formattedDate(entry.time) != formattedDate(selectedDate) { //change to correct log
//                  entry.removeLog(coreDataManager: coreDataManager)
                  let previousLog = entry.relationship
                  previousLog.removeFromRelationship(entry)
                  if let log = fetchLogByDate(date: formattedDate(selectedDate), coreDataManager: coreDataManager) {
                      entry.relationship = log
                      log.addToRelationship(entry)
                  } else {
                      let log = createLog(date: selectedDate, coreDataManager: coreDataManager)
                  }
              }
              
              if dateUpdated {
                  entry.time = selectedDate
              }
              entry.lastUpdated = Date() //added this

              //saving new data if it is picked -> we also need to delete previous data
              if deletePrevMedia {
                  
                  if let prevFilename = entry.mediaFilename {
                      previousMediaFilename = prevFilename
                  }
                  
                  print("deleting previous image")
                  deleteImage(with: previousMediaFilename)
                  
                  
                  if let data = selectedData { // new media data
                      if let savedFilename = saveMedia(data: data) { //save new media
                          entry.mediaFilename = savedFilename
                      } else {
                          print("Failed to save media.")
                      }
             
                  } else {
                      
                  }
              }

              
              // Save the context
              print("isEditing: \(isEditing)")
              coreDataManager.save(context: mainContext)
          }
          isEditing = false
      }
      
    func deleteImage(with mediaFilename: String?) {
        print("in delete image")
        let mainContext = coreDataManager.viewContext
        
        guard let filename = mediaFilename, !filename.isEmpty else {
            print("Filename is empty or nil, no image to delete.")
            return
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Image at \(fileURL) has been deleted")
            } catch {
                print("Error deleting image file: \(error)")
            }
        } else {
            print("File does not exist at path: \(fileURL.path)")
        }
    }
    
    func cancelEdit() {
        editingContent = entry.content // Reset to the original content
        if !previousMediaFilename.isEmpty, let data = previousMediaData { //restore previous media
            entry.saveImage(data: data, coreDataManager: coreDataManager)
        }
        isEditing = false // Exit the editing mode
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
                entry.content = result.bestTranscription.formattedString
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
    func createOrUpdateReminder() {
        let eventStore = EKEventStore()
        let combinedDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: selectedTime), minute: Calendar.current.component(.minute, from: selectedTime), second: 0, of: selectedDate) ?? Date()

        eventStore.requestAccess(to: .reminder) { granted, error in
            guard granted, error == nil else {
                print("Access to reminders denied or failed.")
                showingReminderSheet = false
                return
            }

            if let reminderId = entry.reminderId, reminderExists(with: reminderId, in: eventStore) {
                // Existing reminder found, update it
                editAndSaveReminder(reminderId: reminderId, title: reminderTitle.isEmpty ? "Reminder" : reminderTitle, dueDate: combinedDateTime, recurrenceOption: selectedRecurrence) { success, updatedReminderId in
                    if success, let updatedReminderId = updatedReminderId {
                        entry.reminderId = updatedReminderId
                        print("Reminder updated with identifier: \(updatedReminderId)")
                    } else {
                        print("Failed to update the reminder")
                    }
                    showingReminderSheet = false
                }
            } else {
                // No existing reminder, create a new one
                createAndSaveReminder(title: reminderTitle.isEmpty ? "Reminder" : reminderTitle, dueDate: combinedDateTime, recurrenceOption: selectedRecurrence) { success, newReminderId in
                    if success, let newReminderId = newReminderId {
                        entry.reminderId = newReminderId
                        print("New reminder created with identifier: \(newReminderId)")
                    } else {
                        print("Failed to create a new reminder")
                    }
                    showingReminderSheet = false
                }
            }
        }
    }
    func reminderExists(with identifier: String, in eventStore: EKEventStore) -> Bool {
        if let _ = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder {
            return true
        } else {
            return false
        }
    }


    
    func requestReminderAccess(completion: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .reminder) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func editAndSaveReminder(reminderId: String?, title: String, dueDate: Date, recurrenceOption: String, completion: @escaping (Bool, String?) -> Void) {
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .reminder) { granted, error in
            guard granted, error == nil else {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
                return
            }

            var reminder: EKReminder
            if let reminderId = reminderId, let existingReminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
                reminder = existingReminder
            } else {
                reminder = EKReminder(eventStore: eventStore)
                reminder.calendar = eventStore.defaultCalendarForNewReminders()
            }

            reminder.title = title
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            if let recurrenceRule = createRecurrenceRule(fromOption: recurrenceOption) {
                reminder.recurrenceRules = [recurrenceRule] // Replace existing rules with the new one
            }

            do {
                try eventStore.save(reminder, commit: true)
                DispatchQueue.main.async {
                    completion(true, reminder.calendarItemIdentifier)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        }
    }

    
    func createAndSaveReminder(title: String, dueDate: Date, recurrenceOption: String, completion: @escaping (Bool, String?) -> Void) {
        // Initialize the store.
        let eventStore = EKEventStore()

        // Request access to reminders.
        requestReminderAccess { granted in
            if granted {
                let reminder = EKReminder(eventStore: eventStore)
                reminder.calendar = eventStore.defaultCalendarForNewReminders()
                reminder.title = title
                reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
                
                // Set recurrence rule if applicable
                if let recurrenceRule = createRecurrenceRule(fromOption: recurrenceOption) {
                    reminder.addRecurrenceRule(recurrenceRule)
                }

                // Try to save the reminder
                do {
                    try eventStore.save(reminder, commit: true)
                    completion(true, reminder.calendarItemIdentifier) // Return success and the reminder identifier
                } catch {
                    completion(false, nil) // Return failure
                }
            } else {
                // Handle the case where permission is not granted
                completion(false, nil)
            }
        }
    }


    
    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (granted, error) in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func createRecurrenceRule(fromOption option: String) -> EKRecurrenceRule? {
        switch option {
        case "Daily":
            return EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)
        case "Weekly":
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil)
        case "Weekends":
            let rule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, daysOfTheWeek: [EKRecurrenceDayOfWeek(.saturday), EKRecurrenceDayOfWeek(.sunday)], daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: nil)
            return rule
        case "Biweekly":
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 2, end: nil)
        case "Monthly":
            return EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)
        default:
            return nil
        }
    }

    func fetchAndInitializeReminderDetails(reminderId: String?) {
        guard let reminderId = reminderId, !reminderId.isEmpty else { return }

        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .reminder) { granted, error in
            guard granted, error == nil else {
                print("Access to reminders denied or failed.")
                return
            }
            
            DispatchQueue.main.async {
                if let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
                    // Update title
                    reminderTitle = reminder.title ?? ""
                    
                    // Update date and time if dueDateComponents is available
                    if let dueDateComponents = reminder.dueDateComponents,
                       let dueDate = Calendar.current.date(from: dueDateComponents) {
                        selectedDate = dueDate
                        selectedTime = dueDate
                    }
                    
                    // Update recurrence option if a recurrence rule is available
                    if let recurrenceRule = reminder.recurrenceRules?.first,
                       let recurrenceOption = mapRecurrenceRuleToOption(recurrenceRule) {
                        selectedRecurrence = recurrenceOption
                    }
                }
            }
        }
    }
    func mapRecurrenceRuleToOption(_ rule: EKRecurrenceRule) -> String? {
        switch rule.frequency {
        case .daily:
            return "Daily"
        case .weekly:
            if rule.daysOfTheWeek?.count == 2,
               rule.daysOfTheWeek?.contains(EKRecurrenceDayOfWeek(.saturday)) == true,
               rule.daysOfTheWeek?.contains(EKRecurrenceDayOfWeek(.sunday)) == true {
                return "Weekends"
            }
            return "Weekly"
        case .monthly:
            return "Monthly"
        default:
            return nil
        }
    }


}
