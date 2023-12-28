import SwiftUI
import CoreData
import LocalAuthentication



struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedIndex = 1
    @State private var indices : [Bool] = [false, true, false]
    @ObservedObject private var userPreferences = UserPreferences()
    private var coreDataManager = CoreDataManager(persistenceController: PersistenceController.shared)
    
    
    var body: some View {
                    
            VStack {
                if (!userPreferences.isUnlocked && userPreferences.showLockScreen){
                    ZStack {
                        Color(UIColor.systemGroupedBackground)
                        LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                        
                            .ignoresSafeArea()
                        
                        Button {
                            authenticate()
                        } label: {
                            Label("Locked", systemImage: "lock")
                                .foregroundStyle(Color(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first!) )))
                        }
                    }
                    
                }
                else {
                    TabView(selection: $selectedIndex) {
                        LogsView()
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)
                            .tabItem {
                                Label("Logs", systemImage: "book.fill")
                            }.tag(0)
                        
                        
                        EntryView(color: UIColor(userPreferences.backgroundColors.first ?? Color.clear))
//                        EntryView(color: UIColor(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))))
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)
                            .tabItem {
                                Label("Entries", systemImage: "pencil")
                            }.tag(1)
                        
                        
                        SettingsView()
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)
                            .tabItem {
                                Label("Settings", systemImage: "gearshape")
                            }.tag(2)
                    }
                    .accentColor(userPreferences.accentColor)
                    .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
                }
                
            }.onAppear(perform: {
                createLog(in: coreDataManager.viewContext)
                deleteOldEntries()
                authenticate()
                for family in UIFont.familyNames.sorted() {
                    let names = UIFont.fontNames(forFamilyName: family)
                    print("Family: \(family) Font names: \(names)")
                }
            })
    }
    

    func authenticate() {
        if userPreferences.showLockScreen {
            print("userPreferences.isUnlocked: \(userPreferences.isUnlocked)")
            print("userPreferences.showLockScreen: \(userPreferences.showLockScreen)")

            let context = LAContext()
            var error: NSError?
            
            // check whether biometric authentication is possible
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                // it's possible, so go ahead and use it
                let reason = "We need to unlock your data."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    // authentication has now completed
                    DispatchQueue.main.async {
                        if success {
                            userPreferences.isUnlocked = true
                        } else {
                            // there was a problem
                        }
                    }
                }
            } else {
                // no biometrics
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

