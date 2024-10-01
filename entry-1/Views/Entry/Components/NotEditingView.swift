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
import AVKit


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
    @State var repliedEntryBackgroundColor: Color = Color.clear
    
    @StateObject private var thumbnailGenerator = ThumbnailGenerator()
     @State private var isVideoPlayerPresented = false
    @State var replyEntryId: String?
    
    var entryViewModel: EntryViewModel 

    
    var body : some View {
     finalView()
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
//        .blur(radius: showEntry ? 0 : 7)
    }
    
    @ViewBuilder
    func finalView() -> some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                entryHeaderView()
                    .font(.sectionHeaderSize)
                    .padding([.top, .bottom, .trailing], 7)
                    .foregroundStyle(getIdealHeaderTextColor().opacity(0.4))
                VStack {
                    if let repliedId = replyEntryId {
                        finalRepliedView()
                    } else {
                        entryView()
                    }
              

                tagsView()
                }
                .blur(radius: !entry.isHidden ? 0 : 7)
            }
        }
    }
    
    @ViewBuilder
    func tagsView() -> some View {
        let textColor = getTextColor()
        VStack(alignment: .leading, spacing: 1) {
            if let tags = entry.tagNames, !tags.isEmpty {
                Divider()
                
                FlexibleTagGridView(tags: tags)
                    .padding(.vertical)
            }
        }
        .foregroundStyle(textColor.opacity(0.4))
    }
    
    @ViewBuilder
    func entryView() -> some View {
            VStack {
                entryTextView()
                if let url = getUrl(for: entry.mediaFilename ?? "") {
                    if mediaExists(at: url) {
                        entryMediaView()
                    }
                }
            }
//            .onAppear {
//                     updateEntryAttributes()
//                 }
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
                                    .foregroundStyle(getTextColor().opacity(0.3))
                                    .frame(maxWidth: .infinity, maxHeight: 5) // Correctly size the frame based on the shape dimensions
                                Spacer()
                            }
                        }.padding(.bottom)
                    }
               

            }.padding(.horizontal)
            entryView().padding(.top, 3)

            Spacer()
           }
    }
    
    func getIdealHeaderTextColor() -> Color {
        return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(userPreferences.backgroundColors.first ?? Color.clear), and: UIColor(userPreferences.backgroundColors[1])), colorScheme: colorScheme))
    }
    
    
    @ViewBuilder
    func entrySectionHeader(entry: Entry) -> some View {
        HStack {

                Text("\(entry.isPinned && formattedDate(entry.time) != formattedDate(Date()) ? formattedDateShort(from: entry.time) : formattedTime(time: entry.time))")
                .foregroundStyle(getTextColor().opacity(0.5))
                if let timeLastUpdated = entry.lastUpdated {
                    if formattedTime_long(date: timeLastUpdated) != formattedTime_long(date: entry.time), userPreferences.showMostRecentEntryTime {
                        HStack {
                            Image(systemName: "arrow.right")
                            Text(formattedTime_long(date: timeLastUpdated))
                        }
                        .foregroundStyle(getTextColor().opacity(0.5))
                    }

                }

            Image(systemName: entry.stampIcon).foregroundStyle(Color(entry.color))
            Spacer()
            
            if entry.shouldSyncWithCloudKit {
                Label("", systemImage: "cloud.fill").foregroundStyle(.cyan.opacity(0.5))
            }
            
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
        if let replyId = replyEntryId, !replyId.isEmpty {
            if let repliedEntry = fetchEntryById(id: replyId, coreDataManager: coreDataManager) {
                
                VStack(alignment: .trailing) {
                entrySectionHeader(entry: repliedEntry)
                    NotEditingView_thumbnail(entry: repliedEntry, foregroundColor: UIColor(getDefaultEntryBackgroundColor(colorScheme: colorScheme)), repliedEntryBackgroundColor: $repliedEntryBackgroundColor, repliedEntry: entry)
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)
                            .overlay(
                                  RoundedRectangle(cornerRadius: 15)
                                    .stroke(getTextColor().opacity(0.05), lineWidth: 2)
                            )

                            .background(repliedEntryBackgroundColor)
                            .cornerRadius(15.0)
                          
                            .frame(maxWidth: .infinity)

                        
          
                    
                }
                .onAppear {
                    repliedEntryBackgroundColor = Color(UIColor.backgroundColor(entry: repliedEntry, colorScheme: colorScheme, userPreferences: userPreferences))

                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.5)
                .scaledToFill()
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
                    if mediaExists(at: fileURL) {
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
                entryViewModel.entryContextMenuButtons(entry: entry, isShowingEntryEditView: $isEditing, userPreferences: userPreferences)
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "ellipsis").padding(.vertical, 3).padding(.leading, 5)
                        .font(.system(size: UIFont.systemFontSize+5)).fontWeight(.bold)
                        .onTapGesture {
                            vibration_medium.prepare()
                            vibration_medium.impactOccurred()
                        }
                }
                
            }
            .foregroundStyle(getTextColor().opacity(0.3))
        }
        .padding(.top, 5)
    }
    
    
    func getTextColor() -> Color {
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        let entryBackground = entry.stampIndex == -1 ? userPreferences.entryBackgroundColor : Color(entry.color)
        
        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme
        )
    }

