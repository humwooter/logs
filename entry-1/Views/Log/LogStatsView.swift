//
//  LogStatsView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 4/27/24.
//

import Foundation
import SwiftUI
import CoreData
import Charts
import UIKit

struct StampData: Identifiable, Hashable {
    var id = UUID()
    var color: UIColor
    var label: String
    var name: String = ""
    var date: Date

    static func == (lhs: StampData, rhs: StampData) -> Bool {
        return lhs.id == rhs.id && lhs.label == rhs.label && lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(label)
        hasher.combine(name)
        // If color needs to be part of the identity, convert it to a hashable form
        hasher.combine(color.toHashable())
    }
}



struct LogData: Identifiable {
    var id = UUID()
    var day: String
    var date: Date
    var count: Int //number of entries for that day
    var stamp_counts: [StampData : Int]
}


struct LogStatsView: View {
    @State private var data: [LogData] = []
    @State var logs: [Log]
    @State var maxEntries = 0
    
    var body : some View {
        VStack {
                Chart(data) {
                    BarMark(
                        x: .value("day", formatToShortDateString(dateString: $0.day)),
                        y: .value("num entries", $0.count)
                    )
                }.scaledToFit()
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: 5)
                .chartYAxis{
                    AxisMarks(position: .leading)
                }
                .chartYScale(domain: [0, maxEntries+5])
                .chartXAxisLabel(position: .bottom, alignment: .center) {
                    Text("Date").bold()
                }
                .chartYAxisLabel(position: .leading, alignment: .center) {
                    Text("# of entries").bold()
                }
                
             
     
            
//
//            Chart {
//                      ForEach(data, id: \.id) { logData in
//                          ForEach(Array(logData.stamp_counts.keys).sorted(by: { $0.date < $1.date }), id: \.self) { stampData in
//                              BarMark(
//                                  x: .value("Time", stampData.date),
//                                  y: .value("Total Count", logData.stamp_counts[stampData] ?? 0),
//                                  stack: .byCategory
//                              )
//                              .foregroundStyle(stampData.uiColor)
//                          }
//                      }
//                  }
        }.onAppear {
            initializeData()
        }
        
    }
    
    
    func initializeData() {
        for log in logs {
            if let date = dateFromString(log.day){
                data.append(LogData(day: log.day, date: date, count: log.relationship.count, stamp_counts: calculateStampCounts(log: log)))
                maxEntries = max(maxEntries, log.relationship.count)
            }
        }
    }
    
    func calculateStampCounts(log: Log) -> [StampData : Int] {
        var stampsData: [StampData : Int] = [:]

        guard let entries = log.relationship.allObjects as? [Entry] else {
            print("Failed to cast relationship to [Entry]")
            return stampsData
        }

        for entry in entries {
            let stampData = StampData(color: entry.color, label: entry.stampIcon, date: entry.time)
            stampsData[stampData, default: 0] += 1
        }

        return stampsData
    }
}

func formatToShortDateString(dateString: String) -> String {
    // Create a DateFormatter to parse the input string
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "MM/dd/yyyy"
    inputFormatter.locale = Locale(identifier: "en_US_POSIX")  // Use a fixed locale to ensure consistent parsing

    // Convert the input string to a Date object
    guard let date = inputFormatter.date(from: dateString) else {
        return "Invalid Date"
    }

    // Create a DateFormatter to format the Date object into the desired output string
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "MMM d"  // "Oct 3, 2013" format
    outputFormatter.locale = Locale(identifier: "en_US")  // Locale for formatting output in English

    // Return the formatted date string
    return outputFormatter.string(from: date)
}
