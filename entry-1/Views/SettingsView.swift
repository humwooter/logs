//
//  NewSettingsView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 4/10/24.
//

import Foundation
import SwiftUI
import CoreData
import UIKit
import LocalAuthentication
import UniformTypeIdentifiers



struct TempLog: Decodable {
    var id: UUID
    var day: String
    var relationship: String
}






struct SettingsView: View {
    // data management and environment objects
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var coreDataManager: CoreDataManager
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)]
    ) var logs: FetchedResults<Log>
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var datesModel: DatesModel

    // document picker and file handling
    @State private var isExportDocumentPickerPresented = false
    @State private var isImportDocumentPickerPresented = false
    @State private var tempFileURL: URL?
    @State private var selectedURL: URL?
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var isShareSheetPresented = false
    @State private var fileURLToShare: URL?

    // user interface state
    @State var advancedSettings = false
    @State private var selectedTab = 0
    @EnvironmentObject var tabSelectionInfo: TabSelectionInfo

    @Binding var isUnlocked: Bool
    @State var settingIconColors: [Color] = []

    @State private var isHiddenMediaManager = false


    
    var body: some View {

        NavigationStack {
            VStack {
                List {
                        if !settingIconColors.isEmpty {
                            alternateSettingsView().font(.system(size: UIFont.systemFontSize))
                        }

                }
            }
            .onChange(of: userPreferences.accentColor, { oldValue, newValue in
                var backgroundFontColor = UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear))
                var accentFontColor = UIColor.fontColor(forBackgroundColor: UIColor(newValue))
                UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(newValue)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor:  UIColor.fontColor(forBackgroundColor: UIColor(newValue ?? Color.clear))], for: .selected)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.fontColor(forBackgroundColor: getBackgroundColor())], for: .normal)
                UISegmentedControl.appearance().backgroundColor = UIColor.clear
            })
            .onChange(of: userPreferences.backgroundColors.first, { oldValue, newValue in
                var backgroundFontColor = UIColor.fontColor(forBackgroundColor: UIColor(newValue ?? Color.clear))
                var accentFontColor = UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.accentColor))
                UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(userPreferences.accentColor)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor:  UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.accentColor ?? Color.clear))], for: .selected)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.fontColor(forBackgroundColor: getBackgroundColor())], for: .normal)
                UISegmentedControl.appearance().backgroundColor = UIColor.clear
            })
            .background {
                    ZStack {
                        Color(UIColor.systemGroupedBackground)
                        LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                    }
                    .ignoresSafeArea()
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleTextColor(Color(UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.backgroundColors.first ?? Color.clear), colorScheme: colorScheme)))
            .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
            .accentColor(userPreferences.accentColor)
            .onAppear {
                settingIconColors = generateComplementaryColors(baseColor: userPreferences.accentColor)
            }

        }
        
    }
    
    
    @ViewBuilder
    func alternateSettingsView() -> some View {
                NavigationLink {
                    NavigationStack {
                        List {
                            generalTabView()
//                                    .dismissOnTabTap()
                        }.navigationTitle("General")
                        .background {
                                ZStack {
                                    Color(UIColor.systemGroupedBackground)
                                    LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                                }
                                .ignoresSafeArea()
                        }
                        .scrollContentBackground(.hidden)
                    }
                } label: {
                    Label(
                        title: { Text("General")
                        },
                        icon: { settingsIconView(systemImage: "gearshape.fill")}
                    )
                }
                
        Section {
            
            NavigationLink {
                NavigationStack {
                    List {
                        stampsTabView()
                        
                    }.navigationTitle("Stamps")
                    .background {
                        ZStack {
                            Color(UIColor.systemGroupedBackground)
                            LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                        }
                        .ignoresSafeArea()
                    }
                    .scrollContentBackground(.hidden)
                }
            } label: {
                Label(
                    title: { Text("Stamps")
                    },
                    icon: { settingsIconView(systemImage: "hare.fill")}
                )
            }
            
            NavigationLink {
                NavigationStack {
                    List {
                        preferencesTabView().dismissOnTabTap()
                        
                    }.navigationTitle("Apperance")
                    .background {
                        ZStack {
                            Color(UIColor.systemGroupedBackground)
                            LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                        }
                        .ignoresSafeArea()
                    }
                    .scrollContentBackground(.hidden)
                }
            } label: {
                Label(
                    title: { Text("Appearance")
                    },
                    icon: { settingsIconView(systemImage: "textformat.size")}
                )
            }
            
            
            appTabView()
            
        }
        NavigationLink {
            NavigationStack {
                List {
                    dataTabView()
                }
                .navigationTitle("Data")
                .background {
                        ZStack {
                            Color(UIColor.systemGroupedBackground)
                            LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                        }
                        .ignoresSafeArea()
                }
                .scrollContentBackground(.hidden)
            }
        } label: {
            Label(
                title: { Text("Data").font(.system(size: UIFont.systemFontSize))
                },
                icon: { settingsIconView(systemImage: "arrow.up.arrow.down")}
            )
        }
        
        NavigationLink {
            NavigationStack {
                List {
                    introScreenViews()
                }
                .navigationTitle("Information").font(.system(size: UIFont.systemFontSize))
                .background {
                        ZStack {
                            Color(UIColor.systemGroupedBackground)
                            LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                        }
                        .ignoresSafeArea()
                }
                .scrollContentBackground(.hidden)
            }
        } label: {
            Label(
                title: { Text("Info").font(.system(size: UIFont.systemFontSize))
                },
                icon: { settingsIconView(systemImage: "info")}
            )
        }
    }
    
    @ViewBuilder
    func appTabView() -> some View {
        NavigationLink {
            NavigationStack {
                List {
                    appIconView()
                }
                .navigationTitle("App Icon")
                .background {
                        ZStack {
                            Color(UIColor.systemGroupedBackground)
                            LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
                        }
                        .ignoresSafeArea()
                }
                .scrollContentBackground(.hidden)
            }
        } label: {
            Label(
                title: { Text("App Icon").font(.system(size: UIFont.systemFontSize))
                },
                icon: {
                    settingsIconView(systemImage: "app_icon")}
            )
        }
    }
    
    
    @ViewBuilder
    func appIconView() -> some View {
        
            Picker(selection: $userPreferences.activeAppIcon) {
                let customAppIcons : [String] = ["AppIcon-1", "AppIcon-2", "AppIcon-3"]
                ForEach(customAppIcons, id: \.self) { icon in
                    HStack {
                        Image(icon).cornerRadius(5)
                        Spacer()
                        if icon == "AppIcon-1" {
                            Text("\(icon) (Default)")
                        } else {
                            Text(icon)
                        }
                    }
                        .tag(icon)
                }
            } label: {
                if let currentIcon = UIImage(named: userPreferences.activeAppIcon) {
                    Image(uiImage: currentIcon).resizable().frame(maxWidth: 100, maxHeight: 100).cornerRadius(10)
                }
            }
        .onChange(of: userPreferences.activeAppIcon) { oldValue, newValue in
            UIApplication.shared.setAlternateIconName(newValue)
        }
    }
    
    @ViewBuilder
    func introScreenViews() -> some View {
        Section(header: Text("About").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
            .font(.system(size: UIFont.systemFontSize))

        ) {
            
            NavigationLink {
                NavigationStack {
                    VStack {
                        IntroViews()
                            .environmentObject(userPreferences)
                            .dismissOnTabTap()
                    }
                }
            } label: {
                Label("User Guide", systemImage: "info.circle.fill")
            }
            
        }
    }
    
    @ViewBuilder
    func settingsIconView(systemImage: String) -> some View {
        ZStack {
            if systemImage == "app_icon" {
                Image(uiImage: UIImage(named: "app_icon.svg")!).resizable().scaledToFit().foregroundStyle(userPreferences.accentColor)
                
            } else {
                Image(systemName: systemImage)
                    .foregroundColor(userPreferences.accentColor)
                    .scaledToFit()
            }

        }
        .padding(.vertical, 1)
            .font(.system(size: UIFont.systemFontSize))
    }


    
    @ViewBuilder
    func tabPickerView() -> some View {

        Picker("Options", selection: $selectedTab) {
            Text("General").padding(20).tag(0)
            Text("Stamps").padding(20).tag(2)
        }.padding()
      

        .background {
            ZStack {
                Color(UIColor.tertiarySystemBackground)
            }
        }
        .pickerStyle(.segmented).cornerRadius(5)
  
        .onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(userPreferences.accentColor)
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor:  UIColor.fontColor(forBackgroundColor: UIColor(userPreferences.accentColor ?? Color.clear))], for: .selected)
              UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.fontColor(forBackgroundColor: getBackgroundColor())], for: .normal)
            UISegmentedControl.appearance().backgroundColor = UIColor.clear

        }
    }
    
    func getBackgroundColor() -> UIColor {
        if isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) {
            return UIColor(getDefaultBackgroundColor(colorScheme: colorScheme))
        } else{
            return UIColor(userPreferences.backgroundColors.first ?? Color.clear)
        }
    }
    @ViewBuilder
    func stampsTabView() -> some View {
        Section(header: Text("Stamp Dashboard").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
            .font(.system(size: UIFont.systemFontSize))
        ) {
            ButtonDashboard().environmentObject(userPreferences)
                .listStyle(.automatic)
                .padding(.horizontal, 5)
             
        }
        ForEach(0..<userPreferences.stamps.count, id: \.self) { index in
            if userPreferences.stamps[index].isActive {
                IconPicker(selectedImage: $userPreferences.stamps[index].imageName, selectedColor: $userPreferences.stamps[index].color, accentColor: $userPreferences.accentColor, topColor_background: $userPreferences.backgroundColors[0], bottomColor_background: $userPreferences.backgroundColors[1], buttonIndex: index, inputCategories: imageCategories)
            }
        }

//        StampDataView() // for importing and exporting stamp data
//            .environmentObject(userPreferences)
    }
    
    @ViewBuilder
    func preferencesTabView() -> some View {
        
        Section(header: Text("Preferences").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
            .font(.system(size: UIFont.systemFontSize))
        ) {
            ColorPicker("Accent Color", selection: $userPreferences.accentColor)
            FontPicker(selectedFont:  $userPreferences.fontName, selectedFontSize: $userPreferences.fontSize, accentColor: $userPreferences.accentColor, inputCategories: fontCategories, topColor_background: $userPreferences.backgroundColors[0], bottomColor_background: $userPreferences.backgroundColors[1])
            HStack {
                Text("Line Spacing")
                Slider(value: $userPreferences.lineSpacing, in: 0...15, step: 1, label: { Text("Line Spacing") })
            }
        }
        
        Section {
            BackgroundColorPickerView(topColor: $userPreferences.backgroundColors[0], bottomColor: $userPreferences.backgroundColors[1])
        } header: {
            
            HStack {
                Text("Background Colors").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                    .font(.system(size: UIFont.systemFontSize))
                Spacer()
                Label("reset", systemImage: "gobackward").foregroundStyle(.red)
                    .onTapGesture {
                        vibration_light.impactOccurred()
                        userPreferences.backgroundColors[0] = .clear
                        userPreferences.backgroundColors[1] = .clear
                    }
            }
        }
        
        Section {
                ColorPicker("Default Entry Background Color:", selection: $userPreferences.entryBackgroundColor)
      
        } header: {
            HStack {
                Text("Entry Background").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                    .font(.system(size: UIFont.systemFontSize))
                Spacer()
                Label("reset", systemImage: "gobackward").foregroundStyle(.red)
                    .onTapGesture {
                        vibration_light.impactOccurred()
                        userPreferences.entryBackgroundColor = .clear
                    }
            }
        }


        Section {
            ColorPicker("Pin Color", selection: $userPreferences.pinColor)
        } header: {
            HStack {
                Text("Pin Color").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                    .font(.system(size: UIFont.systemFontSize))
                Spacer()
                Label("", systemImage: "pin.fill").foregroundStyle(userPreferences.pinColor)
            }
        }
        
        Section {
            ColorPicker("Reminder Color", selection: $userPreferences.reminderColor)
        } header: {
            HStack {
                Text("Alerts").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                    .font(.system(size: UIFont.systemFontSize))
                Spacer()
                Label("", systemImage: "bell.fill").foregroundStyle(userPreferences.reminderColor)
            }
        }

        

    }
    
    @ViewBuilder
    func dataTabView() -> some View {
            Section {
                if !isHiddenMediaManager {
                    MediaManagerView()
                }
            } header: {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
                    Text("Manage Data")
                        .font(.system(size: UIFont.systemFontSize))
                        .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                    
                    Spacer()
                    Image(systemName: isHiddenMediaManager ? "chevron.down" : "chevron.up").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
                    
                }
                .onTapGesture {
                    isHiddenMediaManager.toggle()
                }
            }
        

     
            LogsDataView()
                .environmentObject(userPreferences)
                .environmentObject(datesModel)
            
            UserPreferencesView() //for backing up and restoring user preferences data
                .environmentObject(userPreferences)
            
            StampDataView() // for importing and exporting stamp data
                        .environmentObject(userPreferences)
                

        }
    

    
    @ViewBuilder
    func generalTabView() -> some View {

        Section {
            Toggle("Enable authentication", isOn: $userPreferences.showLockScreen) // Make sure to add this property to UserPreferences
                .onChange(of: userPreferences.showLockScreen) { newValue in
                    if newValue {
                        authenticate()
                    }
                }
        } header: {
            HStack {
                Image(systemName: "lock.fill").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
                Text("Passcode").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                    .font(.system(size: UIFont.systemFontSize))
                Spacer()
            }
        }
        
        Section {
            Toggle("Activate hyperlinks", isOn: $userPreferences.showLinks) // Make sure to add this property to UserPreferences
                .onChange(of: userPreferences.showLinks) { newValue in
                    if newValue {
                        userPreferences.showLinks = newValue
                    }
                }
        } header: {
            HStack {
                Image(systemName: "link").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
                Text("Link Detection").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                    .font(.system(size: UIFont.systemFontSize))
                Spacer()
            }
        }

        Toggle("Show most recent entry time", isOn: $userPreferences.showMostRecentEntryTime) // Make sure to add this property to UserPreferences
            .onChange(of: userPreferences.showMostRecentEntryTime) { newValue in
                if newValue {
                    userPreferences.showMostRecentEntryTime = newValue
                }
            }
            
            
//        }
    }


    func exportUserPreferencesData() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(userPreferences)
            let fileName = "logs_preferences.json"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            try data.write(to: tempURL)
            
            presentShareSheet(url: tempURL)
        } catch {
            print("Error exporting UserPreferences: \(error)")
        }
    }
    
    func presentShareSheet(url: URL) {
        self.fileURLToShare = url
        self.isShareSheetPresented = true
    }


    
    private func foregroundColor() -> Color {
        if (userPreferences.activatedButtons[0]) {
            return userPreferences.selectedColors[0]
        }
        else if (userPreferences.activatedButtons[1]) {
            return userPreferences.selectedColors[1]
        }
        else if (userPreferences.activatedButtons[2]) {
            return userPreferences.selectedColors[2]
        }
        else if (userPreferences.activatedButtons[3]) {
            return userPreferences.selectedColors[3]
        }
        else {
            return userPreferences.selectedColors[4]
        }
    }
    
    func authenticate() {
        if userPreferences.showLockScreen {
            self.isUnlocked = true //for now
        }
    }
    
}
