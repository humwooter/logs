//
//  LogDetailView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/27/23.
//

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

    let log: Log
    
    var body: some View {
        if let entries = (log.relationship as? Set<Entry>)?.filter({ !$0.isRemoved }), !entries.isEmpty {
            Section {
                List(entries.sorted(by: { $0.time > $1.time }), id: \.self) { entry in
                    if !entry.isRemoved {
                        EntryDetailView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $replyEntryId, entry: entry)
                            .environmentObject(coreDataManager)
                            .environmentObject(userPreferences)
                            .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                            .lineSpacing(userPreferences.lineSpacing)
                            .listRowBackground(isClear(for: UIColor(userPreferences.entryBackgroundColor)) ? entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme) : userPreferences.entryBackgroundColor)
                    }
                }
                .background {
                        ZStack {
                            Color(UIColor.systemGroupedBackground)
                            LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                                .ignoresSafeArea()
                        }
                }
                .scrollContentBackground(.hidden)
                .onAppear(perform: {
                    for entry in entries {
                        print("ENTRYY: \(entry)")
                    }
                    print("LOG detailz: \(log)")
                })
                .listStyle(.automatic)
            }

            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(convertDate(from: log.day))
        } else {
            Text("No entries available")
                .foregroundColor(.gray)
        }
    }

    func convertDate(from dateString: String) -> String {
        // Create a DateFormatter to parse the input string
        let inputFormatter = DateFormatter()
        // Set the input format to match the new input string pattern
        inputFormatter.dateFormat = "MM/dd/yyyy"
        
        // Create another DateFormatter to format the output string
        let outputFormatter = DateFormatter()
        // Set the output format to "Month Day"
        outputFormatter.dateFormat = "MMMM d"
        
        // Attempt to parse the input string into a Date object
        if let date = inputFormatter.date(from: dateString) {
            // If parsing succeeds, format the Date object into the desired output string
            return outputFormatter.string(from: date)
        } else {
            // If parsing fails, return an error message or handle the error as needed
            return "Invalid date"
        }
    }
    
    func getDefaultEntryBackgroundColor() -> Color {
        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
        
        return Color(color)
    }
}
