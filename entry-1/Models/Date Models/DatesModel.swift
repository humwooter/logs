//
//  DatesModel.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 3/31/24.
//
import Foundation
import Combine
import CoreData

struct LogDate: Identifiable, Equatable {
    let id = UUID()  // unique identifier for each LogDate
    var date: DateComponents
    var isSelected: Bool
    var hasLog = false
    
    static func ==(lhs: LogDate, rhs: LogDate) -> Bool {
        return lhs.date == rhs.date  // equality based only on date, ignoring selection status
    }
}

class DatesModel: ObservableObject {
    @Published var startDate: Date = .distantPast
    @Published var endDate: Date = Date()
    
    var calendar = Calendar.current
    var timeZone = TimeZone.current
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    @Published var dates: [String: LogDate] = {
        var dict = [String: LogDate]()
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let todayString = DateFormatter().string(from: Calendar.current.date(from: todayComponents)!)
        dict[todayString] = LogDate(date: todayComponents, isSelected: true)
        return dict
    }()
    
    var bounds: Range<Date> {
        return startDate..<endDate
    }
    
    func updateDateRange(with logs: [Log]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let dateLogs = logs.compactMap { logEntry -> Date? in
            return dateFormatter.date(from: logEntry.day)
        }
        
        if let earliestDate = dateLogs.min(), let latestDate = dateLogs.max() {
            startDate = earliestDate
            endDate = Calendar.current.date(byAdding: .day, value: 1, to: latestDate) ?? latestDate
        }
        
        updateDatesArray(with: dateLogs)
    }
    
    func updateDateRange(with entries: [Entry]) {
        let dateTimes = entries.compactMap { $0.time }
        
        if let earliestDate = dateTimes.min(), let latestDate = dateTimes.max() {
            startDate = calendar.startOfDay(for: earliestDate)
            endDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: latestDate)) ?? latestDate
        }
        
        updateDatesArray(with: dateTimes)
    }
    
    private func updateDatesArray(with dateTimes: [Date]) {
        var dateSet = Set<DateComponents>()
        
        for date in dateTimes {
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            dateSet.insert(dateComponents)
        }
        
        dates = dateSet.reduce(into: [String: LogDate]()) { dict, dateComponents in
            let hasLog = dateTimes.contains { calendar.isDate($0, inSameDayAs: calendar.date(from: dateComponents)!) }
            if let date = calendar.date(from: dateComponents) {
                let formattedDate = dateFormatter.string(from: date)
                dict[formattedDate] = LogDate(date: dateComponents, isSelected: false, hasLog: hasLog)
            }
        }
    }
    
    func addDate(for entry: Entry) {
//        guard let date = entry.time else { return }
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: entry.time)
        
        if let date = calendar.date(from: dateComponents) {
            let formattedDate = dateFormatter.string(from: date)
            if dates[formattedDate] == nil {
                let logDate = LogDate(date: dateComponents, isSelected: false, hasLog: true)
                dates[formattedDate] = logDate
            }
        }
    }
    
    
    
    func removeDate(for entry: Entry) {
//        guard let date = entry.time else { return }
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: entry.time)
        
        if let date = calendar.date(from: dateComponents) {
            let formattedDate = dateFormatter.string(from: date)
            dates.removeValue(forKey: formattedDate)
        }
    }
    
    // Helper method to check if a date exists
    func doesDateExist(_ date: Date) -> Bool {
        let formattedDate = dateFormatter.string(from: date)
        return dates[formattedDate] != nil
    }
    
    // Helper method to check if a date is selected
    func isDateSelected(_ date: Date) -> Bool {
        let formattedDate = dateFormatter.string(from: date)
        return dates[formattedDate]?.isSelected ?? false
    }
    
    // Method to add today's date if it doesn't exist
    func addTodayIfNotExists() {
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        if let todayDate = calendar.date(from: todayComponents) {
            if !doesDateExist(todayDate) {
                let formattedDate = dateFormatter.string(from: todayDate)
                dates[formattedDate] = LogDate(date: todayComponents, isSelected: true)
            }
        }
    }
    
    func addDateIfNotExists(dateString: String) {
           guard let date = dateFormatter.date(from: dateString) else { return }
           let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
           
           if !dates.keys.contains(dateString) {
               dates[dateString] = LogDate(date: dateComponents, isSelected: false, hasLog: true)
           }
       }
}


extension DatesModel {
    // Method to select a specific date
    func select(date: Date) {
        // Convert date to components
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        // Convert date to formatted string
        let formattedDate = dateFormatter.string(from: calendar.date(from: dateComponents)!)
        
        // Check if the date already exists
        if let logDate = dates[formattedDate] {
            // If it exists, update isSelected to true
            dates[formattedDate] = LogDate(date: logDate.date, isSelected: true, hasLog: logDate.hasLog)
        } else {
            // If the date doesn't exist, add it as a new LogDate and select it
            let newLogDate = LogDate(date: dateComponents, isSelected: true)
            dates[formattedDate] = newLogDate
        }
        
        // Notify observers of the change
        objectWillChange.send()
    }

    // Method to deselect a specific date
    func deselect(date: Date) {
        // Convert date to components
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        // Convert date to formatted string
        let formattedDate = dateFormatter.string(from: calendar.date(from: dateComponents)!)
        
        // Check if the date exists and is selected
        if let logDate = dates[formattedDate], logDate.isSelected {
            // Deselect the date by updating isSelected to false
            dates[formattedDate] = LogDate(date: logDate.date, isSelected: false, hasLog: logDate.hasLog)
        }
        
        // Notify observers of the change
        objectWillChange.send()
    }
}
