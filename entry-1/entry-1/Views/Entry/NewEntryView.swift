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
    
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    TextField(entryContent.isEmpty ? "Start typing here..." : entryContent, text: $entryContent, axis: .vertical)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(colorScheme == .dark ? .white : .black).opacity(0.8)
                        .onTapGesture {
                            focusField = true
                        }
                        .focused($focusField)
                        .padding(.vertical, 30)
                    //                    .padding(.horizontal, 20)
                    
                    
                    Spacer()
                    //                ButtonDashboard_2(activatedButtons: $activatedButtons).environmentObject(userPreferences)
                    //                ImageViewer(selectedImage: selectedImage)
                    if let image = selectedImage { //add gif support and option to pass by data
                        ImageViewer(selectedImage: selectedImage)
                            .contextMenu {
                                Button(role: .destructive, action: {
                                    selectedImage = nil
                                    selectedData = nil
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
            
                    }
                }
                
                HStack(spacing: 25) {
                    Button(action: startOrStopRecognition) {
                        Image(systemName: "mic.fill")
                            .foregroundColor(isListening ? userPreferences.accentColor : Color.complementaryColor(of: userPreferences.accentColor))
                            .font(.system(size: 20))
                    }
                    Spacer()
                    
                    Image(systemName: isHidden ? "eye.slash.fill" : "eye.fill").font(.system(size: 20))

                        .onTapGesture {
                            vibration_heavy.impactOccurred()
                            isHidden.toggle()
                        }
                        .foregroundColor(userPreferences.accentColor).opacity(isHidden ? 1 : 0.1)
                    
                    
                    
                    PhotosPicker(selection:$selectedItem, matching: .images) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 20))

                    }
                    .onChange(of: selectedItem) { _ in
                        Task {
                            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                if isGIF(data: data) {
                                    selectedData = data
                                    selectedImage = UIImage(data: selectedData!)
                                    imageIsAnimated = true
                                }
                                else {
                                    selectedData = nil
                                    selectedImage = nil
                                    imageIsAnimated = false
                                }
                                selectedImage = UIImage(data: data)
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
                            .font(.system(size: 20))
                    }
//                    .padding(.vertical)
                }
                .padding(.vertical)
//                .padding(.horizontal, 15)
                    
                
            }
            .sheet(isPresented: $isCameraPresented) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                
            }
            .padding(.horizontal, 20)
            
            

//            .padding(.horizontal, 30)
            .navigationBarTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        vibration_heavy.impactOccurred()

                     finalizeCreation()
                        presentationMode.wrappedValue.dismiss()
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
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 15))
                    }
                }
            }
        }
    }
    
    func finalizeCreation() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let uniqueFilename = UUID().uuidString + ".png"
        let fileURL = documentsDirectory.appendingPathComponent(uniqueFilename)
        
        let color = colorScheme == .dark ? Color.white : Color.black
        let newEntry = Entry(context: viewContext)
        
        
        
        if let image = selectedImage {
              if let data = imageIsAnimated ? selectedData : image.jpegData(compressionQuality: 0.7) {
                  if let savedFilename = saveMedia(data: data, viewContext: viewContext) {
                      filename = savedFilename
                      newEntry.imageContent = filename
                      print(": \(filename)")
                      // selectedImage = nil // Uncomment this to clear the selectedImage after saving
                  } else {
                      print("Failed to save media.")
                  }
              }
          }
        
        newEntry.content = entryContent
        newEntry.time = Date()
        newEntry.stampIndex = -1
//        newEntry.buttons = [false, false, false, false, false, false, false]
        newEntry.color = UIColor.tertiarySystemBackground
        newEntry.image = ""
        newEntry.id = UUID()
        newEntry.isHidden = isHidden
        newEntry.isRemoved = false
        
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
        
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}
