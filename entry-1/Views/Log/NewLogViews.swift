//
//  NewLogViews.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/11/24.
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
    @Namespace private var animation

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

    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: []
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
        NavigationStack {
            VStack {
                mainView()
            }
            .font(.customHeadline)
            .navigationTitle("Logs")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
            
            .navigationBarItems(trailing: navigationButtons())
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
    func searchNavigationButton() -> some View {
        Button(action: { selectedOption = .search }) {
            Label("Search", systemImage: "magnifyingglass")
                .font(.customHeadline)
        }
    }
    
    @ViewBuilder
    func navigationButtons() -> some View {
        HStack {
            searchNavigationButton()
            Menu {
                Button(action: { selectedOption = .calendar }) {
                    Label("Calendar", systemImage: "calendar")
                }
                Button(action: { selectedOption = .folders }) {
                    Label("Folders", systemImage: "folder")
                }
                Button(action: { selectedOption = .reminders }) {
                    Label("Reminders", systemImage: "bell")
                }
                
                Button(action: { selectedOption = .schedule }) {
                    Label("Schedule", systemImage: "clock")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.customHeadline)
                    .foregroundColor(userPreferences.accentColor)
            }
        }
    }

    @ViewBuilder
    func mainView() -> some View {
        VStack(spacing: 0) {
            switch selectedOption {
            case .calendar:
                mainLogsCalendarView()
                    .refreshable {
                        datesModel.addTodayIfNotExists()
                        updateFetchRequests()
                    }
            case .folders:
                FoldersView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, searchModel: searchModel, reminderManager: ReminderManager())
                    .environmentObject(coreDataManager)
                    .environmentObject(userPreferences)
            case .reminders:
                RemindersView(reminderManager: ReminderManager())
                    .environmentObject(userPreferences)
                    .environmentObject(coreDataManager)
            case .search:
                ZStack {
                    if searchModel.tokens.isEmpty && searchModel.searchText.isEmpty {
                        suggestedSearchView()
                    } else {
                        filteredEntriesListView()
                    }
                }
                .searchable(text: $searchModel.searchText, tokens: $searchModel.tokens, isPresented: showSearch) { token in
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
            case .schedule:
                ScheduleView(showCalendar: $showCalendar, eventManager: EventManager(), reminderManager: ReminderManager())
                    .environmentObject(userPreferences)
                    .environmentObject(userPreferences)
            }
        }
        .background {
            userPreferences.backgroundView(colorScheme: colorScheme)
        }
        .scrollContentBackground(.hidden)
        .sheet(isPresented: $shareSheetShown) {
            if let log_uiimage = image {
                let logImage = Image(uiImage: log_uiimage)
                ShareLink(item: logImage, preview: SharePreview("", image: logImage))
            }
        }
        .listStyle(.insetGrouped)
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
            
            NavigationLink(destination: RecentlyDeletedView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, reminderManager: ReminderManager()).environmentObject(coreDataManager).environmentObject(userPreferences)) {
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
                Label("", systemImage: showCalendar ? "chevron.up" : "chevron.left").foregroundStyle(userPreferences.accentColor)
                    .contentTransition(.symbolEffect(.replace.offUp))
            }
            .onTapGesture {
                showCalendar.toggle()
            }
        }
        .listRowBackground(getSectionColor(colorScheme: colorScheme))
        .onAppear {
            datesModel.addTodayIfNotExists()
        }
    }

    @ViewBuilder
    func logsListView() -> some View {
        ForEach(Array(datesModel.dates.filter { $0.value.isSelected }.keys.sorted(by: >)), id: \.self) { dateString in
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
            }
        }
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

    @ViewBuilder
    func filteredEntriesListView() -> some View {
        FilteredEntriesListView(searchModel: searchModel, entryFilter: EntryFilter(searchText: $searchModel.searchText, filters: $searchModel.tokens), isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, reminderManager: ReminderManager())
            .environmentObject(userPreferences)
            .environmentObject(coreDataManager)
            .scrollContentBackground(.hidden)
            .listRowBackground(getSectionColor(colorScheme: colorScheme))
    }

    func updateFetchRequests() {
        let currentDay = formattedDate(Date())
        currentLog.nsPredicate = NSPredicate(format: "day == %@", currentDay)
        
        if currentLog.isEmpty {
            let newLog = Log(context: coreDataManager.viewContext)
            newLog.day = currentDay
            newLog.id = UUID()
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

    func formattedDate_logs(dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM/dd/yyyy"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM d, yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return dateString
        }
    }

    func entryCount(for dateString: String) -> Int {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM/dd/yyyy"
        
        guard let logDate = inputFormatter.date(from: dateString) else {
            print("Invalid dateString: \(dateString)")
            return 0
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: logDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return 0
        }
        
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

    func deleteLog(logDay: String?) {
        guard let logDay = logDay else { return }
        dateStrings.removeDate(logDay)

        for entry in fetchEntriesByDate(logDay: logDay) {
            entry.isRemoved = true
            do {
                try coreDataManager.viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func fetchEntriesByDate(logDay: String) -> [Entry] {
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()
        guard let logDate = dateFromString(logDay),
              let logComponents = dateComponents(from: logDay) else {
            print("Invalid log.day format")
            return []
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: logDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        request.predicate = NSPredicate(format: "isRemoved == NO AND time >= %@ AND time < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Entry.time, ascending: false)]
        
        do {
            return try coreDataManager.viewContext.fetch(request)
        } catch {
            print("Error fetching entries: \(error)")
            return []
        }
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
}
