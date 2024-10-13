//
//  NewScheduleView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/11/24.
//
import SwiftUI
import EventKit
import CoreData

struct ScheduleView: View, UserPreferencesProvider {
    @ObservedObject var eventManager = EventManager()
    @ObservedObject var reminderManager = ReminderManager()
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var datesModel = DatesModel()
    @State private var entries: [Date: [Entry]] = [:]
    @State private var reminders: [Date: [EKReminder]] = [:]
    @State private var events: [Date: [EKEvent]] = [:]
    @Binding var showCalendar: Bool

    // Predefined sizes
    let timeLabelWidth: CGFloat = 70
    let hourHeight: CGFloat = 120
    let minDayColumnWidth: CGFloat = 150 // Minimum width for day columns

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 5) {
                    calendarView()
                    .padding(.bottom, showCalendar ? 5 : 0)
                
                // Schedule View
                scheduleView()
            }
            .padding(.horizontal)
//            .padding(.vertical, 5)
            .background(userPreferences.backgroundView(colorScheme: colorScheme))
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    // Weekly calendar view in the navigation bar
//                    ScrollableWeeklyScheduleView(
//                        datesModel: datesModel,
//                        selectionColor: userPreferences.accentColor,
//                        backgroundColor: Color(UIColor.fontColor(forBackgroundColor: UIColor(getEntryBackgroundColor()))).opacity(0.05)
//                    )
//                    .environmentObject(userPreferences)
//                    .frame(maxWidth: .infinity)
//                    
//        
//                }
//            }
            .onAppear {
                print("SELECTED DATES: \(selectedDates)")
//                        // Ensure today's date is selected
//                        if !selectedDates.contains(where: { Calendar.current.isDateInToday($0) }) {
//                            datesModel.select(date: Date())
//                        }

                for date in selectedDates {
                    fetchEntries(for: date)
                    fetchReminders(for: date)
                    fetchEvents(for: date)
                }
            }

            .onChange(of: datesModel.dates) { dates in
                let newSelectedDates = dates.values.filter { $0.isSelected }
                    .compactMap { Calendar.current.date(from: $0.date) }
                    .sorted() // Ensure dates are in ascending order

                // Fetch data for newly selected dates
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
                
                print("SELECTED DATES: \(selectedDates)")

            }
        }
    }

    // Computed property for selected dates
    private var selectedDates: [Date] {
        Array(Set(datesModel.dates.values.filter { $0.isSelected }
            .compactMap { Calendar.current.date(from: $0.date)})) // Normalize to start of day
            .sorted() // Convert back to an array and ensure dates are in ascending order
    }


    // MARK: - ViewBuilder Functions

    @ViewBuilder
    func calendarView() -> some View {
        Section {
            VStack {
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
            }
                .background(getSectionColor(colorScheme: colorScheme).cornerRadius(10))
        } header: {
            HStack {
                Text("CALENDAR").foregroundStyle(getIdealHeaderTextColor()).opacity(0.4)
                Spacer()
                Label("", systemImage: showCalendar ? "chevron.up" : "chevron.down").foregroundStyle(userPreferences.accentColor)
                    .contentTransition(.symbolEffect(.replace.offUp))
            }
            .padding(.horizontal)

            .onTapGesture {
                showCalendar.toggle()
            }
        }.padding(.top)

        .onAppear {
            datesModel.addTodayIfNotExists()
        }
    }
    
    @ViewBuilder
    private func scheduleView() -> some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - timeLabelWidth
            let dayColumnCount = max(selectedDates.count, 1)

            // Calculate the total content width
            let totalContentWidth = CGFloat(dayColumnCount) * minDayColumnWidth
            let shouldScrollHorizontally = totalContentWidth > availableWidth

            let calculatedDayColumnWidth: CGFloat = shouldScrollHorizontally ? minDayColumnWidth : availableWidth / CGFloat(dayColumnCount)

            TimelineView(.animation(minimumInterval: 60, paused: false)) { context in
                ScrollView(.vertical) {
                    ZStack(alignment: .topLeading) {
                        HStack(spacing: 0) {
                            // Time Columns (Y-Axis)
                            timelineColumn(hourHeight: hourHeight)

                            if shouldScrollHorizontally {
                                ScrollView(.horizontal) {
                                    HStack(spacing: 0) {
                                        dayColumns(calculatedDayColumnWidth: calculatedDayColumnWidth, hourHeight: hourHeight)
                                    }
                                }
                            } else {
                                HStack(spacing: 0) {
                                    dayColumns(calculatedDayColumnWidth: calculatedDayColumnWidth, hourHeight: hourHeight)
                                }
                            }
                        }

                        // Current Time Indicator
                        currentTimeIndicator(
                            currentDate: context.date,
                            hourHeight: hourHeight,
                            totalWidth: geometry.size.width
                        )
                    }
                }
            }
        }
    }

    private func currentTimeIndicator(
        currentDate: Date,
        hourHeight: CGFloat,
        totalWidth: CGFloat
    ) -> some View {
        guard selectedDates.contains(where: { Calendar.current.isDateInToday($0) }) else {
            return AnyView(EmptyView())
        }

        let xPosition = timeLabelWidth - 65 // Adjust if needed based on actual text width
        let yPosition = yPositionForCurrentTime(currentDate: currentDate, hourHeight: hourHeight)

        return AnyView(
            HStack(alignment: .center, spacing: 0) {
                // Text with rounded rectangle
                Text(formattedTimeShort(currentDate))
                    .bold()
                    .foregroundColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.accentColor))))
                    .padding(.horizontal, 9) // Horizontal padding for spacing
                    .padding(.vertical, 4)    // Vertical padding for text
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(userPreferences.accentColor)
                    )
                    .fixedSize() // Ensures text and background size naturally

                // Line extending to the right
                Rectangle()
                    .fill(userPreferences.accentColor)
                    .frame(height: 2)
                    .layoutPriority(1) // Ensures the line extends and takes up the remaining space
            }
            .offset(x: xPosition, y: yPosition)
        )
    }
    
    
    @ViewBuilder
    private func dayColumns(calculatedDayColumnWidth: CGFloat, hourHeight: CGFloat) -> some View {
        ForEach(selectedDates, id: \.self) { date in
            dayColumnView(
                for: date,
                dayColumnWidth: calculatedDayColumnWidth,
                hourHeight: hourHeight
            )
        }
    }
    
    private func dayColumnHeader(
        for date: Date,
        dayColumnWidth: CGFloat) -> some View {
            Text(formattedDateString(for: date))
                .font(.caption)
                .foregroundColor(getIdealHeaderTextColor())
                .frame(height: 20)
                .frame(width: dayColumnWidth)
            
        }

    private func dayColumnView(
        for date: Date,
        dayColumnWidth: CGFloat,
        hourHeight: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            dayColumnHeader(for: date, dayColumnWidth: dayColumnWidth)
            ZStack(alignment: .topLeading) {
                VStack(spacing: 0) {
                    ForEach(0..<24) { hour in
                        hourBlock(hour: hour, hourHeight: hourHeight)
                    }
                    // Add padding at the bottom
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: hourHeight) // Extra space at the bottom
                }
                overlayDetails(
                    forDate: date,
                    dayColumnWidth: dayColumnWidth,
                    hourHeight: hourHeight
                )
            }
        }
        .frame(width: dayColumnWidth, alignment: .leading)
        .overlay(
            Rectangle()
                .fill(Color.gray)
                .frame(width: 1), // Thickness of the border
            alignment: .trailing // Position the border on the right edge
        )
    }
    
   

    private func timelineColumn(hourHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<24) { hour in
                hourRow(hour: hour, hourHeight: hourHeight)
            }
            // Add padding at the bottom
            Rectangle()
                .fill(Color.clear)
                .frame(height: hourHeight) // Extra space at the bottom
        }
        .frame(width: timeLabelWidth, alignment: .leading)
    }

    private func hourRow(hour: Int, hourHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            Text(formatHour(hour: hour))
                .frame(width: timeLabelWidth - 10, alignment: .leading)
                .padding(.leading, 8)
                .foregroundColor(getTextColor())
            Spacer()
        }
        .frame(height: hourHeight)
    }

    private func hourBlock(hour: Int, hourHeight: CGFloat) -> some View {
        Rectangle()
            .fill(hour % 2 == 0 ? Color.gray.opacity(0.1) : Color.clear)
            .frame(height: hourHeight)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray),
                alignment: .top
            )
    }

    private func overlayDetails(
        forDate date: Date,
        dayColumnWidth: CGFloat,
        hourHeight: CGFloat
    ) -> some View {
        let items = createEventItems(forDate: date, hourHeight: hourHeight)
        let positionedItems = calculateOverlaps(for: items, dayColumnWidth: dayColumnWidth)

        return ZStack(alignment: .topLeading) {
            ForEach(positionedItems) { item in
                item.contentView
                    .frame(width: item.width, height: item.height)
                    .offset(
                        x: item.xOffset,
                        y: item.positionY
                    )
            }
        }
    }
    
    private func entryRow(entry: Entry) -> some View {
        HStack {
            if entry.stampIndex != -1 {
                Image(systemName: entry.stampIcon)
                    .foregroundColor(getTextColor(entryBackgroundColor: entry.stampIndex == -1 ?  getEntryBackgroundColor() : Color(entry.color)))
            }

            Text(entryTitle(for: entry))
                .font(.caption)
                .foregroundColor(getTextColor(entryBackgroundColor: entry.stampIndex == -1 ?  getEntryBackgroundColor() : Color(entry.color)))
        }
        .padding(3)
        .background(entry.stampIndex == -1 ? getEntryBackgroundColor() : Color(entry.color))
        .cornerRadius(8)
    }

    
    private func reminderRow(reminder: EKReminder) -> some View {
        Group {
            if let dueDate = reminder.dueDateComponents?.date {
                HStack {
                    Image(systemName: reminder.isCompleted ? "bell.slash.fill" : "bell.fill")
                        .foregroundColor(userPreferences.reminderColor)
                    Text(getName(for: reminder.title))
                        .font(.caption)
                        .foregroundColor(getTextColor())
                    
                }
                .padding(3)
                .background(getEntryBackgroundColor())
                .cornerRadius(8)
            }
        }
    }

    private func eventRow(event: EKEvent) -> some View {
        HStack {
            Image(systemName: "calendar.badge.clock")
                .foregroundColor(userPreferences.accentColor)
            Text(getName(for: event.title ?? ""))
                .font(.caption)
                .foregroundColor(getTextColor())
        }
        .padding(3)
        .background(getEntryBackgroundColor())
        .cornerRadius(8)
    }

    private func createEventItems(
        forDate date: Date,
        hourHeight: CGFloat
    ) -> [EventItem] {
        var items: [EventItem] = []
        let defaultDuration: TimeInterval = 30 * 60 // 30 minutes
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        if let dayEntries = entries[date] {
            for entry in dayEntries {
                let entryStart = entry.time
                let entryEnd = entry.time.addingTimeInterval(defaultDuration)
                let duration = entryEnd.timeIntervalSince(entryStart)
                let durationInHours = duration / 3600
                let itemHeight = CGFloat(durationInHours) * hourHeight
                let positionY = positionForTime(entryStart, in: date, hourHeight: hourHeight)
                let contentView = AnyView(
                    entryRow(entry: entry)
                )
                let item = EventItem(
                    id: entry.id ?? UUID(),
                    startDate: entryStart,
                    endDate: entryEnd,
                    contentView: contentView,
                    positionY: positionY,
                    height: itemHeight
                )
                items.append(item)
            }
        }

        if let dayReminders = reminders[date] {
            for reminder in dayReminders {
                if let dueDate = reminder.dueDateComponents?.date {
                    let reminderStart = dueDate
                    let reminderEnd = dueDate.addingTimeInterval(defaultDuration)
                    let duration = reminderEnd.timeIntervalSince(reminderStart)
                    let durationInHours = duration / 3600
                    let itemHeight = CGFloat(durationInHours) * hourHeight
                    let positionY = positionForTime(reminderStart, in: date, hourHeight: hourHeight)
                    let contentView = AnyView(
                        reminderRow(reminder: reminder)
                    )
                    let item = EventItem(
                        id: UUID(),
                        startDate: reminderStart,
                        endDate: reminderEnd,
                        contentView: contentView,
                        positionY: positionY,
                        height: itemHeight
                    )
                    items.append(item)
                }
            }
        }

        if let dayEvents = events[date] {
            for event in dayEvents {
                let eventStart = max(event.startDate, startOfDay)
                let eventEnd = min(event.endDate, endOfDay)
                let duration = eventEnd.timeIntervalSince(eventStart)
                let durationInHours = duration / 3600
                let itemHeight = CGFloat(durationInHours) * hourHeight
                let positionY = positionForTime(eventStart, in: date, hourHeight: hourHeight)
                let contentView = AnyView(
                    eventRow(event: event)
                )
                let item = EventItem(
                    id: UUID(),
                    startDate: eventStart,
                    endDate: eventEnd,
                    contentView: contentView,
                    positionY: positionY,
                    height: itemHeight
                )
                items.append(item)
            }
        }

        return items.sorted { $0.startDate < $1.startDate }
    }

    private func calculateOverlaps(for items: [EventItem], dayColumnWidth: CGFloat) -> [PositionedEventItem] {
        var positionedItems: [PositionedEventItem] = []

        var groups: [[EventItem]] = []
        var currentGroup: [EventItem] = []
        var currentGroupEndDate: Date?

        let sortedItems = items.sorted { $0.startDate < $1.startDate }

        for item in sortedItems {
            if currentGroup.isEmpty {
                currentGroup.append(item)
                currentGroupEndDate = item.endDate
            } else {
                // Check if item overlaps with currentGroup
                if item.startDate < currentGroupEndDate! {
                    currentGroup.append(item)
                    // Update currentGroupEndDate if needed
                    if item.endDate > currentGroupEndDate! {
                        currentGroupEndDate = item.endDate
                    }
                } else {
                    // Process currentGroup
                    let groupPositionedItems = assignColumnsAndPositions(for: currentGroup, dayColumnWidth: dayColumnWidth)
                    positionedItems.append(contentsOf: groupPositionedItems)
                    // Start new group
                    currentGroup = [item]
                    currentGroupEndDate = item.endDate
                }
            }
        }
        // Process last group
        if !currentGroup.isEmpty {
            let groupPositionedItems = assignColumnsAndPositions(for: currentGroup, dayColumnWidth: dayColumnWidth)
            positionedItems.append(contentsOf: groupPositionedItems)
        }

        return positionedItems
    }

    private func assignColumnsAndPositions(for group: [EventItem], dayColumnWidth: CGFloat) -> [PositionedEventItem] {
        var positionedItems: [PositionedEventItem] = []
        var activeItems: [UUID] = []
        var columnAssignments: [UUID: Int] = [:]
        var itemDict: [UUID: EventItem] = [:]
        var maxColumns = 0

        for item in group.sorted(by: { $0.startDate < $1.startDate }) {
            itemDict[item.id] = item
            // Remove from activeItems items that have ended
            activeItems = activeItems.filter { itemDict[$0]?.endDate ?? Date.distantPast > item.startDate }
            let usedColumns = Set(activeItems.compactMap { columnAssignments[$0] })

            // Assign the lowest available column
            var column = 0
            while usedColumns.contains(column) {
                column += 1
            }
            columnAssignments[item.id] = column
            activeItems.append(item.id)
            maxColumns = max(maxColumns, column + 1)
        }

        // Now compute positions for each item in the group
        for item in group {
            let column = columnAssignments[item.id] ?? 0
            let itemWidth = dayColumnWidth / CGFloat(maxColumns)
            let itemX = CGFloat(column) * itemWidth
            let positionedItem = PositionedEventItem(
                id: item.id,
                contentView: item.contentView,
                positionY: item.positionY,
                xOffset: itemX,
                width: itemWidth,
                height: item.height
            )
            positionedItems.append(positionedItem)
        }

        return positionedItems
    }

    private func formattedDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: date)
    }




    // MARK: - Utility Functions

    private func yPositionForCurrentTime(currentDate: Date, hourHeight: CGFloat) -> CGFloat {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        let currentInterval = currentDate.timeIntervalSince(startOfDay)
        let hoursFromStart = currentInterval / 3600
        return CGFloat(hoursFromStart) * hourHeight + 20 // +20 to account for date label height
    }

    private func positionForTime(_ time: Date, in dayDate: Date, hourHeight: CGFloat) -> CGFloat {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: dayDate)
        let timeInterval = time.timeIntervalSince(startOfDay)
        let hoursFromStart = timeInterval / 3600
        return CGFloat(hoursFromStart) * hourHeight + 20 // +20 to account for date label height
    }

    private func formatHour(hour: Int) -> String {
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }

    private func entryTitle(for entry: Entry) -> String {
        if let title = entry.title, !title.isEmpty {
            return getName(for: title)
        } else if !entry.content.isEmpty {
            return getName(for: entry.content)
        } else {
            return "Untitled"
        }
    }

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
                reminders[date] = fetchedReminders.filter { reminder in
                    if let dueDate = reminder.dueDateComponents?.date {
                        return calendar.isDate(dueDate, inSameDayAs: date)
                    }
                    return false
                }
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
}

// MARK: - Helper Structures

struct EventItem: Identifiable {
    var id: UUID
    var startDate: Date
    var endDate: Date
    var contentView: AnyView
    var positionY: CGFloat
    var height: CGFloat
}

struct PositionedEventItem: Identifiable {
    var id: UUID
    var contentView: AnyView
    var positionY: CGFloat
    var xOffset: CGFloat
    var width: CGFloat
    var height: CGFloat
}
