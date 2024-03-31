import SwiftUI
import CoreData
import LocalAuthentication



struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedIndex = 1
    @State private var indices : [Bool] = [false, true, false]
    @ObservedObject private var userPreferences = UserPreferences()
    @ObservedObject var datesModel = DatesModel()

    private var coreDataManager = CoreDataManager(persistenceController: PersistenceController.shared)
    @FetchRequest(
           entity: Entry.entity(),
           sortDescriptors: [], // No sorting applied
           predicate: NSPredicate(format: "time == nil")
       ) var entriesWithNilTime: FetchedResults<Entry>
    
    
    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: []  // Empty array implies no sorting
    ) var allEntries: FetchedResults<Entry>
    
    var body: some View {
        ZStack {
            if userPreferences.isFirstLaunch == true {
                NavigationStack {
                    VStack {
                        IntroViews()
                            .environmentObject(userPreferences)
                    }
                }
            } else {
                mainAppView().onAppear(perform: {
                    print("userPreferences.isFirstLaunch: \(userPreferences.isFirstLaunch)")
                    createLog(in: coreDataManager.viewContext)
                    deleteOldEntries()
                    authenticate()
                    
                    print("Entries with nil time: \(entriesWithNilTime.count)")
                })
            }
        } .onAppear {
            print("isFirstLaunch: \(userPreferences.isFirstLaunch)")
        }
    }
    
    @ViewBuilder
    func mainAppView() -> some View {
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
                    LogParentView()
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
                        .environmentObject(datesModel)
                        .tabItem {
                            Label("Logs", systemImage: "book.fill")
                        }.tag(0)
                    EntryView()
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
                        .tabItem {
                            Label("Entries", systemImage: "pencil")
                        }.tag(1)
                    
                    
                    SettingsView()
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
                        .environmentObject(datesModel)
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }.tag(2)
                }
                .accentColor(userPreferences.accentColor)
                .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
            }
            
        }
    }

    func authenticate() {
        if userPreferences.showLockScreen {
            print("userPreferences.isUnlocked: \(userPreferences.isUnlocked)")
            print("userPreferences.showLockScreen: \(userPreferences.showLockScreen)")

            let context = LAContext()
            var error: NSError?

            // Check whether biometric authentication is possible or fallback to passcode
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                // It's possible, so go ahead and use it
                let reason = "We need to unlock your data."

                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                    // Authentication has now completed
                    DispatchQueue.main.async {
                        if success {
                            userPreferences.isUnlocked = true
                        } else {
                            // Biometrics failed and the user either cancelled the passcode screen or entered an incorrect passcode
                            // Handle the failure or fallback to a custom password prompt if needed
                        }
                    }
                }
            } else {
                // Biometrics and passcode not available
                // You might want to fallback to a custom password prompt
            }
        }
    }
}
