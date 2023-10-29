//
//  CustomAsyncImageView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 9/24/23.
//

import Foundation
import SwiftUI


struct CustomAsyncImageView: UIViewRepresentable {
    var url: URL
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let asyncImageView = UIImageView()
        asyncImageView.contentMode = .scaleAspectFit
        asyncImageView.backgroundColor = .black
        view.addSubview(asyncImageView)
        asyncImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            asyncImageView.topAnchor.constraint(equalTo: view.topAnchor),
            asyncImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            asyncImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            asyncImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let imageView = uiView.subviews.first as? UIImageView else { return }
        
        Task {
            guard url.isFileURL else { return }
            
            // Load data directly from file
            if let data = try? Data(contentsOf: url) {
                imageView.image = UIImage(data: data)
            } else {
                print("Failed to load data from file at URL: \(url)")
            }
        }
    }
}

