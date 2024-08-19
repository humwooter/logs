
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


struct HeightGetterModifier: ViewModifier {
    var onHeightCalculated: (CGFloat) -> Void

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .onAppear {
                    onHeightCalculated(geometry.size.height)
                }
        }
    }
}

extension View {
    func getHeight(onHeightCalculated: @escaping (CGFloat) -> Void) -> some View {
        self.modifier(HeightGetterModifier(onHeightCalculated: onHeightCalculated))
    }
}

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

struct GetHeightModifier: ViewModifier {
    @Binding var height: CGFloat

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo -> Color in
                DispatchQueue.main.async {
                    height = geo.size.height
                }
                return Color.clear
            }
        )
    }
}





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

    
    @Binding var filteredLogs: [Log]

    var body: some View {
        
        

        NavigationStack {
            VStack {
                mainView()

            }
            .font(.system(size: UIFont.systemFontSize))

            
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
    
    
//    private func updateFilteredLogs() {
//        print("entered filtered logs")
//            filteredLogs = logs.filter { log in
//                datesModel.dates[log.day]?.isSelected == true
//            }
//        print("FILTERED LOGS: \(filteredLogs)")
//        }
    
    @ViewBuilder
    func horizontalPickerView() -> some View {
        HorizontalPicker(selectedOption: $selectedOption, animation: animation) .padding(.top).padding(.leading)
            .environmentObject(userPreferences)
            .frame(maxWidth: .infinity, maxHeight: 40)
    }
    
 
    @ViewBuilder
    func mainView() -> some View {
        VStack(spacing: 0) {
            horizontalPickerView()

            if !isSearching {

                mainLogsCalendarView()
            }
            else { //if the user is actively searching
                if searchModel.tokens.isEmpty && searchModel.searchText.isEmpty { //present possible tokens
                    suggestedSearchView()
                }
                else {
                    filteredEntriesListView()
                }
            }
        }
        .background {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()
        }
        .scrollContentBackground(.hidden)
        .refreshable {
            datesModel.addTodayIfNotExists()
            
            updateFetchRequests()
//            updateDateRange()
        }
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
//        .onReceive(datesModel.$dates) { _ in
//                   updateFilteredLogs()
//               }
//               .onReceive(logs.publisher) { _ in
//                   updateFilteredLogs()
//               }
//               .onChange(of: datesModel.dates) { oldValue, newValue in
//                   updateFilteredLogs()
//               }
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
                Label("Recently Deleted", systemImage: "trash").foregroundStyle(.red)
            }
        }

    }
    
    @ViewBuilder
    func entryContextMenuButtons(entry: Entry) -> some View {
        
        Button(action: {
            withAnimation {
                isShowingReplyCreationView = true
                replyEntryId = entry.id.uuidString
            }
        }) {
            Text("Reply")
            Image(systemName: "arrow.uturn.left")
                .foregroundColor(userPreferences.accentColor)
        }
        
        Button(action: {
            UIPasteboard.general.string = entry.content
            print("entry color : \(entry.color)")
        }) {
            Text("Copy Message")
            Image(systemName: "doc.on.doc")
        }
    
        
        Button(action: {
            withAnimation(.easeOut) {
                entry.isHidden.toggle()
                coreDataManager.save(context: coreDataManager.viewContext)
            }

        }, label: {
            Label(entry.isHidden ? "Hide Entry" : "Unhide Entry", systemImage: entry.isHidden ? "eye.slash.fill" : "eye.fill")
        })
        
        if let filename = entry.mediaFilename {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            if mediaExists(at: fileURL) {
                if let data =  getMediaData(fromFilename: filename) {
                    if isPDF(data: data) {
                    } else {
                        let image = UIImage(data: data)!
                        Button(action: {
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            
                        }, label: {
                            Label("Save Image", systemImage: "photo.badge.arrow.down.fill")
                        })
                    }
                }
            }
        }
        
        Button(action: {
            withAnimation {
                entry.isPinned.toggle()
                coreDataManager.save(context: coreDataManager.viewContext)
            }
        }) {
            Text(entry.isPinned ? "Unpin" : "Pin")
            Image(systemName: "pin.fill")
                .foregroundColor(.red)
        }
        
        
        
        Button(action: {
            entry.shouldSyncWithCloudKit.toggle()
            
            // Save the flag change in local storage first
            coreDataManager.save(context: coreDataManager.viewContext)

//            CoreDataManager.shared.save(context: CoreDataManager.shared.viewContext)

            // Save the entry in the appropriate store
            CoreDataManager.shared.saveEntry(entry)
        }) {
            Text(entry.shouldSyncWithCloudKit && coreDataManager.isEntryInCloudStorage(entry) ? "Unsync" : "Sync")
            Image(systemName: "cloud.fill")
        }
        
    }
    
    
    @ViewBuilder
      func filteredEntriesListView() -> some View {
          let entries = filteredEntries(entries: Array(allEntries), searchText: searchModel.searchText, tags: searchModel.tokens)
              .sorted { $0.time ?? Date() > $1.time ?? Date() }
          
          
          ScrollView {
              LazyVStack(spacing: 10) {
                  ForEach(Array(entries.enumerated()), id: \.element) { index, entry in
                      if index < currentLoadedCount {
                          VStack(spacing: 5) {
                                                      entryHeaderView(entry: entry)
                                                          .padding(.horizontal)
                                                          .padding(.top, 10)
                                                      
                              EntryDetailView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, entry: entry, showContextMenu: true)
                                                          .environmentObject(userPreferences)
                                                          .environmentObject(coreDataManager)
                                                          .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                                                          .lineSpacing(userPreferences.lineSpacing)
                                                          .padding(.horizontal)
                                                          .padding(.vertical, 10)
                                                          .background(isClear(for: UIColor(userPreferences.entryBackgroundColor)) ? Color("DefaultEntryBackground") : userPreferences.entryBackgroundColor)
                                                          .cornerRadius(10)
                                                          .contextMenu {
                                                              entryContextMenuButtons(entry: entry)
                                                          }
                                                  }
                                                  .padding(.horizontal, 5)
                    
//
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
//          .background {
//              ZStack {
//                  Color(UIColor.systemGroupedBackground)
//                  LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
//              }
//              .ignoresSafeArea()
//          }
//          .scrollContentBackground(.hidden)
      }
      
      @State private var currentLoadedCount = 0
      private let initialLoadCount = 5
      private let additionalLoadCount = 5
      
      private func loadMoreContent(totalCount: Int) {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              currentLoadedCount = min(currentLoadedCount + additionalLoadCount, totalCount)
          }
      }
    


    
    @ViewBuilder func entryHeaderView(entry: Entry) -> some View {
        HStack {
            Text("\(formattedDateFull(entry.time))").font(.system(size: UIFont.systemFontSize))
                .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))
//                .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color(UIColor.label)))).opacity(0.4)
            
            Spacer()
            if let reminderId = entry.reminderId, !reminderId.isEmpty, reminderExists(with: reminderId) {
                Label("", systemImage: "bell.fill").foregroundColor(userPreferences.reminderColor)
            }
            if (entry.isPinned) {
                Label("", systemImage: "pin.fill").foregroundColor(userPreferences.pinColor)

            }
        }
    }
    
    @ViewBuilder
    func suggestedSearchView() -> some View {
        List {
            Section(header: Text("Suggested").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)) {
                Button {
                    searchModel.tokens.append(.hiddenEntries)
                } label: {
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundStyle(userPreferences.accentColor)
                            .padding(.horizontal, 5)
                        Text("Hidden Entries")
                            .foregroundStyle(Color(UIColor.label))
                    }
                }
                
                Button {
                    searchModel.tokens.append(.mediaEntries)
                } label: {
                    HStack {
                        Image(systemName: "paperclip")
                            .foregroundStyle(userPreferences.accentColor)
                            .padding(.horizontal, 5)
                        
                        Text("Entries with Media")
                            .foregroundStyle(Color(UIColor.label))
                    }
                }
                
                Button {
                    searchModel.tokens.append(.reminderEntries)
                } label: {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(userPreferences.accentColor)
                            .padding(.horizontal, 5)
                        
                        Text("Entries with Reminder")
                            .foregroundStyle(Color(UIColor.label))
                    }
                }
                
                Button {
                    searchModel.tokens.append(.pinnedEntries)
                } label: {
                    HStack {
                        Image(systemName: "pin.fill")
                            .foregroundStyle(userPreferences.accentColor)
                            .padding(.horizontal, 5)
                        
                        Text("Pinned Entries")
                            .foregroundStyle(Color(UIColor.label))
                    }
                }
                
                
                Button {
                    searchModel.tokens.append(.stampNameEntries)
                } label: {
                    HStack {
                        Image(systemName: "star.circle.fill")
                            .foregroundStyle(userPreferences.accentColor)
                            .padding(.horizontal, 5)
                        
                        Text("Stamp Icon Label")
                            .foregroundStyle(Color(UIColor.label))
                    }
                }
            }
        }
