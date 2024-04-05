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

var button_width : CGFloat = 82


struct Theme: Identifiable, Hashable {
    let id: UUID = UUID()
    var name: String
    var topColor: Color
    var bottomColor: Color
    var accentColor: Color
    var pinColor: Color
    var reminderColor: Color
    var entryBackgroundColor: Color
    var font: Font
}

struct ThemeEditView: View {
    @Binding var theme: Theme // Assuming 'Theme' is a struct containing the color information and font
    @State var isPresented = true
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            BackgroundColorPickerView(topColor: $theme.topColor, bottomColor: $theme.bottomColor)
            ColorPicker("Entry Background Color", selection: $theme.entryBackgroundColor, supportsOpacity: true)
            ColorPicker("Accent Color", selection: $theme.accentColor, supportsOpacity: true)

            ColorPicker("Pin Color", selection: $theme.pinColor, supportsOpacity: true)
            ColorPicker("Reminder Color", selection: $theme.reminderColor, supportsOpacity: true)
            
            // Additional fields for editing other properties like font name and size can be added here
            
            Button("Save Changes") {
                // Code to save changes, if necessary
                isPresented = false
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onChange(of: theme, { oldValue, newValue in
            print("topColor: \(newValue.topColor)")
            print("bottomColor: \(newValue.bottomColor)")
            print("entryBackgroundColor: \(newValue.entryBackgroundColor)")
            print("pinColor: \(newValue.pinColor)")
            print("reminderColor: \(newValue.reminderColor)")
        })
    }
}

struct ThemePicker: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) var colorScheme

    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    let themePresets: [Theme] = [
        Theme(name: "Sunset", topColor: .orange, bottomColor: .pink, accentColor: Color.white, pinColor: Color.red, reminderColor: .blue, entryBackgroundColor: .white.opacity(0.5), font: .title2),
        Theme(name: "Ocean", topColor: .blue, bottomColor: .green, accentColor: Color.yellow, pinColor: Color.red, reminderColor: .white, entryBackgroundColor: .white.opacity(0.5), font: .title2),
        Theme(name: "Forest", topColor: .green, bottomColor: .brown, accentColor: Color.pink, pinColor: Color.red, reminderColor: .mint, entryBackgroundColor: .white.opacity(0.5), font: .title2),
        Theme(name: "Sky", topColor: .blue, bottomColor: .white, accentColor: Color.mint, pinColor: Color.red, reminderColor: .red, entryBackgroundColor: .white, font: .title2)
    ]
    
    
    @State var newThemePresets: [Theme] = [
        Theme(name: "test", topColor: Color(UIColor(red: 0.99, green: 0.87, blue: 0.81, alpha: 1.0)), bottomColor: Color(UIColor(red: 0.99, green: 0.82, blue: 0.75, alpha: 1.0)), accentColor: Color.white, pinColor: Color(UIColor(red: 0.99, green: 0.87, blue: 0.81, alpha: 1.0)), reminderColor: Color(UIColor(red: 0.99, green: 0.87, blue: 0.81, alpha: 1.0)), entryBackgroundColor: Color(UIColor(red: 0.99, green: 0.92, blue: 0.88, alpha: 1.0)), font: .title2)
    ]
    @State private var selectedThemeIndex: Int = 0 // Store index instead of Theme directly
      @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(newThemePresets.indices, id: \.self) { index in
                            let theme = newThemePresets[index]
                            VStack {
                                Text(theme.name)
                                    .font(theme.font) // Assuming each theme has a 'font' property for customization
                                    .font(.custom(userPreferences.fontName, size: CGFloat(userPreferences.fontSize)))
                                    .padding(.bottom, 5)
                                combinedBlock(topColor: theme.topColor, bottomColor: theme.bottomColor, entryColor: theme.entryBackgroundColor, accentColor: theme.accentColor, pinColor: theme.pinColor, reminderColor: theme.reminderColor)
                            }
                            .padding(10)
                            .onTapGesture {
                                self.selectedThemeIndex = index // Save index of selected theme
                                self.showingEditSheet = true
                            }
                        }
                    }
                    .padding()
                }
        .sheet(isPresented: $showingEditSheet, onDismiss: saveChanges) {
//                   if let index = selectedThemeIndex {
                       ThemeEditView(theme: $newThemePresets[selectedThemeIndex]) // Pass binding to the element
//                   }
               }
        
