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
import UniformTypeIdentifiers



@MainActor
struct LogsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var selectedTimeframe: String = "By Day"
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker: Bool = false
    
    @State private var isExporting = false
    @State private var pdfURL: URL?
    @State private var pdfData: Data?
    
    
    @State private var showingDeleteConfirmation = false
    @State private var logToDelete: Log?
    @State private var selectedDates: Set<DateComponents> = []
    
    
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: false)]
    ) var logs: FetchedResults<Log>
    
    @State private var startDate: Date = .distantPast

    @State private var endDate: Date = Date() // Current day
    var calendar = Calendar.current
    var timeZone = TimeZone.current

    var bounds: Range<Date> {
        return startDate..<endDate
    }

    @State private var dates: Set<DateComponents> = {
        var set = Set<DateComponents>()
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            set.insert(todayComponents)
        
        return set
    }()
    
    
    func updateDateRange() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let dateLogs = logs.compactMap { dateFormatter.date(from: $0.day) }
        
        if let earliestDate = dateLogs.min(),
           let latestDate = dateLogs.max() {
            startDate = earliestDate
            endDate = latestDate
        }
    }
    
    
    // LogsView
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Timeframe", selection: $selectedTimeframe) {
                    Text("By Day").tag("By Day")
                    //                    Text("By Week").tag("By Week")
                    Text("By Month").tag("By Month")
                    //                    Text("By Date").tag("By Date")
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
                        .alert(isPresented: $showingDeleteConfirmation) {
                            Alert(title: Text("Delete log"),
                                  message: Text("Are you sure you want to delete this log? This action cannot be undone."),
                                  primaryButton: .destructive(Text("Delete")) {
                                deleteLog(log: logToDelete)
                            },
                                  secondaryButton: .cancel())
                        }
                        NavigationLink(destination: RecentlyDeletedView().environmentObject(coreDataManager).environmentObject(userPreferences)) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Recently Deleted")
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
                        .alert(isPresented: $showingDeleteConfirmation) {
                            Alert(title: Text("Delete log"),
                                  message: Text("Are you sure you want to delete this log? This action cannot be undone."),
                                  primaryButton: .destructive(Text("Delete")) {
                                deleteLog(log: logToDelete)
                            },
                                  secondaryButton: .cancel())
                        }
                        NavigationLink(destination: RecentlyDeletedView().environmentObject(coreDataManager).environmentObject(userPreferences)) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Recently Deleted")
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("Logs")
                    
                }
                
                
                else {
            
                    List {
                        if selectedTimeframe == "By Date" {
                            //                            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                            MultiDatePicker("Dates Available", selection: $dates, in: bounds)
                            
                        }
                        
        
                        if selectedTimeframe == "By Day" {
                            Section(header: Text("Dates")) {
//                                Text("word")
                                MultiDatePicker("Dates Available", selection: $dates, in: bounds).datePickerStyle(.automatic).foregroundColor(.green)
                                    .foregroundColor(Color.complementaryColor(of: userPreferences.accentColor))
                                    .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                                    .accentColor(Color.complementaryColor(of: userPreferences.accentColor))
                            }
                            
                        }
                        



                        ForEach(filteredLogs(), id: \.self) { log in
                            NavigationLink(destination: LogDetailView(log: log).environmentObject(userPreferences)) {
                                HStack {
                                    Image(systemName: "book.fill")
                                        .foregroundColor(userPreferences.accentColor)
                                    Text(log.day)
                                }
                            }
                            .contextMenu {
                                Button(role: .destructive, action: {
                                    showingDeleteConfirmation = true
                                    logToDelete = log
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .alert(isPresented: $showingDeleteConfirmation) {
                            Alert(title: Text("Delete log"),
                                  message: Text("Are you sure you want to delete this log? This action cannot be undone."),
                                  primaryButton: .destructive(Text("Delete")) {
                                deleteLog(log: logToDelete)
                            },
                                  secondaryButton: .cancel())
                        }
                        
                        NavigationLink(destination: RecentlyDeletedView().environmentObject(coreDataManager).environmentObject(userPreferences)) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Recently Deleted")
                            }
                        }
                        
                    }
                    
                    .listStyle(.automatic)
                    .navigationTitle("Logs")
                }
            }.font(.system(size: userPreferences.fontSize))
            
                .fileExporter(isPresented: $isExporting, document: PDFDocument(pdfURL: pdfURL), contentType: .pdf) { result in
                    switch result {
                    case .success(let url):
                        print("File successfully saved at \(url)")
                    case .failure(let error):
                        print("Failed to save file: \(error)")
                    }
                }
        }
    }
    
    func DatePickerView(date: Binding<Date>, title: String) -> some View {
        List {
            DatePicker("Start Date", selection: date, displayedComponents: .date)
        }
        .navigationTitle(title)
    }
    
    
    func filteredLogs() -> [Log] {
        print("Entered filtered logs!")
        print("All logs: \(logs)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        
        var filtered: [Log] = []
        
        switch selectedTimeframe {
        case "By Day":
            return logs.filter { log in
                guard let logDate = dateFormatter.date(from: log.day) else { return false }
                for dateComponent in dates {
                    if let selectedDate = calendar.date(from: dateComponent) {
                        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
                        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) ?? selectedDate
                        if logDate >= startOfDay && logDate <= endOfDay {
                            return true
                        }
                    }
                }
                return false
            }
            
            
            
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
    
    
    
    private func deleteLog(log: Log?) {
        guard let log = log else { return }
        if let entries = log.relationship as? Set<Entry> {
            for entry in entries {
                //                coreDataManager.viewContext.delete(entry)
                deleteEntry(entry: entry, coreDataManager: coreDataManager)
                
                
            }
        }
        coreDataManager.viewContext.delete(log)
        
        do {
            try coreDataManager.viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func createPDFData(size: CGSize, logs: [Log]) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Your App",
            kCGPDFContextAuthor: "Your Name"
        ]
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, pdfMetaData)
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else {
            return pdfData as Data
        }
        
        for log in logs {
            UIGraphicsBeginPDFPageWithInfo(CGRect(origin: .zero, size: size), nil)
            let renderer = UIGraphicsImageRenderer(size: size)
            let img = renderer.image { ctx in
                let uiView = UIHostingController(rootView: LogDetailView_PDF(userPreferences: userPreferences, log: log)).view
                uiView?.drawHierarchy(in: uiView!.bounds, afterScreenUpdates: true)
            }
            img.draw(in: CGRect(origin: .zero, size: size))
        }
        
        UIGraphicsEndPDFContext()
        return pdfData as Data
    }
    
    
    func render() async -> URL {
        let logsByDay = Dictionary(grouping: filteredLogs(), by: { $0.day })
        let sortedDays = logsByDay.keys.sorted()
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("output.pdf")
        
        let renderer = UIGraphicsPDFRenderer(bounds: .zero)
        
        do {
            try renderer.writePDF(to: url) { context in
                for day in sortedDays {
                    let logsForDay = logsByDay[day]!
                    
                    for log in logsForDay {
                        // Estimate height based on total number of entries per log
                        let estimatedHeightPerEntry: CGFloat = 300
                        let totalHeight = estimatedHeightPerEntry * CGFloat(log.relationship.count)
                        print("Total height: \(totalHeight)")
                        
                        // Split content into multiple pages if total height exceeds a certain limit
                        let pageLimit: CGFloat = 14000 // Adjust this value based on your content
                        let numberOfPages = ceil(totalHeight / pageLimit)
                        
                        for page in 0..<Int(numberOfPages) {
                            let pageHeight = min(pageLimit, totalHeight - CGFloat(page) * pageLimit)
                            
                            context.beginPage(withBounds: CGRect(x: 0, y: 0, width: 612, height: pageHeight), pageInfo: [:])
                            
                            let content = LogDetailView_PDF(userPreferences: userPreferences, log: log)
                            
                            let hostingController = UIHostingController(rootView: content)
                            hostingController.view.bounds = CGRect(origin: .zero, size: CGSize(width: 612, height: pageHeight))
                            hostingController.view.backgroundColor = .clear
                            
                            hostingController.view.setNeedsLayout()
                            hostingController.view.layoutIfNeeded()
                            
                            let targetRect = CGRect(x: 0, y: 0, width: 612, height: pageHeight)
                            hostingController.view.drawHierarchy(in: targetRect, afterScreenUpdates: true)
                        }
                    }
                }
            }
        } catch {
            print("Failed to write PDF: \(error)")
        }
        
        return url
    }
}




struct LogsByWeekView: View {
    var logs: [Log]
    var week: String
    @EnvironmentObject var userPreferences: UserPreferences
    
    
    var body: some View {
        List(logs, id: \.self) { log in
            NavigationLink(destination: LogDetailView(log: log)) {
                HStack {
                    Image(systemName: "book")
                        .foregroundColor(userPreferences.accentColor)
                    Text(log.day)
                }
            }
        }
        .navigationTitle("Week of \(week)")
        .font(.system(size: userPreferences.fontSize))
        
    }
}
struct LogsByMonthView: View {
    var logs: [Log]
    var month: String
    @EnvironmentObject var userPreferences: UserPreferences
    
    var body: some View {
        List(logs, id: \.self) { log in
            NavigationLink(destination: LogDetailView(log: log)) {
                HStack {
                    Image(systemName: "book")
                        .foregroundColor(userPreferences.accentColor)
                    Text(log.day)
                }            }
        }
        .navigationTitle("\(month)")
        .font(.system(size: userPreferences.fontSize))
    }
}





