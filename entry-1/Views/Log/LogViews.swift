
//
//  NewLogViews.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 12/29/23.
//


import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers
import UIKit


let dateFormatter = DateFormatter()



@MainActor
struct LogsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var selectedTimeframe: String = "By Date"
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker: Bool = false
    
    @State private var isExporting = false
    @State private var pdfURL: URL?
    @State private var pdfData: Data?
    
    
    @State private var showingDeleteConfirmation = false
    @State private var logToDelete: Log?
    @State private var logToDeleteDay: String?

    @State private var selectedDates: Set<DateComponents> = []
    @State private var isDatesUpdated = false
    @Binding var replyEntryId: String?

    @Binding var selectedOption: PickerOptions
    @Namespace private var animation //what does this do

    var calendar = Calendar.current
    var timeZone = TimeZone.current

    @EnvironmentObject var datesModel: DatesModel

    
    @State var image: UIImage?
    @State var shareSheetShown = false
    
    @State private var height: CGFloat = 0
    @State var heights: [UUID: CGFloat] = [:]
    @Binding var isShowingReplyCreationView: Bool

    
    @State private var showCalendar = true
    
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
        predicate: NSPredicate(format: "day == %@", formattedDate(Date())),
        animation: nil
    ) var currentLog: FetchedResults<Log>

    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)]
    ) var logs: FetchedResults<Log>

    
    
    // LogsView
    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: []  // Empty array implies no sorting
    ) var allEntries: FetchedResults<Entry>
    
    @Environment(\.isSearching) private var isSearching
    @ObservedObject var searchModel: SearchModel
    @Environment(\.colorScheme) var colorScheme

    @State private var isEditing = false

    @Binding var filteredLogs: [Log]
    let dateStrings = DateStrings()
    
    var entryViewModel: EntryViewModel {
        return EntryViewModel(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId)
    }
    

    var body: some View {
        
        

        NavigationStack {
            VStack {
                mainView()

            }
            .font(.customHeadline)

            
                .fileExporter(isPresented: $isExporting, document: PDFDoc_url(pdfURL: pdfURL), contentType: .pdf) { result in
                    switch result {
                    case .success(let url):
                        print("File successfully saved at \(url)")
                    case .failure(let error):
                        print("Failed to save file: \(error)")
                    }
                }
        }
    }
    
    
    @ViewBuilder
    func horizontalPickerView() -> some View {
        HorizontalPicker(selectedOption: $selectedOption, animation: animation) .padding(.top)
            .environmentObject(userPreferences)
            .frame(maxWidth: .infinity, maxHeight: 40)
    }
    
 
    @ViewBuilder
    func mainView() -> some View {
        VStack(spacing: 0) {
            horizontalPickerView()
            switch selectedOption {
            case .calendar:
                    mainLogsCalendarView()
                    .refreshable {
                        datesModel.addTodayIfNotExists()
                        
                        updateFetchRequests()
            //            updateDateRange()
                    }
            case .folders:
                FoldersView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, searchModel: searchModel)
                    .environmentObject(coreDataManager)
                    .environmentObject(userPreferences)
            case .reminders:
                RemindersView()
                    .environmentObject(userPreferences)
                    .environmentObject(coreDataManager)
            case .search:
                if searchModel.tokens.isEmpty && searchModel.searchText.isEmpty { //present possible tokens
                    suggestedSearchView()
                        .searchable(text: $searchModel.searchText, tokens: $searchModel.tokens) { token in
                                    switch token {
                                    case .isHidden(let value):
                                        Label("Hidden", systemImage: "eye.slash")
                                            .foregroundColor(value ? .primary : .secondary)
                                    case .hasMedia(let value):
                                        Label("Media", systemImage: "paperclip")
                                            .foregroundColor(value ? .primary : .secondary)
                                    case .hasReminder(let value):
                                        Label("Reminder", systemImage: "bell")
                                            .foregroundColor(value ? .primary : .secondary)
                                    case .isPinned(let value):
                                        Label("Pinned", systemImage: "pin")
                                            .foregroundColor(value ? .primary : .secondary)
                                    case .stampIcon(let icon):
                                        if icon.isEmpty {
                                            Label("Stamp Label", systemImage: "hare.fill")
                                        } else {
                                            Label(icon, systemImage: "stamp")
                                        }
                                    case .content(let searchText):
                                        Label(searchText, systemImage: "magnifyingglass")
                                    case .title(let searchText):
                                        Label(searchText, systemImage: "text.magnifyingglass")
                                    case .tag(let tagName):
                                        Label(tagName, systemImage: "tag")
                                    case .date(let date):
                                        Label(dateFormatter.string(from: date), systemImage: "calendar")
                                    case .time(let start, let end):
                                        Label("\(dateFormatter.string(from: start)) - \(dateFormatter.string(from: end))", systemImage: "clock")
                                    case .lastUpdated(let start, let end):
                                        Label("Updated: \(dateFormatter.string(from: start)) - \(dateFormatter.string(from: end))", systemImage: "clock.arrow.circlepath")
                                    case .color(let color):
                                        Label("Color", systemImage: "circle.fill")
                                            .foregroundColor(Color(color))
                                    case .tagNames(let tags):
                                        Label(tags.joined(separator: ", "), systemImage: "tag")
                                    case .isShown(let value):
                                        Label("Shown", systemImage: "eye")
                                            .foregroundColor(value ? .primary : .secondary)
                                    case .isRemoved(let value):
                                        Label("Removed", systemImage: "trash")
                                            .foregroundColor(value ? .primary : .secondary)
                                    case .isDrafted(let value):
                                        Label("Draft", systemImage: "doc.text")
                                            .foregroundColor(value ? .primary : .secondary)
                                    case .shouldSyncWithCloudKit(let value):
                                        Label("Sync", systemImage: "icloud")
                                            .foregroundColor(value ? .primary : .secondary)
                                    case .folderId(let id):
                                        Label("Folder: \(id)", systemImage: "folder")
                                    }
                                }
                }
                else {
                    filteredEntriesListView()
                }
            case .schedule:
                ScheduleView()
                    .environmentObject(coreDataManager)
                    .environmentObject(userPreferences)
            }

        }
        .background {
            userPreferences.backgroundView(colorScheme: colorScheme)
        }
        .scrollContentBackground(.hidden)

        .sheet(isPresented: $shareSheetShown) {
            if let log_uiimage = image {
                let logImage = Image(
                    uiImage: log_uiimage)
                ShareLink(item: logImage, preview: SharePreview("", image: logImage))
            }
        }
        .listStyle(.insetGrouped)
        
        .navigationTitle("Logs")
        .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
    }
    
    @ViewBuilder
       func mainLogsCalendarView() -> some View {
           List {
               calendarView()
               logsListView()
                   .onTapGesture {
                       print("DATES: \(datesModel.dates)")
                   }
                   .alert(isPresented: $showingDeleteConfirmation) {
                       Alert(title: Text("Delete log"),
                             message: Text("Are you sure you want to delete this log? This action cannot be undone."),
                             primaryButton: .destructive(Text("Delete")) {
                           deleteLog(logDay: logToDeleteDay)
                       },
                             secondaryButton: .cancel())
                   }
               
               NavigationLink(destination: RecentlyDeletedView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId).environmentObject(coreDataManager).environmentObject(userPreferences)) {
                   HStack {
                       Text("Recently Deleted").foregroundStyle(getTextColor())
                       Spacer()
                       Image(systemName: "trash").foregroundStyle(.red)
                   }
               }
               .scrollContentBackground(.hidden)
               .listRowBackground(getSectionColor(colorScheme: colorScheme))
           }
           

       }
    
    @ViewBuilder
        func filteredEntriesListView() -> some View {
            FilteredEntriesListView(searchModel: searchModel, entryFilter: EntryFilter(searchText: $searchModel.searchText, filters: $searchModel.tokens), isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId)
                .environmentObject(userPreferences)
                .environmentObject(coreDataManager)
                .scrollContentBackground(.hidden)
                .listRowBackground(getSectionColor(colorScheme: colorScheme))
        }
    
