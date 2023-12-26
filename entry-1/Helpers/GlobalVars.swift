//
//  GlobalVars.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/24/23.
//

import Foundation
import SwiftUI
import CoreHaptics


let vibration_heavy = UIImpactFeedbackGenerator(style: .heavy)
let vibration_light = UIImpactFeedbackGenerator(style: .light)
let vibration_medium = UIImpactFeedbackGenerator(style: .medium)

enum SortOption {
    case timeAscending
    case timeDescending
    case image
    case wordCount
}

var defaultBackgroundColor = Color(UIColor.systemGroupedBackground)
