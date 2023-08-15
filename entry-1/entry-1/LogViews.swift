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
//
////
////detail: {
////    Text(selectedLog?.day ?? "None")
////}
//
////struct LogsView: View {
////    @Environment(\.managedObjectContext) private var viewContext
////
////    @FetchRequest(
////        entity: Log.entity(),
////        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)]
////    ) var logs: FetchedResults<Log>
////
////    @State private var selectedLog: Log? // To keep track of the selected log
////
////    var body: some View {
////        NavigationView {
////            List {
////                ForEach(logs, id: \.self) { log in
////                    NavigationLink(destination: LogDetailView(log: log)) {
////                        Text(log.day ?? "No Date")
////                    }
////                }
////            }
////            .navigationTitle("Logs")
////        }
////    }
////}
////
////struct LogDetailView : View {
////
////}
//
//struct LogsView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        entity: Log.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)]
//    ) var logs: FetchedResults<Log>
//
//    @State private var selectedLogId: NSManagedObjectID?
//
//    var body: some View {
//        NavigationSplitView {
//            List(logs, id: \.self) { log in
//                Button(action: {
//                    selectedLogId = log.objectID
//                }) {
//                    Text(log.day)
//                }
//            }
//            .navigationTitle("Logs")
//
//        } detail: {
//            if let selectedLogId = selectedLogId,
//               let log = viewContext.object(with: selectedLogId) as? Log {
//                List(Array(log.relationship) as! [Entry], id: \.self) { entry in
//
//                    Text(entry.content)
//                }
//                .listStyle(.plain)
//                .navigationBarTitleDisplayMode(.inline)
//            } else {
//                Text("Please select a log")
//            }
//        }
//    }
//}
//

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
        if let entries = log.relationship as? Set<Entry> {
            List(entries.sorted(by: { $0.time > $1.time }), id: \.self) { entry in
                VStack(alignment: .leading, spacing: 5) {
                    Text(formattedTime(entry.time))
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text(entry.content)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
        } else {
            Text("Please select a log")
        }
    }

    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


