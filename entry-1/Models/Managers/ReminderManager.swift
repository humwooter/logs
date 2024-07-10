//
//  ReminderManager.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/1/24.
//

import Foundation
import EventKit

class ReminderManager: ObservableObject {
    @Published var reminderTitle: String = ""
    @Published var selectedDate: Date = Date()
    @Published var selectedTime: Date = Date()
    @Published var selectedRecurrence: String = "None"
    @Published var reminderId: String?
    @Published var hasReminderAccess: Bool = false
    @Published var showingReminderSheet: Bool = false

    let recurrenceOptions = ["None", "Daily", "Weekly", "Weekends", "Biweekly", "Monthly"]

    private let eventStore = EKEventStore()

    func requestReminderAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .reminder) { granted, error in
            DispatchQueue.main.async {
                self.hasReminderAccess = granted
                completion(granted)
            }
        }
    }

    func createOrUpdateReminder(completion: @escaping (Bool) -> Void) {
        let combinedDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: selectedTime), minute: Calendar.current.component(.minute, from: selectedTime), second: 0, of: selectedDate) ?? Date()

        requestReminderAccess { granted in
            guard granted else {
                completion(false)
                return
            }

            if let reminderId = self.reminderId, self.reminderExists(with: reminderId) {
                self.editAndSaveReminder(reminderId: reminderId, title: self.reminderTitle.isEmpty ? "Reminder" : self.reminderTitle, dueDate: combinedDateTime, recurrenceOption: self.selectedRecurrence) { success in
                    completion(success)
                }
            } else {
                self.createAndSaveReminder(title: self.reminderTitle.isEmpty ? "Reminder" : self.reminderTitle, dueDate: combinedDateTime, recurrenceOption: self.selectedRecurrence) { success in
                    completion(success)
                }
            }
        }
    }

    private func reminderExists(with identifier: String) -> Bool {
        return eventStore.calendarItem(withIdentifier: identifier) as? EKReminder != nil
    }

    private func editAndSaveReminder(reminderId: String, title: String, dueDate: Date, recurrenceOption: String, completion: @escaping (Bool) -> Void) {
        guard let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder else {
            completion(false)
            return
        }

        reminder.title = title
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        reminder.recurrenceRules = [createRecurrenceRule(fromOption: recurrenceOption)].compactMap { $0 }

        saveReminder(reminder, completion: completion)
    }

    private func createAndSaveReminder(title: String, dueDate: Date, recurrenceOption: String, completion: @escaping (Bool) -> Void) {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        reminder.title = title
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        reminder.recurrenceRules = [createRecurrenceRule(fromOption: recurrenceOption)].compactMap { $0 }

        saveReminder(reminder, completion: completion)
    }

    private func saveReminder(_ reminder: EKReminder, completion: @escaping (Bool) -> Void) {
        do {
            try eventStore.save(reminder, commit: true)
            reminderId = reminder.calendarItemIdentifier
            completion(true)
        } catch {
            completion(false)
        }
    }

    private func createRecurrenceRule(fromOption option: String) -> EKRecurrenceRule? {
        switch option {
        case "Daily":
            return EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)
        case "Weekly":
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil)
        case "Weekends":
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, daysOfTheWeek: [EKRecurrenceDayOfWeek(.saturday), EKRecurrenceDayOfWeek(.sunday)], daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: nil)
        case "Biweekly":
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 2, end: nil)
        case "Monthly":
            return EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)
        default:
            return nil
        }
    }

    func fetchAndInitializeReminderDetails(reminderId: String?, completion: @escaping () -> Void) {
        guard let reminderId = reminderId, !reminderId.isEmpty else {
            completion()
            return
        }

        eventStore.requestAccess(to: .reminder) { granted, error in
            guard granted, error == nil else {
                print("Access to reminders denied or failed.")
                completion()
                return
            }

            DispatchQueue.main.async {
                if let reminder = self.eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
                    self.reminderTitle = reminder.title ?? ""
                    if let dueDate = reminder.dueDateComponents?.date {
                        self.selectedDate = dueDate
                        self.selectedTime = dueDate
                    }
                    self.selectedRecurrence = self.mapRecurrenceRuleToOption(reminder.recurrenceRules?.first)
                }
                completion()
            }
        }
    }
    
    

    private func mapRecurrenceRuleToOption(_ rule: EKRecurrenceRule?) -> String {
        guard let rule = rule else { return "None" }

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
            return "None"
        }
    }
}
