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
    
    
    let fontCategories: [String: [String]] = [
        "Traditional": ["Gill Sans", "Menlo Regular", "Didot", "Futura", "Georgia", "Impact", "Arial Rounded MT Bold","Superclarendon Regular", ],
        "Monospace": ["Courier New", "STIX Two Math"],
        "Handwriting": ["Bradley Hand", "Noteworthy Light", "SavoyeLetPlain", "Marker Felt Thin", "BarelyEnough-Regular", "MotleyForces-Regular", "ClickerScript-Regular", "Magiera-Script", "Mueda-City", "SunnySpellsBasic-Regular", "Papyrus Condensed", "Nathan-CondensedRegular", "Lilly", "NjalBold", "Darlin\'Pop"],
        "Cursive" : ["Savoye LET", "Snell Roundhand", "SignPainter","DancingScript", "stainellascript"],
        "Decorative": ["Bodoni Ornaments",  "Auseklis", "AstroDotBasic", "MageScript", "HaraldRunic", "LuciusCipher"],
        "Other": ["American Typewriter", "Chalkboard SE Regular", "Academy Engraved LET Plain:1.0", "Copperplate Light",  "Barrbar", "PixelDigivolve"],
        "Unique": ["ShootingStars", "aAnnyeongHaseyo", "Spicy-Chips", "Cute_Aurora_demo", "SparkyStones-Regular", "TheNightOne", "Boekopi", "Emperialisme"],
        "Antique": ["aAnggaranDasar", "IrishUncialfabeta-Bold", "QuaeriteRegnumDei"],
        "Calligraphy": []
    ]
    
    
    
    
    let imageCategories: [String: [String]] = [
        "Shapes": ["circle", "staroflife", "star.fill", "heart.fill", "bolt.heart.fill", "heart.slash.fill", "house.fill"],
        "Symbols": ["folder.fill", "exclamationmark", "checkmark","lightbulb", "gearshape", "bolt.fill", "bookmark.fill", "hourglass", "power", "atom", "compass.drawing", "music.note", "globe.desk.fill", "envelope.fill"],
        "Human": ["brain", "ear.fill", "mustache.fill", "hand.raised.fill", "brain.filled.head.profile", "shoe.fill"],
        "Animals": ["bird.fill", "lizard.fill", "hare.fill", "tortoise.fill", "dog.fill", "cat.fill", "ladybug.fill", "fish.fill"],
        "Nature": ["leaf.fill", "moon.stars.fill", "sun.haze.circle.fill", "wind.snow", "sun.max.fill", "drop.fill", "flame", "flame.fill", "tree", "tree.fill", "globe.asia.australia.fill", "camera.macro", "snowflake", "tornado", "cloud.rainbow.half", "mountain.2.fill"],
        "Actions": ["gamecontroller.fill", "figure.run", "figure.mind.and.body", "book.fill", "paintpalette.fill", "eye.fill", "list.clipboard" ,  "figure.yoga", "music.mic", "figure.strengthtraining.traditional", "paintbrush.fill", "pianokeys.inverse", "paintbrush.pointed.fill"],
        "Fitness": ["gym.bag.fill", "surfboard.fill", "snowboard.fill", "volleyball.fill", "tennis.racket", "basketball.fill", "baseball.fill", "soccerball", "football", "football.fill"],
        "Commerce": ["bag.fill", "cart.fill", "creditcard.fill", "giftcard.fill", "dollarsign", "basket.fill", "handbag.fill"],
        "Sleep": ["bed.double.fill"],
        "Emotions" : ["face.smiling.inverse", "hand.thumbsup.fill", "hands.thumbsdown.fill", "hands.and.sparkles.fill"],
        "Transportation": ["car.fill", "bus.fill", "tram.fill", "ferry.fill", "sailboat.fill", "bicycle", "scooter"],
        "Other" : ["drop.halfull", "swirl.circle.righthalf.filled", "lightspectrum.horizontal", "camera.circle.fill",   "camera.aperture", "books.vertical.fill",  "key.fill", "poweroutlet.type.f", "doc.richtext.fill"],
        "Special" : ["graduationcap.fill", "backpack.fill", "sparkle.magnifyingglass", "theatermasks.fill", "camera.filters", "birthday.cake.fill", "trophy.fill", "timelapse", "puzzlepiece.fill" , "wand.and.rays.inverse", "crown.fill"],
        "Food" : ["frying.pan.fill", "cup.and.saucer.fill", "wineglass.fill", "carrot", "fork.knife", "waterbottle.fill"],
        "Magic": ["suit.club.fill", "suit.spade.fill", "suit.diamond.fill", "hands.and.sparkles.fill"],
        "Tools": ["wrench.adjustable.fill", "hammer.fill", "eyedropper.halffull", "screwdriver.fill", "wrench.and.screwdriver.fill", "stethoscope", "compass.drawing"],
        "Celebratory" : ["balloon.fill", "fireworks"],
        "Gaming" : ["playstation.logo", "xbox.logo"],
        "Currency": ["dollarsign.circle.fill", "centsign.circle.fill", "yensign.circle.fill", "sterlingsign.circle.fill", "francsign.circle.fill", "florinsign.circle.fill", "turkishlirasign.circle.fill", "rublesign.circle.fill", "eurosign.circle.fill", "dongsign.circle.fill", "indianrupeesign.circle.fill", "tengesign.circle.fill", "australsign.circle.fill", "coloncurrencysign.circle.fill", "larisign.circle.fill", "bitcoinsign.circle.fill"]
    ]
    
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
    
    
    var body: some View {

        NavigationStack {
            VStack {
                Picker("Options", selection: $selectedTab) {
                    Text("Preferences").padding().tag(0)
                    Text("Stamps").padding().tag(1)
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
            
//            VStack {
//                Picker("Options", selection: $selectedTab) {
//                    Text("Preferences").tag(0)
//                    Text("Stamps").tag(1)
//                }
//                .pickerStyle(.segmented)
//                .cornerRadius(10)
//                .padding()
//            }
                List {
                    if selectedTab == 0 {
                        
                        Section(header: Text("Preferences")) {
                            ColorPicker("Accent Color", selection: $userPreferences.accentColor)
                            
                            FontPicker(selectedFont: $userPreferences.fontName, selectedFontSize: $userPreferences.fontSize, accentColor: $userPreferences.accentColor, inputCategories: fontCategories)
                            HStack {
                                Text("Line Spacing")
                                Slider(value: $userPreferences.lineSpacing, in: 0...15, step: 1, label: { Text("Line Spacing") })
                            }
                            
                            
                        }
                        
                        Section(header: Text("Data")) {
                            HStack {
                                Spacer()
                                Button {
                                    exportData()
                                    print("Export button tapped")
                                    isExporting = true
                                } label: {
                                    Label("BACKUP", systemImage: "arrow.up.doc").fontWeight(.bold).font(.custom(userPreferences.fontName, size: userPreferences.fontSize))

                                }
                                .fileExporter(isPresented: $isExporting, document: LogDocument(logs: Array(logs)), contentType: .json, defaultFilename: "\(defaultLogsName()).json") { result in
                                    switch result {
                                    case .success(let url):
                                        print("File successfully saved at \(url)")
                                    case .failure(let error):
                                        print("Failed to save file: \(error)")
                                    }
                                }
                                .buttonStyle(BackupButtonStyle())
                                .foregroundColor(Color(UIColor.tertiarySystemBackground))
                                
                                Spacer()
                                Button {
                                    isImporting = true
                                } label: {
                                    Label("RESTORE", systemImage: "arrow.down.doc").fontWeight(.bold).font(.custom(userPreferences.fontName, size: userPreferences.fontSize))
                                }
                                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
                                    Task {
                                        switch result {
                                        case .success(let url):
                                            do {
                                                try await importData(from: url)
                                            } catch {
                                                print("Failed to import data: \(error)")
                                            }
                                        case .failure(let error):
                                            print("Failed to import file: \(error)")
                                        }
                                    }
                                }
                                .buttonStyle(RestoreButtonStyle())
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                                
                                Spacer()
                            }
                            .zIndex(1) // Ensure it lays on top if using ZStack
                        }
                        .background(.clear)  // Use a clear background to prevent any visual breaks
                        
                        
                        
                        Section(header: Text("Advanced Settings")) {
                            Toggle("Advanced Settings", isOn: $advancedSettings) // Make sure to add this property to UserPreferences
                        }
                        
                        
                        if advancedSettings {
                            Section(header: Text("Enable authentication")) {
                                Toggle("Enable authentication", isOn: $userPreferences.showLockScreen) // Make sure to add this property to UserPreferences
                                    .onChange(of: userPreferences.showLockScreen) { newValue in
                                        if newValue {
                                            authenticate()
                                        }
                                    }
                            }
                            Section(header: Text("Background Colors")) {
                                BackgroundColorPickerView(topColor: $userPreferences.backgroundColors[0], bottomColor: $userPreferences.backgroundColors[1])
                            }
                            Section {
                                ColorPicker("Pin Color", selection: $userPreferences.pinColor)
                            } header: {
                                HStack {
                                    Text("Pin Color")
                                    Spacer()
                                    Label("", systemImage: "pin.fill").foregroundStyle(userPreferences.pinColor)
                                }
                            }
                            
                            
                        }
                    }
                    
                    
                    if selectedTab == 1 {
                        Section(header: Text("Stamp Dasboard")) {
                            ButtonDashboard().environmentObject(userPreferences)
                                .listStyle(.automatic)
                            
                        }
                        ForEach(0..<userPreferences.stamps.count, id: \.self) { index in
                            if userPreferences.stamps[index].isActive {
                                
                                IconPicker(
                                    selectedImage: $userPreferences.stamps[index].imageName,
                                    selectedColor: $userPreferences.stamps[index].color, accentColor: $userPreferences.accentColor,
                                    buttonIndex: index,
                                    inputCategories: imageCategories
                                )
                            }
                        }
                    }
                }
//                VStack {
//                    Picker("Options", selection: $selectedTab) {
//                        Text("Preferences").tag(0)
//                        Text("Stamps").tag(1)
//                    }
//                    .pickerStyle(.segmented)
//                    .cornerRadius(10)
//                    .padding()
//                }
                
            }
            .background {
                    ZStack {
                        Color(UIColor.systemGroupedBackground)
                        LinearGradient(colors: [userPreferences.backgroundColors[0], userPreferences.backgroundColors.count > 1 ? userPreferences.backgroundColors[1] : userPreferences.backgroundColors[0]], startPoint: .top, endPoint: .center)
                            .opacity(0.9)
                            .ignoresSafeArea()
                    }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .font(.custom(String(userPreferences.fontName), size: CGFloat(Float(userPreferences.fontSize))))
            .accentColor(userPreferences.accentColor)
            
//            HStack {
//                
//                
//              
//                      }
//                      .cornerRadius(10) // Match corner radius
//                      .padding(.horizontal)
            
//            .safeAreaInset(edge: .top) {
//                Picker("Options", selection: $selectedTab) {
//                    Text("Preferences").padding().tag(0)
//                    Text("Stamps").padding().tag(1)
//                }.foregroundStyle(Color(UIColor.secondarySystemBackground))
//                .background {
//                    ZStack {
//                        Color(UIColor.tertiarySystemBackground)
////                        userPreferences.accentColor.opacity(0.7)
//                    }
//                }.cornerRadius(5)
////                .background(userPreferences.accentColor.opacity(0.5)).cornerRadius(5)
//                .pickerStyle(.segmented)
//                .padding(10)
//                .padding(.horizontal, 5)
//                
//            }.background {
//                Color.white.opacity(0.3)
//            }
        }
        
    }
    
    
    private func exportData() {
        do {
            let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
            let logs = try coreDataManager.backgroundContext.fetch(fetchRequest)
            
            // Check if logs is not empty
            guard !logs.isEmpty else {
                print("No logs to export")
                return
            }
            
            isExporting = true
        } catch {
            print("Failed to fetch logs: \(error)")
        }
    }
    
    
    
    private func importData(from url: URL) async throws {
        print("entered import data")
        
        guard url.startAccessingSecurityScopedResource() else {
            throw NSError(domain: "Security", code: 1, userInfo: nil)
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let jsonData = try Data(contentsOf: url)
        
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                
                coreDataManager.backgroundContext.performAndWait {
                    do {
                        for jsonObject in jsonArray {
                            if let logIdString = jsonObject["id"] as? String, let logId = UUID(uuidString: logIdString) {
                                print("ID: \(logId)")
                                
                                let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
                                fetchRequest.predicate = NSPredicate(format: "id == %@", logId as CVarArg)
                                
                                let existingLogs = try coreDataManager.viewContext.fetch(fetchRequest)
                                
                                if existingLogs.first != nil {
                                    print("LOG WITH ID: \(logId) ALREADY EXISTS")
                                } else {
                                    if let logData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) {
                                        let decoder = JSONDecoder()
                                        decoder.userInfo[CodingUserInfoKey.managedObjectContext] = coreDataManager.viewContext
                                        let log = try decoder.decode(Log.self, from: logData)
                                        coreDataManager.viewContext.insert(log)
                                    }
                                }
                            }
                        }
                        try coreDataManager.backgroundContext.save()
                        
                    } catch {
                        print("Failed to import data: \(error)")
                    }
                }
            }
        } catch {
            print("Failed to parse JSON: \(error)")
        }
        
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
            .padding(10)
            .padding(.horizontal, 5)
            .background {
                LinearGradient(colors: [.cyan, .indigo], startPoint: .leading, endPoint: .trailing)
            }
        //            .foregroundColor(colorScheme == .dark ? .white : .black)
            .clipShape(RoundedRectangle(cornerSize: .init(width: 30, height: 30)))
            .scaleEffect(!configuration.isPressed ? 0.95 : 1.05)
    }
}

struct RestoreButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .padding(.horizontal, 5)
            .background {
                LinearGradient(colors: [.yellow, .red], startPoint: .leading, endPoint: .trailing)
            }
        //            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerSize: .init(width: 30, height: 30)))
            .scaleEffect(!configuration.isPressed ? 0.95 : 1.05)
    }
}
