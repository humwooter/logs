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
    @State var editingContent: String = ""
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
    @StateObject private var reminderManager = ReminderManager()


    @State private var selectedDate : Date = Date()


    @State private var showingDatePicker = false
    
    @State private var isDocumentPickerPresented = false
    @State private var selectedPDFLink: URL? //used for gifs
    @State private var deletePrevMedia = false
    @ObservedObject var textEditorViewModel = TextEditorViewModel()
    @State private var cursorPosition: NSRange? = nil
    
    @State private var showingReminderSheet = false
    @State private var showDeleteReminderAlert = false
    @State private var showFolderSelection = false

    @State private var selectedTime = Date()
    @State private var selectedRecurrence = "None"
    @State private var reminderTitle: String = ""
    @State private var hasReminderAccess = false
    @State private var dateUpdated = false
    @State var repliedEntryBackgroundColor: Color = Color.clear

    // Define your recurrence options

//    @State private var selectedTagsName: String = ""
    @State private var selectedTagsName: [String] = []
    @State private var entryName: String = ""
    @State private var showTagSelection = false
     @State private var showEntryNameSelection = false
    let availableTags = ["Work", "Personal", "Urgent", "Ideas", "To-Do"]
    @State private var currentTags: [Tag: Bool] = [:]
    @StateObject var tagViewModel: TagViewModel

    var body : some View {
        NavigationStack {
            VStack {
                iconHeaderView()
                finalRepliedView()
     buttonBars()
            }
            .onAppear {
//                tagViewModel.initializeCurrentTags(with: entry.tagNames ?? "")
                selectedTagsName = entry.tagNames ?? []
                entryName = entry.title ?? ""
                if let reminderId = entry.reminderId {
                    reminderManager.fetchAndInitializeReminderDetails(reminderId: reminderId)
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
                if editingContent.isEmpty {
                    editingContent = entry.content
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera).ignoresSafeArea()
                
            }
            .navigationBarTitle("Editing Entry")
            .foregroundColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.systemGroupedBackground))))

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                  
                    HStack {
                        
                        Menu("", systemImage: "ellipsis.circle") {
                            
                            Button {
                                showEntryNameSelection = true
                            } label: {
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
                                Label("Set Reminder", systemImage: "bell.fill")
                            }
                            
                            Button {
                                showTagSelection = true
                            } label: {
                                Label("Add tag", systemImage: "number")
                            }
                            
                            Button {
                                showFolderSelection = true
                            } label: {
                                Label(entry.folderId?.isEmpty == false ? "Change Folder" : "Add to folder", systemImage: "folder.fill")
                            }
                        }
                        .font(.customHeadline)

                     
                        Button(action: {
                            vibration_heavy.impactOccurred()
                            finalizeEdit()
                            focusField = false
                        }) {
                            Text("Done").bold()
                                .font(.customHeadline)
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
                            .font(.customHeadline)
                    }
                }
            }
            .font(.customHeadline)
        }
        .overlay(
            CustomPopupView(isPresented: $showingDatePicker, title:
                                "Edit Date", onSave: {
                // Dismiss the view
                                    showingDatePicker = false
                                    dateUpdated = true
            }) {
                DateEditPopupView(selectedDate: $selectedDate)
                    .environmentObject(userPreferences)
            }
        )
        .overlay(
            CustomPopupView(isPresented: $showingReminderSheet, title:
                                entry.reminderId?.isEmpty == true ? "Reminder" : "Edit Reminder", onSave: {
                    saveReminder()
            }) {
                ReminderPopupView(
                    isPresented: $showingReminderSheet,
                    reminderTitle: $reminderManager.reminderTitle,
                    selectedReminderDate: $reminderManager.selectedReminderDate,
                    selectedReminderTime: $reminderManager.selectedReminderTime,
                    selectedRecurrence: $reminderManager.selectedRecurrence,
                    reminderNotes: $entry.content,
                    reminderId: $entry.reminderId,
                    showingReminderSheet: $showingReminderSheet,
                    showDeleteReminderAlert: $showDeleteReminderAlert,
                    reminderManager: reminderManager
                )
                .onAppear {
                    if let reminderId = entry.reminderId {
                        reminderManager.fetchAndInitializeReminderDetails(reminderId: reminderId)
                    } else {
                        entry.reminderId = UUID().uuidString
                    }
                    reminderManager.requestReminderAccess { _ in }
                }
            }
        )
        
        .overlay(
            CustomPopupView(isPresented: $showTagSelection, title: "Select Tags", onSave: {
                tagViewModel.saveSelectedTags(to: &selectedTagsName)

            }) {
                TagSelectionPopup(isPresented: $showTagSelection, entryId: $entry.id, selectedTagNames: $selectedTagsName, tagViewModel: tagViewModel)
                    .environmentObject(userPreferences)
                    .environmentObject(coreDataManager)

            }
        )
        .overlay(
            CustomPopupView(isPresented: $showFolderSelection, title: "Select Folder", onSave: {
                showFolderSelection = false

            }) {
                FolderSelectionView(isPresented: $showFolderSelection, folderId: $entry.folderId)
                    .environmentObject(userPreferences)
                    .environmentObject(coreDataManager)
            }
        )
        .overlay(
            CustomPopupView(isPresented: $showEntryNameSelection, title: "Entry Title" , onSave: {
                // Dismiss the view
                showEntryNameSelection = false

            }) {
                EntryNamePopup(isPresented: $showEntryNameSelection, entryName: $entryName)
                    .environmentObject(userPreferences)
            }
        )
   
        .onTapGesture {
            focusField = true
        }
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
    func entrySectionHeader(entry: Entry) -> some View {
        HStack {
                Text("\(entry.isPinned && formattedDate(entry.time) != formattedDate(Date()) ? formattedDateShort(from: entry.time) : formattedTime(time: entry.time))")
                .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))).opacity(0.4)
                if let timeLastUpdated = entry.lastUpdated {
                    if formattedTime_long(date: timeLastUpdated) != formattedTime_long(date: entry.time), userPreferences.showMostRecentEntryTime {
                        HStack {
                            Image(systemName: "arrow.right")
                            Text(formattedTime_long(date: timeLastUpdated))
                        }
                        .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))).opacity(0.4)
                    }

                }

            Image(systemName: entry.stampIcon).foregroundStyle(Color(entry.color))
            Spacer()
            
            if let reminderId = entry.reminderId, !reminderId.isEmpty, entry_1.reminderExists(with: reminderId) {
                
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
        if let replyEntryId = entry.entryReplyId, !replyEntryId.isEmpty {
            if let repliedEntry = fetchEntryById(id: replyEntryId, coreDataManager: coreDataManager) {
                
                VStack(alignment: .trailing) {
                                    entrySectionHeader(entry: repliedEntry)
                    NotEditingView_thumbnail(entry: repliedEntry, foregroundColor: UIColor(getDefaultEntryBackgroundColor(colorScheme: colorScheme)), repliedEntryBackgroundColor: $repliedEntryBackgroundColor, repliedEntry: entry)
                        .overlay(
                              RoundedRectangle(cornerRadius: 15)
                                  .stroke(getIdealTextColor().opacity(0.05), lineWidth: 1)
                        )
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)
                            .background(repliedEntryBackgroundColor)
                            .cornerRadius(15.0)
                            .frame(maxWidth: .infinity)
                        
          
                    
                }.scaledToFit()
                    .onAppear {
                        repliedEntryBackgroundColor = Color(UIColor.backgroundColor(entry: repliedEntry, colorScheme: colorScheme, userPreferences: userPreferences))

                    }
            }
        }
    }
    

    
    func getIdealTextColor() -> Color {
        let backgroundColor = isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear
        return Color(UIColor.fontColor(forBackgroundColor: UIColor(backgroundColor)))
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
    func iconHeaderView() -> some View {
        HStack() {
            Spacer()
            if let reminderId = entry.reminderId,  !reminderId.isEmpty {
                if (entry.stampIcon != "") {
                    Image(systemName: entry.stampIcon).foregroundStyle(Color(entry.color))

                }
                    Image(systemName: "bell.fill").foregroundStyle(userPreferences.reminderColor)
                        .padding(.horizontal)
            }
            else {
                Image(systemName: entry.stampIcon).foregroundStyle(Color(entry.color))
                    .padding(.horizontal)
            }
        }
        .font(.buttonSize)
    }
    

 
    
    @ViewBuilder
    func textFieldView() -> some View {
        VStack (alignment: .leading) {
            ZStack {
                if editingContent.isEmpty {
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
                GrowingTextField(text: $editingContent, fontName: userPreferences.fontName, fontSize: userPreferences.fontSize, fontColor: UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))), cursorColor: UIColor(userPreferences.accentColor),
                                 cursorPosition: $cursorPosition, viewModel: textEditorViewModel).cornerRadius(15)
                    .frame(minHeight: 50)

            }
            ZStack(alignment: .topTrailing) {
                entryMediaView().cornerRadius(15.0).padding(10).scaledToFit().frame(minHeight: 0)
                if selectedData != nil {
                    
                    Button(role: .destructive, action: {
                        vibration_light.impactOccurred()
                        selectedData = nil
                        selectedImage = nil
                    deletePrevMedia = true
                    }) {
                        Image(systemName: "x.circle").foregroundColor(.red.opacity(0.9)).frame(width: 25, height: 25).padding(15)                            .foregroundColor(.red)
                    }

                }
            }
        }.background {
            ZStack {
                Color(UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))))).opacity(0.05)
            }.ignoresSafeArea(.all)
        }.cornerRadius(15)
        .padding()
        .onSubmit {
            finalizeEdit()
        }
    }

    
    private func saveReminder() {
          reminderManager.createOrUpdateReminder(
            reminderId: entry.reminderId, // or the specific ID if editing an existing reminder
              title: reminderManager.reminderTitle,
              dueDate: reminderManager.selectedReminderDate,
              recurrence: reminderManager.selectedRecurrence,
              notes: "" // Any notes you want to add
          ) { result in
              switch result {
              case .success(let reminderId):
                  // Handle successful save, e.g., save reminderId to your data model
                  print("Reminder saved with ID: \(reminderId)")
              case .failure(let error):
                  // Handle error, e.g., show an alert to the user
                  print("Failed to save reminder: \(error)")
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
                                deletePrevMedia = true
//                                    entry.deleteImage(coreDataManager: coreDataManager)
                                    
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
//        .padding(.vertical, 10)
        .padding(.horizontal, 20)
//        .background(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.05))
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
                    .foregroundColor(!isListening ? userPreferences.accentColor : Color.complementaryColor(of: userPreferences.accentColor))
                    .font(.buttonSize)
            }
            Spacer()
        
            Button {
                vibration_heavy.impactOccurred()
                entry.isHidden.toggle()
            } label: {
                Image(systemName: entry.isHidden ? "eye.slash.fill" : "eye.fill")
                    .font(.buttonSize)
                    .foregroundColor(userPreferences.accentColor).opacity(entry.isHidden ? 1 : 0.1)
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
                        deletePrevMedia = true
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
                    .font(.buttonSize)
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
        .background {
            ZStack {
                Color.clear
                LinearGradient(colors: [UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.05), Color.clear], startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()
        }
        .foregroundColor(userPreferences.accentColor)
    }
    
    
    
    func finalizeEdit() {
          // Code to finalize the edit
        let mainContext = coreDataManager.viewContext
          mainContext.performAndWait {
              entry.content = editingContent
              
              entry.tagNames = selectedTagsName
              
              if formattedDate(entry.time) != formattedDate(selectedDate) { //change to correct log
                  let previousLog = entry.relationship
                  previousLog?.removeFromRelationship(entry)
                  if let log = fetchLogByDate(date: formattedDate(selectedDate), coreDataManager: coreDataManager) {
//                      entry.relationship = log
                      entry.logId = log.id
//                      log.addToRelationship(entry)
                  } else {
//                      createLog(date: selectedDate, coreDataManager: coreDataManager)
                  }
              }
              
              if entryName.isEmpty == false {
                  entry.title = entryName
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
        editingContent = entry.previousContent ?? entry.content // Reset to the original content
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



}
