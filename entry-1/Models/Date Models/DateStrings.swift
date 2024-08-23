//
//  DateStrings.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 4/15/24.
//

import Foundation


class DateStrings {
    // This dictionary stores arrays of date strings, keyed by month in "MM/yyyy" format.
    private var dateDictionary: [String: [String]] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    init() {
        // Initialize the dictionary by loading stored data from UserDefaults.
        self.dateDictionary = DateStrings.loadFromUserDefaults()
    }
    
    // Save the current state of `dateDictionary` to UserDefaults.
    private func saveToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(dateDictionary) {
            UserDefaults.standard.set(encoded, forKey: "dateDictionary")
        }
    }
    
    // Load the dictionary from UserDefaults.
    private static func loadFromUserDefaults() -> [String: [String]] {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "dateDictionary"),
           let decoded = try? decoder.decode([String: [String]].self, from: data) {
            return decoded
        }
        return [:] // Return an empty dictionary if nothing was stored previously.
    }
    
    // Adds a new date string to the dictionary under the appropriate month.
    func addDate(_ dateString: String) {
        guard let monthYearKey = monthYear(from: dateString) else { return }
        
        var dates = dateDictionary[monthYearKey, default: []]
        if !dates.contains(dateString) {
            dates.append(dateString)
            dateDictionary[monthYearKey] = dates
        }
    }
    
    func removeDate(_ dateString: String) {
        guard let monthYearKey = monthYear(from: dateString) else { return }

        // Check if there are dates stored for the month-year key and remove the specific date
        if var dates = dateDictionary[monthYearKey] {
            if let index = dates.firstIndex(of: dateString) {
                dates.remove(at: index)  // Remove the date from the array
                // If the array is empty after removal, decide whether to remove the key or keep an empty array
                if dates.isEmpty {
                    dateDictionary.removeValue(forKey: monthYearKey)
                } else {
                    dateDictionary[monthYearKey] = dates  // Update the dictionary with the new array
                }
            }
        }
    }

    
    // Utility to extract "MM/yyyy" from "MM/dd/yyyy".
     func monthYear(from dateString: String) -> String? {
        let components = dateString.split(separator: "/")
        guard components.count == 3 else { return nil }
        return "\(components[0])/\(components[2])" // Assuming dateString is in the format "MM/dd/yyyy"
    }
    
    // Retrieve dates for a specific month and year.
    func dates(forMonthYear monthYear: String) -> [String]? {
        return dateDictionary[monthYear]
    }
    
    // Check if a specific dateString exists in the dictionary.
        func containsDate(_ dateString: String) -> Bool {
            guard let monthYearKey = monthYear(from: dateString) else { return false }
            return dateDictionary[monthYearKey]?.contains(dateString) ?? false
        }
}