//        ScrollView {
//            LazyVGrid(columns: columns, spacing: 20) {
//                ForEach(newThemePresets, id: \.self) { theme in
//                    VStack {
//                        Text(theme.name)
//                            .font(theme.font) // Assuming each theme has a 'font' property for customization
//                            .font(.custom(userPreferences.fontName, size: CGFloat(userPreferences.fontSize)))
//                            .padding(.bottom, 5)
//                        combinedBlock(topColor: theme.topColor, bottomColor: theme.bottomColor, entryColor: theme.entryBackgroundColor, accentColor: theme.accentColor, pinColor: theme.pinColor, reminderColor: theme.reminderColor)
//
//                    }
//                    
////                    .contextMenu(ContextMenu(menuItems: {
////                        NavigationLink(destination: ThemeEditView(theme: $newThemePresets[0])) {
////                            Text("Edit")
////                        }
////                    }))
//                    .padding(10)
//                    
//                }
//            }
//            .padding()
//        }
    }
    
    private func saveChanges() {
        // This function gets called when the sheet is dismissed.
        // If needed, perform additional actions to save changes,
        // but normally the binding should handle updates automatically.
    }

    @ViewBuilder
    func currentTheme() -> some View {
        VStack {
            Text("Current theme")
                .font(.custom(userPreferences.fontName, size: CGFloat(userPreferences.fontSize)))
                .padding(.bottom, 5)
            combinedBlock(topColor: userPreferences.backgroundColors.first ?? Color.clear, bottomColor: userPreferences.backgroundColors[1] ?? Color.clear, entryColor: userPreferences.entryBackgroundColor, accentColor: userPreferences.accentColor, pinColor: userPreferences.pinColor, reminderColor: userPreferences.reminderColor)
        }
    }
    
    @ViewBuilder
    func combinedBlock(topColor: Color, bottomColor: Color, entryColor: Color, accentColor: Color, pinColor: Color, reminderColor: Color) -> some View {
        ZStack {
            // Background block
            backgroundBlock(topColor: topColor, bottomColor: bottomColor)
                .overlay(
                    ZStack {
                        RoundedRectangle(cornerRadius: 15) // Use the same cornerRadius as your blocks
                            .stroke(accentColor, lineWidth: 5) // This creates the border
                        VStack(spacing: 5) { // Control the spacing directly within the VStack
                            
                            HStack {
                                // Pin icon on the left
                                Image(systemName: "pin.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25) // Uniform size for icons
                                    .foregroundColor(pinColor)
                                
                                Spacer() // This pushes the icons to the edges and keeps them equidistant from the center block
                                
                                // Bell icon on the right
                                Image(systemName: "bell.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25) // Uniform size for icons
                                    .foregroundColor(reminderColor)
                            }
                            .padding(.horizontal) // Horizontal padding to push icons towards the edges
                            .padding(.top, 20)
                            
                            // Entry background block
                            entryBackgroundBlock(color: entryColor)
                                .frame(width: 60, height: 60) // Explicitly set the size of the entry block
                                .padding(.bottom)
                            
                        }
                        .frame(maxHeight: .infinity) // Ensures VStack takes up maximum available height

//                        VStack {
//                        
//                            HStack {
//                                // Pin icon on the left/top
//                                Image(systemName: "pin.fill").imageScale(.large)
//                                    .foregroundColor(pinColor)
//            //                        .scaleEffect(0.5) // Adjust based on your design needs
//                                
//                                Spacer()
//                                
//                                // Bell icon on the right/top
//                                Image(systemName: "bell.fill").imageScale(.large)
//                                    .foregroundColor(reminderColor)
//            //                        .scaleEffect(0.5) // Adjust based on your design needs
//                            }
//                            .padding(.horizontal) // Add some padding to push icons to the edges
//                            .padding(.top, 20)
//
//                            
//                            entryBackgroundBlock(color: entryColor)
//                                .scaleEffect(0.6) // Adjust this value to control the size relative to the background block
//                            
//                        }
//                        .padding(.top, 10) // This pushes the icons slightly down from the top edge
                    }
                )
            
//            VStack {
//                Spacer()
//                Spacer()
//                Spacer()
//                HStack {
//                    // Pin icon on the left/top
//                    Image(systemName: "pin.fill").imageScale(.large)
//                        .foregroundColor(pinColor)
////                        .scaleEffect(0.5) // Adjust based on your design needs
//                    
//                    Spacer()
//                    
//                    // Bell icon on the right/top
//                    Image(systemName: "bell.fill").imageScale(.large)
//                        .foregroundColor(reminderColor)
////                        .scaleEffect(0.5) // Adjust based on your design needs
//                }
//                .padding(.horizontal) // Add some padding to push icons to the edges
//                
//                Spacer()
//                Spacer()
//                Spacer()
//                entryBackgroundBlock(color: entryColor)
//                    .scaleEffect(0.4) // Adjust this value to control the size relative to the background block
//                    .padding(10) // Adjust padding to control the position
//            }
//            .padding(.top, 10) // This pushes the icons slightly down from the top edge
            
//            // Entry background block in the center
//            VStack {
//                Spacer()
//                entryBackgroundBlock(color: entryColor)
//                    .scaleEffect(0.4) // Adjust this value to control the size relative to the background block
//                    .padding(10) // Adjust padding to control the position
//            }
        }
//        .clipShape(RoundedRectangle(cornerRadius: 15)) // Ensure the outer shape also has rounded corners
    }


    
    
    @ViewBuilder
    func backgroundBlock(topColor: Color, bottomColor: Color) -> some View {
        
        if isClear(for: UIColor(topColor)) && isClear(for: UIColor(bottomColor)) {
            RoundedRectangle(cornerRadius: 15)
                .fill(getDefaultBackgroundColor(colorScheme: colorScheme))
                .aspectRatio(1, contentMode: .fit) // Keep the block square-shaped
        } else {
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(gradient: Gradient(colors: [topColor, bottomColor]), startPoint: .top, endPoint: .bottom))
                .aspectRatio(1, contentMode: .fit) // Keep the block square-shaped
        }
    }
    
    @ViewBuilder
    func entryBackgroundBlock(color: Color) -> some View {
        if isClear(for: UIColor(color)) {
            let newColor = Color("DefaultEntryBackground")
            RoundedRectangle(cornerRadius: 15)
                .fill(newColor)
                .aspectRatio(1, contentMode: .fit) // Keep the block square-shaped
                .onAppear {
                    print("ENTRY BACKGROUND IS CLEAR")
                }
        }
        else {
            RoundedRectangle(cornerRadius: 15)
                .fill(color)
                .aspectRatio(1, contentMode: .fit) // Keep the block square-shaped
        }
    }
}




