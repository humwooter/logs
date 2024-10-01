//
//  EntryDetailView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/27/23.
//

import Foundation
import SwiftUI



struct EntryDetailView: View { //used in LogDetailView
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @State var image: UIImage?
    @State var shareSheetShown = false
    @Binding var isShowingReplyCreationView: Bool
    @Binding var replyEntryId: String?
//    @Binding var isEditing: Bool

    @ObservedObject var entry: Entry
    @State private var isFullScreen = false
    

    @State private var mediaDim: CGFloat = 100
     var showContextMenu: Bool = false
    var isInList: Bool = false
    @State private var isEditing = false


@State var showEntry = true
@State var isPinned = false
    @State var repliedEntryBackgroundColor: Color = Color.clear // for replied entry
    
    
    var entryViewModel: EntryViewModel {
        EntryViewModel(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId)
    }

    var body: some View {
        VStack(alignment: .leading) {
            if showContextMenu {
                finalView()
                    .contextMenu {
                        entryViewModel.entryContextMenuButtons(entry: entry, isShowingEntryEditView: $isEditing, userPreferences: userPreferences)
                    }
                    .sheet(isPresented: $isEditing) { //added this here
                        EditingEntryView(entry: entry, isEditing: $isEditing, tagViewModel: TagViewModel(coreDataManager: coreDataManager))
                                .foregroundColor(userPreferences.accentColor)
                                .presentationDragIndicator(.hidden)
                                .environmentObject(userPreferences)
                                .environmentObject(coreDataManager)
                        }
            } else {
                finalView()
            }
        }
            .onAppear {
                showEntry = !entry.isHidden
                isPinned = entry.isPinned
            }

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
            .sheet(isPresented: $isEditing) { //added this here
                EditingEntryView(entry: entry, isEditing: $isEditing, tagViewModel: TagViewModel(coreDataManager: coreDataManager))
                        .foregroundColor(userPreferences.accentColor)
                        .presentationDragIndicator(.hidden)
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
                }
//            .blur(radius: !entry.isHidden ? 0 : 7)
        
        
    }

