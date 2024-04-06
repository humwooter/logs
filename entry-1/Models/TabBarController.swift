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
                                                SettingsView()
                                                    .environmentObject(userPreferences)
                                                    .environmentObject(coreDataManager)
                                                    .environmentObject(datesModel)
                                                    .environmentObject(tabSelectionInfo) // Pass TabSelectionInfo
            .dismissOnTabTap(isRootTabView: true)

        )
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 2)

        tabBarController.setViewControllers([logVC, entryVC, settingsVC], animated: false)
        
        // Omitted UITabBar customization for brevity...

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

        // Track the last selected index to compare against new selections
        private var lastSelectedIndex = -1

        init(_ parent: TabBarController) {
            self.parent = parent
        }
        
//        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//            let selectedIndex = tabBarController.selectedIndex
//
//            // Check if the newly selected tab is the same as the last selected tab
//            if selectedIndex == lastSelectedIndex {
//                print("SAME TAB PRESSED AGAIN")
//                // Attempt to pop to root if the view controller is embedded in a navigation controller
//                if let navController = viewController.navigationController {
//                    navController.popToRootViewController(animated: true)
//                    print("popped to root view")
//                } else if let hostingController = viewController as? UIHostingController<AnyView>, let navController = hostingController.navigationController {
//                    // If your UIHostingController is contained within a UINavigationController
//                    navController.popToRootViewController(animated: true)
//                    print("did not to root view")
//
//                }
//            } else {
//                lastSelectedIndex = selectedIndex // Update the last selected index to the new selection
//            }
//        }
        
        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            // Assuming TabSelectionInfo is accessible and has been initialized
            let selectedIndex = tabBarController.selectedIndex

            // Update the observable object
            DispatchQueue.main.async {
                self.parent.tabSelectionInfo.selectedIndex = selectedIndex
                self.parent.tabSelectionInfo.tabJustTapped = true
                
                // Reset tabJustTapped after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.parent.tabSelectionInfo.tabJustTapped = false
                }
            }
        }
    }
}

