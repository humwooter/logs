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

    @Binding var isUnlocked: Bool
    @State var settingIconColors: [Color] = []

    @State private var isHiddenMediaManager = false


    @State private var showNotification = false
    @State private var isSuccess = false
    @State private var isFailure = false
    
    
    var body: some View {

        NavigationStack {
            VStack {
                List {
                        if !settingIconColors.isEmpty {
                            alternateSettingsView().font(.system(size: UIFont.systemFontSize))
                        }

                }
                
            }
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
    func cloudSyncView() -> some View {
        HStack {
            Toggle("Enable Cloud Sync", isOn: $userPreferences.enableCloudMirror)
        }
//        Picker("Sync Preference", selection: $userPreferences.syncPreference) {
//                    Text("None").tag(UserPreferences.SyncPreference.none)
//                    Text("Documents").tag(UserPreferences.SyncPreference.documents)
//                    Text("All Entries").tag(UserPreferences.SyncPreference.allEntries)
//                    Text("Specific Entries").tag(UserPreferences.SyncPreference.specificEntries)
//                }
//        
//        if userPreferences.syncPreference == .specificEntries {
//               Section(header: Text("Manage Synced Entries")) {
//                   NavigationLink("Select Entries to Sync") {
//                       EntriesSyncSelectionView()
//                   }
//               }
//           }
    }
    
    
    
    
    @ViewBuilder
    func alternateSettingsView() -> some View {
        Section {
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
            
//            NavigationLink {
//                NavigationStack {
//                    List {
//                        cloudSyncView()
//                        //                                    .dismissOnTabTap()
//                    }.navigationTitle("Cloud Sync")
//                        .background {
//                            ZStack {
//                                Color(UIColor.systemGroupedBackground)
//                                LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
//                            }
//                            .ignoresSafeArea()
//                        }
//                        .scrollContentBackground(.hidden)
//                }
//            } label: {
//                Label(
//                    title: { Text("Sync")
//                    },
//                    icon: { settingsIconView(systemImage: "cloud.fill")}
//                )
//            }
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
                        preferencesTabView()
                        
                    }.navigationTitle("Appearance")
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
        
//        NavigationLink {
//            NavigationStack {
//                List {
//                    LogStatsView(logs: Array(logs))
//                }
//                .navigationTitle("Stats")
//                .background {
//                        ZStack {
//                            Color(UIColor.systemGroupedBackground)
//                            LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .bottom)
//                        }
//                        .ignoresSafeArea()
//                }
//                .scrollContentBackground(.hidden)
//            }
//
//        } label: {
//            Label(
//                title: { Text("Stats").font(.system(size: UIFont.systemFontSize))
//                },
//                icon: { settingsIconView(systemImage: "chart.bar.fill")}
//            )
//        }
        
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
        Section(header: Text("About")
            .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))

//            .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
            .font(.system(size: UIFont.systemFontSize))

        ) {
            
            NavigationLink {
                NavigationStack {
                    VStack {
                        IntroViews()
                            .environmentObject(userPreferences)
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
//        let defaultTopColor = getDefaultBackgroundColor(colorScheme: colorScheme)
        Section(header: Text("Stamp Dashboard")
            .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))
//            .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
            .font(.system(size: UIFont.systemFontSize))
        ) {
            ButtonDashboard().environmentObject(userPreferences).scaledToFit()
                .font(.system(size: UIFont.systemFontSize))
                .listStyle(.automatic)
                .padding(.horizontal, 5)
             
        }
        ForEach(0..<userPreferences.stamps.count, id: \.self) { index in
            if userPreferences.stamps[index].isActive {
                IconPicker(selectedImage: $userPreferences.stamps[index].imageName, selectedColor: $userPreferences.stamps[index].color, defaultTopColor: getDefaultBackgroundColor(colorScheme: colorScheme), accentColor: $userPreferences.accentColor, topColor_background: $userPreferences.backgroundColors[0], bottomColor_background: $userPreferences.backgroundColors[1], buttonIndex: index, buttonName: $userPreferences.stamps[index].name, inputCategories: imageCategories)
            }
        }
    }
    
    @ViewBuilder
    func preferencesTabView() -> some View {
        
        Section(header: Text("Preferences")
            .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))
//            .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
            .font(.system(size: UIFont.systemFontSize))
        ) {
            ColorPicker("Accent Color", selection: $userPreferences.accentColor)
            FontPicker(selectedFont:  $userPreferences.fontName, selectedFontSize: $userPreferences.fontSize, accentColor: $userPreferences.accentColor, inputCategories: fontCategories, topColor_background: $userPreferences.backgroundColors[0], bottomColor_background: $userPreferences.backgroundColors[1], defaultTopColor: getDefaultBackgroundColor(colorScheme: colorScheme))
            HStack {
                Text("Line Spacing")
                Slider(value: $userPreferences.lineSpacing, in: 0...15, step: 1, label: { Text("Line Spacing") })
            }
        }
        
        Section {
            BackgroundColorPickerView(topColor: $userPreferences.backgroundColors[0], bottomColor: $userPreferences.backgroundColors[1])
        } header: {
            
            HStack {
                Text("Background Colors")
                    .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))

//                    .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                    .font(.system(size: UIFont.systemFontSize))
                Spacer()
                Label("reset", systemImage: "gobackward").foregroundStyle(.red).font(.system(size: UIFont.systemFontSize))
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
                Text("Entry Background")
                    .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))

