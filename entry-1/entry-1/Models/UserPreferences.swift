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




struct Stamp {
    let color: Color
    let imageName: String
}



class UserPreferences: ObservableObject {
    
    @Published var activatedButtons: [Bool] = [true, false, false, false, false] {
        didSet {
            UserDefaults.standard.set(activatedButtons, forKey: "activatedButtons")
        }
    }
    
    
    @Published var stamps: [Stamp] {
         didSet {
             UserDefaults.standard.saveStamps(stamps: stamps, forKey: "stamps")
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
    
    @Published var accentColor: Color {
        didSet {
            UserDefaults.standard.setColor(color: accentColor, forKey: "accentColor")
        }
    }
    @Published var backgroundColor: Color {
        didSet {
            UserDefaults.standard.setColor(color: backgroundColor, forKey: "backgroundColor")
        }
    }
    
    @Published var showLockScreen: Bool  {
        didSet {
            UserDefaults.standard.set(showLockScreen, forKey: "showLockScreen")
        }
    }
    @Published var isUnlocked: Bool = false
    
    @Published var fontSize: CGFloat {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }
    @Published var fontName: String {
        didSet {
            UserDefaults.standard.set(fontName, forKey: "fontName")
        }
    }
    
    
    init() {
        self.stamps = UserDefaults.standard.loadStamps(forKey: "stamps") ?? [Stamp(color: Color.yellow, imageName: "star.fill"), /* ... */]

        self.accentColor = UserDefaults.standard.color(forKey: "accentColor") ?? Color.blue
        self.fontSize = CGFloat(UserDefaults.standard.float(forKey: "fontSize")) != 0.0 ? CGFloat(UserDefaults.standard.float(forKey: "fontSize")) : CGFloat(16)
        self.fontName = UserDefaults.standard.string(forKey: "fontName") ?? "serif"
        self.activatedButtons = UserDefaults.standard.array(forKey: "activatedButtons") as? [Bool] ?? [true, false, false, false, false]
        self.selectedImages = UserDefaults.standard.array(forKey: "selectedImages") as? [String] ?? ["star.fill", "staroflife", "heart.fill", "book.fill", "gamecontroller.fill"]
//        self.selectedColors = UserDefaults.standard.loadColors(forKey: "selectedColors") ?? [.complementaryColor(of: .pink), .cyan, .complementaryColor(of: .red), .green, .indigo]
        self.selectedColors = UserDefaults.standard.loadColors(forKey: "selectedColors") ?? [Color(hex: "#FFEFC2"), Color(hex: "#FFB1FF"), Color(hex: "#C8FFFF"), Color(hex: "#C2FFCB"), Color(hex: "#928CFF")]
        self.showLockScreen = UserDefaults.standard.bool(forKey: "showLockScreen") ?? false
        self.backgroundColor = Color(.clear)
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
          let uiColors = stamps.map { UIColor($0.color) }
          let imageNames = stamps.map { $0.imageName }
          let colorData = uiColors.compactMap { try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false) }
          set([colorData, imageNames], forKey: key)
      }
      
      func loadStamps(forKey key: String) -> [Stamp]? {
          guard let savedArray = array(forKey: key) as? [Any], savedArray.count == 2 else { return nil }
          guard let colorData = savedArray[0] as? [Data], let imageNames = savedArray[1] as? [String] else { return nil }
          
          let uiColors = colorData.compactMap { try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: $0) }
          let colors = uiColors.map { Color($0) }
          
          return zip(colors, imageNames).map { Stamp(color: $0, imageName: $1) }
      }
}
