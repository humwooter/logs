//
//  EntryView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 11/28/23.
//

import Foundation

import Foundation
import SwiftUI
import CoreData
import Speech
import AVFoundation
import Photos
import CoreHaptics
import PhotosUI
import FLAnimatedImage


class DayChange: ObservableObject {
    @Published var dayChanged = false
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(dayDidChange), name: .NSCalendarDayChanged, object: nil)
    }
    @objc func dayDidChange() {
        dayChanged.toggle()
    }
}


//class MarkedEntries: ObservableObject {
//    @Published var button_entries: [Set<Entry>] = Array(repeating: Set<Entry>(), count: 21)
//}

class Refresh: ObservableObject {
    @Published var needsRefresh: Bool = false
}

struct TextView : View {
    @EnvironmentObject var coreDataManager: CoreDataManager
     
     @EnvironmentObject var userPreferences: UserPreferences
     @ObservedObject var entry : Entry
     
     @State private var editingContent : String = ""
     @State private var isEditing : Bool = false
     
     @State private var engine: CHHapticEngine?
     @FocusState private var focusField: Bool
     @Environment(\.colorScheme) var colorScheme
     @State private var selectedItem : PhotosPickerItem?
     @State private var showingDeleteConfirmation = false
     
     @State private var selectedImage : UIImage?
     
     @State private var showPhotos = false
     @State private var selectedData: Data?
     @State private var showCamera = false
     @State private var shareImage: UIImage? = nil
     
     @State private var showEntry = true
     
     @State private var showDocumentPicker = false
       @State private var pdfFileURL: URL?
     @State private var pdfData: Data?
     @State private var isExporting = false
     
     @Binding var repliedEntryId: String? //should store the id of the current entry
     @Binding var isShowingEntryCreationView: Bool
     @Binding var isShowingReplyCreationView: Bool

    var body : some View {
        
        if (!entry.isFault) {
            Section {
                if (entry.isShown) {
                    NotEditingView(entry: entry, isEditing: $isEditing, foregroundColor: UIColor(getDefaultEntryBackgroundColor(colorScheme: colorScheme)), replyEntryId: entry.entryReplyId).environmentObject(userPreferences).environmentObject(coreDataManager)
                        .blur(radius: !entry.isHidden ? 0 : 7)
                        .contextMenu {
                            entryContextMenuButtons()
                        }
                        .onAppear {
                            if let reminderId = entry.reminderId, !reminderId.isEmpty {
                                if !reminderExists(with: reminderId) {
                                    entry.reminderId = ""
                                } else {
                                    reminderIsComplete(reminderId: reminderId) { isCompleted in
                                        DispatchQueue.main.async {
                                            if isCompleted {
                                                entry.reminderId = ""
                                            } else {
                                                print("The reminder is not completed or does not exist.")
                                            }
                                        }
                                    }
                                    do {
                                        try coreDataManager.viewContext.save()
                                    } catch {
                                        print("Failed to save viewContext: \(error)")
                                    }
                                }
                            }
                        }
                        .onChange(of: isEditing) { newValue in
                                              if newValue {
                                                  editingContent = entry.content
                                              }
                                          }
//                        .onChange(of: isEditing) { newValue in
//                            if newValue {
//                                editingContent = entry.attributedContent ?? buildAttributedString(
//                                    content: entry.content,
//                                    formattingData: entry.formattedContent,
//                                    fontSize: userPreferences.fontSize,
//                                    fontName: userPreferences.fontName
//                                )
//                            }
//                        }
        
                        .sheet(isPresented: $isEditing) {
                            EditingEntryView(entry: entry, editingContent: $editingContent, isEditing: $isEditing)
                                .foregroundColor(userPreferences.accentColor)
                                .presentationDragIndicator(.hidden)
                                .environmentObject(userPreferences)
                                .environmentObject(coreDataManager)
                        }
                    
                        .sheet(isPresented: $isExporting) {
                            if let data = pdfData {
                                Text("test")
                                .fileExporter(
                                    isPresented: $isExporting,
                                    document: PDFDoc(data: data),
                                    contentType: .pdf,
                                    defaultFilename: "MyDocument.pdf"
                                ) { result in
                                    switch result {
                                    case .success(let url):
                                        print("PDF successfully saved at \(url)")
                                    case .failure(let error):
                                        print("Failed to save PDF: \(error)")
                                    }
                                }
                            }
                        }
                }
                
            }
        header: {
                entrySectionHeader()
            }
            footer: {
                entrySectionFooter()
            }
            .onAppear {
                showEntry = !entry.isHidden
            }
        }
         
        
    }
    
//    private func updateAttributedStringFont() {
//        let newFont = UIFont(name: userPreferences.fontName, size: userPreferences.fontSize) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
//        let newAttributes: [NSAttributedString.Key: Any] = [
//            .font: newFont,
//            .foregroundColor: UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))))
//        ]
//        
//        let mutableAttributedString = NSMutableAttributedString(attributedString: editingContent)
//        mutableAttributedString.addAttributes(newAttributes, range: NSRange(location: 0, length: mutableAttributedString.length))
//        editingContent = mutableAttributedString
//    }
    

    
    func deleteEntry(entry: Entry) {
        let mainContext = coreDataManager.viewContext
        mainContext.performAndWait {
            let filename = entry.mediaFilename
            let parentLog = entry.relationship
            
            
            // Fetch the entry in the main context
            let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
            do {
                let fetchedEntries = try mainContext.fetch(fetchRequest)
                guard let entryToDeleteInContext = fetchedEntries.first else {
                    print("Failed to fetch entry in main context")
                    return
                }
                
                print("Entry being deleted: \(entryToDeleteInContext)")
  
                parentLog?.removeFromRelationship(entry)
                entryToDeleteInContext.isRemoved = true
                try mainContext.save()
                
            } catch {
                print("Failed to fetch entry in main context: \(error)")
            }
        }
    }
    
