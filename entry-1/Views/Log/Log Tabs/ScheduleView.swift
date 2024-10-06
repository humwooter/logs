//
//  ScheduleView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/4/24.
//
import SwiftUI
import EventKit
import CoreData

struct ScheduleView: View {
    @ObservedObject var eventManager = EventManager()
    @ObservedObject var reminderManager = ReminderManager()
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    @State private var currentTime: Date = Date()
    @StateObject private var datesModel = DatesModel()
    @State private var entries: [Date: [Entry]] = [:]
    @State private var reminders: [Date: [EKReminder]] = [:]
    @State private var events: [Date: [EKEvent]] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Weekly calendar view allowing date selection
            ScrollableWeeklyCalendarView(
                datesModel: datesModel,
                selectionColor: userPreferences.accentColor,
                backgroundColor: Color(UIColor.fontColor(forBackgroundColor: UIColor(getEntryBackgroundColor()))).opacity(0.05)
            )
            .environmentObject(userPreferences)
            .onReceive(datesModel.$dates) { dates in
                let newSelectedDates = dates.filter { $0.value.isSelected }
                    .compactMap { dateFromString($0.key) }
                
                for date in newSelectedDates {
                    fetchEntries(for: date)
                    fetchReminders(for: date)
                    fetchEvents(for: date)
                }
                
                // Remove data for dates that are no longer selected
                let allDates = Set(entries.keys).union(reminders.keys).union(events.keys)
                let deselectedDates = allDates.subtracting(newSelectedDates)
                
                for date in deselectedDates {
                    entries[date] = nil
                    reminders[date] = nil
                    events[date] = nil
                }
            }
            .onAppear {
                for date in selectedDates {
                    fetchEntries(for: date)
                    fetchReminders(for: date)
                    fetchEvents(for: date)
                }
                startTimer()
            }
            
