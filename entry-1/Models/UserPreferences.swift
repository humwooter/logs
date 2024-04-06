//
//  UserPreferences.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/28/23.
//

import Foundation
import SwiftUI
import CoreData
import UIKit
import LocalAuthentication
import UniformTypeIdentifiers

extension KeyedDecodingContainer {
    func decodeColor(forKey key: K) throws -> Color {
        let colorData = try decode(Data.self, forKey: key)
        guard let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Color data corrupted or invalid")
        }
        return Color(uiColor: uiColor)
    }

    func decodeColors(forKey key: K) throws -> [Color] {
        var colors = [Color]()
        var container = try nestedUnkeyedContainer(forKey: key)
        while !container.isAtEnd {
            let colorData = try container.decode(Data.self)
            if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
                colors.append(Color(uiColor: uiColor))
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Color data corrupted or invalid")
            }
        }
        return colors
    }
}


func zip3<A, B, C>(_ array1: [A], _ array2: [B], _ array3: [C]) -> [(A, B, C)] {
    var result: [(A, B, C)] = []
    let count = min(array1.count, array2.count, array3.count)
    for i in 0..<count {
        result.append((array1[i], array2[i], array3[i]))
    }
    return result
}

func zip5<A, B, C, D, E>(_ array1: [A], _ array2: [B], _ array3: [C], _ array4: [D], _ array5: [E]) -> [(A, B, C, D, E)] {
    var result: [(A, B, C, D, E)] = []
    let count = min(array1.count, array2.count, array3.count, array4.count, array5.count)
    for i in 0..<count {
        result.append((array1[i], array2[i], array3[i], array4[i], array5[i]))
    }
    return result
}





class UserPreferences: ObservableObject, Codable {
    
    enum CodingKeys: CodingKey {
        case activatedButtons, selectedImages, selectedColors, backgroundColors, entryBackgroundColor, accentColor, pinColor, reminderColor, showLockScreen, showLinks, fontSize, lineSpacing, fontName, stamps, stampStorage, showMostRecentEntryTime, isFirstLaunch
    }
    
    
    private func encodeColors(container: inout KeyedEncodingContainer<CodingKeys>, colors: [Color], key: CodingKeys) throws {
        let uiColors = colors.map { UIColor($0) }
        let colorDataArray = try uiColors.map { try NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: true) }
        try container.encode(colorDataArray, forKey: key)
    }
    
    private func decodeColors(container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) throws -> [Color] {
        let colorDataArray = try container.decode([Data].self, forKey: key)
        return colorDataArray.compactMap { data -> Color? in
            guard let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else { return nil }
            return Color(uiColor: uiColor)
        }
    }
    
    
    private func decodeColor(container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) throws -> Color {
        let colorData = try container.decode(Data.self, forKey: key)
        guard let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Color data corrupted")
        }
        return Color(uiColor: uiColor)
    }
    
    private func encodeColor(container: inout KeyedEncodingContainer<CodingKeys>, color: Color, key: CodingKeys) throws {
        let uiColor = UIColor(color)
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: true)
        try container.encode(colorData, forKey: key)
    }
    
    
    func update(from preferences: UserPreferences) {
           DispatchQueue.main.async {
               self.activatedButtons = preferences.activatedButtons
               self.selectedImages = preferences.selectedImages
               self.selectedColors = preferences.selectedColors
               self.backgroundColors = preferences.backgroundColors
               self.entryBackgroundColor = preferences.entryBackgroundColor
               self.accentColor = preferences.accentColor
               self.pinColor = preferences.pinColor
               self.reminderColor = preferences.reminderColor
               self.showLockScreen = preferences.showLockScreen
               self.showLinks = preferences.showLinks
               self.fontSize = preferences.fontSize
               self.lineSpacing = preferences.lineSpacing
               self.fontName = preferences.fontName
//               self.stamps = preferences.stamps //don't update stamps for now
               self.stampStorage = preferences.stampStorage
           }
       }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stampStorage = try container.decode([Stamp].self, forKey: .stampStorage)
        self.stamps = try container.decode([Stamp].self, forKey: .stamps)

        // Decode Colors directly within the initializer
        self.entryBackgroundColor = try container.decodeColor(forKey: .entryBackgroundColor)
        self.accentColor = try container.decodeColor(forKey: .accentColor)
        self.pinColor = try container.decodeColor(forKey: .pinColor)
        self.reminderColor = try container.decodeColor(forKey: .reminderColor)
        self.backgroundColors = try container.decodeColors(forKey: .backgroundColors)
        self.selectedColors = try container.decodeColors(forKey: .selectedColors)
        
        // Decode other properties
        self.activatedButtons = try container.decode([Bool].self, forKey: .activatedButtons)
        self.selectedImages = try container.decode([String].self, forKey: .selectedImages)
        self.showLockScreen = try container.decode(Bool.self, forKey: .showLockScreen)
