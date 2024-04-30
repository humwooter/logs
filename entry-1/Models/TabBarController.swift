//
//  TabBarController.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 4/6/24.
//

import Foundation
import SwiftUI
import UIKit

//
//struct TabBarController: UIViewControllerRepresentable {
//    @EnvironmentObject var userPreferences: UserPreferences
//    @EnvironmentObject var coreDataManager: CoreDataManager
//    @EnvironmentObject var datesModel: DatesModel
//    @Environment(\.colorScheme) var colorScheme
//    
//    @EnvironmentObject var tabSelectionInfo: TabSelectionInfo
//    @Binding var isUnlocked: Bool
//
//    
//    // Initialize TabSelectionInfo within TabBarController
//
//    func makeUIViewController(context: Context) -> UITabBarController {
//        let tabBarController = UITabBarController()
//
//        // Define your view controllers here, passing TabSelectionInfo to each.
//
//        let logVC = UIHostingController(rootView:
//                                            LogParentView()
//                                                .environmentObject(userPreferences)
//                                                .environmentObject(coreDataManager)
//                                                .environmentObject(datesModel)
//                                                .environmentObject(tabSelectionInfo) // Pass TabSelectionInfo
//            .dismissOnTabTap(isRootTabView: true)
//        )
//        logVC.tabBarItem = UITabBarItem(title: "Logs", image: UIImage(systemName: "book.fill"), tag: 0)
//
//        let entryVC = UIHostingController(rootView:
//                                            EntryView()
//                                                .environmentObject(userPreferences)
//                                                .environmentObject(coreDataManager)
//                                                .environmentObject(tabSelectionInfo) // Pass TabSelectionInfo
//            .dismissOnTabTap(isRootTabView: true)
//
//        )
//        entryVC.tabBarItem = UITabBarItem(title: "Entries", image: UIImage(systemName: "pencil"), tag: 1)
//
//        let settingsVC = UIHostingController(rootView:
//                                                SettingsView(isUnlocked: $isUnlocked)
//                                                    .environmentObject(userPreferences)
//                                                    .environmentObject(coreDataManager)
//                                                    .environmentObject(datesModel)
//                                                    .environmentObject(tabSelectionInfo) // Pass TabSelectionInfo
//            .dismissOnTabTap(isRootTabView: true)
//
//        )
//        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 2)
//
//        tabBarController.setViewControllers([logVC, entryVC, settingsVC], animated: false)
//        
//        tabBarController.selectedIndex = 1
//        tabBarController.delegate = context.coordinator
//
//        return tabBarController
//    }
//
//
//    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
//        // Dynamically update the UITabBar's appearance if needed, e.g., if userPreferences.accentColor changes
//        uiViewController.tabBar.tintColor = UIColor(userPreferences.accentColor)
//        let updatedAppearance = UITabBarAppearance()
//        
//        var backgroundColor = UIColor.clear
//
//        updatedAppearance.configureWithDefaultBackground()
//        updatedAppearance.backgroundColor = backgroundColor
//
//        var opacity_val = 0.35
//        //stacked
//        updatedAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor:  UIColor(Color(UIColor.fontColor(forBackgroundColor: backgroundColor, colorScheme: colorScheme)).opacity(opacity_val))]
//        updatedAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: backgroundColor, colorScheme: colorScheme)).opacity(opacity_val))
////        updatedAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(userPreferences.accentColor)
//        
//        //inline
//        updatedAppearance.inlineLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor:  UIColor(Color(UIColor.fontColor(forBackgroundColor: backgroundColor, colorScheme: colorScheme)).opacity(opacity_val))]
//        updatedAppearance.inlineLayoutAppearance.normal.iconColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: backgroundColor, colorScheme: colorScheme)).opacity(opacity_val))
////        updatedAppearance.inlineLayoutAppearance.selected.iconColor = UIColor(userPreferences.accentColor)
//        
//        
//        uiViewController.tabBar.standardAppearance = updatedAppearance
//        uiViewController.tabBar.scrollEdgeAppearance = updatedAppearance
//    }
//    
    
    

