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


struct AnimatedImageView_data: UIViewRepresentable {
    var data: Data
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let animatedView = FLAnimatedImageView()
        animatedView.contentMode = .scaleAspectFit
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
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AnimatedImageView_data>) {
        guard let animatedView = uiView.subviews.first as? FLAnimatedImageView else { return }
        
        let gif = FLAnimatedImage(animatedGIFData: data)
        animatedView.animatedImage = gif
    }
}





struct MediaView: UIViewRepresentable {

    //not async
    var data: Data

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFit

        let imageView = UIImageView()
        let animatedView = FLAnimatedImageView()

        imageView.translatesAutoresizingMaskIntoConstraints = false
        animatedView.translatesAutoresizingMaskIntoConstraints = false

        
        view.addSubview(imageView)
        view.addSubview(animatedView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            animatedView.topAnchor.constraint(equalTo: view.topAnchor),
            animatedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            animatedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animatedView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        
        
//        imageView.isHidden = true
//        animatedView.isHidden = true

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<MediaView>) {
        guard let imageView = uiView.subviews.first(where: { $0 is UIImageView }) as? UIImageView,
              let animatedView = uiView.subviews.first(where: { $0 is FLAnimatedImageView }) as? FLAnimatedImageView else {
            return
        }

        if isGIF(data: data) {
            print("IS GIF")
            let gif = FLAnimatedImage(animatedGIFData: data)
            animatedView.animatedImage = gif
            animatedView.isHidden = false
            imageView.isHidden = true
        } else {
            if let image = UIImage(data: data) {
                imageView.image = image
                imageView.isHidden = false
                animatedView.isHidden = true
            }
        }
    }

}