    @ViewBuilder
    func finalView() -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {
                HStack {
                    entryHeaderView().foregroundStyle(getIdealHeaderTextColor())
                    Spacer()
                }
                Spacer()
                if let repliedId = entry.entryReplyId {
                        finalRepliedView()
                } else {
                    VStack(spacing: 0) {
                        entryTitleView()
                        entryBodyView()
                    }
                }
                
                tagsView().padding(.vertical ,2)
            }.padding(.top)

        }
        .blur(radius: !entry.isHidden ? 0 : 7)
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    
    
    func getSectionColor(colorScheme: ColorScheme) -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        } else {
            return userPreferences.entryBackgroundColor
        }
    }
    
    func getTextColor() -> Color {
        // Retrieve the background colors from user preferences
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        let entryBackground = userPreferences.entryBackgroundColor
        
        // Call the calculateTextColor function with these values
        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme
        )
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
                        .foregroundStyle(getIdealHeaderTextColor().opacity(0.5))
                    }

                }

            Image(systemName: entry.stampIcon ?? "").foregroundStyle(Color(entry.color))
            Spacer()
            
            if entry.shouldSyncWithCloudKit && coreDataManager.isEntryInCloudStorage(entry) {
                Label("", systemImage: "cloud.fill").foregroundStyle(.cyan.opacity(0.3))
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
        if let replyId = entry.entryReplyId, !replyId.isEmpty {
            if let repliedEntry = fetchEntryById(id: replyId, coreDataManager: coreDataManager) {
                
                VStack(alignment: .trailing) {
                                    entrySectionHeader(entry: repliedEntry)
                    //                    .padding(.horizontal, 10) // Apply horizontal padding consistently
                    NotEditingView_thumbnail(entry: repliedEntry, foregroundColor: UIColor(getDefaultEntryBackgroundColor(colorScheme: colorScheme)), repliedEntryBackgroundColor: $repliedEntryBackgroundColor, repliedEntry: entry)
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)
                            .overlay(
                                  RoundedRectangle(cornerRadius: 15)
                                      .stroke(getTextColor().opacity(0.05), lineWidth: 2)
                            )

                            .background(repliedEntryBackgroundColor)
                            .cornerRadius(15.0)
                                    }
                .onAppear {
                    repliedEntryBackgroundColor = Color(UIColor.backgroundColor(entry: repliedEntry, colorScheme: colorScheme, userPreferences: userPreferences))

                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.6)
                .scaledToFill()
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
                                    .padding(.bottom)
                                Spacer()
                            }
                        }.padding(.bottom)
                    }
               

            }.padding(.horizontal)
            entryTitleView()
            entryBodyView()
            Spacer()
           }
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
    func entryBodyView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                VStack(alignment: .leading) {
                    VStack {
                        
                        if (userPreferences.showLinks) {
                            Text(makeAttributedString(from: entry.content ?? ""))
                            
                        } else {
                            Text(entry.content)
                        }
                    }
                    .font(.custom(userPreferences.fontName, size: CGFloat(userPreferences.fontSize)))
                    .fixedSize(horizontal: false, vertical: true) // Allow text to wrap vertically
                    .padding(2)
                    .foregroundStyle(Color(getTextColor()))
                    
                }
                Spacer() // Push the image to the right
            }
            
            entryMediaView()
            
        }
    }
    
    
    @ViewBuilder
    func entryHeaderView() -> some View {
        HStack {
            Text(formattedTime(time: entry.time))
                .foregroundStyle(Color(getTextColor()).opacity(0.4))
            if (entry.stampIndex != -1 ) {
                Image(systemName: entry.stampIcon).tag(entry.stampIcon)
                    .foregroundColor(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
            }
            if let reminderId = entry.reminderId, !reminderId.isEmpty, reminderExists(with: reminderId), isInList {
                Spacer()
                Image(systemName: "bell.fill").tag("bell.fill").foregroundColor(userPreferences.reminderColor)
            }
        }
        .font(.sectionHeaderSize)
    }
    
    
    
    @ViewBuilder
    func entryContextMenuButtons() -> some View {
        
        Button(action: {
            withAnimation {
                isShowingReplyCreationView = true
                replyEntryId = entry.id.uuidString
            }
        }) {
            Text("Reply")
            Image(systemName: "arrow.uturn.left")
                .foregroundColor(userPreferences.accentColor)
        }
        
        Button(action: {
            UIPasteboard.general.string = entry.content
            print("entry color : \(entry.color)")
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
            if mediaExists(at: fileURL) {
                if let data =  getMediaData(fromFilename: filename) {
                    if isPDF(data: data) {
                    } else {
                        let image = UIImage(data: data)!
                        Button(action: {
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
                isPinned.toggle()
                entry.isPinned = isPinned
                coreDataManager.save(context: coreDataManager.viewContext)
            }
        }) {
            Text(isPinned ? "Unpin" : "Pin")
            Image(systemName: "pin.fill")
                .foregroundColor(.red)
        }
        
        
        
        Button(action: {
            entry.shouldSyncWithCloudKit.toggle()
            
            // Save the flag change in local storage first
            CoreDataManager.shared.save(context: CoreDataManager.shared.viewContext)

            // Save the entry in the appropriate store
            CoreDataManager.shared.saveEntry(entry)
        }) {
            Text(entry.shouldSyncWithCloudKit && coreDataManager.isEntryInCloudStorage(entry) ? "Unsync" : "Sync")
            Image(systemName: "cloud.fill")
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
                }
                else if let data, isPDF(data: data) {
                    HStack {
                        Spacer()

                        Label("Expand PDF", systemImage: "arrow.up.left.and.arrow.down.right") .foregroundColor(Color(UIColor.foregroundColor(background: UIColor.blendedColor(from: UIColor(userPreferences.backgroundColors.first!), with: UIColor(userPreferences.entryBackgroundColor)))))
                            .onTapGesture {
                            isFullScreen.toggle()
                        }
                        .padding(.horizontal, 3)
                        .cornerRadius(20)
                   
                    }
                    CustomAsyncPDFThumbnailView(pdfURL: fileURL).scaledToFit()
                }
                else {
                    if mediaExists(at: fileURL) {
                        CustomAsyncImageView(url: fileURL).scaledToFit()
                        
                    }
                }
            }
            
        }
    }
    
    func createPDFData_entry(entry: Entry) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Your App",
            kCGPDFContextAuthor: "Your Name"
        ]
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, pdfMetaData)
        
        
        let rootView = List {
            Section(header: (Text("\(formattedDate(entry.time))")   
                .cornerRadius(30))) {
                    EntryDetailView_PDF(entry: entry)
                        .padding(10)
                        .environmentObject(userPreferences)
                        .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                }
        }
            .listStyle(.automatic)
            .cornerRadius(30)
        
        let uiHostingController = UIHostingController(rootView: rootView)
        let targetSize = uiHostingController.sizeThatFits(in: UIScreen.main.bounds.size)
        
        UIGraphicsBeginPDFPageWithInfo(CGRect(origin: .zero, size: targetSize), nil)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let img = renderer.image { ctx in
            let uiView = uiHostingController.view
            uiView?.bounds = CGRect(origin: .zero, size: targetSize)
            uiView?.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
            
            DispatchQueue.main.async {
                uiView?.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
            }
        }
        img.draw(in: CGRect(origin: .zero, size: targetSize))
        
        UIGraphicsEndPDFContext()
        return pdfData as Data
    }
    
}













