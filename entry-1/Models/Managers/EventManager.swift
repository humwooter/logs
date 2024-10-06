//
//  EventManager.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/1/24.
//

import Foundation
import EventKit

class EventManager: ObservableObject {
    private let eventStore = EKEventStore()
    
    @Published var hasEventAccess: Bool = false
    
    init() {
        checkEventAccess()
    }
    
    // check the current access status for events
    private func checkEventAccess() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            hasEventAccess = true
        case .notDetermined:
            requestEventAccess { granted in
                // handle the result of the access request
                if granted {
                    self.hasEventAccess = true
                } else {
                    self.hasEventAccess = false
                }
            }
        default:
            hasEventAccess = false
        }
    }
    
    // request access to the user's calendar events
    func requestEventAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.hasEventAccess = granted
                completion(granted)
            }
        }
    }
    
    // create a new event or update an existing one
    func createOrUpdateEvent(eventId: String? = nil, title: String, startDate: Date, endDate: Date, notes: String?, completion: @escaping (Result<String, Error>) -> Void) {
        guard hasEventAccess else {
            completion(.failure(EventError.accessDenied))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let event = self.fetchOrCreateEvent(with: eventId)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.notes = notes
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            
            do {
                try self.eventStore.save(event, span: .thisEvent, commit: true)
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
    
    // fetch an existing event by its identifier
    func fetchEvent(eventId: String, completion: @escaping (Result<EKEvent, Error>) -> Void) {
        guard hasEventAccess else {
            completion(.failure(EventError.accessDenied))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            if let event = self.eventStore.event(withIdentifier: eventId) {
                DispatchQueue.main.async {
                    completion(.success(event))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(EventError.eventNotFound))
                }
            }
        }
    }
    
    func fetchEvents(startDate: Date, endDate: Date, completion: @escaping (Result<[EKEvent], Error>) -> Void) {
        guard hasEventAccess else {
            completion(.failure(EventError.accessDenied))
            return
        }

        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let events = self.eventStore.events(matching: predicate)
            
            DispatchQueue.main.async {
                if events.isEmpty {
                    completion(.failure(EventError.eventNotFound))
                } else {
                    completion(.success(events))
                }
            }
        }
    }

    
    // delete an existing event
    func deleteEvent(eventId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard hasEventAccess else {
            completion(.failure(EventError.accessDenied))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            if let event = self.eventStore.event(withIdentifier: eventId) {
                do {
                    try self.eventStore.remove(event, span: .thisEvent, commit: true)
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
    
    // check if an event exists
    func eventExists(with identifier: String) -> Bool {
        if let _ = eventStore.event(withIdentifier: identifier) {
            return true
        } else {
            return false
        }
    }
    
    // return the calendar an event belongs to
    func getCalendar(for eventId: String, completion: @escaping (Result<EKCalendar, Error>) -> Void) {
        guard hasEventAccess else {
            completion(.failure(EventError.accessDenied))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            if let event = self.eventStore.event(withIdentifier: eventId) {
                DispatchQueue.main.async {
                    completion(.success(event.calendar))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(EventError.eventNotFound))
                }
            }
        }
    }
    
    // fetch or create a new event based on the identifier
    private func fetchOrCreateEvent(with identifier: String?) -> EKEvent {
        if let identifier = identifier, let existingEvent = eventStore.event(withIdentifier: identifier) {
            return existingEvent
        } else {
            return EKEvent(eventStore: eventStore)
        }
    }
}

// custom error enum for event management
enum EventError: Error {
    case accessDenied
    case eventNotFound
}
