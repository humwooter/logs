//
//  FilteredEntriesListView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 9/2/24.
//

import SwiftUI

struct FilteredEntriesListView: View { //for general main search
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @ObservedObject var searchModel: SearchModel
    
    @State private var currentLoadedCount = 0
    private let initialLoadCount = 5
    private let additionalLoadCount = 5
    

    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var entryFilter: EntryFilter
    
    @Binding var isShowingReplyCreationView: Bool
    @Binding var replyEntryId: String?
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
                                            showContextMenu: true, filterOption: nil)
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


struct FilteredEntriesView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var searchModel: SearchModel
    var entryFilter: EntryFilter
    
    @State private var filterOption: EntryDateFilters = .day
    @State private var filteredEntries: [Entry] = []
    @State private var currentLoadedCount: Int = 0
    private let additionalLoadCount: Int = 20
    
    @Binding var isShowingReplyCreationView: Bool
    @Binding var replyEntryId: String?
    
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        ScrollView {
            mainView()
        }
        .onAppear {
            filteredEntries = fetchFilteredEntries()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("Filter", selection: $filterOption) {
                        ForEach(EntryDateFilters.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option as EntryDateFilters?)
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
    
    @ViewBuilder
    private func mainView() -> some View {
        groupedEntriesView(filterOption: filterOption)
    }
    
    
    private func fetchFilteredEntries() -> [Entry] {
        return entryFilter.fetchEntries(in: coreDataManager.viewContext, limit: currentLoadedCount + additionalLoadCount)
    }
    
    private func loadMoreContent(totalCount: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            currentLoadedCount = min(currentLoadedCount + additionalLoadCount, totalCount)
        }
    }
    
    

    
    private func sectionHeader(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        switch filterOption {
        case .day:
            dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        case .week:
            dateFormatter.dateFormat = "'Week of' MMM d, yyyy"
        case .month:
            dateFormatter.dateFormat = "MMMM yyyy"
        }
        return dateFormatter.string(from: date)
    }
    
    @ViewBuilder
    private func groupedEntriesView(filterOption: EntryDateFilters) -> some View {
        let groupedEntries = Dictionary(grouping: filteredEntries, by: { entry in
            switch filterOption {
            case .day:
                return Calendar.current.startOfDay(for: entry.time)
            case .week:
                return Calendar.current.dateInterval(of: .weekOfYear, for: entry.time)?.start ?? Date()
            case .month:
                return Calendar.current.dateInterval(of: .month, for: entry.time)?.start ?? Date()
            }
        })
        
        LazyVStack(spacing: 10) {
            ForEach(groupedEntries.keys.sorted(by: >), id: \.self) { group in
                VStack(alignment: .leading, spacing: 5) {
                    Text(sectionHeader(for: group))
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .foregroundStyle(getIdealHeaderTextColor().opacity(0.7))
                    
                    ForEach(groupedEntries[group] ?? [], id: \.self) { entry in
                        EntryDetailView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, entry: entry, showContextMenu: true, filterOption: filterOption)
                            .environmentObject(coreDataManager)
                            .environmentObject(userPreferences)
                            .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                            .lineSpacing(userPreferences.lineSpacing)
                            .background(getSectionColor(colorScheme: colorScheme))
                            .cornerRadius(10)
                            .padding(.vertical, 4)
                    }
                }
            }
            if currentLoadedCount < filteredEntries.count {
                ProgressView()
                    .onAppear {
                        loadMoreContent(totalCount: filteredEntries.count)
                    }
            }
        }
        .padding(.horizontal)
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