//        self.isFirstLaunch = try container.decode(Bool.self, forKey: .isFirstLaunch)
        self.isFirstLaunch = try container.decodeIfPresent(Bool.self, forKey: .isFirstLaunch) ?? false


        self.showLinks = try container.decode(Bool.self, forKey: .showLinks)
//        self.isUnlocked = try container.decode(Bool.self, forKey: .isUnlocked)
        self.fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
        self.lineSpacing = try container.decode(CGFloat.self, forKey: .lineSpacing)
        self.fontName = try container.decode(String.self, forKey: .fontName)
        self.showMostRecentEntryTime = try container.decode(Bool.self, forKey: .showMostRecentEntryTime)
    }


    
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode arrays of Stamps
        try container.encode(stamps, forKey: .stamps)
        try container.encode(stampStorage, forKey: .stampStorage)
        
        // Encode simple types
        try container.encode(activatedButtons, forKey: .activatedButtons)
        try container.encode(selectedImages, forKey: .selectedImages)
        
        // Encode Colors
        try encodeColor(container: &container, color: entryBackgroundColor, key: .entryBackgroundColor)
        try encodeColor(container: &container, color: accentColor, key: .accentColor)
        try encodeColor(container: &container, color: pinColor, key: .pinColor)
        try encodeColor(container: &container, color: reminderColor, key: .reminderColor)

        try encodeColors(container: &container, colors: backgroundColors, key: .backgroundColors)
        try encodeColors(container: &container, colors: selectedColors, key: .selectedColors)
        
        // Encode other properties
        try container.encode(showMostRecentEntryTime, forKey: .showMostRecentEntryTime)
        try container.encode(showLockScreen, forKey: .showLockScreen)
        try container.encode(showLinks, forKey: .showLinks)
