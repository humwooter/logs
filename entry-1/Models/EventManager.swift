//
//  EventManager.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/1/24.
//

import Foundation
import EventKit

class EventManager: ObservableObject {
    @Published var eventTitle: String = ""
    @Published var selectedDate: Date = Date()
    @Published var selectedTime: Date = Date()
    @Published var eventId: String?
    @Published var hasEventAccess: Bool = false

    private let eventStore = EKEventStore()

    func requestEventAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                self.hasEventAccess = granted
                completion(granted)
            }
        }
    }

    func createOrUpdateEvent(completion: @escaping (Bool) -> Void) {
        let combinedDateTime = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: selectedTime), minute: Calendar.current.component(.minute, from: selectedTime), second: 0, of: selectedDate) ?? Date()

        requestEventAccess { granted in
            guard granted else {
                completion(false)
                return
            }

            if let eventId = self.eventId, self.eventExists(with: eventId) {
                self.editAndSaveEvent(eventId: eventId, title: self.eventTitle.isEmpty ? "Event" : self.eventTitle, date: combinedDateTime) { success in
                    completion(success)
                }
            } else {
                self.createAndSaveEvent(title: self.eventTitle.isEmpty ? "Event" : self.eventTitle, date: combinedDateTime) { success in
                    completion(success)
                }
            }
        }
    }

    private func eventExists(with identifier: String) -> Bool {
        return eventStore.calendarItem(withIdentifier: identifier) as? EKEvent != nil
    }

    private func editAndSaveEvent(eventId: String, title: String, date: Date, completion: @escaping (Bool) -> Void) {
        guard let event = eventStore.calendarItem(withIdentifier: eventId) as? EKEvent else {
            completion(false)
            return
        }

        event.title = title
        event.startDate = date
        event.endDate = date.addingTimeInterval(3600) // 1 hour event

        saveEvent(event, completion: completion)
    }

    private func createAndSaveEvent(title: String, date: Date, completion: @escaping (Bool) -> Void) {
        let event = EKEvent(eventStore: eventStore)
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.title = title
        event.startDate = date
        event.endDate = date.addingTimeInterval(3600) // 1 hour event

        saveEvent(event, completion: completion)
    }

    private func saveEvent(_ event: EKEvent, completion: @escaping (Bool) -> Void) {
        do {
            try eventStore.save(event, span: .thisEvent, commit: true)
            eventId = event.eventIdentifier
            completion(true)
        } catch {
            completion(false)
        }
    }

    func fetchAndInitializeEventDetails(eventId: String?, completion: @escaping () -> Void) {
        guard let eventId = eventId, !eventId.isEmpty else {
            completion()
            return
        }

        eventStore.requestAccess(to: .event) { granted, error in
            guard granted, error == nil else {
                print("Access to events denied or failed.")
                completion()
                return
            }

            DispatchQueue.main.async {
                if let event = self.eventStore.calendarItem(withIdentifier: eventId) as? EKEvent {
                    self.eventTitle = event.title ?? ""
                    self.selectedDate = event.startDate
                    self.selectedTime = event.startDate
                }
                completion()
            }
        }
    }
}
