//
//  EntryContentViews.swift
//  entry-1
//
//  Created by Katya Raman on 9/17/23.
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




struct EditingView: View {
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
    
    var body: some View {
        VStack() {
            VStack {
                HStack(spacing: 25) {
                    Image(systemName: "xmark").font(.custom("serif", size: 16))
                        .onTapGesture {
                            vibration_heavy.impactOccurred()
                            cancelEdit() // Function to discard changes
                        }
                    
                    Spacer()
                    if (entry.isHidden) {
                        Image(systemName: "eye.slash.fill").font(.custom("serif", size: 16))
                            .onTapGesture {
                                vibration_heavy.impactOccurred()
                                hideEntry()
                            }
                            .foregroundColor(userPreferences.accentColor)
                        
                    }
                    else {
                        Image(systemName: "eye.fill").font(.custom("serif", size: 16))
                            .onTapGesture {
                                vibration_heavy.impactOccurred()
                                hideEntry()
                            }

                    }
                    
                    PhotosPicker(selection:$selectedItem, matching: .images) {
                        Image(systemName: "photo.fill")
                            .symbolRenderingMode(.multicolor)
                            .font(.custom("serif", size: 16))
                    }
                    .onChange(of: selectedItem) { _ in
                        Task {
                            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                entry.saveImage(data: data, coreDataManager: coreDataManager)
                            }
                        }
                    }
                    
                    Image(systemName: "camera.fill")
                        .font(.custom("serif", size: 16))
                        .onChange(of: selectedImage) { _ in
                            Task {
                                if let data = selectedImage?.jpegData(compressionQuality: 0.7) {
                                    entry.saveImage(data: data, coreDataManager: coreDataManager)
                                }
                            }
                        }
                        .onTapGesture {
                            vibration_heavy.impactOccurred()
                            showCamera = true
                        }
                    
                    Image(systemName: "checkmark")
                        .font(.custom("serif", size: 16))
                        .onTapGesture {
                            withAnimation() {
                                vibration_heavy.impactOccurred()
                                finalizeEdit()
                                focusField = false
                            }
                        }
                }
                .foregroundColor(UIColor.foregroundColor(entry: entry, background: entry.color, colorScheme: colorScheme, userPreferences: userPreferences))
                
            }
            
            VStack {
                TextField(!entry.content.isEmpty ? entry.content : "Start typing here...", text: $editingContent, axis: .vertical)
                    .fixedSize(horizontal: false, vertical: true)
                    .onSubmit {
                        finalizeEdit()
                    }
                    .foregroundColor(UIColor.foregroundColor(entry: entry, background: entry.color, colorScheme: colorScheme, userPreferences: userPreferences)).opacity(0.6) //to determinw whether black or white
                    .onTapGesture {
                        focusField = true
                    }
                    .focused($focusField)
                
                if entry.imageContent != "" {
                    if let filename = entry.imageContent {
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let fileURL = documentsDirectory.appendingPathComponent(filename)
                        let data = try? Data(contentsOf: fileURL)
                        
                        if let data = data, isGIF(data: data) {
                            ZStack(alignment: .topLeading) {
                                AnimatedImageView(url: fileURL).scaledToFit()
                                Image(systemName: "minus.circle") // Cancel button
                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                    .foregroundColor(.red).opacity(0.8)
                                    .font(.custom("serif", size: 20))
                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                    .frame(width:70, height: 70)
                                    .background(Color(.black).opacity(0.01))
                                    .onTapGesture {
                                        vibration_medium.impactOccurred()
                                        entry.deleteImage(coreDataManager: coreDataManager)
                                    }
                            }
                        } else {
                            ZStack(alignment: .topLeading) {
                                AsyncImage(url: fileURL) { image in
                                    image.resizable()
                                        .scaledToFit()
                                }
                            placeholder: {
                                ProgressView()
                            }
                                Image(systemName: "minus.circle") // Cancel button
                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                    .foregroundColor(.red).opacity(0.8)
                                    .font(.custom("serif", size: 20))
                                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                    .frame(width:70, height: 70)
                                    .background(Color(.black).opacity(0.01))
                                    .onTapGesture {
                                        vibration_medium.impactOccurred()
                                        entry.deleteImage(coreDataManager: coreDataManager)
                                    }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
    }
    
    func hideEntry () {
        if entry.isHidden == nil {
            entry.isHidden = false
        }
        entry.isHidden.toggle()
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
        isEditing = false // Exit the editing mode
    }
    
}





struct NotEditingView: View {
    @ObservedObject var entry: Entry
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    
    
    
    var body : some View {
        ZStack(alignment: .topTrailing) {
  
            VStack {
                if entry.isHidden {
                    Text(entry.content)
                        .foregroundColor(UIColor.foregroundColor(entry: entry, background: entry.color, colorScheme: colorScheme, userPreferences: userPreferences))
                    
                        .fontWeight(entry.stampIndex != -1 && entry.stampIndex != nil ? .semibold : .regular)
                        .frame(maxWidth: .infinity, alignment: .leading) // Full width with left alignment
                        .blur(radius:7)
                        .padding(.vertical, 5)
                        .padding(2)
                        .lineSpacing(userPreferences.lineSpacing)
                    
                    
                    if entry.imageContent != "" {
                        if let filename = entry.imageContent {
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let fileURL = documentsDirectory.appendingPathComponent(filename)
                            let data = try? Data(contentsOf: fileURL)
                            
                            
                            if let data = data, isGIF(data: data) {
                                
                                let imageView = AnimatedImageView(url: fileURL)
                                
                                AnimatedImageView(url: fileURL).scaledToFit()
                                    .blur(radius:10)
                    
                                
                            } else {
                                if imageExists(at: fileURL) {
                                    CustomAsyncImageView(url: fileURL).scaledToFit()                                    .blur(radius:10)

                                }
                            }
                        }
                    }
                }
                else {
                    Text(entry.content)
                        .foregroundColor(UIColor.foregroundColor(entry: entry, background: entry.color, colorScheme: colorScheme, userPreferences: userPreferences))
                    
                        .fontWeight(entry.stampIndex != -1 && entry.stampIndex != nil  ? .semibold : .regular)
                        .frame(maxWidth: .infinity, alignment: .leading) // Full width with left alignment
                        .padding(2)
                        .padding(.vertical, 5)
                        .lineSpacing(userPreferences.lineSpacing)

                    
                    if entry.imageContent != "" {
                        
                        if let filename = entry.imageContent {
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let fileURL = documentsDirectory.appendingPathComponent(filename)
                            let data = try? Data(contentsOf: fileURL)
                            
                            
                            if let data = data, isGIF(data: data) {
                                
                                let imageView = AnimatedImageView(url: fileURL)
                                
                                let asyncImage = UIImage(data: data)
                                
                                let height = asyncImage!.size.height
                                
                                AnimatedImageView(url: fileURL).scaledToFit()
                                
                                
                                // Add imageView
                            } else {
                                if imageExists(at: fileURL) {
                                    CustomAsyncImageView(url: fileURL).scaledToFit()
                                }
                            }
                        }
                    }
                }
                
                
            }
            .padding(.top, 5)
        }
        
    }
}



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


    
    

    
    var body : some View {
        NavigationStack {
            VStack {
                
                HStack() {
                    Spacer()
                    if (entry.image != "") {
                        Image(systemName: entry.image).foregroundStyle(Color(entry.color))
                            .font(.system(size: 15))
                            .padding(.horizontal)
                        
                    }
                }
          
                
                ScrollView(.vertical, showsIndicators: true) {
                        VStack {
                            TextField(entry.content.isEmpty ? "Start typing here..." : entry.content, text: $editingContent, axis: .vertical)
                                .foregroundColor(colorScheme == .dark ? .white : .black).opacity(0.8)
                                .onSubmit {
                                    finalizeEdit()
                                }
                                .padding(.vertical, 10)
                        }
                            .padding(.horizontal, 20)
         

                }
                .defaultScrollAnchor(.bottomLeading)
                .safeAreaInset(edge: .bottom) {
                    buttonBar()
                }

                if let data = selectedData {
                    if isGIF(data: data) {
                        AnimatedImageView_data(data: data)
                            .contextMenu {
                                Button(role: .destructive, action: {
                                    withAnimation(.smooth) {
                                        selectedData = nil
                                        entry.deleteImage(coreDataManager: coreDataManager)
//                                        coreDataManager.save(context: coreDataManager.viewContext)

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
                                        entry.deleteImage(coreDataManager: coreDataManager)
//                                        coreDataManager.save(context: coreDataManager.viewContext)
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
            .onAppear {
                if let filename = entry.imageContent, previousMediaFilename.isEmpty {
                    previousMediaFilename = filename
                    previousMediaData = getMediaData(fromFilename: filename)
                    selectedData = previousMediaData
                }
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                
            }
            .navigationBarTitle("Editing Entry")
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
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 15))
                    }
                }
            }
        }
    }
    
    @ViewBuilder
       func buttonBar() -> some View {
           HStack(spacing: 25) {
               Button(action: startOrStopRecognition) {
                   Image(systemName: "mic.fill")
                       .foregroundColor(isListening ? userPreferences.accentColor : Color.oppositeColor(of: userPreferences.accentColor))
                       .font(.system(size: 20))
               }
               
               Spacer()
               Image(systemName: entry.isHidden ? "eye.slash.fill" : "eye.fill").font(.system(size: 20))
                   .onTapGesture {
                       vibration_heavy.impactOccurred()
                       entry.isHidden.toggle()
                   }
                   .foregroundColor(userPreferences.accentColor).opacity(entry.isHidden ? 1 : 0.1)
               
    
               PhotosPicker(selection:$selectedItem, matching: .images) {
                   Image(systemName: "photo.fill")
                       .font(.system(size: 20))
               }
               .onChange(of: selectedItem) { _ in
                   selectedData = nil
                   entry.deleteImage(coreDataManager: coreDataManager)
                   Task {
                       if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                           selectedData = data
                           entry.saveImage(data: data, coreDataManager: coreDataManager)
                       }
                   }
               }
               
               Image(systemName: "camera.fill")
                   .font(.system(size: 20))
                   .onChange(of: selectedImage) { _ in
                       selectedData = nil
                       entry.deleteImage(coreDataManager: coreDataManager)
                       Task {
                           if let data = selectedImage?.jpegData(compressionQuality: 0.7) {
                               selectedData = data
                               entry.saveImage(data: data, coreDataManager: coreDataManager)
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
           .background(
               LinearGradient(
                   gradient: Gradient(colors: [Color.gray.opacity(0.1), Color.clear]),
                   startPoint: .top,
                   endPoint: .bottom
               )
           )
           .edgesIgnoringSafeArea(.bottom)
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
      

//    func finalizeEdit() {
////        // Code to finalize the edit
////        let mainContext = coreDataManager.viewContext
////        entry.content = editingContent
////
////        // Save the context
////        do {
////            if let data = selectedData {
////                entry.saveImage(data: data, coreDataManager: coreDataManager)
////            }
////            coreDataManager.save(context: mainContext)
////        }
//////            print("isEditing: \(isEditing)")
//////            coreDataManager.save(context: mainContext)
//////        isEditing = false
//        ///
//        ///
//        ///if let d
//        ///
//        entry.content = editingContent
//        if let data = selectedData {
//            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//                
//                if let mediaFilename = entry.imageContent, !mediaFilename.isEmpty { //deleting existing image
//                    let existingURL = documentsDirectory.appendingPathComponent(mediaFilename)
//                    if imageExists(at: existingURL) {
//                        entry.deleteImage(coreDataManager: coreDataManager)
//                    }
//                }
//
//                let uniqueFilename = entry.id.uuidString + ".png"
//                let fileURL = documentsDirectory.appendingPathComponent(uniqueFilename)
//                
//                do {
//                    print("file URL from saveImage: \(fileURL)")
//                    try data.write(to: fileURL)
//                } catch {
//                    print("Error saving image file: \(error)")
//                }
//                
//                entry.imageContent = uniqueFilename
//                print("entry from saveImage: \(entry)")
//                
//                let mainContext = coreDataManager.viewContext
//                do {
//                    try mainContext.save()
//                } catch let error as NSError {
//                    print("Could not save. \(error), \(error.userInfo)")
//                }
//        }
//        isEditing = false
//    }
    
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
