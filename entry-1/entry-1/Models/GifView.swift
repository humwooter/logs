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
    var url: URL
    
    func makeUIView(context: Context) -> UIView {
            let view = UIView()
            let animatedView = FLAnimatedImageView()
            animatedView.contentMode = .scaleAspectFit
            animatedView.backgroundColor = .black
            view.addSubview(animatedView)
            animatedView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                animatedView.topAnchor.constraint(equalTo: view.topAnchor),
                animatedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                animatedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                animatedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])

            return view
        }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AnimatedImageView>) {
            guard let animatedView = uiView.subviews.first as? FLAnimatedImageView else { return }

            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let gif = FLAnimatedImage(animatedGIFData: data)
                    animatedView.animatedImage = gif
                } catch {
                    // Handle error if needed
                    print("Could not get data for GIF file located at \(url.absoluteString)")
                }
            }
        }
    }