//this works as of jun 27
//    func getTextColor() -> Color {
//        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) && entry.stampIndex == -1 {
//            var backgroundColor = getDefaultBackgroundColor(colorScheme: colorScheme)
//            var blendedColor = UIColor.blendedColor(from: foregroundColor, with: UIColor(backgroundColor))
//            return Color(UIColor.fontColor(forBackgroundColor: blendedColor))
//        } else {
//            var entryBackgroundColor = entry.stampIndex == -1 ? UIColor(userPreferences.entryBackgroundColor) : entry.color
//            var backgroundColor = isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear
//            var blendedBackground = UIColor.blendedColor(from: entryBackgroundColor, with: UIColor(backgroundColor))
//            
//            
//            return Color(UIColor.fontColor(forBackgroundColor: blendedBackground))
//        }
//    }

    @ViewBuilder
    func videoPlayerView() -> some View { //make sure it's only for mp4's
        if let url_string = extractFirstURL(from: entry.content) {
            if let url = URL(string: url_string) {
                VideoPlayer(player: AVPlayer(url: url)).scaledToFit()
                    .onAppear {
                        print("URL: \(url)")
                    }
            }
        }
    }

    @ViewBuilder
       func entryTextView() -> some View {
           VStack {
               entryTitleView()
               entryContentView()
           }
           .font(.custom(userPreferences.fontName, size: CGFloat(userPreferences.fontSize)))
           .fixedSize(horizontal: false, vertical: true)
           .padding(2)
           .padding(.vertical, 5)
           .lineSpacing(userPreferences.lineSpacing)
           .blur(radius: entry.isHidden ? 7 : 0)
           .shadow(radius: 0)
       }
       
       @ViewBuilder
       private func entryTitleView() -> some View {
           if let entryName = entry.title, !entryName.isEmpty {
               Text(entryName)
                   .font(.custom(userPreferences.fontName, size: 1.35 * CGFloat(userPreferences.fontSize)))
                   .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                   .padding(.vertical, 2)
                   .foregroundStyle(getTextColor())
           }
       }
       
       @ViewBuilder
       private func entryContentView() -> some View {
           if userPreferences.showLinks {
               Text(makeAttributedString(from: entry.content))
                   .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                   .foregroundStyle(getTextColor())
           } else {
               Text(entry.content)
                   .frame(maxWidth: .infinity, alignment: .leading)
                   .foregroundStyle(getTextColor())
           }
       }
       
       private func getForegroundStyle() -> Color {
           getTextColor()
       }
       
       private func backgroundColorForEntry() -> Color {
           if isClear(for: UIColor(userPreferences.entryBackgroundColor)) && entry.stampIndex == -1 {
               return getDefaultBackgroundColor(colorScheme: colorScheme)
           } else {
               let entryBackgroundColor = entry.stampIndex == -1 ? UIColor(userPreferences.entryBackgroundColor) : entry.color
               let backgroundColor = isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ?
                   getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear
               return Color(UIColor.blendedColor(from: entryBackgroundColor, with: UIColor(backgroundColor)))
           }
       }
       
}




