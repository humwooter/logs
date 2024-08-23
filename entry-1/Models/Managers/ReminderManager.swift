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

            let reminder = self.fetchOrCreateReminder(with: self.reminderId)
            reminder.title = self.reminderTitle.isEmpty ? "Reminder" : self.reminderTitle
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: combinedDateTime)
            reminder.recurrenceRules = [self.createRecurrenceRule(fromOption: self.selectedRecurrence)].compactMap { $0 }

            self.saveReminder(reminder) { success in
                if success {
                    self.reminderId = reminder.calendarItemIdentifier
                }
                completion(success)
            }
        }
    }

    private func fetchOrCreateReminder(with identifier: String?) -> EKReminder {
        if let identifier = identifier, let existingReminder = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder {
            return existingReminder
        } else {
            let newReminder = EKReminder(eventStore: eventStore)
            newReminder.calendar = eventStore.defaultCalendarForNewReminders()
            return newReminder
        }
    }

    private func createRecurrenceRule(fromOption option: String) -> EKRecurrenceRule? {
        let recurrenceRules: [String: EKRecurrenceRule] = [
            "Daily": EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil),
            "Weekly": EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil),
            "Weekends": EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, daysOfTheWeek: [EKRecurrenceDayOfWeek(.saturday), EKRecurrenceDayOfWeek(.sunday)], daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: nil),
            "Biweekly": EKRecurrenceRule(recurrenceWith: .weekly, interval: 2, end: nil),
            "Monthly": EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)
        ]
        return recurrenceRules[option]
    }

     func saveReminder(_ reminder: EKReminder, completion: @escaping (Bool) -> Void) {
        do {
            try eventStore.save(reminder, commit: true)
            completion(true)
        } catch {
            completion(false)
        }
    }

    func fetchAndInitializeReminderDetails(reminderId: String?, completion: @escaping () -> Void) {
        guard let reminderId = reminderId, !reminderId.isEmpty else {
            completion()
            return
        }

        requestReminderAccess { granted in
            guard granted else {
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

        if rule.frequency == .daily {
            return "Daily"
        } else if rule.frequency == .weekly {
            if rule.daysOfTheWeek?.contains(where: { $0.dayOfTheWeek == .saturday || $0.dayOfTheWeek == .sunday }) == true {
                return "Weekends"
            }
            return "Weekly"
        } else if rule.frequency == .monthly {
            return "Monthly"
        } else {
            return "None"
        }
    }
}
