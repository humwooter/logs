//import SwiftUI
//import Charts
//import CoreData
//
//
//struct EntryData: Identifiable {
//    let date: Date
//    let count: Double
//    var id = UUID()
//}
//
//struct EntryTypeData: Identifiable {
//    let stampIcon: String
//    let count: Double
//    var id = UUID()
//}
//
//
//class ChartViewModel: ObservableObject {
//    @Published var dailyEntries: [EntryData] = []
//    @Published var entryTypeDistribution: [EntryTypeData] = []
//
//    private var context: NSManagedObjectContext
//
//    init(context: NSManagedObjectContext) {
//        self.context = context
//        loadEntries()
//    }
//
//    private func loadEntries() {
//        let logFetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
//        let entryFetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//
//        do {
//            // Fetch Logs and calculate entries per day
//            let logs = try context.fetch(logFetchRequest)
//            dailyEntries = logs.map { log in
//                // Assuming `Log` has a `date` and `entries` is the relationship
//                if let date = dateFromString(log.day) {
//                    EntryData(date: date, count: Double(log.relationship.count ?? 0))
//                }
//            }
//
//            // Fetch Entries and calculate distribution by type
//            let entries = try context.fetch(entryFetchRequest)
//            let groupedByType = Dictionary(grouping: entries, by: { $0.stampIcon ?? "Unknown" })
//            entryTypeDistribution = groupedByType.map { type, entries in
//                EntryTypeData(stampIcon: type, count: Double(entries.count))
//            }
//
//        } catch {
//            print("Error fetching data: \(error)")
//        }
//    }
//}
//
//
//struct ChartsView: View {
//    @StateObject var viewModel = ChartViewModel()
//    @EnvironmentObject var coreDataManager: CoreDataManager
//    
//    var body: some View {
//        VStack {
//            Chart {
//                ForEach(viewModel.dailyEntries) { data in
//                    BarMark(
//                        x: .value("Date", data.date, format: Date.FormatStyle().day().month()),
//                        y: .value("Count", data.count)
//                    )
//                }
//            }
//            .frame(height: 300)
//
//            Chart {
//                ForEach(viewModel.entryTypeDistribution) { data in
//                    Mark(
//                        x: .value("Stamp Icon", data.stampIcon),
//                        y: .value("Count", data.count)
//                    )
//                    .foregroundStyle(by: .value("Stamp Icon", data.stampIcon))
//                }
//            }
//            .frame(height: 300)
//        }
//    }
//}
