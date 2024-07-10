////
////  CustomPicker.swift
////  LessWrong iOS
////
////  Created by Katyayani G. Raman on 6/6/24.
////
//
//import Foundation
//import UIKit
//import SwiftUI
//
//struct HorizontalPicker: View {
//    @Binding var selectedOption: PickerOptions
//    var animation: Namespace.ID
//    @Environment(\.customFont) var customFont: Font
//
//    @State private var underlineWidth: CGFloat = 0
//    @State private var underlineX: CGFloat = 0
//    var selectedColor = Color.red
//    @Environment(\.colorScheme) var colorScheme
//
//    var body: some View {
//        var unselectedColor: Color {
//            return colorScheme == .dark ? Color.white : Color.black
//        }
//        VStack {
//            HStack(alignment: .center) {
//                ForEach(PickerOptions.allCases, id: \.self) { option in
//                    GeometryReader { geo in
//                        Button(action: {
//                            withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
//                                selectedOption = option
//                                underlineWidth = geo.size.width
//                                underlineX = geo.frame(in: .global).minX - (UIScreen.main.bounds.width / 2) + (underlineWidth / 2)
//                            }
//                        }) {
//                            VStack {
//                                if option.rawValue != "Settings" && option.rawValue != "Search" && option.rawValue != "Bookmark" {
//                                    Text(option.rawValue)
//                                        .foregroundColor(selectedOption == option ? selectedColor : unselectedColor)
//                                } else if option.rawValue == "Search" {
//                                    Image(systemName: "magnifyingglass")
//                                        .foregroundColor(selectedOption == option ? selectedColor : unselectedColor)
//                                } else if option.rawValue == "Bookmark" {
//                                    Image(systemName: "bookmark.fill")
//                                        .foregroundColor(selectedOption == option ? selectedColor : unselectedColor)
//                                } else {
//                                    Image(systemName: "gearshape.fill")
//                                        .foregroundColor(selectedOption == option ? selectedColor : unselectedColor)
//                                }
//                                if selectedOption == option {
//                                    Circle()
//                                        .fill(selectedColor)
//                                        .frame(width: 6, height: 6)
//                                        .offset(y: 4)
//                                        .matchedGeometryEffect(id: "underline", in: animation)
//                                }
//                            }
//                            .padding(.horizontal)
//                            .background(
//                                Group {
//                                    if selectedOption == option {
//                                        Color.clear // This is needed for matchedGeometryEffect
//                                    }
//                                }
//                            )
//                        }
//                        .onAppear {
//                            if selectedOption == option {
//                                underlineWidth = geo.size.width
//                                underlineX = geo.frame(in: .global).minX - (UIScreen.main.bounds.width / 2) + (underlineWidth / 2)
//                            }
//                        }
//                    }
//                    .frame(maxWidth: 65, minHeight: 40)
//                    .font(customFont)
//                }
//            }
//            .frame(maxWidth: .infinity)
//        }
//    }
//}
