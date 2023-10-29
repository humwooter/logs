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
    
    
    let semaphore = DispatchSemaphore(value: 0)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(formattedTime(time: entry.time))
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Spacer()
                        if (entry.stampIndex != -1 && entry.stampIndex != nil ) {
                            Image(systemName: entry.image).tag(entry.image)
                                .foregroundColor(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
                        }
                    }
                    Text(entry.content)
                        .fontWeight(entry.stampIndex != -1 && entry.stampIndex != nil ? .bold : .regular)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = entry.content ?? ""
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
                                UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
                            }, label: {
                                Label("Share Entry", systemImage: "square.and.arrow.up")
                            })
                        }
                }
                Spacer() // Push the image to the right
            }
            
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
                    } else {
                        if imageExists(at: fileURL) {
                            CustomAsyncImageView(url: fileURL).scaledToFit()
                            
                        }
                    }
                }
                
            }
            
        }.padding(.vertical, 5)
            .sheet(isPresented: $shareSheetShown) {
                if let entry_uiimage = image {
                    let entryImage = Image(uiImage: entry_uiimage)
                    ShareLink(item: entryImage, preview: SharePreview("", image: entryImage))
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
        
        var contentHeight: CGFloat = 0 // This will store the content's height
        
        
        
        let rootView = List {
            Section(header: (Text("\(formattedDate(entry.time))")              /*.font(.custom(userPreferences.fontName, size: userPreferences.fontSize))*/
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
        }
        img.draw(in: CGRect(origin: .zero, size: targetSize))
        
        UIGraphicsEndPDFContext()
        return pdfData as Data
    }
    
}



struct EntryDetailView_PDF: View { //used in LogDetailView
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @State var image: UIImage?
    @State var shareSheetShown = false
    let entry: Entry
    
    
    let semaphore = DispatchSemaphore(value: 0)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(formattedTime(time: entry.time))
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Spacer()
                        if (entry.stampIndex  != -1) {
                            Image(systemName: entry.image).tag(entry.image)
                                .foregroundColor(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
                        }
                    }
                    Text(entry.content)
                        .fontWeight(entry.stampIndex != -1 && entry.stampIndex != nil ? .bold : .regular)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                }
                Spacer() // Push the image to the right
            }
            
            if entry.imageContent != "" {
                if let filename = entry.imageContent {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsDirectory.appendingPathComponent(filename)
                    let data = try? Data(contentsOf: fileURL)
                    if let data = data {
                        CustomDataImageView(imageData: data).scaledToFit()
                    }
                }
                
            }
            
        }.padding(.vertical, 5)
            .sheet(isPresented: $shareSheetShown) {
                if let entry_uiimage = image {
                    let entryImage = Image(uiImage: entry_uiimage)
                    ShareLink(item: entryImage, preview: SharePreview("", image: entryImage))
                }
            }
        
    }
    
}
























