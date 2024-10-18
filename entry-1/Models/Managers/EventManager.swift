//  EventManager.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/1/24.
//
import Foundation
import EventKit

/// Manages events using EventKit
class EventManager: ObservableObject {
    /// The Event Store instance for accessing events
//    @Published var eventStore: EKEventStore

    // MARK: - Published Properties
    
    /// Indicates whether the app has access to events
    @Published var hasEventAccess: Bool = false
    
    /// The title of the event
    @Published var eventTitle: String = ""
    
    /// The start date of the event
    @Published var selectedEventStartDate: Date = Date()
    
    /// The end date of the event
    @Published var selectedEventEndDate: Date = Date()
    
    /// Notes for the event
    @Published var eventNotes: String = ""
    
    /// Available calendars for events
    @Published var calendars: [EKCalendar] = []
    
    /// The selected calendar for the event
    @Published var selectedCalendar: EKCalendar?
    
    // MARK: - Initialization
    
    init() {
        checkEventAccess()
    }
    
    // MARK: - Access Control
    
    /// Checks the current authorization status for events
    private func checkEventAccess() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            hasEventAccess = true
            fetchEventCalendars()
        case .notDetermined:
            requestEventAccess { granted in
                if granted {
                    self.hasEventAccess = true
                    self.fetchEventCalendars()
                } else {
                    self.hasEventAccess = false
                }
            }
        default:
            hasEventAccess = false
        }
    }
    
    /// Requests access to events
    func requestEventAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.hasEventAccess = granted
                if granted {
                    self?.fetchEventCalendars()
                }
                completion(granted)
            }
        }
    }
    
    // MARK: - Calendar Management
    
    /// Fetches available calendars for events
    func fetchEventCalendars() {
        calendars = eventStore.calendars(for: .event)
        if let defaultCalendar = eventStore.defaultCalendarForNewEvents {
            selectedCalendar = defaultCalendar
        } else {
            selectedCalendar = calendars.first
        }
    }
    
    // MARK: - Event Creation and Updating
    
    /// Creates or updates an event
    func createOrUpdateEvent(eventId: String? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        guard hasEventAccess else {
            completion(.failure(EventError.accessDenied))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let event = self.fetchOrCreateEvent(with: eventId)
            event.title = self.eventTitle
            event.startDate = self.selectedEventStartDate
            event.endDate = self.selectedEventEndDate
            event.notes = self.eventNotes
            event.calendar = self.selectedCalendar ?? entry_1.eventStore.defaultCalendarForNewEvents
            
            do {
                // Save the event
                try entry_1.eventStore.save(event, span: .thisEvent, commit: true)
                DispatchQueue.main.async {
                    completion(.success(event.eventIdentifier))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Fetches an existing event or creates a new one if it doesn't exist
    private func fetchOrCreateEvent(with identifier: String?) -> EKEvent {
        if let identifier = identifier, let existingEvent = eventStore.event(withIdentifier: identifier) {
            return existingEvent
        } else {
            let newEvent = EKEvent(eventStore: eventStore)
            newEvent.calendar = selectedCalendar ?? eventStore.defaultCalendarForNewEvents
            return newEvent
        }
    }
    
    // MARK: - Event Fetching
    
    /// Fetches events within a specified date range
    func fetchEvents(startDate: Date, endDate: Date, completion: @escaping (Result<[EKEvent], Error>) -> Void) {
        guard hasEventAccess else {
            completion(.failure(EventError.accessDenied))
            return
        }
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let events = entry_1.eventStore.events(matching: predicate)
            DispatchQueue.main.async {
                if events.isEmpty {
                    completion(.failure(EventError.eventNotFound))
                } else {
                    completion(.success(events))
                }
            }
        }
    }
    
    // MARK: - Event Deletion
    
    /// Deletes an event by its identifier
    func deleteEvent(eventId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard hasEventAccess else {
            completion(.failure(EventError.accessDenied))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let event = entry_1.eventStore.event(withIdentifier: eventId) {
                do {
                    try entry_1.eventStore.remove(event, span: .thisEvent, commit: true)
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
                    completion(.failure(EventError.eventNotFound))
                }
            }
        }
    }
    
    // MARK: - Utility Methods
    
    /// Checks if an event exists with the given identifier
    func eventExists(with identifier: String) -> Bool {
        if let _ = eventStore.event(withIdentifier: identifier) {
            return true
        } else {
            return false
        }
    }
}

enum EventError: Error {
    case accessDenied
    case eventNotFound
}
