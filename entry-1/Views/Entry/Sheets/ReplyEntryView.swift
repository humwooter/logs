//
//  ReplyEntryView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 5/4/24.
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
import UniformTypeIdentifiers
import PDFKit
import EventKit


struct ReplyEntryView: View, UserPreferencesProvider, EntryCreationProvider {
    var eventManager: EventManager  = EventManager()
    
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var datesModel: DatesModel
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var coreDataManager: CoreDataManager

    
    
    
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var isListening = false
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @FocusState private var focusField: Bool
    
    
    @State private var selectedItem : PhotosPickerItem?
    @State private var selectedImage : UIImage?
    @State  var selectedData: Data? //used for gifs
    @State private var selectedPDFLink: URL? //used for gifs

    @State private var isCameraPresented = false
    @State private var filename = ""
    @State private var imageData : Data?
    @State private var imageIsAnimated = false
    @State private var isHidden = false
    @State private var isDocumentPickerPresented = false
    
    
    
    @State  var entryContent = ""
    @State private var imageHeight: CGFloat = 0
    @State private var keyboardHeight: CGFloat = 0
    @State private var isFullScreen = false
    @State private var isTextButtonBarVisible: Bool = false
    @State private var cursorPosition: NSRange? = nil
    
    @State  var selectedDate : Date = Date()
    @State private var selectedTime = Date()

    @State private var selectedReminderDate : Date = Date()
    @State private var selectedReminderTime : Date = Date()


    @State private var showingDatePicker = false // To control the visibility of the date picker
    @ObservedObject var textEditorViewModel = TextEditorViewModel()
    
    
    @State private var showingReminderSheet = false
    @State private var selectedRecurrence = "None"
    @State private var reminderTitle: String = ""
    @State  var reminderId: String? = ""
    @State var eventId: String? = ""
    @State var replyEntryId: String? = "" //the id of the entry that is being replied to with this current new one
    @State private var hasReminderAccess = false
    
    @State private var showDeleteReminderAlert = false
    // Define your recurrence options
    let recurrenceOptions = ["None", "Daily", "Weekly", "Weekends", "Biweekly", "Monthly"]

    @State var isEditing = false //for being able to use NotEditingView for repliedEntryView
    @State var entryBackgroundColor: Color = Color.clear
    @StateObject  var reminderManager: ReminderManager

    @State private var showTagSelection = false
    @State private var showFolderSelection = false
    @State private var showEntryNameSelection = false
    @State private var showingEntryTitle = false
    @State private var entryTitle: String = ""
    @State private var entryId: UUID = UUID()
    @State private var folderId: String?
    
