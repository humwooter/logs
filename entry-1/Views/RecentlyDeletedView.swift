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

    
    var body: some View {
        
        
        List(selection: $selectedEntries) {
            Section(header: Text("Entries are available here for 10 days, after which they will be permanently deleted").textCase(.none)
                .font(.caption)
                .foregroundColor(Color(getTextColor()).opacity(0.5))
                .frame(maxWidth: .infinity)
            ) {}

            
                ForEach(filteredEntries, id: \.self) { entry in
                    Section {
                        EntryDetailView(entry: entry).font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                      
                            .contextMenu {
                                Button {
                                    entry.unRemove(coreDataManager: coreDataManager)
                                } label: {
                                    Label("Recovery entry", systemImage: "arrow.up")
                                }
                                
                                Button("Delete", role: .destructive) {
                                    deleteEntry(entry: entry, coreDataManager: coreDataManager)
                                }
                                
                            }
                  
                    } header: {
                        entryHeaderView(entry: entry)
                    }
                    
                    .listRowBackground(isClear(for: UIColor(userPreferences.entryBackgroundColor)) ? Color("DefaultEntryBackground") : userPreferences.entryBackgroundColor)
                }
  
            
            
        }
        .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive))

        .background {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }
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
                                   .font(.system(size: UIFont.systemFontSize))
                           }

                       }
                   }
            
                   ToolbarItem(placement: .navigationBarTrailing) {
                       Button {
                           isEditing.toggle()
                       } label: {
                           Text(isEditing ? "Done" : "Edit")
                               .font(.system(size: UIFont.systemFontSize))
                       }
                   }
               }
        .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always)).font(.system(size: UIFont.systemFontSize))
        .searchBarTextColor(isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear)

    }
    
//    private func deleteEntries(entries: [Entry]) {
//        for entry in entries {
//            deleteEntry(entry: entry, coreDataManager: coreDataManager)
//        }
//    }
    @ViewBuilder func entryHeaderView(entry: Entry) -> some View {
        HStack {
            Text("\(formattedDateFull(entry.time))").font(.system(size: UIFont.systemFontSize)).foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))).opacity(0.4)
            Spacer()
            if let reminderId = entry.reminderId, !reminderId.isEmpty, reminderExists(with: reminderId) {
                Label("", systemImage: "bell.fill").foregroundColor(userPreferences.reminderColor)
            }
            if (entry.isPinned) {
                Label("", systemImage: "pin.fill").foregroundColor(userPreferences.pinColor)

            }
        }
    }
    
    func getTextColor() -> UIColor { //different implementation since the background will always be default unless userPreferences.entryBackgroundColor != .clear
        
        return UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label))))
    }
    
    func getDefaultEntryBackgroundColor() -> Color {
        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
        
        return Color(color)
    }
}
