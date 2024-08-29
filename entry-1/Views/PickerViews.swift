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

//var button_width : CGFloat = UIScreen.main.bounds.height/10





struct ButtonDashboard: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var showAlert = false
    @State private var selectedTab = 0
    var customStampTip: CustomStampTip = CustomStampTip()
    @State private var isIpad = UIDevice.current.userInterfaceIdiom == .pad

        var body: some View {
            let buttonWidth = isIpad ? UIScreen.main.bounds.width/5 : UIScreen.main.bounds.width/4.5

            dashboardView(button_width: CGSize.smallButtonWidth)

          }
    
    
    @ViewBuilder
    func dashboardView(button_width: CGFloat) -> some View {
        VStack(alignment: .center) {
                HStack {
                    Spacer()

                    TabView(selection: $selectedTab) {
                        ForEach(0..<3) { tabPage in
                            dashboardSection(startIndex: tabPage*7, buttonWidth: button_width)
                                .tag(tabPage)
                            
                        }
                    }
                    .frame(minWidth: 4.3*button_width, minHeight: 4.3*button_width)
                    .padding()
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    .font(.customHeadline)

                    Spacer()
                }
        }
    }
    
    
    @ViewBuilder
    private func dashboardSection(startIndex: Int, buttonWidth: CGFloat) -> some View {
        VStack {
            Spacer()
            HStack(alignment: .center, spacing: 0) {
                ForEach(startIndex..<startIndex+2, id: \.self) { index in
                    
                    if index != startIndex+1 {
                        buttonSection(index: index, button_width: buttonWidth)
                            .padding(.trailing)
                    } else {
                        buttonSection(index: index, button_width: buttonWidth)

                    }
                
                    
                }
            }
            HStack(alignment: .center, spacing: 0) {
                ForEach(startIndex+2..<startIndex+5, id: \.self) { index in
                    
                    if index != startIndex+4 {
                        buttonSection(index: index, button_width: buttonWidth)
                            .padding(.trailing)
                    } else {
                        buttonSection(index: index, button_width: buttonWidth)

                    }
                }
            }
            HStack(alignment: .center, spacing: 0) {
                ForEach(startIndex+5..<startIndex+7, id: \.self) { index in
                    if index != startIndex+6 {
                        buttonSection(index: index, button_width: buttonWidth)
                            .padding(.trailing)
                    } else {
                        buttonSection(index: index, button_width: buttonWidth)

                    }

                }
            }
            Spacer()
        }
        .alert(isPresented: $showAlert) {
             Alert(title: Text("Limit Reached"), message: Text("No more than 3 stamps can be activated at a time."), dismissButton: .default(Text("OK")))
         }
    }
    
    @ViewBuilder
    private func buttonSection(index: Int, button_width: CGFloat) -> some View {
        let stamp = userPreferences.stamps[index]
//        let button_width = isIpad ? UIScreen.main.bounds.width/5 : UIScreen.main.bounds.width/5
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

                    .frame(width: button_width, height: button_width)
                    .opacity(stamp.isActive ? 1 : 0.3)
                    .cornerRadius(100)
                    .shadow(radius: stamp.isActive ? 5 : 0)
                VStack(alignment: .center, spacing: 2) {
                    if isIpad {
                        Image(systemName: stamp.imageName).resizable().scaledToFit().frame(width: button_width/5, height: button_width/5)
                            .foregroundColor(stamp.isActive ? stamp.color : Color.gray.opacity(0.3))
                            .padding(.vertical, 5).onTapGesture {
                                if userPreferences.stamps.filter({ $0.isActive }).count < 3 {
                                    
                                    userPreferences.stamps[index].isActive = !userPreferences.stamps[index].isActive //toggle
                                } else {
                                    if userPreferences.stamps.filter({ $0.isActive }).count == 3 && userPreferences.stamps[index].isActive {
                                        //                                    vibration_medium.impactOccurred()
                                        userPreferences.stamps[index].isActive = false
                                    } else {
                                        showAlert = true
                                    }
                                }
                            }
                    } else {
                        Image(systemName: stamp.imageName).bold()
                            .foregroundColor(stamp.isActive ? stamp.color : Color.gray.opacity(0.3))
                            .padding(.vertical, 5).onTapGesture {
                                if userPreferences.stamps.filter({ $0.isActive }).count < 3 {
                                    
                                    userPreferences.stamps[index].isActive = !userPreferences.stamps[index].isActive //toggle
                                } else {
                                    if userPreferences.stamps.filter({ $0.isActive }).count == 3 && userPreferences.stamps[index].isActive {
                                        //                                    vibration_medium.impactOccurred()
                                        userPreferences.stamps[index].isActive = false
                                    } else {
                                        showAlert = true
                                    }
                                }
                            }
                    }
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
 
        }.onAppear {
            userPreferences.stamps[index].index = index
        }
    }
}



struct IconPicker: View {
    @Binding var selectedImage: String
    @Binding var selectedColor: Color
    @State var defaultTopColor: Color
    @Binding var accentColor: Color
    @State private var searchText = ""
    @FocusState private var focusField: Bool
    @Environment(\.colorScheme) var colorScheme

//    @State var backgroundColors: [Color]
    
    @Binding var topColor_background: Color
    @Binding var bottomColor_background: Color
    @State var isEditingStampName = false
    
