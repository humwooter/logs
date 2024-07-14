
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
    @State private var selectedDates: Set<DateComponents> = []
    @State private var isDatesUpdated = false
    @Binding var replyEntryId: String?

    
    
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: false)]
    ) var logs: FetchedResults<Log>
    
//    @State private var startDate: Date = .distantPast
//
//    @State private var endDate: Date = Date() // Current day
    var calendar = Calendar.current
    var timeZone = TimeZone.current

    @EnvironmentObject var datesModel: DatesModel

    
    @State var image: UIImage?
    @State var shareSheetShown = false
    
    @State private var height: CGFloat = 0
    @State var heights: [UUID: CGFloat] = [:]
    @Binding var isShowingReplyCreationView: Bool


    
    func updateDateRange() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let dateLogs = logs.compactMap { dateFormatter.date(from: $0.day) }
        
        guard let earliestDate = dateLogs.min(), let latestDate = dateLogs.max() else {
            return // Return early if there are no dates
        }
        
        // Update the start date to the earliest date from the logs
        datesModel.startDate = earliestDate
        
        // Check if the latest date from the logs is today or in the past
        if Calendar.current.isDateInToday(latestDate) || latestDate < Date() {
            // If so, set the end date to today
            datesModel.endDate = Date()
        } else {
            // If the latest date is in the future, set the end date to the day after the latest date
            if let dayAfterLatestDate = Calendar.current.date(byAdding: .day, value: 1, to: latestDate) {
                datesModel.endDate = dayAfterLatestDate
            } else {
                // Fallback to the latest date if unable to calculate the next day (unlikely to fail)
                datesModel.endDate = latestDate
            }
        }
    }

    
    @State private var showCalendar = true
    
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
        predicate: NSPredicate(format: "day == %@", formattedDate(Date())),
        animation: nil
    ) var currentLog: FetchedResults<Log>

    
    // LogsView
    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: []  // Empty array implies no sorting
    ) var allEntries: FetchedResults<Entry>
    
    @Environment(\.isSearching) private var isSearching
    @ObservedObject var searchModel: SearchModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {

        NavigationStack {
            VStack {
            VStack(spacing: 0) {
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
                    .onAppear {
                                    correctEntryLogRelationships()
                                }
            }.font(.system(size: UIFont.systemFontSize))

            
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
    
    func correctEntryLogRelationships() {
        for entry in allEntries {
            let entryDate = formattedDate(entry.time ?? Date())
            if entry.relationship.day != entryDate {
                // Fetch or create Log for the correct date
                let oldLog = entry.relationship
                oldLog.removeFromRelationship(entry)
                
                if let correctLog = fetchLogByDate(date: entryDate, coreDataManager: coreDataManager) {
                    entry.relationship = correctLog
                } else {
                    let newLog = createLog(date: entry.time ?? Date(), coreDataManager: coreDataManager)
                    entry.relationship = newLog
                }
                do {
                    try coreDataManager.viewContext.save()
                } catch {
                    print("Failed to update entry relationship: \(error.localizedDescription)")
                }
            }
            
            if let reminderId = entry.reminderId, !reminderId.isEmpty {
                if !reminderExists(with: reminderId) {
                    entry.reminderId = ""
                }
                reminderIsComplete(reminderId: reminderId) { isCompleted in
                    DispatchQueue.main.async {
                        if isCompleted {
                            entry.reminderId = ""
                        } else {
                            print("The reminder is not completed or does not exist.")
                        }
                    }
                }
                do {
                    try coreDataManager.viewContext.save()
                } catch {
                    print("Failed to save viewContext: \(error)")
                }
            }
        }
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
                        deleteLog(log: logToDelete)
                    },
                          secondaryButton: .cancel())
                }
            
            NavigationLink(destination: RecentlyDeletedView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId).environmentObject(coreDataManager).environmentObject(userPreferences)) {
                Label("Recently Deleted", systemImage: "trash").foregroundStyle(.red)
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
            let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            // Check if today's date already exists in the dates array
            if let index = datesModel.dates.firstIndex(where: { $0.date == todayComponents }) {
                // If it exists, you can decide to update its isSelected property or leave it as is
                // For example, you could toggle the selection:
                datesModel.dates[index].isSelected.toggle()
            } else {
                // If it doesn't exist, add it as a new LogDate with isSelected initially set to true or false as per your requirement
                datesModel.dates.append(LogDate(date: todayComponents, isSelected: true))
            }
            
            updateFetchRequests()
            updateDateRange()
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
        
//        Button(action: {
//            let pdfData = createPDFData_entry(entry: entry)
//            let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("entry.pdf")
//            try? pdfData.write(to: tmpURL)
//            let activityVC = UIActivityViewController(activityItems: [tmpURL], applicationActivities: nil)
//            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//                let window = windowScene.windows.first
//                window?.rootViewController?.present(activityVC, animated: true, completion: nil)
//            }
//        }, label: {
//            Label("Share Entry", systemImage: "square.and.arrow.up")
//        })
        
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
                                                      
                                                      EntryDetailView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, entry: entry)
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
                                                  .onAppear {
                                                      currentLoadedCount = min(initialLoadCount, entries.count)
                                                  }
