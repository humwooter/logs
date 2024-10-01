//
//  FilteredEntriesListView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 9/2/24.
//

import SwiftUI

struct FilteredEntriesListView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @ObservedObject var searchModel: SearchModel
    
    @State private var currentLoadedCount = 0
    private let initialLoadCount = 5
    private let additionalLoadCount = 5
    
    @State private var isShowingReplyCreationView = false
    @State private var replyEntryId: String?
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var entryFilter: EntryFilter
//    @State private var entries: [Entry] = []
    
//    init(searchModel: SearchModel) {
//        self.searchModel = searchModel
//        self.entryFilter = EntryFilter(searchText: $searchModel.searchText, filters: $searchModel.tokens)
//    }
    
    var body: some View {
        ScrollView {
            mainView()
//                .onAppear {
//                    entries = fetchFilteredEntries()
//                }
//                .onChange(of: entryFilter.searchText) { oldValue, newValue in
//                    entries = fetchFilteredEntries()
//                }
            
        }
    }
    
    @ViewBuilder
    func mainView() -> some View {
        let entries = fetchFilteredEntries()
        LazyVStack(spacing: 10) {
            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                if index < currentLoadedCount {
                    VStack(spacing: 5) {
                        entryHeaderView(entry: entry)
                            .foregroundStyle(getIdealHeaderTextColor())
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        Section {
                            EntryDetailView(isShowingReplyCreationView: $isShowingReplyCreationView,
                                            replyEntryId: $replyEntryId,
                                            entry: entry,
                                            showContextMenu: true)
                                .environmentObject(userPreferences)
                                .environmentObject(coreDataManager)
                                .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                                .lineSpacing(userPreferences.lineSpacing)
                        }
                        .background(getSectionColor(colorScheme: colorScheme))
                        .cornerRadius(10)
                    }
                }
            }
            .onAppear {
                currentLoadedCount = min(initialLoadCount, entries.count)
            }
            
            if currentLoadedCount < entries.count {
                ProgressView()
                    .onAppear {
                        loadMoreContent(totalCount: entries.count)
                    }
            }
        }
        .padding(.horizontal)
    }
    
    private func fetchFilteredEntries() -> [Entry] {
        return entryFilter.fetchEntries(in: coreDataManager.viewContext, limit: currentLoadedCount + additionalLoadCount)
    }
    
    private func loadMoreContent(totalCount: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            currentLoadedCount = min(currentLoadedCount + additionalLoadCount, totalCount)
        }
    }
    
    @ViewBuilder func entryHeaderView(entry: Entry) -> some View {
        HStack {
            Text("\(formattedDateFull(entry.time))")
                .font(.customHeadline)
                .foregroundStyle(getIdealHeaderTextColor().opacity(0.5))
            
            Spacer()
            if let reminderId = entry.reminderId, !reminderId.isEmpty, reminderExists(with: reminderId) {
                Label("", systemImage: "bell.fill").foregroundColor(userPreferences.reminderColor)
            }
            if (entry.isPinned) {
                Label("", systemImage: "pin.fill").foregroundColor(userPreferences.pinColor)

            }
        }
        .font(.sectionHeaderSize)
    }
    
    func getIdealHeaderTextColor() -> Color {
        return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(userPreferences.backgroundColors.first ?? Color.clear), and: UIColor(userPreferences.backgroundColors[1])), colorScheme: colorScheme))
    }
    
    
    func getSectionColor(colorScheme: ColorScheme) -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        } else {
            return userPreferences.entryBackgroundColor
        }
    }
}
