//
//  TabBarController.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 4/6/24.
//

import Foundation
import SwiftUI
import UIKit
import EventKit


struct CustomNavigationViewModel: View { // For iPad
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var datesModel: DatesModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var isUnlocked: Bool
    @Binding var isShowingReplyCreationView: Bool
    @Binding var repliedEntryId: String?

    @State private var selection: Int? = 1 // Active tab index, now optional
    
    @Binding var editingEntryId: String?
    @Binding var isEditing: Bool
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
                    NavigationLink(destination: LogParentView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $repliedEntryId)
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
                        .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))

                        .environmentObject(datesModel), tag: 0, selection: $selection) {
                            Label("Logs", systemImage: "book.fill")
                        }
                    
                    NavigationLink(destination: EntryView(isShowingReplyCreationView: $isShowingReplyCreationView, repliedEntryId: $repliedEntryId)
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
                        .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
                        .environmentObject(datesModel), tag: 1, selection: $selection) {
                            Label("Entries", systemImage: "pencil")
                        }
                    
                    NavigationLink(destination: SettingsView(isUnlocked: $isUnlocked)
                        .environmentObject(userPreferences)
                        .environmentObject(coreDataManager)
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
                        LogParentView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $repliedEntryId)
                            .environmentObject(userPreferences)
                            .environmentObject(coreDataManager)
                            .environmentObject(datesModel)
                            .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))

                    case 1:
                        EntryView(isShowingReplyCreationView: $isShowingReplyCreationView, repliedEntryId: $repliedEntryId)
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
    @Binding var isShowingReplyCreationView: Bool
    @Binding var repliedEntryId: String?
    @Binding var editingEntryId: String?
    @Binding var isEditing: Bool


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
                LogParentView(isShowingReplyCreationView: $isShowingReplyCreationView, replyEntryId: $repliedEntryId)
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
                EntryView( isShowingReplyCreationView: $isShowingReplyCreationView, repliedEntryId: $repliedEntryId)
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
