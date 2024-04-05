//
//  DatesModel.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 3/31/24.
//

import Foundation
import Foundation
import Combine

class DatesModel: ObservableObject {
    @Published var startDate: Date = .distantPast
    @Published var endDate: Date = Date()
    
    var calendar = Calendar.current
    var timeZone = TimeZone.current
    
    @Published var dates: Set<DateComponents> = {
        var set = Set<DateComponents>()
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        set.insert(todayComponents)
        
        return set
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
    
//    func updateDateRange(with logs: [Log]) {
//        print("ENTERED THIS updateDateRange")
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        
//        var newDatesSet = Set<DateComponents>()
//        
//        // Use the passed logs to compute the date range and update dates Set
//        let dateLogs = logs.compactMap { logEntry -> Date? in
//            return dateFormatter.date(from: logEntry.day)
//        }
//        
//        for date in dateLogs {
//            let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
//            newDatesSet.insert(components)
//        }
//        
//        if let earliestDate = dateLogs.min(), let latestDate = dateLogs.max() {
//            startDate = earliestDate
//            // Adjust endDate to potentially include the whole last day
//            endDate = Calendar.current.date(byAdding: .day, value: 1, to: latestDate) ?? latestDate
//        }
//        
//        // Update the dates Set
//        DispatchQueue.main.async {
//            self.dates = newDatesSet
//        }
//        print("FINISHED updating date range and dates Set")
//    }
}
