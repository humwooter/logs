//
//  RemindersView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/22/24.
//
import SwiftUI
import EventKit
import Foundation
import CoreData


struct RemindersView: View, UserPreferencesProvider {
    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.reminderId, ascending: true)]
    ) var entries: FetchedResults<Entry>
    @Environment(\.colorScheme) var colorScheme
    
    @State private var reminders: [EKReminder] = []
    private let eventStore = EKEventStore()
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    
    @ObservedObject var reminderManager = ReminderManager()
    
    var body: some View {
        List {
            ForEach(reminders.filter {$0.isCompleted == false}, id: \.calendarItemIdentifier) { reminder in
                if let entry = entries.first(where: { $0.reminderId == reminder.calendarItemIdentifier }) {
                    if let reminderId = entry.reminderId, !reminderId.isEmpty {
                        Section {
                            reminderView(reminder: reminder, entry: entry)
                        }
                        .listRowBackground( UIColor.backgroundColor(entry: entry, colorScheme: colorScheme, userPreferences: userPreferences))
                        .swipeActions(edge: .leading) {
                            if let reminderId = entry.reminderId {
                                Button(action: {
                                    completeReminder(entry: entry, reminder: reminder, reminderId: reminderId)
                                }) {
                                        Label("Complete", systemImage: "checkmark.circle.fill")
                                    }
                                    .tint(userPreferences.accentColor)
                            }
                        }
                        
                        
                        .onAppear {
                            validateAndUpdateReminderStatus(for: entry, eventStore: eventStore)
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
    
    private func validateAndUpdateReminderStatus(for entry: Entry, eventStore: EKEventStore) {
        guard let reminderId = entry.reminderId, !reminderId.isEmpty else { return }
        
        // Check if the reminder exists
        if !reminderManager.reminderExists(with: reminderId) {  // Accessing reminderManager directly
            entry.reminderId = ""
        } else {
            // Check if the reminder is completed
            reminderManager.reminderIsComplete(reminderId: reminderId, eventStore: eventStore) { isCompleted in
                DispatchQueue.main.async {
                    if isCompleted {
                        entry.reminderId = ""
                    } else {
                        print("The reminder is not completed or does not exist.")
                    }
                    
                    // Save the updated entry
                    do {
                        try coreDataManager.viewContext.save()  // Accessing coreDataManager directly
                    } catch {
                        print("Failed to save viewContext: \(error)")
                    }
                }
            }
        }
    }



    private func completeReminder(entry: Entry, reminder: EKReminder, reminderId: String) {
        reminderManager.completeReminder(eventStore: eventStore, reminderId: reminderId) { success, error in
            if success {
                print("Reminder marked as completed.")
                if !reminder.hasRecurrenceRules {
                    entry.reminderId = ""
                } else {
                    reminder.isCompleted = true
                }
                do {
                    try coreDataManager.viewContext.save()
                } catch {
                    
                }
                // Optionally, update the UI or refresh the list to reflect the completion.
            } else if let error = error {
                print("Failed to complete the reminder: \(error.localizedDescription)")
            } else {
                print("Reminder not found or another issue occurred.")
            }
        }
    }
    func deleteReminders(from indexSet: IndexSet, reminders: [EKReminder]) {
        indexSet.forEach { index in
            let reminder = reminders[index]
            
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
        reminders = entries.compactMap { entry in
            guard let reminderId = entry.reminderId else { return nil }
            return fetchReminder(with: reminderId)
        }
        print("REMINDERS: \(reminders)")
        reminders.sort { ($0.dueDateComponents?.date ?? Date()) < ($1.dueDateComponents?.date ?? Date()) }
        print("REMINDERS: \(reminders)")
    }
    
    private func fetchReminder(with identifier: String) -> EKReminder? {
        eventStore.calendarItem(withIdentifier: identifier) as? EKReminder
    }
    
    private func formattedDueDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    private func overdueInformation(for date: Date) -> String {
        let currentDate = Date()
        let calendar = Calendar.current
        
        if currentDate > date {
            let daysOverdue = calendar.dateComponents([.day], from: date, to: currentDate).day ?? 0
            return daysOverdue == 0 ? "Overdue today" : "\(daysOverdue) day(s) overdue"
        } else {
            let daysUntilDue = calendar.dateComponents([.day], from: currentDate, to: date).day ?? 0
            return daysUntilDue == 0 ? "Due today" : "Due in \(daysUntilDue) day(s)"
        }
    }
    
    
    @ViewBuilder
    private func reminderView(reminder: EKReminder, entry: Entry) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Reminder Title and Date
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(reminder.title ?? "Untitled Reminder")
                            .font(.custom(userPreferences.fontName, size: userPreferences.fontSize)).bold()
                            .foregroundColor(getTextColorForEntry(entry: entry))
                        Spacer()
                        if reminder.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    
                    if let dueDate = reminder.dueDateComponents?.date {
                        Text("Due: \(dueDate, style: .date) \(dueDate, style: .time)")
                            .font(.customHeadline)
                            .foregroundColor(getTextColorForEntry(entry: entry).opacity(0.3))
                    }
                    
                    // Display recurrence information
                    if let recurrenceRule = reminder.recurrenceRules?.first {
                        HStack {
                            Image(systemName: "repeat")
                            Text("\(reminderManager.mapRecurrenceRuleToOption(recurrenceRule))")
                            Spacer()
                        }
                        .foregroundStyle(userPreferences.accentColor)
                        .font(.sectionHeaderSize)
                    }
                    
                }
            }
            
            .padding(.top, 5)
        }
        .padding()
    }
    
}
//
//    // Original functions for color handling
//    func getSectionColor(colorScheme: ColorScheme) -> Color {
//        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
//            return entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)
//        } else {
//            return userPreferences.entryBackgroundColor
//        }
//    }
//
//    func getTextColor(entry: Entry) -> Color {
//        // Retrieve the background colors from user preferences
//        let background1 = userPreferences.backgroundColors.first ?? Color.clear
//        let background2 = userPreferences.backgroundColors[1]
//        var entryBackground = userPreferences.entryBackgroundColor
//        if entry.stampIndex != -1 {
//            entryBackground = Color(entry.color)
//        }
//        // Call the calculateTextColor function with these values
//        return calculateTextColor(
//            basedOn: background1,
//            background2: background2,
//            entryBackground: entryBackground,
//            colorScheme: colorScheme
//        )
//    }
//
//    func getIdealHeaderTextColor() -> Color {
//        return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(userPreferences.backgroundColors.first ?? Color.clear), and: UIColor(userPreferences.backgroundColors[1])), colorScheme: colorScheme))
//    }
//}
