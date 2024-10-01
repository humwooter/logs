////
////  LogDetailView.swift
////  entry-1
////
////  Created by Katyayani G. Raman on 10/27/23.
////
//

import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct LogDetailView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    @Binding var isShowingReplyCreationView: Bool
    @Binding var replyEntryId: String?
    let logDay: String
    
    @State private var isEditing = false

    @FetchRequest private var entries: FetchedResults<Entry>
    
    init(logDay: String, isShowingReplyCreationView: Binding<Bool>, replyEntryId: Binding<String?>) {
        self.logDay = logDay
        self._isShowingReplyCreationView = isShowingReplyCreationView
        self._replyEntryId = replyEntryId
        
        // Convert logDay to a Date object
        guard let logDate = dateFromString(logDay) else {
            print("LOG DAY: \(logDay)")
            fatalError("Invalid logDay format")
        }
        
        // Define the start and end of the day
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: logDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Set up the fetch request with a predicate that matches entries for the specific logDay
        self._entries = FetchRequest<Entry>(
            entity: Entry.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: false)],
            predicate: NSPredicate(format: "isRemoved == NO AND time >= %@ AND time < %@", startOfDay as NSDate, endOfDay as NSDate)
        )
    }

    var entryViewModel: EntryViewModel {
        EntryViewModel(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId)
    }
//    
    var body: some View {
        if !entries.isEmpty {
                List(entries, id: \.self) { entry in
                    EntryDetailView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, entry: entry, showContextMenu: true, isInList: true)
                        .environmentObject(coreDataManager)
                        .environmentObject(userPreferences)
                        .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                        .lineSpacing(userPreferences.lineSpacing)
                        .listRowBackground(getSectionColor(colorScheme: colorScheme))
                }
                .background {
                    userPreferences.backgroundView(colorScheme: colorScheme)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.automatic)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(convertDate(from: logDay))
        } else {
            Text("No entries available")
                .foregroundColor(.gray)
        }
    }
    
    
    func getSectionColor(colorScheme: ColorScheme) -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        } else {
            return userPreferences.entryBackgroundColor
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
