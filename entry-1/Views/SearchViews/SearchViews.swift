//
//  SearchViews.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 12/28/23.
//

import Foundation
import SwiftUI




class SearchModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var tokens: [FilterTokens] = []
}

enum FilterTokens: String, Identifiable, Hashable, CaseIterable {
    case hiddenEntries, stampNameEntries, stampIndexEntries, mediaEntries, searchTextEntries
    var id: Self { self }
}



struct HiddenEntries: View {
    @FetchRequest var hiddenEntries: FetchedResults<Entry>
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.isSearching) var isSearching // 2

    init() {
        self._hiddenEntries = FetchRequest(
            entity: Entry.entity(),
            sortDescriptors: [], // Add sort descriptors if needed
            predicate: NSPredicate(format: "isHidden == true")
        )
    }
    
    var body: some View {
        List(hiddenEntries, id: \.id) { entry in
            EntryDetailView(entry: entry)
        }
    }
}


struct MediaEntries: View {
    @FetchRequest var mediaEntries: FetchedResults<Entry>
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.isSearching) var isSearching // 2

    init() {
        self._mediaEntries = FetchRequest(
            entity: Entry.entity(),
            sortDescriptors: [], // Add any sort descriptors if needed
            predicate: NSPredicate(format: "mediaFilename != nil AND mediaFilename != ''")
        )
    }

    
    var body: some View {
        List(mediaEntries, id: \.id) { entry in
            EntryDetailView(entry: entry)
        }
    }
}



struct FilterByStampIndexEntries: View {
    @State var buttonIndex: Int
    @FetchRequest var entries: FetchedResults<Entry>
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.isSearching) var isSearching // 2

    init(buttonIndex: Int) {
        self._buttonIndex = State(initialValue: buttonIndex)
        self._entries = FetchRequest(
            entity: Entry.entity(),
            sortDescriptors: [], // Add any sort descriptors if needed
            predicate: NSPredicate(format: "stampIndex == %d", buttonIndex)
        )
    }
    
    var body: some View {
        List(entries, id: \.id) { entry in
            EntryDetailView(entry: entry)
        }
    }
}

struct FilterByStampNameEntries: View {
    @State var buttonName: String
    @FetchRequest var entries: FetchedResults<Entry>
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.isSearching) var isSearching // 2

    init(buttonName: String) {
        self._buttonName = State(initialValue: buttonName)
        self._entries = FetchRequest(
            entity: Entry.entity(),
            sortDescriptors: [], // Add any sort descriptors if needed
            predicate: NSPredicate(format: "image == %d", buttonName)
        )
    }
    
    var body: some View {
        List(entries, id: \.id) { entry in
            EntryDetailView(entry: entry)
        }
    }
}

struct FilterBySearchTextEntries: View {
    @State var searchText: String
    @FetchRequest var entries: FetchedResults<Entry>
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.isSearching) var isSearching // 2

    init(searchText: String) {
        self._searchText = State(initialValue: searchText)
        self._entries = FetchRequest(
            entity: Entry.entity(),
            sortDescriptors: [], // Add any sort descriptors if needed
            predicate: NSPredicate(format: "content == %d", searchText)
        )
    }
    
    var body: some View {
        List(entries, id: \.id) { entry in
            EntryDetailView(entry: entry)
        }
    }
}




struct SearchView: View {
    
    // State to control the search bar's active status
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Suggested")) {
                    ForEach(SearchOption.allCases) { option in
                        HStack {
                            Image(systemName: option.systemImageName)
                                .foregroundColor(.yellow)
                            Text(option.displayName)
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Search")
            .toolbar {
                if searchText.isEmpty {
                    Button("Cancel", action: hideKeyboard)
                }
            }
        }
    }
    
    // Function to hide keyboard
    private func hideKeyboard() {
        // Implement keyboard dismissal here
    }
}

// Enum for search options
enum SearchOption: CaseIterable, Identifiable {
    case sharedNotes
    case lockedNotes
    case notesWithChecklists
    case notesWithTags
    case notesWithDrawings
    case notesWithScannedDocuments
    case notesWithAttachments
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .sharedNotes: return "Shared Notes"
        case .lockedNotes: return "Locked Notes"
        case .notesWithChecklists: return "Notes with Checklists"
        case .notesWithTags: return "Notes with Tags"
        case .notesWithDrawings: return "Notes with Drawings"
        case .notesWithScannedDocuments: return "Notes with Scanned Documents"
        case .notesWithAttachments: return "Notes with Attachments"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .sharedNotes: return "person.2.circle"
        case .lockedNotes: return "lock.circle"
        case .notesWithChecklists: return "list.bullet"
        case .notesWithTags: return "tag.circle"
        case .notesWithDrawings: return "scribble.variable"
        case .notesWithScannedDocuments: return "doc.text.magnifyingglass"
        case .notesWithAttachments: return "paperclip.circle"
        }
    }
}
