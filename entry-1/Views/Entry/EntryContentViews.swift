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
                
                if entry.mediaFilename != "" {
                    if let filename = entry.mediaFilename {
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
    @EnvironmentObject var coreDataManager: CoreDataManager
    
    @Environment(\.colorScheme) var colorScheme
    @State private var showEntry = true
    
    @Binding var isEditing: Bool
    
    
    var body : some View {
        ZStack(alignment: .topTrailing) {
            
            VStack {
                HStack {
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            withAnimation {
                                isEditing = true
                            }
                        }) {
                            Text("Edit")
                            Image(systemName: "pencil")
                                .foregroundColor(userPreferences.accentColor)
                        }
                        
                        Button(action: {
                            UIPasteboard.general.string = entry.content
                        }) {
                            Text("Copy Message")
                            Image(systemName: "doc.on.doc")
                        }
                        
                        
                        Button(action: {
                            withAnimation(.easeOut) {
                                showEntry.toggle()
                                entry.isHidden = !showEntry
                                coreDataManager.save(context: coreDataManager.viewContext)
                            }
                            
                        }, label: {
                            Label(showEntry ? "Hide Entry" : "Unhide Entry", systemImage: showEntry ? "eye.slash.fill" : "eye.fill")
                        })
                        
                        if let filename = entry.mediaFilename {
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let fileURL = documentsDirectory.appendingPathComponent(filename)
                            if imageExists(at: fileURL) {
                                if let data =  getMediaData(fromFilename: filename) {
                                    let image = UIImage(data: data)!
                                    Button(action: {
                                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                        let fileURL = documentsDirectory.appendingPathComponent(filename)
                                        
                                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                        
                                    }, label: {
                                        Label("Save Image", systemImage: "photo.badge.arrow.down.fill")
                                    })
                                }
                            }
                            
                        }
                        
                        Button(action: {
                            withAnimation {
                                entry.isPinned.toggle()
                                coreDataManager.save(context: coreDataManager.viewContext)
                            }
                        }) {
                            Text(entry.isPinned ? "Unpin" : "Pin")
                            Image(systemName: "pin.fill")
                                .foregroundColor(.red)
                            
                        }
                    } label: {
                        Image(systemName: "ellipsis").padding(.vertical, 3).padding(.leading, 5)
                            .font(.system(size: UIFont.systemFontSize+5)).fontWeight(.bold)
                            .onTapGesture {
                                vibration_medium.prepare()
                                vibration_medium.impactOccurred()
                            }
                        
                    }
                    .foregroundColor(UIColor.foregroundColor(entry: entry, background: entry.color, colorScheme: colorScheme, userPreferences: userPreferences)).opacity(0.3)

                    
                
                }
                .padding(.top, 5)
                
//                Text(entry.content)
//                ClickableLinksTextView(text: entry.content, fontName: userPreferences.fontName, fontSize: userPreferences.fontSize, fontColor: UIColor(UIColor.foregroundColor(entry: entry, background: entry.color, colorScheme: colorScheme, userPreferences: userPreferences))).scaledToFit()
//                Text(makeAttributedString(from: entry.content))   
                ZStack {
                    if (userPreferences.showLinks) {
                        Text(makeAttributedString(from: entry.content))
                    } else {
                        Text(entry.content)
                    }
                }
                    .fixedSize(horizontal: false, vertical: true) // Allow text to wrap vertically
                    .foregroundColor(UIColor.foregroundColor(entry: entry, background: entry.color, colorScheme: colorScheme, userPreferences: userPreferences))
                    .scaledToFit()
                    .fontWeight(entry.stampIndex != -1 && entry.stampIndex != nil  ? .semibold : .regular)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading) // Full width with left alignment
                    .padding(2)
                    .padding(.vertical, 5)
                    .lineSpacing(userPreferences.lineSpacing)
                    .blur(radius: entry.isHidden ? 7 : 0)
                    .shadow(radius: 0)
                
                
                
                if entry.mediaFilename != "" {
                    
                    if let filename = entry.mediaFilename {
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let fileURL = documentsDirectory.appendingPathComponent(filename)
                        let data = try? Data(contentsOf: fileURL)
                        
                        
                        if let data = data, isGIF(data: data) {
                            
                            
                            let asyncImage = UIImage(data: data)
                            
                            
                            AnimatedImageView(url: fileURL).scaledToFit()
                                .blur(radius: entry.isHidden ? 10 : 0)
                            // Add imageView
                        } else {
                            if imageExists(at: fileURL) {
                                CustomAsyncImageView(url: fileURL).scaledToFit()
                            }
                        }
                    }
                }
                
                
            }
            .onAppear {
                showEntry = !entry.isHidden
            }
            .padding(.top, 5)
        }
        
    }

}



