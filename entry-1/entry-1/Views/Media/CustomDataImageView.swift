//
//  CustomDataImageView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/28/23.
//

import Foundation
import SwiftUI



struct CustomDataImageView: UIViewRepresentable {
    var imageData: Data
    
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
        
        // Update image data directly
        imageView.image = UIImage(data: imageData)
    }
}