            // Timeline view
            timelineView()
        }
    }
    
    // Computed property for selected dates
    private var selectedDates: [Date] {
        datesModel.dates.filter { $0.value.isSelected }
            .compactMap { dateFromString($0.key) }
    }
    
    // MARK: - ViewBuilder Functions
    
    @ViewBuilder
    private func timelineView() -> some View {
        // Vertical ScrollView wrapping both Y-axis and day columns for synchronized vertical scrolling
        ScrollView(.vertical) {
            HStack(spacing: 0) {
                // Y-axis (time labels) - fixed at the leading edge
                timelineColumn()
                
                // Scrollable day columns
                // Horizontal ScrollView wrapping day columns for independent horizontal scrolling
                ScrollView(.horizontal) {
                    // ZStack to overlay the current time indicator on the day columns
                    ZStack(alignment: .topLeading) {
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(Array(datesModel.dates.filter { $0.value.isSelected }.keys.sorted()), id: \.self) { dateString in
                                if let _ = datesModel.dates[dateString], isValidDateFormat(dateString) {
                                    dayColumnView(for: dateString)
                                }
                            }
                        }
                        // Current time indicator line overlaid on day columns
                        currentTimeIndicator()
                    }
                }
            }
        }
    }
    
    // Timeline column (Y-axis time labels)
    private func timelineColumn() -> some View {
        VStack(spacing: 0) {
            ForEach(0..<24) { hour in
                hourRow(hour: hour)
            }
        }
        .frame(width: 70, alignment: .leading) // Fixed width for the time labels
    }
    
    private func hourRow(hour: Int) -> some View {
        HStack(spacing: 0) {
            Text(formatHour(hour: hour))
                .frame(width: 60, alignment: .leading)
                .padding(.leading, 8)
                .foregroundColor(getTextColor())
        }
        .frame(height: 60)
    }



    
    // Main view for a specific day column
    private func dayColumnView(for dayString: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(formattedDateString(dayString))
                .font(.caption)
                .foregroundColor(getIdealHeaderTextColor())
                .frame(height: 20)
            ZStack(alignment: .topLeading) {
                VStack(spacing: 0) {
                    ForEach(0..<24) { hour in
                        hourBlock(hour: hour)
                    }
                }
                overlayDetails(forDateString: dayString)
            }
        }
        .frame(width: 150, alignment: .leading) // Fixed width for each day's column
    }
    
    private func hourBlock(hour: Int) -> some View {
        Rectangle()
            .fill(hour % 2 == 0 ? Color.gray.opacity(0.1) : Color.clear)
            .frame(height: hour == 23 ? 120 : 60)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray),
                alignment: .top
            )
    }
    
    // Displays entries, reminders, and events for a specific day
    private func overlayDetails(forDateString dayString: String) -> some View {
        if let date = dateFromString(dayString) {
            return AnyView(
                ZStack {
                    if let dayEntries = entries[date] {
                        ForEach(dayEntries) { entry in
                            let position = positionForTime(entry.time, in: dayString)
                            entryRow(entry: entry)
                                .offset(y: position)
                        }
                    }
                    if let dayReminders = reminders[date] {
                        ForEach(dayReminders, id: \.calendarItemIdentifier) { reminder in
                            if let dueDate = reminder.dueDateComponents?.date {
                                let position = positionForTime(dueDate, in: dayString)
                                reminderRow(reminder: reminder)
                                    .offset(y: position)
                            }
                        }
                    }
                    if let dayEvents = events[date] {
                        ForEach(dayEvents, id: \.eventIdentifier) { event in
                            let position = positionForTime(event.startDate, in: dayString)
                            let duration = event.endDate.timeIntervalSince(event.startDate)
                            eventRow(event: event, duration: duration)
                                .offset(y: position)
                        }
                    }
                }
                    .padding(.horizontal)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    // View for displaying an entry
    private func entryRow(entry: Entry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if entry.stampIndex != -1 {
                HStack {
                    Image(systemName: entry.stampIcon)
                        .foregroundColor(Color(entry.color))
                    Spacer()
                }
            }
            Text(entryTitle(for: entry))
                .font(.caption)
                .foregroundColor(getTextColor())
        }
        .padding(8)
        .background(getEntryBackgroundColor())
        .cornerRadius(8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Helper function to get the entry title or first 10 characters of content
    private func entryTitle(for entry: Entry) -> String {
        if let title = entry.title, !title.isEmpty {
            return getName(for: title)
        } else if !entry.content.isEmpty {
            return getName(for: entry.content)
        } else {
            return "Untitled"
        }
    }
    
    
    private func getName(for name: String) -> String {
        return name.prefix(5) + "..."
    }
    // View for displaying a reminder
    private func reminderRow(reminder: EKReminder) -> some View {
        if let _ = reminder.dueDateComponents?.date {
            return AnyView(
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(userPreferences.reminderColor)
                        Spacer()
                    }
                    Text(getName(for: reminder.title))
                        .font(.caption)
                        .foregroundColor(getTextColor())
                }
                .padding(8)
                .background(getEntryBackgroundColor())
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .leading)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    // View for displaying an event
    private func eventRow(event: EKEvent, duration: TimeInterval) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.title ?? "")
                .font(.caption)
                .foregroundColor(getTextColor())
//            Text("Event Details")
//                .font(.subheadline)
        }
        .padding(8)
        .background(getEntryBackgroundColor())
        .cornerRadius(8)
        .frame(height: max(CGFloat(duration / 3600) * 60, 40)) // Minimum height of 40
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Horizontal line showing the current time across all day columns
    private func currentTimeIndicator() -> some View {
        Rectangle()
            .fill(userPreferences.accentColor)
            .frame(height: 2)
            .offset(y: yPositionForCurrentTime())
    }
    
    // MARK: - Utility Functions
    
    // Fetch entries from Core Data for a given date
    private func fetchEntries(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Entry.time, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "isRemoved == NO AND time >= %@ AND time < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            entries[date] = try coreDataManager.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch entries: \(error)")
        }
    }
    
    // Fetch reminders from EventKit for a given date
    private func fetchReminders(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        reminderManager.fetchReminders(startDate: startOfDay, endDate: endOfDay) { result in
            switch result {
            case .success(let fetchedReminders):
                reminders[date] = fetchedReminders.filter { $0.dueDateComponents != nil && $0.dueDateComponents!.date != nil && calendar.isDate($0.dueDateComponents!.date!, inSameDayAs: date) }
            case .failure(let error):
                print("Failed to fetch reminders: \(error)")
            }
        }
    }
    
    // Fetch events from EventKit for a given date
    private func fetchEvents(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        eventManager.fetchEvents(startDate: startOfDay, endDate: endOfDay) { result in
            switch result {
            case .success(let fetchedEvents):
                events[date] = fetchedEvents.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
            case .failure(let error):
                print("Failed to fetch events: \(error)")
            }
        }
    }
    
    // Calculate the position for a specific time in the day
    private func positionForTime(_ time: Date, in dayString: String) -> CGFloat {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: dateFromString(dayString) ?? Date())
        let timeInterval = time.timeIntervalSince(startOfDay)
        let hoursFromStart = timeInterval / 3600
        return CGFloat(hoursFromStart) * 60 // 60 points per hour
    }
    
    // Calculate the y position for the current time line
    private func yPositionForCurrentTime() -> CGFloat {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let currentInterval = currentTime.timeIntervalSince(startOfDay)
        let hoursFromStart = currentInterval / 3600
        return CGFloat(hoursFromStart) * 60 // 60 points per hour
    }
    
    // Timer to update current time every minute
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
}






extension ScheduleView {
    
    private func formatHour(hour: Int) -> String { //short with AM PM
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h a" // 12-hour format with AM/PM

        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current // Ensure correct timezone

        // Create a DateComponents for just the hour
        let components = DateComponents(hour: hour)
        
        // Get the date from the components
        if let date = calendar.date(from: components) {
            return dateFormatter.string(from: date)
        }
        
        // Fallback if date couldn't be created
        return "\(hour):00"
    }
    
    // Utility function to convert date string to Date
    private func dateFromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: dateString)
    }
    
    // Utility function to check if date string is valid
    private func isValidDateFormat(_ dateString: String) -> Bool {
        return dateFromString(dateString) != nil
    }
    
    // Utility function to format the date string
    private func formattedDateString(_ dateString: String) -> String {
        if let date = dateFromString(dateString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        } else {
            return dateString
        }
    }
    
    // Utility functions for color handling
    func getSectionColor(colorScheme: ColorScheme) -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        } else {
            return userPreferences.entryBackgroundColor
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
    
    func getIdealHeaderTextColor() -> Color {
        return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(userPreferences.backgroundColors.first ?? Color.clear), and: UIColor(userPreferences.backgroundColors[1])), colorScheme: colorScheme))
    }
    
    func getEntryBackgroundColor() -> Color {
        let entryBackgroundColor = userPreferences.entryBackgroundColor
        if isClear(for: UIColor(entryBackgroundColor)) {
            return getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        } else {
            return entryBackgroundColor
        }
    }
    
    private func isClear(for color: UIColor) -> Bool {
        return color.cgColor.alpha == 0
    }
}
