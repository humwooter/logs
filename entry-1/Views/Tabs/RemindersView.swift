//
//  RemindersView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/22/24.
//
import SwiftUI
import EventKit

struct RemindersView: View {
    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.reminderId, ascending: true)]
    ) var entries: FetchedResults<Entry>
    @Environment(\.colorScheme) var colorScheme

    @State private var reminders: [String: EKReminder] = [:]
    private let eventStore = EKEventStore()
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager

    @ObservedObject var reminderManager = ReminderManager()

    var body: some View {
        List {
            ForEach(reminders.values.filter { !$0.isCompleted }, id: \.calendarItemIdentifier) { reminder in
                if let entry = entries.first(where: { $0.reminderId == reminder.calendarItemIdentifier }) {
                    if let reminderId = entry.reminderId, !reminderId.isEmpty {
                        Section {
                            reminderView(reminder: reminder, entry: entry)
                        }
                        .listRowBackground(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
                        .swipeActions(edge: .leading) {
                            if let reminderId = entry.reminderId {
                                Button(action: {
                                    completeReminder(reminderId: reminderId) { success, error in
                                        if success {
                                            print("Reminder marked as completed.")
                                            if !reminder.hasRecurrenceRules {
                                                entry.reminderId = ""
                                            } else {
                                                reminder.isCompleted = true
                                                if let updatedReminder = fetchReminder(with: reminderId) { reminders[reminderId] = updatedReminder } // Update the UI to reflect the completion.

                                            }
                                            do {
                                                try coreDataManager.viewContext.save()
                                            } catch {
                                                print("Failed to save viewContext: \(error)")
                                            }
                                        } else if let error = error {
                                            print("Failed to complete the reminder: \(error.localizedDescription)")
                                        } else {
                                            print("Reminder not found or another issue occurred.")
                                        }
                                    }
                                }) {
                                    Label("Complete", systemImage: "checkmark.circle.fill")
                                }
                                .tint(userPreferences.accentColor)
                            }
                        }
                        .onAppear {
                            if let reminderId = entry.reminderId, !reminderId.isEmpty {
                                if !reminderExists(with: reminderId) {
                                    entry.reminderId = ""
                                } else {
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
                    }
                }
            }
            .onDelete { indexSet in
                deleteReminders(from: indexSet, reminders: reminders)
            }
        }
        .scrollContentBackground(.hidden)
        .onAppear(perform: loadReminders)
        .navigationTitle("Reminders")
    }

    func deleteReminders(from indexSet: IndexSet, reminders: [String: EKReminder]) {
        indexSet.forEach { index in
            let reminder = Array(reminders.values)[index]
            
            // Delete the reminder from the EventStore
            reminderManager.deleteReminder(reminder: reminder)
            
            // Find and delete the corresponding Entry from Core Data
            if let entry = entries.first(where: { $0.reminderId == reminder.calendarItemIdentifier }) {
                entry.reminderId = ""
            }
        }
        
        do {
            // Save the Core Data context after deletion
            try coreDataManager.viewContext.save()
            // Reload the reminders to reflect changes
            loadReminders()
        } catch {
            print("Failed to save context after deletion: \(error)")
        }
    }

    private func loadReminders() {
        reminders = Dictionary(uniqueKeysWithValues: entries.compactMap { entry in
            guard let reminderId = entry.reminderId, let reminder = fetchReminder(with: reminderId) else { return nil }
            return (reminderId, reminder)
        })
    }

    private func fetchReminder(with identifier: String) -> EKReminder? {
        eventStore.calendarItem(withIdentifier: identifier) as? EKReminder
    }

    @ViewBuilder
    private func reminderView(reminder: EKReminder, entry: Entry) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(reminder.title ?? "Untitled Reminder")
                        .font(.headline)
                        .foregroundColor(getTextColor(entry: entry))
                    Spacer()
                    if reminder.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                if let dueDate = reminder.dueDateComponents?.date {
                    Text("Due: \(dueDate, style: .date) \(dueDate, style: .time)")
                        .font(.subheadline)
                        .foregroundColor(getTextColor(entry: entry).opacity(0.7))
                } else {
                    Text("No due date")
                        .font(.subheadline)
                        .foregroundColor(getTextColor(entry: entry).opacity(0.7))
                }
                
                // Display recurrence information
                if let recurrenceRule = reminder.recurrenceRules?.first {
                    HStack {
                        Image(systemName: "repeat")
                        Text("\(mapRecurrenceRuleToString(recurrenceRule))")
                        Spacer()
                    }
                    .foregroundStyle(userPreferences.accentColor)
                    .font(.subheadline)
                }
            }
            Spacer()
            // Days until due date display
            if let dueDate = reminder.dueDateComponents?.date {
                let daysUntilDue = daysUntilDueDate(dueDate)
                VStack {
                    Text("\(abs(daysUntilDue))")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(daysUntilDue < 0 ? .red : userPreferences.reminderColor)
                    Text(daysUntilDue < 0 ? "days overdue" : "days left")
                        .font(.caption)
                        .foregroundColor(daysUntilDue < 0 ? .red : userPreferences.reminderColor)
                }
            } else {
                VStack {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No due date")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }

    private func daysUntilDueDate(_ date: Date?) -> Int {
        guard let date = date else {
            // If there's no due date, we can assign a high number to sort it at the end
            return Int.max
        }
        let currentDate = Date()
        let calendar = Calendar.current
        let startOfCurrentDate = calendar.startOfDay(for: currentDate)
        let startOfDueDate = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: startOfCurrentDate, to: startOfDueDate)
        return components.day ?? 0
    }

    private func mapRecurrenceRuleToString(_ rule: EKRecurrenceRule) -> String {
        switch rule.frequency {
        case .daily:
            return "Daily"
        case .weekly:
            if rule.daysOfTheWeek?.contains(where: { $0.dayOfTheWeek == .saturday || $0.dayOfTheWeek == .sunday }) == true {
                return "Weekends"
            }
            return "Weekly"
        case .monthly:
            return "Monthly"
        default:
            return "Custom"
        }
    }

    func getTextColor(entry: Entry) -> Color {
        // Retrieve the background colors from user preferences
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        var entryBackground = userPreferences.entryBackgroundColor
        if entry.stampIndex != -1 {
            entryBackground = Color(entry.color)
        }
        // Call the calculateTextColor function with these values
        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme
        )
    }
}