//                    .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                    .font(.system(size: UIFont.systemFontSize))
                Spacer()
                Label("reset", systemImage: "gobackward").foregroundStyle(.red).font(.system(size: UIFont.systemFontSize))
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
                Text("Pin Color")
                    .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))

//                    .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                    .font(.system(size: UIFont.systemFontSize))
                Spacer()
                Image(systemName: "pin.fill").foregroundStyle(userPreferences.pinColor)
            }.font(.system(size: UIFont.systemFontSize))
        }
        
        Section {
            ColorPicker("Reminder Color", selection: $userPreferences.reminderColor)
        } header: {
            HStack {
                Text("Alerts")
                    .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))

//                    .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                    .font(.system(size: UIFont.systemFontSize))
                Spacer()
                Image(systemName: "bell.fill").foregroundStyle(userPreferences.reminderColor)
            }.font(.system(size: UIFont.systemFontSize))
        }

        NavigationLink("Themes") {
            ThemeSheet()
                .environmentObject(userPreferences)
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
                        .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                    
                    Spacer()
                    Image(systemName: isHiddenMediaManager ? "chevron.down" : "chevron.up").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
                }
                .font(.system(size: UIFont.systemFontSize))
                .onTapGesture {
                    isHiddenMediaManager.toggle()
                }
            }
        

     
        LogsDataView(showNotification: $showNotification, isSuccess: $isSuccess, isFailure: $isFailure)
                .environmentObject(userPreferences)
                .environmentObject(datesModel)
            
        UserPreferencesView(showNotification: $showNotification, isSuccess: $isSuccess, isFailure: $isFailure) //for backing up and restoring user preferences data
                .environmentObject(userPreferences)
            
        StampDataView(showNotification: $showNotification, isSuccess: $isSuccess, isFailure: $isFailure) // for importing and exporting stamp data
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
                Text("Passcode")
                    .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))

                Spacer()
            }
            .font(.system(size: UIFont.systemFontSize))
        }
        
        Section {
            Toggle("Enable Cloud Sync", isOn: $userPreferences.enableCloudMirror) // Make sure to add this property to UserPreferences
                .onChange(of: userPreferences.enableCloudMirror) { newValue in
                    if newValue {
                        userPreferences.enableCloudMirror = newValue
                    }
                }
        } header: {
            HStack {
                Image(systemName: "cloud.fill").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
                Text("Sync")
                    .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))

                Spacer()
            }
            .font(.system(size: UIFont.systemFontSize))
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
                Text("Link Detection")
//                    .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                    .foregroundStyle(getIdealTextColor(userPreferences: userPreferences, colorScheme: colorScheme).opacity(0.5))
                Spacer()
            }
            .font(.system(size: UIFont.systemFontSize))
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
//
//struct EntriesSyncSelectionView: View {
//    @FetchRequest(
//        entity: Entry.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.time, ascending: false)]
//    ) var entries: FetchedResults<Entry>
//    
//    @StateObject private var syncManager = SyncManager.shared
//
//    var body: some View {
//        List {
//            Section {
//                Picker("Sync Preference", selection: $syncManager.userPreferences.syncPreference) {
//                    Text("None").tag(UserPreferences.SyncPreference.none)
//                    Text("Documents").tag(UserPreferences.SyncPreference.documents)
//                    Text("All Entries").tag(UserPreferences.SyncPreference.allEntries)
//                    Text("Specific Entries").tag(UserPreferences.SyncPreference.specificEntries)
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .onChange(of: syncManager.userPreferences.syncPreference) { newValue in
//                    if newValue != .none {
//                        syncManager.performSync()
//                    }
//                }
//            }
//            
//            if syncManager.userPreferences.syncPreference == .specificEntries {
//                ForEach(entries) { entry in
//                    CloudSyncEntryRowView(entry: entry)
//                }
//            }
//        }
//    }
//}
//
//struct CloudSyncEntryRowView: View {
//    @ObservedObject var entry: Entry
//    @ObservedObject var syncManager = SyncManager.shared
//    
//    var body: some View {
//        Toggle(isOn: Binding(
//            get: { entry.shouldSyncWithCloudKit },
//            set: { newValue in
//                entry.shouldSyncWithCloudKit = newValue
//                CoreDataManager.shared.save(context: entry.managedObjectContext ?? CoreDataManager.shared.viewContext) //save the flag change in local storage first
//                
//                CoreDataManager.shared.saveEntry(entry)
//                syncManager.updateSyncStatus(for: entry, shouldSync: newValue)
//            }
//        )) {
//            Text(entry.content.prefix(50) ?? "No content")
//        }
//    }
//}
