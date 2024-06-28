//
//  Stamp.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 1/22/24.
//

import Foundation
import CoreData
import SwiftUI
import UIKit

extension Color {
    // Convert Color to UIColor
    func toUIColor() -> UIColor {
        return UIColor(self)
    }
    
    // Initialize Color from UIColor
    init(uiColor: UIColor) {
        self.init(uiColor)
    }
}

struct Stamp: Codable {
    var id: UUID
    var index: Int
    var name: String
    var color: Color // SwiftUI's Color
    var imageName: String
    var isActive: Bool
    
    enum CodingKeys: CodingKey {
        case id, name, index, color, imageName, isActive
    }
    
    init(id: UUID, name: String, index: Int, color: Color, imageName: String, isActive: Bool) {
           self.id = id
           self.name = name
            self.index = index
           self.color = color
           self.imageName = imageName
           self.isActive = isActive
       }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        index = try container.decode(Int.self, forKey: .index)
        imageName = try container.decode(String.self, forKey: .imageName)
        
        // Decode color as Data and then convert to UIColor, and finally to Color
        let colorData = try container.decode(Data.self, forKey: .color)
        if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            color = Color(uiColor: uiColor)
        } else {
            color = Color.clear // Use a default color if decoding fails
        }
        
        isActive = try container.decode(Bool.self, forKey: .isActive)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(index, forKey: .index)
        try container.encode(imageName, forKey: .imageName)
        
        // Convert Color to UIColor, then to Data, and encode
        let uiColor = color.toUIColor()
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: true)
        try container.encode(colorData, forKey: .color)
        try container.encode(isActive, forKey: .isActive)
    }
}
