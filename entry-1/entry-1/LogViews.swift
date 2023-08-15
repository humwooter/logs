////
////  LogViews.swift
////  entry-1
////
////  Created by Katya Raman on 8/14/23.
////
//
import Foundation
import SwiftUI
import CoreData

struct LogsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)]
    ) var logs: FetchedResults<Log>

    var body: some View {
        NavigationView {
            List(logs, id: \.self) { log in
                NavigationLink(destination: LogDetailView(log: log)) {
                    Text(log.day)
                }
            }
            .navigationTitle("Logs")
        }
    }
}

struct LogDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let log: Log

    var body: some View {
        if let entries = log.relationship as? Set<Entry>, !entries.isEmpty {
            List(entries.sorted(by: { $0.time > $1.time }), id: \.self) { entry in
                VStack(alignment: .leading, spacing: 5) {
                    Text(formattedTime(entry.time))
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text(entry.content)
                        .fontWeight(entry.isImportant ? .bold : .regular) // Bold if important
                        .foregroundColor(entry.isImportant ? .yellow : .primary) // Yellow if important
                }
            }
            .listStyle(.plain)
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




