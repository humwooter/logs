//
//  LogViews.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
//
//

import Foundation
import SwiftUI
import CoreData

struct LogsView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @EnvironmentObject var userPreferences: UserPreferences
//
//    @FetchRequest(
//        entity: Log.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)]
//    ) var logs: FetchedResults<Log>

//    var body: some View {
//        NavigationView {
//            List(logs, id: \.self) { log in
//                NavigationLink(destination: LogDetailView(log: log).environmentObject(userPreferences)) {
//                    Text(log.day)
//                }
//            }
//            .navigationTitle("Logs")
//        }
//    }
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var selectedTimeframe: String = "By Day"
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker: Bool = false

    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)]
    ) var logs: FetchedResults<Log>
    
    // LogsView
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Timeframe", selection: $selectedTimeframe) {
                    Text("By Day").tag("By Day")
                    Text("By Week").tag("By Week")
                    Text("By Month").tag("By Month")
                    Text("By Date").tag("By Date")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical)

                if selectedTimeframe == "By Week" {
                    List {
                        ForEach(weeksGrouped().keys.sorted(), id: \.self) { week in
                            NavigationLink(destination: LogsByWeekView(logs: weeksGrouped()[week]!, week: week)) {
                                Text("Week of \(week)")
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("Logs")
                } else if selectedTimeframe == "By Month" {
                    List {
                        ForEach(monthsGrouped().keys.sorted(), id: \.self) { month in
                            NavigationLink(destination: LogsByMonthView(logs: monthsGrouped()[month]!, month: month)) {
                                Text("Month of \(month)")
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("Logs")
                }
                
                
                else {
                    List {
                        if selectedTimeframe == "By Date" {
                            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        }
                        
                        ForEach(filteredLogs(), id: \.self) { log in
                            NavigationLink(destination: LogDetailView(log: log).environmentObject(userPreferences)) {
                                Text(log.day)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("Logs")
                }
            }
        }
    }
    
    func filteredLogs() -> [Log] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        var filtered: [Log] = []

        switch selectedTimeframe {
        case "By Day":
            // Return all logs as they are already sorted by day in FetchRequest
            filtered = Array(logs)
            
        case "By Week":
            // Filter logs by the current week
            let currentWeekStart = startOfWeek(for: Date())
            filtered = logs.filter {
                guard let logDate = dateFormatter.date(from: $0.day) else { return false }
                let logWeekStart = startOfWeek(for: logDate)
                return logWeekStart == currentWeekStart
            }

        case "By Month":
            // Filter logs by the current month
            let currentMonthStart = startOfMonth(for: Date())
            filtered = logs.filter {
                guard let logDate = dateFormatter.date(from: $0.day) else { return false }
                let logMonthStart = startOfMonth(for: logDate)
                return logMonthStart == currentMonthStart
            }

        case "By Date":
            // Filter logs by selected date
            filtered = logs.filter {
                guard let logDate = dateFormatter.date(from: $0.day) else { return false }
                return Calendar.current.isDate(logDate, inSameDayAs: selectedDate)
            }
            
        default:
            // Default logic, return all logs
            filtered = Array(logs)
        }

        return filtered
    }

    func startOfWeek(for date: Date) -> Date {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Optional, set first weekday as Monday
        return cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
    }

    func startOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
    }



    func weeksGrouped() -> [String: [Log]] {
        var weeks: [String: [Log]] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        logs.forEach { log in
            guard let logDate = dateFormatter.date(from: log.day) else { return }
            let weekStart = startOfWeek(for: logDate)

            let weekStr = dateFormatter.string(from: weekStart)

            weeks[weekStr, default: []].append(log)
        }
        return weeks
    }
    

    func monthsGrouped() -> [String: [Log]] {
        var months: [String: [Log]] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let monthDateFormatter = DateFormatter()
        monthDateFormatter.dateFormat = "MMMM YYYY"

        logs.forEach { log in
            guard let logDate = dateFormatter.date(from: log.day) else { return }
            let monthStart = startOfMonth(for: logDate)

            let monthStr = monthDateFormatter.string(from: monthStart)

            months[monthStr, default: []].append(log)
        }
        return months
    }


//   func startOfWeek(for date: Date) -> Date {
//       var cal = Calendar.current
//       cal.firstWeekday = 2 // Optional, set first weekday as Monday
//       return cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
//   }

}




struct LogsByWeekView: View {
    var logs: [Log]
    var week: String
    
    var body: some View {
        List(logs, id: \.self) { log in
            NavigationLink(destination: LogDetailView(log: log)) {
                Text(log.day)
            }
        }
        .navigationTitle("Week of \(week)")
    }
}
struct LogsByMonthView: View {
    var logs: [Log]
    var month: String
    
    var body: some View {
        List(logs, id: \.self) { log in
            NavigationLink(destination: LogDetailView(log: log)) {
                Text(log.day)
            }
        }
        .navigationTitle("\(month)")
    }
}






struct LogDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme

    let log: Log

    var body: some View {
        if let entries = log.relationship as? Set<Entry>, !entries.isEmpty {
            List(entries.sorted(by: { $0.time > $1.time }), id: \.self) { entry in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(formattedTime(entry.time))
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                Spacer()
                                if (entry.buttons.filter{$0}.count > 0 ) {
                                    Image(systemName: entry.image).tag(entry.image)
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(backgroundColor(entry: entry))
//                                        .foregroundStyle(.red, .green, .blue, .purple)
                                }
                                
                            }
                            Text(entry.content)
                                .fontWeight(entry.buttons.filter{$0}.count > 0 ? .bold : .regular)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        Spacer() // Push the image to the right
        
                    }

                    
                    
                    if entry.imageContent != "" {
                        if let filename = entry.imageContent {
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let fileURL = documentsDirectory.appendingPathComponent(filename)
                            let data = try? Data(contentsOf: fileURL)
                            
                            
                            if let data = data, isGIF(data: data) {

                              let imageView = AnimatedImageView(url: fileURL)
                              
                                let asyncImage = UIImage(data: data)
                              
                                let height = asyncImage!.size.height
                              
                                AnimatedImageView(url: fileURL).scaledToFit()


                              // Add imageView
                            } else {
                                AsyncImage(url: fileURL) { image in
                                    image.resizable()
                                        .scaledToFit()
                                }
                            placeholder: {
                                ProgressView()
                            }
                            }
                        }
                    }
                }
//                .listRowBackground(backgroundColor(entry: entry))
            }
            .listStyle(.automatic)

            .navigationBarTitleDisplayMode(.inline)
        } else {
            Text("No entries available")
                .foregroundColor(.gray)
        }
    }
    private func foregroundColor(entry: Entry, background: UIColor) -> Color {
        let color = colorScheme == .dark ? Color.white : Color.black
        if (entry.buttons.filter{$0}.count == 0) { //not marked
            return color
        }
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        background.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let brightness = (red * 299 + green * 587 + blue * 114) / 1000

        return brightness > 0.5 ? Color.black : Color.white
    }
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

