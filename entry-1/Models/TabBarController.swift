//
//  TabBarController.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 4/6/24.
//

import Foundation
import SwiftUI
import UIKit


struct TabBarController: UIViewControllerRepresentable {
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var datesModel: DatesModel
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var tabSelectionInfo: TabSelectionInfo
    @Binding var isUnlocked: Bool

    
    // Initialize TabSelectionInfo within TabBarController

    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarController()

        // Define your view controllers here, passing TabSelectionInfo to each.

        let logVC = UIHostingController(rootView:
                                            LogParentView()
                                                .environmentObject(userPreferences)
                                                .environmentObject(coreDataManager)
                                                .environmentObject(datesModel)
                                                .environmentObject(tabSelectionInfo) // Pass TabSelectionInfo
            .dismissOnTabTap(isRootTabView: true)
        )
        logVC.tabBarItem = UITabBarItem(title: "Logs", image: UIImage(systemName: "book.fill"), tag: 0)

        let entryVC = UIHostingController(rootView:
                                            EntryView()
                                                .environmentObject(userPreferences)
                                                .environmentObject(coreDataManager)
                                                .environmentObject(tabSelectionInfo) // Pass TabSelectionInfo
            .dismissOnTabTap(isRootTabView: true)

        )
        entryVC.tabBarItem = UITabBarItem(title: "Entries", image: UIImage(systemName: "pencil"), tag: 1)

        let settingsVC = UIHostingController(rootView:
                                                SettingsView(isUnlocked: $isUnlocked)
                                                    .environmentObject(userPreferences)
                                                    .environmentObject(coreDataManager)
                                                    .environmentObject(datesModel)
                                                    .environmentObject(tabSelectionInfo) // Pass TabSelectionInfo
            .dismissOnTabTap(isRootTabView: true)

        )
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 2)

        tabBarController.setViewControllers([logVC, entryVC, settingsVC], animated: false)
        
        tabBarController.selectedIndex = 1
        tabBarController.delegate = context.coordinator

        return tabBarController
    }


    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        // Dynamically update the UITabBar's appearance if needed, e.g., if userPreferences.accentColor changes
        uiViewController.tabBar.tintColor = UIColor(userPreferences.accentColor)
        let updatedAppearance = UITabBarAppearance()
        
        var backgroundColor = UIColor.clear

        updatedAppearance.configureWithDefaultBackground()
        updatedAppearance.backgroundColor = backgroundColor

        var opacity_val = 0.35
        //stacked
        updatedAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor:  UIColor(Color(UIColor.fontColor(forBackgroundColor: backgroundColor, colorScheme: colorScheme)).opacity(opacity_val))]
        updatedAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: backgroundColor, colorScheme: colorScheme)).opacity(opacity_val))
//        updatedAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(userPreferences.accentColor)
        
        //inline
        updatedAppearance.inlineLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor:  UIColor(Color(UIColor.fontColor(forBackgroundColor: backgroundColor, colorScheme: colorScheme)).opacity(opacity_val))]
        updatedAppearance.inlineLayoutAppearance.normal.iconColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: backgroundColor, colorScheme: colorScheme)).opacity(opacity_val))
//        updatedAppearance.inlineLayoutAppearance.selected.iconColor = UIColor(userPreferences.accentColor)
        
        
        uiViewController.tabBar.standardAppearance = updatedAppearance
        uiViewController.tabBar.scrollEdgeAppearance = updatedAppearance
    }
    
    
    

    func makeCoordinator() -> Coordinator {
          Coordinator(self)
      }

    class Coordinator: NSObject, UITabBarControllerDelegate {
        var parent: TabBarController
        @EnvironmentObject var userPreferences: UserPreferences
        @EnvironmentObject var coreDataManager: CoreDataManager
        @EnvironmentObject var datesModel: DatesModel


        init(_ parent: TabBarController) {
            self.parent = parent
        }
        
//        func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//            // If the selected view controller is already the currently displayed one, pop to the root.
//            if let navController = viewController as? UINavigationController {
//                if navController.visibleViewController !== navController.viewControllers.first {
//                    navController.popToRootViewController(animated: true)
//                    return false // Prevent the selection from triggering the normal tab switch action
//                }
//            }
//            return true // Allow the tab to be selected normally otherwise
//        }
        
        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            let currentIndex = tabBarController.selectedIndex
            let previousIndex = self.parent.tabSelectionInfo.selectedIndex // Use the current selectedIndex as the previousIndex

            // Immediately update the selectedIndex to the new value
            self.parent.tabSelectionInfo.selectedIndex = currentIndex

            // Determine if the same tab was tapped twice
            if previousIndex == currentIndex {
                // Execute logic for when the same tab is tapped twice
                DispatchQueue.main.async {
                    // Set tabJustTapped to true only if the same tab is tapped twice
                    self.parent.tabSelectionInfo.tabJustTapped = true
                    
                    // Optionally reset tabJustTapped after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.parent.tabSelectionInfo.tabJustTapped = false
                    }
                }
            } else {
                //do nothing here
            }
        }
    }
}


struct CustomTabViewModel: View {
    @State private var selection = 1
    @State private var resetNavigationID = UUID()
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var datesModel: DatesModel
    @EnvironmentObject var tabSelectionInfo: TabSelectionInfo
    @Environment(\.colorScheme) var colorScheme
    @Binding var isUnlocked: Bool
    
    var opacity_val = 0.35

    var body: some View {
        let selectable = Binding(
            get: { self.selection },
            set: {
                if self.selection == $0 {
                        withAnimation(.easeInOut(duration: 3.0)) {
                            self.resetNavigationID = UUID() // Resets navigation stack

                        }
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
                    .environmentObject(tabSelectionInfo)
            }.dismissOnTabTap(isRootTabView: true)
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
            .tag(0)
            .id(resetNavigationID)

            NavigationView {
                EntryView()
                    .environmentObject(userPreferences)
                    .environmentObject(coreDataManager)
                    .environmentObject(tabSelectionInfo)
                    .environmentObject(datesModel)
            }
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
            .id(resetNavigationID)

            NavigationView {
                SettingsView(isUnlocked: $isUnlocked)
                    .environmentObject(userPreferences)
                    .environmentObject(coreDataManager)
                    .environmentObject(datesModel)
                    .environmentObject(tabSelectionInfo)
            }
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
            .id(resetNavigationID)
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
