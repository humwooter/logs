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





class UserPreferences: ObservableObject {
    
    
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
    
    
    @Published var showLockScreen: Bool  {
        didSet {
            UserDefaults.standard.set(showLockScreen, forKey: "showLockScreen")
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

        let initialStamps = [
            Stamp(id: UUID(), name: "", color: Color(hex: "#FF5733"), imageName: "star.fill", isActive: false),
              Stamp(id: UUID(), name: "",color: Color(hex: "#33FF57"), imageName: "heart.fill", isActive: false),
              Stamp(id: UUID(), name: "",color: Color(hex: "#3357FF"), imageName: "bookmark.fill", isActive: false),
              Stamp(id: UUID(), name: "",color: Color(hex: "#AC33FF"), imageName: "lightbulb.fill", isActive: false),
              Stamp(id: UUID(), name: "",color: Color(hex: "#FF33AC"), imageName: "pencil", isActive: false),
              Stamp(id: UUID(), name: "",color: Color(hex: "#FFD133"), imageName: "flag.fill", isActive: false),
              Stamp(id: UUID(), name: "",color: Color(hex: "#33FFF3"), imageName: "bell.fill", isActive: false)
          ]
        
        
        self.showLinks = UserDefaults.standard.bool(forKey: "showLinks") ?? false
        
        self.stampStorage = UserDefaults.standard.loadStamps(forKey: "stampStorage") ?? []


        let additionalStamps = Array(repeating: Stamp(id: UUID(), name: "", color: .indigo, imageName: "pencil", isActive: false), count: 14)
          self.stamps = UserDefaults.standard.loadStamps(forKey: "stamps") ?? (initialStamps + additionalStamps)
      

        self.fontSize = CGFloat(UserDefaults.standard.float(forKey: "fontSize")) != 0.0 ? CGFloat(UserDefaults.standard.float(forKey: "fontSize")) : CGFloat(16)
        self.lineSpacing = 3.0
        self.fontName = UserDefaults.standard.string(forKey: "fontName") ?? "serif"
        self.activatedButtons = UserDefaults.standard.array(forKey: "activatedButtons") as? [Bool] ?? [true, false, false, false, false]
        self.selectedImages = UserDefaults.standard.array(forKey: "selectedImages") as? [String] ?? ["star.fill", "staroflife", "heart.fill", "book.fill", "gamecontroller.fill"]
        self.selectedColors = UserDefaults.standard.loadColors(forKey: "selectedColors") ?? [Color(hex: "#FFEFC2"), Color(hex: "#FFB1FF"), Color(hex: "#C8FFFF"), Color(hex: "#C2FFCB"), Color(hex: "#928CFF")]
        self.backgroundColors = UserDefaults.standard.loadColors(forKey: "backgroundColors") ?? [Color.clear, Color.clear]
        self.entryBackgroundColor =  UserDefaults.standard.color(forKey: "entryBackgroundColor") ?? Color.clear

        self.showLockScreen = UserDefaults.standard.bool(forKey: "showLockScreen") 
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
    

//    func saveStamps(stamps: [Stamp], forKey key: String) {
//        let uiColors = stamps.map { UIColor($0.color) }
//        let imageNames = stamps.map { $0.imageName }
//        let isActive = stamps.map { $0.isActive }
//        let colorData = uiColors.compactMap { try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false) }
//        set([colorData, imageNames, isActive], forKey: key)
//    }
    
    func saveStamps(stamps: [Stamp], forKey key: String) {
        let idStrings = stamps.map { $0.id.uuidString }
        let names = stamps.map { $0.name }
        let uiColors = stamps.map { UIColor($0.color) }
        let imageNames = stamps.map { $0.imageName }
        let isActive = stamps.map { $0.isActive }

        let colorData = uiColors.compactMap { try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false) }

        set([idStrings, names, colorData, imageNames, isActive], forKey: key)
    }


//    func loadStamps(forKey key: String) -> [Stamp]? {
//        
//  
//        guard let savedArray = array(forKey: key), savedArray.count == 3 else { return nil }
//        guard let colorData = savedArray[0] as? [Data], let imageNames = savedArray[1] as? [String], let isActive = savedArray[2] as? [Bool] else { return nil }
//
//        let uiColors = colorData.compactMap { try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: $0) }
//        let colors = uiColors.map { Color($0) }
//
//        return zip3(colors, imageNames, isActive).map { Stamp(color: $0, imageName: $1, isActive: $2) }
//    }
    
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