//    private func backgroundColor(entry: Entry) -> Color {
//        let color: UIColor
//        let opacity_val = colorScheme == .dark ? 0.95 : 0.75
//        if entry.buttons[0] {
//            color = UIColor(userPreferences.selectedColors[0])
//            entry.color = UIColor(Color(color).opacity(opacity_val))
//        } else if entry.buttons[1] {
//            color = UIColor(userPreferences.selectedColors[1])
//            entry.color = UIColor(Color(color).opacity(opacity_val))
//        } else if entry.buttons[2] {
//            color = UIColor(userPreferences.selectedColors[2])
//            entry.color = UIColor(Color(color).opacity(opacity_val))
//        } else {
//            color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
//            entry.color = colorScheme == .dark ? UIColor(Color.white) : UIColor(Color.black)
//            return Color(color)
//        }
//        return Color(entry.color)
//    }
    private func backgroundColor(entry: Entry) -> Color {
        let opacity_val = colorScheme == .dark ? 0.95 : 0.75

        for index in 0..<entry.buttons.count {
            if entry.buttons[index] {
//                let color = UIColor(userPreferences.selectedColors[index])
//                entry.color = UIColor(Color(color).opacity(opacity_val))
                if (entry.color == nil) {
                    entry.color = UIColor(userPreferences.selectedColors[index])
                }
                return Color(entry.color)
            }
        }

        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
        entry.color = colorScheme == .dark ? UIColor(Color.white) : UIColor(Color.black)
        return Color(color)
    }

}
