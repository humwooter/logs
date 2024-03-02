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
    let entry: Entry
    @State private var isFullScreen = false
    

    
@State var showEntry = true
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                VStack(alignment: .leading) {
                        entryHeaderView()

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

        }.padding(.vertical, 5)
            .onAppear {
                showEntry = !entry.isHidden
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
    
    func getTextColor() -> UIColor { //different implementation since the background will always be default unless userPreferences.entryBackgroundColor != .clear
        let defaultBackgroundColor =  colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground

        let foregroundColor =  isClear(for: UIColor(userPreferences.entryBackgroundColor)) ? defaultBackgroundColor : UIColor(userPreferences.entryBackgroundColor)
        let blendedBackgroundColors = UIColor.blendColors(foregroundColor: UIColor(userPreferences.backgroundColors[1].opacity(0.5) ?? Color.clear), backgroundColor: UIColor(userPreferences.backgroundColors[0] ?? Color.clear))
        let blendedColor = UIColor.blendColors(foregroundColor: foregroundColor, backgroundColor: UIColor(Color(blendedBackgroundColors).opacity(0.4)))
        let fontColor = UIColor.fontColor(backgroundColor: blendedColor)
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
        }
    }
    @ViewBuilder
    func entryContextMenuButtons() -> some View {
        Button(action: {
            UIPasteboard.general.string = entry.content
            print("entry color : \(entry.color)")
        }) {
            Text("Copy Message")
            Image(systemName: "doc.on.doc")
        }
        
        Button(action: {
            let pdfData = createPDFData_entry(entry: entry)
            let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("entry.pdf")
            try? pdfData.write(to: tmpURL)
            let activityVC = UIActivityViewController(activityItems: [tmpURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let window = windowScene.windows.first
                window?.rootViewController?.present(activityVC, animated: true, completion: nil)
            }
        }, label: {
            Label("Share Entry", systemImage: "square.and.arrow.up")
        })
        
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
                entry.isPinned.toggle()
                coreDataManager.save(context: coreDataManager.viewContext)
            }
        }) {
            Text(entry.isPinned ? "Unpin" : "Pin")
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
                    if imageExists(at: fileURL) {
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













