//
//  ReminderFuncs.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 3/24/24.
//
//
//import Foundation
//import Foundation
//import CoreData
//import SwiftUI
//import EventKit
//
//
//func reminderExists(eventStore: EKEventStore, with identifier: String) -> Bool {
//    if let _ = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder {
//        print("reminder does exist")
//        return true
//    } else {
//        print("reminder doesn't exist")
//        return false
//    }
//}
//
//func reminderIsComplete(eventStore: EKEventStore, reminderId: String, completion: @escaping (Bool) -> Void) {
//    
//    eventStore.requestAccess(to: .reminder) { granted, error in
//        guard granted, error == nil else {
//            completion(false)
//            return
//        }
//        
//        if let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
//            completion(reminder.isCompleted)
//        } else {
//            completion(false) // Reminder not found or access not granted
//        }
//    }
//}
//
//func completeReminder(eventStore: EKEventStore, reminderId: String, completion: @escaping (Bool, Error?) -> Void) {
//    
//    eventStore.requestAccess(to: .reminder) { (granted, error) in
//        guard granted, error == nil else {
//            completion(false, error)
//            return
//        }
//        
//        guard let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder else {
//            completion(false, nil) // No reminder found with the given ID.
//            return
//        }
//        
//        reminder.isCompleted = true
//        
//        do {
//            try eventStore.save(reminder, commit: true)
//            completion(true, nil) // Successfully marked the reminder as completed.
//        } catch let error {
//            completion(false, error) // Failed to mark the reminder as completed.
//        }
//    }
//}
//
//func deleteReminder(eventStore: EKEventStore, reminderId: String?) {
//    if let reminderId = reminderId, !reminderId.isEmpty {
//        eventStore.requestFullAccessToReminders { granted, error in
//            guard granted, error == nil else {
//                print("Access to reminders denied or failed: \(String(describing: error))")
//                return
//            }
//            
//            DispatchQueue.main.async {
//                if let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
//                    do {
//                        try eventStore.remove(reminder, commit: true)
//                        print("Reminder successfully deleted")
//                    } catch {
//                        print("Failed to delete reminder: \(error)")
//                    }
//                }
//            }
//        }
//    }
//}
