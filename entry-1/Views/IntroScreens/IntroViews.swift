//
//  IntroViews.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 1/22/24.
//

import Foundation
import SwiftUI
import CoreData



struct IntroViews: View {
    @State private var selectedTab: Int = 0
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
                TabView(selection: $selectedTab) {
                    // Category 1: Core Note-Taking
                    IntroView(title: "Essentials", content: [
                        (description: "Quick Entries: Easily jot down thoughts, plans, and notes. Each entry is timestamped and can be tagged with custom stamps", imageName: "note.text"),
                        (description: "Stamps: Activate in Settings, swipe right to expose, tap to use. Up to 21 custom icons/colors for easy identification and organization.", imageName: "bookmark.fill"),
                        (description: "Easy Deletion: Swipe left to delete, recover/remove from Recently Deleted. Auto-delete after 10 days.", imageName: "trash")
                    ], color: userPreferences.accentColor)
                    .tag(0)
                    .transition(.slide)
                    
                    // Category 2: Organization and Customization
                    IntroView(title: "Organization and Customization", content: [
                        (description: "Pinning: Keep important entries accessible in main view across days.", imageName: "pin.fill"),
                        (description: "Add reminders to your entries with custom times and recurrence patterns for staying on top of tasks and notes.", imageName: "bell.fill"),
                        (description: "Personalization: Customize fonts, colors, reminders, pins, accents, and more.", imageName: "wand.and.stars")
                    ], color: userPreferences.accentColor)
                    .tag(1)
                    .transition(.slide)
                    
                    // Category 3: Multimedia and Data Management
                    IntroView(title: "Multimedia and Data Management", content: [
                        (description: "Add photos, GIFs, PDFs. Intuitive PDF reader for note-taking.", imageName: "photo.on.rectangle.angled"),
                        (description: "Data Backup: Backup logs, preferences, and stamps in Settings. Share stamp packs with friends and ensure your data is always safe.", imageName: "externaldrive.badge.icloud"),
                        (description: "Lock your logs to keep it private.", imageName: "lock.fill")
                    ], color: userPreferences.accentColor)
                    .tag(2)
                    .transition(.slide)
                    
                }
                .tabViewStyle(PageTabViewStyle())
        .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {

                    Button(action: {
                        if userPreferences.isFirstLaunch {
                            userPreferences.isFirstLaunch = false
                        }
                        presentationMode.wrappedValue.dismiss()
                 
                    }, label: {
                        Text("Done")
                            .font(.system(size: 15))
                    })
            }
        }
        .background {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()
        }
    }
}



//
//struct IntroViews: View {
//    @State private var selectedTab: Int = 0
//    @EnvironmentObject var userPreferences: UserPreferences
//
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            // Update each IntroView call to pass an array of description-imageName pairs
//            IntroView(title: "Quick Entries", content: [
//                (description: "Effortlessly jot down thoughts, plans, and notes. Each entry is timestamped and can be tagged with custom stamps.", imageName: "note.text")
//            ], color: userPreferences.accentColor)
//            .tag(0)
//            .transition(.slide)
//
//            // Repeat for other tabs...
//
//            // Example of an IntroView with multiple content pieces
//            IntroView(title: "Personalization & Multimedia", content: [
//                (description: "Customize everything from fonts, background colors, reminder and pin colors, to accent color, and more.", imageName: "wand.and.stars"),
//                (description: "Add photos, GIFs, and PDFs to your entries.", imageName: "photo"),
//            ], color: userPreferences.accentColor)
//            .tag(6)
//            .transition(.slide)
//        }
//        .tabViewStyle(PageTabViewStyle())
//        .background {
//            ZStack {
//                Color(UIColor.systemGroupedBackground)
//                LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
//            }
//            .ignoresSafeArea()
//        }
//        // The rest of your TabView configuration...
//    }
//}


//struct IntroViews: View {
//    @State private var selectedTab: Int = 0
//    @EnvironmentObject var userPreferences: UserPreferences
//
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            // Existing IntroViews
//            IntroView(title: "Quick Entries",
//                      description: "Effortlessly jot down thoughts, plans, and notes. Each entry is timestamped and can be tagged with custom stamps.")
//                .tag(0)
//                .transition(.slide)
//
//            IntroView(title: "Stamps",
//                      description: "Personalize up to 21 stamps with unique colors and icons. Stamp entries for easy identification and organization.")
//                .tag(1)
//                .transition(.slide)
//
//            IntroView(title: "Easy Deletion",
//                      description: "Swipe right to delete entries. Recover or permanently remove them from Recently Deleted. Entries auto-delete after 10 days.")
//                .tag(2)
//                .transition(.slide)
//
//            IntroView(title: "Pinning Entries",
//                      description: "Pin your most important entries to keep them accessible in the main Entries view, even as the day changes.")
//                .tag(3)
//                .transition(.slide)
//
//            IntroView(title: "Reminders",
//                      description: "Never miss a beat. Add reminders to your entries and get notified at the right time to act on them.")
//                .tag(4)
//                .transition(.slide)
//
//            IntroView(title: "Data Backup",
//                      description: "Easily back up your logs, preferences, and stamps in Settings. Share stamp packs with friends and ensure your data is always safe.")
//                .tag(5)
//                .transition(.slide)
//
//            // New IntroView for Personalization and Multimedia
//            IntroView(title: "Personalization & Multimedia",
//                      description: "Customize everything from fonts, background colors, reminder and pin colors, to accent color, and more. Add photos, GIFs, and PDFs to your entries. The PDF reader allows for intuitive reading and note-taking simultaneously.")
//                .tag(6)
//                .transition(.slide)
//        }
//        .tabViewStyle(PageTabViewStyle())
//        .background {
//            ZStack {
//                Color(UIColor.systemGroupedBackground)
//                LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
//            }
//            .ignoresSafeArea()
//        }
//        .animation(.easeInOut(duration: 0.5), value: selectedTab)
//    }
//}

//struct IntroView: View {
//    var title: String
//    var description: String
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text(title)
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .padding()
//                .scaleEffect(1.1)
//                .animation(.easeInOut(duration: 0.5))
//
//            Text(description)
//                .font(.body)
//                .padding([.leading, .trailing, .bottom])
//                .multilineTextAlignment(.center)
//                .animation(.easeInOut(duration: 0.5))
//
//            // Add additional UI elements based on userPreferences if needed
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .padding()
//    }
//}


struct IntroView: View {
    var title: String
    var content: [(description: String, imageName: String?)] // Updated to accept multiple pairs
    var color: Color

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Spacer()
                Text(title)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)

                    .fontWeight(.bold)
                    .padding()
                    .scaleEffect(1.1)
                Spacer()
                
                ForEach(0..<content.count, id: \.self) { index in
                    let item = content[index]
                    HStack {
                        if let imageName = item.imageName {
                            Image(systemName: imageName) // Example of handling image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 35, maxHeight: 35)
                                .foregroundStyle(color)
                                .padding()
                        }
                        
                        Text(item.description)
                            .padding(.trailing)
                            .font(.system(size: UIFont.systemFontSize))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
                Spacer()
                Spacer()
            }
        }.padding(.horizontal)
    }
}
