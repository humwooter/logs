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

    let log: Log
    
    var body: some View {
        if let entries = log.relationship as? Set<Entry>, !entries.isEmpty {
            Section {
                List(entries.sorted(by: { $0.time > $1.time }), id: \.self) { entry in
                    EntryDetailView(entry: entry)
                        .environmentObject(coreDataManager)
                        .environmentObject(userPreferences)
                        .font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                        .listRowBackground(isClear(for: UIColor(userPreferences.entryBackgroundColor)) ? getDefaultEntryBackgroundColor() : userPreferences.entryBackgroundColor)

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
                    print("LOG detailz: \(log)")
                })
                .listStyle(.automatic)
            }

            .navigationBarTitleDisplayMode(.inline)
        } else {
            Text("No entries available")
                .foregroundColor(.gray)
        }
    }

    
    func getDefaultEntryBackgroundColor() -> Color {
        let color = colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground
        
        return Color(color)
    }
}
