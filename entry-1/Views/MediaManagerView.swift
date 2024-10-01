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
                Text("Larger than 5 MB")
                    .font(.customCaption)
            }
                mainView()
        }
    }
    
    @ViewBuilder
    func mainView() -> some View {
        
        ScrollView {
            
            LazyVGrid(columns: columns, spacing: 16) {
        

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
                        let fileType = identifyFileType(url: fileURL)
                        if [.gif, .pdf, .image].contains(fileType) {
                            return MediaFile(name: fileURL.lastPathComponent, size: Double(fileSize) / 1_000_000, url: fileURL)
                        }
                    }
                } catch {
                    print("Error getting file information: \(error)")
                }
                return nil
            }
        } catch {
            print("Error reading directory contents: \(error)")
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
                        .font(.customCaption)
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
        print("FILE BEING DELETED IS: \(file.url)")
           DispatchQueue.global(qos: .background).async {
               do {
                   // Get the documents directory
                   let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                   
//                   // Ensure the file is within the documents directory
//                   guard file.url.absoluteString.hasPrefix(documentsUrl.absoluteString) else {
//                       throw NSError(domain: "FileError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Attempted to delete file outside of documents directory"])
//                   }
                   
                   // Check if the file exists before attempting to delete
                   guard FileManager.default.fileExists(atPath: file.url.path) else {
                       throw NSError(domain: "FileError", code: 2, userInfo: [NSLocalizedDescriptionKey: "File does not exist"])
                   }
                   
                   // Use the expanded identifyFileType function to determine the file type
                   let fileType = identifyFileType(url: file.url)
                   
                   // Check if the file type is allowed for deletion
                   guard [.gif, .pdf, .image].contains(fileType) else {
                       throw NSError(domain: "FileError", code: 3, userInfo: [NSLocalizedDescriptionKey: "File type not allowed for deletion"])
                   }
                   
                   // Attempt to delete the file
                   try FileManager.default.removeItem(at: file.url)
                   
                   DispatchQueue.main.async {
                       print("File successfully deleted")
                       // Handle any UI updates or state changes here
                       // You might want to update your mediaFiles array or trigger a UI refresh
                   }
               } catch {
                   DispatchQueue.main.async {
                       print("Error deleting file: \(error.localizedDescription)")
                       // Handle errors, e.g., show an error message to the user
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

enum FileType {
    case gif, pdf, image, sqlite, sqliteRelated, none
}

func identifyFileType(url: URL) -> FileType {
    let fileExtension = url.pathExtension.lowercased()
    
    // Check for SQLite-related files first
    if fileExtension == "sqlite" || url.lastPathComponent.hasSuffix("sqlite-shm") || url.lastPathComponent.hasSuffix("sqlite-wal") {
        return .sqliteRelated
    }
    
    if let data = getMediaData(fromURL: url) {
        if isPDF(data: data) {
            return .pdf
        } else if isGIF(data: data) {
            return .gif
        } else if isImage(data: data) {
            return .image
        } else if isSQLite(data: data) {
            return .sqlite
        }
    }
    
    return .none
}

func isSQLite(data: Data) -> Bool {
    // SQLite files start with the string "SQLite format 3\0"
    let sqliteHeader = "SQLite format 3\0"
    return data.prefix(16) == Data(sqliteHeader.utf8)
}

func isImage(data: Data) -> Bool {
    // Simple check for common image formats
    let imageHeaders: [Data] = [
        Data([0xFF, 0xD8, 0xFF]),          // JPEG
        Data([0x89, 0x50, 0x4E, 0x47]),    // PNG
        Data([0x47, 0x49, 0x46])           // GIF
    ]
    return imageHeaders.contains { data.prefix($0.count) == $0 }
}
