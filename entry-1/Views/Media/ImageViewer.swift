//
//  ImageViewer.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 11/7/23.
//

import Foundation
import SwiftUI
import AVFoundation
import AVKit
import UIKit

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


struct CustomAsyncImageView_uiImage: UIViewRepresentable { //not actually async
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

struct AsyncVideoView: UIViewRepresentable {
    var url: URL
    
    func makeUIView(context: Context) -> UIView {
        // Container view
        let view = UIView()
        
        // Initialize AVPlayer with a URL
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        
        // Set player layer properties
        playerLayer.videoGravity = .resizeAspect
        playerLayer.backgroundColor = UIColor.black.cgColor
        
        // Add player layer to view
        view.layer.addSublayer(playerLayer)
        playerLayer.frame = view.bounds
        
        // Auto-resize player layer on bounds change
//        playerLayer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Start playing the video
        player.play()
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update your view when needed
        // In most cases, updates might involve responding to changes in the URL or player settings.
    }
}
struct AsyncVideoViewFromData: UIViewRepresentable {
    var videoData: Data
    
    func makeUIView(context: Context) -> UIView {
        // Create a UIView container
        let view = UIView()
        view.backgroundColor = .black

        // Attempt to create a temporary URL to hold the video data
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        do {
            try videoData.write(to: tempURL)
        } catch {
            print("Failed to write video data to temporary file: \(error)")
            return view  // Return the empty view if the file cannot be created
        }

        // Create an AVAsset from the temporary file URL
        let asset = AVAsset(url: tempURL)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)

        // Configure the player layer
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspect
        playerLayer.backgroundColor = UIColor.black.cgColor
        
        // Add the player layer to the view's layer
        view.layer.addSublayer(playerLayer)
        
        // Set autoresizing masks
//        playerLayer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Start playback
        player.play()
        
        // Ensure the temporary file is deleted when the view is deinitialized
        context.coordinator.cleanup = {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // This function can be used to handle updates to the videoData
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var cleanup: (() -> Void)?
        deinit {
            cleanup?()
        }
    }
}
