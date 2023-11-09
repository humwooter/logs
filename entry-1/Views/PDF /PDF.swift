//
//  PDF.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/27/23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers





func createPDFData_entries(entries: [Entry], userPreferences: UserPreferences) -> Data {
    print("entries to turn into pdfs: \(entries)")
    let pdfMetaData = [
        kCGPDFContextCreator: "Your App",
        kCGPDFContextAuthor: "Your Name"
    ]
    let pdfData = NSMutableData()
    
    // Create a dummy view controller to host our SwiftUI view
    let uiHostingController = UIHostingController(rootView: EmptyView())
    let width = UIScreen.main.bounds.width // Page width is the screen width, or another fixed value as needed

    // Calculate the total height needed for all entries
    var totalHeight: CGFloat = 0
    let views = entries.map { entry -> UIView in
        let rootView = EntryDetailView_PDF(entry: entry)
            .padding(10)
            .environmentObject(userPreferences)
            .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
        
        let childHostingController = UIHostingController(rootView: rootView)
        childHostingController.view.frame = CGRect(x: 0, y: totalHeight, width: width, height: CGFloat.greatestFiniteMagnitude)
        childHostingController.view.sizeToFit()
        totalHeight += childHostingController.view.frame.height
        return childHostingController.view
    }

    // Now we have the total height, we can start the PDF context
    UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: width, height: totalHeight), pdfMetaData)
    
    // Start a new page for all entries
    UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: width, height: totalHeight), nil)

    // Render all entries on this single page
    views.forEach { view in
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
    }
    
    UIGraphicsEndPDFContext()
    
    return pdfData as Data
}

func createImage_entry(entry: Entry) -> UIImage {
    let uiHostingController = UIHostingController(rootView: EntryDetailView_PDF(entry: entry))
    let targetSize = uiHostingController.sizeThatFits(in: UIScreen.main.bounds.size)
    
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    let img = renderer.image { ctx in
        let uiView = uiHostingController.view
        uiView?.bounds = CGRect(origin: .zero, size: targetSize)
        uiView?.backgroundColor = .clear
        uiView?.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
    }
    
    return img
}

struct LogDetailView_PDF : View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    
    let log: Log
    
    var body: some View {
        if let entries = log.relationship as? Set<Entry>, !entries.isEmpty {
            List(entries.sorted(by: { $0.time > $1.time }), id: \.self) { entry in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(formattedTime(time: entry.time))
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                Spacer()
                                if (entry.buttons.filter{$0}.count > 0 ) {
                                    Image(systemName: entry.image).tag(entry.image)
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
                                    //                                        .foregroundStyle(.red, .green, .blue, .purple)
                                }
                                
                            }
                            Text(entry.content)
                                .fontWeight(entry.buttons.filter{$0}.count > 0 ? .bold : .regular)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                        }
                        Spacer() // Push the image to the right
                        
                    }
                    
                    
                    
                    if entry.imageContent != "" {
                        if let filename = entry.imageContent {
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let fileURL = documentsDirectory.appendingPathComponent(filename)
                            let data = try? Data(contentsOf: fileURL)
                            if let image_data = data {
                                Image(uiImage: UIImage(data: image_data)!)
                                    .resizable()
                                    .scaledToFit()
                            }
                            
                            
                            //                            if let data = data, isGIF(data: data) {
                            //
                            //                                let imageView = AnimatedImageView(url: fileURL)
                            //
                            //                                let asyncImage = UIImage(data: data)
                            //
                            //                                let height = asyncImage!.size.height
                            //
                            //                                AnimatedImageView(url: fileURL).scaledToFit()
                            //
                            //
                            //                                // Add imageView
                            //                            } else {
                            //                                UIImage(data: data)
                            //                            }
                        }
                    }
                }
                //                .listRowBackground(backgroundColor(entry: entry))
            }
            .listStyle(.automatic)
            
            .navigationBarTitleDisplayMode(.inline)
        } else {
            Text("No entries available")
                .foregroundColor(.gray)
        }
    }
    
    //    func formattedTime(_ date: Date) -> String {
    //        let formatter = DateFormatter()
    //        formatter.timeStyle = .short
    //        return formatter.string(from: date)
    //    }
    
}
//struct PDFDocument: View {
//    var filteredLogs: [Log] // Replace with your actual data model
//
//    var body: some View {
//        ForEach(filteredLogs, id: \.self) { log in
//            LogDetailView(log: log) // Replace with your actual SwiftUI view
//        }
//    }
//}


struct PDFDocument: FileDocument {
    var pdfURL: URL?
    
    init(pdfURL: URL?) {
        self.pdfURL = pdfURL
    }
    
    static var readableContentTypes: [UTType] { [.pdf] }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let url = URL(dataRepresentation: data, relativeTo: nil) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        pdfURL = url
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try Data(contentsOf: pdfURL!)
        return .init(regularFileWithContents: data)
    }
}