//        .background {
//            ZStack {
//                Color(UIColor.systemGroupedBackground)
//                LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
//            }
//            .ignoresSafeArea()
//        }
//        .scrollContentBackground(.hidden)
        .refreshable {
            datesModel.addTodayIfNotExists()
            
            updateFetchRequests()
//            updateDateRange()
        }
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
    func calendarView() -> some View {
        Section {
            if showCalendar {
                CalendarView(datesModel: datesModel, selectionColor: userPreferences.accentColor, backgroundColor: Color(UIColor.fontColor(forBackgroundColor: UIColor(entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)))).opacity(0.05))  // Use a specific color for selection
                            .padding()
//                MultiDatePicker("Dates Available", selection: $datesModel.dates, in: datesModel.bounds).datePickerStyle(.graphical)
//                    .foregroundColor(Color.complementaryColor(of: userPreferences.accentColor))
//                    .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
//                    .accentColor(userPreferences.accentColor)
                            .onAppear {
                                datesModel.addTodayIfNotExists()
//                                updateFetchRequests()
                            }
                
            }
            
        } header: {
            HStack {
                Text("Calendar").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                
                Spacer()
                Label("", systemImage: showCalendar ? "chevron.up" : "chevron.down").foregroundStyle(userPreferences.accentColor)
                    .contentTransition(.symbolEffect(.replace.offUp))
            }
            .onTapGesture {
                showCalendar.toggle()
            }

        }
    }
    
    @ViewBuilder
    func logsListView() -> some View {
        ForEach(Array(datesModel.dates.filter{$0.value.isSelected}.keys.sorted()), id: \.self) { dateString in
            if let logDate = datesModel.dates[dateString], logDate.hasLog {
                ScrollView {
                    LazyVStack {
                        NavigationLink(destination: LogDetailView(totalHeight: $height, isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, logDay: dateString)
                            .environmentObject(userPreferences)) {
                                HStack {
                                    Image(systemName: "book.fill").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
                                    Text(dateString).foregroundStyle(Color(UIColor.label))
                                    
                                    Spacer()
                                }
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
    }

    
//    @ViewBuilder
//    func logsListView() -> some View {
//        ForEach(filteredLogs, id: \.self) { log in
//            
//            ScrollView {
//                LazyVStack {
//                    NavigationLink(destination: LogDetailView(totalHeight: $height, isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, log: log)
//                        .environmentObject(userPreferences)) {
//                            HStack {
//                                Image(systemName: "book.fill").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
//                                Text(log.day).foregroundStyle(Color(UIColor.label))
//
//                                Spacer()
//                            }
//                        }.padding(.top, 10)
//                        .contextMenu {
//                            Button(role: .destructive, action: {
//                                showingDeleteConfirmation = true
//                                logToDelete = log
//                            }) {
//                                Label("Delete", systemImage: "trash")
//                                    .foregroundColor(.red)
//                                
//                            }
//                            
//                        }
//                }
//            }
//          
//        }
//        
//    }
    
    func getDefaultEntryBackgroundColor() -> Color {
        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
        
        return Color(color)
    }

    func DatePickerView(date: Binding<Date>, title: String) -> some View {
        List {
            DatePicker("Start Date", selection: date, displayedComponents: .date)
        }
        .navigationTitle(title)
    }
    
    
    func filteredEntries(entries: [Entry], searchText: String, tags: [FilterTokens]) -> [Entry] {
        guard !searchText.isEmpty || !tags.isEmpty else { return entries }

        return entries.filter { entry in
            let matchesSearchText = searchText.isEmpty || entry.content.lowercased().contains(searchText.lowercased())

            let matchesTags: Bool
            if tags.isEmpty {
                matchesTags = true // If no tags, consider it a match.
            } else {
                matchesTags = tags.contains { tag in
                    switch tag {
                    case .hiddenEntries:
                        return entry.isHidden
                    case .stampNameEntries:
                        return entry.stampIcon.lowercased().contains(searchText.lowercased())
                    case .stampIndexEntries:
                        if let index = Int(searchText) {
                            return entry.stampIndex == index
                        }
                        return false
                    case .mediaEntries:
                        if let filename = entry.mediaFilename, !filename.isEmpty {
                            return imageExists(at: filename)
                        }
                        return false
                    case .searchTextEntries:
                        return entry.content.lowercased().contains(searchText.lowercased())
                    case .reminderEntries:
                        if let reminderId = entry.reminderId {
                            return !reminderId.isEmpty
                        } else {
                            return false
                        }
                    case .pinnedEntries:
                        return entry.isPinned
                    }
                }
            }

            
            if tags.first == .mediaEntries || tags.first == .hiddenEntries || tags.first == .pinnedEntries { //to consider both tag and search text
                return matchesTags && matchesSearchText
            }
            if tags.isEmpty {
                return matchesSearchText
            }
            else {
                return matchesTags
            }
        }
    }


    
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
    
//    func updateDates() {
//        print("updating the date range")
//        // Fetch all logs after import is done
//                    let logFetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
//                    do {
//                        let allLogs = try coreDataManager.viewContext.fetch(logFetchRequest)
//                        // Assuming you have an instance of your DateRangeModel and a way to convert logs to the expected format for updateDateRange
//                        self.datesModel.updateDateRange(with: allLogs)
////                        DispatchQueue.main.async {
////                            self.datesModel.updateDateRange(with: allLogs)
////                        }
//                    } catch {
//                        print("Failed to fetch logs for date range update: \(error)")
//                    }
//    }
    
//    func filteredLogs() -> [Log] {
//        print("Entered filteredLogs!")
//        print("dates have been updated once again")
//        
//        print("datesModel.startDate: \(datesModel.startDate)")
//        print("datesModel.endDate: \(datesModel.endDate)")
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//
//        // Parse dates once and store them
//        let parsedLogs = logs.compactMap { log -> (Log, Date)? in
//            guard let logDate = dateFormatter.date(from: log.day) else {
//                print("Failed to parse date from log.day: \(log.day)")
//                return nil
//            }
//            return (log, logDate)
//        }
//        print("Parsed logs count: \(parsedLogs.count)")
//
//        // Group logs by year
//        let groupedByYear = Dictionary(grouping: parsedLogs) { (_, date) -> Int in
//            Calendar.current.component(.year, from: date)
//        }
//        print("Grouped by year count: \(groupedByYear.keys.count)")
//
//        // Sort groups by year and flatten
//        let sortedAndFlattenedLogs = groupedByYear.sorted { $0.key > $1.key } // Previous year logs first
//                                                .flatMap { $0.value.map { $0.0 } }
//        print("Sorted and flattened logs count: \(sortedAndFlattenedLogs.count)")
//
//        switch selectedTimeframe {
//        case "By Date":
//            print("Filtering by Date...")
//            let filteredLogs = sortedAndFlattenedLogs.filter { log in
//                guard let logDate = dateFormatter.date(from: log.day) else {
//                    print("Failed to parse date from log.day in filter: \(log.day)")
//                    return false
//                }
//                let formattedLogDate = dateFormatter.string(from: logDate)
//                let isContained = datesModel.dates.contains { (dateString, logDateEntry) in
//                    guard let selectedDate = datesModel.dateFormatter.date(from: dateString) else {
//                        print("Failed to create date from date string: \(dateString)")
//                        return false
//                    }
//                    let startOfDay = Calendar.current.startOfDay(for: selectedDate)
//                    let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) ?? selectedDate
//                    let isWithinDay = logDate >= startOfDay && logDate <= endOfDay
//                    let isSelected = logDateEntry.isSelected
//                    
//                    if isWithinDay && isSelected {
//                        print("Log date \(logDate) is within selected day \(selectedDate)")
//                    }
//                    return isWithinDay && isSelected
//                }
//                if !isContained {
//                    print("Log date \(logDate) is not within any selected day")
//                }
//                return isContained
//            }
//            print("Filtered logs by date count: \(filteredLogs.count)")
//            return filteredLogs
//
//        default:
//            print("Returning sorted and flattened logs without additional filtering.")
//            return sortedAndFlattenedLogs
//        }
//    }



    

    
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
        
        for entry in fetchEntriesByDate(logDay: logDay) {
            entry.isRemoved = true //moving to recently deleted instead of permanently deleting all entries
//                deleteEntry(entry: entry, coreDataManager: coreDataManager)
            do {
                try coreDataManager.viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
//
//    private func deleteLog(log: Log?) {
//        let dateStringsManager = DateStrings()
//        guard let log = log else { return }
//        dateStringsManager.removeDate(log.day)
//        if let entries = log.relationship as? Set<Entry> {
//            for entry in entries {
//                entry.isRemoved = true //moving to recently deleted instead of permanently deleting all entries
////                deleteEntry(entry: entry, coreDataManager: coreDataManager)
//                do {
//                    try coreDataManager.viewContext.save()
//                } catch {
//                    let nsError = error as NSError
//                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                }
//
//            }
//        }
//        coreDataManager.viewContext.delete(log)
//        
//        do {
//            try coreDataManager.viewContext.save()
//        } catch {
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//    }
    
    

    
    func createPDFData_log(log: Log) -> Data { //finally works
        let pdfMetaData = [
            kCGPDFContextCreator: "Your App",
            kCGPDFContextAuthor: "Your Name"
        ]
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, pdfMetaData)
        
        
        let rootView =               LogDetailView_PDF(height: $height, log: log)
            .padding(10)
            .environmentObject(userPreferences)
            .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
            .modifier(GetHeightModifier(height: $height))

        
        
        print("HEIGHT FROM VIEW MODIFIER: \(height)")
        let uiHostingController = UIHostingController(rootView: rootView)
        // Define lineHeight
        print("userPreferences.fontSize: \(userPreferences.fontSize)")
            let imageHeight: CGFloat = 250 // Additional height for entries with images. this should be dynamic later

        var totalHeight: CGFloat = 0
            if let entries = log.relationship as? Set<Entry> { // Cast NSSet to Set<Entry>
                for entry in entries {
                    let entry_view = EntryDetailView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, entry: entry)
                        .environmentObject(coreDataManager)
                        .environmentObject(userPreferences)
                        .getHeight { height in
                            self.height = height

                               // Use the height here
                               print("Height is \(height)")
                           }
                        .background(
                          GeometryReader { geometryProxy in
                            Color.clear
                              .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                          }
                        )
                        .onPreferenceChange(SizePreferenceKey.self) { newSize in
                            totalHeight += newSize.height

                          print("The new child size is: \(newSize)")
                        }
               
                    
                    print("HEIGHT: \(height)")
                    print()
  
                    print("entry.content: \(entry.content)")
                    if entry.mediaFilename != "" && entry.mediaFilename != nil {
                        totalHeight += (imageHeight + 50)
                    }
                }
            }
//
        

        print("total HEIGHT: \(totalHeight)")
            // Set targetSize with calculated height
            let width = UIScreen.main.bounds.size.width // Assuming full width
            let targetSize = CGSize(width: width, height: totalHeight)

        
        UIGraphicsBeginPDFPageWithInfo(CGRect(origin: .zero, size: targetSize), nil)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        let img = renderer.image { ctx in
            let uiView = uiHostingController.view
            uiView?.bounds = CGRect(origin: .zero, size: targetSize)
            uiView?.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
        }
        img.draw(in: CGRect(origin: .zero, size: targetSize))
        
        UIGraphicsEndPDFContext()
        return pdfData as Data
    }
    
//
//    func render() async -> URL {
//        let logsByDay = Dictionary(grouping: filteredLogs(), by: { $0.day })
//        let sortedDays = logsByDay.keys.sorted()
//
//        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("output.pdf")
//
//        let renderer = UIGraphicsPDFRenderer(bounds: .zero)
//
//        do {
//            try renderer.writePDF(to: url) { context in
//                for day in sortedDays {
//                    let logsForDay = logsByDay[day]!
//
//                    for log in logsForDay {
//                        // Estimate height based on total number of entries per log
//                        let estimatedHeightPerEntry: CGFloat = 300
//                        let totalHeight = estimatedHeightPerEntry * CGFloat(log.relationship.count)
//                        print("Total height: \(totalHeight)")
//
//                        // Split content into multiple pages if total height exceeds a certain limit
//                        let pageLimit: CGFloat = 14000 // Adjust this value based on your content
//                        let numberOfPages = ceil(totalHeight / pageLimit)
//
//                        for page in 0..<Int(numberOfPages) {
//                            let pageHeight = min(pageLimit, totalHeight - CGFloat(page) * pageLimit)
//
//                            context.beginPage(withBounds: CGRect(x: 0, y: 0, width: 612, height: pageHeight), pageInfo: [:])
//
//                            let content = LogDetailView_PDF(log: log)
//                                .padding(10)
//                                .environmentObject(userPreferences)
//                                .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
//
//                            let hostingController = UIHostingController(rootView: content)
//                            hostingController.view.bounds = CGRect(origin: .zero, size: CGSize(width: 612, height: pageHeight))
//                            hostingController.view.backgroundColor = .clear
//
//                            hostingController.view.setNeedsLayout()
//                            hostingController.view.layoutIfNeeded()
//
//                            let targetRect = CGRect(x: 0, y: 0, width: 612, height: pageHeight)
//                            hostingController.view.drawHierarchy(in: targetRect, afterScreenUpdates: true)
//                        }
//                    }
//                }
//            }
//        } catch {
//            print("Failed to write PDF: \(error)")
//        }
//
//        return url
//    }
}






//class SearchBar: UISearchBar, UISearchBarDelegate {
//
//    var textField: UITextField? {
//        if #available(iOS 13.0, *) {
//            return self.searchTextField
//        }
//        return subviews.first?.subviews.first(where: { $0 as? UITextField != nil }) as? UITextField
//    }
//
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        delegate = self
//
//        if let textField = textField {
//            textField.tintColor = UIColor.red
//            textField.textColor = .red
//            textField.clearButtonMode = .whileEditing
//            textField.returnKeyType = .search
//        }
//    }
//
//}


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
            .searchable(text: $searchModel.searchText, tokens: $searchModel.tokens, isPresented: showSearch) { token in
                        switch token {
                        case .hiddenEntries:
                            Text("Hidden")
                        case .mediaEntries:
                            Text("Media")
                        case .stampIndexEntries:
                            Text("Index")
                        case .stampNameEntries:
                            Text("Name")
                        case .searchTextEntries:
                            Text(searchModel.searchText)
                        case .reminderEntries:
                            Text("Reminder")
                        case .pinnedEntries:
                            Text("Pinned")
                        }
                  
                
                
            }
            .searchBarTextColor(isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear)
            .font(.system(size: UIFont.systemFontSize))
            .focused($isSearchFieldFocused)
    }

    
//    func filteredLogs() -> [Log] {
//        print("Entered filteredLogs!")
//        print("dates have been updated once again")
//        
//        print("datesModel.startDate: \(datesModel.startDate)")
//        print("datesModel.endDate: \(datesModel.endDate)")
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//
//        // Parse dates once and store them
//        let parsedLogs = logs.compactMap { log -> (Log, Date)? in
//            guard let logDate = dateFormatter.date(from: log.day) else {
//                print("Failed to parse date from log.day: \(log.day)")
//                return nil
//            }
//            return (log, logDate)
//        }
//        print("Parsed logs count: \(parsedLogs.count)")
//
//        // Group logs by year
//        let groupedByYear = Dictionary(grouping: parsedLogs) { (_, date) -> Int in
//            Calendar.current.component(.year, from: date)
//        }
//        print("Grouped by year count: \(groupedByYear.keys.count)")
//
//        // Sort groups by year and flatten
//        let sortedAndFlattenedLogs = groupedByYear.sorted { $0.key > $1.key } // Previous year logs first
//                                                .flatMap { $0.value.map { $0.0 } }
//        print("Sorted and flattened logs count: \(sortedAndFlattenedLogs.count)")
//
//            print("Filtering by Date...")
//            let filteredLogs = sortedAndFlattenedLogs.filter { log in
//                guard let logDate = dateFormatter.date(from: log.day) else {
//                    print("Failed to parse date from log.day in filter: \(log.day)")
//                    return false
//                }
//                let formattedLogDate = dateFormatter.string(from: logDate)
//                let isContained = datesModel.dates.contains { (dateString, logDateEntry) in
//                    guard let selectedDate = datesModel.dateFormatter.date(from: dateString) else {
//                        print("Failed to create date from date string: \(dateString)")
//                        return false
//                    }
//                    let startOfDay = Calendar.current.startOfDay(for: selectedDate)
//                    let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) ?? selectedDate
//                    let isWithinDay = logDate >= startOfDay && logDate <= endOfDay
//                    let isSelected = logDateEntry.isSelected
//                    
//                    if isWithinDay && isSelected {
//                        print("Log date \(logDate) is within selected day \(selectedDate)")
//                    }
//                    return isWithinDay && isSelected
//                }
//                if !isContained {
//                    print("Log date \(logDate) is not within any selected day")
//                }
//                return isContained
//            }
//            print("Filtered logs by date count: \(filteredLogs.count)")
//            return filteredLogs
//        }
}
