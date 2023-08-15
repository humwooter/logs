import SwiftUI
import CoreData


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedIndex = 1
    @ObservedObject private var userPreferences = UserPreferences()





    var body: some View {
        TabView(selection: $selectedIndex) {
            LogsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Logs", systemImage: "book")
                }.tag(0)

            EntryView()
                .environmentObject(userPreferences)
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Entries", systemImage: "pencil")
                }.tag(1)
            SettingsView()
                .environmentObject(userPreferences)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }.tag(2)
        }
        .accentColor(userPreferences.accentColor)
        .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
