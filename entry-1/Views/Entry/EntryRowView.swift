////
////  EntryRowView.swift
////  entry-1
////
////  Created by Katyayani G. Raman on 11/28/23.
////
//
//import Foundation
//import SwiftUI
//import CoreData
//import Speech
//import AVFoundation
//import Photos
//import CoreHaptics
//import PhotosUI
//import FLAnimatedImage
//
//
//
//struct EntryRowView: View {
//    @EnvironmentObject var coreDataManager: CoreDataManager
//    @ObservedObject var entry: Entry
//    
//    @State private var isShowingEntryCreationView = false
//    
//    @ObservedObject var markedEntries = MarkedEntries()
//    @EnvironmentObject var userPreferences: UserPreferences
//    @Environment(\.colorScheme) var colorScheme
//    @State private var selectedEntry: Entry?
//    @State private var showDeleteAlert = false
//    @State private var editingEntry: Entry?
//    @State private var padding: CGFloat = 2.0
//
//    
//    @State private var engine: CHHapticEngine?
//    
//    var body : some View {
//        if (!entry.isFault && entry.is) {
//         
//           
//                TextView(entry: entry)
//                
//                    .environmentObject(userPreferences)
//                    .environmentObject(coreDataManager)
//                    .listRowBackground(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
//                    .padding(.vertical, padding)
//                
//                    .swipeActions(edge: .leading) {
//                        ForEach(0..<userPreferences.stamps.count, id: \.self) { index in
//                            if userPreferences.stamps[index].isActive {
//                                Button(action: {
//                                    withAnimation {
//                                        activateButton(entry: entry, index: index)
//                                    }
//                                }) {
//                                    Label("", systemImage: userPreferences.stamps[index].imageName)
//                                }
//                                .tint(userPreferences.stamps[index].color)
//                            }
//                        }
//                    }
//
//        }
//        
//        
//        else {
//            ProgressView()
//        }
//        
//    }
//    
//    
//    
//    private func activateButton(entry: Entry, index: Int) {
//        let mainContext = coreDataManager.viewContext
//        mainContext.performAndWait {
//            
//            if (index == entry.stampIndex) {
//                withAnimation {
//                    entry.stampIndex = -1
//                    entry.image = ""
//                    entry.color = UIColor.tertiarySystemBackground
//                }
//            }
//            else {
//                withAnimation {
//                    entry.stampIndex = Int16(index)
//                    entry.image = userPreferences.stamps[index].imageName
//                    entry.color = UIColor(userPreferences.stamps[index].color)
//                }
//            }
//
//            // Save the context
//            do {
//                try mainContext.save()
//            } catch {
//                print("Failed to save mainContext: \(error)")
//            }
//
//            if userPreferences.stamps[index].isActive {
//                markedEntries.button_entries[index].insert(entry)
//            } else {
//                entry.color = UIColor.tertiarySystemBackground
//                markedEntries.button_entries[index].remove(entry)
//            }
//
//        }
//    }
//
//}