//    @ViewBuilder
//      func filteredEntriesListView() -> some View {
//          let entries = filteredEntries(entries: Array(allEntries), searchText: searchModel.searchText, tags: searchModel.tokens)
//              .sorted { $0.time ?? Date() > $1.time ?? Date() }
//          
//          
//          ScrollView {
//              LazyVStack(spacing: 10) {
//                  ForEach(Array(entries.enumerated()), id: \.element) { index, entry in
//                      if index < currentLoadedCount {
//                          VStack(spacing: 5) {
//                              entryHeaderView(entry: entry).foregroundStyle(getIdealHeaderTextColor())
//                                                          .padding(.horizontal)
//                                                          .padding(.top, 10)
//                                                      
//                              Section {
//                                  EntryDetailView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, entry: entry, showContextMenu: true)
//                                      .environmentObject(userPreferences)
//                                      .environmentObject(coreDataManager)
//                                      .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
//                                      .lineSpacing(userPreferences.lineSpacing)
//                              }
//                              
//                              .background(getSectionColor(colorScheme: colorScheme))
//                              .cornerRadius(10)
//
//                        }
//                
//                      }
//                  }
//                  .onAppear {
//                      currentLoadedCount = min(initialLoadCount, entries.count)
//                  }
//                  
//                  
//                  if currentLoadedCount < entries.count {
//                      ProgressView()
//                          .onAppear {
//                              loadMoreContent(totalCount: entries.count)
//                          }
//                  }
//              }
//              .padding(.horizontal)
//     
//          }
//      }
//      
//      @State private var currentLoadedCount = 0
//      private let initialLoadCount = 5
//      private let additionalLoadCount = 5
//      
//      private func loadMoreContent(totalCount: Int) {
//          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//              currentLoadedCount = min(currentLoadedCount + additionalLoadCount, totalCount)
//          }
//      }
//    


    
    @ViewBuilder func entryHeaderView(entry: Entry) -> some View {
        HStack {
            Text("\(formattedDateFull(entry.time))")
                .font(.customHeadline)
                .foregroundStyle(getIdealHeaderTextColor().opacity(0.5))
//                .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))).opacity(0.4)
            
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
    
    @ViewBuilder
        func suggestedSearchView() -> some View {
            List {
                Section(header: Text("Suggested").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.5)) {
                    Button {
                        searchModel.tokens.append(.isHidden(true))
                    } label: {
                        HStack {
                            Image(systemName: "eye.fill")
                                .foregroundStyle(userPreferences.accentColor)
                                .padding(.horizontal, 5)
                            Text("Hidden Entries")
                                .foregroundStyle(getTextColor())
                        }
                    }
                    
                    Button {
                        searchModel.tokens.append(.hasMedia(true))
                    } label: {
                        HStack {
                            Image(systemName: "paperclip")
                                .foregroundStyle(userPreferences.accentColor)
                                .padding(.horizontal, 5)
                            
                            Text("Entries with Media")
                                .foregroundStyle(getTextColor())
                        }
                    }
                    
                    Button {
                        searchModel.tokens.append(.hasReminder(true))
                    } label: {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(userPreferences.accentColor)
                                .padding(.horizontal, 5)
                            
                            Text("Entries with Reminder")
                                .foregroundStyle(getTextColor())
                        }
                    }
                    
                    Button {
                        searchModel.tokens.append(.isPinned(true))
                    } label: {
                        HStack {
                            Image(systemName: "pin.fill")
                                .foregroundStyle(userPreferences.accentColor)
                                .padding(.horizontal, 5)
                            
                            Text("Pinned Entries")
                                .foregroundStyle(getTextColor())
                        }
                    }
                    
                    Button {
                        searchModel.tokens.append(.stampIcon(searchModel.searchText))
                    } label: {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .foregroundStyle(userPreferences.accentColor)
                                .padding(.horizontal, 5)
                            
                            Text("Stamp Icon Label")
                                .foregroundStyle(getTextColor())
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(getSectionColor(colorScheme: colorScheme))
            }
            .refreshable {
                datesModel.addTodayIfNotExists()
                updateFetchRequests()
            }

            .listStyle(.insetGrouped)
            .navigationTitle("Logs")
            .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
        }
//    @ViewBuilder
//    func suggestedSearchView() -> some View {
//        List {
//            Section(header: Text("Suggested").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.5)) {
//                Button {
//                    searchModel.tokens.append(.hiddenEntries)
//                } label: {
//                    HStack {
//                        Image(systemName: "eye.fill")
//                            .foregroundStyle(userPreferences.accentColor)
//                            .padding(.horizontal, 5)
//                        Text("Hidden Entries")
//                            .foregroundStyle(getTextColor())
//                    }
//                }
//                
//                Button {
//                    searchModel.tokens.append(.mediaEntries)
//                } label: {
//                    HStack {
//                        Image(systemName: "paperclip")
//                            .foregroundStyle(userPreferences.accentColor)
//                            .padding(.horizontal, 5)
//                        
//                        Text("Entries with Media")
//                            .foregroundStyle(getTextColor())
//                    }
//                }
//                
//                Button {
//                    searchModel.tokens.append(.reminderEntries)
//                } label: {
//                    HStack {
//                        Image(systemName: "bell.fill")
//                            .foregroundStyle(userPreferences.accentColor)
//                            .padding(.horizontal, 5)
//                        
//                        Text("Entries with Reminder")
//                            .foregroundStyle(getTextColor())
//                    }
//                }
//                
//                Button {
//                    searchModel.tokens.append(.pinnedEntries)
//                } label: {
//                    HStack {
//                        Image(systemName: "pin.fill")
//                            .foregroundStyle(userPreferences.accentColor)
//                            .padding(.horizontal, 5)
//                        
//                        Text("Pinned Entries")
//                            .foregroundStyle(getTextColor())
//                    }
//                }
//                
//                
//                Button {
//                    searchModel.tokens.append(.stampNameEntries)
//                } label: {
//                    HStack {
//                        Image(systemName: "star.circle.fill")
//                            .foregroundStyle(userPreferences.accentColor)
//                            .padding(.horizontal, 5)
//                        
//                        Text("Stamp Icon Label")
//                            .foregroundStyle(getTextColor())
//                    }
//                }
//            }
//            .scrollContentBackground(.hidden)
//            .listRowBackground(getSectionColor(colorScheme: colorScheme))
//        }
//        .refreshable {
//            datesModel.addTodayIfNotExists()
//            updateFetchRequests()
//        }
//        .sheet(isPresented: $shareSheetShown) {
//            if let log_uiimage = image {
//                let logImage = Image(
//                    uiImage: log_uiimage)
//                ShareLink(item: logImage, preview: SharePreview("", image: logImage))
//            }
//        }
//        .listStyle(.insetGrouped)
//        
//        .navigationTitle("Logs")
//        .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
//    }
    
    
    @ViewBuilder
    func calendarView() -> some View {
        Section {
            if showCalendar {
                if userPreferences.calendarPreference == "Weekly" {
                                    ScrollableWeeklyCalendarView(datesModel: datesModel, selectionColor: userPreferences.accentColor, backgroundColor: Color(UIColor.fontColor(forBackgroundColor: UIColor(entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)))).opacity(0.05))
                        .environmentObject(userPreferences)
                        .padding()
                } else {
                    CalendarView(datesModel: datesModel, selectionColor: userPreferences.accentColor, backgroundColor: Color(UIColor.fontColor(forBackgroundColor: UIColor(entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)))).opacity(0.05))
                        .environmentObject(userPreferences)
                        .padding()
                }             
                
            }
            
        } header: {
            HStack {
                Text("Calendar").foregroundStyle(getIdealHeaderTextColor()).opacity(0.4)
                
                Spacer()
                Label("", systemImage: showCalendar ? "chevron.up" : "chevron.down").foregroundStyle(userPreferences.accentColor)
                    .contentTransition(.symbolEffect(.replace.offUp))
            }
            .onTapGesture {
                showCalendar.toggle()
            }

        }
        .listRowBackground(getSectionColor(colorScheme: colorScheme))
        .onAppear {
                    datesModel.addTodayIfNotExists()
//            datesModel[formattedDate(Date())] = true
                }
    }
    
    func getTextColor() -> Color {
        // Retrieve the background colors from user preferences
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        let entryBackground = userPreferences.entryBackgroundColor
        
        // Call the calculateTextColor function with these values
        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme
        )
    }
    
    func formattedDate_logs(dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM/dd/yyyy" // Adjust this if your dateString format is different
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM d, yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return dateString // Return original string if parsing fails
        }
    }
    
    func entryCount(for dateString: String) -> Int {
        // Convert dateString to a Date object
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM/dd/yyyy" // Adjust this if your dateString format is different
        
        guard let logDate = inputFormatter.date(from: dateString) else {
            print("Invalid dateString: \(dateString)")
            return 0
        }
        
        // Define the start and end of the day
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: logDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return 0
        }
        
        // Set up the fetch request with a predicate that matches entries for the specific logDay
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isRemoved == NO AND time >= %@ AND time < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            let entries = try coreDataManager.viewContext.fetch(fetchRequest)
            return entries.count
        } catch {
            print("Failed to fetch entries: \(error)")
            return 0
        }
    }




    
    @ViewBuilder
    func singleLogPreviewView(dateString: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.buttonSize)

                .foregroundStyle(userPreferences.accentColor)
            
            Text(formattedDate_logs(dateString: dateString))
                .font(.customHeadline)
                .foregroundStyle(getTextColor())
            
            Spacer()
            HStack {
                Text("\(entryCount(for: dateString))")
                    .foregroundStyle(userPreferences.accentColor.opacity(0.5))
//                Image(systemName: "chevron.right")
//                    .foregroundStyle(getTextColor().opacity(0.5))
            }
        }

    }

    
    @ViewBuilder
      func logsListView() -> some View {
          ForEach(Array(datesModel.dates.filter{$0.value.isSelected}.keys.sorted(by: >)), id: \.self) { dateString in
              if let logDate = datesModel.dates[dateString], DateStrings.isValidDateFormat(dateString) {
                  ScrollView {
                      LazyVStack {
                          NavigationLink(destination: LogDetailView(logDay: dateString, isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId)
                              .environmentObject(userPreferences)) {
                                  singleLogPreviewView(dateString: dateString)
                              }
                              .padding(.top, 10)
                              .contextMenu {
                                  Button(role: .destructive, action: {
                                      showingDeleteConfirmation = true
                                      logToDeleteDay = dateString
                                  }) {
                                      Label("Delete", systemImage: "trash")
                                          .foregroundColor(.red)
                                  }
                              }
                      }
                  }
              }
            
          }
     
          .scrollContentBackground(.hidden)
          .listRowBackground(getSectionColor(colorScheme: colorScheme))
      }

    func getSectionColor(colorScheme: ColorScheme) -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        } else {
            return userPreferences.entryBackgroundColor
        }
    }
    
    func getIdealHeaderTextColor() -> Color {
        return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(userPreferences.backgroundColors.first ?? Color.clear), and: UIColor(userPreferences.backgroundColors[1])), colorScheme: colorScheme))
    }
    
    

    func DatePickerView(date: Binding<Date>, title: String) -> some View {
        List {
            DatePicker("Start Date", selection: date, displayedComponents: .date)
        }
        .navigationTitle(title)
    }
    
