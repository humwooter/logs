import SwiftUI
import CoreData
import LocalAuthentication



struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedIndex = 1
    @ObservedObject private var userPreferences = UserPreferences()
    @State private var isUnlocked = false


    var body: some View {
        VStack {
            if (isUnlocked) {
                TabView(selection: $selectedIndex) {
                    LogsView()
                        .environment(\.managedObjectContext, viewContext)
                        .environmentObject(userPreferences)
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
                        .environment(\.managedObjectContext, viewContext)
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }.tag(2)
                }
                .accentColor(userPreferences.accentColor)
                .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
            }
            else {
                Text("Locked")
            }
        }.onAppear(perform: authenticate)
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    isUnlocked = true
                } else {
                    // there was a problem
                }
            }
        } else {
            // no biometrics
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