//        try container.encode(isUnlocked, forKey: .isUnlocked)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(lineSpacing, forKey: .lineSpacing)
        try container.encode(fontName, forKey: .fontName)
    }
    
    
    
    @Published var stamps: [Stamp] {
        didSet {
            UserDefaults.standard.saveStamps(stamps: stamps, forKey: "stamps")
        }
    }
    
    @Published var stampStorage: [Stamp] {
        didSet {
            UserDefaults.standard.saveStamps(stamps: stampStorage, forKey: "stampStorage")
        }
    }
    
    
    @Published var activatedButtons: [Bool] = [true, false, false, false, false] {
        didSet {
            UserDefaults.standard.set(activatedButtons, forKey: "activatedButtons")
        }
    }
    
    @Published var selectedImages: [String] =  ["star.fill", "staroflife", "heart.fill", "book.fill", "gamecontroller.fill"] {
        didSet {
            UserDefaults.standard.set(selectedImages, forKey: "selectedImages")
        }
    }
    @Published var selectedColors: [Color] = [.yellow, .cyan, .pink, .green, .indigo] {
        didSet {
            UserDefaults.standard.saveColors(colors: selectedColors, forKey: "selectedColors")
        }
    }
    
    
    @Published var backgroundColors: [Color] = [Color.clear, Color.clear] {
        didSet {
            UserDefaults.standard.saveColors(colors: backgroundColors, forKey: "backgroundColors")
        }
    }
    
    @Published var entryBackgroundColor: Color = Color.clear {
        didSet {
            UserDefaults.standard.setColor(color: entryBackgroundColor, forKey: "entryBackgroundColor")
        }
    }
    
    @Published var accentColor: Color {
        didSet {
            UserDefaults.standard.setColor(color: accentColor, forKey: "accentColor")
        }
    }
    
    @Published var pinColor: Color {
        didSet {
            UserDefaults.standard.setColor(color: pinColor, forKey: "pinColor")
        }
    }
    
    @Published var reminderColor: Color {
        didSet {
            UserDefaults.standard.setColor(color: reminderColor, forKey: "reminderColor")
        }
    }
    
    
    @Published var showLockScreen: Bool  {
        didSet {
            UserDefaults.standard.set(showLockScreen, forKey: "showLockScreen")
        }
    }
    
    @Published var isFirstLaunch: Bool  {
        didSet {
            UserDefaults.standard.set(isFirstLaunch, forKey: "isFirstLaunch")
        }
    }
    
    @Published var showMostRecentEntryTime: Bool  {
        didSet {
            UserDefaults.standard.set(showMostRecentEntryTime, forKey: "showMostRecentEntryTime")
        }
    }
    
    
    @Published var showLinks: Bool = false {
        didSet {
            UserDefaults.standard.set(showLinks, forKey: "showLinks")
        }
    }
    
    @Published var isUnlocked: Bool = false
    
    @Published var fontSize: CGFloat {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }
    
    @Published var lineSpacing: CGFloat {
        didSet {
            UserDefaults.standard.set(lineSpacing, forKey: "lineSpacing")
        }
    }
    
    @Published var fontName: String {
        didSet {
            UserDefaults.standard.set(fontName, forKey: "fontName")
        }
    }
    
    
    
    init() {
        self.accentColor = UserDefaults.standard.color(forKey: "accentColor") ?? Color.blue
        self.pinColor = UserDefaults.standard.color(forKey: "pinColor") ?? Color.red
        self.reminderColor = UserDefaults.standard.color(forKey: "reminderColor") ?? Color.teal

        
        let initialStamps = [
            Stamp(id: UUID(), name: "", color: Color.yellow, imageName: "star.fill", isActive: true),
            Stamp(id: UUID(), name: "",color: Color(hex: "#33FF57"), imageName: "heart.fill", isActive: false),
            Stamp(id: UUID(), name: "",color: Color(hex: "#3357FF"), imageName: "bookmark.fill", isActive: false),
            Stamp(id: UUID(), name: "",color: Color(hex: "#AC33FF"), imageName: "lightbulb.fill", isActive: false),
            Stamp(id: UUID(), name: "",color: Color(hex: "#FF33AC"), imageName: "pencil", isActive: false),
            Stamp(id: UUID(), name: "",color: Color(hex: "#FFD133"), imageName: "flag.fill", isActive: false),
            Stamp(id: UUID(), name: "",color: Color(hex: "#33FFF3"), imageName: "bell.fill", isActive: false)
        ]
        
        
        self.showLinks = UserDefaults.standard.bool(forKey: "showLinks") ?? false
        
        self.stampStorage = UserDefaults.standard.loadStamps(forKey: "stampStorage") ?? []
        
        
        let additionalStamps = Array(repeating: Stamp(id: UUID(), name: "", color: Color.blue, imageName: "pencil", isActive: false), count: 14)
        self.stamps = UserDefaults.standard.loadStamps(forKey: "stamps") ?? (initialStamps + additionalStamps)
        
        
        self.fontSize = CGFloat(UserDefaults.standard.float(forKey: "fontSize")) != 0.0 ? CGFloat(UserDefaults.standard.float(forKey: "fontSize")) : CGFloat(16)
        self.lineSpacing = 3.0
        self.fontName = UserDefaults.standard.string(forKey: "fontName") ?? "Helvetica"
        self.activatedButtons = UserDefaults.standard.array(forKey: "activatedButtons") as? [Bool] ?? [true, false, false, false, false]
        self.selectedImages = UserDefaults.standard.array(forKey: "selectedImages") as? [String] ?? ["star.fill", "staroflife", "heart.fill", "book.fill", "gamecontroller.fill"]
        self.selectedColors = UserDefaults.standard.loadColors(forKey: "selectedColors") ?? [Color(hex: "#FFEFC2"), Color(hex: "#FFB1FF"), Color(hex: "#C8FFFF"), Color(hex: "#C2FFCB"), Color(hex: "#928CFF")]
        self.backgroundColors = UserDefaults.standard.loadColors(forKey: "backgroundColors") ?? [Color.clear, Color.clear]
        self.entryBackgroundColor =  UserDefaults.standard.color(forKey: "entryBackgroundColor") ?? Color.clear
        
        self.showLockScreen = UserDefaults.standard.bool(forKey: "showLockScreen")
        

        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
         if !hasLaunchedBefore  {
             print("First launch, setting UserDefault.")
             UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
             self.isFirstLaunch = true
         } else {
             print("Not first launch.")
             self.isFirstLaunch = false
         }
        
        self.showMostRecentEntryTime = UserDefaults.standard.bool(forKey: "showMostRecentEntryTime")
    }
}


