//
//  RainbowAnimatedView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/27/23.
//

import Foundation
import SwiftUI
import CoreData
import Speech
import AVFoundation
import Photos
import CoreHaptics
import PhotosUI
import FLAnimatedImage


//struct RainbowIconView_animated: View {
//    @ObservedObject var entry: Entry
//    @State var gradientRadius: CGFloat = 60
//    @EnvironmentObject var userPreferences: UserPreferences
//
//    let timer = Timer.publish(every: 2, on: .main, in: .default).autoconnect()
//
//    var body: some View {
//        HStack {
//            Spacer()
//
//            if entry.color != UIColor.tertiarySystemBackground {
//                Image(systemName: entry.image)
//                    .resizable()
//                    .frame(width: 20, height: 20)
//                    .overlay(
//                        RadialGradient(gradient: Gradient(colors: userPreferences.selectedColors), center: .bottomTrailing, startRadius: -1, endRadius: gradientRadius)
//                            .animation(Animation.easeInOut(duration:0.1).repeatForever(autoreverses: true))
//                            .onReceive(timer, perform: { _ in
//                                self.gradientRadius  = self.gradientRadius * 0.5
//                            })
//                            .mask(
//                                Image(systemName: entry.image)
//                                    .resizable()
//                                    .frame(width: 20, height: 20)
//                            )
//                    )
//                    .padding(.top, 2)
//            }
//        }
//    }
//}

struct RainbowIconView_animated: View {
    @ObservedObject var entry: Entry
    @EnvironmentObject var userPreferences: UserPreferences
    @State var hueRotationValue = 0.0

    let timer = Timer.publish(every: 8, on: .main, in: .default).autoconnect()

    var body: some View {
        HStack {
            Spacer()
            
            if entry.color != UIColor.tertiarySystemBackground {
                Label("", systemImage: entry.image)
                    .overlay(
                        LinearGradient(gradient: Gradient(colors: userPreferences.selectedColors), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 1))
                            .hueRotation(Angle(degrees: self.hueRotationValue))
                            .animation(Animation.easeIn(duration: 2).repeatForever(autoreverses: true))
                            .onReceive(timer, perform: { _ in
                                if self.hueRotationValue == 0.0 {
                                    self.hueRotationValue = 360.0
                                } else {
                                    self.hueRotationValue = 0.0
                                }
                            })
                            .mask(Label("", systemImage: entry.image))
                    )
                    .padding(.top, 2)
                    .padding(.trailing, 1)
                    .shadow(radius: 2)
            }
        }
    }
}


//struct RainbowIconView_animated: View {
//    @ObservedObject var entry: Entry
//    @EnvironmentObject var userPreferences: UserPreferences
//    @State var start = UnitPoint(x: 0, y: -1.5)
//    @State var end = UnitPoint(x: 0, y: 3)
//    @State var hueRotationValue = 0.0
//     @State var saturationValue = 1.0
//
//    let timer = Timer.publish(every: 0.8, on: .main, in: .default).autoconnect()
////    let colors: [Color] = userPreferences.selectedColors
//
//    var body: some View {
//        HStack {
//            Spacer()
//
//            if entry.color != UIColor.tertiarySystemBackground {
//                Label("", systemImage: entry.image)
////                    .resizable()
////                    .frame(width: 10, height: 10)  // Assuming a specific size; adjust as needed
//                    .overlay(
//                        LinearGradient(gradient: Gradient(colors: userPreferences.selectedColors), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 1))
////                            .blur(radius: 0.5)
//                            .hueRotation(Angle(degrees: self.hueRotationValue))
//
//                            .animation(Animation.easeIn(duration: 0.7).repeatForever(autoreverses: true).speed(1))
//                            .onReceive(timer, perform: { _ in
//                                self.hueRotationValue = 120
////                                self.start = UnitPoint(x: -4, y: 20)
////                                self.start = UnitPoint(x: 4, y: 0)
//                            })
//                            .mask(
////                                Image(systemName: entry.image)
////                                    .resizable()
////                                    .frame(width: 10, height: 10)
//                                Label("", systemImage: entry.image)
//
//                            )
//                    )
//                    .padding(.top, 2)
//                    .padding(.trailing, 1)
//                    .shadow(radius: 2)
//            }
//        }
//    }
//}
