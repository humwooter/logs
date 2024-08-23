////
////  LogDetailView.swift
////  entry-1
////
////  Created by Katyayani G. Raman on 10/27/23.
////
//
//import Foundation
//import SwiftUI
//import CoreData
//import UniformTypeIdentifiers
//
//
//
//struct LogDetailView: View {
//    @EnvironmentObject var coreDataManager: CoreDataManager
//    @EnvironmentObject var userPreferences: UserPreferences
//    @Environment(\.colorScheme) var colorScheme
//    @Binding var totalHeight: CGFloat
//    @Binding var isShowingReplyCreationView: Bool
//    @Binding var replyEntryId: String?
//
//    let log: Log
//    
//    var body: some View {
//        if let entries = (log.relationship as? Set<Entry>)?.filter({ !$0.isRemoved }), !entries.isEmpty {
//            Section {
//                List(entries.sorted(by: { $0.time > $1.time }), id: \.self) { entry in
//                    if !entry.isRemoved {
//                        EntryDetailView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, entry: entry)
//                            .environmentObject(coreDataManager)
//                            .environmentObject(userPreferences)
//                            .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
//                            .lineSpacing(userPreferences.lineSpacing)
//                            .listRowBackground(isClear(for: UIColor(userPreferences.entryBackgroundColor)) ? entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme) : userPreferences.entryBackgroundColor)
//                    }
//                }
//                .background {
//                        ZStack {
//                            Color(UIColor.systemGroupedBackground)
//                            LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
//                                .ignoresSafeArea()
//                        }
//                }
//                .scrollContentBackground(.hidden)
//                .onAppear(perform: {
//                    for entry in entries {
//                        print("ENTRYY: \(entry)")
//                    }
//                    print("LOG detailz: \(log)")
//                })
//                .listStyle(.automatic)
//            }
//
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationTitle(convertDate(from: log.day))
//        } else {
//            Text("No entries available")
//                .foregroundColor(.gray)
//        }
//    }
//
//    func convertDate(from dateString: String) -> String {
//        // Create a DateFormatter to parse the input string
//        let inputFormatter = DateFormatter()
//        // Set the input format to match the new input string pattern
//        inputFormatter.dateFormat = "MM/dd/yyyy"
//        
//        // Create another DateFormatter to format the output string
//        let outputFormatter = DateFormatter()
//        // Set the output format to "Month Day"
//        outputFormatter.dateFormat = "MMMM d"
//        
//        // Attempt to parse the input string into a Date object
//        if let date = inputFormatter.date(from: dateString) {
//            // If parsing succeeds, format the Date object into the desired output string
//            return outputFormatter.string(from: date)
//        } else {
//            // If parsing fails, return an error message or handle the error as needed
//            return "Invalid date"
//        }
//    }
//    
//    func getDefaultEntryBackgroundColor() -> Color {
//        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
//        
//        return Color(color)
//    }
//}
import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct LogDetailView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    @Binding var totalHeight: CGFloat
    @Binding var isShowingReplyCreationView: Bool
    @Binding var replyEntryId: String?
    let logDay: String

//    let log: Log
    
    var body: some View {
        let entries = fetchEntries()
        if !entries.isEmpty {
            Section {
                List(entries, id: \.self) { entry in
                    EntryDetailView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, entry: entry)
                        .environmentObject(coreDataManager)
                        .environmentObject(userPreferences)
                        .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                        .lineSpacing(userPreferences.lineSpacing)
                        .listRowBackground(isClear(for: UIColor(userPreferences.entryBackgroundColor)) ? getDefaultEntryBackgroundColor(colorScheme: colorScheme) : userPreferences.entryBackgroundColor)
                }
                .background {
                    ZStack {
                        Color(UIColor.systemGroupedBackground)
                        LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                            .ignoresSafeArea()
                    }
                }
                .scrollContentBackground(.hidden)
//                .onAppear(perform: {
//                    for entry in entries {
//                        print("ENTRYY: \(entry)")
//                    }
//                    print("LOG detailz: \(log)")
//                })
                .listStyle(.automatic)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(convertDate(from: logDay))
        } else {
            Text("No entries available")
                .foregroundColor(.gray)
        }
    }

    func fetchEntries() -> [Entry] {
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()

        // Convert log.day into DateComponents
        guard let logDate = dateFromString(logDay),
              let logComponents = dateComponents(from: logDay) else {
            print("Invalid log.day format")
            return []
        }
        
        print("LOG DATE: \(logDate)")
        // Create a predicate that compares the date components of entry.time with log.day
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: logDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Predicate to check if entry.time falls within the same day as log.day and isRemoved is false
        request.predicate = NSPredicate(format: "isRemoved == NO AND time >= %@ AND time < %@", startOfDay as NSDate, endOfDay as NSDate)

        // Sort entries by time in descending order
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Entry.time, ascending: false)]

        do {
            let entries = try coreDataManager.viewContext.fetch(request)
            print("ENTRIES: \(entries)")

            return entries
        } catch {
            print("Error fetching entries: \(error)")
            return []
        }
    }


    func convertDate(from dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM/dd/yyyy"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM d"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return "Invalid date"
        }
    }
    
}
