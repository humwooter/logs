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

    // Predefined sizes
    let timeLabelWidth: CGFloat = 70
    let hourHeight: CGFloat = 90
    let minDayColumnWidth: CGFloat = 200 // Minimum width for day columns

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Schedule View
                scheduleView()
            }
            .background(userPreferences.backgroundView(colorScheme: colorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Weekly calendar view in the navigation bar
                    ScrollableWeeklyScheduleView(
                        datesModel: datesModel,
                        selectionColor: userPreferences.accentColor,
                        backgroundColor: Color(UIColor.fontColor(forBackgroundColor: UIColor(getEntryBackgroundColor()))).opacity(0.05)
                    )
                    .environmentObject(userPreferences)
                    .frame(maxWidth: .infinity)
                    .onChange(of: datesModel.dates) { dates in
                        let newSelectedDates = dates.values.filter { $0.isSelected }
                            .compactMap { Calendar.current.date(from: $0.date) }
                            .sorted() // Ensure dates are in ascending order

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
                    }
                }
            }
        }
    }

    // Computed property for selected dates
    private var selectedDates: [Date] {
        datesModel.dates.values.filter { $0.isSelected }
            .compactMap { Calendar.current.date(from: $0.date) }
            .sorted() // Ensure dates are in ascending order
    }

    // MARK: - ViewBuilder Functions

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

    private func dayColumnView(
        for date: Date,
        dayColumnWidth: CGFloat,
        hourHeight: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(formattedDateString(for: date))
                .font(.caption)
                .foregroundColor(getIdealHeaderTextColor())
                .frame(height: 20)
                .frame(width: dayColumnWidth)
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

    private func entryRow(entry: Entry) -> some View {
        HStack {
            if entry.stampIndex != -1 {
                Image(systemName: entry.stampIcon)
                    .foregroundColor(Color(entry.color))
            }

            Text(entryTitle(for: entry))
                .font(.caption)
                .foregroundColor(getTextColor())
        }
        .padding(3)
        .background(getEntryBackgroundColor())
        .cornerRadius(8)
    }

    private func reminderRow(reminder: EKReminder) -> some View {
        Group {
            if let dueDate = reminder.dueDateComponents?.date {
                HStack {
                    Image(systemName: "bell.fill")
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
        HStack(spacing: 0) {
            Text(formatHour(hour: hour))
                .frame(width: timeLabelWidth - 10, alignment: .leading)
                .padding(.leading, 8)
                .foregroundColor(getTextColor())
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

    private func currentTimeIndicator(
        currentDate: Date,
        hourHeight: CGFloat,
        totalWidth: CGFloat
    ) -> some View {
        guard selectedDates.contains(where: { Calendar.current.isDateInToday($0) }) else {
            return AnyView(EmptyView())
        }

        let xPosition = timeLabelWidth
        let indicatorWidth = totalWidth - timeLabelWidth

        return AnyView(
            Rectangle()
                .fill(userPreferences.accentColor)
                .frame(width: indicatorWidth, height: 2)
                .offset(
                    x: xPosition,
                    y: yPositionForCurrentTime(currentDate: currentDate, hourHeight: hourHeight)
                )
        )
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