    var buttonIndex: Int
    @Binding var buttonName: String
    var inputCategories: [String: [String]]
    let gridLayout: [GridItem] = [
        .init(.flexible(), spacing: 10),
        .init(.flexible(), spacing: 10),
        .init(.flexible(), spacing: 10),
        .init(.flexible(), spacing: 10)

    ]

    
    var body: some View {
        
        Section {
            NavigationLink(destination: imageListView()) {
                HStack {
                    Text(selectedImage)
                    Spacer()
                    Image(systemName: selectedImage).foregroundColor(selectedColor)

                }
            }
            ColorPicker("Stamp Color", selection: $selectedColor)

        } header:{
            HStack {
                if isEditingStampName {
                    TextField("Stamp Name", text: $buttonName, prompt:
                                Text( "Enter Stamp Name").foregroundStyle(accentColor))
                        .focused($focusField)

                    Spacer()
                    Image(systemName: "checkmark").foregroundStyle(.green)
                        .onTapGesture {
                            withAnimation {
                                isEditingStampName = false
                            }
                        }
                } else {
                    if buttonName.isEmpty {
                        Text("Stamp \(buttonIndex + 1)").foregroundStyle(getIdealHeaderTextColor())
                    } else {
                        Text(buttonName).foregroundStyle(getIdealHeaderTextColor())
                    }
                    Spacer()
//                    Image(systemName: "pencil").foregroundStyle(accentColor)
//                        .onTapGesture {
//                            isEditingStampName.toggle()
//                        }
                }
            }
            .foregroundStyle(UIColor.foregroundColor(background: UIColor(topColor_background ?? Color.gray))).opacity(0.4)
            .font(.customHeadline)
        }
    }
    
    func getIdealHeaderTextColor() -> Color {
        return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(topColor_background), and: UIColor(bottomColor_background)), colorScheme: colorScheme))
    }
    
    func imageListView() -> some View {
        let backgroundColor = isClear(for: UIColor(topColor_background)) ? defaultTopColor : topColor_background
        return NavigationStack {
            ScrollView {
                ForEach(inputCategories.keys.sorted(), id: \.self) { category in
                    let filteredImages = inputCategories[category]!.filter { searchText.isEmpty ? true : $0.contains(searchText) }
                    if (!filteredImages.isEmpty) {
                        // Display the category header
                        Text(category)
                            .bold()
                            .font(.buttonSize).foregroundStyle(Color(UIColor.fontColor(forBackgroundColor: UIColor(backgroundColor))))
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 10) // Left padding for alignment
                        
                        LazyVGrid(columns: gridLayout, spacing: 10) {
                            
                            
                            // Display images for the category
                            ForEach(filteredImages, id: \.self) { image in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedImage != image ? Color("DefaultEntryBackground").opacity(1) : selectedColor)
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
                    } else {
                        ZStack {
                            Color.clear
                                .ignoresSafeArea()
                        }
                    }
                }
                .padding(.horizontal, 10) // Horizontal padding for the entire grid
            }
            .background {
                    ZStack {
                        Color(UIColor.systemGroupedBackground)
                        LinearGradient(colors: [topColor_background, bottomColor_background],  startPoint: .top, endPoint: .bottom)
                            .ignoresSafeArea()
                    }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Button \(buttonIndex + 1)")
            .searchable(text: $searchText)
            .font(.buttonSize)
            .searchBarTextColor(isClear(for: UIColor(topColor_background)) ? defaultTopColor : topColor_background)
        }

    }
}

struct FontPicker: View {
    @Binding var selectedFont: String
    @Binding var selectedFontSize: CGFloat
    @Binding var accentColor: Color
    var inputCategories: [String: [String]]
    @State private var searchText = ""
    
    @Binding var topColor_background: Color
    @Binding var bottomColor_background: Color
    @State var defaultTopColor: Color
    
    var body: some View {
            NavigationLink(destination: fontListView()) {
                HStack {
                    Text("Font Family")
                    Spacer()
                    Text(selectedFont)

                }
            }

        HStack {
            Text("Font Size")
            Slider(value: $selectedFontSize, in: 5...30, step: 0.5, label: { Text("Font Size") })
        }
    }
    
    func fontListView() -> some View {
        List {
            ForEach(inputCategories.keys.sorted(), id: \.self) { category in
                let filteredFonts = inputCategories[category]!.filter { searchText.isEmpty ? true : $0.lowercased().contains(searchText.lowercased()) }
                if (!filteredFonts.isEmpty) {
                    
                    Section(header: Text(category).bold().foregroundStyle(UIColor.foregroundColor(background: UIColor(topColor_background ?? Color.gray))).opacity(0.4)) {
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
        .background {
                ZStack {
                    Color(UIColor.systemGroupedBackground)
                    LinearGradient(colors: [topColor_background, bottomColor_background],  startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Font Type")
        .searchable(text: $searchText)
        .font(.customHeadline)
        .searchBarTextColor(isClear(for: UIColor(topColor_background)) ? defaultTopColor : topColor_background)
    }
    
}


struct BackgroundColorPickerView: View {
    @Binding var topColor: Color
    @Binding var bottomColor: Color
    @State var defaultColor = Color.clear
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Section {
            HStack() {
                VStack {
                    ColorPicker("Top Color", selection: $topColor, supportsOpacity: false)
              
                    ColorPicker("Bottom Color", selection: $bottomColor, supportsOpacity: false)
                }
                .shadow(radius: 1)
                
                
                LinearGradient(gradient: Gradient(colors: [topColor, bottomColor]), startPoint: .top, endPoint: .bottom)
                    .frame(height: 100)
                    .cornerRadius(10)
                    .shadow(radius: 1)
            }
        } header: {
        }
    }
}



