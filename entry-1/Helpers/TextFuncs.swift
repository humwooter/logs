//
//  TextFuncs.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/14/24.
//


import SwiftUI
import CoreData
import Foundation


//func getIdealTextColor(userPreferences: UserPreferences, colorScheme: ColorScheme) -> Color {
//    var entryBackgroundColor =  UIColor(userPreferences.entryBackgroundColor)
//    var backgroundColor = isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear
//    var blendedBackground = UIColor.blendedColor(from: entryBackgroundColor, with: UIColor(backgroundColor))
//    return Color(UIColor.fontColor(forBackgroundColor: blendedBackground))
//}


func getIdealTextColor(userPreferences: UserPreferences, colorScheme: ColorScheme) -> Color {
    
    var backgroundColor_top = userPreferences.backgroundColors.first ?? Color.clear
    var backgroundColor_bottom = userPreferences.backgroundColors[1]
    
    if isClear(for: UIColor(backgroundColor_top)) {
        backgroundColor_top = getDefaultBackgroundColor(colorScheme: colorScheme)
    }
    if isClear(for: UIColor(backgroundColor_bottom)) {
        backgroundColor_bottom = getDefaultBackgroundColor(colorScheme: colorScheme)
    }
    return getIdealTextColor(topColor: backgroundColor_top, bottomColor: backgroundColor_bottom, colorScheme: colorScheme)
}

func getIdealTextColor(topColor: Color, bottomColor: Color, colorScheme: ColorScheme) -> Color {
    let blendedBackground = UIColor.blendedColor(from: UIColor(topColor), with: UIColor(bottomColor))
    return Color(UIColor.fontColor(forBackgroundColor: blendedBackground, colorScheme: colorScheme))
}
