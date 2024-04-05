import SwiftUI
import CoreData
import LocalAuthentication



struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
//    @State private var selectedIndex = 1
    @State private var indices : [Bool] = [false, true, false]
    @ObservedObject private var userPreferences = UserPreferences()
    @ObservedObject var datesModel = DatesModel()

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
    
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]))).opacity(0.5))
    }
    
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
                .onAppear {
                    UITabBar.appearance().unselectedItemTintColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]))).opacity(0.5))
                }
                
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
//                TabView(selection: $selectedIndex) {
//                    LogParentView()
//                        .environmentObject(userPreferences)
//                        .environmentObject(coreDataManager)
//                        .environmentObject(datesModel)
//                        .tabItem {
//                            Label("Logs", systemImage: "book.fill")
//                        }.tag(0)
//
////                        .toolbarBackground(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]))), for: .tabBar)
//                    EntryView(backgroundColors: userPreferences.backgroundColors)
//                        .environmentObject(userPreferences)
//                        .environmentObject(coreDataManager)
//                        .tabItem {
//                            Label("Entries", systemImage: "pencil")
//                        }.tag(1)
//                    
//                    
//                    SettingsView()
//                        .environmentObject(userPreferences)
//                        .environmentObject(coreDataManager)
//                        .environmentObject(datesModel)
//                        .tabItem {
//                            Label("Settings", systemImage: "gearshape")
//                        }.tag(2)
//                }
//                .accentColor(userPreferences.accentColor)
//                .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
                
                TabBarController().ignoresSafeArea()
                    .environmentObject(coreDataManager)
                    .environmentObject(userPreferences)
                    .environmentObject(datesModel)
                
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


struct TabBarController: UIViewControllerRepresentable {
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var datesModel: DatesModel
    @Environment(\.colorScheme) var colorScheme


    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarController()

        // Define your view controllers here...
        let logVC = UIHostingController(rootView: 
                                            LogParentView()
                                                .environmentObject(userPreferences)
                                                .environmentObject(coreDataManager)
                                                .environmentObject(datesModel)
        )
        logVC.tabBarItem = UITabBarItem(title: "Logs", image: UIImage(systemName: "book.fill"), tag: 0)

        let entryVC = UIHostingController(rootView: 
                                            EntryView(backgroundColors: userPreferences.backgroundColors)
            .environmentObject(userPreferences)
            .environmentObject(coreDataManager)
        )
        entryVC.tabBarItem = UITabBarItem(title: "Entries", image: UIImage(systemName: "pencil"), tag: 1)

        let settingsVC = UIHostingController(rootView: 
                                                SettingsView()
            .environmentObject(userPreferences)
            .environmentObject(coreDataManager)
            .environmentObject(datesModel)
        )
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 2)

        // Add the view controllers to the tab bar controller
        tabBarController.setViewControllers([logVC, entryVC, settingsVC], animated: false)

        // Customize the UITabBar appearance
        let tabBarAppearance = UITabBarAppearance()
        
        tabBarAppearance.backgroundColor = UIColor(userPreferences.backgroundColors[1]) // Set the background color to the user's accent color
        let unselectedColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]), colorScheme: colorScheme)).opacity(0.5))
        let selectedColor = UIColor(userPreferences.accentColor)
        
        //stacked
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor:  UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]), colorScheme: colorScheme)).opacity(0.5))]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]), colorScheme: colorScheme)).opacity(0.5))
        
        //inline
        tabBarAppearance.inlineLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor:  UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]), colorScheme: colorScheme)).opacity(0.5))]
        tabBarAppearance.inlineLayoutAppearance.normal.iconColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]), colorScheme: colorScheme)).opacity(0.5))
        
        
        // Ensure the tab bar stretches to the bottom and uses the accent color
        tabBarController.tabBar.standardAppearance = tabBarAppearance
        
        tabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance
        tabBarController.tabBar.tintColor = UIColor(userPreferences.accentColor)

        return tabBarController
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        // Dynamically update the UITabBar's appearance if needed, e.g., if userPreferences.accentColor changes
        uiViewController.tabBar.tintColor = UIColor(userPreferences.accentColor)
        let updatedAppearance = UITabBarAppearance()
        
        updatedAppearance.backgroundColor = UIColor(userPreferences.backgroundColors[1])
        
        //stacked
        updatedAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor:  UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]), colorScheme: colorScheme)).opacity(0.5))]
        updatedAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]), colorScheme: colorScheme)).opacity(0.5))
