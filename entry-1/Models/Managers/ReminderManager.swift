//
//  ReminderManager.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/1/24.
//

import Foundation
import EventKit
import SwiftUI

var eventStore = EKEventStore()

class ReminderManager: ObservableObject {
    //    @Published var eventStore: EKEventStore
    
    @Published var hasReminderAccess: Bool = false
    @Published var reminderTitle: String = ""
    @Published var notes: String = ""
    @Published var selectedReminderDate: Date = Date()
    @Published var selectedReminderTime: Date = Date()
    @Published var selectedRecurrence: String = "None"
    
    let recurrenceOptions = ["None", "Daily", "Weekly", "Weekends", "Biweekly", "Monthly"]
    
    init() {
        if !hasReminderAccess {
            checkReminderAccess(eventStore: eventStore)
        }
    }
    
    func createRecurrenceRule(fromOption option: String) -> EKRecurrenceRule? {
        switch option {
        case "Daily":
            return EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)
        case "Weekly":
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil)
        case "Weekends":
            let rule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, daysOfTheWeek: [EKRecurrenceDayOfWeek(.saturday), EKRecurrenceDayOfWeek(.sunday)], daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: nil)
            return rule
        case "Biweekly":
            return EKRecurrenceRule(recurrenceWith: .weekly, interval: 2, end: nil)
        case "Monthly":
            return EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)
        default:
            return nil
        }
    }
    
    
    
    func checkReminderAccess(eventStore: EKEventStore) {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        
        switch status {
        case .authorized:
            print("Reminder access already authorized.")
            self.hasReminderAccess = true
            
        case .notDetermined:
            print("Reminder access not determined. Requesting access...")
            requestReminderAccess(eventStore: eventStore) { granted in
                if granted {
                    print("Reminder access granted.")
                    self.hasReminderAccess = true
                } else {
                    print("Reminder access denied.")
                    self.hasReminderAccess = false
                }
            }
            
        default:
            print("Reminder access denied or restricted. Cannot proceed.")
            self.hasReminderAccess = false
        }
    }
    
    func completeReminder(eventStore: EKEventStore, reminderId: String, completion: @escaping (Bool, Error?) -> Void) {
        
        eventStore.requestFullAccessToReminders { granted, error in
            guard granted, error == nil else {
                completion(false, error)
                return
            }
            
            guard let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder else {
                completion(false, nil) // No reminder found with the given ID.
                return
            }
            
            reminder.isCompleted = true
            
            do {
                try eventStore.save(reminder, commit: true)
                completion(true, nil) // Successfully marked the reminder as completed.
            } catch let error {
                completion(false, error) // Failed to mark the reminder as completed.
            }
        }
    }
    
    func reminderIsComplete(reminderId: String, eventStore: EKEventStore, completion: @escaping (Bool) -> Void) {
        eventStore.requestFullAccessToReminders { granted, error in
            guard granted, error == nil else {
                completion(false)
                return
            }
            
            if let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
                completion(reminder.isCompleted)
            } else {
                completion(false) // Reminder not found or access not granted
            }
        }
    }
    
    private func requestReminderAccess(eventStore: EKEventStore, completion: @escaping (Bool) -> Void) {
        eventStore.requestFullAccessToReminders { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.hasReminderAccess = granted
                completion(granted)
            }
        }
    }
    
    
    func editAndSaveReminder(reminderId: String?, title: String, dueDate: Date, recurrenceOption: String, completion: @escaping (Bool, String?) -> Void) {
        
        requestReminderAccess(eventStore: eventStore) { granted in
            if granted {
                
                var reminder: EKReminder
                if let reminderId = reminderId, let existingReminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
                    reminder = existingReminder
                } else {
                    reminder = EKReminder(eventStore: eventStore)
                    reminder.calendar = eventStore.defaultCalendarForNewReminders()
                }
                
                reminder.title = title
                reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
                if let recurrenceRule = self.createRecurrenceRule(fromOption: recurrenceOption) {
                    reminder.recurrenceRules = [recurrenceRule] // Replace existing rules with the new one
                }
                
                do {
                    try eventStore.save(reminder, commit: true)
                    DispatchQueue.main.async {
                        completion(true, reminder.calendarItemIdentifier)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false, nil)
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
                return
            }
        }
    }
        
        
        func createAndSaveReminder(title: String, dueDate: Date, recurrenceOption: String, completion: @escaping (Bool, String?) -> Void) {
            
            // Request access to reminders.
            requestReminderAccess(eventStore: eventStore) { granted in
                if granted {
                    let reminder = EKReminder(eventStore: eventStore)
                    reminder.calendar = eventStore.defaultCalendarForNewReminders()
                    reminder.title = title
                    reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
                    
                    // Set recurrence rule if applicable
                    if let recurrenceRule = self.createRecurrenceRule(fromOption: recurrenceOption) {
                        reminder.addRecurrenceRule(recurrenceRule)
                    }
                    
                    // Try to save the reminder
                    do {
                        try eventStore.save(reminder, commit: true)
                        completion(true, reminder.calendarItemIdentifier) // Return success and the reminder identifier
                    } catch {
                        completion(false, nil) // Return failure
                    }
                } else {
                    // Handle the case where permission is not granted
                    completion(false, nil)
                }
            }
        }
        
        
        
        func createOrUpdateReminder(reminderId: String? = nil, completion: @escaping (Result<String, Error>) -> Void) {
            guard hasReminderAccess else {
                completion(.failure(ReminderError.accessDenied))
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                let reminder = self.fetchOrCreateReminder(with: reminderId)
                reminder.title = self.reminderTitle.isEmpty ? "Reminder" : self.reminderTitle
                reminder.notes = self.notes
                reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.selectedReminderDate)
                reminder.recurrenceRules = [self.createRecurrenceRule(fromOption: self.selectedRecurrence)].compactMap { $0 }
                
                do {
                    try eventStore.save(reminder, commit: true)
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
        
        
        func fetchOrCreateReminder(with identifier: String?) -> EKReminder {
           if let identifier = identifier, let existingReminder = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder {
               return existingReminder
           } else {
               let newReminder = EKReminder(eventStore: eventStore)
               newReminder.calendar = eventStore.defaultCalendarForNewReminders()
               return newReminder
           }
       }
       
       func fetchReminders(startDate: Date, endDate: Date, completion: @escaping (Result<[EKReminder], Error>) -> Void) {
           guard hasReminderAccess else {
               completion(.failure(ReminderError.accessDenied))
               return
           }
           
           let predicate = eventStore.predicateForReminders(in: nil)
           
           eventStore.fetchReminders(matching: predicate) { reminders in
               guard let reminders = reminders else {
                   completion(.failure(ReminderError.reminderNotFound))
                   return
               }
               
               let filteredReminders = reminders.filter { reminder in
                   guard let dueDate = reminder.dueDateComponents?.date else { return false }
                   print("DUE DATE: \(dueDate)")
                   return (dueDate >= startDate && dueDate < endDate)
               }
               
               completion(.success(reminders))
           }
       }
        
        func fetchReminder(reminderId: String, completion: @escaping (Result<EKReminder, Error>) -> Void) {
            guard hasReminderAccess else {
                completion(.failure(ReminderError.accessDenied))
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                //            guard let self = self else { return }
                
                if let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
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
            
            self.createOrUpdateReminder(reminderId: reminder.calendarItemIdentifier) { result in
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
                
                if let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
                    do {
                        try eventStore.remove(reminder, commit: true)
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
        
      
        
        
      
        
        //     func createRecurrenceRule(fromOption option: String) -> EKRecurrenceRule? {
        //        let recurrenceRules: [String: EKRecurrenceRule] = [
        //            "Daily": EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil),
        //            "Weekly": EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil),
        //            "Weekends": EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, daysOfTheWeek: [EKRecurrenceDayOfWeek(.saturday), EKRecurrenceDayOfWeek(.sunday)], daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: nil),
        //            "Biweekly": EKRecurrenceRule(recurrenceWith: .weekly, interval: 2, end: nil),
        //            "Monthly": EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)
        //        ]
        //        return recurrenceRules[option]
        //    }
        
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
        
        func reminderExists(with identifier: String) -> Bool {
            if let _ = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder {
                return true
            } else {
                return false
            }
        }
        
    }

enum ReminderError: Error {
    case accessDenied
    case reminderNotFound
}