extension UserDefaults {
    
    func saveColors(colors: [Color], forKey key: String) {
        let uiColors = colors.map { UIColor($0) }
        let data = uiColors.compactMap { try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false) }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func loadColors(forKey key: String) -> [Color]? {
        guard let data = array(forKey: key) as? [Data] else { return nil }
        let uiColors = data.compactMap { data -> UIColor? in
            do {
                return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
            } catch {
                print("Failed to unarchive UIColor: \(error)")
                return nil
            }
        }
        return uiColors.map { Color($0) }
    }
    
    func setColor(color: Color, forKey key: String) {
        let uiColor = UIColor(color)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
            set(data, forKey: key)
        } catch {
            print("Error archiving color: \(error)")
        }
    }
    
    func color(forKey key: String) -> Color? {
        guard let data = data(forKey: key) else { return nil }
        
        do {
            if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
                return Color(uiColor) // Assuming there's a Color initializer that takes a UIColor
            }
        } catch {
            print("Failed to unarchive UIColor: \(error)")
        }
        
        return nil
    }
    
    
    func saveStamps(stamps: [Stamp], forKey key: String) {
        let idStrings = stamps.map { $0.id.uuidString }
        let names = stamps.map { $0.name }
        let uiColors = stamps.map { UIColor($0.color) }
        let imageNames = stamps.map { $0.imageName }
        let isActive = stamps.map { $0.isActive }
        
        let colorData = uiColors.compactMap { try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false) }
        
        set([idStrings, names, colorData, imageNames, isActive], forKey: key)
    }
    
    
    
    func loadStamps(forKey key: String) -> [Stamp]? {
        guard let savedArray = array(forKey: key), savedArray.count == 5 else { return nil }
        guard let idStrings = savedArray[0] as? [String],
              let names = savedArray[1] as? [String],
              let colorData = savedArray[2] as? [Data],
              let imageNames = savedArray[3] as? [String],
              let isActive = savedArray[4] as? [Bool] else { return nil }
        
        let ids = idStrings.compactMap { UUID(uuidString: $0) }
        let uiColors = colorData.compactMap { try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: $0) }
        let colors = uiColors.map { Color($0) }
        
        return zip5(ids, names, colors, imageNames, isActive).map { Stamp(id: $0, name: $1, color: $2, imageName: $3, isActive: $4) }
    }
    
    
}


extension UserPreferences {
    static func importFromJson(from url: URL) throws -> UserPreferences {
           let data = try Data(contentsOf: url)
           let decoder = JSONDecoder()
           
           let userPreferences = try decoder.decode(UserPreferences.self, from: data)
           return userPreferences
       }
    
    func exportToJson() throws -> URL {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // For readability
        
        let data = try encoder.encode(self)
        
        // Define the file URL to save the data to (e.g., in the Documents directory)
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = urls[0].appendingPathComponent("UserPreferences.json")
        
        try data.write(to: fileURL)
        
        return fileURL
    }
    
     
}
