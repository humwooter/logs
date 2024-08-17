//
//  HorizontalPicker.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 8/16/24.
//

import Foundation
import UIKit
import SwiftUI


enum PickerOptions: String, CaseIterable {
    case calendar = "Calendar"
    case folders = "Folders"
    case reminders = "Reminders"
    case search = "Search"
}


struct HorizontalPicker: View {
    @Binding var selectedOption: PickerOptions
    var animation: Namespace.ID

    @State private var underlineWidth: CGFloat = 0
    @State private var underlineX: CGFloat = 0
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        var unselectedColor: Color {
            return Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme))
        }
        let options = PickerOptions.allCases

        
        VStack {
            HStack(alignment: .center) {
                ForEach(options, id: \.self) { option in
                    GeometryReader { geo in
                        Button(action: {
                            withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
                                selectedOption = option
                                underlineWidth = geo.size.width
                                underlineX = geo.frame(in: .global).minX - (UIScreen.main.bounds.width / 2) + (underlineWidth / 2)
                            }
                        }) {
                            VStack {
                               if option.rawValue == "Calendar" {
                                    Image(systemName: "calendar.day.timeline.leading")
                                        .foregroundColor(selectedOption == option ? userPreferences.accentColor : unselectedColor)
                                } else if option.rawValue == "Folders" {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(selectedOption == option ? userPreferences.accentColor : unselectedColor)
                                } else if option.rawValue == "Reminders" {
                                    Image(systemName: "bell")
                                        .foregroundColor(selectedOption == option ? userPreferences.accentColor : unselectedColor)
                                }
                                else {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(selectedOption == option ? userPreferences.accentColor : unselectedColor)
                                }
                                if selectedOption == option {
                                    Circle()
                                        .fill(userPreferences.accentColor)
                                        .frame(width: 6, height: 6)
                                        .offset(y: 4)
                                        .matchedGeometryEffect(id: "underline", in: animation)
                                }
                            }
                            .padding(.horizontal)
                            .background(
                                Group {
                                    if selectedOption == option {
                                        Color.clear // This is needed for matchedGeometryEffect
                                    }
                                }
                            )
                        }
                        .onAppear {
                            if selectedOption == option {
                                underlineWidth = geo.size.width
                                underlineX = geo.frame(in: .global).minX - (UIScreen.main.bounds.width / 2) + (underlineWidth / 2)
                            }
                        }
                    }
                    .frame(maxWidth: 65, minHeight: 40)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .animation(.interpolatingSpring(stiffness: 200, damping: 20), value: options)

    }
}