//    func makeCoordinator() -> Coordinator {
//          Coordinator(self)
//      }
//
//    class Coordinator: NSObject, UITabBarControllerDelegate {
//        var parent: TabBarController
//        @EnvironmentObject var userPreferences: UserPreferences
//        @EnvironmentObject var coreDataManager: CoreDataManager
//        @EnvironmentObject var datesModel: DatesModel
//
//
//        init(_ parent: TabBarController) {
//            self.parent = parent
//        }
//        
////        func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
////            // If the selected view controller is already the currently displayed one, pop to the root.
////            if let navController = viewController as? UINavigationController {
////                if navController.visibleViewController !== navController.viewControllers.first {
////                    navController.popToRootViewController(animated: true)
////                    return false // Prevent the selection from triggering the normal tab switch action
////                }
////            }
////            return true // Allow the tab to be selected normally otherwise
////        }
//        
//        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//            let currentIndex = tabBarController.selectedIndex
//            let previousIndex = self.parent.tabSelectionInfo.selectedIndex // Use the current selectedIndex as the previousIndex
//
//            // Immediately update the selectedIndex to the new value
//            self.parent.tabSelectionInfo.selectedIndex = currentIndex
//
//            // Determine if the same tab was tapped twice
//            if previousIndex == currentIndex {
//                // Execute logic for when the same tab is tapped twice
//                DispatchQueue.main.async {
//                    // Set tabJustTapped to true only if the same tab is tapped twice
//                    self.parent.tabSelectionInfo.tabJustTapped = true
//                    
//                    // Optionally reset tabJustTapped after a short delay
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                        self.parent.tabSelectionInfo.tabJustTapped = false
//                    }
//                }
//            } else {
//                //do nothing here
//            }
//        }
//    }
//}
//
//
//struct CustomTabViewModel: View {
//    @State private var selection = 1
//    @State private var resetNavigationID = UUID()
//    @EnvironmentObject var userPreferences: UserPreferences
//    @EnvironmentObject var coreDataManager: CoreDataManager
//    @EnvironmentObject var datesModel: DatesModel
//    @EnvironmentObject var tabSelectionInfo: TabSelectionInfo
//    @Environment(\.colorScheme) var colorScheme
//    @Binding var isUnlocked: Bool
//    @State private var isIpad = UIDevice.current.userInterfaceIdiom == .pad
//
//    var opacity_val = 0.35
//
//    var body: some View {
//        let selectable = Binding(
//            get: { self.selection },
//            set: {
//                if self.selection == $0 {
//                        withAnimation(.easeInOut(duration: 3.0)) {
//                            self.resetNavigationID = UUID() // Resets navigation stack
//
//                        }
//                }
//                self.selection = $0
//            }
//        )
//
//        return TabView(selection: selectable) {
//            NavigationView {
//                LogParentView()
//                    .environmentObject(userPreferences)
//                    .environmentObject(coreDataManager)
//                    .environmentObject(datesModel)
//                    .environmentObject(tabSelectionInfo)
//                    .id(resetNavigationID)
//            }
//            .tabItem {
//                Label("Logs", systemImage: "book.fill")
//            }
//            .background(TabBarAccessor { tabBar in
//                let tabBarAppearance = UITabBarAppearance()
//                tabBarAppearance.configureWithDefaultBackground()
//                tabBar.unselectedItemTintColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor.clear, colorScheme: colorScheme)).opacity(opacity_val))
//                tabBar.standardAppearance = tabBarAppearance
//                tabBar.scrollEdgeAppearance = tabBarAppearance
//                  })
//            .tag(0)
//            
//
//            NavigationView {
//                EntryView()
//                    .environmentObject(userPreferences)
//                    .environmentObject(coreDataManager)
//                    .environmentObject(tabSelectionInfo)
//                    .environmentObject(datesModel)
//                    .id(resetNavigationID)
//            }
//            .tabItem {
//                Label("Entries", systemImage: "pencil")
//            }
//            .background(TabBarAccessor { tabBar in
//                let tabBarAppearance = UITabBarAppearance()
//                tabBarAppearance.configureWithDefaultBackground()
//                tabBar.unselectedItemTintColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor.clear, colorScheme: colorScheme)).opacity(opacity_val))
//                tabBar.standardAppearance = tabBarAppearance
//                tabBar.scrollEdgeAppearance = tabBarAppearance
//                  })
//            .tag(1)
//
//            NavigationView {
//                SettingsView(isUnlocked: $isUnlocked)
//                    .environmentObject(userPreferences)
//                    .environmentObject(coreDataManager)
//                    .environmentObject(datesModel)
//                    .environmentObject(tabSelectionInfo)
//                    
//                
//            }.id(resetNavigationID)
//            .tabItem {
//                Label("Settings", systemImage: "gearshape.fill")
//            }
//            .background(TabBarAccessor { tabBar in
//                let tabBarAppearance = UITabBarAppearance()
//                tabBarAppearance.configureWithDefaultBackground()
//                tabBar.unselectedItemTintColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor.clear, colorScheme: colorScheme)).opacity(opacity_val))
//                tabBar.standardAppearance = tabBarAppearance
//                tabBar.scrollEdgeAppearance = tabBarAppearance
//                  })
//            .tag(2)
//            
//        }
//    }
//}
//
//struct TabBarAccessor: UIViewControllerRepresentable {
//    var callback: (UITabBar) -> Void
//    private let proxyController = ViewController()
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<TabBarAccessor>) ->
//                              UIViewController {
//        proxyController.callback = callback
//        return proxyController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<TabBarAccessor>) {
//    }
//    
//    typealias UIViewControllerType = UIViewController
//
//    private class ViewController: UIViewController {
//        var callback: (UITabBar) -> Void = { _ in }
//
//        override func viewWillAppear(_ animated: Bool) {
//            super.viewWillAppear(animated)
//            if let tabBar = self.tabBarController {
//                self.callback(tabBar.tabBar)
//            }
//        }
//    }
//}




