//
//  ReminderManager.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/1/24.
//

import Foundation
import EventKit

class ReminderManager: ObservableObject {
    private let eventStore = EKEventStore()
    
    @Published var hasReminderAccess: Bool = false
    @Published var reminderTitle: String = ""
    @Published var selectedReminderDate: Date = Date()
    @Published var selectedReminderTime: Date = Date()
    @Published var selectedRecurrence: String = "None"
    
    let recurrenceOptions = ["None", "Daily", "Weekly", "Weekends", "Biweekly", "Monthly"]
    
    init() {
        checkReminderAccess()
    }
    
    private func checkReminderAccess() {
        switch EKEventStore.authorizationStatus(for: .reminder) {
        case .authorized:
            hasReminderAccess = true
        case .notDetermined:
            requestReminderAccess { granted in
                // Handle the result of the access request
                if granted {
                    self.hasReminderAccess = true
                } else {
                    self.hasReminderAccess = false
                }
            }
        default:
            hasReminderAccess = false
        }
    }

    
    func requestReminderAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .reminder) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.hasReminderAccess = granted
                completion(granted)
            }
        }
    }
    
    func createOrUpdateReminder(reminderId: String? = nil, title: String, dueDate: Date, recurrence: String, notes: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard hasReminderAccess else {
            completion(.failure(ReminderError.accessDenied))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let reminder = self.fetchOrCreateReminder(with: reminderId)
            reminder.title = title.isEmpty ? "Reminder" : title
            reminder.notes = notes
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            reminder.recurrenceRules = [self.createRecurrenceRule(fromOption: recurrence)].compactMap { $0 }
            
            do {
                try self.eventStore.save(reminder, commit: true)
                DispatchQueue.main.async {
                    completion(.success(reminder.calendarItemIdentifier))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchReminder(reminderId: String, completion: @escaping (Result<EKReminder, Error>) -> Void) {
        guard hasReminderAccess else {
            completion(.failure(ReminderError.accessDenied))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            if let reminder = self.eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
                DispatchQueue.main.async {
                    completion(.success(reminder))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(ReminderError.reminderNotFound))
                }
            }
        }
    }
    
    // Updated deleteReminder function to match the request
    func deleteReminder(reminder: EKReminder) {
        do {
            try eventStore.remove(reminder, commit: true)
            print("Reminder deleted successfully.")
        } catch {
            print("Failed to delete the reminder: \(error.localizedDescription)")
        }
    }
    
    // Updated editReminder function to match the request
    func editReminder(reminder: EKReminder) {
        fetchAndInitializeReminderDetails(reminderId: reminder.calendarItemIdentifier)
        
        createOrUpdateReminder(
            reminderId: reminder.calendarItemIdentifier,
            title: reminderTitle,
            dueDate: selectedReminderDate,
            recurrence: selectedRecurrence,
            notes: reminder.notes ?? ""
        ) { result in
            switch result {
            case .success(let reminderId):
                print("Reminder updated successfully with ID: \(reminderId).")
            case .failure(let error):
                print("Failed to update the reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteReminder(reminderId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard hasReminderAccess else {
            completion(.failure(ReminderError.accessDenied))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            if let reminder = self.eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
                do {
                    try self.eventStore.remove(reminder, commit: true)
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(ReminderError.reminderNotFound))
                }
            }
        }
    }
    
    func fetchAndInitializeReminderDetails(reminderId: String) {
        fetchReminder(reminderId: reminderId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let reminder):
                DispatchQueue.main.async {
                    self.reminderTitle = reminder.title ?? ""
                    if let dueDate = reminder.dueDateComponents?.date {
                        self.selectedReminderDate = dueDate
                        self.selectedReminderTime = dueDate
                    }
                    self.selectedRecurrence = self.mapRecurrenceRuleToOption(reminder.recurrenceRules?.first)
                }
            case .failure(let error):
                print("Failed to fetch reminder details: \(error)")
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
    
    func mapRecurrenceRuleToOption(_ rule: EKRecurrenceRule?) -> String {
        guard let rule = rule else { return "None" }
        
        switch rule.frequency {
        case .daily:
            return "Daily"
        case .weekly:
            if rule.daysOfTheWeek?.contains(where: { $0.dayOfTheWeek == .saturday || $0.dayOfTheWeek == .sunday }) == true {
                return "Weekends"
            }
            return rule.interval == 1 ? "Weekly" : "Biweekly"
        case .monthly:
            return "Monthly"
        default:
            return "None"
        }
    }
}

enum ReminderError: Error {
    case accessDenied
    case reminderNotFound
}
