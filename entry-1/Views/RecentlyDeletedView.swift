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
    
    var body: some View {
        
        
        List {
            Section(header: Text("Entries are available here for 10 days, after which they will be permanently deleted")
                .font(.caption)
                .foregroundColor(Color(userPreferences.entryBackgroundColor == .clear ? .gray : UIColor(userPreferences.entryBackgroundColor)))
            ) {}
                
                ForEach(filteredEntries, id: \.self) { entry in
                    Section(header: Text("\(formattedDateFull(entry.time))").font(.system(size: UIFont.systemFontSize)).foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.entryBackgroundColor ?? Color.gray))).opacity(0.4)
                    ) {
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
                    }
                    .listRowBackground(userPreferences.entryBackgroundColor == .clear ? getDefaultEntryBackgroundColor() : userPreferences.entryBackgroundColor)
                    
                }
            
            
        }
        .background {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Recently Deleted")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic)).font(.system(size: UIFont.systemFontSize))
        
        
    }
    
    func getDefaultEntryBackgroundColor() -> Color {
        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
        
        return Color(color)
    }
}
