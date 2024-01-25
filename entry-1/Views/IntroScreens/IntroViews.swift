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

    var body: some View {
        TabView(selection: $selectedTab) {
            IntroView(title: "Quick Entries",
                      description: "Effortlessly jot down thoughts, plans, and notes. Each entry is timestamped and can be tagged with custom stamps."
            )
                .tag(0)

            IntroView(title: "Stamps",
                      description: "Personalize up to 21 stamps with unique colors and icons. Stamp entries for easy identification and organization."
            )
                .tag(1)


            IntroView(title: "Easy Deletion",
                      description: "Swipe right to delete entries. Recover or permanently remove them from Recently Deleted. Entries auto-delete after 10 days."
                     )
                .tag(7)
        }
        .tabViewStyle(PageTabViewStyle())
        .background {
                ZStack {
                    Color(UIColor.systemGroupedBackground)
                    LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                }
                .ignoresSafeArea()
        }
        .scrollContentBackground(.hidden)
        .animation(.easeInOut(duration: 0.5), value: selectedTab) // Add animation here
    }
}

struct IntroView: View {
    var title: String
    var description: String

    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .padding()

            Text(description)
                .font(.body)
                .padding()

            // Add additional UI elements based on userPreferences if needed
        }
    }
}
