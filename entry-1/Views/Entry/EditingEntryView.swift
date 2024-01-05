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

struct EditingEntryView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
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
    
    
    @State private var previousMediaFilename: String = ""
    @State private var previousMediaData: Data?
    @State var imageHeight: CGFloat = 0

    

    
    var body : some View {
        NavigationStack {
            VStack {
                
                HStack() {
                    Spacer()
                    if (entry.stampIcon != "") {
                        Image(systemName: entry.stampIcon).foregroundStyle(Color(entry.color))
                            .font(.system(size: 15))
                            .padding(.horizontal)
                        
                    }
                }
                
                
//                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        GrowingTextField(text: $editingContent, fontName: userPreferences.fontName, fontSize: userPreferences.fontSize, fontColor: UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))))).cornerRadius(15)
                            .padding()

//                        TextField(entry.content.isEmpty ? "Start typing here..." : entry.content, text: $editingContent, axis: .vertical)
//                            .focused($focusField)
//                            .foregroundColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.systemGroupedBackground))))
//                        
//                            .onSubmit {
//                                finalizeEdit()
//                            }
//                            .padding(.bottom)
//                            .padding(.vertical, 5)
    
                    }

          
//                    .frame(maxHeight: focusField == true ? UIScreen.main.bounds.height/3 - imageHeight : UIScreen.main.bounds.height/2 - imageHeight)
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
                                            selectedImage = nil
                                            entry.deleteImage(coreDataManager: coreDataManager)
                                            
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
                                            selectedImage = nil
                                            entry.deleteImage(coreDataManager: coreDataManager)
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
            .onAppear {
                if let filename = entry.mediaFilename {
                    selectedData = getMediaData(fromFilename: filename)
                    imageHeight = UIScreen.main.bounds.height/7
                }
                
                        if !entry.content.isEmpty {
                            editingContent = entry.content
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
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                
            }
            .navigationBarTitle("Editing Entry")
            .foregroundColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.systemGroupedBackground))))

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        vibration_heavy.impactOccurred()
                        DispatchQueue.main.async {
                            finalizeEdit()
                        }
                        focusField = false
                    } label: {
                        Text("Done")
                            .font(.system(size: 15))
                            .foregroundColor(userPreferences.accentColor)

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
       func buttonBar() -> some View {
           HStack(spacing: 35) {
               Button(action: startOrStopRecognition) {
                   Image(systemName: "mic.fill")
                       .foregroundColor(isListening ? userPreferences.accentColor : Color.oppositeColor(of: userPreferences.accentColor))
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
                   imageHeight = 0
                   entry.deleteImage(coreDataManager: coreDataManager)
                   Task {
                       if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                           selectedData = data
                           entry.saveImage(data: data, coreDataManager: coreDataManager)
                           imageHeight = UIScreen.main.bounds.height/7
                       }
                   }
               }
               
               Image(systemName: "camera.fill")
                   .font(.system(size: 20))
                   .onChange(of: selectedImage) { _ in
                       selectedData = nil
                       imageHeight = 0
                       entry.deleteImage(coreDataManager: coreDataManager)
                       Task {
                           if let data = selectedImage?.jpegData(compressionQuality: 0.7) {
                               selectedData = data
                               entry.saveImage(data: data, coreDataManager: coreDataManager)
                               imageHeight = UIScreen.main.bounds.height/7
                           }
                       }
                   }
                   .onTapGesture {
                       vibration_heavy.impactOccurred()
                       showCamera = true
                   }
           }
           .padding(.vertical)
           .padding(.horizontal, 20)
           .background(Color.white.opacity(0.05))
       }
    
    
    
    func finalizeEdit() {
          // Code to finalize the edit
          let mainContext = coreDataManager.viewContext
          mainContext.performAndWait {
              entry.content = editingContent
              
              // Save the context
              print("isEditing: \(isEditing)")
              coreDataManager.save(context: mainContext)
          }
          isEditing = false
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
    
}
