//
//  TextFuncs.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 7/14/24.
//


import SwiftUI
import CoreData
import Foundation


func getIdealTextColor(userPreferences: UserPreferences, colorScheme: ColorScheme) -> Color {
    var entryBackgroundColor =  UIColor(userPreferences.entryBackgroundColor)
    var backgroundColor = isClear(for: UIColor(userPreferences.backgroundColors.first ?? Color.clear)) ? getDefaultBackgroundColor(colorScheme: colorScheme) : userPreferences.backgroundColors.first ?? Color.clear
    var blendedBackground = UIColor.blendedColor(from: entryBackgroundColor, with: UIColor(backgroundColor))
    return Color(UIColor.fontColor(forBackgroundColor: blendedBackground))
}

func getIdealTextColor(topColor: Color, bottomColor: Color, colorScheme: ColorScheme) -> Color {
    var blendedBackground = UIColor.blendedColor(from: UIColor(topColor), with: UIColor(bottomColor))
    return Color(UIColor.fontColor(forBackgroundColor: blendedBackground, colorScheme: colorScheme))
}
