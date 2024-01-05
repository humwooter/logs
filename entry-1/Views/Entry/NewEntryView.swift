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
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @FocusState private var focusField: Bool
    
    
    @State private var selectedItem : PhotosPickerItem?
    @State private var selectedImage : UIImage?
    @State private var selectedData: Data? //used for gifs
    @State private var isCameraPresented = false
    @State private var filename = ""
    @State private var imageData : Data?
    @State private var imageIsAnimated = false
    @State private var isHidden = false
    
    
    
    
    @State private var entryContent = ""
    @State private var dynamicHeight: CGFloat = 100
    @State private var imageHeight: CGFloat = 0
    @State private var keyboardHeight: CGFloat = 0


    
    var imageFrameHeight: CGFloat = 150

    
    var body: some View {
        NavigationStack {
            VStack {
//                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
//                        TextField(entryContent.isEmpty ? "Start typing here..." : entryContent, text: $entryContent, axis: .vertical)

                        
                        GrowingTextField(text: $entryContent, fontName: userPreferences.fontName, fontSize: userPreferences.fontSize, fontColor: UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))))).cornerRadius(15)
                            .padding()
                            
//                            .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))))                            .focused($focusField)
                            .onSubmit {
                                finalizeCreation()
                            }
//                            .padding(.bottom)
//                            .padding(.vertical, 5)
                          
                        
                        
                    }
//                    .frame(maxHeight: focusField == true ? UIScreen.main.bounds.height/3 - imageHeight : UIScreen.main.bounds.height/2 - imageHeight)
//                    .onTapGesture {
//                        print("totalHeight: \(UIScreen.main.bounds.height)")
//                        print("maxY: \(UIScreen.main.bounds.maxY)")
//
//                        print("imageHeight: \(imageHeight)")
//                        print("keyboardHeight: \(keyboardHeight)")
//                        print("FRAME VERTICAL HEIGHT: \(0.7*UIScreen.main.bounds.height - imageHeight - keyboardHeight)")
//                        print("prev: \(UIScreen.main.bounds.height/3 - imageHeight)")
//                    }

//                }
//                .padding(.horizontal, 20)
            


                VStack {
                    buttonBar()
                    if let data = selectedData {
                        if isGIF(data: data) {
                            AnimatedImageView_data(data: data)
                                .contextMenu {
                                    Button(role: .destructive, action: {
                                        withAnimation(.smooth) {
                                            selectedData = nil
                                            imageHeight = 0
                                        }
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
                                        withAnimation(.smooth) {
                                            selectedData = nil
                                            imageHeight = 0
                                        }
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
            .background {
                    ZStack {
                        Color(UIColor.systemGroupedBackground)
                        LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                    }
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $isCameraPresented) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                
            }
            .navigationBarTitle("New Entry")
//            .foregroundColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.systemGroupedBackground))))

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        vibration_heavy.impactOccurred()
                        
                        finalizeCreation()
                        presentationMode.wrappedValue.dismiss()
                        focusField = false
                        keyboardHeight = 0
                    }) {
                        Text("Done")
                            .font(.system(size: 15))
                            .foregroundColor(userPreferences.accentColor)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        vibration_heavy.impactOccurred()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15))
                    }
                }
            }
   
        }
        .onTapGesture {
            focusField = true
            keyboardHeight = UIScreen.main.bounds.height/3
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

//                        imageHeight = imageFrameHeight
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
            
            
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(Color.white.opacity(0.05))

    }
    
    func finalizeCreation() {
        let newEntry = Entry(context: viewContext)
        newEntry.id = UUID()
        newEntry.content = entryContent
        newEntry.time = Date()
        print("entry time has been set")
        newEntry.stampIndex = -1
        newEntry.color = UIColor.tertiarySystemBackground
        newEntry.stampIcon = ""
        newEntry.isHidden = isHidden
        newEntry.isRemoved = false
        newEntry.isPinned = false
        newEntry.isShown = true
  
    
        
        if let data = selectedData {
            if let savedFilename = saveMedia(data: data) {
                newEntry.mediaFilename = savedFilename
            } else {
                print("Failed to save media.")
            }
        }

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