    @ViewBuilder
    func entrySectionFooter() -> some View {
        HStack {
//            Spacer()
//            if entry.shouldSyncWithCloudKit {
//                Label("", systemImage: "cloud")
//                    .foregroundStyle(.white.opacity(0.1))
//            }
        }
    }
    
    @ViewBuilder
    func entryContextMenuButtons() -> some View {
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
            withAnimation {
                repliedEntryId = entry.id.uuidString
                isShowingReplyCreationView = true
            }
        }) {
            Text("Reply")
            Image(systemName: "arrow.uturn.left")
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
                entry.isHidden.toggle()
                coreDataManager.save(context: coreDataManager.viewContext)
            }

        }, label: {
            Label(!entry.isHidden ? "Hide Entry" : "Unhide Entry", systemImage: entry.isHidden ? "eye.slash.fill" : "eye.fill")
        })
        
        if let filename = entry.mediaFilename {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            if mediaExists(at: fileURL) {
                if let data =  getMediaData(fromFilename: filename) {
                    
                    if !isPDF(data: data) {
                        let image = UIImage(data: data)!
                        Button(action: {
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let fileURL = documentsDirectory.appendingPathComponent(filename)
                            
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            
                        }, label: {
                            Label("Save Image", systemImage: "photo.badge.arrow.down.fill")
                        })
                    } else {
                         
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
    

    func updateReminders() {
        if let reminderId = entry.reminderId, !reminderId.isEmpty, reminderExists(with: reminderId) {
            if !reminderExists(with: reminderId) {
                entry.reminderId = ""
                print("reminder doesn't exist")
            }
            reminderIsComplete(reminderId: reminderId) { isCompleted in
                DispatchQueue.main.async {
                    if isCompleted {
                        entry.reminderId = ""
                    } else {
                        print("The reminder is not completed or does not exist.")
                    }
                }
            }
            do {
                try coreDataManager.viewContext.save()
            } catch {
                print("Failed to save viewContext: \(error)")
            }
        }
    }
    
    func getIdealHeaderTextColor() -> Color {
        return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(userPreferences.backgroundColors.first ?? Color.clear), and: UIColor(userPreferences.backgroundColors[1])), colorScheme: colorScheme))
    }
    
    
    @ViewBuilder
    func entrySectionHeader() -> some View {
        HStack {
                Text("\(entry.isPinned && formattedDate(entry.time) != formattedDate(Date()) ? formattedDateShort(from: entry.time) : formattedTime(time: entry.time))")
                .foregroundStyle(getIdealHeaderTextColor().opacity(0.5))
                if let timeLastUpdated = entry.lastUpdated {
                    if formattedTime_long(date: timeLastUpdated) != formattedTime_long(date: entry.time), userPreferences.showMostRecentEntryTime {
                        HStack {
                            Image(systemName: "arrow.right")
                            Text(formattedTime_long(date: timeLastUpdated))
                        }
                        .foregroundStyle(getIdealHeaderTextColor().opacity(0.5))
                    }

                }

            Image(systemName: entry.stampIcon).foregroundStyle(Color(entry.color))
            Spacer()
            
            if coreDataManager.isEntryInCloudStorage(entry) {
                Label("", systemImage: "cloud.fill").foregroundStyle(.cyan.opacity(0.3))
            }
            
            if let reminderId = entry.reminderId, !reminderId.isEmpty, reminderExists(with: reminderId) {
                
                Label("", systemImage: "bell.fill").foregroundColor(userPreferences.reminderColor)
            }

            if (entry.isPinned) {
                Label("", systemImage: "pin.fill").foregroundColor(userPreferences.pinColor)

            }
            
            Image(systemName: entry.isShown ? "chevron.up" : "chevron.down").foregroundColor(userPreferences.accentColor)
                .contentTransition(.symbolEffect(.replace.offUp))
        }

        .font(.system(size: UIFont.systemFontSize))
        .onTapGesture {
            vibration_light.impactOccurred()
                entry.isShown.toggle()
                coreDataManager.save(context: coreDataManager.viewContext)
        }
    }
    
    func hideEntry () {
        if entry.isHidden == nil {
            entry.isHidden = false
        }
        entry.isHidden.toggle()
    }

    
}
