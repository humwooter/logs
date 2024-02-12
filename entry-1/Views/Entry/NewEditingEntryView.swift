////
////  NewEditingEntryView.swift
////  entry-1
////
////  Created by Katyayani G. Raman on 2/11/24.
////
//
//import Foundation
//
//
////
////  EditingEntryView.swift
////  entry-1
////
////  Created by Katyayani G. Raman on 12/19/23.
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
//
//struct EditingEntryView: View {
//    @EnvironmentObject var coreDataManager: CoreDataManager
////    @Environment(\.managedObjectContext) private var viewContext
//
//    @EnvironmentObject var userPreferences: UserPreferences
//
//    @Binding var editingContent: String
//    @Binding var isHidden: Bool
//    @Binding var content: String //the entry content
//    @Binding var stampIcon: String //the entry content
//    @Binding var mediaFilename: String?
//
//    @Binding var lastUpdated: Date? //the entry content
//    @Binding var entryColor: UIColor
//
//    
//    @Binding var isEditing: Bool
//    @State private var engine: CHHapticEngine?
//    @FocusState private var focusField: Bool
//    @Environment(\.colorScheme) var colorScheme
//    @State private var selectedItem: PhotosPickerItem?
//    @State private var selectedImage: UIImage?
//    @State private var showPhotos = false
//    @State private var selectedData: Data?
//    @State private var showCamera = false
//    @State private var isListening = false
//    
//    
//    @State private var speechRecognizer = SFSpeechRecognizer()
//    @State private var recognitionTask: SFSpeechRecognitionTask?
//    @State private var audioEngine = AVAudioEngine()
//    
//    
//    @State private var previousMediaFilename: String = ""
//    @State private var previousMediaData: Data?
//    @State var imageHeight: CGFloat = 0
//    @State private var isTextButtonBarVisible: Bool = false
//    
//    @State private var cursorPosition: NSRange? = nil
//
//    @State private var selectedDate : Date = Date()
//
//
//    @State private var showingDatePicker = false
//    
//    @State private var isDocumentPickerPresented = false
//    @State private var selectedPDFLink: URL? //used for gifs
//    @State private var deletePrevMedia = false
//
//    
//    var body : some View {
//        NavigationStack {
//            VStack {
//                
//                HStack() {
//                    Spacer()
//                    if (stampIcon != "") {
//                        Image(systemName: stampIcon).foregroundStyle(Color(entryColor))
//                            .font(.system(size: 15))
//                            .padding(.horizontal)
//                        
//                    }
//                }
//                
//                
////                ScrollView(.vertical, showsIndicators: true) {
//                    VStack {
//                        GrowingTextField(text: $editingContent, fontName: userPreferences.fontName, fontSize: userPreferences.fontSize, fontColor: UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))), cursorPosition: $cursorPosition).cornerRadius(15)
//                            .padding()
//    
//                    }
//
//                VStack {
//                    HStack {
//                        Button(action: {
//                            withAnimation(.easeOut(duration: 0.5)) {
//                                isTextButtonBarVisible.toggle()
//                            }
//                        }) {
//                            HStack {
////                                if (!isTextButtonBarVisible) {
////                                    Image(systemName: "text.justify.left")
////                                }
//                                Image(systemName: isTextButtonBarVisible ? "chevron.left" : "text.justify.left")
//                                    .font(.system(size: 20))
//                                    .foregroundColor(userPreferences.accentColor)
//                                    .padding()
//                            }
//                        }
//                        
//                        if isTextButtonBarVisible {
//                            textFormattingButtonBar()
//                        }
//                        Spacer()
//                    }
//                    buttonBar()
//                    if let data = selectedData {
//                        if isGIF(data: data) {
//                            AnimatedImageView_data(data: data)
//                                .contextMenu {
//                                    Button(role: .destructive, action: {
//                                            selectedData = nil
//                                            selectedImage = nil
//                                        deletePrevMedia = true
////                                            entry.deleteImage(coreDataManager: coreDataManager)
//                                            
//                                    }) {
//                                        Text("Delete")
//                                        Image(systemName: "trash")
//                                            .foregroundColor(.red)
//                                    }
//                                }
//                        } else {
//                            if isPDF(data: data) {
////                                if let url = selectedPDFLink {
////                                    AsyncPDFKitView(url: url).scaledToFit()
////                                        .contextMenu {
////                                            Button(role: .destructive, action: {
////                                                    selectedData = nil
////                                                    selectedImage = nil
////                                                deletePrevMedia = true
//////                                                    entry.deleteImage(coreDataManager: coreDataManager)
////
////                                            }) {
////                                                Text("Delete")
////                                                Image(systemName: "trash")
////                                                    .foregroundColor(.red)
////                                            }
////                                        }
////                                }
//                                PDFKitView(data: data).scaledToFit()
//                                    .contextMenu {
//                                        Button(role: .destructive, action: {
//                                                selectedData = nil
//                                                selectedImage = nil
//                                       
//                                            deletePrevMedia = true
//                                        }) {
//                                            Text("Delete")
//                                            Image(systemName: "trash")
//                                                .foregroundColor(.red)
//                                        }
//                                    }
//                            } else {
//                                CustomAsyncImageView_uiImage(image: UIImage(data: data)!)
//                                    .contextMenu {
//                                        Button(role: .destructive, action: {
//                                                selectedData = nil
//                                                selectedImage = nil
//                                            deletePrevMedia = true
////                                                entry.deleteImage(coreDataManager: coreDataManager)
//                                        }) {
//                                            Text("Delete")
//                                            Image(systemName: "trash")
//                                                .foregroundColor(.red)
//                                        }
//                                    }
//                            }
//                        }
//                    }
//                }
//   
//            }
//            .background {
//                    ZStack {
//                        Color(UIColor.systemGroupedBackground)
//                        LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
//                    }
//                    .ignoresSafeArea()
//            }
//            .onAppear {
//                if let filename = mediaFilename, previousMediaFilename.isEmpty {
//                    previousMediaFilename = filename
//                    previousMediaData = getMediaData(fromFilename: filename)
//                    selectedData = previousMediaData
//                }
//                if !content.isEmpty {
//                    editingContent = content
//                }
//            }
//            .sheet(isPresented: $showCamera) {
//                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
//                
//            }
//            .navigationBarTitle("Editing Entry")
//            .foregroundColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.systemGroupedBackground))))
//
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    
//                  
//                    HStack {
//                        Menu("", systemImage: "ellipsis.circle") {
//                            Button("Edit Date") {
//                                showingDatePicker.toggle()
//                            }
//                        }
//                     
//                        .sheet(isPresented: $showingDatePicker) {
//                            
//                                VStack {
//                                    HStack {
//                                        Button("Cancel") {
//                                            showingDatePicker = false
//                                        }.foregroundStyle(.red)
//                                        Spacer()
//                                        Button("Done") {
//                                            // Perform the action when the date is selected
//                                            showingDatePicker = false
//                                        }.foregroundStyle(Color(UIColor.label))
//                                    }
//                                    .font(.system(size: 15))
//                                    .padding()
//                                }
//                            List {
//
//                                DatePicker("Edit Date", selection: $selectedDate)
//                                    .presentationDetents([.fraction(0.25)])
//                                    .font(.system(size: 15))
//                                    .foregroundColor(userPreferences.accentColor)
//                                    .padding(.horizontal)
//                                
//                                
//                                
//                            }.navigationTitle("Select Custom Date")
//                        }
//                        
//                                     
//            
//                        Button(action: {
//                            vibration_heavy.impactOccurred()
//                            finalizeEdit()
//                            focusField = false
//                        }) {
//                            Text("Done")
//                                .font(.system(size: 15))
//                                .foregroundColor(userPreferences.accentColor)
//                        }
//                    }
//                }
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button {
//                        vibration_heavy.impactOccurred()
//                        cancelEdit() // Function to discard changes
//                    } label: {
//                        Image(systemName: "chevron.left")
//                            .font(.system(size: 15))
//                    }
//                }
//            }
//        }
//   
//        .onTapGesture {
//            focusField = true
//        }
//    }
//    
//    @ViewBuilder
//    func textFormattingButtonBar() -> some View {
//        HStack(spacing: 35) {
//            
//   
//            Button(action: {
//                let (newContent, newCursorPos) = insertOrAppendText("\t• ", into: editingContent, at: cursorPosition)
//                self.cursorPosition = newCursorPos
//                self.editingContent = newContent
//                vibration_heavy.impactOccurred()
//            }) {
//                Image(systemName: "list.bullet")
//                    .font(.system(size: 20))
//                    .foregroundColor(userPreferences.accentColor)
//            }
//
//            // Repeat similar logic for the other buttons
//
//
//            
//            // Tab button
//            Button(action: {
//                let (editingContent, cursorPosition) = insertOrAppendText("\t", into: editingContent, at: self.cursorPosition)
//                self.cursorPosition = cursorPosition
//                self.editingContent = editingContent
//                vibration_heavy.impactOccurred()
//            }) {
//                Image(systemName: "arrow.forward.to.line")
//                    .font(.system(size: 20))
//                    .foregroundColor(userPreferences.accentColor)
//            }
//
//            
//            // New Line button
//            Button(action: {
//                let (editingContent, cursorPosition) = insertOrAppendText("\n", into: editingContent, at: cursorPosition)
//                self.cursorPosition = cursorPosition
//                self.editingContent = editingContent
//                vibration_heavy.impactOccurred()
//            }) {
//                Image(systemName: "return")
//                    .font(.system(size: 20))
//                    .foregroundColor(userPreferences.accentColor)
//            }
//
//            Spacer()
//        }
//        .padding(.vertical, 10)
//        .padding(.horizontal, 20)
//        .background(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.05))
//        .cornerRadius(15)
//
//    }
//
//    @ViewBuilder
//    func buttonBar() -> some View {
//        HStack(spacing: 35) {
//            
//            
//            Button(action: startOrStopRecognition) {
//                Image(systemName: "mic.fill")
//                    .foregroundColor(isListening ? userPreferences.accentColor : Color.complementaryColor(of: userPreferences.accentColor))
//                    .font(.system(size: 20))
//            }
//            Spacer()
//        
//            Button {
//                vibration_heavy.impactOccurred()
//                isHidden.toggle()
//            } label: {
//                Image(systemName: isHidden ? "eye.slash.fill" : "eye.fill").font(.system(size: 20)).foregroundColor(userPreferences.accentColor).opacity(isHidden ? 1 : 0.1)
//            }
//            
//            
//            PhotosPicker(selection:$selectedItem, matching: .images) {
//                Image(systemName: "photo.fill")
//                    .font(.system(size: 20))
//                
//            }
//            .onChange(of: selectedItem) { _ in
//                selectedData = nil
//                Task {
//                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
//                        selectedData = data
//                        deletePrevMedia = true
//                        imageHeight = UIScreen.main.bounds.height/7
//                    }
//                }
//            }
//
//            
//            Image(systemName: "camera.fill")
//                .font(.system(size: 20))
//                .onChange(of: selectedImage) { _ in
//                    selectedData = nil
//                    Task {
//                        if let data = selectedImage?.jpegData(compressionQuality: 0.7) {
//                            selectedData = data
//                            deletePrevMedia = true
//                            imageHeight = UIScreen.main.bounds.height/7
//                        }
//                    }
//                }
//                .onTapGesture {
//                    vibration_heavy.impactOccurred()
//                    showCamera = true
//                }
//            
//            Button {
//                selectedData = nil
//                vibration_heavy.impactOccurred()
//                isDocumentPickerPresented = true
//            } label: {
//                Image(systemName: "link")
//                    .font(.system(size: 20))
//            }
//            .fileImporter(
//                isPresented: $isDocumentPickerPresented,
//                allowedContentTypes: [UTType.image, UTType.pdf],
//                allowsMultipleSelection: false
//            ) { result in
//                switch result {
//                case .success(let urls):
//                    let url = urls[0]
//                    do {
//                        // Attempt to start accessing the security-scoped resource
//                        if url.startAccessingSecurityScopedResource() {
//                            // Here, instead of creating a bookmark, we read the file data directly
//                            let fileData = try Data(contentsOf: url)
//                            selectedData = fileData // Assuming selectedData is of type Data
//                            
//                            if isPDF(data: fileData) {
//                                selectedPDFLink = url
//                            }
//                            
//                            deletePrevMedia = true
//                            
//                            // Remember to stop accessing the security-scoped resource when you’re done
//                            url.stopAccessingSecurityScopedResource()
//                        } else {
//                            // Handle failure to access the file
//                            print("Error accessing file")
//                        }
//                    } catch {
//                        // Handle errors such as file not found, insufficient permissions, etc.
//                        print("Error reading file: \(error)")
//                    }
//                case .failure(let error):
//                    // Handle the case where the document picker failed to return a file
//                    print("Error selecting file: \(error)")
//                }
//            }
//            
//            
//            
//        }
//        .padding(.vertical, 10)
//        .padding(.horizontal, 20)
//        .background(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))).opacity(0.05))
//        .foregroundColor(userPreferences.accentColor)
////        .background(Color(UIColor.label).opacity(0.05))
//
//    }
//    
//    
//    
//    func finalizeEdit() {
//          // Code to finalize the edit
//        let mainContext = coreDataManager.viewContext
//          mainContext.performAndWait {
//              content = editingContent
//              lastUpdated = selectedDate
//              
//              //saving new data if it is picked -> we also need to delete previous data
//              if deletePrevMedia {
//                  
//                  if let prevFilename = mediaFilename {
//                      previousMediaFilename = prevFilename
//                  }
//                  
//                  print("deleting previous image")
//                  deleteImage(with: previousMediaFilename)
//                  
//                  
//                  if let data = selectedData { // new media data
//                      if let savedFilename = saveMedia(data: data) { //save new media
//                          mediaFilename = savedFilename
//                      } else {
//                          print("Failed to save media.")
//                      }
//             
//                  } else {
//                      
//                  }
//              }
//
//              
//              // Save the context
//              print("isEditing: \(isEditing)")
//              coreDataManager.save(context: mainContext)
//          }
//          isEditing = false
//      }
//      
//    func deleteImage(with mediaFilename: String?) {
//        print("in delete image")
//        let mainContext = coreDataManager.viewContext
//        
//        guard let filename = mediaFilename, !filename.isEmpty else {
//            print("Filename is empty or nil, no image to delete.")
//            return
//        }
//        
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let fileURL = documentsDirectory.appendingPathComponent(filename)
//        
//        if FileManager.default.fileExists(atPath: fileURL.path) {
//            do {
//                try FileManager.default.removeItem(at: fileURL)
//                print("Image at \(fileURL) has been deleted")
//            } catch {
//                print("Error deleting image file: \(error)")
//            }
//        } else {
//            print("File does not exist at path: \(fileURL.path)")
//        }
//    }
//    
//    func cancelEdit() {
//        editingContent = content // Reset to the original content
//        if !previousMediaFilename.isEmpty, let data = previousMediaData { //restore previous media
//            mediaFilename = saveMedia(data: data)
////            entry.saveImage(data: data, coreDataManager: coreDataManager)
//        }
//        isEditing = false // Exit the editing mode
//    }
//    
//    
//    func startRecognition() {
//        let audioSession = AVAudioSession.sharedInstance()
//        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        let inputNode = audioEngine.inputNode
//        
//        // Remove existing taps if any
//        inputNode.removeTap(onBus: 0)
//        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, _ in
//            if let result = result {
//                content = result.bestTranscription.formattedString
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
//    
//}
