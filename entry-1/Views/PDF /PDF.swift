//
//  PDF.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/27/23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers




struct LogDetailView_PDF: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    @Binding var height: CGFloat


    
    let log: Log
    
    var body: some View {
        if let entries = log.relationship as? Set<Entry>, !entries.isEmpty {
            Section {
                List(entries.sorted(by: { $0.time > $1.time }), id: \.self) { entry in
                    EntryDetailView_PDF(entry: entry)
                        .environmentObject(userPreferences)
                        .background() {
                            GeometryReader { geometry in
                                Path { path in
                                    height = geometry.size.height
                                    print("Text frame size = \(geometry.size)")
                                }
                            }
                        }
                
                    
                }

                .onAppear(perform: {
                    print("LOG detailz: \(log)")
                })
            
                .listStyle(.automatic)
            }
 
            
            .navigationBarTitleDisplayMode(.inline)
        } else {
            Text("No entries available")
                .foregroundColor(.gray)
        }
    }
    

    func getNavigationTitle () -> String{
        let sortedEntries = (log.relationship as? Set<Entry>)?.sorted(by: { $0.time < $1.time })
        let firstEntryTime = sortedEntries?.first?.time

        let navigationTitle = firstEntryTime != nil ? formattedDateLong(firstEntryTime!) : "No entries"
        return navigationTitle
    }
}


struct EntryDetailView_PDF: View { //used in EntryDetailView
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userPreferences: UserPreferences
    @State var image: UIImage?
    @State var shareSheetShown = false
    let entry: Entry
    
        
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
                            Image(systemName: entry.stampIcon).tag(entry.stampIcon)
                                .foregroundColor(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
                        }
                    }
                    Text(entry.content)
                        .fontWeight(entry.stampIndex != -1 && entry.stampIndex != nil ? .bold : .regular)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                }
                Spacer() // Push the image to the right
            }
            
            if entry.mediaFilename != "" {
                if let filename = entry.mediaFilename {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsDirectory.appendingPathComponent(filename)
                    let data = try? Data(contentsOf: fileURL)
                    if let data = data {
                        CustomDataImageView(imageData: data).scaledToFit()
                    }
                }
                
            }
            
        }.padding(.vertical, 5)

        
    }
    
}





struct PDFDoc_url: FileDocument {
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

struct PDFDoc: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] } // Specify the content type as PDF
    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
