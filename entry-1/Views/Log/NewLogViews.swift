////
////  NewLogViews.swift
////  entry-1
////
////  Created by Katyayani G. Raman on 12/29/23.
////
//
//
//import Foundation
//import SwiftUI
//import CoreData
//import UniformTypeIdentifiers
//import UIKit
//
//
//let dateFormatter = DateFormatter()
//
//
//struct HeightGetterModifier: ViewModifier {
//    var onHeightCalculated: (CGFloat) -> Void
//
//    func body(content: Content) -> some View {
//        GeometryReader { geometry in
//            content
//                .onAppear {
//                    onHeightCalculated(geometry.size.height)
//                }
//        }
//    }
//}
//
//extension View {
//    func getHeight(onHeightCalculated: @escaping (CGFloat) -> Void) -> some View {
//        self.modifier(HeightGetterModifier(onHeightCalculated: onHeightCalculated))
//    }
//}
//
//struct SizePreferenceKey: PreferenceKey {
//  static var defaultValue: CGSize = .zero
//  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
//}
//
//struct GetHeightModifier: ViewModifier {
//    @Binding var height: CGFloat
//
//    func body(content: Content) -> some View {
//        content.background(
//            GeometryReader { geo -> Color in
//                DispatchQueue.main.async {
//                    height = geo.size.height
//                }
//                return Color.clear
//            }
//        )
//    }
//}
//
//
//func estimatedHeight(forText text: String, fontName: String, fontSize: CGFloat, lineSpacing: CGFloat) -> CGFloat {
//    guard let font = UIFont(name: fontName, size: fontSize) else { return 0 }
//    
//    let screenWidth = UIScreen.main.bounds.width
//    let paragraphStyle = NSMutableParagraphStyle()
//    paragraphStyle.lineSpacing = lineSpacing
//
//    let attributes: [NSAttributedString.Key: Any] = [
//        .font: font,
//        .paragraphStyle: paragraphStyle
//    ]
//
//    let constraintRect = CGSize(width: screenWidth, height: .greatestFiniteMagnitude)
//    let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
//
//    return ceil(boundingBox.height)
//}
//
//
//
//@MainActor
//struct LogsView: View {
//    @EnvironmentObject var coreDataManager: CoreDataManager
//    @EnvironmentObject var userPreferences: UserPreferences
//    @State private var selectedTimeframe: String = "By Date"
//    @State private var selectedDate: Date = Date()
//    @State private var showDatePicker: Bool = false
//    
//    @State private var isExporting = false
//    @State private var pdfURL: URL?
//    @State private var pdfData: Data?
//    
//    
//    @State private var showingDeleteConfirmation = false
//    @State private var logToDelete: Log?
//    @State private var selectedDates: Set<DateComponents> = []
//    
//    
//    
//    @FetchRequest(
//        entity: Log.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: false)]
//    ) var logs: FetchedResults<Log>
//    
//    @State private var startDate: Date = .distantPast
//
//    @State private var endDate: Date = Date() // Current day
//    var calendar = Calendar.current
//    var timeZone = TimeZone.current
//
//    var bounds: Range<Date> {
//        return startDate..<endDate
//    }
//
//    @State private var dates: Set<DateComponents> = {
//        var set = Set<DateComponents>()
//        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
//            set.insert(todayComponents)
//        
//        return set
//    }()
//    
//    
//    @State var image: UIImage?
//    @State var shareSheetShown = false
//    
//    @State private var height: CGFloat = 0
//    @State var heights: [UUID: CGFloat] = [:]
//
//    
//    func updateDateRange() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        
//        let dateLogs = logs.compactMap { dateFormatter.date(from: $0.day) }
//        
//        if let earliestDate = dateLogs.min(),
//           let latestDate = dateLogs.max() {
//            startDate = earliestDate
//            endDate = latestDate
//        }
//    }
//    
//    @State private var showCalendar = true
//    
//    @FetchRequest(
//        entity: Log.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
//        predicate: NSPredicate(format: "day == %@", formattedDate(Date())),
//        animation: nil
//    ) var currentLog: FetchedResults<Log>
//
//    @State var selectedLogs: [Log] = []
//    
//    @StateObject private var searchModel = SearchModel()
//    @State var isSearching = false
//    @FetchRequest(
//        entity: Entry.entity(),
//        sortDescriptors: []  // Empty array implies no sorting
//    ) var allEntries: FetchedResults<Entry>
//    // LogsView
//    var body: some View {
//
//        NavigationView {
//            VStack(spacing: 0) {
//                    List {
//                        if !isSearching {
//                            if selectedTimeframe == "By Date" {
//                                Section {
//                                    if showCalendar {
//                                        MultiDatePicker("Dates Available", selection: $dates, in: bounds).datePickerStyle(.automatic)
//                                            .foregroundColor(Color.complementaryColor(of: userPreferences.accentColor))
//                                            .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
//                                            .accentColor(Color.complementaryColor(of: userPreferences.accentColor))
//                                        
//                                    }
//                                    
//                                } header: {
//                                    HStack {
//                                        Text("Dates").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
//                                        
//                                        Spacer()
//                                        Label("", systemImage: showCalendar ? "chevron.up" : "chevron.down").foregroundStyle(userPreferences.accentColor)
//                                            .contentTransition(.symbolEffect(.replace.offUp))
//                                        
//                                            .onTapGesture {
//                                                showCalendar.toggle()
//                                            }
//                                    }
//                                }
//                                
//                                
//                                ForEach(filteredLogs(), id: \.self) { log in
//                                    NavigationLink(destination: LogDetailView(totalHeight: $height, log: log)
//                                        .environmentObject(userPreferences)) {
//                                            Label(log.day, systemImage: "book.fill")
//                                        }
//                                        .contextMenu {
//                                            Button(role: .destructive, action: {
//                                                showingDeleteConfirmation = true
//                                                logToDelete = log
//                                            }) {
//                                                Label("Delete", systemImage: "trash")
//                                                    .foregroundColor(.red)
//                                                
//                                            }
//                                            Button(action: {
//                                                Task {
//                                                    DispatchQueue.main.async {
//                                                        let pdfData = createPDFData_log(log: log)
//                                                        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("log.pdf")
//                                                        try? pdfData.write(to: tmpURL)
//                                                        let activityVC = UIActivityViewController(activityItems: [tmpURL], applicationActivities: nil)
//                                                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//                                                            let window = windowScene.windows.first
//                                                            window?.rootViewController?.present(activityVC, animated: true, completion: nil)
//                                                        }
//                                                    }
//                                                }
//                                                
//                                            }, label: {
//                                                Label("Share Log PDF", systemImage: "square.and.arrow.up")
//                                            })
//                                            
//                                        }
//                                }
//                                .alert(isPresented: $showingDeleteConfirmation) {
//                                    Alert(title: Text("Delete log"),
//                                          message: Text("Are you sure you want to delete this log? This action cannot be undone."),
//                                          primaryButton: .destructive(Text("Delete")) {
//                                        deleteLog(log: logToDelete)
//                                    },
//                                          secondaryButton: .cancel())
//                                }
//                                
//                                NavigationLink(destination: RecentlyDeletedView().environmentObject(coreDataManager).environmentObject(userPreferences)) {
//                                    Label("Recently Deleted", systemImage: "trash").foregroundStyle(.red)
//                                }
//                                
//                                
//                            }
//                            
//                            
//                        }
//                        else { //if the user is actively searching
////                            NavigationLink(destination: HiddenEntries()
////                                .environmentObject(userPreferences)) {
////                                    Label("Hidden Entries", systemImage: "eye.fill")
////                                        .onTapGesture {
////                                            searchModel.tokens.append(.hiddenEntries)
////                                        }
////                                }
//                    
//                     
//                            if searchModel.tokens.isEmpty { //present possible tokens
//                                
//                                VStack(spacing: 5) {
//                                    Section {
//                                        Label("Hidden Entries", systemImage: "eye.fill")
//                                            .onTapGesture {
//                                                searchModel.tokens.append(.hiddenEntries)
//                                            }
//                                    }
//                                    Section {
//                                        Label("Entries with Media", systemImage: "paperclip")
//                                            .onTapGesture {
//                                                searchModel.tokens.append(.mediaEntries)
//                                            }
//                                    }
//                                    Section {
//                                        Label("Stamp Number", systemImage: "circle.fill")
//                                            .onTapGesture {
//                                                searchModel.tokens.append(.stampIndexEntries)
//                                            }
//                                    }
//                                    Section {
//                                        Label("Stamp Icon Label", systemImage: "star.fill")
//                                            .onTapGesture {
//                                                searchModel.tokens.append(.stampNameEntries)
//                                            }
//                                    }
//                                }
//                    
//                            }
//                            else {
//                                let entries = filteredEntries(entries: Array(allEntries), searchText: searchModel.searchText, tags: searchModel.tokens)
//                                
//                                ForEach(entries, id: \.self) { entry in
//                                    EntryDetailView(entry: entry)
//                                        .environmentObject(userPreferences)
//                                        .environmentObject(coreDataManager)
//                                        .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
//
//
//                                }
////                                else if searchModel.tokens.first == .hiddenEntries {
////
////                                }
////                                if searchModel.tokens.first == .hiddenEntries {
////
////                                }
////                                else if searchModel.tokens.first == .hiddenEntries {
////
////                                }
//                            }
//                        }
//                    }
//                    .searchable(text: $searchModel.searchText, tokens: $searchModel.tokens) { token in
//                                switch token {
//                                case .hiddenEntries: Label("Hidden", systemImage: "eye.fill")
//                                case .mediaEntries: Label("Media", systemImage: "photo.fill")
//                                case .stampIndexEntries: Label("Index", systemImage: "circle.fill")
//                                case .stampNameEntries: Label("Name", systemImage: "circle")
//                                case .searchTextEntries: Text(searchModel.searchText)
//                                }
//                    }
//                    .onDisappear(perform: {
//                        isSearching = false
//                    })
//                
//                    .onChange(of: searchModel.searchText) { newValue in
//                                      isSearching = !newValue.isEmpty
//                                  }
//                
//                    .onTapGesture {
//                        isSearching = true
//                    }
//                
//                    .background {
//                            ZStack {
//                                Color(UIColor.systemGroupedBackground)
//                                LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
//                            }
//                            .ignoresSafeArea()
//                    }
//                    .onAppear {
//                        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
//                        dates.insert(todayComponents)
//                        updateFetchRequests()
//                        updateDateRange()
//                        print("UPDATING DATES")
//                        //dates is a set so if the current date exists already then nothing happens
//                    }
//                    .scrollContentBackground(.hidden)
//                    .refreshable {
//                        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
//                        dates.insert(todayComponents)
//                        updateFetchRequests()
//                        updateDateRange()
//                    }
//                    .sheet(isPresented: $shareSheetShown) {
//                        if let log_uiimage = image {
//                            let logImage = Image(
//                                uiImage: log_uiimage)
//                            ShareLink(item: logImage, preview: SharePreview("", image: logImage))
//                        }
//                    }
//                    .listStyle(.automatic)
//                
//                    .navigationTitle("Logs")
//            }.font(.system(size: UIFont.systemFontSize))
//
//            
//                .fileExporter(isPresented: $isExporting, document: PDFDocument(pdfURL: pdfURL), contentType: .pdf) { result in
//                    switch result {
//                    case .success(let url):
//                        print("File successfully saved at \(url)")
//                    case .failure(let error):
//                        print("Failed to save file: \(error)")
//                    }
//                }
//        }
//    }
//
//    func DatePickerView(date: Binding<Date>, title: String) -> some View {
//        List {
//            DatePicker("Start Date", selection: date, displayedComponents: .date)
//        }
//        .navigationTitle(title)
//    }
//    
//    
//    func filteredEntries(entries: [Entry], searchText: String, tags: [FilterTokens]) -> [Entry] {
//        guard !searchText.isEmpty || !tags.isEmpty else { return entries }
//
//        let filtered_entries = entries.filter { entry in
//            let matchesSearchText = searchText.isEmpty || entry.content.lowercased().contains(searchText.lowercased())
//            
//            let matchesTags = tags.contains { tag in
//                switch tag {
//                case .hiddenEntries:
//                    return entry.isHidden
//                case .stampNameEntries:
//                    return entry.image.lowercased().contains(searchText.lowercased())
//                case .stampIndexEntries:
//                    if let index = Int16(searchText) {
//                        return entry.stampIndex == index
//                    }
//                    return false  // Return false if searchText cannot be converted to Int16
//                case .mediaEntries:
//                    return entry.imageContent != ""
//
//                case .searchTextEntries:
//                    return entry.content.lowercased().contains(searchText.lowercased())
//                }
//            }
//            
//            
//            return matchesTags
//        }
//        print("filtered entries: \(filtered_entries)")
//
//        return filtered_entries
//    }
//
//    
//    func entryHasImage(at filename: String?) -> Bool {
//        if let name = filename {
//            if !name.isEmpty {
//                if imageExists(at: name) {
//                    return true
//                }
//            }
//        }
//        return false
//    }
//    
//    func filteredLogs() -> [Log] {
//        print("Entered filtered logs!")
//        print("All logs: \(logs)")
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        
//        
//        var filtered: [Log] = []
//        updateFetchRequests()
//        
//        switch selectedTimeframe {
//        case "By Date":
//            return logs.filter { log in
//                guard let logDate = dateFormatter.date(from: log.day) else { return false }
//                for dateComponent in dates {
//                    if let selectedDate = calendar.date(from: dateComponent) {
//                        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
//                        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) ?? selectedDate
//                        if logDate >= startOfDay && logDate <= endOfDay {
//                            return true
//                        }
//                    }
//                }
//                return false
//            }
//            
//        default:
//            filtered = Array(logs)
//        }
//        
//        return filtered
//    }
//    
//
//    
//    func updateFetchRequests() {
//        
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//
//        let currentDay = formattedDate(Date())
//        currentLog.nsPredicate = NSPredicate(format: "day == %@", currentDay)
//        
//        
//        if currentLog.isEmpty {
//            let newLog = Log(context: coreDataManager.viewContext)
//            newLog.day = currentDay
//            newLog.id = UUID()
//        }
//    }
//    
//    
//    
//    private func deleteLog(log: Log?) {
//        guard let log = log else { return }
//        if let entries = log.relationship as? Set<Entry> {
//            for entry in entries {
//                deleteEntry(entry: entry, coreDataManager: coreDataManager)
//            }
//        }
//        coreDataManager.viewContext.delete(log)
//        
//        do {
//            try coreDataManager.viewContext.save()
//        } catch {
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//    }
//    
//    
//
//    
//    func createPDFData_log(log: Log) -> Data { //finally works
//        let pdfMetaData = [
//            kCGPDFContextCreator: "Your App",
//            kCGPDFContextAuthor: "Your Name"
//        ]
//        let pdfData = NSMutableData()
//        UIGraphicsBeginPDFContextToData(pdfData, .zero, pdfMetaData)
//        
//        
//        let rootView =               LogDetailView_PDF(height: $height, log: log)
//            .padding(10)
//            .environmentObject(userPreferences)
//            .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
//            .modifier(GetHeightModifier(height: $height))
//
//        
//        
//        print("HEIGHT FROM VIEW MODIFIER: \(height)")
//        let uiHostingController = UIHostingController(rootView: rootView)
//        // Define lineHeight
//        print("userPreferences.fontSize: \(userPreferences.fontSize)")
//            let lineHeight: CGFloat = 25 // Example line height
//            let entryHeight: CGFloat = 25
//            let imageHeight: CGFloat = 250 // Additional height for entries with images. this should be dynamic later
//
//        var totalHeight: CGFloat = 0
//            if let entries = log.relationship as? Set<Entry> { // Cast NSSet to Set<Entry>
//                for entry in entries {
//                    let entry_view = EntryDetailView(entry: entry)
//                        .environmentObject(coreDataManager)
//                        .environmentObject(userPreferences)
//                        .getHeight { height in
//                            self.height = height
//
//                               // Use the height here
//                               print("Height is \(height)")
//                           }
//                        .background(
//                          GeometryReader { geometryProxy in
//                            Color.clear
//                              .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
//                          }
//                        )
//                        .onPreferenceChange(SizePreferenceKey.self) { newSize in
//                            totalHeight += newSize.height
//
//                          print("The new child size is: \(newSize)")
//                        }
//               
//                    
//                    print("HEIGHT: \(height)")
//                    print()
//  
//                    print("entry.content: \(entry.content)")
//                    if entry.imageContent != "" && entry.imageContent != nil {
//                        totalHeight += (imageHeight + 50)
//                    }
//                }
//            }
////
//        
//
//        print("total HEIGHT: \(totalHeight)")
//            // Set targetSize with calculated height
//            let width = UIScreen.main.bounds.size.width // Assuming full width
//            let targetSize = CGSize(width: width, height: totalHeight)
//
//        
//        UIGraphicsBeginPDFPageWithInfo(CGRect(origin: .zero, size: targetSize), nil)
//        let renderer = UIGraphicsImageRenderer(size: targetSize)
//        
//        let img = renderer.image { ctx in
//            let uiView = uiHostingController.view
//            uiView?.bounds = CGRect(origin: .zero, size: targetSize)
//            uiView?.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
//        }
//        img.draw(in: CGRect(origin: .zero, size: targetSize))
//        
//        UIGraphicsEndPDFContext()
//        return pdfData as Data
//    }
//    
////
////    func render() async -> URL {
////        let logsByDay = Dictionary(grouping: filteredLogs(), by: { $0.day })
////        let sortedDays = logsByDay.keys.sorted()
////
////        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("output.pdf")
////
////        let renderer = UIGraphicsPDFRenderer(bounds: .zero)
////
////        do {
////            try renderer.writePDF(to: url) { context in
////                for day in sortedDays {
////                    let logsForDay = logsByDay[day]!
////
////                    for log in logsForDay {
////                        // Estimate height based on total number of entries per log
////                        let estimatedHeightPerEntry: CGFloat = 300
////                        let totalHeight = estimatedHeightPerEntry * CGFloat(log.relationship.count)
////                        print("Total height: \(totalHeight)")
////
////                        // Split content into multiple pages if total height exceeds a certain limit
////                        let pageLimit: CGFloat = 14000 // Adjust this value based on your content
////                        let numberOfPages = ceil(totalHeight / pageLimit)
////
////                        for page in 0..<Int(numberOfPages) {
////                            let pageHeight = min(pageLimit, totalHeight - CGFloat(page) * pageLimit)
////
////                            context.beginPage(withBounds: CGRect(x: 0, y: 0, width: 612, height: pageHeight), pageInfo: [:])
////
////                            let content = LogDetailView_PDF(log: log)
////                                .padding(10)
////                                .environmentObject(userPreferences)
////                                .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
////
////                            let hostingController = UIHostingController(rootView: content)
////                            hostingController.view.bounds = CGRect(origin: .zero, size: CGSize(width: 612, height: pageHeight))
////                            hostingController.view.backgroundColor = .clear
////
////                            hostingController.view.setNeedsLayout()
////                            hostingController.view.layoutIfNeeded()
////
////                            let targetRect = CGRect(x: 0, y: 0, width: 612, height: pageHeight)
////                            hostingController.view.drawHierarchy(in: targetRect, afterScreenUpdates: true)
////                        }
////                    }
////                }
////            }
////        } catch {
////            print("Failed to write PDF: \(error)")
////        }
////
////        return url
////    }
//}
//
//
//
//
//
//
