//import WidgetKit
//import SwiftUI
//import Intents
//import CoreData
//
//struct Provider: TimelineProvider {
//    let viewContext = PersistenceController.shared.container.viewContext
//
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), stampedEntries: [])
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let widget = SimpleEntry(date: Date(), stampedEntries: fetchTopEntries())
//        completion(widget)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
//        var entries: [SimpleEntry] = []
//        let currentDate = Date()
//        let entry = SimpleEntry(date: currentDate, stampedEntries: fetchTopEntries())
//        entries.append(entry)
//        
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
//    
//    func fetchTopEntries() -> [Entry] {
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Entry.time, ascending: false)]
//        fetchRequest.fetchLimit = 3
//
//        do {
//            let entries = try viewContext.fetch(fetchRequest)
//            return entries.filter { $0.stampIndex == 0 }
//        } catch {
//            print("Failed to fetch entries: \(error)")
//            return []
//        }
//    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let stampedEntries: [Entry]
//}
//
//struct StampWidgetEntryView : View {
//    var entry: SimpleEntry
//
//    var body: some View {
//        VStack {
//            ForEach(entry.stampedEntries.prefix(3), id: \.self) { entry in
//                Text(entry.content ?? "")
//            }
//        }
//        .widgetURL(URL(string: "myapp://createEntryWithStamp"))
//    }
//}
//
//struct StampWidget: Widget {
//    let kind: String = "StampWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            StampWidgetEntryView(entry: entry)
//        }
//        .configurationDisplayName("Stamp Widget")
//        .description("Displays top entries with a specific stamp.")
//    }
//}