    @State  var selectedTags: [String] = []


    
    @StateObject var tagViewModel: TagViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                    VStack {
                        HStack() {
                            Spacer()
                            if let reminderId = reminderId, !reminderId.isEmpty {
                                Image(systemName: "bell.fill").foregroundStyle(userPreferences.reminderColor)
                                    .font(.system(size: 20))
                                    .padding(.horizontal)
                            }
                        }
                        finalRepliedView()
                        Spacer()
                    }
                    .onTapGesture {
                        focusField = true
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
                                    .padding([.leading, .bottom])
                            }
                        }
                        
                        if isTextButtonBarVisible {
                            textFormattingButtonBar()
                        }
                        Spacer()
                    }
                    buttonBar()
                }.padding(.bottom)
              
           
            }
     
            .background {
                userPreferences.backgroundView(colorScheme: colorScheme)
            }
            .fullScreenCover(isPresented: $isCameraPresented) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera).ignoresSafeArea()
            }
            
            .navigationBarTitle(entryTitle.isEmpty ? "New Reply" : entryTitle)
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
                
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button {
//                        vibration_heavy.impactOccurred()
//                        //delete any reminders if set:
//                        // Delete any reminders if set:
//                        reminderManager.deleteReminder(reminderId: reminderId) { result in
//                            switch result {
//                            case .success:
//                                // Handle successful deletion, e.g., clear the reminderId or show a confirmation message
//                                print("Reminder successfully deleted.")
//                                self.reminderId = "" // Optionally clear the reminderId if it was deleted
//                            case .failure(let error):
//                                // Handle the error, e.g., show an alert or log the error
//                                print("Failed to delete reminder: \(error.localizedDescription)")
//                                // You could also present an alert to the user here if needed
//                            }
//                        }
//
//                        presentationMode.wrappedValue.dismiss()
//                    } label: {
//                        Image(systemName: "chevron.left")
//                            .font(.customHeadline)
////                            .font(.
//                    }
//                }
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
//                    saveReminder()
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
        
        .onTapGesture {
            focusField = true
            keyboardHeight = UIScreen.main.bounds.height/3
        }
       
    }
    
    
    
    private func saveReminder() {
//        if let reminderId = reminderId, reminderId.isEmpty {
//            self.reminderId = UUID().uuidString
//        }
//        reminderManager.createOrUpdateReminder(reminderId: reminderId) { result in
//            switch result {
//            case .success(let savedReminderId):
//                DispatchQueue.main.async {
//                    self.reminderId = savedReminderId
//                    print("Reminder saved with ID: \(savedReminderId)")
//                    // Optionally, update any related data here
//                }
//            case .failure(let error):
//                print("Failed to save reminder: \(error)")
//                DispatchQueue.main.async {
//                    self.reminderId = ""
//                }
//            }
//        }
    }


    @ViewBuilder
    func toolbarMenu() -> some View {
        Menu("", systemImage: "ellipsis.circle") {
            
            Button {
//                                showingEntryTitle = true
                showEntryNameSelection = true
            } label: {
//                                Text("Add Name")
                Label("Add Name", systemImage: "pencil")
            }
            
            Button {
                showingDatePicker.toggle()

            } label: {
                Label("Edit Date", systemImage: "calendar")
            }
            
            Button {
                showingReminderSheet = true

            } label: {
                Label(!reminderManager.reminderExists(with: reminderId ?? "") ? "Add Reminder" :
                        "Edit Reminder", systemImage: "bell.fill")
            }
            
            Button {
                showTagSelection = true
            } label: {
                Label("Add tag", systemImage: "number")
            }
            
            Button {
                showFolderSelection = true
            } label: {
                Label("Add to folder", systemImage: "folder.fill")
            }
            
        }.font(.customHeadline)
    }
    
    @ViewBuilder
    func finalRepliedView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Spacer()

                repliedEntryView().padding([.leading, .top, .bottom]).padding([.leading, .top])
                    .overlay {
                        VStack {
                            Spacer()
                            HStack {
                                UpperLeftCornerShape(cornerRadius: 20, extendLengthX: 6, extendLengthY: 6)
                                    .stroke(lineWidth: 2)
                                    .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.13))
                                    .frame(maxWidth: .infinity, maxHeight: 5) // Correctly size the frame based on the shape dimensions
                                Spacer()
                            }
                        }.padding(.bottom)
                    }
               

            }.padding(.horizontal)
            textFieldView()
            Spacer()
           }
    }
    
    @ViewBuilder
    func textFieldView() -> some View {
        
        VStack (alignment: .leading) {

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
            
            HStack {

                entryMediaView().cornerRadius(15.0).padding(10).scaledToFit().frame(minHeight: 0)
             
      
            }
        }.background {
            ZStack {
                Color(UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))))).opacity(0.05)
            }.ignoresSafeArea(.all)
        }.cornerRadius(15)
            .padding([.leading, .trailing, .top])
