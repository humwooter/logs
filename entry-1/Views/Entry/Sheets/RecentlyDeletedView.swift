//
//  RecentlyDeletedView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/27/23.
//

import Foundation
import SwiftUI
import CoreData



struct RecentlyDeletedView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    @State private var showingPopover = false
    @State private var isEditing = false
    @Binding var isShowingReplyCreationView: Bool

    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: true)],
        predicate: NSPredicate(format: "isRemoved == %@", NSNumber(value: true))
    ) var removedEntries: FetchedResults<Entry>
    
    var filteredEntries: [Entry] {
        if searchText.isEmpty {
            return Array(removedEntries)
        } else {
            return removedEntries.filter { $0.content.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    @State private var selectedEntries = Set<Entry>()
    @Binding var replyEntryId: String?
    @State var reminderManager: ReminderManager

    let dateStrings = DateStrings()

    
    var body: some View {
        
        
        List(selection: $selectedEntries) {
            Section(header: Text("Entries are available here for 10 days, after which they will be permanently deleted").textCase(.none)
                .font(.customCaption)
                .foregroundColor(Color(getTextColor()).opacity(0.5))
                .frame(maxWidth: .infinity)
            ) {}

            
                ForEach(filteredEntries, id: \.self) { entry in
                    Section {
                        EntryDetailView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, entry: entry)
                            .contextMenu {
                                Button {
                                    entry.unRemove(coreDataManager: coreDataManager)
                                    dateStrings.addDate(formattedDate(entry.time))
                                } label: {
                                    Label("Recovery entry", systemImage: "arrow.up")
                                }
                                
                                Button("Delete", role: .destructive) {
                                    deleteEntry(entry: entry, coreDataManager: coreDataManager)
                                }
                                
                            }
                  
                    } header: {
                        entryHeaderView(entry: entry).foregroundStyle(getIdealHeaderTextColor())
                    }
                    
                    .listRowBackground(isClear(for: UIColor(userPreferences.entryBackgroundColor)) ? Color("DefaultEntryBackground") : userPreferences.entryBackgroundColor)
                }
  
            
            
        }
        .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive))

        .background {
            userPreferences.backgroundView(colorScheme: colorScheme)
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Recently Deleted")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                       if isEditing {
                           Button {
                               if selectedEntries.isEmpty {
                                   for entry in filteredEntries {
                                       deleteEntry(entry: entry, coreDataManager: coreDataManager)
                                   }                               } else {
                                       for entry in selectedEntries {
                                           deleteEntry(entry: entry, coreDataManager: coreDataManager)
                                       }
                                   }
                           } label: {
                               Text("Delete \(selectedEntries.count > 0 ? "" : "All")")
                                   .font(.customHeadline)
                           }

                       }
                   }
            
                   ToolbarItem(placement: .navigationBarTrailing) {
                       Button {
                           isEditing.toggle()
                       } label: {
                           Text(isEditing ? "Done" : "Edit")
                               .font(.customHeadline)
                       }
                   }
               }
        .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .font(.customHeadline)
        .searchBarTextColor(isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear)

    }

    @ViewBuilder func entryHeaderView(entry: Entry) -> some View {
        HStack {
            Text("\(formattedDateFull(entry.time ?? Date()))")
                .font(.customHeadline)
                .foregroundStyle(getIdealHeaderTextColor()).opacity(0.4)
            Spacer()
            if let reminderId = entry.reminderId, !reminderId.isEmpty, reminderManager.reminderExists(with: reminderId) {
                Label("", systemImage: "bell.fill").foregroundColor(userPreferences.reminderColor)
            }
            if (entry.isPinned) {
                Label("", systemImage: "pin.fill").foregroundColor(userPreferences.pinColor)

            }
        }
    }
    
    func getTextColor() -> Color {
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        let entryBackground = userPreferences.entryBackgroundColor
        
        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme
        )
    }

    func getIdealHeaderTextColor() -> Color {
        return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(userPreferences.backgroundColors.first ?? Color.clear), and: UIColor(userPreferences.backgroundColors[1])), colorScheme: colorScheme))
    }
}
