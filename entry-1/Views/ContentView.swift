import SwiftUI
import CoreData
import LocalAuthentication



struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedIndex = 1
    @State private var indices : [Bool] = [false, true, false]
    @ObservedObject private var userPreferences = UserPreferences()
    private var coreDataManager = CoreDataManager(persistenceController: PersistenceController.shared)
    
    
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)],
        predicate: NSPredicate(format: "day == %@", formattedDate(Date()))
    ) var logs: FetchedResults<Log> // should only be 1 log

//    @State private var isUnlocked = false

    
    
    var body: some View {
        VStack {
            if (!userPreferences.isUnlocked && userPreferences.showLockScreen){
                Button {
                    authenticate()
                } label: {
                    Label("Locked", systemImage: "lock")
                }

            }
            else {
                TabView(selection: $selectedIndex) {
                    LogsView()
                        // .environment(\.managedObjectContext, viewContext)
//                        .environment(\.managedObjectContext, coreDataManager.viewContext)
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
//                        .onTapGesture {
//                            indices[0].toggle()
//                        }
                        .tabItem {
                            Label("Logs", systemImage: "books.vertical.fill")
//                                .symbolEffect(.bounce.down, value: indices[0])

                        }.tag(0)
                    
                   
                    
              if (logs.count != 0) {
                        EntryView(log: logs.first!)
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)
                            .tabItem {
                                Label("Entries", systemImage: "pencil")
                            }.tag(1)
                    }
                    
                    
                    SettingsView()
//                    .environment(\.managedObjectContext, coreDataManager.viewContext)
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
//                        .onTapGesture {
//                            indices[2].toggle()
//                        }
                        // .environment(\.managedObjectContext, viewContext)
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
//                                .symbolEffect(.bounce.down, value: indices[2])

                        }.tag(2)
                }
                .accentColor(userPreferences.accentColor)
                .background(userPreferences.backgroundColor)
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
//        onAppear(perform: authenticate)
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

