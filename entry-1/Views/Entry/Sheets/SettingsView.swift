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
                            alternateSettingsView()
                                .scrollContentBackground(.hidden)
                                .listRowBackground(getSectionColor(colorScheme: colorScheme))
                                .font(.customHeadline)
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
    
    func getSectionColor(colorScheme: ColorScheme) -> Color {
        if isClear(for: UIColor(userPreferences.entryBackgroundColor)) {
            return entry_1.getDefaultEntryBackgroundColor(colorScheme: colorScheme)
        } else {
            return userPreferences.entryBackgroundColor
        }
    }
    
    @ViewBuilder
    func cloudSyncView() -> some View {
        HStack {
            Toggle("Enable Cloud Sync", isOn: $userPreferences.enableCloudMirror).tint(userPreferences.accentColor)
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
                            .scrollContentBackground(.hidden)
                            .listRowBackground(getSectionColor(colorScheme: colorScheme))
                            .font(.customHeadline)
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
                    title: { Text("General").foregroundStyle(getTextColor())
                    },
                    icon: { settingsIconView(systemImage: "gearshape.fill", appIconSize: nil)}
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
                            .scrollContentBackground(.hidden)
                            .listRowBackground(getSectionColor(colorScheme: colorScheme))
                        
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
                    title: { Text("Stamps").foregroundStyle(getTextColor())
                    },
                    icon: { settingsIconView(systemImage: "hare.fill", appIconSize: nil)}
                )
            }
            
            NavigationLink {
                NavigationStack {
                    List {
                        preferencesTabView()
                            .scrollContentBackground(.hidden)
                            .listRowBackground(getSectionColor(colorScheme: colorScheme))
                        
                    }.navigationTitle("Appearance").foregroundStyle(getTextColor())
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
                    title: { Text("Appearance").foregroundStyle(getTextColor())
                    },
                    icon: { settingsIconView(systemImage: "textformat.size", appIconSize: nil)}
                )
            }
            
            
            appTabView()
                .scrollContentBackground(.hidden)
                .listRowBackground(getSectionColor(colorScheme: colorScheme))
            
        }
        NavigationLink {
            NavigationStack {
                List {
                    dataTabView()
                        .scrollContentBackground(.hidden)
                        .listRowBackground(getSectionColor(colorScheme: colorScheme))
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
                title: { Text("Data").foregroundStyle(getTextColor())
                        .font(.customHeadline)
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
                        .scrollContentBackground(.hidden)
                        .listRowBackground(getSectionColor(colorScheme: colorScheme))
                }
                .navigationTitle("Information").foregroundStyle(getTextColor())
                .font(.customHeadline)
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
                title: { Text("Info").foregroundStyle(getTextColor())
                        .font(.customHeadline)
                },
                icon: { settingsIconView(systemImage: "info").foregroundStyle(userPreferences.accentColor)}
            )
        }
     
    }
    
    @ViewBuilder
    func appTabView() -> some View {
        NavigationLink {
            NavigationStack {
                List {
                    appIconView()
//                        .foregroundStyle(getTextColor())
                        .scrollContentBackground(.hidden)
                        .listRowBackground(getSectionColor(colorScheme: colorScheme))
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
                title: { Text("App Icon").foregroundStyle(getTextColor())
                        .font(.customHeadline)

                },
                icon: {
                    settingsIconView(systemImage: "app_icon", appIconSize: nil)
                }
            )

        }
    }
    
    
    @ViewBuilder
    func appIconView() -> some View {
        
        Section {
            Picker("App Icon", selection: $userPreferences.activeAppIcon) {
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
            }.pickerStyle(MenuPickerStyle())
                .foregroundStyle(getTextColor())
                .font(.customHeadline)
                .onChange(of: userPreferences.activeAppIcon) { oldValue, newValue in
                    UIApplication.shared.setAlternateIconName(newValue)
                }
        } header: {
            HStack {
                settingsIconView(systemImage: "app_icon", appIconSize: CGSize.mediumIconSize())
                Text("App Icon").foregroundStyle(getIdealHeaderTextColor().opacity(0.4))
                Spacer()
            }
            .font(.customHeadline)
        }
    }
    
    @ViewBuilder
    func introScreenViews() -> some View {
        Section(header: Text("About")
            .foregroundStyle(getIdealHeaderTextColor().opacity(0.4))

//            .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
            .font(.customHeadline)

        ) {
            
            NavigationLink {
                NavigationStack {
                    VStack {
                        IntroViews()
                            .environmentObject(userPreferences)
                    }
                }
            } label: {
                HStack {
                    Text("User Guide")
                    Spacer()
                    Image(systemName:  "info.circle.fill").foregroundStyle(userPreferences.accentColor)
            
                }
            }
        }
    }
    
    @ViewBuilder
    func settingsIconView(systemImage: String, appIconSize: CGSize? = nil) -> some View {
        ZStack {
            if systemImage == "app_icon" {
                if let appIconSize {
                    Image(uiImage: UIImage(named: "app_icon.svg")!).resizable().scaledToFill()
                        .foregroundStyle(userPreferences.accentColor)
                        .frame(appIconSize)
                } else {
                    Image(uiImage: UIImage(named: "app_icon.svg")!).resizable().scaledToFill()
                        .foregroundStyle(userPreferences.accentColor)
                        .frame(CGSize.largeIconSize())
                }
            } else {
                Image(systemName: systemImage).scaledToFit()
                    .foregroundColor(userPreferences.accentColor)
                    .frame(CGSize.mediumIconSize())

            }

        }
        .padding(.vertical, 1)
//        .font(.sectionHeaderSize)

    }


    @ViewBuilder
    func stampsTabView() -> some View {
//        let defaultTopColor = getDefaultBackgroundColor(colorScheme: colorScheme)
        Section(header: Text("Stamp Dashboard")
            .foregroundStyle(getIdealHeaderTextColor().opacity(0.4))
//            .foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
            .font(.customHeadline)
        ) {
            ButtonDashboard().environmentObject(userPreferences).scaledToFit()
                .font(.customHeadline)
                .listStyle(.automatic)
                .padding(.horizontal, 5)
             
        }
        ForEach(0..<userPreferences.stamps.count, id: \.self) { index in
            if userPreferences.stamps[index].isActive {
                IconPicker(selectedImage: $userPreferences.stamps[index].imageName, selectedColor: $userPreferences.stamps[index].color, defaultTopColor: getDefaultBackgroundColor(colorScheme: colorScheme), accentColor: $userPreferences.accentColor, topColor_background: $userPreferences.backgroundColors[0], bottomColor_background: $userPreferences.backgroundColors[1], sectionColor: getSectionColor(colorScheme: colorScheme), foregroundStyle: getTextColor(), buttonIndex: index, buttonName: $userPreferences.stamps[index].name, inputCategories: imageCategories)
                    .foregroundStyle(getTextColor())
                    .font(.customHeadline)
                    .environmentObject(userPreferences)
            }
        }
        .onAppear {
            print("STAMPS: \(userPreferences.stamps)")
        }
    }
    
    @ViewBuilder
    func preferencesTabView() -> some View {
        Section {
            Picker("Calendar Preference", selection: $userPreferences.calendarPreference) {
                Text("Monthly").tag("Monthly")
                    .font(.customHeadline)

                Text("Weekly").tag("Weekly")
                    .font(.customHeadline)

            }
            .pickerStyle(MenuPickerStyle()) // You can change this to another picker style if needed
            .foregroundStyle(getTextColor())
            .font(.customHeadline)
        } header: {
            HStack {
                Image(systemName: "calendar").foregroundStyle(userPreferences.accentColor)
                Text("Calendar Preference").foregroundStyle(getIdealHeaderTextColor().opacity(0.4))
                Spacer()
            }
            .font(.customHeadline)
        }

        
        Section {
            NavigationLink("Edit Theme") {
                ThemeSheet()
                    .environmentObject(coreDataManager)
                    .environmentObject(userPreferences)
            }
            .font(.customHeadline)

        } header: {
            HStack {
                Image(systemName: "paintpalette.fill").foregroundStyle(userPreferences.accentColor)
                Text("Themes")
                    .foregroundStyle(getIdealHeaderTextColor().opacity(0.4))
                Spacer()
            }
            .font(.customHeadline)
        }
    }
    
    @ViewBuilder
    func dataTabView() -> some View {
            Section {
                if !isHiddenMediaManager {
                    MediaManagerView()
                        .foregroundStyle(getTextColor())
                }
            } header: {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
                    Text("Manage Data")
                        .foregroundStyle(getIdealHeaderTextColor()).opacity(0.4)
                    
                    Spacer()
                    Image(systemName: isHiddenMediaManager ? "chevron.down" : "chevron.up").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
                }
                .font(.customHeadline)
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
            Toggle("Enable authentication", isOn: $userPreferences.showLockScreen).tint(userPreferences.accentColor)
                .foregroundStyle(getTextColor())
                .onChange(of: userPreferences.showLockScreen) { newValue in
                    if newValue {
                        authenticate()
                    }
                }
        } header: {
            HStack {
                Image(systemName: "lock.fill").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
                Text("Passcode")
                    .foregroundStyle(getIdealHeaderTextColor().opacity(0.4))

                Spacer()
            }
            .font(.customHeadline)
        }
        
        Section {
            Toggle("Enable Cloud Sync", isOn: $userPreferences.enableCloudMirror).tint(userPreferences.accentColor)
                .foregroundStyle(getTextColor())
                .onChange(of: userPreferences.enableCloudMirror) { newValue in
                    if newValue {
                        userPreferences.enableCloudMirror = newValue
                    }
                }
            
        } header: {
            HStack {
                Image(systemName: "cloud.fill").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
                Text("Sync")
                    .foregroundStyle(getIdealHeaderTextColor().opacity(0.4))

                Spacer()
            }
            .font(.customHeadline)
        }
        
        
        Section {
            Toggle("Activate hyperlinks", isOn: $userPreferences.showLinks).tint(userPreferences.accentColor)
                .foregroundStyle(getTextColor())
                .onChange(of: userPreferences.showLinks) { newValue in
                    if newValue {
                        userPreferences.showLinks = newValue
                    }
                }
        } header: {
            HStack {
                Image(systemName: "link").foregroundStyle(userPreferences.accentColor).padding(.horizontal, 5)
                Text("Link Detection")
                    .foregroundStyle(getIdealHeaderTextColor().opacity(0.4))
                Spacer()
            }
            .font(.customHeadline)
        }

        Toggle("Show most recent entry time", isOn: $userPreferences.showMostRecentEntryTime).tint(userPreferences.accentColor)
            .foregroundStyle(getTextColor())
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
    
    func getIdealHeaderTextColor() -> Color {
        return Color(UIColor.fontColor(forBackgroundColor: UIColor.averageColor(of: UIColor(userPreferences.backgroundColors.first ?? Color.clear), and: UIColor(userPreferences.backgroundColors[1])), colorScheme: colorScheme))
    }
    
    func getTextColor() -> Color {
        let background1 = userPreferences.backgroundColors.first ?? Color.clear
        let background2 = userPreferences.backgroundColors[1]
        let entryBackground = userPreferences.entryBackgroundColor
        
        return calculateTextColor(
            basedOn: background1,
            background2: background2,
            entryBackground: entryBackground,
            colorScheme: colorScheme
        )
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