struct CustomNavigationViewModel: View { // For iPad
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var datesModel: DatesModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var isUnlocked: Bool

    @State private var selection: Int? = 1 // Active tab index, now optional
@State private var isShown_firstTab = true
    var body: some View {
        NavigationSplitView {
            List {
                HStack {
                    Text("Main Menu")
                    Spacer()
                    Image(systemName: isShown_firstTab ? "chevron.down" : "chevron.right").foregroundStyle(userPreferences.accentColor)
                }.onTapGesture {
                    withAnimation {
                        isShown_firstTab.toggle()
                    }
                }.font(.system(size: UIFont.systemFontSize + 3))
                
                if isShown_firstTab {
                    NavigationLink(destination: LogParentView()
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
//                        .environmentObject(datesModel)
                        .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))

                        .environmentObject(datesModel), tag: 0, selection: $selection) {
                            Label("Logs", systemImage: "book.fill")
                        }
                    
                    NavigationLink(destination: EntryView()
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
//                        .environmentObject(datesModel)
                        .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
                        .environmentObject(datesModel), tag: 1, selection: $selection) {
                            Label("Entries", systemImage: "pencil")
                        }
                    
                    NavigationLink(destination: SettingsView(isUnlocked: $isUnlocked)
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
//                        .environmentObject(datesModel)
                        .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
                        .environmentObject(datesModel), tag: 2, selection: $selection) {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                }
            }
               
            .listStyle(.sidebar)
        } detail: {
            
            Group {
                if let selection = selection {
                    switch selection {
                    case 0:
                        LogParentView()
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)
                            .environmentObject(datesModel)
                            .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))

                    case 1:
                        EntryView()
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)
                            .environmentObject(datesModel)
                            .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))

                    case 2:
                        SettingsView(isUnlocked: $isUnlocked)
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)
                            .environmentObject(datesModel)
                            .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))

                    default:
                        Text("Please select a tab from the sidebar")
                    }
                } else {
                    Text("Please select a tab from the sidebar")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}



struct CustomTabViewModel: View {
    @State private var selection = 1
    @State private var resetNavigationID = UUID()
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var datesModel: DatesModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var isUnlocked: Bool
    @State private var isIpad = UIDevice.current.userInterfaceIdiom == .pad

    var opacity_val = 0.35

    var body: some View {
        let selectable = Binding(
            get: { self.selection },
            set: {
                if self.selection == $0 {
                            self.resetNavigationID = UUID() // Resets navigation stack

                }
                self.selection = $0
            }
        )
        

        return TabView(selection: selectable) {
            NavigationView {
                LogParentView()
                    .environmentObject(userPreferences)
                    .environmentObject(coreDataManager)
                    .environmentObject(datesModel)
                    
            }
            .tabItem {
                Label("Logs", systemImage: "book.fill")
            }
            .background(TabBarAccessor { tabBar in
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithDefaultBackground()
                tabBar.unselectedItemTintColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor.clear, colorScheme: colorScheme)).opacity(opacity_val))
                tabBar.standardAppearance = tabBarAppearance
                tabBar.scrollEdgeAppearance = tabBarAppearance
                  })
            .id(resetNavigationID)
            .tag(0)
            

            NavigationView {
                EntryView()
                    .environmentObject(userPreferences)
                    .environmentObject(coreDataManager)
                    .environmentObject(datesModel)
                   
            }
            .id(resetNavigationID)
            .tabItem {
                Label("Entries", systemImage: "pencil")
            }
            .background(TabBarAccessor { tabBar in
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithDefaultBackground()
                tabBar.unselectedItemTintColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor.clear, colorScheme: colorScheme)).opacity(opacity_val))
                tabBar.standardAppearance = tabBarAppearance
                tabBar.scrollEdgeAppearance = tabBarAppearance
                  })
            .tag(1)

            NavigationView {
                SettingsView(isUnlocked: $isUnlocked)
                    .environmentObject(userPreferences)
                    .environmentObject(coreDataManager)
                    .environmentObject(datesModel)
                    
                
            }.id(resetNavigationID)
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .background(TabBarAccessor { tabBar in
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithDefaultBackground()
                tabBar.unselectedItemTintColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor.clear, colorScheme: colorScheme)).opacity(opacity_val))
                tabBar.standardAppearance = tabBarAppearance
                tabBar.scrollEdgeAppearance = tabBarAppearance
                  })
            .tag(2)
            
        }
    }
}

struct TabBarAccessor: UIViewControllerRepresentable {
    var callback: (UITabBar) -> Void
    private let proxyController = ViewController()

    func makeUIViewController(context: UIViewControllerRepresentableContext<TabBarAccessor>) ->
                              UIViewController {
        proxyController.callback = callback
        return proxyController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<TabBarAccessor>) {
    }
    
    typealias UIViewControllerType = UIViewController

    private class ViewController: UIViewController {
        var callback: (UITabBar) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let tabBar = self.tabBarController {
                self.callback(tabBar.tabBar)
            }
        }
    }
}
