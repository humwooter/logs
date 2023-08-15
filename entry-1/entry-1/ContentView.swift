import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedIndex = 1

    
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            LogsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Logs", systemImage: "book")
                }.tag(0)
            
            EntryView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Entries", systemImage: "pencil")
                }.tag(1)
            Text("Settings Page Here")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }.tag(2)
        }
        .accentColor(.cyan)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
