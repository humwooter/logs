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
import TipKit




struct ButtonDashboard: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var showAlert = false
    @State private var selectedTab = 0
    var customStampTip: CustomStampTip = CustomStampTip()


        var body: some View {
              VStack {
                  
                  HStack {
                      Text("STAMPS").font(.custom(userPreferences.fontName, size: userPreferences.fontSize + 3)).bold()
                  }

                  dashboardSection(startIndex: selectedTab*7)

                  // TabView at the bottom
                  TabView(selection: $selectedTab) {
                      ForEach(0..<3) { tabPage in
                          Text("") // Placeholder for tab content
                              .tag(tabPage) // Important to set the tag for selection
                      }
                  }
                  .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                  .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always)) // so that it will show up in light mode against a white background

//
              }.padding(.top, 35)
          }
    
    
    @ViewBuilder
    private func dashboardSection(startIndex: Int) -> some View {
//        let startIndex = startIndex * 7
        VStack {
            Spacer()
//            Text("STAMPS").font(.custom(userPreferences.fontName, size: userPreferences.fontSize + 3)).bold()
//            Spacer()
            HStack(alignment: .center, spacing: 20) {
                ForEach(startIndex..<startIndex+2, id: \.self) { index in
                    
                    buttonSection(index: index)
                }
            }
            HStack(alignment: .center, spacing: 20) {
                ForEach(startIndex+2..<startIndex+5, id: \.self) { index in
                    buttonSection(index: index)
                }
            }
            HStack(alignment: .center, spacing: 20) {
                ForEach(startIndex+5..<startIndex+7, id: \.self) { index in
                    buttonSection(index: index)
                }
            }
            Spacer()
        }
        .alert(isPresented: $showAlert) {
             Alert(title: Text("Limit Reached"), message: Text("No more than 3 stamps can be activated at a time."), dismissButton: .default(Text("OK")))
         }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private func buttonSection(index: Int) -> some View {
        let stamp = userPreferences.stamps[index]
        VStack {
            ZStack {
                Rectangle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(
                                colors: stamp.isActive ?
                                    [stamp.color, Color(UIColor.tertiarySystemBackground)] :
                                    [Color(UIColor.tertiarySystemBackground), stamp.color.opacity(0.35)]
                            ),
                            center: .center,
                            startRadius: 200,
                            endRadius: 0
                        )
                    )

                    .frame(width: 82, height: 82)
                    .opacity(stamp.isActive ? 1 : 0.3)
                    .cornerRadius(40)
                    .shadow(radius: stamp.isActive ? 5 : 0)
                VStack(alignment: .center, spacing: 2) {
                        Image(systemName: stamp.imageName).fontWeight(.bold)
                        .foregroundColor(stamp.isActive ? stamp.color : Color.gray.opacity(0.3))
                            .padding(.vertical, 5)
                    ToggleButton(isOn: Binding(
                                       get: { stamp.isActive },
                                       set: { newValue in
                                           if userPreferences.stamps.filter({ $0.isActive }).count < 3 || stamp.isActive {
                                               userPreferences.stamps[index].isActive = newValue
                                           } else {
                                               showAlert = true
                                           }
                                       }
                                   ), color: stamp.color)
                }
            }
        }
        .onTapGesture {
            print("INDEX: \(index)")
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
    
    var body: some View {
//        Section(header: Text("Font Family")) {
            NavigationLink(destination: fontListView()) {
                HStack {
                    Text("Font Family")
                    Spacer()
                    Text(selectedFont)

                }
            }
//        }
//        Section(header: Text("Font Size")) {
        HStack {
            Text("Font Size")
            Slider(value: $selectedFontSize, in: 10...30, step: 1, label: { Text("Font Size") })
        }
//        }
    }
    
    func fontListView() -> some View {
        List {
            ForEach(inputCategories.keys.sorted(), id: \.self) { category in
                let filteredFonts = inputCategories[category]!.filter { searchText.isEmpty ? true : $0.lowercased().contains(searchText.lowercased()) }
                if (!filteredFonts.isEmpty) {
                    
                    Section(header: Text(category).bold()) {
                        ForEach(filteredFonts, id: \.self) { font in
                            
                            HStack {
                                Text(font)
                                    .font(Font.custom(font, size: selectedFontSize))
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


struct BackgroundColorPickerView: View {
    @Binding var topColor: Color
    @Binding var bottomColor: Color
    @State var defaultColor = Color.clear
    var body: some View {
        Section {
            HStack() {
                VStack {
                    ColorPicker("Top Color", selection: $topColor, supportsOpacity: false)
              
                    ColorPicker("Bottom Color", selection: $bottomColor, supportsOpacity: false)
                }
                .padding()
                .shadow(radius: 1)
                
                
                LinearGradient(gradient: Gradient(colors: [topColor, bottomColor]), startPoint: .top, endPoint: .bottom)
                    .frame(height: 100)
                    .cornerRadius(10)
                    .shadow(radius: 1)
            }
        } header: {
            HStack {
                Spacer()
                Label("Reset to default", systemImage: "gobackward").foregroundStyle(.red)
                    .onTapGesture {
                        vibration_light.impactOccurred()
                        topColor = defaultColor
                        bottomColor = defaultColor
                    }
                    .padding(1)
            }
        }

    }
}
