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

struct NewEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var datesModel: DatesModel
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var coreDataManager: CoreDataManager
    @StateObject private var reminderManager = ReminderManager()

    
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
    @State private var selectedPDFLink: URL? //used for gifs

    @State private var isCameraPresented = false
    @State private var filename = ""
    @State private var imageData : Data?
    @State private var imageIsAnimated = false
    @State private var isHidden = false
    @State private var isDocumentPickerPresented = false
    
    
//    @State private var entryContent = ""
    @State private var entryContent = NSAttributedString(string: "")


    @State private var dynamicHeight: CGFloat = 100
    @State private var imageHeight: CGFloat = 0
    @State private var keyboardHeight: CGFloat = 0
    @State private var isFullScreen = false
    @State private var isTextButtonBarVisible: Bool = false
    @State private var cursorPosition: NSRange? = nil
    
    @State private var selectedDate : Date = Date()
    @State private var selectedTime = Date()



    @State private var showingDatePicker = false // To control the visibility of the date picker
    @ObservedObject var textEditorViewModel = TextEditorViewModel()
    
    
    @State private var showingReminderSheet = false
    @State private var showDeleteReminderAlert = false
    // Define recurrence options

    @State var isEditing = false //for being able to use NotEditingView for repliedEntryView
    
    @State private var selectedStamp: Stamp?
    
    @State private var showingEntryTitle = false
    @State private var entryTitle: String = ""
    @State private var tempEntryTitle: String = ""

    
    var body: some View {
        NavigationStack {
            VStack {
                    VStack {
                        
                        
                        HStack() {
                            Spacer()
                            if let reminderId = reminderManager.reminderId, !reminderId.isEmpty {
                                Image(systemName: "bell.fill").foregroundStyle(userPreferences.reminderColor)
                                    .font(.system(size: 15))
                                    .padding(.horizontal)
                            }
                        }
                        
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
                    NotificationCenter.default.addObserver(forName: NSNotification.Name("CreateEntryWithStamp"), object: nil, queue: .main) { notification in
                        if let stampId = notification.object as? UUID {
                            self.selectedStamp = userPreferences.fetchStamp(by: stampId)
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
            .fullScreenCover(isPresented: $isCameraPresented) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera).ignoresSafeArea()
            }
            

            .navigationBarTitle(entryTitle.isEmpty ? "New Entry" : entryTitle)


            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Menu("", systemImage: "ellipsis.circle") {
                            
                            Button {
                                showingEntryTitle = true
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
                                Label("Set Reminder", systemImage: "bell.fill")
                            }
                            
                        

                        }

                        .sheet(isPresented: $showingDatePicker) {
                            dateEditSheet()
                        }
                        .sheet(isPresented: $showingReminderSheet) {
                            reminderSheet()
                            .onAppear {
                                if let reminderId = reminderManager.reminderId {
                                    reminderManager.fetchAndInitializeReminderDetails(reminderId: reminderId) {
                                        print("success")
                                    }
                                }
                                reminderManager.requestReminderAccess { granted in
                                    if granted {
                                        reminderManager.hasReminderAccess = true
                                        print("Access to reminders granted.")
                                    } else {
                                        reminderManager.hasReminderAccess = false
                                        print("Access to reminders denied or failed.")
                                    }
                                }
                            }
                        }

            
                        Button(action: {
                            vibration_heavy.impactOccurred()
                            
                            finalizeCreation()
                            presentationMode.wrappedValue.dismiss()
                            focusField = false
                            keyboardHeight = 0
                        }) {
                            Text("Done")
//                                .font(.system(size: 15))
                                .foregroundColor(userPreferences.accentColor)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        vibration_heavy.impactOccurred()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
//                            .font(.system(size: 15))
                    }
                }
            }
            .font(.system(size: UIFont.systemFontSize))
   
        }
        
        .onTapGesture {
            focusField = true
            keyboardHeight = UIScreen.main.bounds.height/3
        }
       
    }
    

    
    @ViewBuilder
    func entryTitleView() -> some View {
        if showingEntryTitle {
            
            var fontColor = Color(UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))))
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
                    GrowingTextField(
                        attributedText: $tempEntryTitle.asAttributedString(
                            fontName: userPreferences.fontName,
                            fontSize: userPreferences.fontSize,
                            fontColor: UIColor(
                                UIColor.foregroundColor(
                                    background: UIColor(userPreferences.backgroundColors.first ?? Color.clear)
                                )
                            )
                        ),
                        fontName: userPreferences.fontName,
                        fontSize: userPreferences.fontSize,
                        fontColor: UIColor.black,
                        cursorColor: UIColor(userPreferences.accentColor),
                        backgroundColor: UIColor(userPreferences.backgroundColors.first ?? .black),
                        cursorPosition: $cursorPosition,
                        viewModel: textEditorViewModel
                    )

                    .cornerRadius(15)
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
        }
    }
    
    
    @ViewBuilder
    func textFieldView() -> some View {
        VStack(alignment: .leading) {
            ZStack {

            }
            
            ZStack {
                if entryContent.string.isEmpty {
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
                
                GrowingTextField(
                    attributedText: $entryContent,
                    fontName: userPreferences.fontName,
                    fontSize: userPreferences.fontSize,
                    fontColor: UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.clear))),
                    cursorColor: UIColor(userPreferences.accentColor),
                    backgroundColor: UIColor(userPreferences.backgroundColors.first ?? .black),
                    cursorPosition: $cursorPosition,
                    viewModel: textEditorViewModel
                )
                .cornerRadius(15)
//                GrowingTextField(text: $entryContent, fontName: userPreferences.fontName, fontSize: userPreferences.fontSize, fontColor: UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))), cursorColor: UIColor(userPreferences.accentColor), cursorPosition: $cursorPosition, viewModel: textEditorViewModel).cornerRadius(15)
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

    @ViewBuilder
    func reminderSheet() -> some View {
        NavigationStack {
            if reminderManager.hasReminderAccess {
                List {
                    Section {
                        TextField("Title", text: $reminderManager.reminderTitle)
                            .background(Color.clear) // Set the background to clear
                               .textFieldStyle(PlainTextFieldStyle()) // Use
                            .frame(maxWidth: .infinity)
//                            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)

                    }
                    Section {
                        DatePicker("Date", selection: $reminderManager.selectedDate, displayedComponents: .date)
                        DatePicker("Time", selection: $reminderManager.selectedTime, displayedComponents: .hourAndMinute)

                    }
//                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                    .accentColor(userPreferences.accentColor)

                    NavigationLink {
                        List {
                            Picker("Recurrence", selection: $reminderManager.selectedRecurrence) {
                                ForEach(reminderManager.recurrenceOptions, id: \.self) { option in
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
//                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                    .accentColor(userPreferences.accentColor)
                    
                    Section {
              
                        
                        Button {
                            if let reminderId = reminderManager.reminderId, !reminderId.isEmpty {
                                completeReminder(reminderId: reminderId) { success, error in
                                    if success {
                                        print("Reminder completed successfully.")
                                        reminderManager.reminderId = ""
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
                              deleteReminder(reminderId: reminderManager.reminderId)
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
                        }
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
                            reminderManager.createOrUpdateReminder { success in
                                                           showingReminderSheet = false
                                                       }
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

    @ViewBuilder
    func buttonBar() -> some View {
        HStack(spacing: 35) {
            
            
            Button(action: startOrStopRecognition) {
                Image(systemName: "mic.fill")
                    .foregroundColor(!isListening ? userPreferences.accentColor : Color.complementaryColor(of: userPreferences.accentColor))
                    .font(.system(size: 20))
            }
            Spacer()
        
            Button {
                vibration_heavy.impactOccurred()
                isHidden.toggle()
            } label: {
                Image(systemName: isHidden ? "eye.slash.fill" : "eye.fill").font(.system(size: 20)).foregroundColor(userPreferences.accentColor).opacity(isHidden ? 1 : 0.1)
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
                    .font(.system(size: 20))
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
//        .background(Color(UIColor.label).opacity(0.05))

    }
    
    func finalizeCreation() {
        let newEntry = Entry(context: viewContext)
        newEntry.id = UUID()
        newEntry.attributedContent = entryContent
        newEntry.content = entryContent.string

            // Convert NSAttributedString to Data and save formatted text
            do {
                let data = try entryContent.data(from: NSRange(location: 0, length: entryContent.length),
                                                 documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
                newEntry.formattedContent = data
            } catch {
                print("Error converting attributed string to data: \(error)")
            }
        newEntry.time = selectedDate
        newEntry.lastUpdated = nil
        print("entry time has been set")
        newEntry.stampIndex = -1
        
        newEntry.color = UIColor.clear
        newEntry.stampIcon = ""
        newEntry.isHidden = isHidden
        newEntry.isRemoved = false
        newEntry.isDrafted = false
        newEntry.isPinned = false
        newEntry.isShown = true
        newEntry.shouldSyncWithCloudKit = false
        newEntry.name = "" //change later
        if !entryTitle.isEmpty {
            newEntry.title = entryTitle
        }
        
        if let stamp = selectedStamp {
            newEntry.stampIndex = Int16(stamp.index)
            newEntry.color = UIColor(stamp.color)
            newEntry.stampIcon = stamp.imageName
        }
    
        
        if let data = selectedData {
            if let savedFilename = saveMedia(data: data) {
                newEntry.mediaFilename = savedFilename
                newEntry.mediaFilenames = [savedFilename] //
            } else {
                print("Failed to save media.")
            }
        }
        
        if let reminderId = reminderManager.reminderId {
            newEntry.reminderId = reminderId
        } else {
            newEntry.reminderId = ""
        }
        

        // Fetch the log with the appropriate day
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "day == %@", formattedDate(newEntry.time ?? Date()))
        
        do {
            let logs = try viewContext.fetch(fetchRequest)
            print("LOGS: ", logs)
            if let log = logs.first {
                log.addToRelationship(newEntry)
                newEntry.relationship = log
            } else {
                // Create a new log if needed
                let dateStringManager = DateStrings()
                let newLog = Log(context: viewContext)
                newLog.day = formattedDate(newEntry.time ?? Date())
                dateStringManager.addDate(newLog.day)
                newLog.addToRelationship(newEntry)
                newLog.id = UUID()
                newEntry.relationship = newLog
                
                let todayDate = Date()
                let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                let todayDateString = formattedDate(todayDate)  // Using formattedDate function
                datesModel.dates.append(LogDate(date: todayComponents, isSelected: false, hasLog: true))  // Start with today not selected
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
                 let plainText = result.bestTranscription.formattedString
                 let attributes: [NSAttributedString.Key: Any] = [
                     .font: UIFont(name: self.userPreferences.fontName, size: self.userPreferences.fontSize) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize),
                     .foregroundColor: UIColor(UIColor.foregroundColor(background: UIColor(self.userPreferences.backgroundColors.first ?? Color.clear)))
                 ]
                 self.entryContent = NSAttributedString(string: plainText, attributes: attributes)
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
