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
            ForEach(filteredEntries, id: \.self) { entry in
                Section(header: Text("\(formattedDateFull(entry.time))").font(.system(size: UIFont.systemFontSize)).foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                ) {
                    EntryDetailView(entry: entry)
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
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
//        .font(.system(size: UIFont.systemFontSize))
        .navigationTitle("Recently Deleted")
    }
}
