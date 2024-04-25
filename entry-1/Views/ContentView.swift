import SwiftUI
import CoreData
import LocalAuthentication
import Combine



struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
//    @State private var selectedIndex = 1
    @State private var indices : [Bool] = [false, true, false]
    @ObservedObject private var userPreferences = UserPreferences()
//    @ObservedObject var datesModel = DatesModel()
    @EnvironmentObject var tabSelectionInfo: TabSelectionInfo
    @ObservedObject var datesModel = DatesModel()
//    @State var dateStringsManager = DateStrings()

    private var coreDataManager = CoreDataManager(persistenceController: PersistenceController.shared)
    @FetchRequest(
           entity: Entry.entity(),
           sortDescriptors: [], // No sorting applied
           predicate: NSPredicate(format: "time == nil")
       ) var entriesWithNilTime: FetchedResults<Entry>
    
    @Environment(\.colorScheme) var colorScheme

    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: []  // Empty array implies no sorting
    ) var allEntries: FetchedResults<Entry>
    @State private var isUnlocked: Bool = false
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: false)]
    ) var logs: FetchedResults<Log>
    
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
                    initializeDateStrings()
                    if userPreferences.showLockScreen {
                        authenticate()
                    }
                })
            }
        }
    }
    
    func initializeDateStrings() {
        let dateStringsManager = DateStrings()
        for log in logs {
            dateStringsManager.addDate(log.day)
        }
    }
    
    @ViewBuilder
    func lockScreenView() -> some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
            LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 5) {
                Button {
                    authenticate()
                } label: {
                    Image(systemName: "lock.circle.fill").resizable().frame(width: 80, height: 80)
                        .foregroundStyle(userPreferences.accentColor)
                }.padding(.vertical, 30)
                
                Text("Logs are Locked").font(.title)
                Text("Use Face ID to View Logs").opacity(0.5)
                Button {
                    authenticate()
                } label: {
                    HStack(alignment: .center) {
                            Text("View Logs").padding(.top,1)
//                        Image(uiImage: UIImage(named: "app_icon.svg")!).resizable().scaledToFit().foregroundStyle(userPreferences.accentColor).frame(maxHeight: 25)
                    }.foregroundStyle(userPreferences.accentColor)
                        .frame(height: 25)
                    
                }.padding(.vertical, 30)
            }.foregroundColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
        }
    }
    
    

    @ViewBuilder
    func mainAppView() -> some View {
        VStack {
            if (!self.isUnlocked && userPreferences.showLockScreen){
                lockScreenView()
            }
            else {
//                TabBarController(isUnlocked: $isUnlocked).ignoresSafeArea()
//                    .environmentObject(coreDataManager)
//                    .environmentObject(userPreferences)
//                    .environmentObject(datesModel)
//                    .environmentObject(tabSelectionInfo)
//                    .accentColor(userPreferences.accentColor)
//                    .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
                
                CustomTabViewModel(isUnlocked: $isUnlocked)
                    .environmentObject(coreDataManager)
                    .environmentObject(userPreferences)
                    .environmentObject(datesModel)
                    .environmentObject(tabSelectionInfo)
                    .accentColor(userPreferences.accentColor)
                    .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
                
            }
            
        }
    }

    func authenticate() {
        if !self.isUnlocked {
            print("userPreferences.isUnlocked: \(self.isUnlocked)")
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
                            withAnimation {
                                self.isUnlocked = true
                            }
                            print("authentication succeeded")
                        } else {
                            print("authentication failed")
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



