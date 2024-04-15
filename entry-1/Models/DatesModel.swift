//
//  DatesModel.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 3/31/24.
//

import Foundation
import Foundation
import Combine
import CoreData

struct LogDate: Identifiable, Equatable {
    let id = UUID()  // Unique identifier for each LogDate
    var date: DateComponents
    var isSelected: Bool
    var hasLog = false
    
    static func ==(lhs: LogDate, rhs: LogDate) -> Bool {
        return lhs.date == rhs.date  // Equality based only on date, ignoring selection status
    }
}

class DatesModel: ObservableObject {
    @Published var startDate: Date = .distantPast
    @Published var endDate: Date = Date()
    
    var calendar = Calendar.current
    var timeZone = TimeZone.current
    
    @Published var dates: [LogDate] = {  // Changed to array for easier management of isSelected
        var list = [LogDate]()
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        list.append(LogDate(date: todayComponents, isSelected: true))  // Start with today not selected
        return list
    }()
    
    var bounds: Range<Date> {
        return startDate..<endDate
    }
    
    // Function to update the date range based on passed logs
    // Now accepting logs as a parameter
    func updateDateRange(with logs: [Log]) {
        print("ENTRED THIS updateDateRange")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        // Use the passed logs to compute the date range
        let dateLogs = logs.compactMap { logEntry -> Date? in
            return dateFormatter.date(from: logEntry.day)
        }
        
        print("DATE LOGS: \(dateLogs)")
        
        
        if let earliestDate = dateLogs.min(), let latestDate = dateLogs.max() {
            startDate = earliestDate
            // Adjust endDate to potentially include the whole last day
            endDate = Calendar.current.date(byAdding: .day, value: 1, to: latestDate) ?? latestDate
        }
        print("FINISHED")
        print("END DATE IS: \(endDate)")
    }
}
