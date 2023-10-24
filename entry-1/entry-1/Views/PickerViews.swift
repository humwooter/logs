//
//  PickerViews.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/24/23.
//

import Foundation
import SwiftUI
import CoreData
import UIKit






struct ButtonDashboard: View {
    @EnvironmentObject var userPreferences: UserPreferences
    var body : some View {
        VStack {

            Spacer()
            Text("BUTTON DASHBOARD")
                .bold()
            Spacer()
            HStack(alignment: .center, spacing: 45) {
                ForEach(0..<3, id: \.self) { index in
                    buttonSection(index: index)
                }
            }
            HStack(alignment: .center, spacing: 45) {
                ForEach(3..<5, id: \.self) { index in
                    buttonSection(index: index)
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private func buttonSection(index: Int) -> some View {
        Section {
            VStack(alignment: .center) {
                Text("Button \(index + 1)")
                    .multilineTextAlignment(.center)
                ToggleButton(isOn: $userPreferences.activatedButtons[index], color: userPreferences.selectedColors[index])
            }
        }
    }
}



struct IconPicker: View {
    @Binding var selectedImage: String
    @Binding var selectedColor: Color
    @Binding var accentColor: Color
    
    
    var buttonIndex: Int
    var inputCategories: [String: [String]]

    
    
    var body: some View {
        Section(header: Text("Button \(buttonIndex + 1)")) {
            NavigationLink(destination: imageListView()) {
                HStack {
                    Text(selectedImage)
                    Spacer()
                    Image(systemName: selectedImage).foregroundColor(selectedColor)

                }
            }
        }

    }
    
    func imageListView() -> some View {
        List {
            ForEach(inputCategories.keys.sorted(), id: \.self) { category in
                Section(header: Text(category).bold()) {
                    ForEach(inputCategories[category]!, id: \.self) { image in
                        HStack {
                            Image(systemName: image).foregroundColor(selectedColor)
                            Text(image)
                            Spacer()
                            if image == selectedImage {
                                Image(systemName: "checkmark").foregroundColor(accentColor)
                            }
                        }
//                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.selectedImage = image
                        }
                    }
                }
            }
        }
        .navigationTitle("Button \(buttonIndex + 1)")

    }

}

struct FontPicker: View {
    @Binding var selectedFont: String
    @Binding var selectedFontSize: CGFloat
    @Binding var accentColor: Color
    var inputCategories: [String: [String]]

    
    
    var body: some View {
        Section(header: Text("Font Family")) {
            NavigationLink(destination: fontListView()) {
                HStack {
                    Text("Font Type")
                    Spacer()
                    Text(selectedFont)

                }
            }
        }
        Section(header: Text("Font Size")) {
            Slider(value: $selectedFontSize, in: 10...30, step: 1, label: { Text("Font Size") })
        }
    }
    
    func fontListView() -> some View {
        List {
            ForEach(inputCategories.keys.sorted(), id: \.self) { category in
                Section(header: Text(category).bold()) {
                    ForEach(inputCategories[category]!, id: \.self) { font in
                        HStack {
                            Text(font)
                                .font(.custom(font, size: selectedFontSize))
                            Spacer()
                            if selectedFont == font {
                                Image(systemName: "checkmark").foregroundColor(accentColor)
                            }

            
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.selectedFont = font
                        }
                    }
                }
            }
      
        }
        .navigationTitle("Font Type")

    }

}
