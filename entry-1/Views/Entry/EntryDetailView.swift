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
    let entry: Entry
    @State private var isFullScreen = false
    

    @State private var mediaDim: CGFloat = 100

@State var showEntry = true
@State var isPinned = false
    
    var body: some View {
        finalView().padding(.vertical, 5)
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
            .blur(radius: showEntry ? 0 : 7)
        
        
    }
    
    func getIdealTextColor() -> Color {
        var entryBackgroundColor =  UIColor(userPreferences.entryBackgroundColor)
        var backgroundColor = isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear
        var blendedBackground = UIColor.blendedColor(from: entryBackgroundColor, with: UIColor(backgroundColor))
        return Color(UIColor.fontColor(forBackgroundColor: blendedBackground))
    }
    
    
    @ViewBuilder
    func finalView() -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {
                HStack {
                    entryHeaderView()
                        .font(.system(size: UIFont.systemFontSize))
                    Spacer()
                }
                Spacer()
//                entryHeaderView().font(.system(size: UIFont.systemFontSize)).padding([.top, .bottom, .trailing], 7)
                if let repliedId = entry.entryReplyId {
                        finalRepliedView()
                } else {
                    entryView()
                }
            }
        }
    }
    
    @ViewBuilder
    func entrySectionHeader(entry: Entry) -> some View {
        HStack {

                Text("\(entry.isPinned && formattedDate(entry.time) != formattedDate(Date()) ? formattedDateShort(from: entry.time) : formattedTime(time: entry.time))")
                .foregroundStyle(getIdealTextColor().opacity(0.5))
                if let timeLastUpdated = entry.lastUpdated {
                    if formattedTime_long(date: timeLastUpdated) != formattedTime_long(date: entry.time), userPreferences.showMostRecentEntryTime {
                        HStack {
                            Image(systemName: "arrow.right")
                            Text(formattedTime_long(date: timeLastUpdated))
                        }
                        .foregroundStyle(getIdealTextColor().opacity(0.5))
                    }

                }

            Image(systemName: entry.stampIcon).foregroundStyle(Color(entry.color))
            Spacer()
            
            if let reminderId = entry.reminderId, !reminderId.isEmpty, entry_1.reminderExists(with: reminderId) {
                
                Label("", systemImage: "bell.fill").foregroundColor(userPreferences.reminderColor)
            }

            if (entry.isPinned) {
                Label("", systemImage: "pin.fill").foregroundColor(userPreferences.pinColor)

            }
        }
        .font(.system(size: max(UIFont.systemFontSize*0.8,5)))

    }
    
    @ViewBuilder
    func repliedEntryView() -> some View {
        if let replyId = entry.entryReplyId, !replyId.isEmpty {
            if let repliedEntry = fetchEntryById(id: replyId, coreDataManager: coreDataManager) {
                
                VStack(alignment: .trailing) {
                                    entrySectionHeader(entry: repliedEntry)
                    //                    .padding(.horizontal, 10) // Apply horizontal padding consistently
                    NotEditingView_thumbnail(entry: repliedEntry, foregroundColor: UIColor(getDefaultEntryBackgroundColor(colorScheme: colorScheme)))
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)
                            .overlay(
                                  RoundedRectangle(cornerRadius: 15)
                                      .stroke(getIdealTextColor().opacity(0.05), lineWidth: 2)
                            )

                            .background(Color(UIColor.backgroundColor(entry: repliedEntry, colorScheme: colorScheme, userPreferences: userPreferences)))
                            .cornerRadius(15.0)
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.6)
                .scaledToFill()
            }
        }
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
                                    .foregroundStyle(getIdealTextColor().opacity(0.3))
                                    .frame(maxWidth: .infinity, maxHeight: 5) // Correctly size the frame based on the shape dimensions
                                    .padding(.bottom)
                                Spacer()
                            }
                        }.padding(.bottom)
                    }
               

            }.padding(.horizontal)
            entryView()
            Spacer()
           }
    }
    
    @ViewBuilder
    func entryView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                VStack(alignment: .leading) {
//                        entryHeaderView()
//                        .font(.system(size: UIFont.systemFontSize))


                    VStack {
                        
                        if (userPreferences.showLinks) {
                            Text(makeAttributedString(from: entry.content))

                        } else {
                            Text(entry.content)
                        }
                    }
                    .foregroundStyle(Color(getTextColor()))
                    .fixedSize(horizontal: false, vertical: true) // Allow text to wrap vertically
                        .contextMenu {
                            entryContextMenuButtons()
                        }
                }
                Spacer() // Push the image to the right
            }
            
            entryMediaView()

        }
    }
    
    func getTextColor() -> UIColor { //different implementation since the background will always be default unless
        let defaultEntryBackgroundColor =  getDefaultEntryBackgroundColor(colorScheme: colorScheme)

        let foregroundColor =  isClear(for: UIColor(userPreferences.entryBackgroundColor)) ? UIColor(defaultEntryBackgroundColor) : UIColor(userPreferences.entryBackgroundColor)
        let backgroundColor_top = isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear
        
        let backgroundColor_bottom = isClear(for: UIColor(userPreferences.backgroundColors[1])) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors[1]

        
        let blendedBackgroundColors = UIColor.blendedColor(from: UIColor(backgroundColor_top), with: UIColor(backgroundColor_bottom))
        let blendedColor = UIColor.blendedColor(from: foregroundColor, with: UIColor(Color(backgroundColor_top)))
        let fontColor = UIColor.fontColor(forBackgroundColor: blendedColor)
        return fontColor
    }
    
    
    @ViewBuilder
    func entryHeaderView() -> some View {
        HStack {
            Text(formattedTime(time: entry.time))
                .font(.footnote)
                .foregroundStyle(Color(getTextColor()).opacity(0.4))
            if (entry.stampIndex != -1 ) {
                Image(systemName: entry.stampIcon).tag(entry.stampIcon)
                    .foregroundColor(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
            }
//            if let reminderId = entry.reminderId, !reminderId.isEmpty, reminderExists(with: reminderId) {
//                Spacer()
//                Image(systemName: "bell.fill").tag("bell.fill").foregroundColor(userPreferences.reminderColor)
//            }
        }
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
        
//        Button(action: {
//            let pdfData = createPDFData_entry(entry: entry)
//            let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("entry.pdf")
//            try? pdfData.write(to: tmpURL)
//            let activityVC = UIActivityViewController(activityItems: [tmpURL], applicationActivities: nil)
//            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//                let window = windowScene.windows.first
//                window?.rootViewController?.present(activityVC, animated: true, completion: nil)
//            }
//        }, label: {
//            Label("Share Entry", systemImage: "square.and.arrow.up")
//        })
        
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













