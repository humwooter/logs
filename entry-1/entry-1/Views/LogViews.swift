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


//func deleteEntry(entry: Entry, coreDataManager: CoreDataManager) {
//    let mainContext = coreDataManager.viewContext
//    mainContext.performAndWait {
//        let filename = entry.imageContent
//        let parentLog = entry.relationship
//
//        // Fetch the entry in the main context
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
//        do {
//            let fetchedEntries = try mainContext.fetch(fetchRequest)
//            guard let entryToDeleteInContext = fetchedEntries.first else {
//                print("Failed to fetch entry in main context")
//                return
//            }
//
//            print("Entry being deleted: \(entry)")
//            // Now perform the deletion
//            entry.imageContent = nil
//            parentLog.removeFromRelationship(entry)
//            mainContext.delete(entryToDeleteInContext)
//            try mainContext.save()
//            if let filename = filename {
//                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//                let fileURL = documentsDirectory.appendingPathComponent(filename)
//
//                do {
//                    // Delete file
//                    try FileManager.default.removeItem(at: fileURL)
//                } catch {
//                    // Handle file deletion errors
//                    print("Failed to delete file: \(error)")
//                }
//            }
//
//        } catch {
//            print("Failed to fetch entry in main context: \(error)")
//        }
//    }
//}



@MainActor
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
                        .alert(isPresented: $showingDeleteConfirmation) {
                            Alert(title: Text("Delete log"),
                                  message: Text("Are you sure you want to delete this log? This action cannot be undone."),
                                  primaryButton: .destructive(Text("Delete")) {
                                      deleteLog(log: logToDelete)
                                  },
                                  secondaryButton: .cancel())
                        }                    }

                    .listStyle(.insetGrouped)
                    .navigationTitle("Logs")
                    
                } else if selectedTimeframe == "By Month" {
                    List {
                        ForEach(monthsGrouped().keys.sorted(), id: \.self) { month in
                            NavigationLink(destination: LogsByMonthView(logs: monthsGrouped()[month]!, month: month)) {
                                Text("Month of \(month)")
                            }
//                            .contextMenu {
//                                Button(action: {
//                                    showingDeleteConfirmation = true
//                                    logToDelete = log
//                                }) {
//                                    Text("Delete")
//                                    Image(systemName: "trash")
//                                }
//                            }
                        }
                        .alert(isPresented: $showingDeleteConfirmation) {
                            Alert(title: Text("Delete log"),
                                  message: Text("Are you sure you want to delete this log? This action cannot be undone."),
                                  primaryButton: .destructive(Text("Delete")) {
                                      deleteLog(log: logToDelete)
                                  },
                                  secondaryButton: .cancel())
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
                        
                    }

                    .listStyle(.insetGrouped)
                    .navigationTitle("Logs")
                }
            }
            .navigationBarItems(trailing:
                                    Button(action: {
                Task {
                    pdfURL = await render()
                    isExporting = true
                }
            }, label: {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 16))
            })
            )
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
    
    func filteredLogs() -> [Log] {
        print("Entered filtered logs!")
        print("All logs: \(logs)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        
        var filtered: [Log] = []
        
        switch selectedTimeframe {
        case "By Day":
            // Return all logs as they are already sorted by day in FetchRequest
            filtered = Array(logs)
            print("Filtered: \(filtered)")
            
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
    
//    private func deleteLog(at offsets: IndexSet) {
//        for index in offsets {
//            let log = logs[index]
//            if let entries = log.relationship as? Set<Entry> {
//                for entry in entries {
//                    coreDataManager.viewContext.delete(entry)
//                }
//            }
//            coreDataManager.viewContext.delete(log)
//        }
//
//        do {
//            try coreDataManager.viewContext.save()
//        } catch {
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//    }
    
    private func deleteLog(log: Log?) {
        guard let log = log else { return }
        if let entries = log.relationship as? Set<Entry> {
            for entry in entries {
//                coreDataManager.viewContext.delete(entry)
                Entry.deleteEntry(entry: entry, coreDataManager: coreDataManager)

                
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
    @EnvironmentObject var coreDataManager: CoreDataManager
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
                                        .foregroundColor(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme))
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
    
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
}


struct LogDetailView_PDF : View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State var userPreferences: UserPreferences
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
                                        .foregroundColor(UIColor.backgroundColor(entry: entry, colorScheme: colorScheme))
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
                            if let image_data = data {
                                Image(uiImage: UIImage(data: image_data)!)
                                    .resizable()
                                    .scaledToFit()
                            }
                            
                            
//                            if let data = data, isGIF(data: data) {
//
//                                let imageView = AnimatedImageView(url: fileURL)
//
//                                let asyncImage = UIImage(data: data)
//
//                                let height = asyncImage!.size.height
//
//                                AnimatedImageView(url: fileURL).scaledToFit()
//
//
//                                // Add imageView
//                            } else {
//                                UIImage(data: data)
//                            }
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
    
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
}
//struct PDFDocument: View {
//    var filteredLogs: [Log] // Replace with your actual data model
//
//    var body: some View {
//        ForEach(filteredLogs, id: \.self) { log in
//            LogDetailView(log: log) // Replace with your actual SwiftUI view
//        }
//    }
//}


struct PDFDocument: FileDocument {
    var pdfURL: URL?
    
    init(pdfURL: URL?) {
        self.pdfURL = pdfURL
    }
    
    static var readableContentTypes: [UTType] { [.pdf] }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let url = URL(dataRepresentation: data, relativeTo: nil) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        pdfURL = url
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try Data(contentsOf: pdfURL!)
        return .init(regularFileWithContents: data)
    }
}

