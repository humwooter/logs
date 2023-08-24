//
//  GifView.swift
//  entry-1
//
//  Created by Katya Raman on 8/24/23.
//

import Foundation
import UIKit
import FLAnimatedImage
import SwiftUI


struct AnimatedImageView: UIViewRepresentable {
    let animatedView = FLAnimatedImageView()
    var url: URL



    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let gifData = try! Data(contentsOf: url)
        let gif = FLAnimatedImage(gifData: gifData)
        animatedView.animatedImage = gif
        
        
        animatedView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animatedView)
        NSLayoutConstraint.activate([
            animatedView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animatedView.widthAnchor.constraint(equalTo: view.widthAnchor),

        ])
        return view

      }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AnimatedImageView>) {
        
    }
//
//    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AnimatedImageView>) {
//        let data = try? Data(contentsOf: url)
//        let animatedImage = FLAnimatedImage(animatedGIFData: data)
//
//        uiView.animatedImage = animatedImage
//    }
}
