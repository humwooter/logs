//
//  SettingsView.swift
//  entry-1
//
//  Created by Katya Raman on 8/14/23.
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


func defaultLogsName() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "M-d-yy"
    let dateString = formatter.string(from: date)
    return "logs backup \(dateString)"
}



struct SettingsView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    //    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    
    
    @State var advancedSettings = false
    @State private var isExportDocumentPickerPresented = false
    @State private var isImportDocumentPickerPresented = false
    @StateObject var docPickerDelegate = DocumentPickerDelegate()
    @Environment(\.colorScheme) var colorScheme
    
    
    @State private var tempFileURL: URL?
    
    @State private var selectedURL: URL?
    
    @State private var isExporting = false
    @State private var isImporting = false
    @FetchRequest(
        entity: Log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Log.day, ascending: true)]
    ) var logs: FetchedResults<Log>
    
    
    @State private var selectedTab = 0
    
    
    @State private var isShareSheetPresented = false
    @State private var fileURLToShare: URL?
//    init(color: UIColor) {
//        if !isClear(for: color) {
//            let textColor = UIColor(UIColor.foregroundColor(background: color))
//            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: textColor]
//            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: textColor]
//        }
//        if isClear(for: color) {
//            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color("TextColor"))]
//        }
//        
//   }
    
    var body: some View {

        NavigationStack {
            VStack {
                Picker("Options", selection: $selectedTab) {
                    Text("General").padding().tag(0)
                    Text("Preferences").padding().tag(1)
                    Text("Stamps").padding().tag(2)
                }.foregroundStyle(Color(UIColor.secondarySystemBackground))
                .background {
                    ZStack {
                        Color(UIColor.tertiarySystemBackground)
//                        userPreferences.accentColor.opacity(0.7)
                    }
                }.cornerRadius(5)
//                .background(userPreferences.accentColor.opacity(0.5)).cornerRadius(5)
                .pickerStyle(.segmented)
                .padding(10)
                .padding(.horizontal, 5)

                List {
                    
                    if selectedTab == 0 {
                        
                        Section(header: Text("About").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                            .font(.system(size: UIFont.systemFontSize))

                        ) {
                            
                            NavigationLink {
                                IntroViews()
                                    .environmentObject(userPreferences)
                            } label: {
                                Label("User Guide", systemImage: "info.circle.fill")
                            }

                      
                            
                        }
                        LogsDataView()
                            .environmentObject(userPreferences)

                        
                        Section(header: Text("Advanced Settings").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                            .font(.system(size: UIFont.systemFontSize))

                        ) {
                            Toggle("Advanced Settings", isOn: $advancedSettings) // Make sure to add this property to UserPreferences
                        }
                        
                        
                        if advancedSettings {
                            Section(header: Text("Enable authentication").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                                .font(.system(size: UIFont.systemFontSize))

                            ) {
                                Toggle("Enable authentication", isOn: $userPreferences.showLockScreen) // Make sure to add this property to UserPreferences
                                    .onChange(of: userPreferences.showLockScreen) { newValue in
                                        if newValue {
                                            authenticate()
                                        }
                                    }
                            }
              
                            Section(header: Text("Link Detection").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                                .font(.system(size: UIFont.systemFontSize))

                            ) {
                                Toggle("Activate hyperlinks", isOn: $userPreferences.showLinks) // Make sure to add this property to UserPreferences
                                    .onChange(of: userPreferences.showLinks) { newValue in
                                        if newValue {
                                            userPreferences.showLinks = newValue
                                        }
                                    }
                            }
                            
                            
                        }
                    }
                    if selectedTab == 1 {
                        
                        Section(header: Text("Preferences").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                            .font(.system(size: UIFont.systemFontSize))

                        ) {
                            ColorPicker("Accent Color", selection: $userPreferences.accentColor)
                            FontPicker(selectedFont:  $userPreferences.fontName, selectedFontSize: $userPreferences.fontSize, accentColor: $userPreferences.accentColor, inputCategories: fontCategories, topColor_background: $userPreferences.backgroundColors[0], bottomColor_background: $userPreferences.backgroundColors[1])
                            HStack {
                                Text("Line Spacing")
                                Slider(value: $userPreferences.lineSpacing, in: 0...15, step: 1, label: { Text("Line Spacing") })
                            }
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    Label("Reset to default", systemImage: "gobackward").foregroundStyle(.red)
                                        .onTapGesture {
                                            vibration_light.impactOccurred()
                                            userPreferences.entryBackgroundColor = .clear
                                        }
                                        .padding(1)
                                }
                                ColorPicker("Entry background color", selection: $userPreferences.entryBackgroundColor)                           
                            }
                            .padding() // Add padding around the VStack for overall spacing

                            
                        }
                        
                        
                        Section(header: Text("Background Colors").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)
                            .font(.system(size: UIFont.systemFontSize))

                        ) {
                            BackgroundColorPickerView(topColor: $userPreferences.backgroundColors[0], bottomColor: $userPreferences.backgroundColors[1])
                        }
                        

                        Section {
                            ColorPicker("Pin Color", selection: $userPreferences.pinColor)
                        } header: {
                            HStack {
                                Text("Pin Color").foregroundStyle(UIColor.foregroundColor(background: UIColor(userPreferences.backgroundColors.first ?? Color.gray))).opacity(0.4)                                .font(.system(size: UIFont.systemFontSize))


                                
                                Spacer()
                                Label("", systemImage: "pin.fill").foregroundStyle(userPreferences.pinColor)
                            }
                        }
                        
                        UserPreferencesView() //for importing and exporting userPreferences
                            .environmentObject(userPreferences)
                        
  
                    }
                    
                    
                    if selectedTab == 2 {
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
                    }
                }

            }
            .sheet(isPresented: $isShareSheetPresented, onDismiss: {
                // Handle dismissal if needed
            }) {
                if let fileURLToShare = fileURLToShare {
                    ShareSheet(activityItems: [fileURLToShare])
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
            .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
            .accentColor(userPreferences.accentColor)

        }
        
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

    
    // UIDocumentPickerDelegate method
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        if controller.documentPickerMode == .exportToService {
            do {
                
                // Handle export (write jsonData to the selected URL)
            } catch {
                print("Failed to export data: \(error)")
            }
        } else if controller.documentPickerMode == .import {
            do {
                // Handle import (read jsonData from the selected URL)
            } catch {
                print("Failed to import data: \(error)")
            }
        }
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
            userPreferences.isUnlocked = true //for now
        }
    }
    
}


extension EnvironmentValues {
    var viewController: UIViewController? {
        self[UIViewControllerKey.self]
    }
}

struct UIViewControllerKey: EnvironmentKey {
    static let defaultValue: UIViewController? = nil
}

struct ToggleButton: View {
    @Binding var isOn: Bool
    var color: Color
    
    var body: some View {
        Toggle("", isOn: $isOn)
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle(tint: color))
    }
    
}


class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate, ObservableObject {
    @Published var pickedURL: URL? = nil
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        pickedURL = urls.first
    }
}



struct BackupButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .padding(.horizontal, 10)
            .background {
                LinearGradient(colors: [.green, .cyan], startPoint: .leading, endPoint: .trailing)
            }
        //            .foregroundColor(colorScheme == .dark ? .white : .black)
            .clipShape(RoundedRectangle(cornerSize: .init(width: 30, height: 30)))
            .scaleEffect(!configuration.isPressed ? 0.95 : 1.05)
    }
}

struct RestoreButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .padding(.horizontal, 10)
            .background {
                LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
            }
        //            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerSize: .init(width: 30, height: 30)))
            .scaleEffect(!configuration.isPressed ? 0.95 : 1.05)
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
