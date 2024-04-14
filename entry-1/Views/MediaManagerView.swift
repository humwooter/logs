//
//  MediaManagerView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 4/13/24.
//

import Foundation
import SwiftUI

// Assuming each media file has an identifier, name, and size
struct MediaFile: Identifiable {
    let id = UUID()
    let name: String
    let size: Double // size in MB
    let url: URL
}

struct MediaManagerView: View {
    @State private var totalUsedSize = 0.0
    @State private var mediaFiles: [MediaFile] = []
    
    let columns: [GridItem] = [
          GridItem(.flexible(), spacing: 16),
          GridItem(.flexible(), spacing: 16),
          GridItem(.flexible(), spacing: 16) // Add more GridItems for more columns
      ]
      
    var body: some View {
        Section {
            NavigationLink(destination: detailsView()) {
                Text("Larger than 5 MB").font(.caption)
            }
            mainView()
        }
    }
    
    @ViewBuilder
    func mainView() -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                if mediaFiles.count == 0 {
                    Text("No media data")
                }

                ForEach(mediaFiles.sorted{$0.size > $1.size}.prefix(3)) { file in
                        AsyncMediaView(file: file)
                }
            }
            .padding() // Add padding around the grid
        }
        .onAppear {
            calculateStorage()
        }
    }
    
      
    @ViewBuilder
    func detailsView() -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(mediaFiles.sorted{$0.size > $1.size}) { file in
                    AsyncMediaView(file: file)
                }
            }
            .padding() // Add padding around the grid
        }
        .navigationTitle("All Files")
    }
    
    func calculateStorage() {
        let documentsURL = getDocumentsDirectory()
        totalUsedSize = calculateDirectorySize(url: documentsURL) / 1024 // Convert to MB
        mediaFiles = findMediaFilesLargerThan5MB(at: documentsURL)
    }
    
    func findMediaFilesLargerThan5MB(at url: URL) -> [MediaFile] {
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [])
            return files.compactMap { fileURL -> MediaFile? in
                do {
                    let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                    if let fileSize = resourceValues.fileSize, Double(fileSize) / 1_000_000 > 5 {
                        return MediaFile(name: fileURL.lastPathComponent, size: Double(fileSize) / 1_000_000, url: fileURL)
                    }
                } catch {
                    print(error)
                }
                return nil
            }
        } catch {
            print(error)
            return []
        }
    }
}

struct AsyncPDFPreviewView: View {
    let url: URL
    
    var body: some View {
        // Placeholder for PDF rendering
        Text("PDF Content")
    }
}

struct AsyncMediaView: View {
    let file: MediaFile
    @State private var fileType: FileType?
    @State private var deleteMedia = false

    var body: some View {
        if mediaExists(at: file.url) {
            VStack {
                if let fileType = fileType {
                    mediaContent(for: fileType)
                        .frame(width: 100, height: 100)
                        .contextMenu {
                            Button(action: {
                                deleteMedia = true
                            }, label: {
                                Text("Delete")
                            })
                        }
                } else {
                    Text("Loading...")
                        .frame(width: 100, height: 100)
                    
                }
            }.frame(maxWidth: 500)
                .overlay(alignment: .topTrailing) {
                    Text(file.size.fileSizeFormatted())
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .font(.caption)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            
                .alert("Are you sure you want to delete this media?", isPresented: $deleteMedia) {
                    Button("Delete", role: .destructive) {
                        deleteMediaFile()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Media Size: \(file.size.fileSizeFormatted())")
                }
                .onAppear {
                    determineFileType(url: file.url)
                }
        }
    }
    
    func deleteMediaFile() {
        DispatchQueue.global(qos: .background).async {
            do {
                try FileManager.default.removeItem(at: file.url)
                DispatchQueue.main.async {
                    // Handle any UI updates or state changes here
                    print("File successfully deleted")
                }
            } catch {
                DispatchQueue.main.async {
                    // Handle errors, e.g., show an error message
                    print("Error deleting file: \(error)")
                }
            }
        }
    }


    @ViewBuilder
    private func mediaContent(for type: FileType) -> some View {
        switch type {
        case .gif, .image:
            CustomAsyncImageView(url: file.url).scaledToFit()
        case .pdf:
            CustomAsyncPDFThumbnailView(pdfURL: file.url).scaledToFit()
        default:
            Text("Unsupported format").scaledToFit()
        }
    }

    private func determineFileType(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fileType = identifyFileType(url: url)
            DispatchQueue.main.async {
                self.fileType = fileType
            }
        }
    }
}

enum FileType {
    case gif, pdf, image, none
}


struct StorageDataBar: View {
    var storageData: StorageData
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .foregroundColor(Color.gray.opacity(0.3))
                    .frame(height: 20)
                
                HStack(spacing: 0) {
                    Capsule()
                        .foregroundColor(.green)
                        .frame(width: geometry.size.width * CGFloat(storageData.usedStoragePhoto / storageData.totalStorage), height: 20)
                    
                    Capsule()
                        .foregroundColor(.blue)
                        .frame(width: geometry.size.width * CGFloat(storageData.usedStoragePDF / storageData.totalStorage), height: 20)
                }
            }
        }
    }
}

struct StorageData {
    var totalStorage: Double
    var usedStoragePhoto: Double
    var usedStoragePDF: Double
}

func calculateStorageData(mediaFiles: [MediaFile]) -> StorageData {
    let fileManager = FileManager.default
    do {
        let attributes = try fileManager.attributesOfFileSystem(forPath: NSHomeDirectory())
        let totalStorage = (attributes[.systemSize] as? NSNumber)?.doubleValue ?? 0
        let freeStorage = (attributes[.systemFreeSize] as? NSNumber)?.doubleValue ?? 0
        let usedStorageTotal = totalStorage - freeStorage

        let usedStoragePhoto = mediaFiles.filter { identifyFileType(url: $0.url) == .gif || identifyFileType(url: $0.url) == .image }.reduce(0) { $0 + $1.size * 1_000_000 }
        let usedStoragePDF = mediaFiles.filter { identifyFileType(url: $0.url) == .pdf }.reduce(0) { $0 + $1.size * 1_000_000 }

        return StorageData(totalStorage: usedStorageTotal, usedStoragePhoto: usedStoragePhoto, usedStoragePDF: usedStoragePDF)
    } catch {
        print("Error getting storage info: \(error)")
        return StorageData(totalStorage: 0, usedStoragePhoto: 0, usedStoragePDF: 0)
    }
}

func identifyFileType(url: URL) -> FileType {
    if let data = getMediaData(fromURL: url) {
        if isPDF(data: data) {
            return .pdf
        } else if isGIF(data: data) {
            return .gif
        } else {
            return .image
        }
    }
    return .image
}