struct ButtonDashboard: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var showAlert = false
    @State private var selectedTab = 0
    var customStampTip: CustomStampTip = CustomStampTip()


        var body: some View {
            VStack(alignment: .center) {
                    HStack {
                        Spacer()

                        TabView(selection: $selectedTab) {
                            ForEach(0..<3) { tabPage in
                                dashboardSection(startIndex: tabPage*7)
                                    .tag(tabPage)
                                
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))

                        Spacer()
                    }
            }
            .frame(minWidth: 4.3*button_width, minHeight: 4.3*button_width)
            .scaledToFit()

          }
    
    
    @ViewBuilder
    private func dashboardSection(startIndex: Int) -> some View {
        VStack {
            Spacer()
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

                    .frame(width: button_width, height: button_width)
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
    }
}



struct IconPicker: View {
    @Binding var selectedImage: String
    @Binding var selectedColor: Color
    @Binding var accentColor: Color
    @State private var searchText = ""
    
//    @State var backgroundColors: [Color]
    
    @Binding var topColor_background: Color
    @Binding var bottomColor_background: Color

    
    var buttonIndex: Int
    var inputCategories: [String: [String]]
    let gridLayout: [GridItem] = [
        .init(.flexible(), spacing: 10),
        .init(.flexible(), spacing: 10),
        .init(.flexible(), spacing: 10),
        .init(.flexible(), spacing: 10)

    ]

    
    var body: some View {
        
        Section(header: 
                    Text("Stamp \(buttonIndex + 1)").foregroundStyle(UIColor.foregroundColor(background: UIColor(topColor_background ?? Color.gray))).opacity(0.4)
            .font(.system(size: UIFont.systemFontSize))

        ) {
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
        NavigationStack {
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
            .searchable(text: $searchText).font(.system(size: UIFont.systemFontSize))
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

//        .onChange(of: bottomColor) { oldValue, newValue in
//            print("CHANGED TAB BAR")
//            UITabBar.appearance().unselectedItemTintColor = UIColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(newValue))).opacity(0.5))
//        }

    }
}