//        updatedAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(userPreferences.accentColor)
        
        //inline
        updatedAppearance.inlineLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor:  UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]), colorScheme: colorScheme)).opacity(0.5))]
        updatedAppearance.inlineLayoutAppearance.normal.iconColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]), colorScheme: colorScheme)).opacity(0.5))
//        updatedAppearance.inlineLayoutAppearance.selected.iconColor = UIColor(userPreferences.accentColor)
        
        
        uiViewController.tabBar.standardAppearance = updatedAppearance
        uiViewController.tabBar.scrollEdgeAppearance = updatedAppearance
    }
}



//
//
//struct TabBarController: UIViewControllerRepresentable {
//    @EnvironmentObject var userPreferences: UserPreferences
//    @EnvironmentObject var coreDataManager: CoreDataManager
//    @EnvironmentObject var datesModel: DatesModel
//
//
//    func makeUIViewController(context: Context) -> UITabBarController {
//        let tabBarController = UITabBarController()
//
//        // Define your view controllers here...
//        let logVC = UIHostingController(rootView:
//                                            LogParentView()
//                                                .environmentObject(userPreferences)
//                                                .environmentObject(coreDataManager)
//                                                .environmentObject(datesModel)
//        )
//        logVC.tabBarItem = UITabBarItem(title: "Logs", image: UIImage(systemName: "book.fill"), tag: 0)
//
//        let entryVC = UIHostingController(rootView:
//                                            EntryView(backgroundColors: userPreferences.backgroundColors)
//            .environmentObject(userPreferences)
//            .environmentObject(coreDataManager)
//        )
//        entryVC.tabBarItem = UITabBarItem(title: "Entries", image: UIImage(systemName: "pencil"), tag: 1)
//
//        let settingsVC = UIHostingController(rootView:
//                                                SettingsView()
//            .environmentObject(userPreferences)
//            .environmentObject(coreDataManager)
//            .environmentObject(datesModel)
//        )
//        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 2)
//
//        // Add the view controllers to the tab bar controller
//        tabBarController.setViewControllers([logVC, entryVC, settingsVC], animated: false)
//
//        // Customize the UITabBar appearance
//        let tabBarAppearance = UITabBarAppearance()
//        
//        tabBarAppearance.backgroundColor = UIColor(userPreferences.backgroundColors[1]) // Set the background color to the user's accent color
//        let unselectedColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]))).opacity(0.5))
//        let selectedColor = UIColor(userPreferences.accentColor)
//        
//        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor:  UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]))).opacity(0.5))]
//        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(userPreferences.accentColor)
//]
//        
//        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]))).opacity(0.5))
//        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(userPreferences.accentColor)
//
//        // Ensure the tab bar stretches to the bottom and uses the accent color
//        tabBarController.tabBar.standardAppearance = tabBarAppearance
//        
//        tabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance
//
//        // Set the tintColor to match the userPreferences accent color for the selected tab item
////        tabBarController.tabBar.unselectedItemTintColor = UIColor.green
////        tabBarController.tabBar.tintColor = UIColor(userPreferences.accentColor)
//
//        return tabBarController
//    }
//
//    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
//        // Dynamically update the UITabBar's appearance if needed, e.g., if userPreferences.accentColor changes
////        uiViewController.tabBar.tintColor = UIColor(userPreferences.accentColor)
//        let updatedAppearance = UITabBarAppearance()
//        updatedAppearance.backgroundColor = UIColor(userPreferences.backgroundColors[1])
//        
//        updatedAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor:  UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]))).opacity(0.5))]
//        updatedAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(userPreferences.accentColor)
//]
//        updatedAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors[1]))).opacity(0.5))
//        updatedAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(userPreferences.accentColor)
//
//
//        uiViewController.tabBar.standardAppearance = updatedAppearance
//        uiViewController.tabBar.scrollEdgeAppearance = updatedAppearance
//    }
//}
//
