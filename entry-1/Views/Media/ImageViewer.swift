//
//  ImageViewer.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 11/7/23.
//

import Foundation
import SwiftUI



struct ImageViewer: View {
    @State private var isLoading = true
    var selectedImage: UIImage?
    var imageFrameHeight: CGFloat

    var body: some View {
        ZStack {
            // Image display
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: imageFrameHeight)
                    .background(Color.black)
                    .onAppear {
                        // Image has appeared, so stop showing the progress view
                        isLoading = false
                    }
            }

            // Progress view
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2)
            }
        }
    }
}


struct CustomAsyncImageView_uiImage: UIViewRepresentable {
    var image: UIImage
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let asyncImageView = UIImageView()
        asyncImageView.contentMode = .scaleAspectFit
        asyncImageView.backgroundColor = .black
        asyncImageView.image = image // Set the image directly
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
        // You can handle any dynamic updates to the image here if needed.
        // Since the image is directly set in `makeUIView`, you might not need to update anything here.
    }
}
