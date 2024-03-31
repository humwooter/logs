//
//  ThumbnailView.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 3/30/24.
//

import Foundation
import SwiftUI
import AVKit
import QuickLookThumbnailing



struct ThumbnailImageView: View {
    let url: URL

    @State private var thumbnail: CGImage? = nil

    var body: some View {
        Group {
            if thumbnail != nil {
                Image(self.thumbnail!, scale: (UIScreen.main.scale), label: Text("PDF"))
            } else {
                Image(systemName: "photo") // << any placeholder
                  .onAppear(perform: generateThumbnail) // << here !!
            }
        }
    }

    func generateThumbnail() {
        let size: CGSize = CGSize(width: 68, height: 88)
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: (UIScreen.main.scale), representationTypes: .all)
        let generator = QLThumbnailGenerator.shared

        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            DispatchQueue.main.async {
                if thumbnail == nil || error != nil {
                    assert(false, "Thumbnail failed to generate")
                } else {
                    DispatchQueue.main.async { // << required !!
                        self.thumbnail = thumbnail!.cgImage  // here !!
                    }
                }
            }
        }
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Update the view controller if needed.
    }
}


class ThumbnailGenerator: ObservableObject {
    @Published var thumbnail: UIImage?
    
    func generateThumbnail(for url: URL) -> Bool {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            
            let thumbnailTime = CMTimeMake(value: 7, timescale: 1)
            do {
                let cgThumbImage = try assetImgGenerate.copyCGImage(at: thumbnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    self.thumbnail = thumbImage
                }
                
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.thumbnail = nil
                }
            }
        }
        if let thumbnail = thumbnail {
            return true
        }
        return false
    }
}


// Thumbnail Generator Function
func generateThumbnail(url: URL, completion: @escaping (UIImage?) -> Void) {
    let asset = AVAsset(url: url)
    let assetImgGenerate = AVAssetImageGenerator(asset: asset)
    assetImgGenerate.appliesPreferredTrackTransform = true
    let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
    
    DispatchQueue.global().async {
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            DispatchQueue.main.async {
                completion(thumbnail)
            }
        } catch {
            // Handle the error by completing with nil, indicating failure
            print("Error generating thumbnail: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
}

// SwiftUI View
struct ThumbnailView: View {
    let videoURL: URL
    @State private var thumbnailImage: UIImage? = nil
    
    var body: some View {
        Group {
            if let image = thumbnailImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // Display nothing or a placeholder
                Text("Thumbnail not available")
            }
        }
        .onAppear {
            generateThumbnail(url: videoURL) { image in
                thumbnailImage = image
            }
        }
    }
}