//    
//    func filteredEntries(entries: [Entry], searchText: String, tags: [FilterTokens]) -> [Entry] {
//        guard !searchText.isEmpty || !tags.isEmpty else { return entries }
//
//        return entries.filter { entry in
//            let matchesSearchText = searchText.isEmpty || entry.content.lowercased().contains(searchText.lowercased())
//
//            let matchesTags: Bool
//            if tags.isEmpty {
//                matchesTags = true // If no tags, consider it a match.
//            } else {
//                matchesTags = tags.contains { tag in
//                    switch tag {
//                    case .hiddenEntries:
//                        return entry.isHidden
//                    case .stampNameEntries:
//                        return entry.stampIcon.lowercased().contains(searchText.lowercased())
//                    case .stampIndexEntries:
//                        if let index = Int(searchText) {
//                            return entry.stampIndex == index
//                        }
//                        return false
//                    case .mediaEntries:
//                        if let filename = entry.mediaFilename, !filename.isEmpty {
//                            return imageExists(at: filename)
//                        }
//                        return false
//                    case .searchTextEntries:
//                        return entry.content.lowercased().contains(searchText.lowercased())
//                    case .reminderEntries:
//                        if let reminderId = entry.reminderId {
//                            return !reminderId.isEmpty
//                        } else {
//                            return false
//                        }
//                    case .pinnedEntries:
//                        return entry.isPinned
//                    }
//                }
//            }
//
//            
//            if tags.first == .mediaEntries || tags.first == .hiddenEntries || tags.first == .pinnedEntries { //to consider both tag and search text
//                return matchesTags && matchesSearchText
//            }
//            if tags.isEmpty {
//                return matchesSearchText
//            }
//            else {
//                return matchesTags
//            }
//        }
//    }


    
    func entryHasImage(at filename: String?) -> Bool {
        if let name = filename {
            if !name.isEmpty {
                if imageExists(at: name) {
                    return true
                }
            }
        }
        return false
    }
    
    
    func updateFetchRequests() {
        
        dateFormatter.dateFormat = "MM/dd/yyyy"

        let currentDay = formattedDate(Date())
        currentLog.nsPredicate = NSPredicate(format: "day == %@", currentDay)
        
        
        if currentLog.isEmpty {
            let newLog = Log(context: coreDataManager.viewContext)
            newLog.day = currentDay
            newLog.id = UUID()
        }
    }
    
    
    func fetchEntriesByDate(logDay: String) -> [Entry] {
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()

        // Convert log.day into DateComponents
        guard let logDate = dateFromString(logDay),
              let logComponents = dateComponents(from: logDay) else {
            print("Invalid log.day format")
            return []
        }

        // Create a predicate that compares the date components of entry.time with log.day
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: logDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Predicate to check if entry.time falls within the same day as log.day and isRemoved is false
        request.predicate = NSPredicate(format: "isRemoved == NO AND time >= %@ AND time < %@", startOfDay as NSDate, endOfDay as NSDate)

        // Sort entries by time in descending order
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Entry.time, ascending: false)]

        do {
            return try coreDataManager.viewContext.fetch(request)
        } catch {
            print("Error fetching entries: \(error)")
            return []
        }
    }

    
    private func deleteLog(logDay: String?) {
        guard let logDay = logDay else { return }
        dateStrings.removeDate(logDay)

        for entry in fetchEntriesByDate(logDay: logDay) {
            entry.isRemoved = true //moving to recently deleted instead of permanently deleting all entries
            do {
                try coreDataManager.viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct LogParentView : View {
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var datesModel: DatesModel

    @StateObject private var searchModel = SearchModel()
    @FocusState private var isSearchFieldFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    @Binding var isShowingReplyCreationView: Bool
    @Binding var replyEntryId: String?
//    @FetchRequest(
//        entity: Log.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: false)]
//    ) var logs: FetchedResults<Log>
    
    @State private var filteredLogs: [Log] = []

    @State private var selectedOption: PickerOptions = .calendar
    var showSearch: Binding<Bool> {
          Binding<Bool>(
              get: { self.selectedOption == .search },
              set: { newValue in
                  if newValue {
                      self.selectedOption = .search
                  } else {
                      self.selectedOption = .calendar
                  }
              }
          )
      }

    var body: some View {
        
        LogsView(replyEntryId: $replyEntryId, selectedOption: $selectedOption, isShowingReplyCreationView: $isShowingReplyCreationView, searchModel: searchModel, filteredLogs: $filteredLogs)
            .environmentObject(datesModel)
            .environmentObject(userPreferences)
            .environmentObject(coreDataManager)
//            .searchable(text: $searchModel.searchText, tokens: $searchModel.tokens, isPresented: showSearch) { token in
//                        switch token {
//                        case .isHidden(let value):
//                            Label("Hidden", systemImage: "eye.slash")
//                                .foregroundColor(value ? .primary : .secondary)
//                        case .hasMedia(let value):
//                            Label("Media", systemImage: "paperclip")
//                                .foregroundColor(value ? .primary : .secondary)
//                        case .hasReminder(let value):
//                            Label("Reminder", systemImage: "bell")
//                                .foregroundColor(value ? .primary : .secondary)
//                        case .isPinned(let value):
//                            Label("Pinned", systemImage: "pin")
//                                .foregroundColor(value ? .primary : .secondary)
//                        case .stampIcon(let icon):
//                            if icon.isEmpty {
//                                Label("Stamp Label", systemImage: "hare.fill")
//                            } else {
//                                Label(icon, systemImage: "stamp")
//                            }
//                        case .content(let searchText):
//                            Label(searchText, systemImage: "magnifyingglass")
//                        case .title(let searchText):
//                            Label(searchText, systemImage: "text.magnifyingglass")
//                        case .tag(let tagName):
//                            Label(tagName, systemImage: "tag")
//                        case .date(let date):
//                            Label(dateFormatter.string(from: date), systemImage: "calendar")
//                        case .time(let start, let end):
//                            Label("\(dateFormatter.string(from: start)) - \(dateFormatter.string(from: end))", systemImage: "clock")
//                        case .lastUpdated(let start, let end):
//                            Label("Updated: \(dateFormatter.string(from: start)) - \(dateFormatter.string(from: end))", systemImage: "clock.arrow.circlepath")
//                        case .color(let color):
//                            Label("Color", systemImage: "circle.fill")
//                                .foregroundColor(Color(color))
//                        case .tagNames(let tags):
//                            Label(tags.joined(separator: ", "), systemImage: "tag")
//                        case .isShown(let value):
//                            Label("Shown", systemImage: "eye")
//                                .foregroundColor(value ? .primary : .secondary)
//                        case .isRemoved(let value):
//                            Label("Removed", systemImage: "trash")
//                                .foregroundColor(value ? .primary : .secondary)
//                        case .isDrafted(let value):
//                            Label("Draft", systemImage: "doc.text")
//                                .foregroundColor(value ? .primary : .secondary)
//                        case .shouldSyncWithCloudKit(let value):
//                            Label("Sync", systemImage: "icloud")
//                                .foregroundColor(value ? .primary : .secondary)
//                        case .folderId(let id):
//                            Label("Folder: \(id)", systemImage: "folder")
//                        }
//                    }
//            .searchable(text: $searchModel.searchText, tokens: $searchModel.tokens, isPresented: showSearch) { token in
//                        switch token {
//                        case .hiddenEntries:
//                            Text("Hidden")
//                        case .mediaEntries:
//                            Text("Media")
//                        case .stampIndexEntries:
//                            Text("Index")
//                        case .stampNameEntries:
//                            Text("Name")
//                        case .searchTextEntries:
//                            Text(searchModel.searchText)
//                        case .reminderEntries:
//                            Text("Reminder")
//                        case .pinnedEntries:
//                            Text("Pinned")
//                        }
//                  
//                
//                
//            }
            .searchBarTextColor(isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear)
            .font(.customHeadline)
            .focused($isSearchFieldFocused)
    }
}


@MainActor
struct SuggestedSearchView: View, UserPreferencesProvider {
    @EnvironmentObject var userPreferences: UserPreferences
    @ObservedObject var searchModel: SearchModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        List {
            Section(header: Text("Suggested").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.5)) {
                Button {
                    searchModel.tokens.append(.isHidden(true))
                } label: {
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundStyle(userPreferences.accentColor)
                            .padding(.horizontal, 5)
                        Text("Hidden Entries")
                            .foregroundStyle(getTextColor())
                    }
                }
                
                Button {
                    searchModel.tokens.append(.hasMedia(true))
                } label: {
                    HStack {
                        Image(systemName: "paperclip")
                            .foregroundStyle(userPreferences.accentColor)
                            .padding(.horizontal, 5)
                        
                        Text("Entries with Media")
                            .foregroundStyle(getTextColor())
                    }
                }
                
                Button {
                    searchModel.tokens.append(.hasReminder(true))
                } label: {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(userPreferences.accentColor)
                            .padding(.horizontal, 5)
                        
                        Text("Entries with Reminder")
                            .foregroundStyle(getTextColor())
                    }
                }
                
                Button {
                    searchModel.tokens.append(.isPinned(true))
                } label: {
                    HStack {
                        Image(systemName: "pin.fill")
                            .foregroundStyle(userPreferences.accentColor)
                            .padding(.horizontal, 5)
                        
                        Text("Pinned Entries")
                            .foregroundStyle(getTextColor())
                    }
                }
                
                Button {
                    searchModel.tokens.append(.stampIcon(searchModel.searchText))
                } label: {
                    HStack {
                        Image(systemName: "star.circle.fill")
                            .foregroundStyle(userPreferences.accentColor)
                            .padding(.horizontal, 5)
                        
                        Text("Stamp Icon Label")
                            .foregroundStyle(getTextColor())
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listRowBackground(getSectionColor(colorScheme: colorScheme))
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Logs")
        .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
    }
}

