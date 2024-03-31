//
//  ReminderFuncs.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 3/24/24.
//

import Foundation
import Foundation
import CoreData
import SwiftUI
import EventKit


func reminderExists(with identifier: String) -> Bool {
    let eventStore = EKEventStore()
    if let _ = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder {
        return true
    } else {
        return false
    }
}

func reminderIsComplete(reminderId: String, completion: @escaping (Bool) -> Void) {
    let eventStore = EKEventStore()
    
    eventStore.requestAccess(to: .reminder) { granted, error in
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

func completeReminder(reminderId: String, completion: @escaping (Bool, Error?) -> Void) {
    let eventStore = EKEventStore()
    
    eventStore.requestAccess(to: .reminder) { (granted, error) in
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

func deleteReminder(reminderId: String?) {
    if let reminderId = reminderId, !reminderId.isEmpty {
        let eventStore = EKEventStore() // Initialize EKEventStore to work with reminders
        eventStore.requestFullAccessToReminders { granted, error in
            guard granted, error == nil else {
                print("Access to reminders denied or failed: \(String(describing: error))")
                return
            }
            
            DispatchQueue.main.async {
                if let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
                    do {
                        try eventStore.remove(reminder, commit: true)
                        print("Reminder successfully deleted")
                    } catch {
                        print("Failed to delete reminder: \(error)")
                    }
                }
            }
        }
    }
}
