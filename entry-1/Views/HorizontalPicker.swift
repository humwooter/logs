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
        let unselectedColor = Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme))
        let options = PickerOptions.allCases

        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
                                selectedOption = option
                            }
                        }) {
                            VStack {
                                Group {
                                    switch option.rawValue {
                                    case "Calendar":
                                        Image(systemName: "calendar")
                                    case "Folders":
                                        Image(systemName: "folder.fill")
                                    case "Reminders":
                                        Image(systemName: "bell.fill")
                                    default:
                                        Image(systemName: "magnifyingglass")
                                    }
                                }
                                .font(.customHeadline)
                                .foregroundColor(selectedOption == option ? userPreferences.accentColor : unselectedColor)
                                
                                if selectedOption == option {
                                    Circle()
                                        .fill(userPreferences.accentColor)
                                        .frame(width: 6, height: 6)
                                        .offset(y: 4)
                                        .matchedGeometryEffect(id: "underline", in: animation)
                                }
                            }
                            .frame(width: geometry.size.width / CGFloat(options.count))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 40)
        .animation(.interpolatingSpring(stiffness: 200, damping: 20), value: selectedOption)
    }
}
