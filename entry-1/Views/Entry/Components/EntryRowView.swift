//
//  EntryRowView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 2/26/24.
//

import Foundation
import SwiftUI
import CoreData
import Speech
import AVFoundation
import Photos
import CoreHaptics
import PhotosUI
import FLAnimatedImage


struct EntryRowView: View {
    // data management
    @EnvironmentObject var coreDataManager: CoreDataManager
    @ObservedObject var entry: Entry

    // user interface state
    @Binding  var isShowingEntryCreationView: Bool
    @Binding var isShowingReplyCreationView: Bool
    @Binding  var repliedEntryId: String?

    @State private var selectedEntry: Entry?
    @State private var showDeleteAlert = false
    @State private var editingEntry: Entry?
    @State private var padding: CGFloat = 0.0

    // user preferences and environment settings
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme

    // haptic feedback engine
    @State private var engine: CHHapticEngine?
    @State var textColor = Color.white

    
    
    var body: some View {
        if !entry.isFault {
            TextView(entry: entry, repliedEntryId: $repliedEntryId, isShowingEntryCreationView: $isShowingEntryCreationView, isShowingReplyCreationView: $isShowingReplyCreationView)
                .environmentObject(userPreferences)
                .environmentObject(coreDataManager)
//                .listRowBackground(calculateTextColor(basedOn: userPreferences.backgroundColors.first ?? Color.clear, background2: userPreferences.backgroundColors[1], entryBackground: userPreferences.entryBackgroundColor, colorScheme: colorScheme))
                .listRowBackground( UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
                .padding(.bottom, padding)
                .swipeActions(edge: .leading) {
                    stampsRowView()
                }
                .onTapGesture {
                    print("ENTRY COLOR IS: \(entry.color)")
                    printColorComponents(color: entry.color)
                }
        }
    }
    

    
    @ViewBuilder
    private func stampsRowView() -> some View {
        ForEach(0..<userPreferences.stamps.count, id: \.self) { index in
            if userPreferences.stamps[index].isActive {
                Button(action: {
                    withAnimation(.smooth) {
                        activateButton(entry: entry, index: index)
                    }
                }) {
                    Label("", systemImage: userPreferences.stamps[index].imageName)
                }
                .tint(userPreferences.stamps[index].color)
            }
        }
    }
    
    private func activateButton(entry: Entry, index: Int) {
        print("ENTERED AACTIVATE BUTTON")
        print("INDEX IS: \(index)")
        print("ENTRY INDEX: \(entry.stampIndex)")

        let mainContext = coreDataManager.viewContext
        mainContext.performAndWait {
            
            if (index == entry.stampIndex) {
                    entry.stampIndex = -1
                    entry.stampIcon = ""
                    entry.color = UIColor.clear
            }
            else {
                    entry.stampIndex = Int16(index)
                    entry.stampIcon = userPreferences.stamps[index].imageName
                    entry.stampName = userPreferences.stamps[index].name

                    entry.color = UIColor(userPreferences.stamps[index].color)
                
                print("SUCCESFULLY UPDATED")
            }

            do {
                try mainContext.save()
                if entry.shouldSyncWithCloudKit {
                    CoreDataManager.shared.saveEntry(entry)
                }

//                coreDataManager.saveEntry(entry)
            } catch {
                print("Failed to save mainContext: \(error)")
            }
            print("ENTRY INDEX: \(entry.stampIndex)")
            print("UPDATED ENTRY ICON: \(entry.stampIcon)")
        }
    }
}