//        .padding()
            .onSubmit {
                finalizeCreation()
//                finalizeCreation {
////                    saveReminder()
//                } saveEvent: {
////                    saveEvent()
//                }
            }
    }
    
    @ViewBuilder
    func dateEditSheet() -> some View {
        VStack {
            HStack {
                Button("Cancel") {
                    showingDatePicker = false
                }.foregroundStyle(.red)
                Spacer()
                Button("Done") {
                    // Perform the action when the date is selected
                    showingDatePicker = false
                }.foregroundStyle(Color(UIColor.label))
            }
            .font(.customHeadline)
            .padding()
        }
    List {

        DatePicker("Edit Date", selection: $selectedDate)
            .presentationDetents([.fraction(0.25)])
            .font(.customHeadline)
            .foregroundColor(userPreferences.accentColor)
            .padding(.horizontal)
    }.navigationTitle("Select Custom Date")
    }

 
    @ViewBuilder
    func repliedEntrySectionHeader(entry: Entry) -> some View {
        HStack {
            Text("\(formattedDate(entry.time) == formattedDate(Date()) ? formattedTime(time: entry.time) : formattedDateTweetStyle(entry.time))")
                .foregroundStyle(getIdealHeaderTextColor().opacity(0.4))
                .padding(.leading)
            
                if let timeLastUpdated = entry.lastUpdated {
                    if formattedTimeLong(date: timeLastUpdated) != formattedTimeLong(date: entry.time), userPreferences.showMostRecentEntryTime {
                        HStack {
                            Image(systemName: "arrow.right")
                            Text(formattedTimeLong(date: timeLastUpdated))
                        }
                        .foregroundStyle(getIdealHeaderTextColor().opacity(0.4))
                    }

                }

            Image(systemName: entry.stampIcon).foregroundStyle(Color(entry.color))
            Spacer()
            
            if let reminderId = entry.reminderId, !reminderId.isEmpty, reminderManager.reminderExists(with: reminderId) {
                
                Label("", systemImage: "bell.fill").foregroundColor(userPreferences.reminderColor)
            }

            if (entry.isPinned) {
                Label("", systemImage: "pin.fill").foregroundColor(userPreferences.pinColor)

            }
        }
        .font(.customCaption)

    }
    
  
    @ViewBuilder
    func repliedEntryView() -> some View {
        if let replyEntryId = replyEntryId, !replyEntryId.isEmpty {
            if let repliedEntry = fetchEntryById(id: replyEntryId, coreDataManager: coreDataManager) {
                VStack(alignment: .trailing) {
                    repliedEntrySectionHeader(entry: repliedEntry)
                    NotEditingView_thumbnail(entry: repliedEntry, foregroundColor: UIColor(getDefaultEntryBackgroundColor(colorScheme: colorScheme)), repliedEntryBackgroundColor: $entryBackgroundColor, repliedEntry: repliedEntry)
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)
                            .background(entryBackgroundColor)
                            .cornerRadius(15.0)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                  RoundedRectangle(cornerRadius: 15)
                                    .stroke(getTextColor().opacity(0.05), lineWidth: 2)
                            )
                }
                .onAppear {
                    entryBackgroundColor = Color(UIColor.backgroundColor(entry: repliedEntry, colorScheme: colorScheme, userPreferences: userPreferences))
                }.scaledToFit()
                 
            
            }
        }
    }


    @ViewBuilder
    func entryMediaView() -> some View {
        ZStack(alignment: .topTrailing) {
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
            if selectedData != nil {
                Button(role: .destructive, action: {
                    vibration_light.impactOccurred()
                    selectedData = nil
                    imageHeight = 0
                }) {
                    Image(systemName: "x.circle").foregroundColor(.red.opacity(0.9)).frame(width: 25, height: 25).padding(2)
                        .foregroundColor(.red)
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
  
        .background(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.05)).ignoresSafeArea(.all)
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
            .onChange(of: selectedItem) { oldItem, newItem in
                selectedData = nil
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedData = data
                        imageHeight = UIScreen.main.bounds.height / 7
                    }
                }
            }

            
            Image(systemName: "camera.fill")
                .font(.buttonSize)
                .onChange(of: selectedImage) { oldImage, newImage in
                    selectedData = nil
                    Task {
                        if let data = newImage?.jpegData(compressionQuality: 0.7) {
                            selectedData = data
                            imageHeight = UIScreen.main.bounds.height / 7
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
        .background {
            ZStack {
                Color.clear
                LinearGradient(colors: [UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.05), Color.clear], startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()
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
        selectedData = nil
        
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}