struct NotEditingView_thumbnail: View {
    // data management objects
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @ObservedObject var entry: Entry

    // environment and view state
    @Environment(\.colorScheme) private var colorScheme
    @State private var showEntry = true

    // editing state
    @State private var cursorPosition: NSRange? = nil

    // media handling
    @State var currentMediaData: Data?
    @State private var isFullScreen = false
    @State private var selectedURL: URL? = nil
    @State private var textColor: Color = Color.clear
    @State  var foregroundColor: UIColor
    @Binding var repliedEntryBackgroundColor: Color
    
    @StateObject private var thumbnailGenerator = ThumbnailGenerator()
    @State private var isVideoPlayerPresented = false
    @State private var mediaDim: CGFloat = 100
    @State var repliedEntry: Entry

    
    var body : some View {
        VStack(alignment: .leading) {
            entryTitleView()
            entryTextView()
                //                    .font(.custom(userPreferences.fontName, size: CGFloat(userPreferences.fontSize)))
                if let url = getUrl(for: entry.mediaFilename ?? "") {
                    if mediaExists(at: url) {
                        entryMediaView()
                    }
                }
        }
        .foregroundStyle(getTextColor())
        .onChange(of: entry.stampIndex, { oldValue, newValue in
            repliedEntryBackgroundColor = Color(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
        })
        .padding()
        .blur(radius: showEntry ? 0 : 7)
    }

    func getSectionColor() -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        }
        return userPreferences.entryBackgroundColor
    }
    
    
    func getTextColor() -> Color {
        var entryBackground = getSectionColor()

        if entry.stampIndex != -1 {
            entryBackground = Color(entry.color)
        }
        // Retrieve the background colors from user preferences
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        
        // Call the calculateTextColor function with these values
        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme
        )
    }
    
    @ViewBuilder
    private func entryTitleView() -> some View {
        if let entryName = entry.title, !entryName.isEmpty {
            Text(entryName)
                .font(.custom(userPreferences.fontName, size: 1.0*CGFloat(userPreferences.fontSize)))
                .foregroundStyle(getTextColor())
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
                    if mediaExists(at: fileURL) {
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
    
    
//    func getTextColor() -> UIColor { //different implementation since the background will always be default unless
//        let defaultEntryBackgroundColor =  getDefaultEntryBackgroundColor(colorScheme: colorScheme)
//
//        let foregroundColor =  isClear(for: UIColor(userPreferences.entryBackgroundColor)) ? UIColor(defaultEntryBackgroundColor) : UIColor(userPreferences.entryBackgroundColor)
//        let backgroundColor_top = isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear
//        
//        let backgroundColor_bottom = isClear(for: UIColor(userPreferences.backgroundColors[1] ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors[1] ?? Color.clear
//
//        
//        let blendedBackgroundColors = UIColor.blendedColor(from: UIColor(backgroundColor_top), with: UIColor(backgroundColor_bottom))
//        let blendedColor = UIColor.blendedColor(from: foregroundColor, with: UIColor(Color(backgroundColor_top)))
//        let fontColor = UIColor.fontColor(forBackgroundColor: blendedColor)
//        return fontColor
//    }

    @ViewBuilder
    func videoPlayerView() -> some View { //make sure it's only for mp4's
        if let url_string = extractFirstURL(from: entry.content) {
            if let url = URL(string: url_string) {
                VideoPlayer(player: AVPlayer(url: url)).scaledToFit()
                    .onAppear {
                        print("URL: \(url)")
                    }
            }
        }
    }
    
    private func entryHasMedia() -> Bool {
        if let filename = entry.mediaFilename {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            return entry_1.mediaExists(at: fileURL)
        }
        return false
    }


    
    @ViewBuilder
    func entryTextView() -> some View {
        let truncatedText = entryHasMedia() ? truncatedText(entry.content, wordLimit: 3, maxCharacterLimit: 15) : truncatedText(entry.content, wordLimit: 20, maxCharacterLimit: 100)
        VStack {
            if isClear(for: UIColor(userPreferences.entryBackgroundColor)) && entry.stampIndex == -1 {
                var backgroundColor = getDefaultBackgroundColor(colorScheme: colorScheme)
                var blendedColor = UIColor.blendedColor(from: foregroundColor, with: UIColor(backgroundColor))
                if (userPreferences.showLinks && foregroundColor != UIColor.clear) {
                    
            
                    Text(makeAttributedString(from: truncatedText))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading) // Full width with left alignment
//                        .foregroundStyle( Color(UIColor.fontColor(forBackgroundColor: blendedColor)))
                        .foregroundStyle(getTextColor())
                } else {
                    Text(truncatedText)
                        .frame(maxWidth: .infinity, alignment: .leading) // Full width with left alignment
//                        .foregroundStyle( Color(UIColor.fontColor(forBackgroundColor: blendedColor)))
                        .foregroundStyle(getTextColor())

                }
            } else {
                var entryBackgroundColor = entry.stampIndex == -1 ? UIColor(userPreferences.entryBackgroundColor) : entry.color
                var backgroundColor = isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear
                var blendedBackground = UIColor.blendedColor(from: entryBackgroundColor, with: UIColor(backgroundColor))
                if (userPreferences.showLinks) {
                    
                    VStack {
                        Text(makeAttributedString(from: truncatedText))
                            .foregroundStyle(getTextColor())

//                            .foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: blendedBackground)))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading) // Full width with left alignment
                            .onAppear {
                                entryBackgroundColor = entry.stampIndex == -1 ? UIColor(userPreferences.entryBackgroundColor) : entry.color
                            }
                    }
                } else {
                    Text(truncatedText)
                        .frame(maxWidth: .infinity, alignment: .leading) // Full width with left alignment
                        .foregroundStyle(getTextColor())

//                        .foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: blendedBackground)))
                }
            }
            
        }
        .font(.custom(userPreferences.fontName, size: max(CGFloat(userPreferences.fontSize*0.6),5)))
            .fixedSize(horizontal: false, vertical: true) // Allow text to wrap vertically
            .padding(1)
            .padding(.vertical, 3)
            .lineSpacing(userPreferences.lineSpacing)
            .blur(radius: entry.isHidden ? 7 : 0)
            .shadow(radius: 0)
    }
    
    func truncatedText(_ text: String, wordLimit: Int, maxCharacterLimit: Int) -> String {
        // Split the text into segments based on spaces or new lines
        let segments = text.components(separatedBy: .whitespacesAndNewlines)
        
        // Use a temporary variable to build the truncated text
        var truncated = ""
        
        // Iterate over the segments and append them to the truncated string until the word limit or character limit is reached
        for segment in segments.prefix(wordLimit) {
            // Check if adding this segment would exceed the character limit
            if truncated.count + segment.count + 1 > maxCharacterLimit { // +1 for space
                break
            }
            // Append the segment followed by a space
            truncated += (truncated.isEmpty ? "" : " ") + segment
        }
        
        // Check if the original text is different from the truncated text, then append "..."
        if truncated != text {
            truncated += "..."
        }
        
        return truncated
    }

    
    
}
