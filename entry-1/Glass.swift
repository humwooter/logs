//
//  Glass.swift
//  entry-1
//
//  Created by Katya Raman on 8/17/23.
//

import Foundation
import UIKit
import SwiftUI


struct Blur: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}


//
//    .overlay {
//        if isShowingEntryCreationView {
//            ZStack {
//                VStack {
//                    Spacer()
//                    HStack {
//                        Spacer()
//
//                        TextField("", text: $entryContent, axis: .vertical).padding(50)
////                                        .frame(height: 500)
//
////                                    NewEntryView()
//                            .modifier(FlatGlassView())
//                        Spacer()
//                    }
//                    .padding(.horizontal, 5)
//                    Spacer()
//                }
//                .offset(y: dragOffset)
////                            VStack {
////                                HStack {
////                                    Button(action: {
////                                        withAnimation(.easeInOut(duration: 0.3)) {
////                                            isShowingEntryCreationView = false
////                                        }
////                                    }) {
////                                        Image(systemName: "arrow.left")
////                                            .padding()
////                                    }
////                                    .padding(.leading, 20)
////                                    .padding(.top, 20)
////                                    Spacer()
////                                }
////                                Spacer()
////                            }
//            }
//            .transition(AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
//            .animation(isShowingEntryCreationView ? .easeOut(duration: 0.3) : .easeIn(duration: 0.3))
//            .gesture(
//                          DragGesture()
//                              .onChanged { value in
//                                  dragOffset = value.translation.height
//                              }
//                              .onEnded { value in
//                                  if value.translation.height > 50 { // adjust as needed
//                                      isShowingEntryCreationView = false
//                                  }
//                                  dragOffset = 0
//                              }
//                      )
//        }
//    }


//                .overlay {
//                    Group {
//                        if isShowingEntryCreationView {
//                            VStack {
//                                Spacer() // This will push the HStack to the bottom
//                                HStack {
//                                    NewEntryView()
//                                        .modifier(FlatGlassView())
//                                }
//                                .padding(.horizontal, 10) // Add some padding on the sides
//                            }
//                            .transition(.move(edge: .bottom)) // This specifies the transition from the bottom
//                            .animation(.default) // This will animate the transition
//                        }
//                    }
//                }
