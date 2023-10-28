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
            Text("STAMPS").font(.custom(userPreferences.fontName, size: userPreferences.fontSize + 3))
                .bold()
            Spacer()
            HStack(alignment: .center, spacing: 20) {
                ForEach(0..<3, id: \.self) { index in
                    buttonSection(index: index)
                }
            }
            HStack(alignment: .center, spacing: 20) {
                ForEach(3..<5, id: \.self) { index in
                    buttonSection(index: index)
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private func buttonSection(index: Int) -> some View {
        VStack {
            ZStack {

                Rectangle()
//                    .background(.white).opacity(0.03)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(
                                colors: userPreferences.activatedButtons[index] ?
                                    [userPreferences.selectedColors[index], .clear] :
                                    [.white, .clear]
                            ),
                            center: .center,
                            startRadius: 200,
                            endRadius: 0
                        )
                        )
                    .frame(width: 82, height: 82)

                    .opacity(userPreferences.activatedButtons[index] ? 1 : 0.3)
                    .cornerRadius(50)
                    .shadow(radius: 5)
                    


                VStack(alignment: .center, spacing: 2) {
                    if (userPreferences.activatedButtons[index]) {
                        Image(systemName: userPreferences.selectedImages[index]).fontWeight(.bold)
                            .foregroundColor(userPreferences.selectedColors[index])
                            .padding(.vertical, 5)
                    }
                    ToggleButton(isOn: $userPreferences.activatedButtons[index], color: userPreferences.selectedColors[index])
                }
            }
            Text("Stamp \(index + 1)")
                .font(.caption) // Smaller font to save space
        }
    }


}




struct IconPicker: View {
    @Binding var selectedImage: String
    @Binding var selectedColor: Color
    @Binding var accentColor: Color
    @State private var searchText = ""

    
    var buttonIndex: Int
    var inputCategories: [String: [String]]
    let gridLayout: [GridItem] = [
        .init(.flexible(), spacing: 10),
        .init(.flexible(), spacing: 10),
        .init(.flexible(), spacing: 10),

        .init(.flexible(), spacing: 10)

    ]


    
    
    var body: some View {
        
        Section(header: Text("Stamp \(buttonIndex + 1)")) {
            NavigationLink(destination: imageListView()) {
                HStack {
                    Text(selectedImage)
                    Spacer()
                    Image(systemName: selectedImage).foregroundColor(selectedColor)

                }
            }
            ColorPicker("Stamp Color", selection: $selectedColor)

        }
    }
    
    func imageListView() -> some View {
        ScrollView {
                ForEach(inputCategories.keys.sorted(), id: \.self) { category in
                    let filteredImages = inputCategories[category]!.filter { searchText.isEmpty ? true : $0.contains(searchText) }
                    if (!filteredImages.isEmpty) {
                        // Display the category header
                        Text(category)
                            .bold()
                            .font(.headline)
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 10) // Left padding for alignment
                        
                        LazyVGrid(columns: gridLayout, spacing: 10) {
                            
                            
                            // Display images for the category
                            ForEach(filteredImages, id: \.self) { image in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedImage != image ? Color(UIColor.secondarySystemBackground).opacity(1) : selectedColor)
                                        .frame(maxWidth: 70, minHeight: 70, maxHeight: 150)
                                    
                                    HStack {
                                        Image(systemName: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)  // Adjust width and height as needed
                                            .foregroundColor(
                                                selectedImage != image
                                                ? selectedColor
                                                : textColor(for: UIColor(selectedColor))
                                            )
                                    }
                                    .foregroundColor(
                                        selectedImage != image
                                        ? textColor(for: UIColor.secondarySystemBackground)
                                        : textColor(for: UIColor(selectedColor))
                                    )
                                }
                                .onTapGesture {
                                    if (selectedImage != image) {
                                        vibration_medium.prepare()
                                        vibration_medium.impactOccurred()
                                        self.selectedImage = image
                                    }
                                }
                            }
                        }
                    }
            }
            .padding(.horizontal, 10) // Horizontal padding for the entire grid
        }
        .navigationTitle("Button \(buttonIndex + 1)")
        .searchable(text: $searchText)


    }
}

struct FontPicker: View {
    @Binding var selectedFont: String
    @Binding var selectedFontSize: CGFloat
    @Binding var accentColor: Color
    var inputCategories: [String: [String]]
    @State private var searchText = ""
//
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
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
                let filteredFonts = inputCategories[category]!.filter { searchText.isEmpty ? true : $0.contains(searchText) }
                if (!filteredFonts.isEmpty) {
                    
                    Section(header: Text(category).bold()) {
                        ForEach(filteredFonts, id: \.self) { font in
                            
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
                                if (selectedFont != font) {
                                    vibration_medium.prepare()
                                    vibration_medium.impactOccurred()
                                    self.selectedFont = font
//                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }
            }
      
        }
        .navigationTitle("Font Type")
        .searchable(text: $searchText)
    }

}
