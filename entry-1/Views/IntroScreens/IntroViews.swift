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
    @Environment(\.colorScheme) var colorScheme

    

    var body: some View {
                TabView(selection: $selectedTab) {
                    // Category 1: Core Note-Taking
                    IntroView(title: "Essentials", content: [
                        (description: "Quick Entries: Jot down thoughts, plans, and notes. Each entry is timestamped and taggable with custom stamps.", imageName: "note.text"),
                        (description: "Stamps: Swipe right to reveal, tap to use. Define up to 21 stamps with unique icons and colors in Settings for easy identification and organization", imageName: "bookmark.fill"),
                        (description: "Easy Deletion: Swipe left to delete, with options to recover or permanently remove from Recently Deleted. Auto-delete after 10 days.", imageName: "trash")
                    ], color: userPreferences.accentColor)
                    .environmentObject(userPreferences)
                    .tag(0)
                    .transition(.slide)
                    
                    // Category 2: Organization and Customization
                    IntroView(title: "Organization and Customization", content: [
                        (description: "Pinning: Keep important entries accessible in main view across days.", imageName: "pin.fill"),
                        (description: "Add reminders to your entries with custom times and recurrence patterns for staying on top of tasks and notes.", imageName: "bell.fill"),
                        (description: "Personalization: Customize fonts, colors, reminders, pins, accents, and more.", imageName: "wand.and.stars")
                    ], color: userPreferences.accentColor)
                    .environmentObject(userPreferences)
                    .tag(1)
                    .transition(.slide)
                    
                    // Category 3: Multimedia and Data Management
                    IntroView(title: "Multimedia and Data Management", content: [
                        (description: "Add photos, GIFs, PDFs. Intuitive PDF reader for note-taking.", imageName: "photo.on.rectangle.angled"),
                        (description: "Data Backup: Backup logs, preferences, and stamps in Settings. Share stamp packs and themes with friends and ensure your data is always safe.", imageName: "externaldrive.badge.icloud"),
                        (description: "Lock your logs to keep it private.", imageName: "lock.fill")
                    ], color: userPreferences.accentColor)
                    .environmentObject(userPreferences)
                    .tag(2)
                    .transition(.slide)
                    
                }
                .tabViewStyle(PageTabViewStyle()).pickerColor(userPreferences.backgroundColors[1] ?? Color.clear)
                .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {

                    Button(action: {
                        if userPreferences.isFirstLaunch {
                            userPreferences.isFirstLaunch = false
                        }
                        presentationMode.wrappedValue.dismiss()
                 
                    }, label: {
                        Text("Done")
                            .font(.customHeadline)
                    })
            }
        }
        .background {
            userPreferences.backgroundView(colorScheme: colorScheme)
        }
    }
}


struct IntroView: View {
    var title: String
    var content: [(description: String, imageName: String?)] // Updated to accept multiple pairs
    var color: Color
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme


    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Spacer()
                Text(title)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))

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
                            .font(.customHeadline)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
                        
                        Spacer()
                    }
                }
                Spacer()
                Spacer()
            }
        }.padding(.horizontal)
    }
}