//                          Section(header: entryHeaderView(entry: entry)) {
//                              EntryDetailView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, entry: entry)
//                                  .environmentObject(userPreferences)
//                                  .environmentObject(coreDataManager)
//                                  .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
//                                  .lineSpacing(userPreferences.lineSpacing)
//                                  .background(isClear(for: UIColor(userPreferences.entryBackgroundColor)) ? Color("DefaultEntryBackground") : userPreferences.entryBackgroundColor)
//                                  .cornerRadius(10)
//                                  .padding(5)
//                          }
//                          .padding(5)
//                          .listRowBackground(isClear(for: UIColor(userPreferences.entryBackgroundColor)) ? Color("DefaultEntryBackground") : userPreferences.entryBackgroundColor)
                      }
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
          .background {
              ZStack {
                  Color(UIColor.systemGroupedBackground)
                  LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
              }
              .ignoresSafeArea()
          }
          .scrollContentBackground(.hidden)
      }
      
      @State private var currentLoadedCount = 0
      private let initialLoadCount = 5
      private let additionalLoadCount = 5
      
      private func loadMoreContent(totalCount: Int) {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              currentLoadedCount = min(currentLoadedCount + additionalLoadCount, totalCount)
          }
      }
    

    func getIdealTextColor() -> Color {
        var entryBackgroundColor =  UIColor(userPreferences.entryBackgroundColor)
        var backgroundColor = isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear
        var blendedBackground = UIColor.blendedColor(from: entryBackgroundColor, with: UIColor(backgroundColor))
        return Color(UIColor.fontColor(forBackgroundColor: blendedBackground))
    }
    
    @ViewBuilder func entryHeaderView(entry: Entry) -> some View {
        HStack {
            Text("\(formattedDateFull(entry.time))").font(.system(size: UIFont.systemFontSize))
                .foregroundStyle(getIdealTextColor().opacity(0.5))
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
                
                //            Button {
                //                searchModel.tokens.append(.stampIndexEntries)
                //            } label: {
                //                HStack {
                //                    Image(systemName: "number.circle.fill")
                //                        .foregroundStyle(userPreferences.accentColor)
                //                        .padding(.horizontal, 5)
                //
                //                    Text("Stamp Number")
                //                        .foregroundStyle(Color(UIColor.label))
                //                }
                //            }
                //
                
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
        .background {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()
        }
        .scrollContentBackground(.hidden)
        .refreshable {
            let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            // Check if today's date already exists in the dates array
            if let index = datesModel.dates.firstIndex(where: { $0.date == todayComponents }) {
                // If it exists, you can decide to update its isSelected property or leave it as is
                // For example, you could toggle the selection:
                datesModel.dates[index].isSelected.toggle()
            } else {
                // If it doesn't exist, add it as a new LogDate with isSelected initially set to true or false as per your requirement
                datesModel.dates.append(LogDate(date: todayComponents, isSelected: true))
            }
            
            updateFetchRequests()
            updateDateRange()
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
                        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                        // Check if today's date already exists in the dates array
                        if let index = datesModel.dates.firstIndex(where: { $0.date == todayComponents }) {
                        } else {
                            datesModel.dates.append(LogDate(date: todayComponents, isSelected: true))
                        }
                        
                        updateFetchRequests()
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
        ForEach(filteredLogs(), id: \.self) { log in
            
            ScrollView {
                LazyVStack {
                    NavigationLink(destination: LogDetailView(totalHeight: $height, isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, log: log)
                        .environmentObject(userPreferences)) {
                            HStack {
                                Image(systemName: "book.fill").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
                                Text(log.day).foregroundStyle(Color(UIColor.label))

                                Spacer()
                            }
                        }.padding(.top, 10)
                        .contextMenu {
                            Button(role: .destructive, action: {
                                showingDeleteConfirmation = true
                                logToDelete = log
                            }) {
                                Label("Delete", systemImage: "trash")
                                    .foregroundColor(.red)
                                
                            }
//                            Button(action: {
//                                Task {
//                                    DispatchQueue.main.async {
//                                        let pdfData = createPDFData_log(log: log)
//                                        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("log.pdf")
//                                        try? pdfData.write(to: tmpURL)
//                                        let activityVC = UIActivityViewController(activityItems: [tmpURL], applicationActivities: nil)
//                                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//                                            let window = windowScene.windows.first
//                                            window?.rootViewController?.present(activityVC, animated: true, completion: nil)
//                                        }
//                                    }
//                                }
//                                
//                            }, label: {
//                                Label("Share Log PDF", systemImage: "square.and.arrow.up")
//                            })
                            
                        }
                }
            }
        }
    }
    
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
    
    func filteredLogs() -> [Log] {
        print("Entered filteredLogs!")
        print("dates have been updated once again")
        
        print("datesModel.startDate: \(datesModel.startDate)")
        print("datesModel.endDate: \(datesModel.startDate)")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        // Parse dates once and store them
        let parsedLogs = logs.compactMap { log -> (Log, Date)? in
            guard let logDate = dateFormatter.date(from: log.day) else {
                print("Failed to parse date from log.day: \(log.day)")
                return nil
            }
            return (log, logDate)
        }
        print("Parsed logs count: \(parsedLogs.count)")

        // Group logs by year
        let groupedByYear = Dictionary(grouping: parsedLogs) { (_, date) -> Int in
            Calendar.current.component(.year, from: date)
        }
        print("Grouped by year count: \(groupedByYear.keys.count)")

        // Sort groups by year and flatten
        let sortedAndFlattenedLogs = groupedByYear.sorted { $0.key > $1.key } // Previous year logs first
                                                .flatMap { $0.value.map { $0.0 } }
        print("Sorted and flattened logs count: \(sortedAndFlattenedLogs.count)")

        switch selectedTimeframe {
        case "By Date":
            print("Filtering by Date...")
            let filteredLogs = sortedAndFlattenedLogs.filter { log in
                guard let logDate = dateFormatter.date(from: log.day) else {
                    print("Failed to parse date from log.day in filter: \(log.day)")
                    return false
                }
                let isContained = datesModel.dates.contains { logDateEntry in
                    guard let selectedDate = calendar.date(from: logDateEntry.date) else {
                        print("Failed to create date from dateComponent")
                        return false
                    }
                    let startOfDay = Calendar.current.startOfDay(for: selectedDate)
                    let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) ?? selectedDate
                    let isWithinDay = logDate >= startOfDay && logDate <= endOfDay
                    let isSelected = logDateEntry.isSelected
                    
                    if isWithinDay && isSelected {
                        print("Log date \(logDate) is within selected day \(selectedDate)")
                    }
                    return isWithinDay && isSelected
                }
                if !isContained {
                    print("Log date \(logDate) is not within any selected day")
                }
                return isContained
            }
            print("Filtered logs by date count: \(filteredLogs.count)")
            return filteredLogs

        default:
            print("Returning sorted and flattened logs without additional filtering.")
            return sortedAndFlattenedLogs
        }
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
    
    
    
    private func deleteLog(log: Log?) {
        let dateStringsManager = DateStrings()
        guard let log = log else { return }
        dateStringsManager.removeDate(log.day)
        if let entries = log.relationship as? Set<Entry> {
            for entry in entries {
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
        coreDataManager.viewContext.delete(log)
        
        do {
            try coreDataManager.viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    

    
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


    var body: some View {
        
        LogsView(replyEntryId: $replyEntryId, isShowingReplyCreationView: $isShowingReplyCreationView, searchModel: searchModel)
            .environmentObject(datesModel)
            .environmentObject(userPreferences)
            .environmentObject(coreDataManager)
            .searchable(text: $searchModel.searchText, tokens: $searchModel.tokens) { token in
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
}
