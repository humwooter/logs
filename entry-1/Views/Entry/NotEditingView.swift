//
//  NotEditingView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 2/26/24.
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



struct NotEditingView: View {
    // data management objects
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @ObservedObject var entry: Entry

    // environment and view state
    @Environment(\.colorScheme) var colorScheme
    @State private var showEntry = true

    // editing state
    @Binding var isEditing: Bool
    @State private var cursorPosition: NSRange? = nil

    // media handling
    @State var currentMediaData: Data?
    @State private var isFullScreen = false
    @State private var selectedURL: URL? = nil

    var body : some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                entryHeaderView()
                entryTextView()
                entryMediaView()
            }
        }
    }
    
    @ViewBuilder
    func entryMediaView() -> some View {
        if entry.mediaFilename != "" {
            
            if let filename = entry.mediaFilename {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent(filename)
                let data = try? Data(contentsOf: fileURL)
            
                
                if let data = data, isGIF(data: data) {
                    let asyncImage = UIImage(data: data)
                    AnimatedImageView(url: fileURL).scaledToFit()
                        .blur(radius: entry.isHidden ? 10 : 0)
                        .quickLookPreview($selectedURL)
                        .onTapGesture {
                            selectedURL = fileURL
                        }
                    // Add imageView
                } else if let data, isPDF(data: data) {
                    VStack {
                            HStack {
                                Spacer()
                                Label("Expand PDF", systemImage: "arrow.up.left.and.arrow.down.right") .foregroundColor(Color(UIColor.foregroundColor(background: UIColor.blendedColor(from: UIColor(userPreferences.backgroundColors.first!), with: UIColor(userPreferences.entryBackgroundColor)))))
                                    .onTapGesture {
                                    isFullScreen.toggle()
                                }
                                .padding(.horizontal, 3)
                                .cornerRadius(20)
                            }

                       
                        AsyncPDFKitView(url: fileURL).scaledToFit()
                            .blur(radius: entry.isHidden ? 10 : 0)
                      
                    }

                } else {
                    if imageExists(at: fileURL) {
                        CustomAsyncImageView(url: fileURL).scaledToFit()
                            .blur(radius: entry.isHidden ? 10 : 0)
                            .quickLookPreview($selectedURL)
                            .onTapGesture {
                                selectedURL = fileURL
                            }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func entryHeaderView() -> some View {
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
                            if isPDF(data: data) {
                            }
                            else {
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
            .foregroundColor(UIColor.foregroundColor(entry: entry, background: entry.color, userPreferences: userPreferences)).opacity(0.3)

            
        
        }
        .padding(.top, 5)
    }
    
    @ViewBuilder
    func entryTextView() -> some View {
        VStack {
            let foregroundColor = isClear(for: entry.color) ? UIColor(userPreferences.entryBackgroundColor) : entry.color
            let blendedBackgroundColors = UIColor.blendColors(foregroundColor: UIColor(userPreferences.backgroundColors[1].opacity(0.5) ?? Color.clear), backgroundColor: UIColor(userPreferences.backgroundColors[0] ?? Color.clear))
            let blendedColor = UIColor.blendColors(foregroundColor: foregroundColor, backgroundColor: UIColor(Color(blendedBackgroundColors).opacity(0.4)))
            let fontColor = UIColor.fontColor(backgroundColor: blendedColor)
            
            if (userPreferences.showLinks) {
        
                Text(makeAttributedString(from: entry.content))
                    .foregroundStyle(Color(fontColor))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading) // Full width with left alignment
                    .onAppear {
                        print("ENTRY COLOR IS: \( entry.color)")
                        print("isClear(for: entry.color): \(isClear(for: entry.color))")
                    }

            } else {
                Text(entry.content)
                    .frame(maxWidth: .infinity, alignment: .leading) // Full width with left alignment
                    .foregroundStyle(Color(fontColor))

            }
        }
            .fixedSize(horizontal: false, vertical: true) // Allow text to wrap vertically
            .padding(2)
            .padding(.vertical, 5)
            .lineSpacing(userPreferences.lineSpacing)
            .blur(radius: entry.isHidden ? 7 : 0)
            .shadow(radius: 0)
    }
}

