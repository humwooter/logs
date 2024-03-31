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
    @Environment(\.colorScheme) private var colorScheme
    @State private var showEntry = true

    // editing state
    @Binding var isEditing: Bool
    @State private var cursorPosition: NSRange? = nil

    // media handling
    @State var currentMediaData: Data?
    @State private var isFullScreen = false
    @State private var selectedURL: URL? = nil
    @State private var textColor: Color = Color.clear
    @State  var foregroundColor: UIColor
    
    @StateObject private var thumbnailGenerator = ThumbnailGenerator()
     @State private var isVideoPlayerPresented = false

    
    var body : some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                entryHeaderView()
                entryTextView()
                entryMediaView()
            }
        }
        .onChange(of: colorScheme, { oldValue, newValue in
            foregroundColor = UIColor(getDefaultEntryBackgroundColor(colorScheme: newValue))
                    })
        .fullScreenCover(isPresented: $isFullScreen) {
            
            if let filename = entry.mediaFilename {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent(filename)
                let data = try? Data(contentsOf: fileURL)
                
                if let data = data, isPDF(data: data) {
                    VStack {
                        
                        PDFReader(entry: entry,
                                  isFullScreen: $isFullScreen,
                                  currentPageIndex: Binding<Int16>(
                                      get: { entry.pageNum_pdf },
                                      set: { entry.pageNum_pdf = $0; try? coreDataManager.viewContext.save() }
                                  ))
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)

                        

                    }
        
                    .scrollContentBackground(.hidden)
                }
            }
        
        }
        .blur(radius: showEntry ? 0 : 7)
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
                                Label("Expand PDF", systemImage: "arrow.up.left.and.arrow.down.right")
//                                    .foregroundStyle(Color(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first!).blended(withBackgroundColor: UIColor(userPreferences.entryBackgroundColor)))))

                                    .foregroundColor(Color(UIColor.foregroundColor(background: UIColor.blendedColor(from: UIColor(userPreferences.backgroundColors.first!), with: UIColor(userPreferences.entryBackgroundColor)))))
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
            .foregroundStyle(Color(getTextColor()).opacity(0.3))
        }
        .padding(.top, 5)
    }
    
    func getTextColor() -> UIColor { //different implementation since the background will always be default unless
        let defaultEntryBackgroundColor =  getDefaultEntryBackgroundColor(colorScheme: colorScheme)

        let foregroundColor =  isClear(for: UIColor(userPreferences.entryBackgroundColor)) ? UIColor(defaultEntryBackgroundColor) : UIColor(userPreferences.entryBackgroundColor)
        let backgroundColor_top = isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear
        
        let backgroundColor_bottom = isClear(for: UIColor(userPreferences.backgroundColors[1] ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors[1] ?? Color.clear

        
        let blendedBackgroundColors = UIColor.blendedColor(from: UIColor(backgroundColor_top), with: UIColor(backgroundColor_bottom))
        let blendedColor = UIColor.blendedColor(from: foregroundColor, with: UIColor(Color(backgroundColor_top)))
        let fontColor = UIColor.fontColor(forBackgroundColor: blendedColor)
        return fontColor
    }

    
    @ViewBuilder
    func entryTextView() -> some View {
        VStack {
            if isClear(for: UIColor(userPreferences.entryBackgroundColor)) && entry.stampIndex == -1 {
                var backgroundColor = getDefaultBackgroundColor(colorScheme: colorScheme)
                var blendedColor = UIColor.blendedColor(from: foregroundColor, with: UIColor(backgroundColor))
                if (userPreferences.showLinks && foregroundColor != UIColor.clear) {
            
                    Text(makeAttributedString(from: entry.content))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading) // Full width with left alignment
//                        .foregroundStyle(Color(foregroundColor))
                        .foregroundStyle( Color(UIColor.fontColor(forBackgroundColor: foregroundColor)))
                        .onTapGesture {
                            print()
                            print("ENTERED THIS AND FOREGROUND COLOR IS: ")
                            printColorComponents(color: foregroundColor)
                            print("ENTERED THIS AND BACKGROUND COLOR IS: ")
                            printColorComponents(color: UIColor(backgroundColor))
                            print("ENTERED THIS AND BLENDED COLOR IS: ")
                            printColorComponents(color: blendedColor)
                            print("FONT COLOR IS")
                            printColorComponents(color: UIColor.fontColor(forBackgroundColor: blendedColor))
                            print("ENTRY COLOR")
                            printColorComponents(color: entry.color)
                        }
            

                } else {
                    Text(entry.content)
                        .frame(maxWidth: .infinity, alignment: .leading) // Full width with left alignment
                        .foregroundStyle( Color(UIColor.fontColor(forBackgroundColor: blendedColor)))
                }
            } else {
                var entryBackgroundColor = entry.stampIndex == -1 ? UIColor(userPreferences.entryBackgroundColor) : entry.color
                var backgroundColor = isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear
                var blendedBackground = UIColor.blendedColor(from: entryBackgroundColor, with: UIColor(backgroundColor))
                if (userPreferences.showLinks) {
                    
                    VStack {
                        Text(makeAttributedString(from: entry.content))
                            .foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: blendedBackground)))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading) // Full width with left alignment
                            .onAppear {
                                entryBackgroundColor = entry.stampIndex == -1 ? UIColor(userPreferences.entryBackgroundColor) : entry.color
                            }
                        
//                        if let url = extractFirstURL(from: entry.content) {
//                            if let thumbnail = createThumbnailOfVideoFromRemoteUrl(url: url) {
//                                Image(uiImage: thumbnail)
//                                    .scaledToFit()
//                            }
//                          
//                        }
                    }
                } else {
                    Text(entry.content)
                        .frame(maxWidth: .infinity, alignment: .leading) // Full width with left alignment
                        .foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: blendedBackground)))
                }
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
